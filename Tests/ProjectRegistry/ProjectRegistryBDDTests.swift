@testable import DevSupervisor
import XCTest

final class ProjectRegistryBDDTests: XCTestCase {
    func testScenario01_registerValidProject_createsStableIdentityVisibleAsActive_withExplicitSuccess() {
        let sut = makeSUT()

        let registration = sut.registerProject(name: "Alpha", localPath: "/projects/alpha")

        XCTAssertTrue(registration.result.isSuccess)
        XCTAssertNotNil(registration.createdProjectID)

        let projects = sut.listProjects()
        XCTAssertEqual(projects.count, 1)
        XCTAssertEqual(projects.first?.name, "Alpha")
        XCTAssertEqual(projects.first?.localPath, "/projects/alpha")
        XCTAssertEqual(projects.first?.status, .active)
    }

    func testScenario02_registerMultipleProjectsConcurrently_bothExistWithUniqueIdentity_withExplicitSuccess() {
        let sut = makeSUT()

        let first = sut.registerProject(name: "Alpha", localPath: "/projects/alpha")
        let second = sut.registerProject(name: "Beta", localPath: "/projects/beta")

        XCTAssertTrue(first.result.isSuccess)
        XCTAssertTrue(second.result.isSuccess)

        let projects = sut.listProjects()
        XCTAssertEqual(projects.count, 2)

        let ids = Set(projects.map(\.id))
        XCTAssertEqual(ids.count, 2)
        XCTAssertNotEqual(first.createdProjectID, second.createdProjectID)
    }

    func testScenario03_registerWithMissingRequiredFields_rejectsCreation_withExplicitFailureReason() {
        let sut = makeSUT()

        let emptyNameResult = sut.registerProject(name: "", localPath: "/projects/alpha").result
        let emptyPathResult = sut.registerProject(name: "Alpha", localPath: "").result

        assertExplicitFailureWithReason(emptyNameResult)
        assertExplicitFailureWithReason(emptyPathResult)
        XCTAssertEqual(sut.listProjects().count, 0)
    }

    func testScenario04_registerDuplicateActivePath_rejectsSecondProject_withExplicitFailureReason() {
        let sut = makeSUT()

        let first = sut.registerProject(name: "Alpha", localPath: "/projects/alpha")
        XCTAssertTrue(first.result.isSuccess)

        let duplicate = sut.registerProject(name: "Alpha Copy", localPath: "/projects/alpha")

        assertExplicitFailureWithReason(duplicate.result)
        XCTAssertEqual(sut.listProjects().count, 1)
    }

    func testScenario05_updateProjectMetadata_preservesIdentityAndShowsUpdatedMetadata_withExplicitSuccess() throws {
        let sut = makeSUT()

        let createdID = try XCTUnwrap(sut.registerProject(name: "Alpha", localPath: "/projects/alpha").createdProjectID)

        let updateResult = sut.updateProjectMetadata(id: createdID, name: "Alpha Renamed", localPath: nil)

        XCTAssertTrue(updateResult.isSuccess)

        let updated = try XCTUnwrap(sut.project(by: createdID))
        XCTAssertEqual(updated.id, createdID)
        XCTAssertEqual(updated.name, "Alpha Renamed")
    }

    func testScenario06_updateNonExistentProject_rejectsWithNoStateChange_andExplicitFailureReason() {
        let sut = makeSUT()

        let before = sut.listProjects()

        let result = sut.updateProjectMetadata(id: ProjectID(rawValue: "P-404"), name: "Should Fail", localPath: nil)

        assertExplicitFailureWithReason(result)
        XCTAssertEqual(sut.listProjects(), before)
    }

    func testScenario07_archiveProject_preservesIdentityAndHistory_andReturnsExplicitSuccess() throws {
        let sut = makeSUT()

        let id = try XCTUnwrap(sut.registerProject(name: "Alpha", localPath: "/projects/alpha").createdProjectID)
        let before = try XCTUnwrap(sut.project(by: id))

        let result = sut.archiveProject(id: id)

        XCTAssertTrue(result.isSuccess)

        let after = try XCTUnwrap(sut.project(by: id))
        XCTAssertEqual(after.id, before.id)
        XCTAssertEqual(after.status, .archived)
        XCTAssertEqual(after.history, before.history)
    }

    func testScenario08_reactivateArchivedProject_preservesIdentityAndHistory_andReturnsExplicitSuccess() throws {
        let sut = makeSUT()

        let id = try XCTUnwrap(sut.registerProject(name: "Alpha", localPath: "/projects/alpha").createdProjectID)
        XCTAssertTrue(sut.archiveProject(id: id).isSuccess)
        let before = try XCTUnwrap(sut.project(by: id))

        let result = sut.reactivateProject(id: id)

        XCTAssertTrue(result.isSuccess)

        let after = try XCTUnwrap(sut.project(by: id))
        XCTAssertEqual(after.id, before.id)
        XCTAssertEqual(after.status, .active)
        XCTAssertEqual(after.history, before.history)
    }

