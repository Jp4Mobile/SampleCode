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
}

extension Image {
    struct Tab {
        struct Icon {
            static let tasks = Image("list.bullet.circle")
            static let text = Image("list.bullet.circle.fill")
            static let settings = Image("gearshape.circle.fill")
        }
    }
}
