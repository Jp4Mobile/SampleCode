//
//  TextViewTests.swift
//  TaskManager
//
//  Created by Jp LaFond on 6/18/25.
//

import SwiftUI
import XCTest

@testable import TaskManager

class TextViewTests: XCTestCase {
    var sut: TextView.ViewModel!

    override func setUp() {
        super.setUp()

        sut = .init(from: TMType.Mock.TopLevel.text)
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    // MARK: - Verify flow
    func test_updateText_withInvalidData_setsErrorAndResetsText() {
        // Setup
        let textBinding: Binding<String> = sut.binding(\.text)

        XCTAssertNil(sut.state.errorToPresent)
        XCTAssertEqual(sut.state.type, TMType.Mock.TopLevel.text)

        // Validation
        textBinding.wrappedValue = ""
        sut.doneButtonTapped()

        XCTAssertEqual(sut.state.errorToPresent, "Unable to convert <>")
        XCTAssertEqual(sut.state.type, TMType.Mock.TopLevel.text)
        XCTAssertEqual(sut.state.text, TMType.Mock.TopLevel.text.toString)
    }

    func test_updateText_withMultipleTopLevelItems_setsError_andSetsToFirstItem() {
        // Setup
        let textBinding: Binding<String> = sut.binding(\.text)

        // Validation
        textBinding.wrappedValue = TMType.Mock.TopLevel.project.toString +
                                    "\n" +
                                    TMType.Mock.TopLevel.task.toString
        sut.doneButtonTapped()

        XCTAssertEqual(sut.state.errorToPresent,
                       "Only the first converted type model is saved. " +
                       "You may need to change indentation to keep them " +
                       "under the proper project.")
        XCTAssertEqual(sut.state.type, TMType.Mock.TopLevel.project)
        XCTAssertEqual(sut.state.text, TMType.Mock.TopLevel.project.toString)
    }

    func test_updateText_withValidData_clearsErrorAndSetsToItem() {
        // Setup
        let textBinding: Binding<String> = sut.binding(\.text)
        sut.update(\.errorToPresent, to: "Error Present")

        // Validation
        textBinding.wrappedValue = TMType.Mock.Projects.projectWithTasks.toString
        sut.doneButtonTapped()

        XCTAssertNil(sut.state.errorToPresent)
        XCTAssertEqual(sut.state.type, TMType.Mock.Projects.projectWithTasks)
        XCTAssertEqual(sut.state.text, TMType.Mock.Projects.projectWithTasks.toString)
    }
}
