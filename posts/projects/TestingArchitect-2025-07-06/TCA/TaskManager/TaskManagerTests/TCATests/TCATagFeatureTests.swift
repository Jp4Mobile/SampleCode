//
//  TCATagFeatureTests.swift
//  TaskManagerTests
//
//  Created by Jp LaFond on 6/29/25.
//

import ComposableArchitecture
import SwiftUI
import Testing
import XCTest

@testable import TaskManager

final class TCATagFeatureTests {
    // MARK: - Exhaustive Tests
    @Test
    func test_exhaustive_editFlow() async throws {
        let expectedTag = try XCTUnwrap("@tag(payload)".toTag())
        // Set up
        let store = TestStore(initialState: TagConverter.State(tag: Constants.MockTag.test)) {
            TagConverter()
        }

        // Walk through the flow
        await store.send(.tapped) {
            $0.editMode = .active
        }
        await store.send(.entered("tag(payload)")) {
            $0.text = "tag(payload)"
        }
        // Invalid text triggers the error flow
        await store.send(.submitted("tag(payload)"))
        // Which resets the store.
        await store.receive(
            .error("Unable to convert <tag(payload)> into a tag.")
        ) {
            $0.errorMessage = "Unable to convert <tag(payload)> into a tag."
            $0.editMode = .inactive
            $0.text = $0.tag.toString
        }
        // Valid text triggers the update flow
        await store.send(.tapped) {
            $0.editMode = .active
        }
        await store.send(.entered("@tag(payload)")) {
            $0.text = "@tag(payload)"
        }
        await store.send(.submitted("@tag(payload)"))
        await store.receive(
            .saved(expectedTag)
        ) {
            $0.errorMessage = nil
            $0.tag = expectedTag
            $0.editMode = .inactive
        }
    }

    // MARK: - Non-Exhaustive Tests
    // MARK: editFlow initiated
    @Test
    func test_inexhaustive_editFlow_tapped() async {
        // Set up
        let store = TestStore(initialState: TagConverter.State(tag: Constants.MockTag.test)) {
            TagConverter()
        }
        store.exhaustivity = .off

        // Walk through the flow
        await store.send(.tapped) {
            $0.editMode = .active
        }
    }

    @MainActor
    @Test
    func test_inexhaustive_invalidEditFlow_generatesAnError() async {
        // Set up
        var state = TagConverter.State(tag: Constants.MockTag.test)
        state.editMode = .active
        state.text = "tag(payload)"

        let store = await TestStore(initialState: state) {
            TagConverter()
        }
        store.exhaustivity = .off

        // Walk through the error flow
        await store.send(.submitted("tag(payload)"))
        await store.receive(
            .error("Unable to convert <tag(payload)> into a tag.")
        ) {
            $0.errorMessage = "Unable to convert <tag(payload)> into a tag."
            $0.editMode = .inactive
            $0.text = $0.tag.toString
        }
    }

    @MainActor
    @Test
    func test_inexhaustive_validEditFlow_updatesTag() async throws {
        let expectedTag = try XCTUnwrap("@tag(payload)".toTag())
        // Set up
        var state = TagConverter.State(tag: Constants.MockTag.test)
        state.editMode = .active
        state.text = "@tag(payload)"

        let store = await TestStore(initialState: state) {
            TagConverter()
        }
        store.exhaustivity = .off

        // Walk through the error flow
        await store.send(.submitted("@tag(payload)"))
        await store.receive(
            .saved(expectedTag)
        ) {
            $0.editMode = .inactive
            $0.tag = expectedTag
            $0.text = expectedTag.toString
        }
    }
}
