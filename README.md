# Event Management System - Sufyan

A comprehensive Flutter-based Event Management System with Supabase backend integration for managing events, registrations, tickets, and payments.

## 🌟 Features

### For Attendees
- Browse and search events by category, location, and date
- Register for events and purchase tickets
- Receive digital tickets with QR codes
- Favorite events for later
- Get notifications about event updates
- View registration history
- Check-in at events

### For Organizers
- Create and manage events
- Track registrations and attendance
- View event analytics and statistics
- Manage ticket sales and revenue
- Send notifications to attendees
- Monitor event performance

## 🏗️ Architecture

### Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **State Management**: StatefulWidget
- **UI Components**: Material Design 3
- **Authentication**: Supabase Auth

### Database Structure
The system uses 9 main tables:
1. **profiles** - User profiles and roles
2. **event_categories** - Event categorization
3. **events** - Event management
4. **registrations** - Event registrations
5. **favorites** - User favorites
6. **tickets** - Digital tickets
7. **notifications** - User notifications
8. **organizer_statistics** - Performance tracking
9. **payments** - Payment management

See [DATABASE_STRUCTURE.md](DATABASE_STRUCTURE.md) for detailed schema documentation.

### Service Layer
The app uses a clean service-oriented architecture:
- **BaseService** - Common CRUD operations
- **UserService** - User management
- **EventService** - Event operations
- **CategoryService** - Category management
- **RegistrationService** - Registration handling
- **FavoriteService** - Favorites management
- **TicketService** - Ticket generation
- **NotificationService** - Notifications
- **OrganizerStatisticsService** - Analytics
- **PaymentService** - Payment processing

See [SERVICE_API.md](SERVICE_API.md) for complete API reference.

## 📦 Installation

### Prerequisites
- Flutter SDK (>= 3.9.0)
- Dart SDK
- Supabase account
- Android Studio / VS Code

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Sufyankhan2004/event_management_system-Sufyan.git
   cd event_management_system-Sufyan
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a Supabase project at [supabase.com](https://supabase.com)
   - Run the SQL schema: `schema.sql`
   - Apply RLS policies: `rls_policies.sql`
   - Update `lib/config/supabase_config.dart` with your credentials:
     ```dart
     const String supabaseUrl = 'YOUR_SUPABASE_URL';
     const String supabaseAnonKey = 'YOUR_ANON_KEY';
     ```

4. **Create Storage Buckets**
   - Create a public bucket named `event-images` in Supabase Storage

5. **Run the app**
   ```bash
   flutter run
   ```

## 📚 Documentation

- [Database Structure](DATABASE_STRUCTURE.md) - Complete database schema
- [Service API Reference](SERVICE_API.md) - Service layer documentation
- [Security Guidelines](SECURITY.md) - Security best practices

## 🔒 Security

This project implements several security measures:
- Row Level Security (RLS) on all tables
- Authentication-based access control
- Input validation
- Secure error handling
- SQL injection prevention

**Important**: Before deploying to production:
1. Enable RLS policies (see `rls_policies.sql`)
2. Replace mock payment with real payment gateway
3. Move credentials to environment variables
4. Review [SECURITY.md](SECURITY.md)

## 🚀 Usage

### As an Attendee
1. Sign up with email/password
2. Browse events on the home screen
3. Search or filter by category
4. Register for events
5. View tickets in "My Events"
6. Check notifications

### As an Organizer
1. Sign up with role "Organizer"
2. Create events from the home screen
3. Manage events in "My Events"
4. View registrations and statistics
5. Send notifications to attendees

## 🛠️ Development

### Project Structure
```
lib/
├── config/           # Configuration files
├── models/           # Data models
├── services/         # Service layer
├── screens/          # UI screens
│   ├── auth/        # Authentication
│   ├── events/      # Event management
│   ├── home/        # Home and navigation
│   ├── notifications/
│   ├── profile/     # User profile
│   ├── search/      # Event search
│   └── tickets/     # Ticket management
└── widgets/          # Reusable widgets
```

### Key Dependencies
- `supabase_flutter` - Supabase integration
- `google_fonts` - Typography
- `qr_flutter` - QR code generation
- `qr_code_scanner` - QR scanning
- `image_picker` - Image selection
- `cached_network_image` - Image caching
- `uuid` - Unique ID generation

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is a semester project for educational purposes.

## 👨‍💻 Author

**Sufyan Khan**
- GitHub: [@Sufyankhan2004](https://github.com/Sufyankhan2004)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- All contributors and testers

## 📞 Support

For support, email or create an issue in the repository.

---

Made with ❤️ using Flutter and Supabase

