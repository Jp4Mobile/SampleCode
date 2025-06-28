//
//  UIExtensions.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/9/25.
//

import SwiftUI

extension Color {
    struct Tag {
        static var `default`: Color {
            .black.opacity(0.75)
        }
        static var tint: Color {
            .black
        }
        static var border: Color {
            .gray
        }
    }

    struct Alert {
        static var alert: Color {
            .red.opacity(0.8)
        }
    }
}

extension Image {
    struct Tab {
        struct Icon {
            static let tasks = Image(systemName: "list.bullet.circle")
            static let text = Image(systemName: "pencil.circle.fill")
            static let settings = Image(systemName: "gearshape.circle.fill")
        }
    }

    struct Task {
        struct Icon {
            static let edit = Image(systemName: "pencil.circle")
        }
    }
}

extension Text {
    struct TextModifier: ViewModifier {
        let font: Font
        let textStyle: Font.TextStyle

        func body(content: Content) -> some View {
            @ScaledMetric(relativeTo: textStyle) var scaledPadding = Spacing.default

            return content
                .font(font)
                .textScale(.default)
                .multilineTextAlignment(.leading)
                .padding(scaledPadding)
        }
    }

    func fontMode(font: Font, textStyle: Font.TextStyle) -> some View {
        ModifiedContent(content: self,
        modifier: TextModifier(font: font, textStyle: textStyle))
    }

    func bodyMode() -> some View {
        fontMode(font: .body, textStyle: .body)
    }

    func captionMode() -> some View {
        fontMode(font: .caption, textStyle: .caption)
    }
}

extension TextField {
    struct TextFieldModifier: ViewModifier {
        let font: Font
        let textStyle: Font.TextStyle
        let borderColor: Color

        func body(content: Content) -> some View {
            @ScaledMetric(relativeTo: textStyle) var scaledPadding = Spacing.default

            return content
                .textFieldStyle(.plain)
                .font(font)
                .textScale(.default)
                .multilineTextAlignment(.leading)
                .padding(scaledPadding)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style: StrokeStyle(lineWidth: 1,
                                                   dash: [2, 1]))
                        .foregroundStyle(borderColor)
                )
        }
    }

    func fontMode(font: Font, textStyle: Font.TextStyle, borderColor: Color) -> some View {
        ModifiedContent(content: self,
                        modifier: TextFieldModifier(font: font,
                                                    textStyle: textStyle,
                                                    borderColor: borderColor))
    }

    func bodyMode(borderColor: Color = Color.Tag.border) -> some View {
        fontMode(font: .body, textStyle: .body, borderColor: borderColor)
    }

    func captionMode() -> some View {
        fontMode(font: .caption, textStyle: .caption, borderColor: Color.Tag.border)
    }
}
