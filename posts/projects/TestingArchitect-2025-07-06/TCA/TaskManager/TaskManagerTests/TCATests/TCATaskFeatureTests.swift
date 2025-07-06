//
//  TCATaskFeatureTests.swift
//  TaskManager
//
//  Created by Jp LaFond on 7/5/25.
//

import ComposableArchitecture
import SwiftUI
import Testing

@testable import TaskManager

final class TCATaskFeatureTests {
    // MARK: - Exhaustive Tests
    @Test
    func test_addFlow_withSave() async {
        let expectedTask: TCATask = .init(id: UUID(0), task: .init(type: .text("")))
        let updatedTask: TCATask = .init(id: UUID(0), task: .init(type: .task("Call Home")))

        // Set up
        let state: TCATaskFeature.State = .init()
        let store = TestStore(initialState: state) {
            TCATaskFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        // Walk through the flow
        await store.send(.addButtonTapped) {
            $0.destination = .addTask(TCAAddEditTaskFeature.State(
                mode: .add,
                task: expectedTask
            ))
        }
        // Add View, editing, and returning a valid task...
        await store.send(.destination(.presented(.addTask(.delegate(.saveTask(updatedTask)))))) {
            $0.tasks = [updatedTask]
        }
    }

    @Test
    func test_editFlow_withDelete() async {
        let initialTask: TCATask = .init(id: UUID(0), task: .init(type: .task("Call Home")))
        let updatedTask: TCATask = .init(id: UUID(0), task: .init(type: .project("Project")))

        // Set up
        let state: TCATaskFeature.State = .init(tasks: [initialTask])
        let store = TestStore(initialState: state) {
            TCATaskFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        // Walk through the flow
        await store.send(.editTask(initialTask)) {
            $0.destination = .editTask(TCAAddEditTaskFeature.State(
                mode: .edit,
                task: initialTask
            ))
        }
        await store.send(.destination(.presented(.editTask(.delegate(.saveTask(updatedTask)))))) {
            $0.tasks = [updatedTask]
        }
        await store.send(.editTask(updatedTask)) {
            $0.destination = .editTask(TCAAddEditTaskFeature.State(
                mode: .edit,
                task: updatedTask
            ))
        }
        await store.send(.deleteSent(initialTask)) {
            $0.alert = AlertState {
                TextState(Constants.Alert.message)
            } actions: {
                ButtonState(role: .destructive,
                            action: .confirmDeletion(id: initialTask.id)) {
                    TextState(Constants.Alert.deleteTitle)
                }
            }
        }
        await store.send(.alert(.presented(.confirmDeletion(id: initialTask.id)))) {
            $0.tasks = []
            $0.alert = nil
        }
    }
    // MARK: - Inexaustive Tests
    @Test
    func test_subsequentAddItems_haveDifferentIDs() async {
        let initialTask: TCATask = .init(id: UUID(0), task: .init(type: .text("")))
        let addedTask: TCATask = .init(id: UUID(1), task: .init(type: .text("")))

        // Set up
        let state: TCATaskFeature.State = .init()
        let store = TestStore(initialState: state) {
            TCATaskFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        // Walk through the flow
        await store.send(.addButtonTapped) {
            $0.destination = .addTask(TCAAddEditTaskFeature.State(
                mode: .add,
                task: initialTask
            ))
        }
        await store.send(.addButtonTapped) {
            $0.destination = .addTask(TCAAddEditTaskFeature.State(
                mode: .add,
                task: addedTask
            ))
        }
    }
}
