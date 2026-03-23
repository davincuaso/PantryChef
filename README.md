# PantryChef: AI Recipe Generator

## Overview
PantryChef eliminates food waste by helping users cook with what they already have. By snapping a photo of ingredients, the app uses on-device Vision capabilities to identify food items and fetches highly-rated recipes matching those ingredients.

## Key Features
* **Ingredient Recognition:** Utilizes Apple's Vision framework to detect text/objects in photos
* **Recipe Fetching:** Integrates with the Spoonacular API to find relevant meals
* **Missing Ingredient Breakdown:** Shows exactly what you have and what you still need for a recipe

## Tech Stack
* **Framework:** SwiftUI
* **Image Processing:** Vision framework & Core ML
* **Networking:** URLSession (async/await), Codable
* **API:** Spoonacular Recipe API

## Requirements
* iOS 17.0+
* Xcode 15.0+
* Spoonacular API Key

## Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd PantryChef
```

### 2. Get a Spoonacular API Key
1. Visit [Spoonacular API](https://spoonacular.com/food-api)
2. Sign up for a free account
3. Navigate to your profile to find your API key

### 3. Configure the API Key
Set your API key as an environment variable in Xcode:
1. Edit the scheme (Product > Scheme > Edit Scheme)
2. Select "Run" in the sidebar
3. Go to the "Arguments" tab
4. Add an environment variable: `SPOONACULAR_API_KEY` = `your_api_key`

Alternatively, replace `YOUR_API_KEY_HERE` in `SpoonacularService.swift` (not recommended for production).

### 4. Build and Run
Open `PantryChef.xcodeproj` in Xcode and run on a simulator or device.

## Project Structure

```
PantryChef/
├── PantryChefApp.swift          # App entry point
├── Models/
│   ├── Recipe.swift             # Codable models for API responses
│   └── AppError.swift           # Custom error types
├── Services/
│   ├── VisionService.swift      # Vision framework for image analysis
│   └── SpoonacularService.swift # API networking layer
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
1. Extracted ingredients are joined into a comma-separated query
2. `URLSession.shared.data(from:)` with `await` fetches recipes
3. Response is decoded using `Codable` into `Recipe` structs
4. All network calls run off the main thread via Swift Concurrency

### JSON Parsing
The `Recipe` and `RecipeIngredient` models conform to `Codable`:
- Automatic key mapping from JSON to Swift properties
- Support for optional fields and nested objects
- Type-safe parsing with error handling

## Usage

1. **Capture Ingredients:** Tap the camera button to take a photo or select from library
2. **Review Detection:** View recognized ingredients as removable chips
3. **Search Recipes:** Tap "Find Recipes" to query the Spoonacular API
4. **Browse Results:** Scroll through recipes showing used/missing ingredients
5. **View Details:** Tap a recipe for full ingredient breakdown

## Privacy

The app requires the following permissions:
- **Camera:** To capture photos of ingredients
- **Photo Library:** To select existing images

All image processing happens on-device using Apple's Vision framework.

## API Rate Limits

The free Spoonacular tier includes:
- 150 requests/day
- Access to recipe search endpoints

Consider upgrading for production use.

## Future Enhancements

- [ ] Custom Core ML model for better food recognition
- [ ] Barcode scanning for packaged ingredients
- [ ] Recipe favorites and history
- [ ] Nutritional information display
- [ ] Shopping list generation
- [ ] Offline recipe caching

## License

MIT License - See LICENSE file for details
