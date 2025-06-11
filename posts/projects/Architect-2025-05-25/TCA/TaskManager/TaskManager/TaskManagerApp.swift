//
//  TaskManagerApp.swift
//  TaskManager
//
//  Created by Jp LaFond on 10/13/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct TaskManagerApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: Self.store)
        }
    }
}
