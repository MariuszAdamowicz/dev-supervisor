import CryptoKit
import Foundation

extension PlaybookRuntimeFileSystem {
    func createOpInstance(_ request: RuntimeCreateOpRequest, projectRoot: URL) throws -> RuntimeOpSnapshot {
        let eventID = nextProcessEventID(projectRoot: projectRoot)
        let createdAt = timestamp()
        let event = RuntimeProcessEvent(
            eventID: eventID,
            opID: request.opID,
            opType: request.opType,
            eventType: "op.created",
            payloadHash: hash([
                "op_id": .string(request.opID),
                "op_type": .string(request.opType),
                "state": .string(request.state),
            ]),
            actor: request.actor,
            ts: createdAt,
            idempotencyKey: "\(request.opID)|1|created",
            fromState: nil,
            toState: request.state,
            gateDecisionID: nil
        )
        let snapshot = RuntimeOpSnapshot(
            opID: request.opID,
            opType: request.opType,
            opVersion: 1,
            state: request.state,
            owner: request.owner,
            createdAt: createdAt,
            updatedAt: createdAt,
            links: request.links,
            tags: request.tags,
            lastEventID: eventID,
            payload: request.payload
        )

        try writeSnapshot(snapshot, projectRoot: projectRoot)
        try appendProcessEvent(event, projectRoot: projectRoot)
        return snapshot
    }

    func applyTransition(_ request: RuntimeTransitionRequest, projectRoot: URL) throws -> RuntimeOpSnapshot {
        guard let latest = try latestSnapshot(for: request.opID, projectRoot: projectRoot) else {
            throw RuntimeError(message: "Missing runtime snapshot for \(request.opID).")
        }

        guard latest.state == request.expectedFromState else {
            throw RuntimeError(message: "Illegal transition for \(request.opID): expected \(request.expectedFromState), got \(latest.state).")
        }

        let nextVersion = latest.opVersion + 1
        try appendProcessEvent(
            makeTransitionAttemptEvent(request, latest: latest, nextVersion: nextVersion, projectRoot: projectRoot),
            projectRoot: projectRoot
        )
        let gateDecisionID = try recordGateIfNeeded(request, latest: latest, nextVersion: nextVersion, projectRoot: projectRoot)

        let commitEvent = makeTransitionCommitEvent(
            request,
            latest: latest,
            nextVersion: nextVersion,
            projectRoot: projectRoot,
            gateDecisionID: gateDecisionID
        )
        let updatedSnapshot = RuntimeOpSnapshot(
            opID: latest.opID,
            opType: latest.opType,
            opVersion: nextVersion,
            state: request.toState,
            owner: latest.owner,
            createdAt: latest.createdAt,
            updatedAt: commitEvent.ts,
            links: latest.links,
            tags: latest.tags,
            lastEventID: commitEvent.eventID,
            payload: latest.payload
        )

        try writeSnapshot(updatedSnapshot, projectRoot: projectRoot)
        try appendProcessEvent(commitEvent, projectRoot: projectRoot)
        return updatedSnapshot
    }

    func writeDecisionEnvelope(
        projectRoot: URL,
        opID: String,
        sequence: Int,
        envelope: RuntimeDecisionEnvelope
    ) throws -> String {
        let directory = opDirectory(for: opID, projectRoot: projectRoot).appendingPathComponent("envelopes")
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent(String(format: "%06d.json", sequence))
        let data = try makeEncoder().encode(envelope)
        try data.write(to: url, options: .atomic)
        return url.path
    }
}

