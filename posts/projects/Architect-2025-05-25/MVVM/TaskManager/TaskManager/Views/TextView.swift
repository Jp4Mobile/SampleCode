//
//  TextView.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/19/25.
//

import SwiftUI

struct TextView: View {
    @Observable
    class ViewModel {
        private var type: TMType {
            didSet {
                text = type.toString
            }
        }
        var text: String
        var errorMessage: String? {
            didSet {
                guard let errorMessage else { return }

                text = type.toString
            }
        }

        init(from type: TMType) {
            self.type = type
            text = type.toString
        }

        func updatedText(text: String) {
            let types = TMType.parse(string: text)
            guard !text.isEmpty,
                  !types.isEmpty else {
                errorMessage = "Unable to convert <\(text)>"
                return
            }
            let updatedTypes = TMType.normalize(types)
            guard let firstType = updatedTypes.first else {
                errorMessage = "Unable to convert <\(text)>"
                return
            }

            if updatedTypes.count > 1 {
                errorMessage = "Only the first converted type model is saved. You may need to change indentation to keep them under the proper project."
            } else {
                errorMessage = nil
            }

            type = firstType
        }
    }

    @State var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
                TextEditor(text: $viewModel.text)
                    .padding(Spacing.default)
                    .onSubmit {
                        viewModel.updatedText(text: viewModel.text)
                    }
            }
            .navigationTitle(Constants.TextView.title)
            .toolbar {
                ToolbarItem {
                    Button {
                        viewModel.updatedText(text: viewModel.text)
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
    TextView(viewModel: TextView.ViewModel(from: TMType.Mock.Projects.projectWithTasks))
}
