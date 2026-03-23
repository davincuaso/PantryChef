//
//  RecipeDetailView.swift
//  PantryChef
//
//  Detailed view showing recipe information with ingredient breakdown
//

import SwiftUI

/// Displays detailed recipe information including used and missing ingredients
struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe Image
                AsyncImage(url: recipe.imageURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay {
                                ProgressView()
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 250)
                .clipped()

                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text(recipe.title)
                        .font(.title2.bold())

                    // Stats Row
                    HStack(spacing: 20) {
                        StatView(
                            value: recipe.usedIngredientCount,
                            label: "Ingredients You Have",
                            color: .green,
                            icon: "checkmark.circle.fill"
                        )

                        StatView(
                            value: recipe.missedIngredientCount,
                            label: "Ingredients Needed",
                            color: .orange,
                            icon: "cart.fill"
                        )
                    }

                    Divider()

                    // Used Ingredients Section
                    if !recipe.usedIngredients.isEmpty {
                        IngredientSection(
                            title: "Ingredients You Have",
                            ingredients: recipe.usedIngredients,
                            color: .green
                        )
                    }

                    // Missing Ingredients Section
                    if !recipe.missedIngredients.isEmpty {
                        IngredientSection(
                            title: "Ingredients to Buy",
                            ingredients: recipe.missedIngredients,
                            color: .orange
                        )
                    }

                    // Unused Ingredients Section
                    if let unusedIngredients = recipe.unusedIngredients, !unusedIngredients.isEmpty {
                        IngredientSection(
                            title: "Won't Be Used",
                            ingredients: unusedIngredients,
                            color: .gray
                        )
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Stat display view
struct StatView: View {
    let value: Int
    let label: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text("\(value)")
                    .font(.title.bold())
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Section displaying a list of ingredients
struct IngredientSection: View {
    let title: String
    let ingredients: [RecipeIngredient]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.headline)
            }

            ForEach(ingredients) { ingredient in
                IngredientRow(ingredient: ingredient)
            }
        }
    }
}

/// Row displaying a single ingredient
struct IngredientRow: View {
    let ingredient: RecipeIngredient

    var body: some View {
        HStack(spacing: 12) {
            // Ingredient Image
            AsyncImage(url: ingredient.imageURL) { phase in
                switch phase {
                case .empty, .failure:
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "leaf.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name.capitalized)
                    .font(.subheadline)
                Text(ingredient.displayAmount)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            id: 1,
            title: "Chicken Stir Fry with Fresh Vegetables",
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
                ),
                RecipeIngredient(
                    id: 2,
                    amount: 1,
                    unit: "cup",
                    unitLong: "cup",
                    unitShort: "cup",
                    aisle: "Vegetables",
                    name: "broccoli",
                    original: "1 cup broccoli",
                    originalName: "broccoli",
                    meta: nil,
                    image: "broccoli.jpg"
                )
            ],
            missedIngredients: [
                RecipeIngredient(
                    id: 3,
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
        ))
    }
}
