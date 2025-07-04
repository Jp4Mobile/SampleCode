//
//  TCATagView.swift
//  TaskManager
//
//  Created by Jp LaFond on 6/23/25.
//

import ComposableArchitecture
import SwiftUI

/*
 TCA Features are broken down into two parts:
 * The Reducer which will have three parts:
   - State (the properties that can be read or changed)
   - Actions (the actions that will change the state)
   - Body (the reducer itself that will take current state, and current action and result in the updated state or next action)
 * The View with a bindable store and the visible UI/UX.
 */

// MARK: - Reducer
@Reducer
struct TagSimpleBindingConverter {
    // MARK: State
    @ObservableState
    struct State: Equatable {
        var editMode: EditMode
        var initialTag: Tag
        var tag: Tag {
            didSet {
                text = tag.toString
            }
        }
        var text: String

        init(tag: Tag) {
            self.initialTag = tag
            self.tag = tag
            self.text = tag.toString
            self.editMode = .inactive
        }
    }

    // MARK: Action
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
    }

    // MARK: Body (Reducer)
    var body: some Reducer<State, Action> {
        BindingReducer()
    }
}

// MARK: - View
struct TCASimpleBindingTagView: View {
    @Bindable
    var store: StoreOf<TagSimpleBindingConverter>
    @ScaledMetric(relativeTo: .caption) private var scaledPadding = Spacing.default

    var body: some View {
        Group {
            if store.editMode == .active {
                textFieldTag
            } else {
                textTag
            }
        }
    }
}

// MARK: SubViews
extension TCASimpleBindingTagView {
    func textTag(tag: Tag) -> Text {
        guard let payload = tag.payload else {
            return Text("@\(tag.tag)")
        }

        return Text("@\(tag.tag)(**\(payload)**)")
    }

    var textTag: some View {
        textTag(tag: store.tag)
            .font(.caption)
            .textScale(.secondary)
            .tint(Color.Tag.tint)
            .multilineTextAlignment(.trailing)
            .padding(scaledPadding)
            .overlay(
                Capsule()
                    .stroke(Color.Tag.border,
                           lineWidth: 1)
            )
            .onLongPressGesture {
                store.editMode = .active
            }
    }

    var textFieldTag: some View {
        TextField(Constants.Tag.placeholder,
                  text: $store.text,
                  axis: .vertical)
        .textFieldStyle(.plain)
        .multilineTextAlignment(.center)
        .onSubmit {
            onTextFieldSubmission()
        }
        .font(.caption)
        .textScale(.secondary)
        .tint(Color.Tag.tint)
        .padding(scaledPadding)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 1,
                                          dash: [2]))
                .foregroundStyle(Color.Tag.border)
        )
    }
}

// MARK: Helper Functions
extension TCASimpleBindingTagView {
    func onTextFieldSubmission() {
        defer {
            store.editMode = .inactive
        }

        guard let updatedTag = store.text.toTag() else {
            // TODO: Present an error
            store.text = store.tag.toString
            return
        }
        store.tag = updatedTag
    }
}

#Preview {
    ScrollView {
        TCASimpleBindingTagView(
            store: Store(
                initialState:
                    TagSimpleBindingConverter.State(tag: Tag("test")
                                      )
            ) {
                TagSimpleBindingConverter()
            }
        )
        TCASimpleBindingTagView(
            store: Store(
                initialState:
                    TagSimpleBindingConverter.State(tag: Tag(.due, payload: "2025-06-07")
                                      )
            ) {
                TagSimpleBindingConverter()
            }
        )
        TCASimpleBindingTagView(
            store: Store(
                initialState:
                    TagSimpleBindingConverter.State(tag: Tag(.due, payload: "2025-06-07 10:00")
                                      )
            ) {
                TagSimpleBindingConverter()
            }
        )
        TCASimpleBindingTagView(
            store: Store(
                initialState:
                    TagSimpleBindingConverter.State(tag: Tag(.due, payload: "2025-06-07 10:00-11:00")
                                      )
            ) {
                TagSimpleBindingConverter()
            }
        )
        TCASimpleBindingTagView(
            store: Store(
                initialState:
                    TagSimpleBindingConverter.State(tag: Tag(.due, payload: "2025-06-07 10:00 thru 2025-06-09 13:00")
                                      )
            ) {
                TagSimpleBindingConverter()
            }
        )
    }
}
