//
//  AppError.swift
//  PantryChef
//
//  Custom error types for the application
//

import Foundation

/// Unified error type for the application
enum AppError: LocalizedError {
    case cameraUnavailable
    case imageProcessingFailed
    case visionRequestFailed(Error)
    case noIngredientsFound
    case networkError(Error)
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case apiKeyMissing
    case rateLimitExceeded
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .cameraUnavailable:
            return "Camera is not available on this device"
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .visionRequestFailed(let error):
            return "Vision analysis failed: \(error.localizedDescription)"
        case .noIngredientsFound:
            return "No ingredients could be identified in the image"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL configuration"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .apiKeyMissing:
            return "Spoonacular API key is missing. Please add your API key."
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .cameraUnavailable:
            return "Try selecting an image from your photo library instead"
        case .imageProcessingFailed, .visionRequestFailed:
            return "Try taking another photo with better lighting"
        case .noIngredientsFound:
            return "Make sure ingredients are clearly visible and try again"
        case .networkError:
            return "Check your internet connection and try again"
        case .apiKeyMissing:
            return "Add your Spoonacular API key in the app configuration"
        case .rateLimitExceeded:
            return "Wait a few minutes before making another request"
        default:
            return "Please try again"
        }
    }
}
