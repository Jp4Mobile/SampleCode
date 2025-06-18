//
//  TMType.swift
//  TaskManager
//
//  Created by Jp LaFond on 11/20/24.
//

import Foundation

protocol FormattedTMType {
    var toString: String { get }
}

struct TMType: Codable, Equatable, FormattedTMType {
    private(set) var tabLevel: Int
    let type: TPType
    private(set) var tags: [Tag]
    private(set) var children: [TMType]

    init(tabLevel: UInt = 0,
         type: TPType,
         tags: [Tag] = [],
         children: [TMType] = []) {
        self.tabLevel = Int(tabLevel)
        self.type = type
        self.tags = tags
        self.children = children
    }

    // MARK: - Update Functionality
    mutating func set(indent: UInt) {
        self.tabLevel = Int(indent)
    }

    mutating func append(tag: Tag) {
        tags.append(tag)
    }

    mutating func append(child: TMType) {
        children.append(child)
    }

    mutating func replace(child: TMType, at index: Int) {
        guard index >= children.startIndex,
              index < children.endIndex else { return }

        children[index] = child
    }

    @discardableResult
    mutating func replace(child: TMType, with updatedChild: TMType) -> Bool {
        guard let index = children.firstIndex(of: child) else { return false }

        children[index] = updatedChild
        
        return true
    }

    // MARK: - Helper Functions for Searching
    func isEqualWithoutChildren(to other: TMType) -> Bool {
        tabLevel == other.tabLevel &&
        type == other.type &&
        tags == other.tags
    }

    func lastChild() -> TMType? {
        guard let lastChild = children.last else { return nil }

        return lastChild.lastChild() ?? lastChild
    }

    func lastChild(with tabLevel: Int) -> TMType? {
        guard let lastChild = children.last else { return nil }

        guard lastChild.tabLevel == tabLevel else {
            // Recursively look down
            return lastChild.lastChild(with: tabLevel)
        }

        return lastChild
    }

    func parent(of child: TMType) -> TMType? {
        if children.contains(child) {
            return self
        }

        // Recursively walk down the list
        return children.last?.parent(of: child)
    }

    // MARK: - FormattedTMType Functionality
    var toString: String {
        var result = String(repeating: "\t", count: tabLevel)
        result += type.toString
        tags.forEach { tag in
            if !result.isEmpty {
                result += " "
            }
            result += tag.toString
        }
        guard !children.isEmpty else { return result }

        children.forEach { child in
            if !result.isEmpty {
                result += "\n"
            }
            result += child.toString
        }
        return result
    }
}

extension TMType: Identifiable {
    var id: String {
        "[\(tabLevel)]\(type.toString)<\(tags.map{$0.toString}.joined(separator: ","))>"
    }
}

extension TMType: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension TMType: CustomDebugStringConvertible {
    var debugDescription: String {
        var result = "[\(tabLevel)] `\(type.toString)`"
        if !tags.isEmpty {
            result += " \(tags.map { $0.toString }.joined(separator: " ") )"
        }
        if !children.isEmpty {
            result += " children: <"
            result += children.map {
                String(repeating: "#", count: $0.tabLevel) + $0.debugDescription
            }.joined(separator: "; ")
            result += ">"
        }
        return result
    }
}
