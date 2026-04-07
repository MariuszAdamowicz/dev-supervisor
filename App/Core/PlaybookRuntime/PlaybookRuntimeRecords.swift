import Foundation

struct RuntimeError: LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}

protocol IdempotentRuntimeRecord {
    var idempotencyKey: String { get }
}

struct RuntimeLink: Codable, Equatable {
    let rel: String
    let target: String
}

struct RuntimeOpSnapshot: Codable, Equatable {
    let schemaVersion: String
    let entity: String
    let opID: String
    let opType: String
    let opVersion: Int
    let state: String
    let owner: String
    let createdAt: String
    let updatedAt: String
    let links: [RuntimeLink]
    let tags: [String]
    let lastEventID: String
    let payload: [String: JSONValue]?

    init(
        opID: String,
        opType: String,
        opVersion: Int,
        state: String,
        owner: String,
        createdAt: String,
        updatedAt: String,
        links: [RuntimeLink],
        tags: [String],
        lastEventID: String,
        payload: [String: JSONValue]?
    ) {
        schemaVersion = "file-ai-runtime/v1"
        entity = "op_instance"
        self.opID = opID
        self.opType = opType
        self.opVersion = opVersion
        self.state = state
        self.owner = owner
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.links = links
        self.tags = tags
        self.lastEventID = lastEventID
        self.payload = payload
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case entity
        case opID = "op_id"
        case opType = "op_type"
        case opVersion = "op_version"
        case state
        case owner
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case links
        case tags
        case lastEventID = "last_event_id"
        case payload
    }
}

struct RuntimeProcessEvent: Codable, Equatable, IdempotentRuntimeRecord {
    let schemaVersion: String
    let entity: String
    let eventID: String
    let opID: String
    let opType: String?
    let eventType: String
    let payloadHash: String
    let actor: String
    let ts: String
    let idempotencyKey: String
    let fromState: String?
    let toState: String?
    let gateDecisionID: String?

    init(
        eventID: String,
        opID: String,
        opType: String?,
        eventType: String,
        payloadHash: String,
        actor: String,
        ts: String,
        idempotencyKey: String,
        fromState: String?,
        toState: String?,
        gateDecisionID: String?
    ) {
        schemaVersion = "file-ai-runtime/v1"
        entity = "process_event"
        self.eventID = eventID
        self.opID = opID
        self.opType = opType
        self.eventType = eventType
        self.payloadHash = payloadHash
        self.actor = actor
        self.ts = ts
        self.idempotencyKey = idempotencyKey
        self.fromState = fromState
        self.toState = toState
        self.gateDecisionID = gateDecisionID
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case entity
        case eventID = "event_id"
        case opID = "op_id"
        case opType = "op_type"
        case eventType = "event_type"
        case payloadHash = "payload_hash"
        case actor
        case ts
        case idempotencyKey = "idempotency_key"
        case fromState = "from_state"
        case toState = "to_state"
        case gateDecisionID = "gate_decision_id"
    }
}

struct RuntimeGateDecision: Codable, Equatable, IdempotentRuntimeRecord {
    let schemaVersion: String
    let entity: String
    let decisionID: String
    let opID: String
    let gateType: String
    let decision: String
    let reason: String
    let actor: String
    let ts: String
    let idempotencyKey: String

    init(
        decisionID: String,
        opID: String,
        gateType: String,
        decision: String,
        reason: String,
        actor: String,
        ts: String,
        idempotencyKey: String
    ) {
        schemaVersion = "file-ai-runtime/v1"
        entity = "gate_decision"
        self.decisionID = decisionID
        self.opID = opID
        self.gateType = gateType
        self.decision = decision
        self.reason = reason
        self.actor = actor
        self.ts = ts
        self.idempotencyKey = idempotencyKey
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case entity
        case decisionID = "decision_id"
        case opID = "op_id"
        case gateType = "gate_type"
        case decision
        case reason
        case actor
        case ts
        case idempotencyKey = "idempotency_key"
    }
}

struct RuntimeEvidenceRecord: Codable, Equatable, IdempotentRuntimeRecord {
    let schemaVersion: String
    let entity: String
    let evidenceID: String
    let evidenceClass: String
    let sourceRef: String
    let executorRef: String
    let actorOrSystem: String
    let subjectHash: String
    let startedAt: String
    let finishedAt: String
    let environment: String
    let replayableInputRef: String
    let attestationRef: String?
    let idempotencyKey: String

