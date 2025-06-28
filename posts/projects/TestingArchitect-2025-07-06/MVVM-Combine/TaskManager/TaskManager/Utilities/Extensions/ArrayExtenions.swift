//
//  ArrayExtenions.swift
//  TaskManager
//
//  Created by Jp LaFond on 11/23/24.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        guard index >= startIndex,
              index < endIndex else { return nil }
        return self[index]
    }
}
