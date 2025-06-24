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
    static let store = Store(initialState: TCAAppFeature.State()) {
        TCAAppFeature()
    }
    var body: some Scene {
        WindowGroup {
            TCAAppView(store: TaskManagerApp.store)
        }
    }
}
