//
//  TCATextFeature.swift
//  TaskManager
//
//  Created by Jp LaFond on 6/24/25.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Reducer
@Reducer
struct TCATextFeature {
    // MARK: State
    @ObservableState
    struct State: Equatable {
        var text: String
        var task: TCATask {
            didSet {
                text = task.task.toString
            }
        }
        var errorMessage: String? {
            didSet {
                guard errorMessage != nil else { return }

                text = task.task.toString
            }
        }
        var hasError: Bool {
            errorMessage != nil
        }

        init(_ task: TCATask) {
            self.task = task
            self.text = task.task.toString
            self.errorMessage = nil
        }

        init(task: TCATask,
             text: String? = nil,
             errorMessage: String? = nil) {
            self.task = task
            self.errorMessage = errorMessage
            self.text = text ?? task.task.toString
        }

        // This is a broken initializer that screws up the tests due to the didSets.
        init(broken task: TCATask,
             text: String? = nil,
             errorMessage: String? = nil) {
            self.task = task
            self.text = text ?? task.task.toString
            self.errorMessage = errorMessage
        }


        func updatedCopy(_ newType: TMType) -> TCATask {
            TCATask(id: self.task.id, task: newType)
        }
    }

    // MARK: Action
    enum Action: Equatable {
        case entered(String)
        case saveButtonTapped
        case error(String)
        case errorAndTask(String, TCATask)
        case saveTask(TCATask)
    }

    // MARK: Body (Reducer)
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .entered(text):
                state.text = text
                return .none
            case .saveButtonTapped:
                let taskList = TMType.parse(string: state.text)
                guard !state.text.isEmpty,
                      !taskList.isEmpty else {
                    let errorMessage = "Unable to parse <\(state.text)>."
                    return .send(.error(errorMessage))
                }
                let normalizedList = TMType.normalize(taskList)
                guard let firstTask = normalizedList.first else {
                    let errorMessage = "Unable to parse <\(state.text)>."
                    return .send(.error(errorMessage))
                }

                let newTask = state.task.updatedCopy(firstTask)
                guard normalizedList.count == 1 else {
                    let errorMessage = "Only the first converted type model is saved. You may need to change indentation to keep them under the proper project."
                    return .send(.errorAndTask(errorMessage, newTask))
                }

                return .send(.saveTask(newTask))

            case let .error(errorMessage):
                state.errorMessage = errorMessage
                return .none

            case let .errorAndTask(errorMessage, updatedTask):
                state.errorMessage = errorMessage
                state.task = updatedTask
                return .none

            case let .saveTask(updatedTask):
                state.task = updatedTask
                state.errorMessage = nil
                return .none
            }
        }
    }
}

// MARK: - View
struct TCATextView: View {
    @Bindable
    var store: StoreOf<TCATextFeature>
    @ScaledMetric(relativeTo: .caption) var scaledPadding = Spacing.default

    var body: some View {
        NavigationStack {
            VStack {
                if let errorMessage = store.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .textScale(.secondary)
                        .foregroundStyle(Color.Alert.alert)
                        .padding(scaledPadding)
                    Spacer(minLength: Spacing.half)
                }
                TextEditor(text: $store.text.sending(\.entered))
                    .font(.body)
                    .monospaced()
                    .textScale(.secondary)
                    .overlay (
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 1,
                                                       dash: [2, 1]))
                            .foregroundStyle(Color.Tag.border)
                    )
                    .padding(scaledPadding)
                    .onSubmit {
                        store.send(.saveButtonTapped)
                    }
            }
            .navigationTitle(Constants.TextView.title)
            .toolbar {
                ToolbarItem {
                    Button {
                        store.send(.saveButtonTapped)
                    } label: {
                        Text(Constants.TextView.saveTitle)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

#Preview {
    TCATextView(
        store: Store (
            initialState:
                TCATextFeature.State(.init(id: UUID(),
                                           task: TMType.Mock.Projects.projectWithTasks))
        ) {
            TCATextFeature()
        }
    )
}
