//
//  TaskView.swift
//  TaskManager
//
//  Created by Jp LaFond on 5/19/25.
//

import SwiftUI

struct TaskView: View {
    @StateObject var viewModel: TaskMasterAndDetailView.ViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.state.items,
                 id: \.id,
                 selection: viewModel.binding(\.selectedItem)) { item in
                HStack {
                    Text(item.type.type.toString)
                    Spacer()
                    Button {
                        viewModel.select(item: item)
                    } label: {
                        Image(systemName: "pencil.circle")
                    }
                    .buttonStyle(.borderless)
                    .tint(.green)
                }
                .onTapGesture {
                    viewModel.select(item: item)
                }
            }
            .navigationTitle(Constants.TaskView.title)
            .toolbar {
                Button {
                    viewModel.addItem(from: "")
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
