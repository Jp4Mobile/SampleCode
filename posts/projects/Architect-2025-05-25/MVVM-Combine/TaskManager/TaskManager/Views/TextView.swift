//
//  TextView.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/19/25.
//

import SwiftUI

struct TextView: View {
    struct TaskState: Equatable {
        var type: TMType
        var text: String

        var errorToPresent: String?
    }

    final class ViewModel: StateBindingViewModel<TaskState> {

        func update(_ text: String) {
            let types = TMType.parse(string: text)
            guard !text.isEmpty,
                  !types.isEmpty else {
                update(\.errorToPresent, to: "Unable to convert <\(text)>")
                update(\.text, to: state.type.toString)
                return
            }
            let updatedTypes = TMType.normalize(types)
            guard let firstType = updatedTypes.first else {
                update(\.errorToPresent, to: "Unable to convert <\(text)>")
                update(\.text, to: state.type.toString)
                return
            }

            if updatedTypes.count > 1 {
                update(\.errorToPresent, to: "Only the first converted type model is saved. You may need to change indentation to keep them under the proper project.")
            } else {
                update(\.errorToPresent, to: nil)
            }

            update(\.type, to: firstType)
            update(\.text, to: firstType.toString)
        }

        func doneButtonTapped() {
            self.update(state.text)
        }
    }

    @StateObject
    var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if let error = viewModel.state.errorToPresent {
                    Text(error)
                        .font(.headline)
                        .foregroundStyle(.red)
                    Spacer(minLength: Spacing.default)
                }
                TextEditor(text: viewModel.binding(\.text))
                    .padding(Spacing.default)
                    .onSubmit {
                        viewModel.update(viewModel.state.text)
                    }
            }
            .navigationTitle(Constants.Text.title)
            .toolbar {
                ToolbarItem {
                    Button {
                        viewModel.doneButtonTapped()
                    } label: {
                        Text(Constants.Text.saveButtonTitle)
                    }
                }
            }
        }
    }
}

extension TextView.ViewModel {
    convenience init(from type: TMType) {
        self.init(initialState: .init(type: type,
                                      text: type.toString))
    }

    func addError(_ error: String) {
        self.update(\.errorToPresent, to: error)
    }
}

#Preview {
    TextView(viewModel: .init(from: TMType.Mock.Projects.projectWithTasks))
}
