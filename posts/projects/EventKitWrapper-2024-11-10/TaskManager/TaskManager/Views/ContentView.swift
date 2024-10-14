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
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            Task {
                do {
                    let ekMgr = EKManager.shared
                    let reminder = EventParameters(title: "Test Reminder",
                                                   startDate: Date(format: .date, "2024-10-31")!,
                                                   notes: "@TM @Test  @Reminder",
                                                   dateFormat: .date)
                    let event = EventParameters(title: "Test Event",
                                                startDate: Date(format: .dateTime, "2024-10-31 12:30")!,
                                                endDate: Date(format: .dateTime, "2024-10-31 15:30"),
                                                notes: "@TM @Test @Event")
                    let otherEvent = EventParameters(title: "Test Other Event",
                                                     startDate: Date(format: .dateTime,  "2024-10-31 11:30")!,
                                                     endDate: Date(format: .dateTime, "2024-11-05 14:30"),
                                                                   notes: "@TM @Test @MultiEvent")
                    try await ekMgr.create(.reminder, model: reminder)
                    try await ekMgr.create(.event, model: event)
                    try await ekMgr.create(.event, model: otherEvent)
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
