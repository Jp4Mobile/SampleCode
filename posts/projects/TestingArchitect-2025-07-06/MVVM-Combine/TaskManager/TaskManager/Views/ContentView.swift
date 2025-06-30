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
                TaskMasterAndDetailView(viewModel: .init(initialState: .init()))
                    .tabItem {
                        Label("Tasks",
                              systemImage: "list.bullet.circle")
                    }
                TextView(viewModel: .init(initialState: .init(type: .init(type: .text("")))))
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

