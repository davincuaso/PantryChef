//
//  RecipeRowView.swift
//  PantryChef
//
//  Row view for displaying a single recipe in the list
//

import SwiftUI

/// Displays a single recipe with image, title, and ingredient breakdown
struct RecipeRowView: View {
    let recipe: Recipe

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Recipe Image
            AsyncImage(url: recipe.imageURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            ProgressView()
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                case .failure:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Recipe Details
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)

                // Ingredient counts
                HStack(spacing: 12) {
                    IngredientBadge(
                        count: recipe.usedIngredientCount,
                        label: "Used",
                        color: .green
                    )

                    IngredientBadge(
                        count: recipe.missedIngredientCount,
                        label: "Missing",
                        color: .orange
                    )
                }

                // Category and area info
                if let category = recipe.category {
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                        Text(category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let area = recipe.area {
                            Text("•")
                                .foregroundStyle(.secondary)
                            Text(area)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

/// Badge showing ingredient count
struct IngredientBadge: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text("\(count)")
                .font(.caption.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    List {
        RecipeRowView(recipe: Recipe(
            id: "52772",
            title: "Teriyaki Chicken Casserole",
            image: "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg",
            category: "Chicken",
            area: "Japanese",
            instructions: nil,
            youtubeURL: nil,
            usedIngredients: [
                RecipeIngredient(id: 0, name: "chicken", measure: "1 lb")
            ],
            missedIngredients: [
                RecipeIngredient(id: 1, name: "soy sauce", measure: "2 tbsp"),
                RecipeIngredient(id: 2, name: "rice", measure: "1 cup")
            ]
        ))
    }
}
