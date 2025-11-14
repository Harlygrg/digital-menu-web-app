# Digital Menu Order App

A pixel-perfect, responsive Flutter home screen for mobile and tablet devices with RTL support for Arabic language.

## Features

- **Responsive Design**: Optimized for both mobile (portrait) and tablet (portrait) devices
- **RTL Support**: Full Arabic language support with proper text direction
- **Theme Support**: Light and dark theme modes
- **State Management**: Provider-based state management with MVC architecture
- **Search & Filtering**: Real-time search with debouncing and category/veg filters
- **Cart Functionality**: Add/remove items with quantity management
- **Grid/List Views**: Toggle between grid and list item layouts
- **Accessibility**: Proper semantics and touch targets

## Project Structure

```
lib/
├── main.dart                 # App entry point with MultiProvider setup
├── theme/
│   └── theme.dart           # Color tokens, responsive helpers, themes
├── routes/
│   └── routes.dart          # Central route configuration
├── models/
│   ├── category_model.dart  # Category data model
│   ├── item_model.dart      # Menu item data model
│   └── cart_item_model.dart # Cart item data model
├── providers/
│   └── home_provider.dart   # State management with Provider
├── controllers/
│   └── home_controller.dart # Business logic controller
└── views/
    └── home/
        ├── home_screen.dart  # Main home screen
        └── widgets/          # Reusable UI components
            ├── app_bar_silver.dart
            ├── language_dropdown.dart
            ├── cart_button.dart
            ├── search_bar.dart
            ├── category_chips.dart
            ├── veg_toggle.dart
            ├── items_grid.dart
            ├── items_list.dart
            └── grid_list_toggle.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (^3.8.1)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd digital_menu_order
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Testing Different Screen Sizes

#### Mobile Testing
- Use a mobile device or emulator with portrait orientation
- Screen width should be < 600px for mobile layout (2 columns in grid)

#### Tablet Testing
- Use a tablet device or emulator with portrait orientation
- Screen width should be ≥ 600px for tablet layout (3 columns in grid)

#### Manual Screen Size Testing
You can test different screen sizes by:

1. **Android Emulator**:
   - Create different AVDs with different screen sizes
   - Use "Extended Controls" → "Settings" → "Screen" to change resolution

2. **iOS Simulator**:
   - Use different device types (iPhone, iPad)
   - Rotate to portrait mode

3. **Chrome Web**:
   - Use Chrome DevTools to simulate different screen sizes
   - Toggle device toolbar and select different devices

### Key Features Testing

#### Language Toggle
- Tap the language dropdown in the top-right corner
- Switch between "EN" and "عربي"
- Verify text direction changes (LTR ↔ RTL)
- Check that all text updates to the selected language

#### Grid/List Toggle
- Tap the grid/list toggle buttons in the "All Items" section
- Verify smooth transition between layouts
- Check that mobile shows 2 columns, tablet shows 3 columns in grid view

#### Search Functionality
- Type in the search bar
- Verify 300ms debounce works (no immediate filtering)
- Test with both English and Arabic text

#### Category Filtering
- Tap different category chips
- Verify items filter correctly
- Test "All" category to show all items

#### Veg/Non-Veg Filter
- Toggle between "Veg" and "Non-Veg" buttons
- Verify only appropriate items are shown
- Check that the selected state is visually distinct

#### Cart Functionality
- Tap the "+" button on any item to add to cart
- Verify cart badge shows correct count
- Tap cart button to open bottom sheet
- Test quantity increase/decrease buttons
- Test "Clear" button to empty cart

## Architecture

### State Management
- **Provider**: Used for state management
- **HomeProvider**: Manages all UI state (language, filters, cart, etc.)
- **HomeController**: Handles business logic and user actions

### Responsive Design
- **Responsive Class**: Helper for scaling fonts, padding, and grid columns
- **Breakpoints**: Mobile (<600px), Tablet (600-900px), Large Tablet (>900px)
- **Dynamic Sizing**: All UI elements scale based on screen width

### RTL Support
- **Directionality Widget**: Wraps the entire app for RTL support
- **Text Direction**: Automatically switches based on selected language
- **Icon Positioning**: Icons and layouts adapt to RTL direction

### Theme System
- **Color Tokens**: Centralized color definitions for light/dark themes
- **Typography**: Responsive font sizing with theme-aware colors
- **Material 3**: Uses Material 3 design system

## Customization

### Adding New Items
Edit `lib/providers/home_provider.dart` and add items to the `_getSampleItems()` method:

```dart
const ItemModel(
  id: 'new_item',
  name: 'New Item',
  nameAr: 'عنصر جديد',
  description: 'Description',
  descriptionAr: 'الوصف',
  price: 9.99,
  imageUrl: 'https://example.com/image.jpg',
  categoryId: 'main_course',
  isVeg: true,
),
```

### Adding New Categories
Edit `lib/providers/home_provider.dart` and add categories to the `_getSampleCategories()` method:

```dart
const CategoryModel(
  id: 'new_category',
  name: 'New Category',
  nameAr: 'فئة جديدة',
  iconPath: 'assets/images/new_category.png',
),
```

### Customizing Colors
Edit `lib/theme/theme.dart` and modify the `AppColors` and `AppColorsDark` classes.

### Adding New Languages
1. Add locale to `supportedLocales` in `main.dart`
2. Add language option to `LanguageDropdownWidget`
3. Update all text strings to support the new language

## Testing

Run the test suite:

```bash
flutter test
```

The tests cover:
- Language toggle functionality
- Grid/list view switching
- Veg filter functionality
- Search functionality
- Cart operations

## Performance Considerations

- **Debounced Search**: 300ms delay prevents excessive filtering
- **Selective Rebuilds**: Uses `Consumer` and `Selector` for minimal rebuilds
- **Image Caching**: Network images are cached automatically
- **Lazy Loading**: Grid and list views use lazy loading for large datasets

## Accessibility

- **Semantic Labels**: All interactive elements have proper semantics
- **Touch Targets**: Minimum 48x48dp touch targets
- **Screen Reader**: Compatible with screen readers
- **High Contrast**: Supports high contrast themes

## Future Enhancements

- [ ] Backend integration
- [ ] User authentication
- [ ] Order management
- [ ] Payment integration
- [ ] Push notifications
- [ ] Offline support
- [ ] More languages
- [ ] Advanced filtering options
- [ ] Item favorites
- [ ] Order history

## Troubleshooting

### Common Issues

1. **Images not loading**: Check network connectivity and image URLs
2. **RTL not working**: Ensure `Directionality` widget is properly configured
3. **Layout issues**: Verify responsive breakpoints and screen sizes
4. **State not updating**: Check Provider setup and Consumer usage

### Debug Mode
Run in debug mode for detailed logs:

```bash
flutter run --debug
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
