//
//  AddTCATaskFeature.swift
//  TaskManager
//
//  Created by Jp LaFond on 6/9/25.
//

import Foundation
import ComposableArchitecture
import SwiftUI

// MARK: - Reducer
@Reducer
struct AddEditTCATaskFeature {
    enum Mode: Equatable {
        case add
        case edit

        var title: String {
            switch self {
            case .add:
                return Constants.AddEditTask.addTitle
            case .edit:
                return Constants.AddEditTask.editTitle
            }
        }
    }
    // MARK: State
    @ObservableState
    struct State: Equatable {
        let mode: Mode
        var task: TCATask
    }
    // MARK: Action
    enum Action {
        case cancelButtonTapped
        case delegate(Delegate)
        case saveButtonTapped
        case deleteButtonTapped
        case setText(String)

        @CasePathable
        enum Delegate: Equatable {
            case deleteTask(TCATask)
            case saveTask(TCATask)
        }
    }
    // MARK: Body
    @Dependency(\.dismiss) var dismiss
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .run { _ in await self.dismiss() }
            case .delegate:
                return .none
            case .deleteButtonTapped:
                return .run { [task = state.task] send in

                    await send(.delegate(.deleteTask(task)))
                    await self.dismiss()
                }
            case .saveButtonTapped:
                return .run { [task = state.task] send in

                    await send(.delegate(.saveTask(task)))
                    await self.dismiss()
                }
            case let .setText(text):
                state.task.text = text
                return .none
            }
        }
    }
}

// MARK: - View
struct AddTCATaskFeatureView: View {
    @Bindable var store: StoreOf<AddEditTCATaskFeature>

    var body: some View {
        Form {
            TextField(Constants.AddEditTask.placeholder,
                      text: $store.task.text.sending(\.setText))

            HStack {
                if case .edit = store.mode {
                    Button(Constants.AddEditTask.deleteTitle) {
                        store.send(.deleteButtonTapped)
                    }
                    .tint(.red.opacity(0.8))
                    Spacer()
                }

                Button(Constants.AddEditTask.saveTitle) {
                    store.send(.saveButtonTapped)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle(store.mode.title)
        .toolbar {
            ToolbarItem {
                Button(Constants.AddEditTask.cancelTitle) {
                    store.send(.cancelButtonTapped)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddTCATaskFeatureView(
            store: Store(
                initialState: AddEditTCATaskFeature.State(
                    mode: .add,
                    task: TCATask(id: UUID(),
                                  text: "")
                )
            ) {
                AddEditTCATaskFeature()
            }
        )
    }

    NavigationStack {
        AddTCATaskFeatureView(
            store: Store(
                initialState: AddEditTCATaskFeature.State(
                    mode: .edit,
                    task: TCATask(id: UUID(),
                                  text: "Project:")
                )
            ) {
                AddEditTCATaskFeature()
            }
        )
    }

}
