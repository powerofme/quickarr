//
//  ListDetailView.swift
//  Quickarr
//
//  Shopping list detail with session management
//

import SwiftUI
import SwiftData

struct ListDetailView: View {
    @Environment(DependencyContainer.self) private var dependencies
    @State private var viewModel: ListDetailViewModel?
    let list: ShoppingList
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                listDetailContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            if viewModel == nil {
                viewModel = ListDetailViewModel(
                    list: list,
                    listRepository: dependencies.listRepository,
                    sessionRepository: dependencies.sessionRepository,
                    addItemUseCase: dependencies.addItemUseCase,
                    updateItemStatusUseCase: dependencies.updateItemStatusUseCase,
                    startSessionUseCase: dependencies.startSessionUseCase,
                    shareListUseCase: dependencies.shareListUseCase,
                    sendUpdateUseCase: dependencies.sendUpdateUseCase,
                    suggestCategoryUseCase: dependencies.suggestCategoryUseCase
                )
                await viewModel?.loadList()
            }
        }
    }
    
    @ViewBuilder
    private func listDetailContent(viewModel: ListDetailViewModel) -> some View {
        VStack(spacing: 0) {
            // Active session banner
            if viewModel.activeSession != nil {
                activeSessionBanner(viewModel: viewModel)
            }
            
            // Items list
            List {
                // Add item section
                Section {
                    addItemRow(viewModel: viewModel)
                }
                
                // Items grouped by category
                let grouped = viewModel.list.itemsByCategory
                let sortedCategories = grouped.keys.sorted { $0.displayName < $1.displayName }
                
                ForEach(sortedCategories, id: \.self) { category in
                    Section(header: categoryHeader(category)) {
                        if let items = grouped[category] {
                            ForEach(items) { item in
                                ItemRow(
                                    item: item,
                                    isInSession: viewModel.activeSession != nil,
                                    onStatusChange: { status in
                                        Task {
                                            await viewModel.updateItemStatus(itemId: item.id, status: status)
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            // Bottom toolbar
            bottomToolbar(viewModel: viewModel)
        }
        .navigationTitle(viewModel.list.name)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func activeSessionBanner(viewModel: ListDetailViewModel) -> some View {
        HStack {
            Image(systemName: "cart.fill")
                .foregroundStyle(.blue)
            
            Text("Shopping in progress")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Button("End") {
                Task {
                    await viewModel.endShopping()
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private func addItemRow(viewModel: ListDetailViewModel) -> some View {
        HStack {
            TextField("Add item", text: Binding(
                get: { viewModel.newItemName },
                set: { viewModel.newItemName = $0 }
            ))
            .textInputAutocapitalization(.words)
            .onSubmit {
                Task {
                    await viewModel.addItem()
                }
            }
            .onChange(of: viewModel.newItemName) { _, _ in
                Task {
                    await viewModel.suggestCategoryForNewItem()
                }
            }
            
            if !viewModel.newItemName.isEmpty {
                CategoryBadge(category: viewModel.newItemCategory)
                
                Button {
                    Task {
                        await viewModel.addItem()
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private func categoryHeader(_ category: ItemCategory) -> some View {
        HStack {
            Image(systemName: category.iconName)
            Text(category.displayName)
        }
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundStyle(.primary)
    }
    
    private func bottomToolbar(viewModel: ListDetailViewModel) -> some View {
        HStack(spacing: 16) {
            if viewModel.activeSession == nil {
                Button {
                    Task {
                        await viewModel.startShopping()
                    }
                } label: {
                    Label("Start Shopping", systemImage: "cart")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                Button {
                    Task {
                        await viewModel.sendUpdate()
                    }
                } label: {
                    Label("Send Update", systemImage: "paperplane.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            
            Button {
                Task {
                    await viewModel.shareList()
                }
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding()
        .background(.regularMaterial)
    }
}

struct ItemRow: View {
    let item: ShoppingItem
    let isInSession: Bool
    let onStatusChange: (ItemStatus) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                
                CategoryBadge(category: item.category)
            }
            
            Spacer()
            
            if isInSession {
                statusControls
            } else {
                statusIndicator
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusIndicator: some View {
        Image(systemName: item.status.iconName)
            .foregroundStyle(statusColor)
            .font(.title3)
    }
    
    private var statusControls: some View {
        Menu {
            Button {
                onStatusChange(.picked)
            } label: {
                Label("Picked", systemImage: "checkmark.circle.fill")
            }
            
            Button {
                onStatusChange(.unavailable)
            } label: {
                Label("Unavailable", systemImage: "xmark.circle.fill")
            }
            
            Button {
                // For simplicity, create a basic substitute
                let substitute = SubstituteItem(
                    name: "\(item.name) (alt)",
                    category: item.category
                )
                onStatusChange(.substituted(substitute))
            } label: {
                Label("Substitute", systemImage: "arrow.triangle.2.circlepath")
            }
        } label: {
            Image(systemName: item.status.iconName)
                .foregroundStyle(statusColor)
                .font(.title3)
        }
    }
    
    private var statusColor: Color {
        switch item.status {
        case .pending: return .gray
        case .picked: return .green
        case .unavailable: return .red
        case .substituted: return .orange
        }
    }
}

struct CategoryBadge: View {
    let category: ItemCategory
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.iconName)
            Text(category.displayName)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.2))
        .clipShape(Capsule())
    }
}

#Preview {
    let container = try! ModelContainer(for: ShoppingListModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let dependencies = DependencyContainer(modelContainer: container)
    
    var list = ShoppingList(name: "Groceries")
    list.addItem(ShoppingItem(name: "Milk", category: .dairy))
    list.addItem(ShoppingItem(name: "Apples", category: .produce))
    
    return NavigationStack {
        ListDetailView(list: list)
            .environment(dependencies)
    }
}
