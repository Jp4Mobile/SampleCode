//
//  TaskDetail.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/28/25.
//

import SwiftUI

struct
TaskDetailView: View {
    @Observable
    class ViewModel {
        var text = ""
        var shouldDismiss = false
        var errorMessage: String? {
            didSet {
                shouldDismiss = !(errorMessage != nil)
            }
        }

        func setup(from item: IdentifiedTMType?) {
            text = item?.type.toString ?? ""
            errorMessage = nil
        }
    }

    @Binding var viewModel: TaskMasterAndDetailView.ViewModel
    @State var localViewModel: ViewModel

    @Environment(\.dismiss) var dismiss

    func cancelTapped() {
        guard let selectedItem = viewModel.selectedItem else { return }

        viewModel.responseType = .canceled(selectedItem)
    }

    func deleteTapped() {
        guard let selectedItem = viewModel.selectedItem else { return }

        viewModel.responseType = .deleted(selectedItem)
    }

    func saveTapped() {
        guard let selectedItem = viewModel.selectedItem else { return }

        guard let newType = localViewModel.text.toTMType() else {
            localViewModel.errorMessage = "Unable to convert <\(localViewModel.text)>"
            localViewModel.text = selectedItem.type.toString
            return
        }

        let newItem = selectedItem.duplicate(with: newType)
        viewModel.responseType = .save(newItem)
    }

    var body: some View {
        VStack {
            if let errorText = localViewModel.errorMessage {
                Text(errorText)
                    .font(.title3)
                    .foregroundStyle(.red)
            }
            TextField(Constants.Task.placeholder,
                      text: $localViewModel.text,
                      axis: .vertical
            )
        }
        .navigationTitle(viewModel.detailMode.title)
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

            if viewModel.detailMode.isEditing {
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
        .onChange(of: localViewModel.shouldDismiss) {
            guard localViewModel.shouldDismiss else { return }

            dismiss()
        }
        .onAppear() {
            localViewModel.setup(from: viewModel.selectedItem)
        }
    }
}
