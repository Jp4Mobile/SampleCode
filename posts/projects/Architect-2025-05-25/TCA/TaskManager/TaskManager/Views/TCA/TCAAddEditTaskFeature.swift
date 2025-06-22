//
//  TCAAddEditTaskFeature.swift
//  TaskManager
//
//  Created by Jp LaFond on 6/23/25.
//

import Foundation
import ComposableArchitecture
import SwiftUI

// MARK: - Reducer
@Reducer
struct TCAAddEditTaskFeature {
    enum Mode: Equatable {
        case add
        case edit

        var title: String {
            switch self {
            case .add:
                return Constants.DetailView.addTitle
            case .edit:
                return Constants.DetailView.editTitle
            }
        }
    }
    // MARK: State
    @ObservableState
    struct State: Equatable {
        let mode: Mode
        var task: TCATask {
            didSet {
                text = task.task.toString
            }
        }
        var errorMessage: String? {
            didSet {
                guard errorMessage != nil else {
                    return
                }
                text = task.task.toString
            }
        }
        var text: String

        var hasError: Bool {
            errorMessage != nil
        }

        var isEditing: Bool {
            mode == .edit
        }

        init(mode: Mode = .add,
             task: TCATask) {
            self.mode = mode
            self.task = task
            self.text = task.task.toString
            self.errorMessage = nil
        }
    }
    // MARK: Action
    enum Action {
        case cancelButtonTapped
        case delegate(Delegate)
        case saveButtonTapped
        case deleteButtonTapped
        case setText(String)
        case presentError(String)

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
                guard let newTask = state.text.toTMType() else {
                    let errorMessage = "Unable to convert <\(state.text)> into a task."
                    return .send(.presentError(errorMessage))
                }

                return .run { [task = state.task] send in

                    let updatedTask = task.updatedCopy(newTask)

                    await send(.delegate(.saveTask(updatedTask)))
                    await self.dismiss()
                }
            case let .presentError(errorMessage):
                state.errorMessage = errorMessage
                return .none
            case let .setText(text):
                state.text = text
                return .none
            }
        }
    }
}

// MARK: - View
struct TCAAddEditTaskView: View {
    @Bindable var store: StoreOf<TCAAddEditTaskFeature>

    var body: some View {
        Form {
            TextField(Constants.DetailView.placeholder,
                      text: $store.text.sending(\.setText),
                      axis: .vertical)
            .bodyMode(borderColor: store.hasError ? Color.Alert.alert : Color.Tag.border)
            .onSubmit {
                store.send(.saveButtonTapped)
            }
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .font(.callout.bold())
                    .foregroundStyle(Color.Alert.alert)
            }

            HStack {
                if store.isEditing {
                    Button(Constants.DetailView.deleteTitle) {
                        store.send(.deleteButtonTapped)
                    }
                    .tint(.Alert.alert)
                    Spacer()
                }

                Button(Constants.DetailView.saveTitle) {
                    store.send(.saveButtonTapped)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle(store.mode.title)
        .toolbar {
            ToolbarItem {
                Button(Constants.DetailView.cancelTitle) {
                    store.send(.cancelButtonTapped)
                }
            }
        }
    }
}

#Preview("Add Mode") {
    NavigationStack {
        TCAAddEditTaskView(
            store: Store(
                initialState: TCAAddEditTaskFeature.State(
                    mode: .add,
                    task: TCATask(id: UUID(),
                                  task: .init(type: .text("")))
                )
            ) {
                TCAAddEditTaskFeature()
            }
        )
    }
}

#Preview("Add Mode (with Error)") {
    var state = TCAAddEditTaskFeature.State(mode: .add,
                                            task: .init(id: UUID(),
                                                        task: TMType.Mock.TopLevel.project))
    state.errorMessage = "Error Present"

    return NavigationStack {
        TCAAddEditTaskView(
            store: Store(
                initialState: state
            ) {
                TCAAddEditTaskFeature()
            }
        )
    }
}

#Preview("Edit Mode") {
    NavigationStack {
        TCAAddEditTaskView(
            store: Store(
                initialState: TCAAddEditTaskFeature.State(
                    mode: .edit,
                    task: TCATask(id: UUID(),
                                  task: TMType.Mock.TopLevel.project)
                )
            ) {
                TCAAddEditTaskFeature()
            }
        )
    }

}

#Preview("Edit Mode (with error)") {
    var state = TCAAddEditTaskFeature.State(mode: .edit,
                                            task: .init(id: UUID(),
                                                        task: TMType.Mock.TopLevel.project))
    state.errorMessage = "Error Present"

    return NavigationStack {
        TCAAddEditTaskView(
            store: Store(
                initialState: state
            ) {
                TCAAddEditTaskFeature()
            }
        )
    }

}
