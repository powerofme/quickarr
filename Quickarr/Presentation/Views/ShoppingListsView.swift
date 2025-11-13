//
//  ShoppingListsView.swift
//  Quickarr
//
//  Shopping lists overview with adaptive layout
//

import SwiftUI

struct ShoppingListsView: View {
    @State private var viewModel: ShoppingListsViewModel
    @State private var showingAddList = false
    @State private var newListName = ""
    
    init(dependencies: DependencyContainer) {
        let vm = ShoppingListsViewModel(
            listRepository: dependencies.listRepository,
            createListUseCase: dependencies.createListUseCase,
            getActiveSessionsUseCase: dependencies.getActiveSessionsUseCase
        )
        _viewModel = State(initialValue: vm)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.lists.isEmpty {
                    ProgressView()
                } else if viewModel.lists.isEmpty {
                    emptyState
                } else {
                    listContent
                }
            }
            .navigationTitle("Shopping Lists")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddList = true
                    } label: {
                        Label("New List", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddList) {
                addListSheet
            }
            .task {
                await viewModel.loadLists()
            }
            .refreshable {
                await viewModel.loadLists()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("No Shopping Lists")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create your first shopping list to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingAddList = true
            } label: {
                Label("Create List", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
    
    private var listContent: some View {
        List {
            ForEach(viewModel.lists) { list in
                NavigationLink(value: list) {
                    ShoppingListRow(
                        list: list,
                        activeSession: viewModel.activeSession(forListId: list.id)
                    )
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .padding(.vertical, 4)
                )
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let list = viewModel.lists[index]
                    Task {
                        await viewModel.deleteList(id: list.id)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: ShoppingList.self) { list in
            ListDetailView(list: list)
        }
    }
    
    private var addListSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("List Name", text: $newListName)
                        .textInputAutocapitalization(.words)
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddList = false
                        newListName = ""
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            await viewModel.createList(name: newListName)
                            showingAddList = false
                            newListName = ""
                        }
                    }
                    .disabled(newListName.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct ShoppingListRow: View {
    let list: ShoppingList
    let activeSession: ShoppingSession?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(list.name)
                    .font(.headline)
                
                Spacer()
                
                if activeSession != nil {
                    Image(systemName: "cart.fill")
                        .foregroundStyle(.blue)
                        .font(.subheadline)
                }
            }
            
            HStack(spacing: 16) {
                Label("\(list.totalItems)", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if list.pickedCount > 0 {
                    Label("\(list.pickedCount)", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                
                if list.unavailableCount > 0 {
                    Label("\(list.unavailableCount)", systemImage: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                
                if list.substitutedCount > 0 {
                    Label("\(list.substitutedCount)", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let container = try! ModelContainer(for: ShoppingListModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let dependencies = DependencyContainer(modelContainer: container)
    return ShoppingListsView(dependencies: dependencies)
}
