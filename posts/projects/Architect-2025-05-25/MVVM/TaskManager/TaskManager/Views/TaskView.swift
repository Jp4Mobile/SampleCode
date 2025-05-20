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
                     Ideally, this should go through the view model, but the solutions that I've seen such as view model toggling a boolean state that turns on/off the navigation links all feel a bit hacky.
                     */
                    NavigationLink {
                        Text(item.toString)
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