private extension PlaybookRuntimeFileSystem {
    func makeTransitionAttemptEvent(
        _ request: RuntimeTransitionRequest,
        latest: RuntimeOpSnapshot,
        nextVersion: Int,
        projectRoot: URL
    ) -> RuntimeProcessEvent {
        RuntimeProcessEvent(
            eventID: nextProcessEventID(projectRoot: projectRoot),
            opID: request.opID,
            opType: latest.opType,
            eventType: "transition.attempted",
            payloadHash: transitionPayloadHash(request),
            actor: request.actor,
            ts: timestamp(),
            idempotencyKey: "\(request.opID)|\(nextVersion)|attempt",
            fromState: request.expectedFromState,
            toState: request.toState,
            gateDecisionID: nil
        )
    }

    func recordGateIfNeeded(
        _ request: RuntimeTransitionRequest,
        latest: RuntimeOpSnapshot,
        nextVersion: Int,
        projectRoot: URL
    ) throws -> String? {
        guard let gate = request.gate else {
            return nil
        }

        let decision = RuntimeGateDecision(
            decisionID: nextGateDecisionID(projectRoot: projectRoot),
            opID: request.opID,
            gateType: "transition_gate",
            decision: gate.decision.rawValue,
            reason: gate.reason,
            actor: gate.actor,
            ts: timestamp(),
            idempotencyKey: "\(request.opID)|\(nextVersion)|gate"
        )
        try appendGateDecision(decision, projectRoot: projectRoot)

        let event = RuntimeProcessEvent(
            eventID: nextProcessEventID(projectRoot: projectRoot),
            opID: request.opID,
            opType: latest.opType,
            eventType: "gate.recorded",
            payloadHash: hash([
                "decision": .string(gate.decision.rawValue),
                "reason": .string(gate.reason),
            ]),
            actor: gate.actor,
            ts: timestamp(),
            idempotencyKey: "\(request.opID)|\(nextVersion)|gate-recorded",
            fromState: nil,
            toState: nil,
            gateDecisionID: decision.decisionID
        )
        try appendProcessEvent(event, projectRoot: projectRoot)
        return decision.decisionID
    }

    func makeTransitionCommitEvent(
        _ request: RuntimeTransitionRequest,
        latest: RuntimeOpSnapshot,
        nextVersion: Int,
        projectRoot: URL,
        gateDecisionID: String?
    ) -> RuntimeProcessEvent {
        RuntimeProcessEvent(
            eventID: nextProcessEventID(projectRoot: projectRoot),
            opID: request.opID,
            opType: latest.opType,
            eventType: "transition.committed",
            payloadHash: transitionPayloadHash(request),
            actor: request.actor,
            ts: timestamp(),
            idempotencyKey: "\(request.opID)|\(nextVersion)|commit",
            fromState: request.expectedFromState,
            toState: request.toState,
            gateDecisionID: gateDecisionID
        )
    }

    func transitionPayloadHash(_ request: RuntimeTransitionRequest) -> String {
        hash([
            "event": .string(request.event),
            "from_state": .string(request.expectedFromState),
            "to_state": .string(request.toState),
        ])
    }
}

