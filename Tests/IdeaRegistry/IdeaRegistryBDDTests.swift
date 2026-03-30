@testable import DevSupervisor
import XCTest

final class IdeaRegistryBDDTests: XCTestCase {
    func testScenario01_createIdeaForActiveProjectWithValidTitle_createsStableIdentityInProject_withExplicitSuccess() throws {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        sut.selectActiveProject(id: alpha)

        let creation = sut.createIdea(title: "Offline mode", description: "Support offline workflow")

        XCTAssertTrue(creation.result.isSuccess)
        let ideaID = try XCTUnwrap(creation.createdIdeaID)
        let created = try XCTUnwrap(sut.idea(by: ideaID))
        XCTAssertEqual(created.projectID, alpha)
        XCTAssertEqual(created.title, "Offline mode")
        XCTAssertEqual(created.description, "Support offline workflow")
        XCTAssertEqual(created.status, .new)
    }

    func testScenario02_createMultipleIdeasWithinOneProject_keepsBothWithUniqueIdentity_withExplicitSuccess() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        sut.selectActiveProject(id: alpha)

        let first = sut.createIdea(title: "Offline mode", description: nil)
        let second = sut.createIdea(title: "Bulk import", description: nil)

        XCTAssertTrue(first.result.isSuccess)
        XCTAssertTrue(second.result.isSuccess)
        XCTAssertNotEqual(first.createdIdeaID, second.createdIdeaID)

