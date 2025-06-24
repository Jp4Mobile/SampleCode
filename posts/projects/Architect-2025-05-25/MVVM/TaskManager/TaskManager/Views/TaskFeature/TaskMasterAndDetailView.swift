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

struct TaskMasterAndDetailView: View {

    @Observable
    class ViewModel {
        var selectedItem: IdentifiedTMType?
        var responseType: DetailResponseType?
        var detailMode: DetailMode = .add
        var items: [IdentifiedTMType] = []

        init(selectedItem: IdentifiedTMType? = nil,
             responseType: DetailResponseType? = nil,
             detailMode: DetailMode = .add,
             items: [IdentifiedTMType] = []) {
            self.selectedItem = selectedItem
            self.responseType = responseType
            self.detailMode = detailMode
            self.items = items
        }

        // MARK: - Helper Methods
        func addItem(from text: String?) {
            let newItem = IdentifiedTMType(TMType(type: .text(text ?? "")))
            items.append(newItem)
            selectedItem = newItem
        }

        func select(item: IdentifiedTMType) {
            detailMode = .edit
            selectedItem = item
        }

        func process(_ response: DetailResponseType?) {
            guard let response else { return }

            // Clean up
            defer {
                selectedItem = nil
                detailMode = .add
            }

            switch response {
            case let .canceled(model):
                // Only delete, when we're adding and the user cancels
                guard detailMode == .add,
                      let index = items.firstIndex(where: { $0.id == model.id }) else { return }

                items.remove(at: index)
            case let .deleted(model):
                guard let index = items.firstIndex(where: { $0.id == model.id }) else { return }

                items.remove(at: index)
            case let .save(model):
                guard let index = items.firstIndex(where: { $0.id == model.id }) else { return }

                items[index] = model
            }
        }
    }

    @State var viewModel: ViewModel

    var body: some View {
        NavigationSplitView {
            TaskView(viewModel: $viewModel)
        } detail: {
            TaskDetailView(viewModel: $viewModel, localViewModel: .init())
        }
        .onChange(of: viewModel.responseType) {
            viewModel.process(viewModel.responseType)
        }
    }
}

#Preview {
    TaskMasterAndDetailView(viewModel: .init())
}
