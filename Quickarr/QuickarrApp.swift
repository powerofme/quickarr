//
//  QuickarrApp.swift
//  Quickarr
//
//  Universal iOS/iPadOS App
//

import SwiftUI
import SwiftData

@main
struct QuickarrApp: App {
    let modelContainer: ModelContainer
    let dependencies: DependencyContainer
    
    init() {
        do {
            let schema = Schema([
                ShoppingListModel.self,
                ShoppingSessionModel.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            dependencies = DependencyContainer(modelContainer: modelContainer)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ShoppingListsView(dependencies: dependencies)
                .environment(dependencies)
                .modelContainer(modelContainer)
        }
    }
}