    func testScenario09_archiveAlreadyArchivedProject_rejectsWithNoStateChange_andExplicitFailureReason() throws {
        let sut = makeSUT()

        let id = try XCTUnwrap(sut.registerProject(name: "Alpha", localPath: "/projects/alpha").createdProjectID)
        XCTAssertTrue(sut.archiveProject(id: id).isSuccess)
        let snapshot = try XCTUnwrap(sut.project(by: id))

        let secondArchive = sut.archiveProject(id: id)

        assertExplicitFailureWithReason(secondArchive)
        XCTAssertEqual(sut.project(by: id), snapshot)
    }

    func testScenario10_reactivateAlreadyActiveProject_rejectsWithNoStateChange_andExplicitFailureReason() throws {
        let sut = makeSUT()

        let id = try XCTUnwrap(sut.registerProject(name: "Beta", localPath: "/projects/beta").createdProjectID)
        let snapshot = try XCTUnwrap(sut.project(by: id))

        let reactivation = sut.reactivateProject(id: id)

        assertExplicitFailureWithReason(reactivation)
        XCTAssertEqual(sut.project(by: id), snapshot)
    }

    func testScenario11_selectOneActiveWorkingProject_explicitly_setsSingleSelection_withExplicitSuccess() throws {
        let sut = makeSUT()

        let alpha = try XCTUnwrap(sut.registerProject(name: "Alpha", localPath: "/projects/alpha").createdProjectID)
        _ = sut.registerProject(name: "Beta", localPath: "/projects/beta")

        XCTAssertNil(sut.activeWorkingProjectID())

        let selection = sut.selectActiveWorkingProject(id: alpha)

        XCTAssertTrue(selection.isSuccess)
        XCTAssertEqual(sut.activeWorkingProjectID(), alpha)
    }

    func testScenario12_replaceActiveWorkingProjectSelection_replacesPreviousSelection_withExplicitSuccess() throws {
        let sut = makeSUT()

        let alpha = try XCTUnwrap(sut.registerProject(name: "Alpha", localPath: "/projects/alpha").createdProjectID)
        let beta = try XCTUnwrap(sut.registerProject(name: "Beta", localPath: "/projects/beta").createdProjectID)
        XCTAssertTrue(sut.selectActiveWorkingProject(id: alpha).isSuccess)

        let replacement = sut.selectActiveWorkingProject(id: beta)

        XCTAssertTrue(replacement.isSuccess)
        XCTAssertEqual(sut.activeWorkingProjectID(), beta)
        XCTAssertNotEqual(sut.activeWorkingProjectID(), alpha)
    }

    func testScenario13_whenNoProjectIsSelected_featureOperationIsBlocked_withExplicitError() {
        let sut = makeSUT()

        _ = sut.registerProject(name: "Alpha", localPath: "/projects/alpha")
        _ = sut.registerProject(name: "Beta", localPath: "/projects/beta")
        XCTAssertNil(sut.activeWorkingProjectID())

        let result = sut.performFeatureLevelOperation()

        assertExplicitFailureWithReason(result)
    }

    func testScenario14_projectIsolation_viewingAlphaScopeReturnsOnlyAlphaData() throws {
        let sut = makeSUT()

        let alpha = try XCTUnwrap(sut.registerProject(name: "Alpha", localPath: "/projects/alpha").createdProjectID)
        let beta = try XCTUnwrap(sut.registerProject(name: "Beta", localPath: "/projects/beta").createdProjectID)

        sut.seedScopedData(
            for: alpha,
            data: ProjectScopedData(
                ideas: ["A-idea"],
                features: ["A-feature"],
                progress: ["A-progress"],
                metadata: ["owner": "alpha"]
            )
        )
        sut.seedScopedData(
            for: beta,
            data: ProjectScopedData(
                ideas: ["B-idea"],
                features: ["B-feature"],
                progress: ["B-progress"],
                metadata: ["owner": "beta"]
            )
        )

        let alphaView = try XCTUnwrap(sut.scopedData(for: alpha))

        XCTAssertEqual(alphaView.ideas, ["A-idea"])
        XCTAssertEqual(alphaView.features, ["A-feature"])
        XCTAssertEqual(alphaView.progress, ["A-progress"])
        XCTAssertEqual(alphaView.metadata["owner"], "alpha")
        XCTAssertFalse(alphaView.ideas.contains("B-idea"))
        XCTAssertFalse(alphaView.features.contains("B-feature"))
    }

    func testScenario15_listWhenNoProjectsExist_returnsExplicitEmptyList_withoutImplicitCreation() {
        let sut = makeSUT()

        let projects = sut.listProjects()

        XCTAssertTrue(projects.isEmpty)
        XCTAssertNil(sut.activeWorkingProjectID())
    }

