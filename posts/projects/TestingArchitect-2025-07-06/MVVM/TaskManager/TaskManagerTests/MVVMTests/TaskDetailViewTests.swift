//
//  TaskDetailViewTests.swift
//  TaskManager
//
//  Created by Jp LaFond on 7/4/25.
//

import SwiftUI
import XCTest

@testable import TaskManager

final class TaskDetailViewTests: XCTestCase {

    var sut: TaskDetailView.ViewModel!

    override func setUp() {
        super.setUp()

        sut = .init()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    // MARK: - DidSet Logic Tests
    func test_errorMessage_whenPresent_setsShouldDismiss() {
        sut.shouldDismiss = true

        sut.errorMessage = "present"

        XCTAssertFalse(sut.shouldDismiss)
    }

    func test_errorMessage_whenNil_clearsShouldDismiss() {
        sut.shouldDismiss = true

        sut.errorMessage = nil

        XCTAssertTrue(sut.shouldDismiss)
    }

    // MARK: - Setup Tests
    func test_setup_whenNil_setsAppropriately() {
        sut.setup(from: nil)

        XCTAssertEqual(sut.text, "")
        XCTAssertNil(sut.errorMessage)
    }

    func test_setup_withValue_setsAppropriately() {
        let project: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.project)
        sut.setup(from: project)

        XCTAssertEqual(sut.text, project.type.toString)
    }

    // MARK: - tapped tests
    func test_cancelTapped_whenSelectedItem_sendsCanceledResponse() {
        let project: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.project)
        @State var viewModel: TaskMasterAndDetailView.ViewModel = .init(selectedItem: project, items: [project])
        let sut = TaskDetailView(viewModel: $viewModel, localViewModel: self.sut)

        XCTAssertNil(viewModel.responseType)

        sut.cancelTapped()

        XCTAssertEqual(viewModel.responseType, .canceled(project))
    }

    func test_deleteTapped_whenSelectedItem_sendsDeletedResponse() {
        let project: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.project)
        @State var viewModel: TaskMasterAndDetailView.ViewModel = .init(selectedItem: project, items: [project])
        let sut = TaskDetailView(viewModel: $viewModel, localViewModel: self.sut)

        sut.deleteTapped()

        XCTAssertEqual(viewModel.responseType, .deleted(project))
    }

    func test_saveTapped_whenItConverts_sendsUpdatedSaveResponse() {
        let initial: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.project)
        let expected: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.task)
        @State var viewModel: TaskMasterAndDetailView.ViewModel = .init(selectedItem: initial, items: [initial])
        let sut = TaskDetailView(viewModel: $viewModel, localViewModel: self.sut)

        self.sut.text = expected.type.toString

        sut.saveTapped()

        XCTAssertEqual(viewModel.responseType, .save(expected))
    }

    func test_saveTapped_whenItDoesNotConvert_resetsTextAndDoesNotSendResponse() {
        let initial: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.project)
        @State var viewModel: TaskMasterAndDetailView.ViewModel = .init(selectedItem: initial, items: [initial])
        let sut = TaskDetailView(viewModel: $viewModel, localViewModel: self.sut)

        self.sut.text = ""

        sut.saveTapped()

        XCTAssertEqual(self.sut.errorMessage, "Unable to convert <>")
        XCTAssertEqual(self.sut.text, initial.type.toString)
        XCTAssertNil(viewModel.responseType)
    }

}
