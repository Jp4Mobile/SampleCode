//
//  TagView.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/9/25.
//

import SwiftUI

struct TagView: View {
    @Observable
    class ViewModel {
        var editMode: EditMode
        private(set) var tag: Tag
        var textTag: String

        init(_ tag: Tag, editMode: EditMode = .inactive) {
            self.editMode = editMode
            self.tag = tag
            self.textTag = tag.toString
        }

        func convertTagIfValid(from string: String) {
            guard let convertedTag = string.toTag() else {
                self.textTag = tag.toString
                return
            }
            self.tag = convertedTag
            self.textTag = convertedTag.toString
        }
    }

    @State private var editMode: EditMode = .inactive
    @ScaledMetric(relativeTo: .caption) private var scaledPadding = Spacing.default

    @State var viewModel: ViewModel

    var body: some View {
        Group {
            if viewModel.editMode == .active {
                TextField(Constants.Tag.placeholder,
                          text: $viewModel.textTag,
                          axis: .vertical)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        viewModel.editMode = .inactive
                        viewModel.convertTagIfValid(from: viewModel.textTag)
                    }
            } else {
                if let payload = viewModel.tag.payload {
                    Text("@\(viewModel.tag.tag)(**\(payload)**)")
                } else {
                    Text("@\(viewModel.tag.tag)")
                }
            }
        }
        .font(.caption)
        .textScale(.secondary)
        .tint(Color.Tag.tint)
        .multilineTextAlignment(.trailing)
        .padding(scaledPadding)
        .overlay(
            Group {
                if viewModel.editMode == .active {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style: StrokeStyle(lineWidth: 1,
                                                   dash: [2]))
                        .foregroundColor(Color.Tag.border)
                } else {
                    Capsule()
                        .stroke(Color.Tag.border,
                                lineWidth: 1)
                }
            }
        )
        .onLongPressGesture {
            viewModel.editMode = .active
        }
    }
}

extension Constants {
    struct MockTag {
        static let test = TaskManager.Tag("test")
        static let dueDate = TaskManager.Tag(.due,
                                             payload: "2025-05-11")
        static let dueDateTime = TaskManager.Tag(.due,
                                                 payload: "2025-05-11 10:00")
        static let dueDateTimeRange = TaskManager.Tag(.due,
                                                      payload: "2025-05-11 10:00-13:00")
        static let dueDayRange = TaskManager.Tag(.due,
                                                 payload: "2025-05-11 10:00 thru 2025-05-31 23:59")
    }
}

#Preview {
    ScrollView {
        TagView(viewModel: TagView.ViewModel(Constants.MockTag.test))
        TagView(viewModel: TagView.ViewModel(Constants.MockTag.dueDate))
        TagView(viewModel: TagView.ViewModel(Constants.MockTag.dueDateTime))
        TagView(viewModel: TagView.ViewModel(Constants.MockTag.dueDateTimeRange))
        TagView(viewModel: TagView.ViewModel(Constants.MockTag.dueDayRange))
    }
}
