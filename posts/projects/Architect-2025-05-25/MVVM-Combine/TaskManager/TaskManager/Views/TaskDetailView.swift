//
//  TaskDetail.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/28/25.
//

import SwiftUI

struct TaskDetailView: View {
    struct TaskState: Equatable {
        var item: TMType

        init(_ type: TMType) {
            self.item = type
        }
    }

    final class ViewModel: StateBindingViewModel<TaskState> {
    }

    @StateObject
    var viewModel: ViewModel

    var body: some View {
        Text(viewModel.state.item.toString)
    }
}

extension TaskDetailView.ViewModel {
    convenience init(item type: TMType) {
        self.init(initialState: .init(type))
    }
}

extension TaskDetailView {
    init(item type: TMType) {
        let viewModel = ViewModel(initialState: .init(type))

        self.init(viewModel: viewModel)
    }
}

#Preview {
    TaskDetailView(item: TMType.Mock.Projects.projectWithTasks)
}