        let list = sut.listIdeasForActiveProject()
        XCTAssertTrue(list.result.isSuccess)
        XCTAssertEqual(list.ideas.count, 2)
    }

    func testScenario03_createIdeaWhenNoActiveProjectSelected_rejectsWithExplicitFailureReason() {
        let sut = makeSUT()
        sut.selectActiveProject(id: nil)

        let creation = sut.createIdea(title: "Offline mode", description: nil)

        assertExplicitFailureWithReason(creation.result)
        XCTAssertNil(creation.createdIdeaID)
    }

    func testScenario04_createIdeaWithEmptyTitle_rejectsWithExplicitFailureReason() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let creation = sut.createIdea(title: "", description: nil)

        assertExplicitFailureWithReason(creation.result)
        XCTAssertNil(creation.createdIdeaID)
    }

    func testScenario05_updateIdeaContentByOperatorAction_preservesIdentityAndUpdatesVisibleContent_withExplicitSuccess() throws {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        sut.selectActiveProject(id: alpha)
        let ideaID = try XCTUnwrap(sut.createIdea(title: "Offline mode", description: nil).createdIdeaID)

        let update = sut.updateIdeaContent(id: ideaID, title: "Offline-first mode", description: "Prioritize no-network use")

        XCTAssertTrue(update.isSuccess)
        let updated = try XCTUnwrap(sut.idea(by: ideaID))
        XCTAssertEqual(updated.id, ideaID)
        XCTAssertEqual(updated.title, "Offline-first mode")
        XCTAssertEqual(updated.description, "Prioritize no-network use")
    }

    func testScenario06_updateNonExistentIdea_rejectsWithNoStateChange_andExplicitFailureReason() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))
        let before = sut.listIdeasForActiveProject().ideas

        let update = sut.updateIdeaContent(id: IdeaID(rawValue: "I-404"), title: "Should Fail", description: nil)

        assertExplicitFailureWithReason(update)
        XCTAssertEqual(sut.listIdeasForActiveProject().ideas, before)
    }

    func testScenario07_changeIdeaStatusToDeferred_updatesStatus_withExplicitSuccess() throws {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        sut.selectActiveProject(id: alpha)
        let ideaID = try XCTUnwrap(sut.createIdea(title: "Offline mode", description: nil).createdIdeaID)

        let result = sut.changeIdeaStatus(id: ideaID, status: .deferred)

        XCTAssertTrue(result.isSuccess)
        XCTAssertEqual(sut.idea(by: ideaID)?.status, .deferred)
    }

    func testScenario08_selectOneIdeaAsPRDCandidate_setsSelectedStatusAndIndicator_withExplicitSuccess() throws {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        sut.selectActiveProject(id: alpha)
        let ideaID = try XCTUnwrap(sut.createIdea(title: "Offline mode", description: nil).createdIdeaID)

        let result = sut.changeIdeaStatus(id: ideaID, status: .selected)

        XCTAssertTrue(result.isSuccess)
        XCTAssertEqual(sut.idea(by: ideaID)?.status, .selected)
    }

    func testScenario09_secondSelectedIdeaInSameProject_rejectsAndKeepsSingleSelected_withExplicitFailureReason() throws {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        sut.selectActiveProject(id: alpha)
        let first = try XCTUnwrap(sut.createIdea(title: "Offline mode", description: nil).createdIdeaID)
        let second = try XCTUnwrap(sut.createIdea(title: "Bulk import", description: nil).createdIdeaID)
        XCTAssertTrue(sut.changeIdeaStatus(id: first, status: .selected).isSuccess)

        let secondSelection = sut.changeIdeaStatus(id: second, status: .selected)

        assertExplicitFailureWithReason(secondSelection)
        XCTAssertEqual(sut.idea(by: second)?.status, .new)
        let selectedCount = sut.listIdeasForActiveProject().ideas.filter { $0.status == .selected }.count
        XCTAssertEqual(selectedCount, 1)
    }

    func testScenario10_invalidIdeaStatusValue_rejectsChange_withExplicitFailureReason() throws {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        sut.selectActiveProject(id: alpha)
        let ideaID = try XCTUnwrap(sut.createIdea(title: "Offline mode", description: nil).createdIdeaID)
        let before = try XCTUnwrap(sut.idea(by: ideaID))

        let result = sut.changeIdeaStatus(id: ideaID, rawStatus: "in-progress")

        assertExplicitFailureWithReason(result)
        XCTAssertEqual(sut.idea(by: ideaID), before)
    }

    func testScenario11_changeStatusForNonExistentIdea_rejectsWithNoStateChange_andExplicitFailureReason() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))
        let before = sut.listIdeasForActiveProject().ideas

        let result = sut.changeIdeaStatus(id: IdeaID(rawValue: "I-404"), status: .deferred)

        assertExplicitFailureWithReason(result)
        XCTAssertEqual(sut.listIdeasForActiveProject().ideas, before)
    }

    func testScenario12_updateAndStatusChangeWhenNoActiveProjectSelected_areBlockedWithExplicitFailureReason() throws {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))
        let ideaID = try XCTUnwrap(sut.createIdea(title: "Offline mode", description: nil).createdIdeaID)
        sut.selectActiveProject(id: nil)

        let update = sut.updateIdeaContent(id: ideaID, title: "Offline-first mode", description: nil)
        let status = sut.changeIdeaStatus(id: ideaID, status: .deferred)

        assertExplicitFailureWithReason(update)
        assertExplicitFailureWithReason(status)
    }

    func testScenario13_listIdeasForActiveProject_returnsOnlyActiveProjectIdeas() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let beta = ProjectID(rawValue: "P-2")
        sut.selectActiveProject(id: alpha)
        _ = sut.createIdea(title: "Offline mode", description: nil)
        sut.selectActiveProject(id: beta)
        _ = sut.createIdea(title: "Telemetry export", description: nil)
        sut.selectActiveProject(id: alpha)

        let list = sut.listIdeasForActiveProject()

        XCTAssertTrue(list.result.isSuccess)
        XCTAssertEqual(list.ideas.map(\.title), ["Offline mode"])
        XCTAssertFalse(list.ideas.contains { $0.title == "Telemetry export" })
    }

    func testScenario14_listIdeasWhenProjectHasNoIdeas_returnsExplicitEmptyList_withoutImplicitCreation() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let list = sut.listIdeasForActiveProject()

        XCTAssertTrue(list.result.isSuccess)
        XCTAssertTrue(list.ideas.isEmpty)
    }

    func testScenario15_explicitPRDCandidateSelection_isTraceableAsStateTransition_withExplicitSuccess() throws {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        sut.selectActiveProject(id: alpha)
        let ideaID = try XCTUnwrap(sut.createIdea(title: "Offline mode", description: nil).createdIdeaID)

        let result = sut.changeIdeaStatus(id: ideaID, status: .selected)

        XCTAssertTrue(result.isSuccess)
        XCTAssertEqual(sut.idea(by: ideaID)?.status, .selected)
    }

    func testScenario16_projectIsolation_preventsCrossProjectIdeaAccessAndMutation() throws {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let beta = ProjectID(rawValue: "P-2")
        sut.selectActiveProject(id: alpha)
        _ = sut.createIdea(title: "Offline mode", description: nil)
        sut.selectActiveProject(id: beta)
        let betaIdea = try XCTUnwrap(sut.createIdea(title: "Telemetry export", description: nil).createdIdeaID)
        sut.selectActiveProject(id: alpha)

        let mutation = sut.updateIdeaContent(id: betaIdea, title: "Should Not Update", description: nil)
        let scoped = sut.listIdeasForActiveProject()

        assertExplicitFailureWithReason(mutation)
        XCTAssertTrue(scoped.ideas.allSatisfy { $0.projectID == alpha })
        XCTAssertEqual(sut.idea(by: betaIdea)?.title, "Telemetry export")
    }
}

private extension IdeaRegistryBDDTests {
    func makeSUT() -> any IdeaRegistryContract {
        IdeaRegistryInMemory()
    }

    func assertExplicitFailureWithReason(
        _ result: RegistryOperationResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case let .failure(reason) = result else {
            XCTFail("Expected explicit failure with reason, got success", file: file, line: line)
            return
        }

        XCTAssertFalse(reason.message.isEmpty, "Failure reason should be explicit and non-empty", file: file, line: line)
    }
}
