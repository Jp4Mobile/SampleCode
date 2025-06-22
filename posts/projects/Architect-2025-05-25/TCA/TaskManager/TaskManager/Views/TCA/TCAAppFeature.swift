//
//  TCAAppFeature.swift
//  TaskManager
//
//  Created by Jp LaFond on 6/24/25.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Reducer
@Reducer
struct TCAAppFeature {
    // MARK: State
    struct State: Equatable {
        var taskState = TCATaskFeature.State()
        var textState = TCATextFeature.State(.init(id: UUID(),
                                                   task: .init(type: .text(""))))
    }

    // MARK: Action
    enum Action {
        case taskAction(TCATaskFeature.Action)
        case textAction(TCATextFeature.Action)
    }

    // MARK: Body
    var body: some ReducerOf<Self> {
        Scope(state: \.taskState,
              action: \.taskAction) {
            TCATaskFeature()
        }

        Scope(state: \.textState,
              action: \.textAction) {
            TCATextFeature()
        }

        Reduce { state, action in
            // Core logic of the app feature
                .none
        }
    }
}

// MARK: - View
struct TCAAppView: View {
    let store: StoreOf<TCAAppFeature>

    var body: some View {
        TabView {
            TCATaskFeatureView(
                store: store.scope(state: \.taskState,
                                   action: \.taskAction)
            )
            .tabItem {
                Label("Tasks",
                systemImage: "list.bullet.circle")
            }
            TCATextView(
                store: store.scope(state: \.textState,
                                   action: \.textAction)
            )
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

#Preview {
    TCAAppView(store: Store(
        initialState: TCAAppFeature.State()) {
        TCAAppFeature()
    }
    )
}
