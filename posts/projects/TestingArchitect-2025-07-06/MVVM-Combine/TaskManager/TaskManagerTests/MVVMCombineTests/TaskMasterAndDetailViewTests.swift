//
//  TaskMasterAndDetailViewTests.swift
//  TaskManager
//
//  Created by Jp LaFond on 7/5/25.
//

import SwiftUI
import XCTest

@testable import TaskManager

final class TaskMasterAndDetailViewTests: XCTestCase {
    var sut: TaskMasterAndDetailView.ViewModel!

    override func setUp() {
        super.setUp()

        sut = .init(initialState: .init())
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    // MARK: - addItem test
    func test_addItem_fromNil_setsProperly() {
        XCTAssertTrue(sut.state.items.isEmpty)
        XCTAssertNil(sut.state.selectedItem)

        sut.addItem(from: nil)

        XCTAssertEqual(sut.state.items.count, 1)
        XCTAssertEqual(sut.state.items.first?.type, TMType(type: .text("")))
        XCTAssertEqual(sut.state.selectedItem, sut.state.items.first)
    }

    // MARK: - select test
    func test_select_updatesValuesProperly() {
        let project = IdentifiedTMType(id: "001", TMType.Mock.TopLevel.project)
        sut.update(\.items, to: [project])

        sut.select(item: project)

        XCTAssertEqual(sut.state.detailMode, .edit)
        XCTAssertEqual(sut.state.selectedItem, project)
    }

    // MARK: - process tests
    func test_cancel_whenAdding_removesExistingItem() {
        let project = IdentifiedTMType(id: "001", TMType.Mock.TopLevel.project)

        sut.update(\.items, to: [project])

        XCTAssertEqual(sut.state.detailMode, .add)

        sut.process(.canceled(project))

        XCTAssertTrue(sut.state.items.isEmpty)
    }

    func test_cancel_whenEditing_doesNothing() {
        let project = IdentifiedTMType(id: "001", TMType.Mock.TopLevel.project)

        sut.update(\.items, to: [project])
        sut.update(\.detailMode, to: .edit)

        sut.process(.canceled(project))

        XCTAssertEqual(sut.state.items, [project])
    }

    func test_deleted_whenPresent_removesItem() {
        let project = IdentifiedTMType(id: "001", TMType.Mock.TopLevel.project)

        sut.update(\.items, to: [project])
        sut.update(\.detailMode, to: .edit)

        sut.process(.deleted(project))

        XCTAssertTrue(sut.state.items.isEmpty)
    }

    func test_saved_whenPresent_updatesItem() {
        let initial = IdentifiedTMType(id: "001", TMType.Mock.TopLevel.project)
        let expected = IdentifiedTMType(id: "001", TMType.Mock.TopLevel.task)

        sut.update(\.items, to: [initial])

        sut.process(.save(expected))

        XCTAssertEqual(sut.state.items, [expected])
    }
}
