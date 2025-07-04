//
//  TextView.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/19/25.
//

import SwiftUI

// Here we convert the view from the previous code into a ViewModel with Combine.
struct TextView: View {
    // StateBindingViewModel leverages a specific equatable state model.
    struct TextState: Equatable {
        var type: TMType {
            didSet {
                text = type.toString
            }
        }
        var text: String
        var errorMessage: String? {
            didSet {
                guard errorMessage != nil else {
                    text = type.toString
                    return
                }
            }
        }

        init(type: TMType) {
            self.type = type
            self.text = type.toString
            self.errorMessage = nil
        }
    }

    final class ViewModel: StateBindingViewModel<TextState> {

        convenience init(type: TMType) {
            self.init(initialState: .init(type: type))
        }

        func updatedText(text: String) {
            let types = TMType.parse(string: text)
            guard !text.isEmpty,
                  !types.isEmpty else {
                let errorMessage = "Unable to convert <\(text)>"
                update(\.errorMessage, to: errorMessage)
                update(\.text, to: state.type.toString)
                return
            }
            let updatedTypes = TMType.normalize(types)
            guard let firstType = updatedTypes.first else {
                let errorMessage = "Unable to convert <\(text)>"
                update(\.errorMessage, to: errorMessage)
                update(\.text, to: state.type.toString)
                return
            }

            if updatedTypes.count > 1 {
                let errorMessage = "Only the first converted type model is saved. You may need to change indentation to keep them under the proper project."
                update(\.errorMessage, to: errorMessage)
                update(\.text, to: state.type.toString)
            } else {
                update(\.errorMessage, to: nil)
            }

            update(\.type, to: firstType)
        }
    }

    @StateObject
    var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if let errorMessage = viewModel.state.errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(Color.Alert.alert)
                }
                TextEditor(text: viewModel.binding(\.text))
                    .padding(Spacing.default)
                    .onSubmit {
                        viewModel.updatedText(text: viewModel.state.text)
                    }
            }
            .navigationTitle(Constants.TextView.title)
            .toolbar {
                ToolbarItem {
                    Button {
                        viewModel.updatedText(text: viewModel.state.text)
                    } label: {
                        Text(Constants.TextView.saveTitle)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

#Preview {
    TextView(viewModel: .init(initialState: .init(type: TMType.Mock.Projects.projectWithTasks)))
}
