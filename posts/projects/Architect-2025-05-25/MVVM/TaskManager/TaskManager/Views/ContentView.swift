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
            Text("MVVM Version")
                .font(.largeTitle)
                .underline()
            Spacer()
            TabView {
                TaskMasterAndDetailView(viewModel: .init())
                    .tabItem {
                        Label("Tasks",
                              systemImage: "list.bullet.circle")
                    }
                TextView(viewModel: TextView.ViewModel(from: TMType(type: .text(""))))
                    .tabItem {
                        Label("Edit",
                              systemImage: "pencil.circle.fill")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings",
                              systemImage: "gearshape.circle.fill")
                    }
            }
        }
    }

}

#Preview {
    ContentView()
}

