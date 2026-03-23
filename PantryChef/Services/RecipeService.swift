//
//  RecipeService.swift
//  PantryChef
//
//  Networking layer for TheMealDB API (free, no API key required)
//

import Foundation

/// Service for fetching recipes from TheMealDB API
actor RecipeService {

    // MARK: - Configuration

    /// Base URL for TheMealDB API (free tier, no key needed)
    private let baseURL = "https://www.themealdb.com/api/json/v1/1"

    /// URLSession configured for API requests
    private let session: URLSession

    // MARK: - Initialization

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Public API

    /// Fetches recipes that can be made with the given ingredients
    /// - Parameter ingredients: Array of ingredient names
    /// - Returns: Array of Recipe objects sorted by ingredient match
    func findRecipes(byIngredients ingredients: [String]) async throws -> [Recipe] {
        guard !ingredients.isEmpty else {
            return []
        }

        // Search for meals using each ingredient and collect unique results
        var allMeals: [String: MealDBMeal] = [:]

        // Search by first few ingredients to get relevant results
        for ingredient in ingredients.prefix(3) {
            let meals = try await searchByIngredient(ingredient)
            for meal in meals {
                if allMeals[meal.idMeal] == nil {
                    // Fetch full details for each meal
                    if let fullMeal = try await getMealDetails(id: meal.idMeal) {
                        allMeals[meal.idMeal] = fullMeal
                    }
                }
            }
        }

        // Convert to Recipe objects and sort by number of matching ingredients
        let recipes = allMeals.values
            .map { Recipe.from(meal: $0, userIngredients: ingredients) }
            .sorted { $0.usedIngredientCount > $1.usedIngredientCount }

        return Array(recipes.prefix(15))
    }

    /// Searches for meals by main ingredient
    private func searchByIngredient(_ ingredient: String) async throws -> [MealDBMeal] {
        let urlString = "\(baseURL)/filter.php"

        guard var urlComponents = URLComponents(string: urlString) else {
            throw AppError.invalidURL
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "i", value: ingredient)
        ]

        guard let url = urlComponents.url else {
            throw AppError.invalidURL
        }

        let (data, response) = try await performRequest(url: url)
        try validateResponse(response)

        // Filter endpoint returns minimal data
        struct FilterResponse: Codable {
            let meals: [FilterMeal]?

            struct FilterMeal: Codable {
                let idMeal: String
                let strMeal: String
                let strMealThumb: String?
            }
        }

        let filterResponse = try JSONDecoder().decode(FilterResponse.self, from: data)

        // Convert to MealDBMeal with minimal data (we'll fetch full details later)
        return filterResponse.meals?.map { meal in
            MealDBMeal(
                idMeal: meal.idMeal,
                strMeal: meal.strMeal,
                strCategory: nil, strArea: nil, strInstructions: nil,
                strMealThumb: meal.strMealThumb, strYoutube: nil,
                strIngredient1: nil, strIngredient2: nil, strIngredient3: nil,
                strIngredient4: nil, strIngredient5: nil, strIngredient6: nil,
                strIngredient7: nil, strIngredient8: nil, strIngredient9: nil,
                strIngredient10: nil, strIngredient11: nil, strIngredient12: nil,
                strIngredient13: nil, strIngredient14: nil, strIngredient15: nil,
                strIngredient16: nil, strIngredient17: nil, strIngredient18: nil,
                strIngredient19: nil, strIngredient20: nil,
                strMeasure1: nil, strMeasure2: nil, strMeasure3: nil,
                strMeasure4: nil, strMeasure5: nil, strMeasure6: nil,
                strMeasure7: nil, strMeasure8: nil, strMeasure9: nil,
                strMeasure10: nil, strMeasure11: nil, strMeasure12: nil,
                strMeasure13: nil, strMeasure14: nil, strMeasure15: nil,
                strMeasure16: nil, strMeasure17: nil, strMeasure18: nil,
                strMeasure19: nil, strMeasure20: nil
            )
        } ?? []
    }

    /// Fetches full meal details by ID
    private func getMealDetails(id: String) async throws -> MealDBMeal? {
        let urlString = "\(baseURL)/lookup.php"

        guard var urlComponents = URLComponents(string: urlString) else {
            throw AppError.invalidURL
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "i", value: id)
        ]

        guard let url = urlComponents.url else {
            throw AppError.invalidURL
        }

        let (data, response) = try await performRequest(url: url)
        try validateResponse(response)

        let mealResponse = try JSONDecoder().decode(MealDBResponse.self, from: data)
        return mealResponse.meals?.first
    }

    /// Searches for meals by name (alternative search method)
    func searchByName(_ name: String) async throws -> [Recipe] {
        let urlString = "\(baseURL)/search.php"

        guard var urlComponents = URLComponents(string: urlString) else {
            throw AppError.invalidURL
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "s", value: name)
        ]

        guard let url = urlComponents.url else {
            throw AppError.invalidURL
        }

        let (data, response) = try await performRequest(url: url)
        try validateResponse(response)

        let mealResponse = try JSONDecoder().decode(MealDBResponse.self, from: data)

        return mealResponse.meals?.map { Recipe.from(meal: $0, userIngredients: []) } ?? []
    }

    // MARK: - Private Helpers

    private func performRequest(url: URL) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(from: url)
        } catch let error as URLError {
            throw AppError.networkError(error)
        } catch {
            throw AppError.unknown(error)
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 429:
            throw AppError.rateLimitExceeded
        default:
            throw AppError.invalidResponse
        }
    }
}
