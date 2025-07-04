//
//  TagView.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/9/25.
//

import SwiftUI

// Here we convert the view from the previous code into a ViewModel with Combine.
struct TagView: View {
    // StateBindingViewModel leverages a specific equatable state model.
    struct TagState: Equatable {
        var editMode: EditMode
        var tag: Tag {
            didSet {
                text = tag.toString
            }
        }
        var text: String

        init(_ tag: Tag, editMode: EditMode = .inactive) {
            self.editMode = editMode
            self.tag = tag
            self.text = tag.toString
        }
    }

    // The new version of the view model leverages the `StateBindingViewModel`.
    final class ViewModel: StateBindingViewModel<TagState> {
        init(_ tag: Tag,
             editMode: EditMode = .inactive) {
            super.init(initialState: .init(tag, editMode: editMode))
        }

        var isEditing: Bool {
            state.editMode == .active
        }

        func convertTagIfValid(from string: String) {
            guard let convertedTag = string.toTag() else {
                update(\.text, to: state.tag.toString)
                update(\.editMode, to: .inactive)
                return
            }
            update(\.tag, to: convertedTag)
            update(\.editMode, to: .inactive)
        }
    }

    @ScaledMetric(relativeTo: .caption) private var scaledPadding = Spacing.default
    @StateObject
    var viewModel: ViewModel

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
        textTag(tag: viewModel.state.tag)
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
                viewModel.update(\.editMode, to: .active)
            }
    }

    var textFieldTag: some View {
        TextField(Constants.Tag.placeholder,
                  text: viewModel.binding(\.text),
                  axis: .vertical)
        .textFieldStyle(.plain)
        .multilineTextAlignment(.center)
        .onSubmit {
            viewModel.convertTagIfValid(from: viewModel.state.text)
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
