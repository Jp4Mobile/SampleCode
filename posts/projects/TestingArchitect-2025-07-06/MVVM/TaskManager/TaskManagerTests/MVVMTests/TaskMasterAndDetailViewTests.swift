//
//  TaskMasterAndDetailViewTests.swift
//  TaskManager
//
//  Created by Jp LaFond on 7/4/25.
//

import XCTest

@testable import TaskManager

final class TaskMasterAndDetailViewTests: XCTestCase {
    var sut: TaskMasterAndDetailView.ViewModel!

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    // MARK: - Initializer Tests
    func test_init_forAdd_setsThingsProperly() {
        sut = .init()

        XCTAssertNil(sut.selectedItem)
        XCTAssertNil(sut.responseType)
        XCTAssertEqual(sut.detailMode, .add)
        XCTAssertTrue(sut.items.isEmpty)
    }

    func test_init_forEdit_setsThingsProperly() {
        sut = .init(detailMode: .edit)

        XCTAssertEqual(sut.detailMode, .edit)
    }

    // MARK: - Add Item Tests
    func test_addItem_setsThingsProperly() {
        sut = .init()

        sut.addItem(from: nil)

        XCTAssertEqual(sut.items.map { $0.type}, [TMType(type:.text(""))])
        XCTAssertEqual(sut.selectedItem, sut.items.first)
    }

    // MARK: - Select Item Tests
    func test_selectItem_setsThingsProperly() {
        let project: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.project)
        sut = .init(items: [
            project,
            .init(id: "002", TMType.Mock.TopLevel.task),
            .init(id: "003", TMType.Mock.TopLevel.text)
        ])

        sut.select(item: project)
        XCTAssertEqual(sut.detailMode, .edit)
        XCTAssertEqual(sut.selectedItem, project)
    }

    // MARK: - Process Tests
    func test_process_canceledAdd_whenPresent_removesElement() {
        let project: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.project)
        sut = .init(items: [project])
        sut.selectedItem = project
        XCTAssertEqual(sut.items, [project])

        sut.process(.canceled(project))

        XCTAssertTrue(sut.items.isEmpty)
        XCTAssertNil(sut.selectedItem)
    }

    func test_process_canceledAdd_whenNotPresent_deletesNothing() {
        let project: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.project)
        let task: IdentifiedTMType = .init(id: "002", TMType.Mock.TopLevel.task)

        sut = .init(selectedItem: task, items: [project])
        sut.process(.canceled(task))

        XCTAssertEqual(sut.items, [project])
    }

    func test_process_canceledEdit_whenPresent_deletesNothing() {
        let project: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.project)

        sut = .init(selectedItem: project, detailMode: .edit, items: [project])
        sut.process(.canceled(project))

        XCTAssertEqual(sut.items, [project])
    }

    func test_process_deleted_whenPresent_removedElement() {
        let project: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.project)

        sut = .init(selectedItem: project, detailMode: .edit, items: [project])
        sut.process(.deleted(project))

        XCTAssertTrue(sut.items.isEmpty)
    }

    func test_process_deleted_whenNotPresent_doesNothing() {
        let project: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.project)
        let task: IdentifiedTMType = .init(id: "002", TMType.Mock.TopLevel.task)

        sut = .init(selectedItem: task, items: [project])
        sut.process(.deleted(task))

        XCTAssertEqual(sut.items, [project])
    }

    func test_process_saved_whenPresent_updates() {
        let initial: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.project)
        let expected: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.task)

        sut = .init(selectedItem: initial, items: [initial])
        sut.process(.save(expected))

        XCTAssertEqual(sut.items, [expected])
    }

    func test_process_saved_whenNotPresent_doesNothing() {
        let project: IdentifiedTMType = .init(id: "001", TMType.Mock.TopLevel.project)
        let task: IdentifiedTMType = .init(id: "002", TMType.Mock.TopLevel.task)

        sut = .init(selectedItem: task, items: [project])
        sut.process(.save(task))

        XCTAssertEqual(sut.items, [project])
    }
}
