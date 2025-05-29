# Shutters

A Flutter application for applying filters to images and creating collages.

## Features

### Image Filters
- **Grayscale**: Convert images to black and white
- **Sepia**: Apply vintage sepia tone effect
- **Blur**: Add gaussian blur effect
- **Brighten**: Increase image brightness
- **Darken**: Decrease image brightness
- **Contrast**: Enhance image contrast
- **Vintage**: Combine sepia, contrast, and brightness effects

### Collage Creation
- **Grid Layout**: Arrange images in a grid pattern
- **Horizontal Layout**: Place images side by side
- **Vertical Layout**: Stack images vertically
- **Mosaic Layout**: Create artistic mosaic arrangements

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio (for Android development)

### Installation

1. **Clone or create the project**:
   ```bash
   flutter create photo_editor_app
   cd photo_editor_app
   ```

2. **Replace the generated files** with the provided code files:
   - `pubspec.yaml`
   - `lib/main.dart`
   - `lib/screens/filter_screen.dart`
   - `lib/screens/collage_screen.dart`
   - `android/app/src/main/AndroidManifest.xml`

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

### Running on Android

1. **Connect your Android device** or start an emulator

2. **Run the app**:
   ```bash
   flutter run -d android
   ```

### Building for Release

#### Android APK
```bash
flutter build apk --release
```

## Project Structure

```
shutters/
├── lib/
│   ├── main.dart                 # App entry point and home screen
│   └── screens/
│       ├── filter_screen.dart    # Image filtering functionality
│       └── collage_screen.dart   # Collage creation functionality
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml   # Android permissions
├── pubspec.yaml                 # Dependencies
└── README.md                    # This file
```

## Dependencies

- **image_picker**: For selecting images from camera/gallery
- **image**: For image processing and manipulation
- **path_provider**: For accessing device storage paths
- **permission_handler**: For managing app permissions
- **image_gallery_saver_plus**: For saving processed images to gallery

## Permissions

### Android
The app requires the following permissions:
- `CAMERA`: To capture photos
- `READ_EXTERNAL_STORAGE`: To read images from storage
- `WRITE_EXTERNAL_STORAGE`: To save processed images
- `READ_MEDIA_IMAGES`: For Android 13+ media access

## Usage

1. **Launch the app** and choose between "Apply Filters" or "Create Collage"

2. **For Filters**:
   - Select image source (Camera or Gallery)
   - Choose from available filters
   - Save the filtered image

3. **For Collages**:
   - Select multiple images from gallery
   - Choose layout style (Grid, Horizontal, Vertical, Mosaic)
   - Save the collage

### Performance Tips

- Images are automatically resized to improve performance
- For large collages, consider using fewer images
- Filter processing may take time on older devices

## Development Notes

### Adding New Filters

To add a new filter, modify `filter_screen.dart`:

1. Add filter name to `_filters` list
2. Add case in `_applyFilter` switch statement
3. Use `image` package functions for processing

### Adding New Collage Layouts

To add layouts, modify `collage_screen.dart`:

1. Add layout name to `_layouts` list
2. Create new layout method (e.g., `_createCustomLayout`)
3. Add case in `_createCollage` switch statement

## Future Enhancements

- Brightness/contrast sliders
- Crop functionality
- Text overlay on images
- Social sharing
- Custom filter creation
- Batch processing
- Undo/redo functionality

## License

This project is open source and available under the [AGPL License](https://www.gnu.org/licenses/agpl-3.0.en.html#license-text).
