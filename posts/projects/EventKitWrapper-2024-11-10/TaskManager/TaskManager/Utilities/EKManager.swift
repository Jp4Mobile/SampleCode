//
//  EKManager.swift
//  TaskManager
//
//  Created by Jp LaFond on 10/13/24.
//

import EventKit
import Foundation

class EKManager {
    // MARK: - Errors
    enum EKManagerError: Error {
        case calendarAccessDenied
        case reminderAccessDenied
        case unknownEntity
        case noDefaultCalendarForEvents
        case noDefaultCalendarForReminders
        case noSourceFound
        case calendarNotFound(String)
        case eventNotFound(String)
        case reminderNotFound(String)
    }

    // MARK: - Properties
    let eventStore = EKEventStore()
    private(set) var hasCalendarAccess: Bool = false
    private(set) var hasReminderAccess: Bool = false

    static let shared = EKManager()

    // MARK: - Lifecycle Methods
    private init() {}

    // MARK: - Properties
    // MARK: Access Wrappers
    func requestCalendarAccess() async throws {
        do {
            let access = try await eventStore.requestFullAccessToEvents()
            hasCalendarAccess = access
        } catch {
            hasCalendarAccess = false
            throw error
        }
    }

    func requestReminderAccess() async throws {
        do {
            let access = try await eventStore.requestFullAccessToReminders()
            hasReminderAccess = access
        } catch {
            hasReminderAccess = false
            throw error
        }
    }

    func verifyAccess(for entityType: EKEntityType) async throws {
        switch entityType {
        case .event:
            if !hasCalendarAccess {
                try await requestCalendarAccess()
            }
            guard hasCalendarAccess else {
                throw EKManagerError.calendarAccessDenied
            }
        case .reminder:
            if !hasReminderAccess {
                try await requestReminderAccess()
            }
            guard hasReminderAccess else {
                throw EKManagerError.reminderAccessDenied
            }
        default:
            throw EKManagerError.unknownEntity
        }
    }

    // MARK: Source Wrappers
    func getEventSource(for entityType: EKEntityType) async throws -> EKSource {
        let `default` = try await getDefaultCalendar(for: entityType).source
        let isICloudPresent: (EKSource) -> Bool = {
            $0.title.lowercased().contains("icloud")
        }
        let iCloud = eventStore.sources.first(where: isICloudPresent)
        let local = eventStore.sources.first(where: { $0.sourceType == .local })

        guard let source = `default` ?? iCloud ?? local else {
            throw EKManagerError.noSourceFound
        }

        return source
    }

    // MARK: Calendar Wrappers
    func getDefaultCalendar(for entityType: EKEntityType) async throws -> EKCalendar {
        switch entityType {
        case .event:
            return try await retrieveDefaultEventCalendar()
        case .reminder:
            return try await retrieveDefaultReminderCalendar()
        default:
            throw EKManagerError.unknownEntity
        }
    }

    private func retrieveDefaultEventCalendar() async throws -> EKCalendar {
        try await verifyAccess(for: .event)

        guard let calendar = eventStore.defaultCalendarForNewEvents else {
            throw EKManagerError.noDefaultCalendarForEvents
        }

        return calendar
    }

    private func retrieveDefaultReminderCalendar() async throws -> EKCalendar {
        try await verifyAccess(for: .reminder)

        guard let calendar = eventStore.defaultCalendarForNewReminders() else {
            throw EKManagerError.noDefaultCalendarForReminders
        }

        return calendar
    }

    func getCalendars(for entityType: EKEntityType) async throws -> [EKCalendar] {
        switch entityType {
        case .event:
            return try await retrieveEventCalendars()
        case .reminder:
            return try await retreiveReminderCalendars()
        default:
            throw EKManagerError.unknownEntity
        }
    }

    private func retrieveEventCalendars() async throws -> [EKCalendar] {
        try await verifyAccess(for: .event)

        return eventStore.calendars(for: .event)
    }

    private func retreiveReminderCalendars() async throws -> [EKCalendar] {
        try await verifyAccess(for: .reminder)

        return eventStore.calendars(for: .reminder)
    }

    func getCalendar(for entityType: EKEntityType, with title: String) async throws -> EKCalendar {
        let calendar = try await getCalendars(for: entityType)
            .filter { $0.title == title }
            .first

        guard let calendar else {
            throw EKManagerError.calendarNotFound(title)
        }

        return calendar
    }

    func getCalendarToUse(for entityType: EKEntityType) async throws -> EKCalendar {
        guard let calendar = try? await getCalendar(for: entityType,
                                                    with: Constants.EKManager.defaultCalendarName) else {
            // Try to create one
            return try await retrieveOrCreateCalendar(for: entityType)
        }

        return calendar
    }

    private func retrieveOrCreateCalendar(for entityType: EKEntityType, with name: String = Constants.EKManager.defaultCalendarName) async throws -> EKCalendar {
        guard let calendar = try? await getCalendar(for: entityType, with: name) else {
            return try await createCalendar(for: entityType,
                                            with: name)
        }

        return calendar
    }

