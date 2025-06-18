//
//  ContentView.swift
//  TaskManager
//
//  Created by Jp LaFond on 10/13/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("MVVM (Combine) Version")
                .font(.largeTitle)
                .underline()
            Spacer()
            TabView {
                TaskView(viewModel: TaskView.ViewModel(items: [TMType.Mock.TopLevel.project, TMType.Mock.TopLevel.task, TMType.Mock.TopLevel.text]))
                    .tabItem {
                        Label("Tasks",
                              systemImage: "list.bullet.circle")
                    }
                TextView(viewModel: TextView.ViewModel(from: TMType.Mock.Projects.projectWithTasks))
                    .tabItem {
                        Label("Edit",
                              systemImage: "pencil.circle.fill")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings",
                              systemImage: "gearshape.circle.fill")
                    }
                ScrollView {
                    TagView(viewModel: .init(Constants.MockTag.test))
                    TagView(viewModel: .init(Constants.MockTag.dueDate))
                    TagView(viewModel: .init(Constants.MockTag.dueDateTime))
                    TagView(viewModel: .init(Constants.MockTag.dueDateTimeRange))
                    TagView(viewModel: .init(Constants.MockTag.dueDayRange))
                }
                .tabItem {
                    Label("TagView",
                          systemImage: "questionmark.circle.fill")
                }
            }
        }
    }

}

#Preview {
    ContentView()
}

