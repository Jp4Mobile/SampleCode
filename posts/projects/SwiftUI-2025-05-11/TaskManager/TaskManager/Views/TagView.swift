//
//  TagView.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/9/25.
//

import SwiftUI

struct TagView: View {
    @ScaledMetric(relativeTo: .caption) private var scaledPadding = Spacing.default

    let tag: Tag
    var body: some View {
        Group {
            if let payload = tag.payload {
                Text("@\(tag.tag)(**\(payload)**)")
            } else {
                Text("@\(tag.tag)")
            }
        }
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
