//
//  DateExtensions.swift
//  TaskManager
//
//  Created by Jp LaFond on 10/13/24.
//

import Foundation

extension Date {
    // MARK: - TMDateFormat
    /// Standardized TM Date Formats
    enum TMDateFormat: Codable {
        /// Date only
        case date
        /// Date Time
        case dateTime

        /// Input/Output format string
        var string: String {
            switch self {
            case .date:
                return Constants.Date.YMD
            case .dateTime:
                return Constants.Date.YMDHM
            }
        }

        /// Date Components
        var components: Set<Calendar.Component> {
            switch self {
            case .date:
                return [.year, .month, .day]
            case .dateTime:
                return [.year, .month, .day, .hour, .minute]
            }
        }
    }

    // MARK: - Properties
    private var currentCalendar: Calendar {
        Calendar.current
    }

    private var dateFormatter: DateFormatter {
        DateFormatter()
    }

    // MARK: - Standardized Input/Output Transformations
    // MARK: Parameter Model Conversions
    func toDateParameters() -> DateParameters? {
        let components = currentCalendar.dateComponents(TMDateFormat.date.components, from: self)

        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return nil
        }

        return .init(year: year, month: month, day: day)
    }

    func toDateTimeParameters() -> DateTimeParameters? {
        let components = currentCalendar.dateComponents(TMDateFormat.dateTime.components, from: self)

        guard let year = components.year,
              let month = components.month,
              let day = components.day,
              let hour = components.hour,
              let minutes = components.minute else {
            return nil
        }

        return .init(date: .init(year: year,
                                 month: month,
                                 day: day),
                     time: .init(hour: hour,
                                 minute: minutes))
    }

    func toComponents(format: TMDateFormat) -> DateComponents? {
        currentCalendar.dateComponents(format.components, from: self)
    }

    // MARK: Output strings
    func string(format: TMDateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.string

        return dateFormatter.string(from: self)
    }

    // MARK: Initializers
    init?(format: TMDateFormat, _ input: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.string
        
        guard let date = dateFormatter.date(from: input) else {
            return nil
        }
        
        self = date
    }

    init?(date parameters: DateParameters) {
        self.init(format: .date, parameters.formattedDate)
    }

    init?(dateTime parameters: DateTimeParameters) {
        self.init(format: .dateTime, parameters.formattedDate)
    }
}
