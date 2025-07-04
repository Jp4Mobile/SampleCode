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
        // MARK: Properties
        /// The edit state of the view
        var editMode: EditMode
        /// The actual tag
        private(set) var tag: Tag {
            didSet {
                text = tag.toString
            }
        }
        /// The entered text to be converted into the tag
        var text: String

        // MARK: Computed Properties
        var isEditing: Bool {
            editMode == .active
        }

        // MARK: Initializer
        init(_ tag: Tag, editMode: EditMode = .inactive) {
            self.editMode = editMode
            self.tag = tag
            self.text = tag.toString
        }

        // MARK: Helper Function
        /// Converts into a tag, if valid
        /// - parameter from: the text to attempt to convert
        func convertTagIfValid(from string: String) {
            guard let convertedTag = string.toTag() else {
                self.text = tag.toString
                return
            }
            self.tag = convertedTag
            self.editMode = .inactive
        }
    }

    @ScaledMetric(relativeTo: .caption) private var scaledPadding = Spacing.default
    @State var viewModel: ViewModel

    var body: some View {
        if viewModel.isEditing {
            tagEditView
        } else {
            tagView
        }
    }
}

extension TagView {
    func tagView(tag: Tag) -> Text {
        guard let payload = tag.payload else {
            return Text("@\(tag.tag)")
        }

        return Text("@\(tag.tag)(**\(payload)**)")
    }

    var tagView: some View {
        tagView(tag: viewModel.tag)
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

    var tagEditView: some View {
        TextField(Constants.Tag.placeholder,
                  text: $viewModel.text,
                  axis: .vertical)
        .textFieldStyle(.plain)
        .multilineTextAlignment(.center)
        .onSubmit {
            viewModel.convertTagIfValid(from: viewModel.text)
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
