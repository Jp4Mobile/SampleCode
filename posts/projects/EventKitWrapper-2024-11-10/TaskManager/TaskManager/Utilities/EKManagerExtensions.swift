//
//  EKManagerExtensions.swift
//  TaskManager
//
//  Created by Jp LaFond on 10/24/24.
//

import EventKit
import Foundation

enum TMEntity: Codable, Equatable {
    case event
    case reminder

    var ekEntityType: EKEntityType {
        switch self {
        case .event: return .event
        case .reminder: return .reminder
        }
    }
}

enum TMSearchType: Codable, Equatable {
    case byId(String)
    case bySearchValues(EventParametersSearchable)
}

protocol EventCapable {
    /// Create an appropiate entity from a known model
    ///  - Parameter entity: entity to create
    ///  - Parameter model: data model to convert into the appropriate entity
    ///  - Parameter shouldCommit: whether or not these changes are commited.
    ///  - Note: Non-commited changes can be batched and commited to the appropriate ``EKCalendar`` or ``EKEventStore`` as appropriate.
    func create(entity: TMEntity, model: EventParameters, shouldCommit: Bool) async throws

    /// Replace an appropriate entity from a known model
    /// - Parameter entity: entity to update
    /// - Parameter by searchType: defines how to search for the appropriate entity
    /// - Parameter model: data model to update the appropriate entity
    /// - Parameter shouldCommit: whether or not these changes are commited.
    func update(entity: TMEntity, by searchType: TMSearchType, model: EventParameters, shouldCommit: Bool) async throws

    /// Search for an appropriate entity from a known model
    func search(entity: TMEntity, by searchType: TMSearchType) async throws -> [EventResult]

    /// Delete an appropriate entity from a known model
    func delete(entity: TMEntity, by searchType: TMSearchType) async throws
}

extension EKManager: EventCapable {
    func create(entity: TMEntity, model: EventParameters, shouldCommit: Bool) async throws {
        try await create(entity.ekEntityType, model: model, shouldCommit: shouldCommit)
    }
    
    func update(entity: TMEntity, by searchType: TMSearchType, model: EventParameters, shouldCommit: Bool) async throws {
        let results = try await search(entity: entity, by: searchType)

        guard let result = results.first else {
            throw TMError.entityNotFound(entity, searchType)
        }

        try await delete(entity: entity, by: result.searchType)
        try await create(entity: entity, model: model, shouldCommit: shouldCommit)
    }
    
    func search(entity: TMEntity, by searchType: TMSearchType) async throws -> [EventResult] {
        try await filter(entity: entity, by: searchType)
    }
    
    func delete(entity: TMEntity, by searchType: TMSearchType) async throws {
        switch entity {
        case .event:
            let events = try await getEvents()
                .filter { $0.result.matches(searchType: searchType) }
            for event in events {
                try await remove(event: event, shouldBatch: true)
            }
        case .reminder:
            let reminders = try await getReminders()
                .filter { $0.result.matches(searchType: searchType) }
            for reminder in reminders {
                try await remove(reminder: reminder, shouldBatch: true)
            }
        }
        try eventStore.commit()
    }
}

extension EKManager {
    // MARK: - Helper Functions
    func retrieve(entity: TMEntity) async throws -> [EventResult] {
        switch entity {
        case .event:
            return try await getEvents()
                .map { $0.result }
        case .reminder:
            return try await getReminders()
                .map { $0.result }
        }
    }

    func filter(entity: TMEntity, by searchType: TMSearchType) async throws -> [EventResult] {
        switch searchType {
        case .byId(let id):
            switch entity {
            case .event:
                let event = try await getEvent(id: id)
                return [event.result]
            case .reminder:
                let reminder = try await getReminder(id: id)
                return [reminder.result]
            }
        case .bySearchValues:
            return try await retrieve(entity: entity)
                .filter { $0.matches(searchType: searchType) }
        }
    }
}
