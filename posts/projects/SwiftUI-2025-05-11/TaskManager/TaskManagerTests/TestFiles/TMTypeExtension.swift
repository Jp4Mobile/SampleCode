//
//  TMTypeExtension.swift
//  TaskManagerTests
//
//  Created by Jp LaFond on 11/21/24.
//

import Foundation

@testable import TaskManager
extension TMType {
    static var TestSampleModel: [TMType] {
        [
            TMType(type: .project("Project"),
                   children: [
                    TMType(tabLevel: 1, type: .text("Notes on a project.")),
                    TMType(tabLevel: 1, type: .text("TaskPaper uses a hierarchical structure to keep track of parents and ownership.")),
                    TMType(tabLevel: 1, type: .text("ie; all of the below items are within this project.")),
                    TMType(tabLevel: 1, type: .task("Item for that project."),
                           children: [
                                TMType(tabLevel: 2, type: .task("Child item with a note."),
                                       children: [
                                        TMType(tabLevel: 3, type: .text("Note about that item."))
                                       ])
                           ]),
                    TMType(tabLevel: 1, type: .task("Tagged Item"), tags: [.tag("tag")]),
                    TMType(tabLevel: 1, type: .task("Tagged Item where the tag has a payload"), tags: [.payloadTag("tag", "payload")]),
                    TMType(tabLevel: 1, type: .text("Let's illustrate some of the time formats that we've worked so hard on.")),
                    TMType(tabLevel: 1, type: .task("Something completed"),
                           tags: [.tag("test"), .payloadTag("due", "2024-11-23"), .payloadTag("done", "2024-11-23")]),
                    TMType(tabLevel: 1, type: .task("Something with a set due date and time"),
                           tags: [.tag("test"), .payloadTag("due", "2024-11-24 10:00")]),
                    TMType(tabLevel: 1, type: .task("An appointment"),
                           tags: [.tag("test"), .payloadTag("due", "2024-11-24 10:00-10:30")]),
                    TMType(tabLevel: 1, type: .task("A spanning appointment"),
                           tags: [.tag("test"), .payloadTag("due", "2024-11-23 11:00 thru 2024-11-24 10:00")])
                   ]),
            TMType(type: .text("")),
            TMType(type: .project("Other Project"),
                   children: [
                    TMType(tabLevel: 1, type: .task("Item for the other project"))
                   ]),
            TMType(type: .text(""))
        ]
    }
}
