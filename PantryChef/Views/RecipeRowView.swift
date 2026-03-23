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

                // Likes count if available
                if let likes = recipe.likes, likes > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundStyle(.red)
                        Text("\(likes)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
            id: 1,
            title: "Delicious Chicken Stir Fry with Vegetables",
            image: "https://spoonacular.com/recipeImages/716429-312x231.jpg",
            imageType: "jpg",
            usedIngredientCount: 3,
            missedIngredientCount: 2,
            usedIngredients: [],
            missedIngredients: [],
            unusedIngredients: nil,
            likes: 150
        ))
    }
}
