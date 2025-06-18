//
//  TaskView.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/19/25.
//

import SwiftUI

struct TaskView: View {
    @Observable
    class ViewModel {
        private(set) var items: [TMType]
        private var collapsed: [TMType: Bool] = [:]

        init(items: [TMType]) {
            self.items = items
        }

        // MARK: - Supported Functionality
        func move(from source: IndexSet, to destination: Int) {
            items.move(fromOffsets: source, toOffset: destination)
        }
    }

    @State var viewModel: ViewModel
    var body: some View {
        NavigationStack {
            List {
                ForEach (viewModel.items) { item in
                    /*
                     I like solution: generate a subsequent ViewModel from the current ViewModel and then inject that into the new view. I feel that this better fits the MVVM paradigm. An example of this would be a list of movies that can subsequently present a movie detail page upon movie card click.
                     */
                    NavigationLink {
                        let viewModel: TaskDetailView.ViewModel = .init(item: item)
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

#Preview {
    TaskView(viewModel: TaskView.ViewModel(items: [
        TMType.Mock.TopLevel.project,
        TMType.Mock.TopLevel.task,
        TMType.Mock.TopLevel.text,
        TMType.Mock.Projects.projectWithTasks
    ]))
}
