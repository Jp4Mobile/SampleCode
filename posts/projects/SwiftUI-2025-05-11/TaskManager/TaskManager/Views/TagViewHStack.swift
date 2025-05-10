//
//  TagViewHStack.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/9/25.
//

//
//  TagView.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/9/25.
//

import SwiftUI

struct TagViewHStack: View {
    let tag: Tag
    var body: some View {
        Group {
            if let payload = tag.payload {
                HStack(spacing: 0) {
                    Text("@\(tag.tag)(")
                        .font(.caption)
                    Text(payload)
                        .font(.caption.bold())
                    Text(")")
                        .font(.caption)
                }
            } else {
                Text("@\(tag.tag)")
            }
        }
        .tint(Color.Tag.tint)
        .padding(Spacing.default)
        .overlay(
            Capsule()
                .stroke(Color.Tag.border,
                        lineWidth: 1)
        )
    }
}

#Preview {
    ScrollView {
        TagViewHStack(tag: Tag("test"))
        TagViewHStack(tag: Tag(.due,
                               payload: "2025-05-11"))
        TagViewHStack(tag: Tag(.due,
                               payload: "2025-05-11 10:00"))
        TagViewHStack(tag: Tag(.due,
                               payload: "2025-05-11 10:00-13:00"))
        TagViewHStack(tag: Tag(.due,
                               payload: "2025-05-11 10:00 thru 2025-05-31 23:59"))
    }
}
