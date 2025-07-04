//
//  TCATagFeature (First Pass).swift
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
struct TagConverterFirstPass {
    // MARK: State
    @ObservableState
    struct State: Equatable {
        var errorMessage: String? {
            didSet {
                guard errorMessage != nil else { return }
                text = tag.toString
                editMode = .inactive
            }
        }
        var shouldPresentError: Bool {
            errorMessage != nil
        }
        var editMode: EditMode = .inactive
        var isEditing: Bool {
            editMode == .active
        }
        var tag: Tag {
            didSet {
                text = tag.toString
                editMode = .inactive
            }
        }
        var text: String

        init(tag: Tag) {
            self.tag = tag
            self.text = tag.toString
        }
    }

    // MARK: Action
    enum Action {
        case tapped
        case entered(String)
        case submitted(String)
        case saved(Tag)
        case error(String)
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

            case let .submitted(text):
                guard let newTag = text.toTag() else {
                    let errorMessage = "Unable to convert <\(text)> into a tag."
                    return .send(.error(errorMessage))
                }

                return .send(.saved(newTag))

            case let .error(errorMessage):
                state.errorMessage = errorMessage
                return .none

            case let .saved(newTag):
                state.tag = newTag
                state.errorMessage = nil
                return .none
            }
        }
    }
}

// MARK: - View
struct TCATagViewFirstPass: View {
    @Bindable
    var store: StoreOf<TagConverterFirstPass>
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
extension TCATagViewFirstPass {
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
        .onSubmit {
            store.send(.submitted(store.text))
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
        TCATagViewFirstPass(
            store: Store (
                initialState:
                    TagConverterFirstPass.State(tag: Tag("test")
                                      )
            ) {
                TagConverterFirstPass()
            }
            )

        TCATagViewFirstPass(
            store: Store (
                initialState:
                    TagConverterFirstPass.State(tag: Tag(.due,
                                                payload: "2025-06-07")
                                      )
            ) {
                TagConverterFirstPass()
            }
        )

        TCATagViewFirstPass(
            store: Store (
                initialState:
                    TagConverterFirstPass.State(tag: Tag(.due,
                                                payload: "2025-06-07 10:00")
                    )
            ) {
                TagConverterFirstPass()
            }
        )

        TCATagViewFirstPass(
            store: Store (
                initialState:
                    TagConverterFirstPass.State(tag: Tag(.due,
                                                payload: "2025-06-07 10:00-11:00")
                    )
            ) {
                TagConverterFirstPass()
            }
        )

        TCATagViewFirstPass(
            store: Store (
                initialState:
                    TagConverterFirstPass.State(tag: Tag(.due,
                                                payload: "2025-06-07 10:00 thru 2025-06-09 13:00")
                    )
            ) {
                TagConverterFirstPass()
            }
        )
    }
}
