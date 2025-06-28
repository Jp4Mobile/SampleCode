//
//  TMTypeInitializers.swift
//  TaskManager
//
//  Created by Jp LaFond on 11/21/24.
//

import Foundation

extension TMType {
    /// Initializer from a Data object
    init?(from data: Data?) {
        guard let data,
              let string = String(data: data, encoding: .utf8) else { return nil }

        self.init(from: string)
    }

    /// Initializer from a String object
    init?(from string: String?) {
        nil
    }

    static func parse(string: String) -> [TMType] {
        // Keep empty strings, as we may want the placeholders
        let lines = string.split(separator: "\n",
                                 omittingEmptySubsequences: false)
        var models: [TMType] = []
        
        for line in lines {
            if let model = line.toTMType() {
                models.append(model)
            } else {
                let model = TMType(tabLevel: 0, type: .text(String(line)))
                models.append(model)
            }
        }

        return models
    }

    static func normalize(_ models: [TMType]) -> [TMType] {
        guard !models.isEmpty else { return models }

        var updatedList: [TMType] = []

        models.forEach { model in

            switch decideHowToHandle(model: model, into: updatedList) {
            case .appendToList(let updatedModel):
                updatedList.append(updatedModel)
            case .replaceInList(original: let original, replacement: let replacement):
                if let index = updatedList.lastIndex(of: original) {
                    updatedList[index] = replacement
                } else {
                    // We didn't find it, as expect, fall back to append
                    updatedList.append(model)
                }
            }
        }

        return updatedList
    }

    static func decideHowToHandle(model: TMType, into list: [TMType]) -> Choice {
        guard let lastInList = list.last else {
            // If the list is empty, we just append to the list
            return .appendToList(model)
        }

        guard model.tabLevel > lastInList.tabLevel else {
            // If it's the same as the tabLevels in the list, we just append
            // The other edge case is that the list tabLevel is higher and they reset the baseline, either way, we just append and start the list over.
            return .appendToList(model)
        }

        var bottomToAppend: TMType
        var parentOfBottom: TMType

        if let lastChildWithSameTabLevel = lastInList.lastChild(with: model.tabLevel),
           let parentOfLastChild = lastInList.parent(of: lastChildWithSameTabLevel) {
            // We already had an item with the same tab level.
            if let grandParentOfLastChild = lastInList.parent(of: parentOfLastChild) {
                bottomToAppend = parentOfLastChild
                parentOfBottom = grandParentOfLastChild
            } else {
                // We don't have a grandparent, so we just replace the proper element in the list and we're done.
                var updatedParent = parentOfLastChild
                updatedParent.append(child: model)
                return .replaceInList(original: parentOfLastChild, replacement: updatedParent)
            }
        } else if let lastChild = lastInList.lastChild(),
                  let parentOfLastChild = lastInList.parent(of: lastChild),
                  lastChild.children.isEmpty {
            // This is a new tab level and the lastChild, has no children, so we can append there.
            bottomToAppend = lastChild
            parentOfBottom = parentOfLastChild
        } else {
            // Fall back to append to the last model.
            var updatedLast = lastInList
            updatedLast.append(child: model)
            
            return .replaceInList(original: lastInList, replacement: updatedLast)
        }

        // Now that we know where we're appending and their parent
        var updatedBottom = bottomToAppend
        updatedBottom.append(child: model)

        var updatedParent = parentOfBottom
        updatedParent.replace(child: bottomToAppend, with: updatedBottom)

        // Walk our way back up
        var childToSearch = parentOfBottom
        while let parent = lastInList.parent(of: childToSearch) {
            // Replace that parent
            var updatedParentToReplace = parent
            updatedParentToReplace.replace(child: childToSearch, with: updatedParent)

            // Set up the search for the next iteration
            childToSearch = parent
            updatedParent = updatedParentToReplace
        }

        return .replaceInList(original: lastInList, replacement: updatedParent)
    }

    enum Choice: Equatable {
        case appendToList(TMType)
        case replaceInList(original: TMType, replacement: TMType)
    }
}
