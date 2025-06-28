//
//  TaskDetail.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/28/25.
//

import SwiftUI

struct
TaskDetailView: View {
    struct LocalDetailState: Equatable {
        var text = ""
        var shouldDismiss = false
        var errorMessage: String? {
            didSet {
                shouldDismiss = !(errorMessage != nil)
            }
        }
    }

    final class ViewModel: StateBindingViewModel<LocalDetailState> {
        func setup(from item: IdentifiedTMType?) {
            update(\.text, to: item?.type.toString ?? "")
            update(\.errorMessage, to: nil)
        }
    }

    @StateObject
    var viewModel: TaskMasterAndDetailView.ViewModel
    @StateObject
    var localViewModel: ViewModel

    @Environment(\.dismiss) var dismiss

    func cancelTapped() {
        guard let selectedItem = viewModel.state.selectedItem else { return }

        viewModel.update(\.responseType, to: .canceled(selectedItem))
    }

    func deleteTapped() {
        guard let selectedItem = viewModel.state.selectedItem else { return }

        viewModel.update(\.responseType, to: .deleted(selectedItem))
    }

    func saveTapped() {
        guard let selectedItem = viewModel.state.selectedItem else { return }

        guard let newType = localViewModel.state.text.toTMType() else {
            localViewModel.update(\.errorMessage, to: "Unable to convert <\(localViewModel.state.text)>")
            localViewModel.update(\.text, to: selectedItem.type.toString)
            return
        }

        let newItem = selectedItem.duplicate(with: newType)
        viewModel.update(\.responseType, to: .save(newItem))
    }

    var body: some View {
        VStack {
            if let errorText = localViewModel.state.errorMessage {
                Text(errorText)
                    .font(.title3)
                    .foregroundStyle(.red)
            }
            TextField(Constants.Task.placeholder,
                      text: localViewModel.binding(\.text),
                      axis: .vertical
            )
        }
        .navigationTitle(viewModel.state.detailMode.title)
        .onSubmit {
            saveTapped()
        }
        .toolbar {
            ToolbarItem {
                Button(role: .destructive,
                       action: {
                    cancelTapped()
                },
                       label: {
                    Text(Constants.DetailView.cancelTitle)
                })
            }

            if viewModel.state.detailMode.isEditing {
                ToolbarItem {
                    Button {
                        deleteTapped()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .accessibilityLabel(Constants.DetailView.deleteTitle)
                }
            }
            ToolbarItem {
                Button {
                    saveTapped()
                } label: {
                    Text(Constants.DetailView.saveTitle)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onChange(of: localViewModel.state.shouldDismiss) {
            guard localViewModel.state.shouldDismiss else { return }

            dismiss()
        }
        .onAppear() {
            localViewModel.setup(from: viewModel.state.selectedItem)
        }
    }
}
