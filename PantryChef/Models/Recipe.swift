//
//  Recipe.swift
//  PantryChef
//
//  Codable models for TheMealDB API responses (free, no API key required)
//

import Foundation

// MARK: - API Response Models

/// Response wrapper from TheMealDB API
struct MealDBResponse: Codable {
    let meals: [MealDBMeal]?
}

/// Raw meal data from TheMealDB API
struct MealDBMeal: Codable {
    let idMeal: String
    let strMeal: String
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let strMealThumb: String?
    let strYoutube: String?

    // Ingredients (TheMealDB uses numbered fields 1-20)
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strIngredient11: String?
    let strIngredient12: String?
    let strIngredient13: String?
    let strIngredient14: String?
    let strIngredient15: String?
    let strIngredient16: String?
    let strIngredient17: String?
    let strIngredient18: String?
    let strIngredient19: String?
    let strIngredient20: String?

    // Measurements
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
    let strMeasure11: String?
    let strMeasure12: String?
    let strMeasure13: String?
    let strMeasure14: String?
    let strMeasure15: String?
    let strMeasure16: String?
    let strMeasure17: String?
    let strMeasure18: String?
    let strMeasure19: String?
    let strMeasure20: String?

    /// Extracts all non-empty ingredients with their measurements
    var ingredientsList: [(name: String, measure: String)] {
        let ingredients = [
            strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5,
            strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10,
            strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15,
            strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        ]
        let measures = [
            strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5,
            strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10,
            strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15,
            strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
        ]

        var result: [(name: String, measure: String)] = []
        for (index, ingredient) in ingredients.enumerated() {
            if let name = ingredient, !name.trimmingCharacters(in: .whitespaces).isEmpty {
                let measure = measures[index]?.trimmingCharacters(in: .whitespaces) ?? ""
                result.append((name: name, measure: measure))
            }
        }
        return result
    }
}

// MARK: - App Models

/// Represents a recipe for display in the app
struct Recipe: Identifiable {
    let id: String
    let title: String
    let image: String
    let category: String?
    let area: String?
    let instructions: String?
    let youtubeURL: String?
    let usedIngredients: [RecipeIngredient]
    let missedIngredients: [RecipeIngredient]

    var usedIngredientCount: Int { usedIngredients.count }
    var missedIngredientCount: Int { missedIngredients.count }

    var imageURL: URL? {
        URL(string: image)
    }

    /// Creates a Recipe from MealDB data, categorizing ingredients as used/missing
    static func from(meal: MealDBMeal, userIngredients: [String]) -> Recipe {
        let userIngredientsLower = Set(userIngredients.map { $0.lowercased() })

        var usedIngredients: [RecipeIngredient] = []
        var missedIngredients: [RecipeIngredient] = []

        for (index, item) in meal.ingredientsList.enumerated() {
            let ingredient = RecipeIngredient(
                id: index,
                name: item.name,
                measure: item.measure
            )

            // Check if user has this ingredient (partial match)
            let isUsed = userIngredientsLower.contains { userIng in
                item.name.lowercased().contains(userIng) ||
                userIng.contains(item.name.lowercased())
            }

            if isUsed {
                usedIngredients.append(ingredient)
            } else {
                missedIngredients.append(ingredient)
            }
        }

        return Recipe(
            id: meal.idMeal,
            title: meal.strMeal,
            image: meal.strMealThumb ?? "",
            category: meal.strCategory,
            area: meal.strArea,
            instructions: meal.strInstructions,
            youtubeURL: meal.strYoutube,
            usedIngredients: usedIngredients,
            missedIngredients: missedIngredients
        )
    }
}

/// Represents an ingredient within a recipe
struct RecipeIngredient: Identifiable {
    let id: Int
    let name: String
    let measure: String

    var displayAmount: String {
        measure.isEmpty ? name : "\(measure) \(name)"
    }

    var imageURL: URL? {
        // TheMealDB provides ingredient images
        let formatted = name.lowercased().replacingOccurrences(of: " ", with: "_")
        return URL(string: "https://www.themealdb.com/images/ingredients/\(formatted)-Small.png")
    }
}

/// Container for recognized ingredients from Vision processing
struct RecognizedIngredients {
    let ingredients: [String]
    let confidence: Double

    var queryString: String {
        ingredients.joined(separator: ",")
    }
}
