//
//  AdaptiveRootView.swift
//  Quickarr
//
//  Adaptive root view with split view for iPad
//

import SwiftUI

struct AdaptiveRootView: View {
    let dependencies: DependencyContainer
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .regular {
            // iPad: Use split view
            iPadLayout
        } else {
            // iPhone: Use standard navigation
            ShoppingListsView(dependencies: dependencies)
        }
    }
    
    private var iPadLayout: some View {
        NavigationSplitView {
            ShoppingListsView(dependencies: dependencies)
        } detail: {
            Text("Select a shopping list")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("iPhone") {
    let container = try! ModelContainer(for: ShoppingListModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let dependencies = DependencyContainer(modelContainer: container)
    return AdaptiveRootView(dependencies: dependencies)
        .environment(\.horizontalSizeClass, .compact)
}

#Preview("iPad") {
    let container = try! ModelContainer(for: ShoppingListModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let dependencies = DependencyContainer(modelContainer: container)
    return AdaptiveRootView(dependencies: dependencies)
        .environment(\.horizontalSizeClass, .regular)
}
