//
//  iMessageSharingService.swift
//  Quickarr
//
//  iMessage sharing implementation using iOS share sheet
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// iMessage sharing service implementation
public actor iMessageSharingService: SharingService {
    
    public init() {}
    
    public func share(list: ShoppingList, via channel: SharingChannel) async throws {
        guard channel == .iMessage else {
            throw SharingServiceError.unsupportedChannel
        }
        
        let message = formatListMessage(list)
        await presentShareSheet(message: message)
    }
    
    public func sendUpdate(for session: ShoppingSession, list: ShoppingList, via channel: SharingChannel) async throws {
        guard channel == .iMessage else {
            throw SharingServiceError.unsupportedChannel
        }
        
        let message = formatUpdateMessage(session: session, list: list)
        await presentShareSheet(message: message)
    }
    
    // MARK: - Private
    
    private func formatListMessage(_ list: ShoppingList) -> String {
        var message = "📝 Shopping List: \(list.name)\n\n"
        
        let grouped = list.itemsByCategory
        let sortedCategories = grouped.keys.sorted { $0.displayName < $1.displayName }
        
        for category in sortedCategories {
            guard let items = grouped[category] else { continue }
            message += "\(category.displayName):\n"
            for item in items {
                message += "  • \(item.name)\n"
            }
            message += "\n"
        }
        
        message += "Total: \(list.totalItems) items"
        return message
    }
    
    private func formatUpdateMessage(session: ShoppingSession, list: ShoppingList) -> String {
        var message = "🛒 Shopping Update: \(list.name)\n\n"
        
        var picked: [ShoppingItem] = []
        var unavailable: [ShoppingItem] = []
        var substituted: [(ShoppingItem, SubstituteItem)] = []
        
        for item in list.items {
            switch item.status {
            case .picked:
                picked.append(item)
            case .unavailable:
                unavailable.append(item)
            case .substituted(let sub):
                substituted.append((item, sub))
            case .pending:
                break
            }
        }
        
        if !picked.isEmpty {
            message += "✅ Picked (\(picked.count)):\n"
            for item in picked {
                message += "  • \(item.name)\n"
            }
            message += "\n"
        }
        
        if !unavailable.isEmpty {
            message += "❌ Unavailable (\(unavailable.count)):\n"
            for item in unavailable {
                message += "  • \(item.name)\n"
            }
            message += "\n"
        }
        
        if !substituted.isEmpty {
            message += "🔄 Substituted (\(substituted.count)):\n"
            for (original, substitute) in substituted {
                message += "  • \(original.name) → \(substitute.name)\n"
            }
            message += "\n"
        }
        
        let total = list.totalItems
        let completed = picked.count + unavailable.count + substituted.count
        message += "Progress: \(completed)/\(total) items"
        
        return message
    }
    
    @MainActor
    private func presentShareSheet(message: String) {
        #if canImport(UIKit)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        
        // Prefer Messages app
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                print("Shared via \(activityType?.rawValue ?? "unknown")")
            }
        }
        
        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = rootViewController.view
            popover.sourceRect = CGRect(
                x: rootViewController.view.bounds.midX,
                y: rootViewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        rootViewController.present(activityVC, animated: true)
        #endif
    }
}

/// Errors for sharing service
public enum SharingServiceError: Error {
    case unsupportedChannel
    case sharingFailed(Error)
}