    func testScenario16_archiveNonExistentProject_rejectsWithNoStateChange_andExplicitFailureReason() {
        let sut = makeSUT()

        let before = sut.listProjects()

        let result = sut.archiveProject(id: ProjectID(rawValue: "P-404"))

        assertExplicitFailureWithReason(result)
        XCTAssertEqual(sut.listProjects(), before)
    }

    func testScenario17_whenRegisteredPathIsUnavailable_operationFailsExplicitly_withNoSilentStateChange() throws {
        let sut = makeSUT()

        let alpha = try XCTUnwrap(sut.registerProject(name: "Alpha", localPath: "/projects/alpha").createdProjectID)
        let before = try XCTUnwrap(sut.project(by: alpha))

        sut.setPathAvailability(for: alpha, isAvailable: false)
        let result = sut.performPathRequiredOperation(for: alpha)

        assertExplicitFailureWithReason(result)
        XCTAssertEqual(sut.project(by: alpha), before)
    }

    func testScenario18_selectNonExistentProject_rejectsAndKeepsNoActiveSelection_withExplicitFailureReason() {
        let sut = makeSUT()

        let result = sut.selectActiveWorkingProject(id: ProjectID(rawValue: "P-404"))

        assertExplicitFailureWithReason(result)
        XCTAssertNil(sut.activeWorkingProjectID())
    }

    func testScenario19_selectArchivedProject_rejectsAndKeepsNoActiveSelection_withExplicitFailureReason() throws {
        let sut = makeSUT()

        let alpha = try XCTUnwrap(sut.registerProject(name: "Alpha", localPath: "/projects/alpha").createdProjectID)
        XCTAssertTrue(sut.archiveProject(id: alpha).isSuccess)

        let result = sut.selectActiveWorkingProject(id: alpha)

        assertExplicitFailureWithReason(result)
        XCTAssertNil(sut.activeWorkingProjectID())
    }

    func testScenario20_updateToDuplicateActivePath_rejectsUpdate_withExplicitFailureReason() throws {
        let sut = makeSUT()

        _ = sut.registerProject(name: "Alpha", localPath: "/projects/alpha")
        let beta = try XCTUnwrap(sut.registerProject(name: "Beta", localPath: "/projects/beta").createdProjectID)
        let before = try XCTUnwrap(sut.project(by: beta))

        let result = sut.updateProjectMetadata(id: beta, name: nil, localPath: "/projects/alpha")

        assertExplicitFailureWithReason(result)
        XCTAssertEqual(sut.project(by: beta), before)
    }

    func testScenario21_updateProjectLocalPathToNewUniquePath_succeedsWithExplicitSuccess() throws {
        let sut = makeSUT()

        let id = try XCTUnwrap(sut.registerProject(name: "Alpha", localPath: "/projects/alpha").createdProjectID)

        let result = sut.updateProjectMetadata(id: id, name: nil, localPath: "/projects/alpha-new")

        XCTAssertTrue(result.isSuccess)

        let updated = try XCTUnwrap(sut.project(by: id))
        XCTAssertEqual(updated.localPath, "/projects/alpha-new")
    }

    func testScenario22_listProjects_includesArchivedProjectsAlongsideActiveOnes() throws {
        let sut = makeSUT()

        let alpha = try XCTUnwrap(sut.registerProject(name: "Alpha", localPath: "/projects/alpha").createdProjectID)
        let beta = try XCTUnwrap(sut.registerProject(name: "Beta", localPath: "/projects/beta").createdProjectID)

        XCTAssertTrue(sut.archiveProject(id: beta).isSuccess)

        let projects = sut.listProjects()

        XCTAssertEqual(projects.count, 2)
        XCTAssertTrue(projects.contains { $0.id == alpha && $0.status == .active })
        XCTAssertTrue(projects.contains { $0.id == beta && $0.status == .archived })
    }

    func testScenario23_reactivateWithPathConflict_rejectsAndKeepsProjectArchived_withExplicitFailureReason() throws {
        let sut = makeSUT()

        _ = sut.registerProject(name: "Alpha", localPath: "/projects/alpha")
        let beta = try XCTUnwrap(sut.registerProject(name: "Beta", localPath: "/projects/beta").createdProjectID)
        XCTAssertTrue(sut.archiveProject(id: beta).isSuccess)
        XCTAssertTrue(sut.updateProjectMetadata(id: beta, name: nil, localPath: "/projects/alpha").isSuccess)

        let before = try XCTUnwrap(sut.project(by: beta))
        XCTAssertEqual(before.status, .archived)

        let result = sut.reactivateProject(id: beta)

        assertExplicitFailureWithReason(result)
        XCTAssertEqual(sut.project(by: beta), before)
    }
}

private extension ProjectRegistryBDDTests {
    func makeSUT() -> any ProjectRegistryContract {
        ProjectRegistryInMemory()
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
