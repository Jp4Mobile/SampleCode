//
//  StringExtensionsTests.swift
//  TaskManagerTests
//
//  Created by Jp LaFond on 11/22/24.
//

import XCTest

@testable import TaskManager

final class StringExtensionsTests: XCTestCase {

    // MARK: - Project Tests
    func test_projectWithoutSpaces_convertsProperly() {
        let expected = TMType(tabLevel: 2,
                              type: .project("Project"))
        let sut = "  Project:".toTMType()
        XCTAssertEqual(sut, expected)
    }

    func test_projectWithSpaces_convertsProperly() {
        let expected = TMType(type: .project("Project For Work"))
        let sut = "Project For Work:".toTMType()
        XCTAssertEqual(sut, expected)
    }

    // MARK: - Task Tests
    func test_taskWithoutTags_convertsProperly() {
        let expected = TMType(type: .task("Task"))
        let sut = "- Task".toTMType()
        XCTAssertEqual(sut, expected)
    }

    func test_taskWithSimpleTag_convertsProperly() {
        let expected = TMType(type: .task("Task"), tags: [.tag("tag")])
        let sut = "- Task @tag".toTMType()
        XCTAssertEqual(sut, expected)
    }

    func test_taskWithPayloadTag_convertsProperly() {
        let expected = TMType(type: .task("Task"),
                              tags: [Tag.payloadTag("tag", "payload")])
        let sut = "- Task @tag(payload)".toTMType()
        XCTAssertEqual(sut, expected)
    }

    func test_taskWithSpaceWithPayloadTag_convertsProperly() {
        let expected = TMType(type: .task("Task with space"),
                              tags: [.tag("tag"), .payloadTag("test", "pay load")])
        let sut = "- Task with space @tag @test(pay load)".toTMType()
        XCTAssertEqual(sut, expected)
    }

    // MARK: Tasks with our known date formats in the payloads
    func test_taskWithDueDateTag_convertsProperly() {
        let expected = TMType(tabLevel: 2,
                              type: .task("Task"),
                              tags: [.payloadTag("due", "2024-10-31")])
        let sut = "\t - Task @due(2024-10-31)".toTMType()
        XCTAssertEqual(sut, expected)
    }

    func test_taskWithDueDateTimeTag_convertsProperly() {
        let expected = TMType(tabLevel: 3,
                              type: .task("Task"),
                              tags: [.payloadTag("due", "2024-10-31 10:31")])
        let sut = "   - Task @due(2024-10-31 10:31)".toTMType()
        XCTAssertEqual(sut, expected)
    }


    func test_taskWithDueDateTimeCompactEndTimeTag_convertsProperly() {
        let expected = TMType(tabLevel: 3,
                              type: .task("Task"),
                              tags: [.payloadTag("due", "2024-10-31 10:31-13:00")])
        let sut = "   - Task @due(2024-10-31 10:31-13:00)".toTMType()
        XCTAssertEqual(sut, expected)
    }

    func test_taskWithDueDateTimeExpandedEndTimeTagWithoutSpaces_convertsProperly() {
        let expected = TMType(tabLevel: 3,
                              type: .task("Task"),
                              tags: [.payloadTag("due", "2024-10-31 10:31thru13:00")])
        let sut = "   - Task @due(2024-10-31 10:31thru13:00)".toTMType()
        XCTAssertEqual(sut, expected)
    }

    func test_taskWithDueDateTimeExpandedEndTimeTagWithSpaces_convertsProperly() {
        let expected = TMType(tabLevel: 3,
                              type: .task("Task"),
                              tags: [.payloadTag("due", "2024-10-31 10:31 thru 13:00")])
        let sut = "   - Task @due(2024-10-31 10:31 thru 13:00)".toTMType()
        XCTAssertEqual(sut, expected)
    }

    func test_taskWithDueDateEndDateTag_convertsProperly() {
        let expected = TMType(type: .task("Task"),
                              tags: [.payloadTag("due", "2024-10-31 10:31 thru 2024-11-02 13:00")])
        let sut = "- Task @due(2024-10-31 10:31 thru 2024-11-02 13:00)".toTMType()
        XCTAssertEqual(sut, expected)
    }

