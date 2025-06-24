//
//  TagView.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/9/25.
//

import SwiftUI

// Here we convert the view from the previous code into a ViewModel.
struct TagView: View {
    @Observable
    class ViewModel {
        // Properties
        var editMode: EditMode
        private(set) var tag: Tag {
            didSet {
                textTag = tag.toString
            }
        }
        var textTag: String

        var isEditing: Bool {
            editMode == .active
        }

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
            self.editMode = .inactive
        }
    }

    @ScaledMetric(relativeTo: .caption) private var scaledPadding = Spacing.default
    @State var viewModel: ViewModel

    var body: some View {
        Group {
            if viewModel.isEditing {
                textFieldTag
            } else {
                textTag
            }
        }
    }
}

extension TagView {
    func textTag(tag: Tag) -> Text {
        guard let payload = tag.payload else {
            return Text("@\(tag.tag)")
        }

        return Text("@\(tag.tag)(**\(payload)**)")
    }

    var textTag: some View {
        textTag(tag: viewModel.tag)
            .font(.caption)
            .textScale(.secondary)
            .tint(Color.Tag.tint)
            .multilineTextAlignment(.trailing)
            .padding(scaledPadding)
            .overlay(
                Capsule()
                    .stroke(Color.Tag.border,
                            lineWidth: 1)
            )
            .onLongPressGesture {
                viewModel.editMode = .active
            }
    }

    var textFieldTag: some View {
        TextField(Constants.Tag.placeholder,
                  text: $viewModel.textTag,
                  axis: .vertical)
        .textFieldStyle(.plain)
        .multilineTextAlignment(.center)
        .onSubmit {
            viewModel.convertTagIfValid(from: viewModel.textTag)
        }
        .font(.caption)
        .textScale(.secondary)
        .tint(Color.Tag.tint)
        .padding(scaledPadding)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 1,
                                           dash: [2]))
                .foregroundColor(Color.Tag.border)
        )
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
        TagView(viewModel: .init(Constants.MockTag.test))
        TagView(viewModel: TagView.ViewModel(Constants.MockTag.dueDate))
        TagView(viewModel: TagView.ViewModel(Constants.MockTag.dueDateTime))
        TagView(viewModel: TagView.ViewModel(Constants.MockTag.dueDateTimeRange))
        TagView(viewModel: TagView.ViewModel(Constants.MockTag.dueDayRange))
    }
}
