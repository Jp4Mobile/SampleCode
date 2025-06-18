//
//  TagView.swift
//  TaskManager
//
//  Created by Jp LaFond on 6/16/25.
//

import Foundation
import SwiftUI

struct TagView: View {
    struct TagState: Equatable {
        var editMode: EditMode
        var tag: Tag {
            // Ensure that the textTag is always appropriately set.
            didSet {
                self.textTag = tag.toString
            }
        }
        var textTag: String

        init(_ tag: Tag, editMode: EditMode = .inactive) {
            self.editMode = editMode
            self.tag = tag
            self.textTag = tag.toString
        }
    }

    final class ViewModel: StateBindingViewModel<TagState> {
        init(_ tag: Tag, editMode: EditMode = .inactive) {
            super.init(initialState: .init(tag, editMode: editMode))
        }

        var isEditing: Bool {
            state.editMode == .active
        }

        func convertTagIfValid(from string: String) {
            guard let convertedTag = string.toTag() else {
                update(\.textTag, to: state.tag.toString)
                update(\.editMode, to: .inactive)
                return
            }
            update(\.tag, to: convertedTag)
            update(\.editMode, to: .inactive)
        }
    }

    // MARK: - Properties
    @StateObject
    var viewModel: ViewModel
    @ScaledMetric(relativeTo: .caption) private var scaledPadding = Spacing.default

    // MARK: - View Content
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
                  text: viewModel.binding(\.textTag),
                  axis: .vertical)
        .textFieldStyle(.plain)
        .multilineTextAlignment(.center)
        .onSubmit {
            viewModel.convertTagIfValid(from: viewModel.state.textTag)
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
        Spacer(minLength: 16)
        TagView(viewModel: .init(Constants.MockTag.dueDate))
        Spacer(minLength: 16)
        TagView(viewModel: .init(Constants.MockTag.dueDateTime))
        Spacer(minLength: 16)
        TagView(viewModel: .init(Constants.MockTag.dueDateTimeRange))
        Spacer(minLength: 16)
        TagView(viewModel: .init(Constants.MockTag.dueDayRange))
    }
}