    func test_tasksWithIdenticalText_shouldBeIdentical() {
        let expected = TPType.task("task")
        ["- task",
         "- task @tag",
         "- task @tag(payload)"].forEach {
            let sut = $0.toTMType()
            XCTAssertEqual(sut?.type, expected)
        }
    }

    // MARK: - Text Tests
    func test_textWithSpaces_convertsProperly() {
        let expected = TMType(tabLevel: 5,
                              type: .text("Text"))
        let sut = "     Text".toTMType()
        XCTAssertEqual(sut, expected)
    }

    func test_textWithoutSpaces_convertsProperly() {
        let expected = TMType(type: .text("Text with spaces"))
        let sut = "Text with spaces".toTMType()
        XCTAssertEqual(sut, expected)
    }

    func test_punctuatedString_convertsProperly() {
        let expected = TMType(tabLevel: 1, type: .text("Let\'s illustrate some of the time formats that we\'ve worked so hard on."))
        let sut = " Let\'s illustrate some of the time formats that we\'ve worked so hard on.".toTMType()
        XCTAssertEqual(sut, expected)
    }

    func test_justWhiteSpace_convertsProperly() {
        let expected = TMType(tabLevel: 5, type: .text(""))
        let sut = " \t \t ".toTMType()
        XCTAssertEqual(sut, expected)
    }

    // MARK: - Split/Verify Tests
    func test_splittingText_convertsProperly() {
        let taskPaperText =
"""
Project:
Test of TaskManager

- Task @tag
Not happy with this.
  - Task with space @due(2024-10-31) @done(2024-10-31 10:31)
"""
        let stringsArray = taskPaperText.split(separator: "\n")
        let sut = stringsArray.map { String($0) }
            .map { $0.toTMType() ?? TMType(type: .text($0)) }
        let expected: [TMType] = [
            TMType(type: .project("Project")),
            TMType(type: .text("Test of TaskManager")),
            TMType(type: .task("Task"), tags: [.tag("tag")]),
            TMType(type: .text("Not happy with this.")),
            TMType(tabLevel: 2, type: .task("Task with space"),
                   tags: [.payloadTag("due", "2024-10-31"),
                          .payloadTag("done", "2024-10-31 10:31")
                   ])
        ]
        XCTAssertEqual(sut, expected)
    }

