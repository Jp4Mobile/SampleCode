//
//  StringExtensions.swift
//  TaskManager
//
//  Created by Jp LaFond on 11/22/24.
//

import RegexBuilder

extension String {
    // MARK: - Specific Search Functionality
    // MARK: Helper Functions
    private func isWhitespaceOnly() -> Bool {
        let trimmed = trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty
    }

    private func indentLevel(of string: String?) -> Int {
        guard let string,
              string.isWhitespaceOnly() else { return 0 }

        return string.count
    }

    private func indentLevel(of substring: Substring?) -> Int {
        guard let substring else { return 0 }

        return substring.count
    }

    private func isTask(_ substring: Substring?) -> Bool {
        guard let substring else { return false }

        return substring.contains("-")
    }

    private func isProject(_ substring: Substring?) -> Bool {
        guard let substring else { return false }

        return substring.contains(":")
    }

    // MARK: TMType Conversion
    /// Convert from String to a TMType entity
    func toTMType() -> TMType? {
        // Set up references
        let indentRef = Reference(Substring.self)
        let hyphenRef = Reference(Substring.self)
        let colonRef = Reference(Substring.self)
        let textRef = Reference(Substring.self)

        // Set up the regex
        let normalizeText = Regex {
            Capture(as: textRef) {
                OneOrMore(.anyNonNewline, .reluctant)
            }
            ZeroOrMore(.whitespace)
            // We know there's a tag.
            "@"
            // And anything after to fill out the line.
            ZeroOrMore(.anyNonNewline)
        }
        let tmTypeSearch = Regex {
            // Initial Indent
            Capture(as: indentRef) {
                ZeroOrMore(.whitespace)
            }
            // Whether or not it's a task
            Capture(as: hyphenRef) {
                Optionally {
                    "-"
                }
            }
            ZeroOrMore(.whitespace)
            // Text of the element (including tags)
            Capture(as: textRef) {
                OneOrMore(
                    ChoiceOf {
                        // All of the valid characters for the text area.
                        CharacterClass(.anyNonNewline)
                    }, .reluctant
                )
            }
            // Whether it's a project or not
            Capture(as: colonRef) {
                Optionally {
                    ":"
                }
            }
        }
        // Parse the results
        do {
            guard let result = try tmTypeSearch.wholeMatch(in: self) else { return nil }

            let indentationLevel = indentLevel(of: result[indentRef])
            let isTask = isTask(result[hyphenRef])
            let isProject = isProject(result[colonRef])

            var text = result[textRef]

            var tags: [Tag] = []

            if text.contains("@") {
                tags = text.extractTags()

                // We need to normalize the text to remove the tags
                let normalizedResult = try normalizeText.wholeMatch(in: text)
                if let normalizedResult {
                    let normalizedText = normalizedResult[textRef]
                    text = normalizedText
                }
            }

            let tpType: TPType = {
                let name = String(text)
                if isProject {
                    return .project(name)
                } else if isTask {
                    return .task(name)
                } else {
                    return .text(name)
                }
            }()

            // Edge case for whitespace only levels
            if case .text(let textToCheck) = tpType,
               textToCheck.isWhitespaceOnly() {
                let updatedIndentationLevel = indentationLevel + indentLevel(of: textToCheck)

                return TMType(tabLevel: UInt(updatedIndentationLevel),
                              type: .text(""),
                              tags: tags)
            }

            return TMType(tabLevel: UInt(indentationLevel),
                          type: tpType,
                          tags: tags)
        } catch {
            print("*Jp* \(self)::\(#function)[\(#line)] <\(error)>")
            return nil
        }
    }
}

extension Substring {
    // MARK: - Specific Search Functionality
    /// Extract the tags out of a text substring from the type
    func extractTags() -> [Tag] {
        guard self.contains("@") else { return [] }

        // Set up references
        let textRef = Reference(Substring.self)
        let payloadRef = Reference(Substring.self)

        // Set up the regexes
        // ie; @<tag>(<payload>)
        let payloadSearch = Regex {
            "@"
            Capture(as: textRef) {
                OneOrMore(.word)
            }
            "("
            Capture(as: payloadRef) {
                OneOrMore(.anyNonNewline, .reluctant)
            }
            ")"
            ZeroOrMore(.whitespace)
        }
        // ie; @<tag>
        let tagSearch = Regex {
            "@"
            Capture(as: textRef) {
                OneOrMore(.word)
            }
            ZeroOrMore(.whitespace)
        }
        // Do the searching...
        var results: [Tag] = []

        // Get the tags
        let tagResults = self.matches(of: tagSearch)
        if !tagResults.isEmpty {
            tagResults.forEach { result in
                let tag = String(result[textRef])
                results.append(.tag(tag))
            }
        }
        let payloadResults = self.matches(of: payloadSearch)
        if !payloadResults.isEmpty {
            payloadResults.forEach { result in
                let payload = String(result[payloadRef])
                let tag = String(result[textRef])
                let payloadTag = Tag.payloadTag(tag, payload)
                // Because of the nature of our tag search and our payload search, we have to replace the tag with the payload, if present.
                if let index = results.firstIndex(of: .tag(tag)) {
                    results.remove(at: index)
                    results.insert(payloadTag, at: index)
                } else {
                    results.append(payloadTag)
                }
            }
        }

        return results
    }

    func toTMType() -> TMType? {
        String(self).toTMType()
    }
}