extension PlaybookRuntimeFileSystem {
    func latestSnapshot(for opID: String, projectRoot: URL) throws -> RuntimeOpSnapshot? {
        let versionsURL = opDirectory(for: opID, projectRoot: projectRoot).appendingPathComponent("versions")
        guard fileManager.fileExists(atPath: versionsURL.path) else {
            return nil
        }

        let versions = try fileManager.contentsOfDirectory(at: versionsURL, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        guard let latestURL = versions.last else {
            return nil
        }

        return try decode(RuntimeOpSnapshot.self, from: latestURL)
    }

    func latestVersion(for opID: String, projectRoot: URL) -> Int {
        (try? latestSnapshot(for: opID, projectRoot: projectRoot)?.opVersion) ?? 0
    }

    func writeSnapshot(_ snapshot: RuntimeOpSnapshot, projectRoot: URL) throws {
        let versionsURL = opDirectory(for: snapshot.opID, projectRoot: projectRoot).appendingPathComponent("versions")
        try fileManager.createDirectory(at: versionsURL, withIntermediateDirectories: true)
        let fileURL = versionsURL.appendingPathComponent(String(format: "%06d.json", snapshot.opVersion))
        guard !fileManager.fileExists(atPath: fileURL.path) else {
            throw RuntimeError(message: "Runtime snapshot already exists: \(fileURL.path)")
        }

        let data = try makeEncoder().encode(snapshot)
        try data.write(to: fileURL, options: .atomic)
        try writeOpIndex(projectRoot: projectRoot)
    }

    func appendProcessEvent(_ event: RuntimeProcessEvent, projectRoot: URL) throws {
        let opURL = opDirectory(for: event.opID, projectRoot: projectRoot)
        try appendRecord(event, to: opURL.appendingPathComponent("events.ndjson"))
        try appendRecord(event, to: projectRoot.appendingPathComponent(".ai/runtime/v1/process-events.ndjson"))
    }

    func appendGateDecision(_ gate: RuntimeGateDecision, projectRoot: URL) throws {
        let opURL = opDirectory(for: gate.opID, projectRoot: projectRoot)
        try appendRecord(gate, to: opURL.appendingPathComponent("gates.ndjson"))
        try appendRecord(gate, to: projectRoot.appendingPathComponent(".ai/runtime/v1/gate-decisions.ndjson"))
    }

    func appendEvidence(_ evidence: RuntimeEvidenceRecord, projectRoot: URL) throws {
        try appendRecord(evidence, to: projectRoot.appendingPathComponent(".ai/runtime/v1/evidence.ndjson"))
    }

    func appendRecord<Record: Codable & IdempotentRuntimeRecord>(_ record: Record, to url: URL) throws {
        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let encoded = try String(decoding: makeEncoder().encode(record), as: UTF8.self)

        guard fileManager.fileExists(atPath: url.path) else {
            try (encoded + "\n").write(to: url, atomically: true, encoding: .utf8)
            return
        }

        let existingText = try String(contentsOf: url, encoding: .utf8)
        let lines = existingText
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .filter { !$0.isEmpty }

        for line in lines where line.contains("\"idempotency_key\":\"\(record.idempotencyKey)\"") {
            if line == encoded {
                return
            }
            throw RuntimeError(message: "Idempotency conflict for \(record.idempotencyKey).")
        }

        try (existingText + encoded + "\n").write(to: url, atomically: true, encoding: .utf8)
    }

    func opDirectory(for opID: String, projectRoot: URL) -> URL {
        projectRoot.appendingPathComponent(".ai/runtime/v1/ops/\(opID)")
    }

    func nextSequentialOpID(prefix: String, projectRoot: URL) -> String {
        let opsRoot = projectRoot.appendingPathComponent(".ai/runtime/v1/ops")
        let existing = (try? fileManager.contentsOfDirectory(atPath: opsRoot.path)) ?? []
        let numbers = existing.compactMap { entry -> Int? in
            guard entry.hasPrefix("\(prefix).") else {
                return nil
            }
            return Int(entry.replacingOccurrences(of: "\(prefix).", with: ""))
        }
        let next = (numbers.max() ?? 0) + 1
        return "\(prefix).\(String(format: "%04d", next))"
    }

    func nextProcessEventID(projectRoot: URL) -> String {
        let count = countLines(at: projectRoot.appendingPathComponent(".ai/runtime/v1/process-events.ndjson"))
        return String(format: "evt_%04d", count + 1)
    }

    func nextGateDecisionID(projectRoot: URL) -> String {
        let count = countLines(at: projectRoot.appendingPathComponent(".ai/runtime/v1/gate-decisions.ndjson"))
        return String(format: "gate_%04d", count + 1)
    }

    func nextEvidenceID(projectRoot: URL) -> String {
        let count = countLines(at: projectRoot.appendingPathComponent(".ai/runtime/v1/evidence.ndjson"))
        return String(format: "evidence_%04d", count + 1)
    }

    func countLines(at url: URL) -> Int {
        guard let text = try? String(contentsOf: url, encoding: .utf8), !text.isEmpty else {
            return 0
        }
        return text.split(whereSeparator: \.isNewline).count
    }

    func decode<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }

