//
//  TMTypeTests.swift
//  TaskManagerTests
//
//  Created by Jp LaFond on 11/21/24.
//

import XCTest

@testable import TaskManager

final class TMTypeTests: XCTestCase {
    // file path for file "TestSample.taskpaper"
    // Because we want the bundle for tests, NOT the main bundle, we need to do this...
    static let bundle = Bundle(for: TMTypeTests.self)
    static let path = bundle.path(forResource: "TestSample", ofType: "taskpaper")
    static var testSampleText: String!

    override class func setUp() {
        super.setUp()

        do {
            guard let path else {
                print("Unable to open the required test sample text file.")
                XCTFail("Could not load the required test sample text")
                return
            }
            testSampleText = try String(contentsOf: URL(fileURLWithPath: path),
                                        encoding: .utf8)
        } catch {
            print(error.localizedDescription)
            XCTFail(error.localizedDescription)
        }
    }

    // MARK: - FormattedTMType Functionality
    func test_formattedTMType_returns_correct_string() {
        let sut = TMType.TestSampleModel.map { $0.toString }
            .joined(separator: "\n")

        XCTAssertEqual(sut, TMTypeTests.testSampleText)
    }

    // MARK: - Set Indent Functionality
    func test_setIndent_toValue_setsIndentCorrectly() {
        let text = "Test"
        var sut = TMType(type: .text(text))
        sut.set(indent: 1)

        let expected = TMType(tabLevel: 1,
                              type: .text(text))
        XCTAssertEqual(sut, expected)
    }

    // MARK: - Append Tag Functionality
    func test_appendTag_toValue_appendsTagCorrectly() {
        let text = "Test"
        let tag = Tag.tag("test")
        var sut = TMType(type: .text(text))
        sut.append(tag: tag)

        let expected = TMType(type: .text(text),
                              tags: [tag])
        XCTAssertEqual(sut, expected)
    }

    // MARK: - Append Child Functionality
    func test_appendChild_toValue_appendsChildCorrectly() {
        let project = "Project"
        let text = "Test"
        let child = TMType(type: .text(text))
        var sut = TMType(type: .project(project))
        sut.append(child: child)
        
        let expected = TMType(type: .project(project),
                              children: [child])

        XCTAssertEqual(sut, expected)
    }

    // MARK: - Search Functionality
    func test_lastChild_returnsAppropriateValue() {
        let expectedLastChild = TMType(tabLevel: 1,
                                       type: .task("SubTask 2"))
        let sut = TMType(type: .project("Project"),
                         children: [
                            TMType(tabLevel: 1,
                                   type: .task("SubTask 1"),
                                   children: [
                                    TMType(tabLevel: 2,
                                           type: .task("SubSubTask 1"))
                                   ]),
                            expectedLastChild
                         ])
        XCTAssertEqual(sut.lastChild(), expectedLastChild)
    }

    func test_lastChild_withTabLevel_returnsAppropriateValue() {
        let expectedValue = TMType(tabLevel: 2,
                                   type: .task("SubSubTask 1"))
        let sut = TMType(type: .project("Project"),
                         children: [
                            TMType(tabLevel: 1,
                                   type: .task("SubTask 1")),
                            TMType(tabLevel: 1,
                                   type: .task("SubTask 2"),
                                   children: [
                                    expectedValue
                                   ])
                         ])
        XCTAssertEqual(sut.lastChild(with: 2), expectedValue)
    }

    func test_parentOf_returnsAppropriateValue() throws {
        let sut = TMType(type: .project("Project"),
                         children: [
                            TMType(tabLevel: 1,
                                   type: .task("SubTask 1")),
                            TMType(tabLevel: 1,
                                   type: .task("SubTask 2"),
                                   children: [
                                    TMType(tabLevel: 2,
                                           type: .task("SubSubTask 1"))
                                   ])
                         ])
        let lastChild = try XCTUnwrap(sut.lastChild())
        XCTAssertTrue(lastChild.isEqualWithoutChildren(to: TMType(tabLevel: 2,
                                                                  type: .task("SubSubTask 1"))))
        let parent = sut.parent(of: lastChild)
        XCTAssertTrue(parent?.isEqualWithoutChildren(to: TMType(tabLevel: 1, type: .task("SubTask 2"))) ?? false)
    }

