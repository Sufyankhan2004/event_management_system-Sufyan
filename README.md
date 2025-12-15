# Event Management System - Flutter + Supabase

A comprehensive Flutter application for event management with beautiful UI and Supabase backend integration.

![Flutter](https://img.shields.io/badge/Flutter-3.9.0+-blue.svg)
![Supabase](https://img.shields.io/badge/Supabase-Latest-green.svg)

## 🌟 Features

- **User Authentication** - Secure login/signup with role-based access (User/Organizer)
- **Event Management** - Browse, create, edit, and manage events
- **Event Registration** - Easy registration with QR code tickets
- **Profile Management** - Customize user profiles and preferences
- **Ticket System** - QR code-based ticket generation and validation
- **Search & Filter** - Advanced search by category, location, date, and more
- **Favorites** - Save and manage favorite events
- **Notifications** - Real-time event updates and reminders
- **Reviews** - Rate and review attended events
- **Beautiful UI** - Modern Material Design with smooth animations

## 📁 Project Structure

This project follows a clean, modular architecture:

```
lib/
├── main.dart                 # Application entry point
├── config/                   # Configuration files
├── models/                   # Data models
├── screens/                  # UI screens (organized by feature)
├── widgets/                  # Reusable widgets
```

For detailed structure, see [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Supabase account

### Installation

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
   - Update credentials in `lib/config/supabase_config.dart`
   - Run the SQL schema provided in your Supabase project

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

*(Add your app screenshots here)*

## 🛠️ Technologies Used

- **Flutter** - UI framework
- **Supabase** - Backend and database
- **Google Fonts** - Typography
- **Cached Network Image** - Image caching
- **QR Code** - Ticket generation
- **Material Design 3** - UI components

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**Sufyan Khan**
- GitHub: [@Sufyankhan2004](https://github.com/Sufyankhan2004)

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

## 📝 Notes

This is a semester project demonstrating Flutter development with Supabase integration.
The app includes best practices for Flutter architecture and clean code organization.
