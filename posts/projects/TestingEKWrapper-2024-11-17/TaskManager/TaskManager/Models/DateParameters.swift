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