    // MARK: - Parser Tests
    func test_parser_returnsCorrectValue() {
        let taskPaperText =
"""
Project:
Test of TaskManager

- Task @tag
Not happy with this.
  - Task with space @due(2024-10-31) @done(2024-10-31 10:31)
"""
        let expected: [TMType] = [
            TMType(type: .project("Project")),
            TMType(type: .text("Test of TaskManager")),
            TMType(type: .text("")),
            TMType(type: .task("Task"), tags: [.tag("tag")]),
            TMType(type: .text("Not happy with this.")),
            TMType(tabLevel: 2, type: .task("Task with space"),
                   tags: [.payloadTag("due", "2024-10-31"),
                          .payloadTag("done", "2024-10-31 10:31")
                   ])
        ]
        let parsed = TMType.parse(string: taskPaperText)
        let sut = TMType.normalize(parsed)

        XCTAssertEqual(sut, TMType.normalize(expected))
    }

    func test_normalize_array_doesNothingWhenTheSameIndentLevel() {
        let sut = [
            TMType(type: .project("Project")),
            TMType(type: .task("Task")),
            TMType(type: .text("Line 1")),
            TMType(type: .text("Line 2")),
        ]
        let toTest = TMType.normalize(sut)
        XCTAssertEqual(sut, toTest)
    }

    func test_normalize_initialChild_isAddedToParent() {
        let initialList = [
            TMType(type: .project("Project")),
            TMType(tabLevel: 1, type: .task("Task"))
        ]
        let expectedList = [
            TMType(type: .project("Project"),
                   children: [
                    TMType(tabLevel: 1, type: .task("Task"))
                   ])
        ]
        let sut = TMType.normalize(initialList)
        XCTAssertEqual(sut, expectedList)
    }

    func test_normalize_subsequentIndentedChild_isAppropriatelyAddedToParent() {
        let initialList = [
            TMType(type: .project("Project")),
            TMType(tabLevel: 1, type: .task("Task")),
            TMType(tabLevel: 2, type: .text("Text"))
        ]
        let expectedList = [
            TMType(type: .project("Project"),
                   children: [
                    TMType(tabLevel: 1, type: .task("Task"),
                           children: [
                            TMType(tabLevel: 2, type: .text("Text"))
                           ])
                   ])
        ]
        let sut = TMType.normalize(initialList)
        XCTAssertEqual(sut, expectedList)
    }

    func test_normalize_subsequentIndentedChildren_areAppropriatelyAddedToParent() {
        let initialList = [
            TMType(type: .project("Project")),
            TMType(tabLevel: 1, type: .task("Task")),
            TMType(tabLevel: 1, type: .text("Text"))
        ]
        let expectedList = [
            TMType(type: .project("Project"),
                   children: [
                    TMType(tabLevel: 1, type: .task("Task")),
                    TMType(tabLevel: 1, type: .text("Text"))
                   ])
        ]
        let sut = TMType.normalize(initialList)
        XCTAssertEqual(sut, expectedList)

    }

    func test_normalize_subsequentDeindentedChild_isAppropriatelyReplaced() {
        let initialList = [
            TMType(type: .project("Project")),
            TMType(tabLevel: 1, type: .task("Task")),
            TMType(tabLevel: 2, type: .text("Text")),
            TMType(tabLevel: 1, type: .task("Other Task"))
        ]
        let expectedList = [
            TMType(type: .project("Project"),
                   children: [
                    TMType(tabLevel: 1, type: .task("Task"),
                           children: [
                            TMType(tabLevel: 2, type: .text("Text"))
                           ]),
                    TMType(tabLevel: 1, type: .task("Other Task"))
                   ])
        ]
        let sut = TMType.normalize(initialList)
        XCTAssertEqual(sut, expectedList)
    }

    func test_normalize_subsequentBaseIndentation_isAppropriatelyAppended() {
        let initialList = [
            TMType(type: .project("Project")),
            TMType(tabLevel: 1, type: .task("Task")),
            TMType(tabLevel: 2, type: .text("Text")),
            TMType(tabLevel: 1, type: .task("Other Task")),
            TMType(type: .text("")),
            TMType(type: .project("Subsequent Project"))
        ]
        let expectedList = [
            TMType(type: .project("Project"),
                   children: [
                    TMType(tabLevel: 1, type: .task("Task"),
                           children: [
                            TMType(tabLevel: 2, type: .text("Text"))
                           ]),
                    TMType(tabLevel: 1, type: .task("Other Task"))
                   ]),
            TMType(type: .text("")),
            TMType(type: .project("Subsequent Project"))
        ]
        let sut = TMType.normalize(initialList)
        XCTAssertEqual(sut, expectedList)
    }

