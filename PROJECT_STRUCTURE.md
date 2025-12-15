# Event Management System - Flutter + Supabase

A comprehensive Flutter application for event management with Supabase backend integration.

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── config/                   # Configuration files
│   ├── app_theme.dart        # App theme and styling
│   └── supabase_config.dart  # Supabase configuration
├── models/                   # Data models
│   ├── event.dart            # Event model
│   ├── registration.dart     # Registration model
│   └── user_profile.dart     # User profile model
├── screens/                  # UI screens
│   ├── auth/                 # Authentication screens
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── splash_screen.dart
│   ├── events/               # Event-related screens
│   │   ├── category_events_screen.dart
│   │   ├── create_event_screen.dart
│   │   ├── event_details_screen.dart
│   │   ├── event_registration_screen.dart
│   │   ├── my_events_screen.dart
│   │   └── organizer_event_details_screen.dart
│   ├── home/                 # Home screens
│   │   ├── home_screen.dart
│   │   └── main_screen.dart
│   ├── notifications/        # Notification screens
│   │   └── notifications_screen.dart
│   ├── profile/              # Profile screens
│   │   ├── favorites_screen.dart
│   │   └── profile_screen.dart
│   ├── search/               # Search screens
│   │   └── search_screen.dart
│   └── tickets/              # Ticket screens
│       └── ticket_screen.dart
└── widgets/                  # Reusable widgets
    ├── event_list_card.dart
    └── featured_event_card.dart
```

## Features

- **User Authentication**: Login, signup, and role-based access (User/Organizer)
- **Event Management**: Browse, create, and manage events
- **Event Registration**: Register for events and manage tickets
- **Profile Management**: View and edit user profiles
- **Ticket System**: QR code-based ticket generation and validation
- **Search & Filter**: Search events by category, location, and more
- **Favorites**: Save favorite events for quick access
- **Notifications**: Real-time event notifications
- **Reviews**: Rate and review events

## Setup Instructions

1. **Install Flutter**: Make sure you have Flutter installed ([Installation Guide](https://docs.flutter.dev/get-started/install))

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**:
   - Update the Supabase URL and anon key in `lib/config/supabase_config.dart`
   - Run the SQL schema in your Supabase project

4. **Run the App**:
   ```bash
   flutter run
   ```

## Dependencies

- `flutter` - Flutter SDK
- `supabase_flutter` - Supabase integration
- `google_fonts` - Google Fonts
- `qr_flutter` - QR code generation
- `qr_code_scanner` - QR code scanning
- `image_picker` - Image selection
- `intl` - Internationalization
- `cached_network_image` - Image caching
- `shimmer` - Loading animations
- `uuid` - UUID generation
- `flutter_rating_bar` - Rating bars
- `share_plus` - Sharing functionality

## Architecture

The app follows a clean architecture with:
- **Models**: Data layer representing business entities
- **Screens**: UI layer with StatefulWidget/StatelessWidget
- **Widgets**: Reusable UI components
- **Config**: Configuration and theme management

## Database Schema

The app uses Supabase (PostgreSQL) with the following main tables:
- `profiles` - User profiles
- `events` - Event information
- `registrations` - Event registrations
- `favorites` - User favorites
- `reviews` - Event reviews
- `notifications` - User notifications
- `event_categories` - Event categories

## Contributing

Feel free to contribute to this project by creating pull requests or reporting issues.

## License

This project is licensed under the MIT License.
