//
//  ContentView.swift
//  PantryChef
//
//  Main view with ingredient scanning and recipe search functionality
//

import SwiftUI

/// Main content view for the PantryChef app
struct ContentView: View {
    // MARK: - State

    @State private var selectedImage: UIImage?
    @State private var recognizedIngredients: [String] = []
    @State private var recipes: [Recipe] = []
    @State private var isProcessing = false
    @State private var isFetchingRecipes = false
    @State private var errorMessage: String?
    @State private var showError = false

    // Image picker state
    @State private var showImageSourcePicker = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var selectedSource: ImageSource?

    // Services
    private let visionService = VisionService()
    private let spoonacularService = SpoonacularService()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection

                    // Image Section
                    imageSection

                    // Recognized Ingredients
                    if !recognizedIngredients.isEmpty {
                        ingredientsSection
                    }

                    // Recipes Section
                    if !recipes.isEmpty {
                        recipesSection
                    }
                }
                .padding()
            }
            .navigationTitle("PantryChef")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        resetState()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .disabled(selectedImage == nil && recipes.isEmpty)
                }
            }
            .sheet(isPresented: $showImageSourcePicker) {
                ImageSourcePicker(
                    selectedSource: $selectedSource,
                    isPresented: $showImageSourcePicker,
                    onSourceSelected: handleSourceSelection
                )
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker(image: $selectedImage)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showPhotoLibrary) {
                PhotoLibraryPicker(image: $selectedImage)
            }
            .onChange(of: selectedImage) { _, newImage in
                if newImage != nil {
                    processImage()
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "carrot.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange)

            Text("Scan your ingredients")
                .font(.title2.bold())

            Text("Take a photo of your ingredients and we'll find recipes you can make")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }

    private var imageSection: some View {
        VStack(spacing: 16) {
            if let image = selectedImage {
                // Display selected image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            withAnimation {
                                selectedImage = nil
                                recognizedIngredients = []
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                        }
                        .padding(8)
                    }

                if isProcessing {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Analyzing ingredients...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                // Image capture button
                Button {
                    showImageSourcePicker = true
                } label: {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                        Text("Add Photo")
                            .font(.headline)
                    }
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundStyle(.blue.opacity(0.5))
                    }
                }
            }
        }
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recognized Ingredients")
                    .font(.headline)
                Spacer()
                Text("\(recognizedIngredients.count) found")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Ingredient chips
            FlowLayout(spacing: 8) {
                ForEach(recognizedIngredients, id: \.self) { ingredient in
                    IngredientChip(name: ingredient) {
                        withAnimation {
                            recognizedIngredients.removeAll { $0 == ingredient }
                        }
                    }
                }
            }

            // Find Recipes Button
            Button {
                fetchRecipes()
            } label: {
                HStack {
                    if isFetchingRecipes {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "magnifyingglass")
                    }
                    Text(isFetchingRecipes ? "Searching..." : "Find Recipes")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(recognizedIngredients.isEmpty ? Color.gray : Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(recognizedIngredients.isEmpty || isFetchingRecipes)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var recipesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recipes")
                    .font(.headline)
                Spacer()
                Text("\(recipes.count) found")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRowView(recipe: recipe)
                }
                .buttonStyle(.plain)

                if recipe.id != recipes.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Actions

    private func handleSourceSelection(_ source: ImageSource) {
        switch source {
        case .camera:
            showCamera = true
        case .photoLibrary:
            showPhotoLibrary = true
        }
    }

    private func processImage() {
        guard let image = selectedImage else { return }

        isProcessing = true
        recognizedIngredients = []

        Task {
            do {
                let result = try await visionService.recognizeIngredients(from: image)
                await MainActor.run {
                    recognizedIngredients = result.ingredients
                    isProcessing = false
                }
            } catch let error as AppError {
                await MainActor.run {
                    errorMessage = error.errorDescription
                    showError = true
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isProcessing = false
                }
            }
        }
    }

    private func fetchRecipes() {
        guard !recognizedIngredients.isEmpty else { return }

        isFetchingRecipes = true
        recipes = []

        Task {
            do {
                let fetchedRecipes = try await spoonacularService.findRecipes(
                    byIngredients: recognizedIngredients
                )
                await MainActor.run {
                    recipes = fetchedRecipes
                    isFetchingRecipes = false
                }
            } catch let error as AppError {
                await MainActor.run {
                    errorMessage = error.errorDescription
                    showError = true
                    isFetchingRecipes = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isFetchingRecipes = false
                }
            }
        }
    }

    private func resetState() {
        withAnimation {
            selectedImage = nil
            recognizedIngredients = []
            recipes = []
            errorMessage = nil
        }
    }
}

// MARK: - Supporting Views

/// Removable ingredient chip
struct IngredientChip: View {
    let name: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(name.capitalized)
                .font(.subheadline)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.2))
        .clipShape(Capsule())
    }
}

/// Flow layout for ingredient chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)

        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            ), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