    // MARK: - Payload Parsing Tests
    func test_tag_date_convertsProperly() throws {
        let payloadTag = Tag.payloadTag("due", "2024-11-30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertNil(sut.endDate)
        XCTAssertEqual(sut.startDate.string(format: .date), payload)
    }

    func test_tag_dateTime_convertsProperly() throws {
        let payloadTag = Tag.payloadTag("due", "2024-11-30 11:30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertNil(sut.endDate)
        XCTAssertEqual(sut.startDate.string(format: .dateTime), payload)
    }

    func test_tag_dateTimeEndTimeCompactNoSpace_convertsProperly() throws {
        let startExpected = "2024-11-30 11:30"
        let endExpected = "2024-11-30 23:30"

        let payloadTag = Tag.payloadTag("due", "2024-11-30 11:30-23:30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertEqual(sut.startDate.string(format: .dateTime), startExpected)
        XCTAssertEqual(sut.endDate?.string(format: .dateTime), endExpected)
    }

    func test_tag_dateTimeEndTimeCompactSpaces_convertsProperly() throws {
        let startExpected = "2024-11-30 11:30"
        let endExpected = "2024-11-30 23:30"

        let payloadTag = Tag.payloadTag("due", "2024-11-30 11:30 - 23:30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertEqual(sut.startDate.string(format: .dateTime), startExpected)
        XCTAssertEqual(sut.endDate?.string(format: .dateTime), endExpected)
    }

    func test_tag_dateTimeEndTimeExpandedNoSpaces_convertsProperly() throws {
        let startExpected = "2024-11-30 11:30"
        let endExpected = "2024-11-30 23:30"

        let payloadTag = Tag.payloadTag("due", "2024-11-30 11:30thru23:30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertEqual(sut.startDate.string(format: .dateTime), startExpected)
        XCTAssertEqual(sut.endDate?.string(format: .dateTime), endExpected)
    }

    func test_tag_dateTimeEndTimeExpandedSpaces_convertsProperly() throws {
        let startExpected = "2024-11-30 11:30"
        let endExpected = "2024-11-30 23:30"

        let payloadTag = Tag.payloadTag("due", "2024-11-30 11:30 thru 23:30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertEqual(sut.startDate.string(format: .dateTime), startExpected)
        XCTAssertEqual(sut.endDate?.string(format: .dateTime), endExpected)
    }

    func test_tag_dateTimeEndTimeGrammarExpandedNoSpaces_convertsProperly() throws {
        let startExpected = "2024-11-30 11:30"
        let endExpected = "2024-11-30 23:30"

        let payloadTag = Tag.payloadTag("due", "2024-11-30 11:30through23:30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertEqual(sut.startDate.string(format: .dateTime), startExpected)
        XCTAssertEqual(sut.endDate?.string(format: .dateTime), endExpected)
    }

    func test_tag_dateTimeEndTimeGrammarExpandedSpaces_convertsProperly() throws {
        let startExpected = "2024-11-30 11:30"
        let endExpected = "2024-11-30 23:30"

        let payloadTag = Tag.payloadTag("due", "2024-11-30 11:30 through 23:30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertEqual(sut.startDate.string(format: .dateTime), startExpected)
        XCTAssertEqual(sut.endDate?.string(format: .dateTime), endExpected)
    }

    func test_tag_dateTimeDateTimeCompactNoSpace_convertsProperly() throws {
        let startExpected = "2024-11-30 11:30"
        let endExpected = "2024-12-02 23:30"

        let payloadTag = Tag.payloadTag("due", "2024-11-30 11:30-2024-12-02 23:30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertEqual(sut.startDate.string(format: .dateTime), startExpected)
        XCTAssertEqual(sut.endDate?.string(format: .dateTime), endExpected)
    }

    func test_tag_dateTimeDateTimeCompactSpace_convertsProperly() throws {
        let startExpected = "2024-11-30 11:30"
        let endExpected = "2024-12-02 23:30"

        let payloadTag = Tag.payloadTag("due", "2024-11-30 11:30 - 2024-12-02 23:30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertEqual(sut.startDate.string(format: .dateTime), startExpected)
        XCTAssertEqual(sut.endDate?.string(format: .dateTime), endExpected)
    }

    func test_tag_dateTimeDateTimeExpandedNoSpace_convertsProperly() throws {
        let startExpected = "2024-11-30 11:30"
        let endExpected = "2024-12-02 23:30"

        let payloadTag = Tag.payloadTag("due", "2024-11-30 11:30thru2024-12-02 23:30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertEqual(sut.startDate.string(format: .dateTime), startExpected)
        XCTAssertEqual(sut.endDate?.string(format: .dateTime), endExpected)
    }

    func test_tag_dateTimeDateTimeExpandedSpace_convertsProperly() throws {
        let startExpected = "2024-11-30 11:30"
        let endExpected = "2024-12-02 23:30"

        let payloadTag = Tag.payloadTag("due", "2024-11-30 11:30 thru 2024-12-02 23:30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertEqual(sut.startDate.string(format: .dateTime), startExpected)
        XCTAssertEqual(sut.endDate?.string(format: .dateTime), endExpected)
    }

    func test_tag_dateTimeDateTimeGrammarExpandedNoSpace_convertsProperly() throws {
        let startExpected = "2024-11-30 11:30"
        let endExpected = "2024-12-02 23:30"

        let payloadTag = Tag.payloadTag("due", "2024-11-30 11:30through2024-12-02 23:30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertEqual(sut.startDate.string(format: .dateTime), startExpected)
        XCTAssertEqual(sut.endDate?.string(format: .dateTime), endExpected)
    }

    func test_tag_dateTimeDateTimeGrammarExpandedSpace_convertsProperly() throws {
        let startExpected = "2024-11-30 11:30"
        let endExpected = "2024-12-02 23:30"

        let payloadTag = Tag.payloadTag("due", "2024-11-30 11:30 through 2024-12-02 23:30")
        let payload = try XCTUnwrap(payloadTag.payload)
        let sut = try XCTUnwrap(payload.toTMDateType())

        XCTAssertEqual(sut.startDate.string(format: .dateTime), startExpected)
        XCTAssertEqual(sut.endDate?.string(format: .dateTime), endExpected)
    }
}
