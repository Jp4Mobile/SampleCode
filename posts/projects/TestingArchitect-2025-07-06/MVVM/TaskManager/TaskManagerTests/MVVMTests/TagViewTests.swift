//
//  TagViewTests.swift
//  TaskManager
//
//  Created by Jp LaFond on 7/4/25.
//

import XCTest

@testable import TaskManager

final class TagViewTests: XCTestCase {

    var sut: TagView.ViewModel!

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    // MARK: - Initializer
    func test_init_initializesThingsProperly() {
        let expectedPayload = "2025-07-06"
        let expectedTag = Tag(.due, payload: expectedPayload)
        sut = .init(Tag(.due, payload: expectedPayload),
                    editMode: .inactive)

        XCTAssertEqual(sut.tag, expectedTag)
        XCTAssertEqual(sut.text, expectedTag.toString)
        XCTAssertEqual(sut.editMode, .inactive)
    }

    // MARK: - Conversion Tests
    func func_convertTag_whenUnsuccessful_resetsBackToPreviousTagText() {
        let tag = Tag("tag")
        sut = .init(tag)

        // Invalid conversion
        let invalidText = "invalid"
        sut.text = invalidText
        sut.editMode = .active
        XCTAssertEqual(sut.text, invalidText)
        sut.convertTagIfValid(from: invalidText)

        XCTAssertEqual(sut.tag, tag)
        XCTAssertEqual(sut.text, tag.toString)
        XCTAssertEqual(sut.editMode, .active)
        XCTAssertEqual(sut.isEditing, true)
    }

    func test_convertTag_whenSuccessful_setsEverythingProperly() {
        let tag = Tag("tag")
        let expectedTag = Tag(.due, payload: "2025-07-06")

        sut = .init(tag)
        sut.text = expectedTag.toString
        sut.editMode = .active

        sut.convertTagIfValid(from: expectedTag.toString)

        XCTAssertEqual(sut.tag, expectedTag)
        XCTAssertEqual(sut.text, expectedTag.toString)
        XCTAssertEqual(sut.editMode, .inactive)
        XCTAssertEqual(sut.isEditing, false)
    }

}
