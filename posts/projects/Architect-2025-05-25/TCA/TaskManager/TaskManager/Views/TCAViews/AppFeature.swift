//
//  AppFeature.swift
//  TaskManager
//
//  Created by Jp LaFond on 6/9/25.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Reducer
@Reducer
struct AppFeature {
    // MARK: State
    struct State: Equatable {
        var taskFeatureStore = TCATaskFeature.State()
    }

    // MARK: Action
    enum Action {
        case task(TCATaskFeature.Action)
    }

    // MARK: Body
    var body: some ReducerOf<Self> {
        Scope(state: \.taskFeatureStore,
              action: \.task) {
            TCATaskFeature()
        }

        Reduce { state, action in
            // Core Logic of the app feature

            return .none
        }
    }
}

// MARK: - View
struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        TabView {
            TCATaskFeatureView(store: store.scope(state: \.taskFeatureStore,
                                                  action: \.task))
            .tabItem {
                Label("Tasks",
                      systemImage: "list.bullet.circle")
            }

            Text("Text Goes Here")
                .tabItem {
                    Label("Edit",
                          systemImage: "pencil.circle.fill")
                }

            Text("Settings Go Here")
                .tabItem {
                    Label("Settings",
                          systemImage: "gearshape.circle.fill")
                }
        }
    }
}

#Preview {
    AppView(store: Store(
        initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