    func test_normalize_subsequentDeeperBaseIndentation_isAppropriatelyAppended() {
        let initialList = [
            TMType(type: .project("Project")),
            TMType(tabLevel: 1, type: .task("Task")),
            TMType(tabLevel: 2, type: .task("Subtask")),
            TMType(tabLevel: 3, type: .text("Subtask text")),
            TMType(tabLevel: 1, type: .task("Other Task")),
            TMType(type: .text("")),
            TMType(type: .project("Subsequent Project"))
        ]
        let expectedList = [
            TMType(type: .project("Project"),
                   children: [
                    TMType(tabLevel: 1, type: .task("Task"),
                           children: [
                            TMType(tabLevel: 2, type: .task("Subtask"),
                                   children: [
                                    TMType(tabLevel: 3, type: .text("Subtask text"))
                                   ])
                           ]),
                    TMType(tabLevel: 1, type: .task("Other Task"))
                   ]),
            TMType(type: .text("")),
            TMType(type: .project("Subsequent Project"))
        ]
        let sut = TMType.normalize(initialList)
        XCTAssertEqual(sut, expectedList)
    }

    func test_parser_ofSampleText_returnsCorrectValue() {
        let expected = [
            TMType(type: .project("Project")),
            TMType(tabLevel: 1,
                   type: .text("Notes on a project.")),
            TMType(tabLevel: 1,
                   type: .text("TaskPaper uses a hierarchical structure to keep track of parents and ownership.")),
            TMType(tabLevel: 1,
                   type: .text("ie; all of the below items are within this project.")),
            TMType(tabLevel: 1,
                   type: .task("Item for that project.")),
            TMType(tabLevel: 2,
                   type: .task("Child item with a note.")),
            TMType(tabLevel: 3,
                   type: .text("Note about that item.")),
            TMType(tabLevel: 1,
                   type: .task("Tagged Item"), tags: [.tag("tag")]),
            TMType(tabLevel: 1,
                   type: .task("Tagged Item where the tag has a payload"),
                   tags: [.payloadTag("tag", "payload")]),
            TMType(tabLevel: 1,
                   type: .text("Let\'s illustrate some of the time formats that we\'ve worked so hard on.")),
            TMType(tabLevel: 1,
                   type: .task("Something completed"),
                   tags: [.tag("test"), .payloadTag("due", "2024-11-23"), .payloadTag("done", "2024-11-23")]),
            TMType(tabLevel: 1,
                   type: .task("Something with a set due date and time"),
                   tags: [.tag("test"), .payloadTag("due", "2024-11-24 10:00")]),
            TMType(tabLevel: 1,
                   type: .task("An appointment"),
                   tags: [.tag("test"), .payloadTag("due", "2024-11-24 10:00-10:30")]),
            TMType(tabLevel: 1,
                   type: .task("A spanning appointment"),
                   tags: [.tag("test"), .payloadTag("due", "2024-11-23 11:00 thru 2024-11-24 10:00")]),
            TMType(type: .text("")),
            TMType(type: .project("Other Project")),
            TMType(tabLevel: 1,
                   type: .task("Item for the other project")),
            TMType(type: .text(""))
        ]
        let sut = TMType.parse(string: TMTypeTests.testSampleText)
        XCTAssertEqual(sut, expected)
    }

    func test_normalize_withLowerIndentation_returnsCorrectValue() {
        let parsed = [
            TMType(tabLevel: 1,
                   type: .project("Project:")),
            TMType(tabLevel: 2,
                   type: .task("Task")),
            TMType(tabLevel: 3,
                   type: .task("SubTask")),
            TMType(tabLevel: 4,
                   type: .text("SubTask's Text")),
            TMType(type: .text("")),
            TMType(type: .project("Additional Project")),
            TMType(tabLevel: 1,
                   type: .task("Task"))
        ]
        let expected = [
            TMType(tabLevel: 1,
                   type: .project("Project:"),
                   children: [
                    TMType(tabLevel: 2,
                           type: .task("Task"),
                           children: [
                            TMType(tabLevel: 3,
                                   type: .task("SubTask"),
                                   children: [
                                    TMType(tabLevel: 4,
                                           type: .text("SubTask's Text"))
                                   ])
                           ])
                   ]),
            TMType(type: .text("")),
            TMType(type: .project("Additional Project"),
                   children: [
                    TMType(tabLevel: 1,
                           type: .task("Task"))
                   ])
        ]
    }

    func test_normalize_parsedSampleText_returnsCorrectValue() {
        let parsed = TMType.parse(string: TMTypeTests.testSampleText)
        let sut = TMType.normalize(parsed)
        XCTAssertEqual(sut, TMType.TestSampleModel)
    }
}
