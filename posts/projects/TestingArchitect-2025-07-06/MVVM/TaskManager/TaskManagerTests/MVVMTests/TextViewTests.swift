//
//  TextViewTests.swift
//  TaskManager
//
//  Created by Jp LaFond on 7/4/25.
//

import XCTest

@testable import TaskManager

final class TextViewTests: XCTestCase {

    var sut: TextView.ViewModel!

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    // MARK: - Initializer Tests
    func test_initializer_setsThingsProperly() {
        sut = .init(from: TMType.Mock.TopLevel.text)
        XCTAssertEqual(sut.type, TMType.Mock.TopLevel.text)
        XCTAssertEqual(sut.text, TMType.Mock.TopLevel.text.toString)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - DidSet Tests
    func test_type_setsText() {
        sut = .init(from: TMType.Mock.TopLevel.text)
        sut.text = "Invalid"

        sut.type = TMType.Mock.Projects.projectWithTasks

        XCTAssertEqual(sut.text, TMType.Mock.Projects.projectWithTasks.toString)
    }

    func test_errorMessage_toValue_setsTextBackToType() {
        sut = .init(from: TMType.Mock.TopLevel.text)
        sut.text = "Invalid"

        sut.errorMessage = "Error"
        XCTAssertEqual(sut.text, sut.type.toString)
    }

    func test_errorMessage_toNil_doesNothing() {
        sut = .init(from: TMType.Mock.TopLevel.text)
        let expectedValue = "Invalid"
        sut.text = expectedValue

        sut.errorMessage = nil
        XCTAssertEqual(sut.text, expectedValue)
    }

    // MARK: - Updated Text Conversion Tests
    func test_updatedText_whenEmpty_setsExpectedError() {
        sut = .init(from: TMType.Mock.TopLevel.text)

        sut.updatedText(text: "")

        XCTAssertEqual(sut.type, TMType.Mock.TopLevel.text)
        XCTAssertEqual(sut.text, TMType.Mock.TopLevel.text.toString)
        XCTAssertEqual(sut.errorMessage, "Unable to convert <>")
    }

    func test_updatedText_whenMultiple_setsExpectedError() {
        sut = .init(from: TMType.Mock.TopLevel.text)

        sut.updatedText(text: TMType.Mock.TopLevel.project.toString + "\n" +
                        TMType.Mock.Projects.projectWithTasks.toString)

        XCTAssertEqual(sut.type, TMType.Mock.TopLevel.project)
        XCTAssertEqual(sut.text, TMType.Mock.TopLevel.project.toString)
        XCTAssertEqual(sut.errorMessage, "Only the first converted type model is saved. You may need to change indentation to keep them under the proper project.")

    }

    func test_updatedText_whenConverted_setsTextProperly() {
        sut = .init(from: TMType.Mock.TopLevel.text)
        sut.errorMessage = "Invalid"

        sut.updatedText(text: TMType.Mock.Projects.projectWithTasks.toString)

        XCTAssertEqual(sut.type, TMType.Mock.Projects.projectWithTasks)
        XCTAssertEqual(sut.text, TMType.Mock.Projects.projectWithTasks.toString)
        XCTAssertNil(sut.errorMessage)
    }
}
