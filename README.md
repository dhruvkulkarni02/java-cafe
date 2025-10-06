# Java Café ☕️

A Flutter showcase app for browsing, favoriting, and ordering craft coffee drinks. The menu is sourced entirely from the public [Free Food Menus API](https://github.com/igdev116/free-food-menus-api), so no local image assets are bundled with the project.

## Highlights

- Material 3 UI with dark/light theming via `provider`-powered state.
- Remote menu ingestion with graceful loading, pull-to-refresh, and offline error handling.
- Cart and favorites persisted locally using `shared_preferences`.
- Smooth imagery transitions using network photos and `transparent_image` placeholders.

## Development

```bash
flutter pub get
flutter run
```

During development you can refresh the menu by pulling down on the list. If the API is temporarily unavailable, the app surfaces a friendly error state with a retry action.

## Testing

```bash
flutter test
```

Widget tests stub the data layer so the suite runs without external network access.