    func remoteRepositoryLinks(_ remoteURL: String?) -> [RuntimeLink] {
        guard let remoteURL, !remoteURL.isEmpty else {
            return []
        }
        return [RuntimeLink(rel: "git_remote", target: remoteURL)]
    }

    func baselineChangeSet(projectRoot: URL) -> [String] {
        [
            projectRoot.appendingPathComponent(".ai/prd/overview.md").path,
            projectRoot.appendingPathComponent(".ai/prd/constraints.md").path,
            projectRoot.appendingPathComponent(".ai/prd/glossary.md").path,
            projectRoot.appendingPathComponent(".ai/adr/0001-project-baseline.md").path,
            projectRoot.appendingPathComponent(".ai/architecture/use-cases.md").path,
            projectRoot.appendingPathComponent(".ai/architecture/port-contracts.md").path,
            projectRoot.appendingPathComponent(".ai/architecture/component-map.md").path,
            projectRoot.appendingPathComponent(".ai/ux/new-project.md").path,
            projectRoot.appendingPathComponent(".ai/runtime/v1/op-index.json").path,
            projectRoot.appendingPathComponent(".ai/runtime/v1/ops/project.ds").path,
            projectRoot.appendingPathComponent(".ai/runtime/v1/ops/requirement.bootstrap").path,
            projectRoot.appendingPathComponent(".ai/runtime/v1/ops/constraint.bootstrap").path,
            projectRoot.appendingPathComponent(".ai/runtime/v1/ops/decision.bootstrap").path,
            projectRoot.appendingPathComponent(".ai/runtime/v1/ops/usecase.bootstrap-start-project").path,
            projectRoot.appendingPathComponent(".ai/runtime/v1/ops/portcontract.bootstrap-start-project").path,
            projectRoot.appendingPathComponent(".ai/runtime/v1/ops/component.bootstrap-workspace").path,
            projectRoot.appendingPathComponent(".ai/runtime/v1/ops/permission.operator-local").path,
        ]
    }

    func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    func makeJSONString(_ object: [String: JSONValue]) -> String {
        let data = (try? makeEncoder().encode(object)) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }

    func timestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: now())
    }

    func hash(_ object: [String: JSONValue]) -> String {
        let json = makeJSONString(object)
        let digest = SHA256.hash(data: Data(json.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    func writeOpIndex(projectRoot: URL) throws {
        let opsRoot = projectRoot.appendingPathComponent(".ai/runtime/v1/ops")
        let opDirectories = (try? fileManager.contentsOfDirectory(
            at: opsRoot,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )) ?? []

        let entries = try opDirectories.compactMap { opDirectory -> RuntimeOpIndexEntry? in
            guard let snapshot = try latestSnapshot(for: opDirectory.lastPathComponent, projectRoot: projectRoot) else {
                return nil
            }

            let parentID = snapshot.links.first(where: { $0.rel == "parent" })?.target
            return RuntimeOpIndexEntry(
                opID: snapshot.opID,
                opType: snapshot.opType,
                state: snapshot.state,
                parentID: parentID,
                terminal: isTerminalState(snapshot.state),
                lastEventID: snapshot.lastEventID
            )
        }
        .sorted { $0.opID < $1.opID }

        let index = RuntimeOpIndex(updatedAt: timestamp(), entries: entries)
        let url = projectRoot.appendingPathComponent(".ai/runtime/v1/op-index.json")
        let data = try makeEncoder().encode(index)
        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }

    func isTerminalState(_ state: String) -> Bool {
        [
            "archived",
            "cancelled",
            "closed",
            "converted",
            "deprecated",
            "done",
            "dropped",
            "published",
            "revoked",
        ].contains(state)
    }
}
