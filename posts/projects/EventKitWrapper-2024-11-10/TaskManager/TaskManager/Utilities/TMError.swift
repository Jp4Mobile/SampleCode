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
    // MARK: - EKManager Specific Errors
    case unabletoCreate(TMEntity, EventParameters)
    case unableToUpdate(TMEntity, EventParameters)
    case unableToDelete(TMEntity)
    case entityNotFound(TMEntity, TMSearchType)
    

    var errorDescription: String? {
        switch self {
        case .invalidFormattedString(let string):
            return "Invalid formatted string: \(string)"
        case .endDateNotAfterStartDate(let startDate, let endDate):
            return "End date \(endDate.string(format: .dateTime)) must be after start date \(startDate.string(format: .dateTime))"
        case .entityNotFound(let entity, let search):
            return "Entity \(entity) not found for search type \(search)"
        case .unabletoCreate(let entity, let model):
            return "Unable to create \(entity) from model \(model)"
        case .unableToUpdate(let entity, let model):
            return "Unable to create \(entity) from model \(model)"
        case .unableToDelete(let entity):
            return "Unable to delete \(entity)"
        }
    }
}
