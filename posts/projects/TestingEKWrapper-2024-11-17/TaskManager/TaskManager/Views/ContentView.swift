//
//  ContentView.swift
//  TaskManager
//
//  Created by Jp LaFond on 10/13/24.
//

import SwiftUI
import EventKit

struct TestData {
    let reminder: EventParameters
    let event: EventParameters
    let otherEvent: EventParameters

    init(from date: Date = Date()) {
        let startDate = date
        let endDatePlusHour = Calendar.current.date(byAdding: .hour, value: 1, to: startDate) ?? startDate
        let endDatePlusWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate) ?? startDate

        self.reminder = EventParameters(title: "Test Reminder",
                                        startDate: startDate,
                                        notes: "@TM @Test @Reminder",
                                        dateFormat: .date)
        self.event = EventParameters(title: "Test Event",
                                     startDate: startDate,
                                     endDate: endDatePlusHour,
                                     notes: "@TM @Test @Event")

        self.otherEvent = EventParameters(title: "Other Test Event",
                                          startDate: startDate,
                                          endDate: endDatePlusWeek,
                                          notes: "@TM @Test @MultiEvent")
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Create Events Directly") {
                Task {
                    try? await createEventsDirectly()
                }
            }
            Spacer()
            Button("Create Events Thru API") {
                Task {
                    try? await createEventsThruAPI()
                }
            }
            Spacer()
            Button("Get Everything Matching") {
                Task {
                    try? await getEverythingMatching(notesSearch)
                }
            }
        }
        .padding()
    }

    let reminderSearch: TMSearchType = .bySearchValues(.init(title: "Test Reminder"))
    let eventSearch: TMSearchType = .bySearchValues(.init(title: "Test Event"))
    let otherEventSearch: TMSearchType = .bySearchValues(.init(title: "Test Other Event"))
    let notesSearch: TMSearchType = .bySearchValues(.init(notes: "@TM"))

    let testData = TestData()

    func createEventsDirectly() async throws {
        let ekMgr = EKManager.shared
        try await ekMgr.create(.reminder, model: testData.reminder)
        try await ekMgr.create(.event, model: testData.event)
        try await ekMgr.create(.event, model: testData.otherEvent)
    }

    func createEventsThruAPI() async throws {
        let ekMgr = EKManager.shared

        try await ekMgr.create(entity: .reminder, model: testData.reminder, shouldCommit: true)
        try await ekMgr.create(entity: .event, model: testData.event, shouldCommit: true)
        try await ekMgr.create(entity: .event, model: testData.otherEvent, shouldCommit: true)
        let reminderResult = try await ekMgr.search(entity: .reminder, by: reminderSearch)
        let eventResult = try await ekMgr.search(entity: .event, by: eventSearch)
        let otherEventResult = try await ekMgr.search(entity: .event, by: otherEventSearch)
        print("*Jp* \(self)::\(#function)[\(#line)] rem <\(reminderResult.map { ( $0.id, $0.model.title ) })>")
        print("*Jp* \(self)::\(#function)[\(#line)] evnt <\(eventResult.map { ( $0.id, $0.model.title ) })>")
        print("*Jp* \(self)::\(#function)[\(#line)] oEvnt <\(otherEventResult.map { ( $0.id, $0.model.title ) })>")
        try await ekMgr.delete(entity: .reminder, by: notesSearch)
        try await ekMgr.delete(entity: .event, by: notesSearch)
    }

    func getEverythingMatching(_ search: TMSearchType) async throws {
        let reminder: EventResult
        var results = try await EKManager.shared.search(entity: .event, by: search)
        guard let event = results.first else { return }
        results += try await EKManager.shared.search(entity: .reminder, by: search)
        reminder = results.last!

        print("*Jp* \(self)::\(#function)[\(#line)] <\(results.map { ($0.id, $0.model.title) } )>")

        print("*Jp* \(self)::\(#function)[\(#line)] event <\(event.id)> reminder <\(reminder.id)>")

        var retrieved: [EKCalendarItem] = []
        let retrievedEvent = try await EKManager.shared.getEvent(id: event.id)
        retrieved.append(retrievedEvent)

        let retrievedReminder = try await EKManager.shared.getReminder(id: reminder.id)
        retrieved.append(retrievedReminder)

        print("*Jp* \(self)::\(#function)[\(#line)] <\(retrieved.map { ( $0.calendarItemIdentifier, $0.title ) } )>")

        retrievedEvent.title = retrievedEvent.title + " (updated)"
        retrievedReminder.title = retrievedReminder.title + " (updated)"

        try await EKManager.shared.update(retrievedEvent)
        try await EKManager.shared.update(retrievedReminder)
    }
}

#Preview {
    ContentView()
}

