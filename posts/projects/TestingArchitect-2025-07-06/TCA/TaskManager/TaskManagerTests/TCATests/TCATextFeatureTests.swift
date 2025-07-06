//
//  TCATextFeatureTests.swift
//  TaskManager
//
//  Created by Jp LaFond on 7/5/25.
//

import ComposableArchitecture
import SwiftUI
import Testing
import XCTest

@testable import TaskManager

final class TCATextFeatureTests {
    // MARK: - Exhaustive Tests
    @Test
    func test_wholeErrorFlow_forEmptyString_presentsProperError() async {
        let expectedType: TCATask = .init(id: UUID(),
                                          task: TMType.Mock.TopLevel.task)
        let expectedErrorMessage = "Unable to parse <>."
        // Set up
        let store = TestStore(initialState:
                                TCATextFeature.State(expectedType)
        ) {
            TCATextFeature()
        }

        // Walk through the flow
        await store.send(.entered("")) {
            $0.text = ""
        }
        await store.send(.saveButtonTapped)
        await store.receive(.error(expectedErrorMessage)) {
            $0.errorMessage = expectedErrorMessage
        }
    }

    @Test
    func test_wholeErrorFlow_forMultipleTasks_presentsProperError() async {
        let initialType: TCATask = .init(id: UUID(),
                                         task: TMType.Mock.TopLevel.task)
        let expectedType: TCATask = .init(id: initialType.id,
                                          task: TMType.Mock.TopLevel.project)
        let enteredText = TMType.Mock.TopLevel.project.toString + "\n" +
            TMType.Mock.TopLevel.project.toString
        let expectedErrorMessage = "Only the first converted type model is saved." +
            " You may need to change indentation to keep them under the proper " +
            "project."
        let expectedText = TMType.Mock.TopLevel.project.toString

        // Set up
        let store = TestStore(initialState:
                                TCATextFeature.State(initialType)
        ) {
            TCATextFeature()
        }

        // Walk through the flow
        await store.send(.entered(enteredText)) {
            $0.text = enteredText
        }
        await store.send(.saveButtonTapped)
        await store.receive(.errorAndTask(expectedErrorMessage, expectedType)) {
            $0.errorMessage = expectedErrorMessage
            $0.task = expectedType
            $0.errorMessage = expectedErrorMessage
        }
    }

    @Test
    func test_wholeSuccessFlow_setsStateProperly() async {
        let initialType: TCATask = .init(id: UUID(),
                                         task: TMType.Mock.TopLevel.task)
        let expectedType: TCATask = .init(id: initialType.id,
                                          task: TMType.Mock.Projects.projectWithTasks)
        let expectedText = TMType.Mock.Projects.projectWithTasks.toString

        // Set up
        let store = TestStore(initialState:
                                TCATextFeature.State(initialType)
        ) {
            TCATextFeature()
        }

        // Walk through the flow
        await store.send(.entered(expectedText)) {
            $0.text = expectedText
        }
        await store.send(.saveButtonTapped)
        await store.receive(.saveTask(expectedType)) {
            $0.task = expectedType
        }
    }

    // MARK: - Inexhaustive Tests
    @Test
    func test_successPath_invalidTest_dueToDidSets() async {
        let initialType: TCATask = .init(id: UUID(),
                                         task: TMType.Mock.TopLevel.task)
        let expectedType: TCATask = .init(id: initialType.id,
                                          task: TMType.Mock.TopLevel.project)
        let expectedText = TMType.Mock.TopLevel.project.toString
        // Set up
        // Using the broken initializer. The order of the sets cause the text
        // not to be what's expected.
        let store = TestStore(initialState:
                                TCATextFeature.State(broken: initialType,
                                                     text: expectedText,
                                                     errorMessage: "errorMessage")
        ) {
            TCATextFeature()
        }
        store.exhaustivity = .off

        // Test Success flow portion
        // Instead of setting the initial text as expected, the initializer's
        // bug caused it to be set it to the wrong value.
        XCTAssertEqual(store.state.text, initialType.task.toString)
        // Everything after flowed from the incorrect value in the text
        await store.send(.saveButtonTapped)
        await store.receive(.saveTask(initialType)) {
            $0.task = initialType
            $0.errorMessage = nil
        }
    }

    @Test
    func test_successPath_clearsErrorMessageAndSavesStateProperly() async {
        let initialType: TCATask = .init(id: UUID(),
                                         task: TMType.Mock.TopLevel.task)
        let expectedType: TCATask = .init(id: initialType.id,
                                          task: TMType.Mock.TopLevel.project)
        let expectedText = TMType.Mock.TopLevel.project.toString
        // Set up
        let store = TestStore(initialState:
                                TCATextFeature.State(task: initialType,
                                                     text: expectedText,
                                                     errorMessage: "errorMessage")
        ) {
            TCATextFeature()
        }
        store.exhaustivity = .off

        // Test Success flow portion
        await store.send(.saveButtonTapped)
        await store.receive(.saveTask(expectedType)) {
            $0.task = expectedType
            $0.errorMessage = nil
        }
    }
}
