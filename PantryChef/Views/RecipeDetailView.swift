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

                    // Category and Area
                    if recipe.category != nil || recipe.area != nil {
                        HStack(spacing: 12) {
                            if let category = recipe.category {
                                Label(category, systemImage: "tag.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                            }
                            if let area = recipe.area {
                                Label(area, systemImage: "globe")
                                    .font(.subheadline)
                                    .foregroundStyle(.green)
                            }
                        }
                    }

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

                    // Instructions Section
                    if let instructions = recipe.instructions, !instructions.isEmpty {
                        Divider()

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Instructions")
                                .font(.headline)

                            Text(instructions)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // YouTube Link
                    if let youtubeURL = recipe.youtubeURL,
                       let url = URL(string: youtubeURL) {
                        Divider()

                        Link(destination: url) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .foregroundStyle(.red)
                                Text("Watch on YouTube")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
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
                if !ingredient.measure.isEmpty {
                    Text(ingredient.measure)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
            id: "52772",
            title: "Teriyaki Chicken Casserole",
            image: "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg",
            category: "Chicken",
            area: "Japanese",
            instructions: "Preheat oven to 350 degrees F. Combine soy sauce, water, brown sugar, and garlic in a bowl. Place chicken in a 9x13 baking dish and pour sauce over chicken. Bake for 30 minutes.",
            youtubeURL: "https://www.youtube.com/watch?v=4aZr5hZXP_s",
            usedIngredients: [
                RecipeIngredient(id: 0, name: "chicken breast", measure: "1 lb"),
                RecipeIngredient(id: 1, name: "garlic", measure: "3 cloves")
            ],
            missedIngredients: [
                RecipeIngredient(id: 2, name: "soy sauce", measure: "3/4 cup"),
                RecipeIngredient(id: 3, name: "brown sugar", measure: "1/2 cup")
            ]
        ))
    }
}
