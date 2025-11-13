//
//  RemoteCategorySuggestionService.swift
//  Quickarr
//
//  Remote category suggestion service with caching
//

import Foundation

/// Remote category suggestion service implementation
public actor RemoteCategorySuggestionService: CategorySuggestionService {
    private let urlSession: URLSession
    private let baseURL: String
    private var memoryCache: [String: CachedCategory] = [:]
    private let cacheExpiration: TimeInterval = 3600 // 1 hour
    
    struct CachedCategory {
        let category: ItemCategory
        let timestamp: Date
        
        func isExpired(expiration: TimeInterval) -> Bool {
            Date().timeIntervalSince(timestamp) > expiration
        }
    }
    
    public init(
        urlSession: URLSession = .shared,
        baseURL: String = "https://api.example.com/category"
    ) {
        self.urlSession = urlSession
        self.baseURL = baseURL
    }
    
    public func suggestCategory(for itemName: String) async throws -> ItemCategory {
        let normalizedName = itemName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check memory cache
        if let cached = memoryCache[normalizedName],
           !cached.isExpired(expiration: cacheExpiration) {
            return cached.category
        }
        
        // Try to fetch from remote
        do {
            let category = try await fetchFromRemote(itemName: normalizedName)
            memoryCache[normalizedName] = CachedCategory(category: category, timestamp: Date())
            return category
        } catch {
            // Fallback: use simple heuristic
            let category = fallbackCategorization(itemName: normalizedName)
            memoryCache[normalizedName] = CachedCategory(category: category, timestamp: Date())
            return category
        }
    }
    
    public func suggestCategories(for itemNames: [String]) async throws -> [String: ItemCategory] {
        var results: [String: ItemCategory] = [:]
        
        // Process in parallel
        await withTaskGroup(of: (String, ItemCategory).self) { group in
            for name in itemNames {
                group.addTask {
                    let category = (try? await self.suggestCategory(for: name)) ?? .other
                    return (name, category)
                }
            }
            
            for await (name, category) in group {
                results[name] = category
            }
        }
        
        return results
    }
    
    // MARK: - Private
    
    private func fetchFromRemote(itemName: String) async throws -> ItemCategory {
        // In a real implementation, this would call an actual API
        // For now, throw an error to trigger fallback
        throw NSError(domain: "RemoteCategorySuggestionService", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Remote API not configured"
        ])
    }
    
    /// Simple heuristic-based categorization as fallback
    private func fallbackCategorization(itemName: String) -> ItemCategory {
        let name = itemName.lowercased()
        
        // Produce
        if name.contains("apple") || name.contains("banana") || name.contains("orange") ||
           name.contains("lettuce") || name.contains("tomato") || name.contains("carrot") ||
           name.contains("spinach") || name.contains("potato") || name.contains("onion") ||
           name.contains("fruit") || name.contains("vegetable") {
            return .produce
        }
        
        // Dairy
        if name.contains("milk") || name.contains("cheese") || name.contains("yogurt") ||
           name.contains("butter") || name.contains("cream") || name.contains("dairy") {
            return .dairy
        }
        
        // Meat
        if name.contains("chicken") || name.contains("beef") || name.contains("pork") ||
           name.contains("fish") || name.contains("salmon") || name.contains("turkey") ||
           name.contains("meat") || name.contains("steak") {
            return .meat
        }
        
        // Bakery
        if name.contains("bread") || name.contains("bagel") || name.contains("croissant") ||
           name.contains("muffin") || name.contains("cake") || name.contains("cookie") ||
           name.contains("pastry") {
            return .bakery
        }
        
        // Frozen
        if name.contains("frozen") || name.contains("ice cream") || name.contains("pizza") {
            return .frozen
        }
        
        // Beverages
        if name.contains("water") || name.contains("juice") || name.contains("soda") ||
           name.contains("coffee") || name.contains("tea") || name.contains("drink") ||
           name.contains("beer") || name.contains("wine") {
            return .beverages
        }
        
        // Snacks
        if name.contains("chips") || name.contains("crackers") || name.contains("candy") ||
           name.contains("chocolate") || name.contains("snack") || name.contains("popcorn") {
            return .snacks
        }
        
        // Household
        if name.contains("soap") || name.contains("detergent") || name.contains("paper") ||
           name.contains("towel") || name.contains("cleaner") || name.contains("trash") {
            return .household
        }
        
        // Health & Beauty
        if name.contains("shampoo") || name.contains("toothpaste") || name.contains("lotion") ||
           name.contains("deodorant") || name.contains("vitamin") {
            return .healthBeauty
        }
        
        // Pantry (common staples)
        if name.contains("rice") || name.contains("pasta") || name.contains("flour") ||
           name.contains("sugar") || name.contains("salt") || name.contains("oil") ||
           name.contains("sauce") || name.contains("cereal") {
            return .pantry
        }
        
        return .other
    }
}
