//
//  VisionService.swift
//  PantryChef
//
//  Vision framework service for ingredient recognition
//

import Foundation
import Vision
import UIKit
import CoreML

/// Service for processing images and extracting ingredient information using Vision framework
actor VisionService {

    // MARK: - Common Food Keywords

    /// Common food-related keywords to filter Vision results
    private let foodKeywords: Set<String> = [
        // Proteins
        "chicken", "beef", "pork", "fish", "salmon", "tuna", "shrimp", "egg", "eggs",
        "turkey", "lamb", "bacon", "ham", "sausage", "steak", "tofu",
        // Vegetables
        "tomato", "tomatoes", "onion", "onions", "garlic", "pepper", "peppers",
        "carrot", "carrots", "broccoli", "spinach", "lettuce", "celery", "cucumber",
        "potato", "potatoes", "corn", "peas", "beans", "mushroom", "mushrooms",
        "zucchini", "squash", "eggplant", "cabbage", "kale", "asparagus",
        // Fruits
        "apple", "apples", "banana", "bananas", "orange", "oranges", "lemon", "lemons",
        "lime", "limes", "strawberry", "strawberries", "blueberry", "blueberries",
        "grape", "grapes", "mango", "avocado", "pineapple", "watermelon", "peach",
        // Dairy
        "milk", "cheese", "butter", "cream", "yogurt", "mozzarella", "cheddar",
        "parmesan", "feta",
        // Grains & Pasta
        "rice", "pasta", "bread", "flour", "oats", "quinoa", "noodles", "spaghetti",
        // Condiments & Seasonings
        "salt", "pepper", "sugar", "oil", "olive oil", "vinegar", "soy sauce",
        "ketchup", "mustard", "mayonnaise", "honey",
        // Canned & Packaged
        "beans", "soup", "sauce", "broth", "stock"
    ]

    // MARK: - Public Methods

    /// Recognizes ingredients from an image using text recognition
    /// - Parameter image: The UIImage to analyze
    /// - Returns: RecognizedIngredients containing found ingredients
    func recognizeIngredients(from image: UIImage) async throws -> RecognizedIngredients {
        guard let cgImage = image.cgImage else {
            throw AppError.imageProcessingFailed
        }

        // Perform both text recognition and object classification
        async let textResults = performTextRecognition(on: cgImage)
        async let classificationResults = performImageClassification(on: cgImage)

        let (textIngredients, classifiedIngredients) = try await (textResults, classificationResults)

        // Combine and deduplicate results
        var allIngredients = Set(textIngredients)
        allIngredients.formUnion(classifiedIngredients)

        let uniqueIngredients = Array(allIngredients).sorted()

        if uniqueIngredients.isEmpty {
            throw AppError.noIngredientsFound
        }

        return RecognizedIngredients(
            ingredients: uniqueIngredients,
            confidence: 0.8
        )
    }

    // MARK: - Text Recognition

    /// Performs OCR text recognition to find ingredient labels
    private func performTextRecognition(on cgImage: CGImage) async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: AppError.visionRequestFailed(error))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let ingredients = self.extractIngredients(from: observations)
                continuation.resume(returning: ingredients)
            }

            // Configure for accurate recognition
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: AppError.visionRequestFailed(error))
            }
        }
    }

    /// Extracts ingredient strings from text observations
    private func extractIngredients(from observations: [VNRecognizedTextObservation]) -> [String] {
        var ingredients: [String] = []

        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }

            let text = topCandidate.string.lowercased()
            let words = text.components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty }

            for word in words {
                if foodKeywords.contains(word) && !ingredients.contains(word) {
                    ingredients.append(word)
                }
            }
        }

        return ingredients
    }

    // MARK: - Image Classification

    /// Performs image classification to identify food items visually
    private func performImageClassification(on cgImage: CGImage) async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            // Use VNClassifyImageRequest for general image classification
            let request = VNClassifyImageRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: AppError.visionRequestFailed(error))
                    return
                }

                guard let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let ingredients = self.extractFoodClassifications(from: observations)
                continuation.resume(returning: ingredients)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                // Classification may not be available on all devices
                // Return empty array instead of failing
                continuation.resume(returning: [])
            }
        }
    }

    /// Filters classification results for food-related items
    private func extractFoodClassifications(from observations: [VNClassificationObservation]) -> [String] {
        var ingredients: [String] = []

        // Filter for high-confidence food classifications
        let foodObservations = observations.filter { observation in
            observation.confidence > 0.3
        }

        for observation in foodObservations.prefix(10) {
            let identifier = observation.identifier.lowercased()
            let words = identifier.components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty }

            for word in words {
                if foodKeywords.contains(word) && !ingredients.contains(word) {
                    ingredients.append(word)
                }
            }
        }

        return ingredients
    }

    // MARK: - Core ML Integration (Placeholder)

    /// Placeholder for custom Core ML model integration
    /// Replace with your own food recognition model for better accuracy
    func recognizeWithCoreML(image: UIImage, model: VNCoreMLModel) async throws -> [String] {
        guard let cgImage = image.cgImage else {
            throw AppError.imageProcessingFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    continuation.resume(throwing: AppError.visionRequestFailed(error))
                    return
                }

                guard let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let ingredients = observations
                    .filter { $0.confidence > 0.5 }
                    .prefix(10)
                    .map { $0.identifier.lowercased() }

                continuation.resume(returning: Array(ingredients))
            }

            request.imageCropAndScaleOption = .centerCrop

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: AppError.visionRequestFailed(error))
            }
        }
    }
}
