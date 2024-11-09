//
//  EKManagerTests.swift
//  TaskManagerTests
//
//  Created by Jp LaFond on 11/9/24.
//

import EventKit
import XCTest

@testable import TaskManager

final class EKManagerTests: XCTestCase {
    var sut: EKManager!

    override func tearDown() {
        sut.reset()
        sut = nil

        super.tearDown()
    }

    enum TestError: Error, Equatable {
        case error
    }

    // MARK: - Access Wrapper Tests
    // MARK: Events
    func test_requestCalendarAccess_whenThrowingAnError_thenThrowsError() async {
        // Set up injection
        let fakeEventStore = FakeEKEventStore()
        fakeEventStore.errorToThrow = TestError.error
        sut = EKManager.shared
        sut.eventStore = fakeEventStore

        do {
            try await sut.requestCalendarAccess()
            XCTFail("Should not have succeeded")
        } catch {
            XCTAssertEqual(error as? TestError, .error)
            XCTAssertFalse(sut.hasCalendarAccess)
        }
    }

    func test_requestCalendarAccess_whenUnsuccessful_doesNotGrantAccess() async throws {
        // Set up injection
        let fakeEventStore = FakeEKEventStore()
        fakeEventStore.accessResult = false
        sut = EKManager.shared
        sut.eventStore = fakeEventStore

        try await sut.requestCalendarAccess()
        XCTAssertFalse(sut.hasCalendarAccess)
    }

    func test_requestCalendarAccess_whenSuccessful_grantsAccess() async throws {
        // Set up injection
        let fakeEventStore = FakeEKEventStore()
        fakeEventStore.accessResult = true
        sut = EKManager.shared
        sut.eventStore = fakeEventStore

        try await sut.requestCalendarAccess()
        XCTAssertTrue(sut.hasCalendarAccess)
    }

    // MARK: Reminders
    func test_requestReminderAccess_whenThrowingAnError_thenThrowsError() async {
        let fakeEventStore = FakeEKEventStore()
        fakeEventStore.errorToThrow = TestError.error
        sut = EKManager.shared
        sut.eventStore = fakeEventStore

        do {
            try await sut.requestReminderAccess()
            XCTFail("Should not have succeeded")
        } catch {
            XCTAssertEqual(error as? TestError, .error)
            XCTAssertFalse(sut.hasReminderAccess)
        }
    }

    func test_requestReminderAccess_whenUnsuccessful_doesNotGrantAccess() async throws {
        // Set up injection
        let fakeEventStore = FakeEKEventStore()
        fakeEventStore.accessResult = false
        sut = EKManager.shared
        sut.eventStore = fakeEventStore

        try await sut.requestReminderAccess()
        XCTAssertFalse(sut.hasReminderAccess)
    }

    func test_requestReminderAccess_whenSuccessful_grantsAccess() async throws {
        // Set up injection
        let fakeEventStore = FakeEKEventStore()
        fakeEventStore.accessResult = true
        sut = EKManager.shared
        sut.eventStore = fakeEventStore

        try await sut.requestReminderAccess()
        XCTAssertTrue(sut.hasReminderAccess)
    }

    // MARK: Verify Access
    func test_verifyAccess_forEvents_whenAccessHasBeenGranted_doesNotRequestAccess() async throws {
        let fakeEventStore = FakeEKEventStore()
        fakeEventStore.errorToThrow = TestError.error
        sut = EKManager.shared
        sut.eventStore = fakeEventStore
        sut.set(hasCalendarAccess: true)

        try await sut.verifyAccess(for: .event)
        XCTAssertTrue(sut.hasCalendarAccess)
    }

    func test_verifyAccess_forReminders_whenAccessHasBeenGranted_doesNotRequestAccess() async throws {
        let fakeEventStore = FakeEKEventStore()
        fakeEventStore.errorToThrow = TestError.error
        sut = EKManager.shared
        sut.eventStore = fakeEventStore
        sut.set(hasReminderAccess: true)

        try await sut.verifyAccess(for: .reminder)
        XCTAssertTrue(sut.hasReminderAccess)
    }