    init(
        evidenceID: String,
        evidenceClass: String,
        sourceRef: String,
        executorRef: String,
        actorOrSystem: String,
        subjectHash: String,
        startedAt: String,
        finishedAt: String,
        environment: String,
        replayableInputRef: String,
        attestationRef: String?,
        idempotencyKey: String
    ) {
        schemaVersion = "file-ai-runtime/v1"
        entity = "evidence_record"
        self.evidenceID = evidenceID
        self.evidenceClass = evidenceClass
        self.sourceRef = sourceRef
        self.executorRef = executorRef
        self.actorOrSystem = actorOrSystem
        self.subjectHash = subjectHash
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.environment = environment
        self.replayableInputRef = replayableInputRef
        self.attestationRef = attestationRef
        self.idempotencyKey = idempotencyKey
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case entity
        case evidenceID = "evidence_id"
        case evidenceClass = "evidence_class"
        case sourceRef = "source_ref"
        case executorRef = "executor_ref"
        case actorOrSystem = "actor_or_system"
        case subjectHash = "subject_hash"
        case startedAt = "started_at"
        case finishedAt = "finished_at"
        case environment
        case replayableInputRef = "replayable_input_ref"
        case attestationRef = "attestation_ref"
        case idempotencyKey = "idempotency_key"
    }
}

struct RuntimeOpIndexEntry: Codable, Equatable {
    let opID: String
    let opType: String
    let state: String
    let parentID: String?
    let terminal: Bool
    let lastEventID: String

    private enum CodingKeys: String, CodingKey {
        case opID = "op_id"
        case opType = "op_type"
        case state
        case parentID = "parent_id"
        case terminal
        case lastEventID = "last_event_id"
    }
}

struct RuntimeOpIndex: Codable, Equatable {
    let schemaVersion: String
    let entity: String
    let updatedAt: String
    let entries: [RuntimeOpIndexEntry]

    init(updatedAt: String, entries: [RuntimeOpIndexEntry]) {
        schemaVersion = "file-ai-runtime/v1"
        entity = "op_index"
        self.updatedAt = updatedAt
        self.entries = entries
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case entity
        case updatedAt = "updated_at"
        case entries
    }
}

struct RuntimeEnvelopeCondition: Codable, Equatable {
    let name: String
    let passed: Bool
    let detail: String
}

struct RuntimeEnvelopeValidation: Codable, Equatable {
    let buildStatus: String
    let testStatus: String
    let lintStatus: String
    let qualitySignal: String
    let reportRef: String

    private enum CodingKeys: String, CodingKey {
        case buildStatus = "build_status"
        case testStatus = "test_status"
        case lintStatus = "lint_status"
        case qualitySignal = "quality_signal"
        case reportRef = "report_ref"
    }
}

struct RuntimeDecisionEnvelope: Codable, Equatable {
    let transitionRef: String
    let currentState: String
    let targetState: String
    let preconditions: [RuntimeEnvelopeCondition]
    let scope: String
    let changeSet: [String]
    let validation: RuntimeEnvelopeValidation
    let traceability: [String]
    let risks: [String]
    let rollbackOrReworkPlan: [String]
    let decisionOptions: [String]
    let decisionEffects: [String: String]
    let requiredActor: String
    let auditRefs: [String]

    private enum CodingKeys: String, CodingKey {
        case transitionRef = "transition_ref"
        case currentState = "current_state"
        case targetState = "target_state"
        case preconditions
        case scope
        case changeSet = "change_set"
        case validation
        case traceability
        case risks
        case rollbackOrReworkPlan = "rollback_or_rework_plan"
        case decisionOptions = "decision_options"
        case decisionEffects = "decision_effects"
        case requiredActor = "required_actor"
        case auditRefs = "audit_refs"
    }
}

struct RuntimeDerivedDefinition {
    let opID: String
    let opType: String
    let initialState: String
    let links: [RuntimeLink]
    let tags: [String]
    let payload: [String: JSONValue]
}

struct RuntimeCreateOpRequest {
    let opID: String
    let opType: String
    let state: String
    let owner: String
    let links: [RuntimeLink]
    let tags: [String]
    let payload: [String: JSONValue]?
    let actor: String
}

struct RuntimeTransitionRequest {
    let opID: String
    let expectedFromState: String
    let event: String
    let toState: String
    let actor: String
    let gate: PlaybookGateInput?

    init(
        opID: String,
        expectedFromState: String,
        event: String,
        toState: String,
        actor: String,
        gate: PlaybookGateInput? = nil
    ) {
        self.opID = opID
        self.expectedFromState = expectedFromState
        self.event = event
        self.toState = toState
        self.actor = actor
        self.gate = gate
    }
}

enum JSONValue: Codable, Equatable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case array([JSONValue])
    case object([String: JSONValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSONValue].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value.")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(value):
            try container.encode(value)
        case let .number(value):
            try container.encode(value)
        case let .bool(value):
            try container.encode(value)
        case let .array(value):
            try container.encode(value)
        case let .object(value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }

    var stringValue: String? {
        guard case let .string(value) = self else {
            return nil
        }
        return value
    }

    var objectValue: [String: JSONValue]? {
        guard case let .object(value) = self else {
            return nil
        }
        return value
    }
}
