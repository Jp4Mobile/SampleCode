//
//  TagViewTests.swift
//  TaskManager
//
//  Created by Jp LaFond on 7/5/25.
//

import SwiftUI
import XCTest

@testable import TaskManager

final class TagViewTests: XCTestCase {

    var sut: TagView.ViewModel!

    override func setUp() {
        super.setUp()

        sut = .init(Constants.MockTag.test)
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    // MARK: - Binding Verification Tests
    func test_verifyTextBinding_savesNewValue() {
        // Set up
        let textBinding: Binding<String> = sut.binding(\.text)

        XCTAssertEqual(textBinding.wrappedValue, Constants.MockTag.test.toString)

        // Update the value
        let newValue = "@test(payload)"

        textBinding.wrappedValue = newValue

        XCTAssertEqual(sut.state.text, newValue)
    }

    // MARK: - Verify view model functionality
    func test_convertTagIfValid_withInvalidInput_doesNothing() {
        // Setup
        sut.update(\.editMode, to: .active)

        XCTAssertEqual(sut.state.editMode, .active)
        XCTAssertEqual(sut.state.tag, Constants.MockTag.test)
        XCTAssertEqual(sut.state.text, Constants.MockTag.test.toString)

        // Verification
        sut.convertTagIfValid(from: "")

        XCTAssertEqual(sut.state.editMode, .inactive)
        XCTAssertEqual(sut.state.tag, Constants.MockTag.test)
        XCTAssertEqual(sut.state.text, Constants.MockTag.test.toString)
    }

    func test_convertTagIfValid_withValidInputButNoPayload_normalizesTag() {
        // Setup
        sut.update(\.editMode, to: .active)

        XCTAssertEqual(sut.state.editMode, .active)
        XCTAssertEqual(sut.state.tag, Constants.MockTag.test)
        XCTAssertEqual(sut.state.text, Constants.MockTag.test.toString)

        // Verification
        sut.convertTagIfValid(from: "@updatedTag()")

        XCTAssertEqual(sut.state.editMode, .inactive)
        XCTAssertEqual(sut.state.tag, Tag("updatedTag"))
        XCTAssertEqual(sut.state.text, "@updatedTag")
    }

    func test_convertTagIfValid_withValidInput_updatesTag() {
        // Setup
        sut.update(\.editMode, to: .active)

        XCTAssertEqual(sut.state.editMode, .active)
        XCTAssertEqual(sut.state.tag, Constants.MockTag.test)
        XCTAssertEqual(sut.state.text, Constants.MockTag.test.toString)

        // Verification
        sut.convertTagIfValid(from: Constants.MockTag.dueDate.toString)

        XCTAssertEqual(sut.state.tag, Constants.MockTag.dueDate)
        XCTAssertEqual(sut.state.text, Constants.MockTag.dueDate.toString)
    }
}
