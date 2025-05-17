//
//  EventParameters.swift
//  TaskManager
//
//  Created by Jp LaFond on 10/13/24.
//

import EventKit
import Foundation

protocol EventSearchable {
    var searchType: TMSearchType { get }

    func matches(searchType: TMSearchType) -> Bool
}

struct EventParameters: Codable, Equatable, EventSearchable {
    let title: String
    let startDate: Date
    let endDate: Date?
    let notes: String?
    let dateFormat: Date.TMDateFormat

    init(title: String,
         startDate: Date,
         endDate: Date? = nil,
         notes: String? = nil,
         dateFormat: Date.TMDateFormat = .dateTime) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.dateFormat = dateFormat
    }

    var toSearchable: EventParametersSearchable {
        EventParametersSearchable(title: title,
                                  startDate: startDate,
                                  endDate: endDate,
                                  notes: notes,
                                  dateFormat: dateFormat)
    }

    var searchType: TMSearchType {
        .bySearchValues(self.toSearchable)
    }

    func matches(searchType: TMSearchType) -> Bool {
        switch searchType {
        case .byId:
            // There is no ID
            return false
        case .bySearchValues(let searchBy):
            var keysToSearch: Set<CodingKeys> = []

            if let title = searchBy.title {
                keysToSearch.insert(.title)
            }
            if let startDate = searchBy.startDate {
                keysToSearch.insert(.startDate)
            }
            if let endDate = searchBy.endDate {
                keysToSearch.insert(.endDate)
            }
            if let notes = searchBy.notes {
                keysToSearch.insert(.notes)
            }

            switch keysToSearch {
            case [.title, .startDate, .endDate, .notes]:
                return title == searchBy.title &&
                    startDate == searchBy.startDate &&
                    endDate == searchBy.endDate &&
                    notes == searchBy.notes
            case [.title, .startDate, .endDate]:
                return title == searchBy.title &&
                startDate == searchBy.startDate &&
                endDate == searchBy.endDate
            case [.title, .startDate, .notes]:
                return title == searchBy.title &&
                startDate == searchBy.startDate &&
                notes == searchBy.notes
            case [.title, .endDate, .notes]:
                return title == searchBy.title &&
                endDate == searchBy.endDate &&
                notes == searchBy.notes
            case [.title, .startDate]:
                return title == searchBy.title &&
                startDate == searchBy.startDate
            case [.title, .endDate]:
                return title == searchBy.title &&
                endDate == searchBy.endDate
            case [.title, .notes]:
                return title == searchBy.title &&
                notes == searchBy.notes
            case [.title]:
                guard let searchTitle = searchBy.title else { return false }
                return title.contains(searchTitle)
            case [.startDate, .endDate, .notes]:
                return startDate == searchBy.startDate &&
                endDate == searchBy.endDate &&
                notes == searchBy.notes
            case [.startDate, .notes]:
                return startDate == searchBy.startDate &&
                notes == searchBy.notes
            case [.startDate]:
                return startDate == searchBy.startDate
            case [.endDate, .notes]:
                return endDate == searchBy.endDate &&
                notes == searchBy.notes
            case [.endDate]:
                return endDate == searchBy.endDate
            case [.notes]:
                guard let notes,
                      let searchNotes = searchBy.notes else { return false }
                return notes.contains(searchNotes)
            default:
                return false
            }
        }
    }
}

struct EventResult: Codable, Equatable, EventSearchable {
    let id: String
    let model: EventParameters

    var searchType: TMSearchType {
        .byId(id)
    }

    func matches(searchType: TMSearchType) -> Bool {
        switch searchType {
        case .byId(let id):
            return self.id == id
        case .bySearchValues:
            return model.matches(searchType: searchType)
        }
    }
}

struct EventParametersSearchable: Codable, Equatable {
    let title: String?
    let startDate: Date?
    let endDate: Date?
    let notes: String?
    let dateFormat: Date.TMDateFormat?

    init(title: String? = nil,
         startDate: Date? = nil,
         endDate: Date? = nil,
         notes: String? = nil,
         dateFormat: Date.TMDateFormat? = nil) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.dateFormat = dateFormat
    }
}

// MARK: - Helper Extensions
protocol ModelConvertible {
    var result: EventResult { get }
}

extension EKEvent: ModelConvertible {
    var result: EventResult {
        .init(id: self.eventIdentifier,
              model: .init(title: self.title,
                           startDate: self.startDate,
                           endDate: self.endDate,
                           notes: self.notes,
                           dateFormat: .dateTime))
    }
}

extension DateComponents {
    var dateFormat: Date.TMDateFormat? {
        guard year != nil,
              month != nil,
              day != nil else { return nil }

        guard hour != nil,
              minute != nil else { return .date }

        return .dateTime
    }
}

extension EKReminder: ModelConvertible {
    var result: EventResult {
        guard let dateFormat = self.startDateComponents?.dateFormat,
              let date = self.startDateComponents?.date else {
            return .init(id: self.calendarItemIdentifier,
                         model: .init(title: self.title,
                                      startDate: Date(),
                                      endDate: self.dueDateComponents?.date,
                                      notes: self.notes,
                                      dateFormat: .date))
        }



        return .init(id: self.calendarItemIdentifier,
                     model: .init(title: self.title,
                                  startDate: date,
                                  endDate: self.dueDateComponents?.date,
                                  notes: self.notes,
                                  dateFormat: dateFormat))
    }
}
