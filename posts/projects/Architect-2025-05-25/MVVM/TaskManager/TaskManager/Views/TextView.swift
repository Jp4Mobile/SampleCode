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
        private var type: TMType
        var text: String

        init(from type: TMType) {
            self.type = type
            text = type.toString
        }

        func updatedText(text: String) {
            // TODO: Present an error
            guard let type = text.toTMType() else { return }

            self.type = type
            self.text = type.toString
        }
    }

    @State var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        TextEditor(text: $viewModel.text)
            .padding(Spacing.default)
            .onSubmit {
                viewModel.updatedText(text: viewModel.text)
            }
    }
}

#Preview {
    TextView(viewModel: TextView.ViewModel(from: TMType.Mock.Projects.projectWithTasks))
}
