//
//  TCATagFeatureTests.swift
//  TaskManager
//
//  Created by Jp LaFond on 7/5/25.
//

import ComposableArchitecture
import SwiftUI
import Testing
import XCTest

@testable import TaskManager

final class TCATagFeatureTests {
    // MARK: - Exhaustive Tests
    /*
     Exhaustive tests test and verify each change to the TCA state from an
     initial state to the end of a specific flow through the app.
     We current have two flows through the `TCATagFeatureFinalPass`: successful
     and not successful.
     We could test both a negative flow and a positive flow in the same test,
     but I've always felt a proper unit test will test a specific thing and that
     alone.
     */
    @Test
    func test_exhaustive_successfulEditFlow() async throws {
        let expectedTag = try XCTUnwrap("@tag".toTag())
        let expectedText = "@tag()"
        // Set up
        let store = TestStore(initialState:
                                TagConverter.State(tag: Constants.MockTag.test)
        ) {
            TagConverter()
        }

        // Walk through the flow
        await store.send(.tapped) {
            $0.editMode = .active
        }
        await store.send(.entered(expectedText)) {
            $0.text = expectedText
        }
        // Valid text, when submitted, triggers the update flow
        await store.send(.submitted) {
            $0.editMode = .inactive
            $0.tag = expectedTag
            // And verifies the normalized text (which is different than the entered text)
            $0.text = expectedTag.toString
        }
    }

    @Test
    func test_exhaustive_unsuccessfulEditFlow() async throws {
        let expectedText = "tag(payload"
        // Set up
        let store = await TestStore(initialState:
                                        TagConverter.State(tag: Constants.MockTag.test)
        ) {
            TagConverter()
        }

        // Walk through the flow
        await store.send(.tapped) {
            $0.editMode = .active
        }
        await store.send(.entered(expectedText)) {
            $0.text = expectedText
        }
        // Invalid text, when submitted, triggers the error flow
        await store.send(.submitted) {
            $0.errorMessage = "Unable to convert <\(expectedText)> into a tag."
        }
    }

    // MARK: - Inexhaustive Tests
    /*
     Inexaustive tests are much more finite and verify only specific change from
     specific actions.
     */
    // MARK: Error flows
    @Test
    func test_inexhaustive_tapped_initiatesEditFlow() async {
        // Set up
        let store = TestStore(initialState:
                                TagConverter.State(tag: Constants.MockTag.test)
            ) {
            TagConverter()
        }
        store.exhaustivity = .off

        // We only test the tap
        await store.send(.tapped) {
            $0.editMode = .active
        }
    }

    @Test
    func test_inexhaustive_invalidSubmission_generatesError() async {
        let expectedText = "tag(payload"
        // Set up
        let store = TestStore(initialState:
                                TagConverter.State(Constants.MockTag.test,
                                                   editMode: .active,
                                                   text: expectedText)
        ) {
            TagConverter()
        }
        store.exhaustivity = .off

        // Verify the submission error flow
        await store.send(.submitted) {
            $0.errorMessage = "Unable to convert <\(expectedText)> into a tag."
        }
    }

    @Test
    func test_inexhaustive_subsequentValidSubmission_clearsErrorAndSetsStateProperly() async throws {
        let expectedText = "@tag(payload)"
        let expectedTag = try XCTUnwrap(expectedText.toTag())

        // Set up
        let store = TestStore(initialState:
                                TagConverter.State(Constants.MockTag.test,
                                                   editMode: .active,
                                                   errorMessage: "Shown Error",
                                                   text: expectedText)
        ) {
            TagConverter()
        }
        store.exhaustivity = .off

        // Verify a successful subsequent submission resets editMode, sets the tag,
        // and clears any error
        await store.send(.submitted) {
            $0.editMode = .inactive
            $0.errorMessage = nil
            $0.tag = expectedTag
        }
    }
}
