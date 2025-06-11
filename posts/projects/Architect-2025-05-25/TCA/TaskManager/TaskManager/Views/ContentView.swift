//
//  ContentView.swift
//  TaskManager
//
//  Created by Jp LaFond on 10/13/24.
//

import SwiftUI
import EventKit

struct ContentView: View {
    var body: some View {
        VStack {
            Text("TCA Version")
                .font(.largeTitle)
                .underline()
            Spacer()
            TabView {
                Text("Tasks")                    .tabItem {
                        Label("Tasks",
                              systemImage: "list.bullet.circle")
                    }
                Text("Edit")                    .tabItem {
                        Label("Edit",
                              systemImage: "list.bullet.circle.fill")
                    }
                Text("Settings")                    .tabItem {
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

