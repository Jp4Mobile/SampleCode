//
//  TCATaskFeature.swift
//  TaskManager
//
//  Created by Jp LaFond on 6/23/25.
//

import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - Model
struct TCATask: Equatable, Identifiable {
    let id: UUID
    var task: TMType

    func updatedCopy(_ newTask: TMType) -> TCATask {
        TCATask(id: self.id,
                task: newTask)
    }
}

// MARK: - Reducer
@Reducer
struct TCATaskFeature {
    // MARK: State
    @ObservableState
    struct State: Equatable {
        var tasks: IdentifiedArrayOf<TCATask> = []

        @Presents var alert: AlertState<Action.Alert>?
        @Presents var destination: Destination.State?
    }
    // MARK: Action
    enum Action {
        case addButtonTapped
        case alert(PresentationAction<Alert>)
        case deleteSent(TCATask)
        case destination(PresentationAction<Destination.Action>)
        case editTask(TCATask)

        @CasePathable
        enum Alert: Equatable {
            case confirmDeletion(id: TCATask.ID)
        }
    }
    // MARK: Body
    @Dependency(\.uuid) var uuid
    var body: some ReducerOf<Self> {
        Reduce { state, action in

            switch action {
            case .addButtonTapped:
                state.destination = .addTask(
                    TCAAddEditTaskFeature.State(
                        mode: .add,
                        task: TCATask(id: self.uuid(),
                                      task: .init(type: .text("")))
                    )
                )

                return .none

            case let .alert(.presented(.confirmDeletion(id: id))):
                state.tasks.remove(id: id)
                return .none

            case .alert:
                return .none

            case let .deleteSent(task):
                state.alert = AlertState {
                    TextState(Constants.Alert.message)
                } actions: {
                    ButtonState(role: .destructive,
                                action: .confirmDeletion(id: task.id)) {
                        TextState(Constants.Alert.deleteTitle)
                    }
                }
                return .none

            case let .destination(.presented(.addTask(.delegate(.saveTask(task))))):
                state.tasks.append(task)

                return .none

            case let .destination(.presented(.editTask(.delegate(.saveTask(task))))):

                guard let index = state.tasks.firstIndex(where: { $0.id == task.id }) else {
                    return .none
                }

                state.tasks[index] = task

                return .none

            case let .destination(.presented(.editTask(.delegate(.deleteTask(task))))):

                return .send(.deleteSent(task))

            case .destination:
                return .none

            case let .editTask(task):

                state.destination = .editTask(
                    TCAAddEditTaskFeature.State(
                        mode: .edit,
                        task: task
                    )
                )

                return .none
            }

        }
        .ifLet(\.$destination,
                action: \.destination) {
            Destination.body
        }
                .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Destination
extension TCATaskFeature {
    // MARK: Reducer
    @Reducer
    enum Destination {
        case addTask(TCAAddEditTaskFeature)
        case editTask(TCAAddEditTaskFeature)
    }
}
// MARK: State
extension TCATaskFeature.Destination.State: Equatable {}

// MARK: - View
struct TCATaskFeatureView: View {
    @Bindable var store: StoreOf<TCATaskFeature>

    var body: some View {
        NavigationStack {
            List {
                ForEach (store.tasks) { task in

                    HStack {
                        Text(task.task.type.toString)
                            .bodyMode()
                        Spacer()
                        Button {
                            store.send(.editTask(task))
                        } label: {
                            Image.Task.Icon.edit
                                .tint(Color.green.opacity(0.8))
                        }
                        .buttonStyle(.borderless)
                    }

                }
            }
            .navigationTitle(Constants.TaskView.title)
            .toolbar {
                ToolbarItem {
                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(
            item: $store.scope(state: \.destination?.addTask,
                               action: \.destination.addTask)
        ) { addTaskStore in

            NavigationStack {
                TCAAddEditTaskView(store: addTaskStore)
            }
        }
        .sheet(
            item: $store.scope(state: \.destination?.editTask,
                               action: \.destination.editTask)
        ) { editTaskStore in

            NavigationStack {
                TCAAddEditTaskView(store: editTaskStore)
            }

        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    TCATaskFeatureView(
        store: Store(
            initialState: TCATaskFeature.State(
                tasks: [
                    TCATask(id: UUID(),
                            task: TMType.Mock.TopLevel.project),
                    TCATask(id: UUID(),
                            task: TMType.Mock.TopLevel.task),
                    TCATask(id: UUID(),
                            task: TMType.Mock.TopLevel.text)
                ]
            )
        ) {
            TCATaskFeature()
        }
    )
}