    func test_verifyAccess_forEvents_withoutAccess_throwsError() async {
        let fakeEventStore = FakeEKEventStore()
        fakeEventStore.accessResult = false
        sut = EKManager.shared
        sut.eventStore = fakeEventStore

        do {
            try await sut.verifyAccess(for: .event)
            XCTFail("Should not succeed")
        } catch {
            if let ekError = error as? EKManager.EKManagerError,
               case .calendarAccessDenied = ekError {
                return
            } else {
                XCTFail("Unknown error: \(error)")
            }
        }
    }

    func test_verifyAccess_forReminders_withoutAccess_throwsError() async {
        let fakeEventStore = FakeEKEventStore()
        fakeEventStore.accessResult = false
        sut = EKManager.shared
        sut.eventStore = fakeEventStore

        do {
            try await sut.verifyAccess(for: .reminder)
            XCTFail("Should not succeed")
        } catch {
            if let ekError = error as? EKManager.EKManagerError,
               case .reminderAccessDenied = ekError {
                return
            } else {
                XCTFail("Unknown error: \(error)")
            }
        }
    }

    // MARK: - Retrieve Tests
    // MARK: Events
    func test_getEvents_withoutAccess_throwsError() async {
        let fakeEventStore = FakeEKEventStore()
        fakeEventStore.accessResult = false
        fakeEventStore.eventsResult = []
        sut = EKManager.shared
        sut.eventStore = fakeEventStore
        
        do {
            _ = try await sut.getEvents()
            XCTFail("Should not succeed")
        } catch {
            if let ekError = error as? EKManager.EKManagerError,
               case .calendarAccessDenied = ekError {
                return
            } else {
                XCTFail("Unknown error: \(error)")
            }
        }
    }

    func test_getEvents_withAccess_returnsEvents() async throws {
        let fakeEventStore = FakeEKEventStore()
        let event = EKEvent(eventStore: fakeEventStore)
        fakeEventStore.eventsResult = [event]
        sut = EKManager.shared
        sut.eventStore = fakeEventStore
        sut.set(hasCalendarAccess: true)

        let events = try await sut.getEvents()
        XCTAssertEqual(events, [event])
    }

    func test_getEvent_withAccess_returnsEvent() async throws {
        let fakeEventStore = FakeEKEventStore()
        let event = EKEvent(eventStore: fakeEventStore)
        fakeEventStore.eventResult = event
        sut = EKManager.shared
        sut.eventStore = fakeEventStore
        sut.set(hasCalendarAccess: true)
        let eventToTest = try await sut.getEvent(id: "ignored")
        XCTAssertEqual(eventToTest, event)
    }

    func test_getEvent_withNoResult_throwsError() async {
        let fakeEventStore = FakeEKEventStore()
        sut = EKManager.shared
        sut.eventStore = fakeEventStore
        sut.set(hasCalendarAccess: true)
        do {
            _ = try await sut.getEvent(id: "ignored")
            XCTFail("Should not succeed")
        } catch {
            if let ekError = error as? EKManager.EKManagerError,
               case .eventNotFound = ekError {
                return
            } else {
                XCTFail("Unknown error: \(error)")
            }
        }
    }

    // MARK: Reminders
    func test_getReminders_withoutAccess_throwsError() async {
        let fakeEventStore = FakeEKEventStore()
        fakeEventStore.accessResult = false
        fakeEventStore.remindersResult = []
        sut = EKManager.shared
        sut.eventStore = fakeEventStore
        
        do {
            _ = try await sut.getReminders()
            XCTFail("Should not succeed")
        } catch {
            if let ekError = error as? EKManager.EKManagerError,
               case .reminderAccessDenied = ekError {
                return
            } else {
                XCTFail("Unknown error: \(error)")
            }
        }
    }

    func test_getReminders_withAccess_returnsEvents() async throws {
        let fakeEventStore = FakeEKEventStore()
        let reminder = EKReminder(eventStore: fakeEventStore)
        fakeEventStore.remindersResult = [reminder]
        sut = EKManager.shared
        sut.eventStore = fakeEventStore
        sut.set(hasReminderAccess: true)

        let reminders = try await sut.getReminders()
        XCTAssertEqual(reminders, [reminder])
    }

