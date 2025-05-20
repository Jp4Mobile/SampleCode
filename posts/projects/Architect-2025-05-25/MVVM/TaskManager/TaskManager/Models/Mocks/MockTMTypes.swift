//
//  MockTMTypes.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/19/25.
//

import Foundation

#if DEBUG

extension TMType {
    enum Mock {
        enum TopLevel {
            static var text: TMType = TMType(type: .text("Text"))
            static var task: TMType = TMType(type: .task("Task"))
            static var project: TMType = TMType(type: .project("Project"))
        }

        enum Tasks {
            // MARK: Tasks With Tags
            static var taskWithTag: TMType = TMType(type: .task("Task"),
                                                    tags: [Tag("tag")])
            static var taskWithDueDate: TMType = TMType(type: .task("Task with Due Date"),
                                                        tags: [Tag(.due, payload: "2025-06-01")])
            static var taskWithDueDateTime: TMType = TMType(type: .task("Task with Due Date/Time"),
                                                            tags: [Tag(.due, payload: "2025-06-01 06:01")])
            static var taskWithDueDateTimeRange: TMType = TMType(type: .task("Task with Due Date/Time Range"),
                                                                 tags: [Tag(.due, payload: "2025-06-01 06:01-13:00")])
            static var taskWithDueDateRange: TMType = TMType(type: .task("Task with Due Date Range"),
                                                             tags: [Tag(.due, payload: "2025-06-01 06:01 thru 2025-06-30 13:00")])

            // MARK: Tasks with Tags and Text
            static var taskWithTagAndText: TMType = TMType(type: .task("Task"),
                                                           tags: [Tag("tag")],
                                                           children: [TMType(tabLevel: 1,
                                                                             type: .text("Text 1")),
                                                                      TMType(tabLevel: 1,
                                                                             type: .text("Text 2")),
                                                                      TMType(tabLevel: 1,
                                                                             type: .text("Text 3"))])
            static var taskWithDueDateAndText: TMType = TMType(type: .task("Task with Due Date"),
                                                               tags: [Tag(.due, payload: "2025-06-01")],
                                                               children: [TMType(tabLevel: 1,
                                                                                 type: .text("Text 1")),
                                                                          TMType(tabLevel: 1,
                                                                                 type: .text("Text 2")),
                                                                          TMType(tabLevel: 1,
                                                                                 type: .text("Text 3"))])
            static var taskWithDueDateTimeAndText: TMType = TMType(type: .task("Task with Due Date/Time"),
                                                                   tags: [Tag(.due, payload: "2025-06-01 06:01")],
                                                                   children: [TMType(tabLevel: 1,
                                                                                     type: .text("Text 1")),
                                                                              TMType(tabLevel: 1,
                                                                                     type: .text("Text 2")),
                                                                              TMType(tabLevel: 1,
                                                                                     type: .text("Text 3"))])
            static var taskWithDueDateTimeRangeAndText: TMType = TMType(type: .task("Task with Due Date/Time Range"),
                                                                        tags: [Tag(.due, payload: "2025-06-01 06:01-13:00")],
                                                                        children: [TMType(tabLevel: 1,
                                                                                          type: .text("Text 1")),
                                                                                   TMType(tabLevel: 1,
                                                                                          type: .text("Text 2")),
                                                                                   TMType(tabLevel: 1,
                                                                                          type: .text("Text 3"))])
            static var taskWithDueDateRangeAndText: TMType = TMType(type: .task("Task with Due Date Range"),
                                                                    tags: [Tag(.due, payload: "2025-06-01 06:01 thru 2025-06-30 13:00")],
                                                                    children: [TMType(tabLevel: 1,
                                                                                      type: .text("Text 1")),
                                                                               TMType(tabLevel: 1,
                                                                                      type: .text("Text 2")),
                                                                               TMType(tabLevel: 1,
                                                                                      type: .text("Text 3"))])
        }

        enum Projects {
            static var projectWithTask: TMType {
                TMType(type: .project("Project with Task with Due Date"),
                children: [
                    TMType(tabLevel: 1, type: .task("Task with Due Date"),
                           tags: [Tag(.due, payload: "2025-06-01")],
                          children: [
                            TMType(tabLevel: 2, type: .text("Text")),
                            TMType(tabLevel: 2, type: .text("SubText"))
                          ])
                ])
            }
            static var projectWithTasks: TMType {
                TMType(type: .project("Project with Task with Due Date"),
                       children: [
                        TMType(tabLevel: 1, type: .task("Task with Due Date"),
                               tags: [Tag(.due, payload: "2025-06-01")],
                               children: [
                                TMType(tabLevel: 2, type: .text("Text")),
                                TMType(tabLevel: 2, type: .text("SubText"))
                               ]),
                        TMType(tabLevel: 1, type: .task("Task with Due Date/Time"),
                               tags: [Tag(.due, payload: "2025-06-01 06:01")],
                               children: [
                                TMType(tabLevel: 2, type: .text("Text")),
                                TMType(tabLevel: 2, type: .text("SubText"))
                               ]),
                        TMType(tabLevel: 1, type: .task("Task with Due Date/Time Range"),
                               tags: [Tag(.due, payload: "2025-06-01 06:01-13:00")],
                               children: [
                                TMType(tabLevel: 2, type: .text("Text")),
                                TMType(tabLevel: 2, type: .text("SubText"))
                               ]),
                        TMType(tabLevel: 1, type: .task("Task with Due Date Range"),
                               tags: [Tag(.due, payload: "2025-06-01 06:01 thru 2025-06-30 13:00")],
                               children: [
                                TMType(tabLevel: 2, type: .text("Text")),
                                TMType(tabLevel: 2, type: .text("SubText"))
                               ])
                       ])
            }
        }
    }
}

#endif

