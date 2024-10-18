//
//  EventParameters.swift
//  TaskManager
//
//  Created by Jp LaFond on 10/13/24.
//

import Foundation

struct EventParameters: Codable {
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
}
