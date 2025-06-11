//
//  TCATaskFeatureTests.swift
//  TaskManager
//
//  Created by Jp LaFond on 6/11/25.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import TaskManager

@MainActor
struct TCATaskFeatureTests {
    // MARK: - Exhaustive Tests
    // MARK: addFlow
    @Test
    func testExhaustiveAddFlow() async {
        // Set up
        let store = TestStore(initialState: TCATaskFeature.State()) {
            TCATaskFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        // Walk thru the whole flow
        await store.send(.addButtonTapped) {
            $0.destination = .addTask(
                AddEditTCATaskFeature.State(mode: .add,
                                            task: TCATask(id: UUID(0),
                                                          text: "")
                                           )
            )
        }
        await store.send(\.destination.addTask.setText, "Project:") {
            $0.destination?.modify(\.addTask) { $0.task.text = "Project:" }
        }
        await store.send(\.destination.addTask.saveButtonTapped)
        await store.receive(
            \.destination.addTask.delegate.saveTask,
             TCATask(id: UUID(0), text: "Project:")
        ) {
            $0.tasks = [
                TCATask(id: UUID(0), text: "Project:")
            ]
        }
        await store.receive(\.destination.dismiss) {
            $0.destination = nil
        }
    }

    // MARK: - Non-Exhaustive Tests
    // MARK: addFlow saved
    @Test
    func test_addFlow_saveButtonTapped() async {
        // Set up
        let store = TestStore(initialState: TCATaskFeature.State()) {
            TCATaskFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        // Verify the save button tapped flow
        await store.send(.addButtonTapped)
        await store.send(\.destination.addTask.setText, "Project:")
        await store.send(\.destination.addTask.saveButtonTapped)

        await store.skipReceivedActions()
        store.assert {
            $0.tasks = [
                TCATask(id: UUID(0), text: "Project:")
            ]
            $0.destination = nil
        }
    }

    // MARK: addFlow canceled
    @Test
    func test_addFlow_cancelButtonTapped() async {
        // Set up
        let store = TestStore(initialState: TCATaskFeature.State()) {
            TCATaskFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        // Verify the save button tapped flow
        await store.send(.addButtonTapped)
        await store.send(\.destination.addTask.setText, "Project:")
        await store.send(\.destination.addTask.cancelButtonTapped)

        await store.skipReceivedActions()
        store.assert {
            $0.tasks = [
            ]
            $0.destination = nil
        }
    }

    // MARK: editFlow saved
    @Test
    func test_editFlow_saveButtonTapped() async {
        // Set up
        let store = TestStore(initialState: TCATaskFeature.State(
            tasks: [
                TCATask(id: UUID(0), text: "Project"),
                TCATask(id: UUID(1), text: "- Task @tag @due(2025-06-11)"),
                TCATask(id: UUID(2), text: "Text"),
                TCATask(id: UUID(3), text: "New Item")
            ]
        )) {
            TCATaskFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        // Verify the save button tapped flow
        await store.send(.editTask(TCATask(id: UUID(3), text: "New Item")))
        await store.send(\.destination.editTask.setText, "New Item (Updated)")
        await store.send(\.destination.editTask.saveButtonTapped)

        await store.skipReceivedActions()
        store.assert {
            $0.tasks = [
                TCATask(id: UUID(0), text: "Project"),
                TCATask(id: UUID(1), text: "- Task @tag @due(2025-06-11)"),
                TCATask(id: UUID(2), text: "Text"),
                TCATask(id: UUID(3), text: "New Item (Updated)")
            ]
            $0.destination = nil
        }

    }

    // MARK: editFlow canceled
    @Test
    func test_editFlow_cancelButtonTapped() async {
        // Set up
        let store = TestStore(initialState: TCATaskFeature.State(
            tasks: [
                TCATask(id: UUID(0), text: "Project"),
                TCATask(id: UUID(1), text: "- Task @tag @due(2025-06-11)"),
                TCATask(id: UUID(2), text: "Text"),
                TCATask(id: UUID(3), text: "New Item")
            ]
        )) {
            TCATaskFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        // Verify the save button tapped flow
        await store.send(.editTask(TCATask(id: UUID(3), text: "New Item")))
        await store.send(\.destination.editTask.setText, "New Item (Updated)")
        await store.send(\.destination.editTask.cancelButtonTapped)

        await store.skipReceivedActions()
        store.assert {
            $0.tasks = [
                TCATask(id: UUID(0), text: "Project"),
                TCATask(id: UUID(1), text: "- Task @tag @due(2025-06-11)"),
                TCATask(id: UUID(2), text: "Text"),
                TCATask(id: UUID(3), text: "New Item")
            ]
            $0.destination = nil
        }

    }

    // MARK: editFlow delete (not confirmed)
    @Test
    func test_editFlow_deleteButtonTapped_notConfirmed() async {
        // Set up
        let store = TestStore(initialState: TCATaskFeature.State(
            tasks: [
                TCATask(id: UUID(0), text: "Project"),
                TCATask(id: UUID(1), text: "- Task @tag @due(2025-06-11)"),
                TCATask(id: UUID(2), text: "Text"),
                TCATask(id: UUID(3), text: "New Item")
            ]
        )) {
            TCATaskFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        // Verify the save button tapped flow
        await store.send(.editTask(TCATask(id: UUID(3), text: "New Item")))
        await store.send(\.destination.editTask.deleteButtonTapped)

        await store.skipReceivedActions()
        store.assert {
            $0.tasks = [
                TCATask(id: UUID(0), text: "Project"),
                TCATask(id: UUID(1), text: "- Task @tag @due(2025-06-11)"),
                TCATask(id: UUID(2), text: "Text"),
                TCATask(id: UUID(3), text: "New Item")
            ]
            $0.destination = nil
        }

    }

    // MARK: editFlow delete (confirmed)
    @Test
    func test_editFlow_deleteButtonTapped_confirmed() async {
        // Set up
        let store = TestStore(initialState: TCATaskFeature.State(
            tasks: [
                TCATask(id: UUID(0), text: "Project"),
                TCATask(id: UUID(1), text: "- Task @tag @due(2025-06-11)"),
                TCATask(id: UUID(2), text: "Text"),
                TCATask(id: UUID(3), text: "New Item")
            ]
        )) {
            TCATaskFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        // Verify the save button tapped flow
        await store.send(.editTask(TCATask(id: UUID(3), text: "New Item")))
        await store.send(\.destination.editTask.deleteButtonTapped)
        await store.send(\.alert.presented.confirmDeletion, UUID(3))

        // There are no skipped actions, so there doesn't need to be an await on those...
        store.assert {
            $0.tasks = [
                TCATask(id: UUID(0), text: "Project"),
                TCATask(id: UUID(1), text: "- Task @tag @due(2025-06-11)"),
                TCATask(id: UUID(2), text: "Text")
            ]
            $0.destination = nil
        }

    }
}
