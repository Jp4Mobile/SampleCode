//
//  DateParameters.swift
//  TaskManager
//
//  Created by Jp LaFond on 10/13/24.
//

import Foundation

/// Formatted Date Representable
protocol FormattedDateRepresentable {
    var formattedDate: String { get }
}


enum TMDateType: Equatable {
    case date(Date)
    case beginEndDate(Date, Date)

    var startDate: Date {
        switch self {
        case .date(let date):
            return date
        case .beginEndDate(let start, _):
            return start
        }
    }

    var endDate: Date? {
        guard case .beginEndDate(_, let end) = self else {
            return nil
        }

        return end
    }

    /// Convert to a Formatted Date String, if posssible
    func toFormattedDateString(format: DateParameterFormat,
                               separator: DateFormatSeparatorType = .compact,
                               withSpaces: Bool = true) -> String? {
        switch self {
        case .date(let date):
            switch format {
            case .date:
                return date.string(format: .date)
            case .dateTime:
                return date.string(format: .dateTime)
            default:
                // Invalid formats for only one date
                return nil
            }
        case .beginEndDate(let start, let end):
            switch format {
            case .dateTimeDateTime:
                return "\(start.string(format: .dateTime))\(separator.toString(withSpaces: withSpaces))\(end.string(format: .dateTime))"
            case .dateTimeEndTime:
                // Ensure that they're both the same date
                guard start.string(format: .date) == end.string(format: .date),
                      let endDateTimeParameters = end.toDateTimeParameters() else { return nil }

                return "\(start.string(format: .dateTime))\(separator.toString(withSpaces: withSpaces))\(endDateTimeParameters.time.formattedDate)"
            default:
                // Invalid formats for only one date
                return nil
            }
        }
    }


    /// Helper Enum for Formatting...
    enum DateParameterFormat: Equatable {
        case date
        case dateTime
        case dateTimeEndTime
        case dateTimeDateTime

        init?(from string: String) {
            switch string.count {
            case 10:
                // YYYY-mm-dd
                self = .date
            case 16:
                // YYYY-mm-dd HH:mm
                self = .dateTime
            case 22...32:
                // YYYY-mm-dd HH:mm-HH:mm
                // ...
                // YYYY-mm-dd HH:mm through HH:mm
                self = .dateTimeEndTime
            case 33...41:
                // YYYY-mm-dd HH:mm-YYYY-mm-dd HH:mm
                // ...
                // YYYY-mm-dd HH:mm through YYYY-mm-dd HH:mm
                self = .dateTimeDateTime
            default:
                return nil
            }
        }
    }

    /// Helper Enum for Extended Date Formatting
    enum DateFormatSeparatorType: String, Equatable {
        case compact = "-"
        case extended = "thru"
        case grammarExtended = "through"

        func toString(withSpaces: Bool = true) -> String {
            guard withSpaces else { return rawValue }

            return " \(rawValue) "
        }
    }
}

protocol ParameterConvertible {
    func toDateType() throws -> TMDateType
}

private extension Int {
    func leadingZeroString(digits: Int = 2) -> String {
        let format = "%0\(digits)d"
        return String(format: format, self)
    }
}

// MARK: - Date Parameter Models
struct DateParameters: FormattedDateRepresentable, ParameterConvertible {
    let year: Int
    let month: Int
    let day: Int

    var formattedDate: String {
        // yyyy-MM-dd
        "\(year.leadingZeroString(digits: 4))-\(month.leadingZeroString())-\(day.leadingZeroString())"
    }

    func toDateType() throws -> TMDateType {
        guard let date = Date(format: .date, formattedDate) else {
            throw TMError.invalidFormattedString(formattedDate)
        }

        return .date(date)
    }
}

struct TimeParameters: FormattedDateRepresentable {
    let hour: Int
    let minute: Int

    var formattedDate: String {
        "\(hour.leadingZeroString()):\(minute.leadingZeroString())"
    }
}

struct DateTimeParameters: FormattedDateRepresentable, ParameterConvertible {
    let date: DateParameters
    let time: TimeParameters

    var formattedDate: String {
        "\(date.formattedDate) \(time.formattedDate)"
    }

    func toDateType() throws -> TMDateType {
        guard let date = Date(format: .dateTime, formattedDate) else {
            throw TMError.invalidFormattedString(formattedDate)
        }

        return .date(date)
    }
}

struct DateTimeEndTimeParameters: FormattedDateRepresentable, ParameterConvertible {
    enum OutputFormat: String {
        case compact = "-"
        case expanded = " thru "

        var divider: String {
            self.rawValue
        }
    }

    let date: DateParameters
    let time: TimeParameters
    let endTime: TimeParameters
    var outputFormat: OutputFormat = .compact

    var formattedDate: String {
        "\(date.formattedDate) \(time.formattedDate)\(outputFormat.divider)\(endTime.formattedDate)"
    }

    func toDateType() throws -> TMDateType {
        let startDateModel = DateTimeParameters(date: date, time: time)
        let endDateModel = DateTimeParameters(date: date, time: endTime)
        guard let startDate = Date(format: .dateTime, startDateModel.formattedDate),
              let endDate = Date(format: .dateTime, endDateModel.formattedDate) else {
            throw TMError.invalidFormattedString(formattedDate)
        }
        guard startDate < endDate else {
            throw TMError.endDateNotAfterStartDate(startDate, endDate)
        }

        return .beginEndDate(startDate, endDate)
    }
}

struct DateTimeDateTimeParameters: FormattedDateRepresentable, ParameterConvertible {
    let start: DateTimeParameters
    let end: DateTimeParameters

    var formattedDate: String {
        "\(start.formattedDate) thru \(end.formattedDate)"
    }

    func toDateType() throws -> TMDateType {
        guard let startDate = Date(format: .dateTime, start.formattedDate),
              let endDate = Date(format: .dateTime, end.formattedDate) else {
            throw TMError.invalidFormattedString(formattedDate)
        }
        guard startDate < endDate else {
            throw TMError.endDateNotAfterStartDate(startDate, endDate)
        }

        return .beginEndDate(startDate, endDate)
    }
}
