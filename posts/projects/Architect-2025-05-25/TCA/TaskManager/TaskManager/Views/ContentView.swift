//
//  ContentView.swift
//  TaskManager
//
//  Created by Jp LaFond on 10/13/24.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("TCA Version")
                .font(.largeTitle)
                .underline()
            Spacer()
            TCAAppView(store:
                        Store(
                            initialState: TCAAppFeature.State()
                        ) {
                            TCAAppFeature()
                        }
            )
        }
    }

}

#Preview {
    ContentView()
}