    func test_getReminder_withAccess_returnsEvent() async throws {
        let fakeEventStore = FakeEKEventStore()
        let reminder = EKReminder(eventStore: fakeEventStore)
        fakeEventStore.reminderResult = reminder
        sut = EKManager.shared
        sut.eventStore = fakeEventStore
        sut.set(hasReminderAccess: true)

        let reminderToTest = try await sut.getReminder(id: "ignored")
        XCTAssertEqual(reminderToTest, reminder)
    }

    func test_getReminder_withNoResult_throwsError() async {
        let fakeEventStore = FakeEKEventStore()
        sut = EKManager.shared
        sut.eventStore = fakeEventStore
        sut.set(hasCalendarAccess: true)
        do {
            _ = try await sut.getReminder(id: "ignored")
            XCTFail("Should not succeed")
        } catch {
            if let ekError = error as? EKManager.EKManagerError,
               case .reminderNotFound = ekError {
                return
            } else {
                XCTFail("Unknown error: \(error)")
            }
        }
    }
}

class FakeEKEventStore: EKEventStore {
    var errorToThrow: Error?

    // MARK: - Access
    var accessResult: Bool?

    override func requestFullAccessToEvents() async throws -> Bool {
        if let errorToThrow {
            throw errorToThrow
        }

        if let accessResult {
            return accessResult
        }
        
        return try await super.requestFullAccessToEvents()
    }

    override func requestFullAccessToReminders() async throws -> Bool {
        if let errorToThrow {
            throw errorToThrow
        }
        
        if let accessResult {
            return accessResult
        }
        
        return try await super.requestFullAccessToReminders()
    }

    // MARK: - Commit
    override func commit() throws {
        if let errorToThrow {
            throw errorToThrow
        }

        // Don't actually commit
    }

    // MARK: - Calendars
    var calendarsResult: [EKCalendar]?
    var calendarResult: EKCalendar?

    override var defaultCalendarForNewEvents: EKCalendar? {
        if let calendarResult {
            return calendarResult
        }
        
        return super.defaultCalendarForNewEvents
    }

    override func defaultCalendarForNewReminders() -> EKCalendar? {
        if let calendarResult {
            return calendarResult
        }
        
        return super.defaultCalendarForNewReminders()
    }

    override func calendars(for entityType: EKEntityType) -> [EKCalendar] {
        if let calendarsResult {
            return calendarsResult
        }

        return super.calendars(for: entityType)
    }

    override func saveCalendar(_ calendar: EKCalendar, commit: Bool) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        // Don't actually save...
    }

    override func removeCalendar(_ calendar: EKCalendar, commit: Bool) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        // Don't actually remove...
    }

    // MARK: - Source
    var sourcesResult: [EKSource]?

    override var sources: [EKSource] {
        if let sourcesResult {
            return sourcesResult
        }
        
        return super.sources
    }

    // MARK: - Events
    var eventsResult: [EKEvent]?
    var eventResult: EKEvent?

    override func events(matching predicate: NSPredicate) -> [EKEvent] {
        if let eventsResult {
            return eventsResult
        }

        return []
    }

    override func event(withIdentifier identifier: String) -> EKEvent? {
        if let eventResult {
            return eventResult
        }
        
        return nil
    }

    override func remove(_ event: EKEvent, span: EKSpan, commit: Bool) throws {
        if let errorToThrow {
            throw errorToThrow
        }
        
        // Don't actually remove
    }

    override func remove(_ event: EKEvent, span: EKSpan) throws {
        if let errorToThrow {
            throw errorToThrow
        }
        
        // Don't actually remove
    }

    // MARK: - Reminders
    var remindersResult: [EKReminder]?
    var reminderResult: EKReminder?

    override func fetchReminders(matching predicate: NSPredicate, completion: @escaping ([EKReminder]?) -> Void) -> Any {
        if let remindersResult {
            completion(remindersResult)
            return remindersResult
        }

        completion(nil)
        return ""
    }

    override func calendarItem(withIdentifier identifier: String) -> EKCalendarItem? {
        if let reminderResult {
            return reminderResult
        }
        
        return nil
    }

    override func remove(_ reminder: EKReminder, commit: Bool) throws {
        if let errorToThrow {
            throw errorToThrow
        }
        
        // Don't actually remove
    }
}
