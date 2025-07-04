//
//  TCATagFeature (Final Pass).swift
//  TaskManager
//
//  Created by Jp LaFond on 6/23/25.
//

/*
 TCA Features are broken down into two parts:
 * The Reducer which will have three parts:
 - State (the properties that can be read or changed)
 - Actions (the actions that will change the state)
 - Body (the reducer itself that will take current state, and current action and result in the updated state or next action)
 * The View with a bindable store and the visible UI/UX.

 This changes to a slightly different way of handling the TagView with more explicit actions.
 */

import ComposableArchitecture
import SwiftUI

// MARK: - Reducer
@Reducer
struct TagConverter {
    // MARK: State
    @ObservableState
    struct State: Equatable {
        // MARK: Properties
        /// An optional error message to present to the user, if present
        var errorMessage: String?
        /// The edit state of the view
        var editMode: EditMode = .inactive
        /// The actual tag
        var tag: Tag
        /// The entered text to be converted into the tag
        var text: String

        // MARK: Computed Properties
        var isEditing: Bool {
            editMode == .active
        }
        var shouldPresentError: Bool {
            errorMessage != nil
        }

        // MARK: Initializer
        init(tag: Tag) {
            self.tag = tag
            self.text = tag.toString
        }

        init(_ tag: Tag,
             editMode: EditMode = .inactive,
             errorMessage: String? = nil,
             text: String? = nil) {
            self.tag = tag
            self.text = text ?? tag.toString
            self.editMode = editMode
            self.errorMessage = errorMessage
        }
    }

    // MARK: Action
    enum Action {
        /// When the user taps on the tag to initiate editing
        case tapped
        /// When the user changes the text in the text field
        case entered(String)
        /// When the user taps return to submit the answer
        case submitted
    }

    // MARK: Body (Reducer)
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .tapped:
                state.editMode = .active
                return .none

            case let .entered(text):
                state.text = text
                return .none

            case .submitted:
                guard let newTag = state.text.toTag() else {
                    let errorMessage = "Unable to convert <\(state.text)> into a tag."
                    state.errorMessage = errorMessage
                    return .none
                }

                state.tag = newTag
                state.errorMessage = nil
                // Clear the state
                state.editMode = .inactive
                state.text = newTag.toString
                return .none
            }
        }
    }
}

// MARK: - View
struct TCATagView: View {
    @Bindable
    var store: StoreOf<TagConverter>
    @ScaledMetric(relativeTo: .caption) private var scaledPadding = Spacing.default

    var body: some View {
        VStack {
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            if store.isEditing {
                editTagView
            } else {
                tagView
            }
        }
    }
}

// MARK: SubViews
extension TCATagView {
    func tagView(tag: Tag) -> Text {
        guard let payload = tag.payload else {
            return Text("@\(tag.tag)")
        }
        return Text("@\(tag.tag)(**\(payload)**)")
    }

    var tagView: some View {
        tagView(tag: store.tag)
            .captionMode()
            .tint(Color.Tag.tint)
            .overlay(
                Capsule()
                    .stroke(store.shouldPresentError ? .red : Color.Tag.border,
                            lineWidth: 1)
            )
            .onLongPressGesture {
                store.send(.tapped)
            }
    }

    var editTagView: some View {
        TextField(Constants.Tag.placeholder,
                  text: $store.text.sending(\.entered),
                  axis: .vertical)
        .captionMode()
        .submitLabel(.done)
        .onSubmit {
            store.send(.submitted)
        }
        .tint(Color.Tag.tint)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 1,
                                           dash: [2]))
                .foregroundStyle(Color.Tag.border)
        )
    }
}

#Preview {
    ScrollView {
        TCATagView(
            store: Store (
                initialState:
                    TagConverter.State(tag: Tag("test")
                                      )
            ) {
                TagConverter()
            }
            )

        TCATagView(
            store: Store (
                initialState:
                    TagConverter.State(tag: Tag(.due,
                                                payload: "2025-06-07")
                                      )
            ) {
                TagConverter()
            }
        )

        TCATagView(
            store: Store (
                initialState:
                    TagConverter.State(tag: Tag(.due,
                                                payload: "2025-06-07 10:00")
                    )
            ) {
                TagConverter()
            }
        )

        TCATagView(
            store: Store (
                initialState:
                    TagConverter.State(tag: Tag(.due,
                                                payload: "2025-06-07 10:00-11:00")
                    )
            ) {
                TagConverter()
            }
        )

        TCATagView(
            store: Store (
                initialState:
                    TagConverter.State(tag: Tag(.due,
                                                payload: "2025-06-07 10:00 thru 2025-06-09 13:00")
                    )
            ) {
                TagConverter()
            }
        )
    }
}