    private func createCalendar(for entityType: EKEntityType, with name: String) async throws -> EKCalendar {
        try await verifyAccess(for: entityType)

        let calendar = EKCalendar(for: entityType,
                                  eventStore: eventStore)
        calendar.title = name
        calendar.source = try await getEventSource(for: entityType)

        try eventStore.saveCalendar(calendar, commit: true)

        return calendar
    }

    func removeCalendar(for entityType: EKEntityType, with name: String) async throws {
        let calendar = try await getCalendar(for: entityType, with: name)
        try eventStore.removeCalendar(calendar, commit: true)
    }

    // MARK: - Retrieves
    func getEvents(from startDate: Date = Date()) async throws -> [EKEvent] {
        let calendar = try await getCalendarToUse(for: .event)

        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        let predicate = eventStore.predicateForEvents(withStart: startDate,
                                                      end: endDate,
                                                      calendars: [calendar])
        
        let allEvents = eventStore.events(matching: predicate)

        return allEvents
    }

    func getEvent(id: String) async throws -> EKEvent {
        try await verifyAccess(for: .event)

        guard let event = eventStore.event(withIdentifier: id) else {
            throw EKManagerError.eventNotFound(id)
        }

        return event
    }

    func getReminders() async throws -> [EKReminder] {
        let calendar = try await getCalendarToUse(for: .reminder)

        let predicate = eventStore.predicateForReminders(in: [calendar])

        return await withCheckedContinuation { continuation in

            eventStore.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
            }
        }
    }

    func getReminder(id: String) async throws -> EKReminder {
        try await verifyAccess(for: .reminder)

        guard let calendarItem = eventStore.calendarItem(withIdentifier: id),
              let reminder = calendarItem as? EKReminder else {
            throw EKManagerError.reminderNotFound(id)
        }

        return reminder
    }

    // MARK: - Removers
    func remove(event: EKEvent, shouldBatch: Bool = false) async throws {
        try await verifyAccess(for: .event)

        // If we should batch, we shouldn't commit.
        try eventStore.remove(event, span:.thisEvent,  commit: !shouldBatch)
    }

    func remove(reminder: EKReminder, shouldBatch: Bool = false) async throws {
        try await verifyAccess(for: .reminder)

        // If we should batch, we shouldn't commit.
        try eventStore.remove(reminder, commit: !shouldBatch)
    }

    func removeAll(events: inout [EKEvent],
                   reminders: inout [EKReminder]) async throws {
        if !events.isEmpty {
            for event in events {
                try await remove(event: event, shouldBatch: true)
                events.removeAll(where: { $0.eventIdentifier == event.eventIdentifier })
            }
            // After all the events were removed, we commit.
            try eventStore.commit()
        }

        if !reminders.isEmpty {
            for reminder in reminders {
                try await remove(reminder: reminder, shouldBatch: true)
                reminders.removeAll(where: {$0.calendarItemIdentifier == reminder.calendarItemIdentifier })
            }
            // After all the reminders were removed, we commit
            try eventStore.commit()
        }
    }

    // MARK: - Creator
    func create(_ entityType: EKEntityType,
                model: EventParameters,
                shouldCommit: Bool = true) async throws {
        let calendar = try await getCalendarToUse(for: entityType)

        switch entityType {
        case .event:
            try createEvent(for: model, on: calendar, shouldCommit: shouldCommit)
        case .reminder:
            try createReminder(for: model, on: calendar, shouldCommit: shouldCommit)
        default:
            throw EKManagerError.unknownEntity
        }
    }

    private func createEvent(for model: EventParameters,
                             on calendar: EKCalendar,
                             shouldCommit: Bool = true) throws {
        let event = EKEvent(eventStore: eventStore)
        event.title = model.title
        event.startDate = model.startDate
        event.endDate = model.endDate
        event.notes = model.notes
        event.calendar = calendar

        try eventStore.save(event, span: .thisEvent, commit: shouldCommit)
    }

    private func createReminder(for model: EventParameters,
                                on calendar: EKCalendar,
                                shouldCommit: Bool = true) throws {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = model.title
        reminder.dueDateComponents = model.startDate.toComponents(format: model.dateFormat)
        reminder.notes = model.notes
        reminder.calendar = calendar
        try eventStore.save(reminder, commit: shouldCommit)
    }

    // MARK: - Updaters
    func update(_ event: EKEvent, shouldBatch: Bool = false) async throws {
        try await verifyAccess(for: .event)

        try eventStore.save(event, span: .thisEvent)

        guard !shouldBatch else { return }

        try eventStore.commit()
    }

    func update(_ reminder: EKReminder, shouldBatch: Bool = false) async throws {
        try await verifyAccess(for: .reminder)

        try eventStore.save(reminder, commit: !shouldBatch)
    }
}
