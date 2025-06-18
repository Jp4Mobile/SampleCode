//
//  Constants.swift
//  TaskManager
//
//  Created by Jp LaFond on 10/13/24.
//

import Foundation

enum Constants {
    /// Date elements
    enum Date {
        /// Year-Month-Day date format
        /// ie; yyyy-MM-dd
        static let YMD = "yyyy-MM-dd"
        /// Year-Month-Day Hour:Minute date time format
        static let YMDHM = "yyyy-MM-dd HH:mm"
    }

    /// Default Tags
    enum DefaultTag: String, Codable, Equatable {
        case due
        case done
    }
}

/// Default UI Spacings
enum Spacing {
    /// 4
    static let half = Spacing.default / 2
    /// 8
    static let `default`: CGFloat = 8
    /// 16
    static let double = Spacing.default * 2
    /// 24
    static let triple = Spacing.default * 3
    /// 32
    static let quadruple = Spacing.default * 4
}

/// Localizable Strings
extension Constants {
    /// EKManager Elements
    enum Alert {
        static let message = NSLocalizedString("Are you sure?",
                                               comment: "")
        static let deleteTitle = NSLocalizedString("Delete",
                                                   comment: "")
    }
    enum EKManager {
        static let defaultCalendarName = NSLocalizedString("TaskManager",
                                                           comment: "Default calendar name")
    }
    enum Tag {
        static let placeholder = NSLocalizedString("Enter Tag",
                                                   comment: "Tag placeholder")
    }
    enum Tasks {
        static let title = NSLocalizedString("Tasks", comment: "Tasks view title")
    }

    enum AddEditTask {
        static let addTitle = NSLocalizedString("Add Task", comment: "")
        static let editTitle = NSLocalizedString("Edit Task", comment: "")

        static let placeholder = NSLocalizedString("Enter Task", comment: "")
        static let cancelTitle = NSLocalizedString("Cancel", comment: "")
        static let deleteTitle = NSLocalizedString("Delete", comment: "")
        static let saveTitle = NSLocalizedString("Save", comment: "")
    }
}
