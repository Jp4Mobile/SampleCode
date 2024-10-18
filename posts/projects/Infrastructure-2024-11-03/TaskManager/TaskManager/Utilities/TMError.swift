//
//  TMError.swift
//  TaskManager
//
//  Created by Jp LaFond on 10/13/24.
//

import Foundation

enum TMError: Error, LocalizedError, Equatable {
    // MARK: - Date/Date Model Specific Errors
    case invalidFormattedString(String)
    case endDateNotAfterStartDate(Date, Date)

    var errorDescription: String? {
        switch self {
        case .invalidFormattedString(let string):
            return "Invalid formatted string: \(string)"
        case .endDateNotAfterStartDate(let startDate, let endDate):
            return "End date \(endDate.string(format: .dateTime)) must be after start date \(startDate.string(format: .dateTime))"
        }
    }
}
