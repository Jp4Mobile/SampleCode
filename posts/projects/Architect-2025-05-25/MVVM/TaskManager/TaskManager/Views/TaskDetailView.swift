//
//  TaskDetail.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/28/25.
//

import SwiftUI

struct TaskDetailView: View {
    @Observable
    class ViewModel {
        private(set) var item: TMType

        init(item: TMType) {
            self.item = item
        }
    }

    @State var viewModel: ViewModel

    var body: some View {
        Text(viewModel.item.toString)
    }
}

#Preview {
    TaskDetailView(viewModel: TaskDetailView.ViewModel(item: TMType.Mock.Projects.projectWithTasks))
}
