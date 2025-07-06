//
//  TaskMasterAndDetailView.swift
//  TaskManager
//
//  Created by Jp LaFond on 6/22/25.
//

import SwiftUI

struct IdentifiedTMType: Identifiable, Hashable {
    var id: String
    var type: TMType

    init(id: String = UUID().uuidString,
         _ type: TMType) {
        self.id = id
        self.type = type
    }

    mutating func update(_ newItem: TMType) {
        self.type = newItem
    }

    func duplicate(with newItem: TMType) -> Self {
        IdentifiedTMType(id: self.id,
                         newItem)
    }
}

enum DetailMode {
    case add
    case edit

    var title: String {
        switch self {
        case .add:
            return Constants.DetailView.addTitle
        case .edit:
            return Constants.DetailView.editTitle
        }
    }

    var isEditing: Bool {
        self == .edit
    }
}

enum DetailResponseType: Equatable {
    case canceled(IdentifiedTMType)
    case deleted(IdentifiedTMType)
    case save(IdentifiedTMType)

    var item: IdentifiedTMType {
        switch self {
        case let .canceled(model),
            let .deleted(model),
            let .save(model):
            return model
        }
    }
}

// Here we convert the view from the previous code into a ViewModel with Combine.
struct TaskMasterAndDetailView: View {
    // StateBindingViewModel leverages a specific equatable state model.
    struct TaskState: Equatable {
        var selectedItem: IdentifiedTMType?
        var responseType: DetailResponseType?
        var detailMode: DetailMode = .add
        var items: [IdentifiedTMType] = []
    }

    final class ViewModel: StateBindingViewModel<TaskState> {
        // MARK: - Helper Methods
        func addItem(from text: String?) {
            let newItem = IdentifiedTMType(TMType(type: .text(text ?? "")))
            let items = state.items + [newItem]
            update(\.items, to: items)
            update(\.selectedItem, to: newItem)
        }

        func select(item: IdentifiedTMType) {
            update(\.detailMode, to: .edit)
            update(\.selectedItem, to: item)
        }

        func process(_ response: DetailResponseType?) {
            guard let response else { return }

            // Clean up
            defer {
                update(\.selectedItem, to: nil)
                update(\.detailMode, to: .add)
            }

            switch response {
            case let .canceled(model):
                // Only delete, when we're adding and the user cancels
                guard state.detailMode == .add,
                      let index = state.items.firstIndex(where: { $0.id == model.id }) else { return }

                var items = state.items

                items.remove(at: index)
                update(\.items, to: items)
            case let .deleted(model):
                guard let index = state.items.firstIndex(where: { $0.id == model.id }) else { return }

                var items = state.items
                items.remove(at: index)
                update(\.items, to: items)
            case let .save(model):
                guard let index = state.items.firstIndex(where: { $0.id == model.id }) else { return }

                var items = state.items
                items[index] = model
                update(\.items, to: items)
            }
        }
    }

    @StateObject
    var viewModel: ViewModel

    var body: some View {
        NavigationSplitView {
            TaskView(viewModel: viewModel)
        } detail: {
            TaskDetailView(viewModel: viewModel, localViewModel: .init(initialState: .init()))
        }
        .onChange(of: viewModel.state.responseType) {
            viewModel.process(viewModel.state.responseType)
        }
    }
}

#Preview {
    TaskMasterAndDetailView(viewModel: .init(initialState: .init()))
}
