//
//  SpoonacularService.swift
//  PantryChef
//
//  Networking layer for Spoonacular API using async/await
//

import Foundation

/// Service for fetching recipes from Spoonacular API
actor SpoonacularService {

    // MARK: - Configuration

    /// Base URL for Spoonacular API
    private let baseURL = "https://api.spoonacular.com"

    /// API Key - Replace with your own key from https://spoonacular.com/food-api
    /// In production, store this securely (e.g., Keychain or environment variable)
    private var apiKey: String {
        // Check for API key in environment or use placeholder
        ProcessInfo.processInfo.environment["SPOONACULAR_API_KEY"] ?? "YOUR_API_KEY_HERE"
    }

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
    /// - Parameters:
    ///   - ingredients: Array of ingredient names
    ///   - number: Maximum number of recipes to return (default: 10)
    ///   - ranking: 1 = maximize used ingredients, 2 = minimize missing ingredients
    /// - Returns: Array of Recipe objects
    func findRecipes(
        byIngredients ingredients: [String],
        number: Int = 10,
        ranking: Int = 1
    ) async throws -> [Recipe] {
        // Validate API key
        guard apiKey != "YOUR_API_KEY_HERE" else {
            throw AppError.apiKeyMissing
        }

        // Build URL
        let ingredientString = ingredients.joined(separator: ",+")
        let urlString = "\(baseURL)/recipes/findByIngredients"

        guard var urlComponents = URLComponents(string: urlString) else {
            throw AppError.invalidURL
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "ingredients", value: ingredientString),
            URLQueryItem(name: "number", value: String(number)),
            URLQueryItem(name: "ranking", value: String(ranking)),
            URLQueryItem(name: "ignorePantry", value: "true")
        ]

        guard let url = urlComponents.url else {
            throw AppError.invalidURL
        }

        // Make request
        let (data, response) = try await performRequest(url: url)

        // Validate response
        try validateResponse(response)

        // Decode JSON
        return try decodeRecipes(from: data)
    }

    /// Fetches detailed information for a specific recipe
    /// - Parameter id: The recipe ID
    /// - Returns: Detailed recipe information (for future expansion)
    func getRecipeDetails(id: Int) async throws -> Data {
        guard apiKey != "YOUR_API_KEY_HERE" else {
            throw AppError.apiKeyMissing
        }

        let urlString = "\(baseURL)/recipes/\(id)/information"

        guard var urlComponents = URLComponents(string: urlString) else {
            throw AppError.invalidURL
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey)
        ]

        guard let url = urlComponents.url else {
            throw AppError.invalidURL
        }

        let (data, response) = try await performRequest(url: url)
        try validateResponse(response)

        return data
    }

    // MARK: - Private Helpers

    /// Performs the network request with error handling
    private func performRequest(url: URL) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(from: url)
        } catch let error as URLError {
            throw AppError.networkError(error)
        } catch {
            throw AppError.unknown(error)
        }
    }

    /// Validates the HTTP response
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return // Success
        case 401:
            throw AppError.apiKeyMissing
        case 402:
            throw AppError.rateLimitExceeded
        case 429:
            throw AppError.rateLimitExceeded
        default:
            throw AppError.invalidResponse
        }
    }

    /// Decodes the JSON response into Recipe objects
    private func decodeRecipes(from data: Data) throws -> [Recipe] {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Recipe].self, from: data)
        } catch {
            throw AppError.decodingError(error)
        }
    }
}

// MARK: - Mock Service for Previews and Testing

/// Mock service that returns sample data for previews and testing
actor MockSpoonacularService {

    func findRecipes(byIngredients ingredients: [String]) async throws -> [Recipe] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        return [
            Recipe(
                id: 1,
                title: "Chicken Stir Fry",
                image: "https://spoonacular.com/recipeImages/716429-312x231.jpg",
                imageType: "jpg",
                usedIngredientCount: 3,
                missedIngredientCount: 2,
                usedIngredients: [
                    RecipeIngredient(
                        id: 1,
                        amount: 2,
                        unit: "lbs",
                        unitLong: "pounds",
                        unitShort: "lbs",
                        aisle: "Meat",
                        name: "chicken breast",
                        original: "2 lbs chicken breast",
                        originalName: "chicken breast",
                        meta: nil,
                        image: "chicken-breast.jpg"
                    )
                ],
                missedIngredients: [
                    RecipeIngredient(
                        id: 2,
                        amount: 2,
                        unit: "tbsp",
                        unitLong: "tablespoons",
                        unitShort: "tbsp",
                        aisle: "Condiments",
                        name: "soy sauce",
                        original: "2 tbsp soy sauce",
                        originalName: "soy sauce",
                        meta: nil,
                        image: "soy-sauce.jpg"
                    )
                ],
                unusedIngredients: nil,
                likes: 150
            ),
            Recipe(
                id: 2,
                title: "Vegetable Rice Bowl",
                image: "https://spoonacular.com/recipeImages/715594-312x231.jpg",
                imageType: "jpg",
                usedIngredientCount: 4,
                missedIngredientCount: 1,
                usedIngredients: [
                    RecipeIngredient(
                        id: 3,
                        amount: 1,
                        unit: "cup",
                        unitLong: "cup",
                        unitShort: "cup",
                        aisle: "Grains",
                        name: "rice",
                        original: "1 cup rice",
                        originalName: "rice",
                        meta: nil,
                        image: "rice.jpg"
                    )
                ],
                missedIngredients: [],
                unusedIngredients: nil,
                likes: 89
            )
        ]
    }
}
