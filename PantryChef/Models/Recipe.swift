//
//  Recipe.swift
//  PantryChef
//
//  Codable models for Spoonacular API responses
//

import Foundation

/// Represents a recipe returned from the Spoonacular findByIngredients endpoint
struct Recipe: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String
    let imageType: String?
    let usedIngredientCount: Int
    let missedIngredientCount: Int
    let usedIngredients: [RecipeIngredient]
    let missedIngredients: [RecipeIngredient]
    let unusedIngredients: [RecipeIngredient]?
    let likes: Int?

    /// Computed property to get a valid image URL
    var imageURL: URL? {
        URL(string: image)
    }
}

/// Represents an ingredient within a recipe
struct RecipeIngredient: Codable, Identifiable {
    let id: Int
    let amount: Double
    let unit: String
    let unitLong: String?
    let unitShort: String?
    let aisle: String?
    let name: String
    let original: String
    let originalName: String?
    let meta: [String]?
    let image: String?

    /// Computed property for display-friendly amount string
    var displayAmount: String {
        let formattedAmount = amount.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", amount)
            : String(format: "%.1f", amount)
        return "\(formattedAmount) \(unit)"
    }

    /// Computed property to get ingredient image URL
    var imageURL: URL? {
        guard let image = image else { return nil }
        // Spoonacular ingredient images need the CDN prefix
        if image.hasPrefix("http") {
            return URL(string: image)
        }
        return URL(string: "https://spoonacular.com/cdn/ingredients_100x100/\(image)")
    }
}

/// Container for recognized ingredients from Vision processing
struct RecognizedIngredients {
    let ingredients: [String]
    let confidence: Double

    /// Comma-separated string for API request
    var queryString: String {
        ingredients.joined(separator: ",")
    }
}
