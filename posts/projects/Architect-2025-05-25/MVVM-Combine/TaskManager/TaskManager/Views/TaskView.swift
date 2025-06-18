//
//  TaskView.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/19/25.
//

import SwiftUI

struct TaskView: View {
    struct TaskState: Equatable {
        var items: [TMType] = []
    }

    final class ViewModel: StateBindingViewModel<TaskState> {

        // MARK: - Supported Functionality
        func move(from source: IndexSet, to destination: Int) {
            var updatedItems = state.items
            updatedItems.move(fromOffsets: source, toOffset: destination)

            update(\.items, to: updatedItems)
        }
    }

    @StateObject
    var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach (viewModel.state.items) { item in
                    /*
                     I like solution: generate a subsequent ViewModel from the current ViewModel and then inject that into the new view. I feel that this better fits the MVVM paradigm. An example of this would be a list of movies that can subsequently present a movie detail page upon movie card click.
                     */
                    NavigationLink {
                        // This initializer creates a ViewModel
                        // This initializer creates a ViewModel
//                        return TaskDetailView(item: item)
                        // This creates the view model first
                        let viewModel = TaskDetailView.ViewModel(item: item)
                        return TaskDetailView(viewModel: viewModel)
                    } label: {
                        Text(item.type.toString)
                    }
                }
                .onMove(perform: rearrange)
            }
        }
    }

    func rearrange(from source: IndexSet, to destination: Int) {
        viewModel.move(from: source, to: destination)
    }
}

extension TaskView.ViewModel {
    convenience init(items: [TMType]) {
        self.init(initialState: .init(items: items))
    }
}

#Preview {
    TaskView(viewModel: .init(items: [
        TMType.Mock.TopLevel.project,
        TMType.Mock.TopLevel.task,
        TMType.Mock.TopLevel.text,
        TMType.Mock.Projects.projectWithTasks
    ]))
}
