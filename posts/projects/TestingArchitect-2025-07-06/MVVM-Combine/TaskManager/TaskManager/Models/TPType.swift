//
//  TPType.swift
//  TaskManager
//
//  Created by Jp LaFond on 11/20/24.
//

import Foundation

enum TPType: Codable, Equatable, FormattedTMType {
    case project(String)
    case task(String)
    case text(String)

    // MARK: - FormattedTMType Functionality
    var toString: String {
        switch self {
        case .project(let string):
            return "\(string):"
        case .task(let string):
            return "- \(string)"
        case .text(let string):
            return string
        }
    }
}
