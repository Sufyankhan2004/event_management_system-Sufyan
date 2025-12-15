# Event Management System

A Flutter-based Event Management System with role-based authentication for Organizers and Attendees.

## Features

### For Attendees
- Browse and discover events
- Search events by title, location, or description
- Register for events
- View registered events and tickets
- QR code-based check-in

### For Organizers
- Dashboard with analytics and statistics
- Create, edit, and delete events
- Manage event details (date, time, location, description)
- View list of attendees for each event
- Track event registrations and capacity

## Architecture

The app follows a clean, role-based architecture:

```
lib/
├── auth/               # Authentication screens
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   └── splash_screen.dart
├── services/           # Business logic and API services
│   ├── auth_service.dart
│   ├── event_service.dart
│   └── registration_service.dart
├── models/             # Data models
│   ├── event.dart
│   ├── user_profile.dart
│   └── registration.dart
├── attendee/           # Attendee-specific screens
│   ├── attendee_main_screen.dart
│   ├── attendee_home_screen.dart
│   ├── attendee_events_screen.dart
│   ├── attendee_search_screen.dart
│   └── attendee_profile_screen.dart
├── organizer/          # Organizer-specific screens
│   ├── organizer_main_screen.dart
│   ├── organizer_dashboard_screen.dart
│   ├── organizer_events_screen.dart
│   └── organizer_profile_screen.dart
├── screens/            # Shared screens
├── widgets/            # Reusable widgets
└── config/             # Configuration files
```

## Role-Based Access

The system implements strict role-based routing:

1. **Signup/Login**: Users select their role (Attendee or Organizer) during signup
2. **Authentication**: Role is validated on login
3. **Routing**: Users are directed to role-specific dashboards
   - Attendees → Attendee Home (browse events)
   - Organizers → Organizer Dashboard (analytics & event management)
4. **Navigation**: Separate bottom navigation for each role

## Getting Started

### Prerequisites
- Flutter SDK (>=3.9.0)
- Supabase account

### Installation

1. Clone the repository
```bash
git clone https://github.com/Sufyankhan2004/event_management_system-Sufyan.git
cd event_management_system-Sufyan
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Supabase
- Update `lib/config/supabase_config.dart` with your Supabase URL and anon key

4. Run the app
```bash
flutter run
```

## Database Schema

The app uses Supabase with the following main tables:

- `profiles`: User profiles with role information
- `events`: Event details and metadata
- `registrations`: Event registrations and tickets
- `event_categories`: Event categories
- `favorites`: User favorites

## Technologies Used

- **Flutter**: Cross-platform mobile development
- **Supabase**: Backend-as-a-Service (authentication, database, storage)
- **Google Fonts**: Typography
- **Cached Network Image**: Image caching
- **QR Flutter**: QR code generation
- **Intl**: Date formatting

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is created as a semester project.
