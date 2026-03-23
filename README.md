# PantryChef: AI Recipe Generator

## Overview
PantryChef eliminates food waste by helping users cook with what they already have. By snapping a photo of ingredients, the app uses on-device Vision capabilities to identify food items and fetches recipes matching those ingredients.

## Key Features
* **Ingredient Recognition:** Utilizes Apple's Vision framework to detect text/objects in photos
* **Recipe Fetching:** Integrates with TheMealDB API (free, no API key required)
* **Missing Ingredient Breakdown:** Shows exactly what you have and what you still need for a recipe
* **Recipe Instructions:** Full cooking instructions and YouTube video links

## Tech Stack
* **Framework:** SwiftUI
* **Image Processing:** Vision framework & Core ML
* **Networking:** URLSession (async/await), Codable
* **API:** TheMealDB (free, no API key required)

## Requirements
* iOS 17.0+
* Xcode 15.0+

## Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd PantryChef
```

### 2. Build and Run
Open `PantryChef.xcodeproj` in Xcode and run on a simulator or device.

No API key configuration needed - TheMealDB is completely free!

## Project Structure

```
PantryChef/
├── PantryChefApp.swift          # App entry point
├── Models/
│   ├── Recipe.swift             # Codable models for API responses
│   └── AppError.swift           # Custom error types
├── Services/
│   ├── VisionService.swift      # Vision framework for image analysis
│   └── RecipeService.swift      # TheMealDB API networking layer
├── Views/
│   ├── ContentView.swift        # Main app interface
│   ├── ImagePicker.swift        # Camera/photo library picker
│   ├── RecipeRowView.swift      # Recipe list row
│   └── RecipeDetailView.swift   # Recipe detail screen
└── Assets.xcassets/             # App icons and colors
```

## Architecture

### Image Processing
1. User captures/selects an image of ingredients
2. Image is converted to `CGImage` for Vision processing
3. `VNRecognizeTextRequest` performs OCR to detect food labels
4. `VNClassifyImageRequest` identifies visual food items
5. Results are filtered against a curated food keyword list

### Networking
1. Extracted ingredients are used to search TheMealDB
2. `URLSession.shared.data(from:)` with `await` fetches recipes
3. Response is decoded using `Codable` into `Recipe` structs
4. All network calls run off the main thread via Swift Concurrency

### JSON Parsing
The `MealDBMeal` and `Recipe` models handle TheMealDB's response format:
- Automatic key mapping from JSON to Swift properties
- Ingredients are extracted from numbered fields (strIngredient1-20)
- Type-safe parsing with error handling

## Usage

1. **Capture Ingredients:** Tap the camera button to take a photo or select from library
2. **Review Detection:** View recognized ingredients as removable chips
3. **Search Recipes:** Tap "Find Recipes" to query TheMealDB
4. **Browse Results:** Scroll through recipes showing used/missing ingredients
5. **View Details:** Tap a recipe for full instructions and YouTube video link

## Privacy

The app requires the following permissions:
- **Camera:** To capture photos of ingredients
- **Photo Library:** To select existing images

All image processing happens on-device using Apple's Vision framework.

## TheMealDB API

This app uses [TheMealDB](https://www.themealdb.com/api.php), a free and open recipe database:
- No API key required for basic usage
- Thousands of recipes from around the world
- Includes cooking instructions and video tutorials
- Ingredient images provided

## Future Enhancements

- [ ] Custom Core ML model for better food recognition
- [ ] Barcode scanning for packaged ingredients
- [ ] Recipe favorites and history
- [ ] Nutritional information display
- [ ] Shopping list generation
- [ ] Offline recipe caching

## License

MIT License - See LICENSE file for details
