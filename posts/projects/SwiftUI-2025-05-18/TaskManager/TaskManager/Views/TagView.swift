//
//  TagView.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/9/25.
//

import SwiftUI

struct TagView: View {
    @State private var editMode: EditMode = .inactive
    @ScaledMetric(relativeTo: .caption) private var scaledPadding = Spacing.default

    @State var tag: Tag
    @State var tagPlaceHolder: String

    init(editMode: EditMode = .inactive,
         tag: Tag) {
        self.editMode = editMode
        self.tag = tag
        self.tagPlaceHolder = tag.toString
    }

    var body: some View {
        Group {
            if editMode == .active {
                TextField(Constants.Tag.placeholder,
                          text: $tagPlaceHolder,
                          axis: .vertical)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        editMode = .inactive
                        convertToTag(placeholder: tagPlaceHolder,
                                     baseTag: tag)
                    }
            } else {
                if let payload = tag.payload {
                    Text("@\(tag.tag)(**\(payload)**)")
                } else {
                    Text("@\(tag.tag)")
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
                if editMode == .active {
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
            editMode = .active
        }
    }

    func convertToTag(placeholder: String,
                      baseTag: Tag) {
        guard let convertedTag = placeholder.toTag() else {
            tagPlaceHolder = baseTag.toString
            return
        }

        self.tag = convertedTag
        self.tagPlaceHolder = convertedTag.toString
    }
}

#Preview {
    ScrollView {
        TagView(tag: Tag("test"))
        TagView(tag: Tag(.due,
                         payload: "2025-05-11"))
        TagView(tag: Tag(.due,
                         payload: "2025-05-11 10:00"))
        TagView(tag: Tag(.due,
                         payload: "2025-05-11 10:00-13:00"))
        TagView(tag: Tag(.due,
                         payload: "2025-05-11 10:00 thru 2025-05-31 23:59"))
    }
}
