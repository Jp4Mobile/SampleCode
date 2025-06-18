//
//  TCATagView.swift
//  TaskManager
//
//  Created by Jp LaFond on 6/6/25.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Reducer
@Reducer
struct TagConverter {
    // MARK: State
    @ObservableState
    struct State: Equatable {
        var editMode: EditMode = .inactive
        var initialTag: Tag
        var tag: Tag {
            didSet {
                text = tag.toString
            }
        }
        var text = ""

        init(tag: Tag) {
            self.initialTag = tag
            self.tag = tag
            self.text = tag.toString
        }
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
    }
}

struct TCATagView: View {
    @Bindable var store: StoreOf<TagConverter>
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

extension TCATagView {
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
                .foregroundColor(Color.Tag.border)
        )
    }

    func onTextFieldSubmission() {
        defer {
            store.editMode = .inactive
        }

        guard let updatedTag = store.text.toTag() else {
            print("*Jp* \(self)::\(#function)[\(#line)] unable to convert")
            store.text = store.tag.toString
            return
        }
        store.tag = updatedTag
    }
}

#Preview {
    ScrollView {
        TCATagView(
            store: Store(
                initialState:
                    TagConverter.State(tag: Tag("test")
                                      )
            ) {
                TagConverter()
            }
        )
        TCATagView(
            store: Store(
                initialState:
                    TagConverter.State(tag: Tag(.due, payload: "2025-06-07")
                                      )
            ) {
                TagConverter()
            }
        )
        TCATagView(
            store: Store(
                initialState:
                    TagConverter.State(tag: Tag(.due, payload: "2025-06-07 10:00")
                                      )
            ) {
                TagConverter()
            }
        )
        TCATagView(
            store: Store(
                initialState:
                    TagConverter.State(tag: Tag(.due, payload: "2025-06-07 10:00-11:00")
                                      )
            ) {
                TagConverter()
            }
        )
        TCATagView(
            store: Store(
                initialState:
                    TagConverter.State(tag: Tag(.due, payload: "2025-06-07 10:00 thru 2025-06-09 13:00")
                                      )
            ) {
                TagConverter()
            }
        )
    }
}
