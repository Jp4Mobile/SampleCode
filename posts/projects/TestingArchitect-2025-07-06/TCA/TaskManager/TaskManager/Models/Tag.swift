//
//  Tag.swift
//  TaskManager
//
//  Created by Jp LaFond on 11/20/24.
//

import Foundation
import RegexBuilder

enum Tag: Codable, Equatable, FormattedTMType {
    case tag(String)
    case payloadTag(String, String)

    // MARK: - Initializers
    init(_ tag: String, payload: String? = nil) {
        guard let payload,
              !payload.isEmpty else {
            self = .tag(tag)
            return
        }

        self = .payloadTag(tag, payload)
    }

    init(_ knownTag: Constants.DefaultTag, payload: String? = nil) {
        self = Tag(knownTag.rawValue, payload: payload)
    }

    // MARK: - Accessor Helpers
    var tag: String {
        switch self {
        case .tag(let tag),
                .payloadTag(let tag, _):
            return tag
        }
    }

    var payload: String? {
        guard case .payloadTag(_, let payload) = self else { return nil }

        return payload
    }

    // MARK: - FormattedTMType Functionality
    var toString: String {
        switch self {
        case .tag(let tag):
            return "@\(tag)"
        case .payloadTag(let tag, let payload):
            return "@\(tag)(\(payload))"
        }
    }
}

extension Tag: Identifiable {
    public var id: String {
        toString
    }
}

// MARK: - Payload Conversions
extension String {
    func toTMDateType() throws -> TMDateType? {
        guard let format = TMDateType.DateParameterFormat(from: self) else { return nil }

        // Set up the references
        let yearRef = Reference(Int.self)
        let monthRef = Reference(Int.self)
        let dayRef = Reference(Int.self)

        let hourRef = Reference(Int.self)
        let minuteRef = Reference(Int.self)

        let secondHourRef = Reference(Int.self)
        let secondMinuteRef = Reference(Int.self)

        let secondYearRef = Reference(Int.self)
        let secondMonthRef = Reference(Int.self)
        let secondDayRef = Reference(Int.self)
        
        // Set up matches
        let dateMatch = Regex {
            // yyyy-MM-dd
            TryCapture(as: yearRef) {
                Repeat(count: 4) {
                    .digit
                }
            } transform: { match in
                Int(match)
            }
            "-"
            TryCapture(as: monthRef) {
                Repeat(count: 2) {
                    .digit
                }
            } transform: { match in
                Int(match)
            }
            "-"
            TryCapture(as: dayRef) {
                Repeat(count: 2) {
                    .digit
                }
            } transform: { match in
                Int(match)
            }
        }

        let timeMatch = Regex {
            // HH:mm
            TryCapture(as: hourRef) {
                Repeat(count: 2) {
                    .digit
                }
            } transform: { match in
                Int(match)
            }
            ":"
            TryCapture(as: minuteRef) {
                Repeat(count: 2) {
                    .digit
                }
            } transform: { match in
                Int(match)
            }
        }

        let secondDateMatch = Regex {
            // yyyy-MM-dd
            TryCapture(as: secondYearRef) {
                Repeat(count: 4) {
                    .digit
                }
            } transform: { match in
                Int(match)
            }
            "-"
            TryCapture(as: secondMonthRef) {
                Repeat(count: 2) {
                    .digit
                }
            } transform: { match in
                Int(match)
            }
            "-"
            TryCapture(as: secondDayRef) {
                Repeat(count: 2) {
                    .digit
                }
            } transform: { match in
                Int(match)
            }
        }

        let secondTimeMatch = Regex {
            // HH:mm
            TryCapture(as: secondHourRef) {
                Repeat(count: 2) {
                    .digit
                }
            } transform: { match in
                Int(match)
            }
            ":"
            TryCapture(as: secondMinuteRef) {
                Repeat(count: 2) {
                    .digit
                }
            } transform: { match in
                Int(match)
            }
        }

        let dateSeparatorMatch = Regex {
            ZeroOrMore(.whitespace)
            ChoiceOf {
                "-"
                "thru"
                "through"
            }
            ZeroOrMore(.whitespace)
        }

        let dateTimeMatch = Regex {
            // yyyy-MM-dd HH:mm
            dateMatch

            OneOrMore(.whitespace)

            timeMatch
        }

        let dateTimeEndTimeMatch = Regex {
            // yyyy-MM-dd HH:mm '[-|thru|through]` HH:mm
            dateTimeMatch

            dateSeparatorMatch

            secondTimeMatch
        }

        let dateTimeDateTimeMatch = Regex {
            // yyyy-MM-dd HH:mm `[-|thru|through]` yyyy-MM-dd HH:mm
            dateTimeMatch

            dateSeparatorMatch
            
            secondDateMatch
            OneOrMore(.whitespace)
            secondTimeMatch
        }

        // Check the possible format against our regex patterns...
        switch format {
        case .date:
            // yyyy-MM-dd
            guard let match = self.wholeMatch(of: dateMatch) else {
                return nil
            }
            let year = match[yearRef]
            let month = match[monthRef]
            let day = match[dayRef]

            return try DateParameters(year: year, month: month, day: day).toDateType()

        case .dateTime:
            // yyyy-MM-dd HH:mm
            guard let match = self.wholeMatch(of: dateTimeMatch) else {
                return nil
            }
            let year = match[yearRef]
            let month = match[monthRef]
            let day = match[dayRef]
            let hour = match[hourRef]
            let minute = match[minuteRef]

            return try DateTimeParameters(date: .init(year: year, month: month, day: day),
                                          time: .init(hour: hour, minute: minute)).toDateType()

        case .dateTimeEndTime:
            // yyyy-MM-dd HH:mm-HH:mm
            guard let match = self.wholeMatch(of: dateTimeEndTimeMatch) else {
                return nil
            }
            let year = match[yearRef]
            let month = match[monthRef]
            let day = match[dayRef]
            let hour = match[hourRef]
            let minute = match[minuteRef]
            let secondHour = match[secondHourRef]
            let secondMinute = match[secondMinuteRef]

            return try DateTimeEndTimeParameters(date: .init(year: year, month: month, day: day),
                                                 time: .init(hour: hour, minute: minute),
                                                 endTime: .init(hour: secondHour, minute: secondMinute)).toDateType()

        case .dateTimeDateTime:
            // yyyy-MM-dd HH:mm thru yyyy-MM-dd HH:mm
            guard let match = self.wholeMatch(of: dateTimeDateTimeMatch) else {
                return nil
            }
            let year = match[yearRef]
            let month = match[monthRef]
            let day = match[dayRef]
            let hour = match[hourRef]
            let minute = match[minuteRef]
            let secondYear = match[secondYearRef]
            let secondMonth = match[secondMonthRef]
            let secondDay = match[secondDayRef]
            let secondHour = match[secondHourRef]
            let secondMinute = match[secondMinuteRef]

            return try DateTimeDateTimeParameters(start: .init(date: .init(year: year, month: month, day: day),
                                                               time: .init(hour: hour, minute: minute)),
                                                  end: .init(date: .init(year: secondYear, month: secondMonth, day: secondDay),
                                                             time: .init(hour: secondHour, minute: secondMinute))).toDateType()
        }
    }
}
