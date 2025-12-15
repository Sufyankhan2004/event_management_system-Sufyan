# Event Management System - Database Integration

This document describes the database structure and service layer implementation for the Event Management System built with Flutter and Supabase.

## Database Structure

The system uses 9 main tables in Supabase PostgreSQL:

### 1. Users Table (profiles)
Handles user authentication and role-based differentiation.

**Fields:**
- `id` (UUID, Primary Key) - User ID from Supabase Auth
- `full_name` (Text) - User's full name
- `phone` (Text, Optional) - Phone number
- `role` (Text) - User role: 'user', 'organizer'
- `avatar_url` (Text, Optional) - Profile picture URL
- `created_at` (Timestamp) - Account creation date

### 2. Events Table (events)
Manages events created by organizers.

**Fields:**
- `id` (UUID, Primary Key) - Event ID
- `organizer_id` (UUID, Foreign Key → profiles.id) - Event creator
- `title` (Text) - Event name
- `description` (Text) - Event description
- `category` (Text) - Event category
- `location` (Text) - Event location/city
- `venue` (Text) - Specific venue name
- `event_date` (Timestamp) - Event date and time
- `end_date` (Timestamp, Optional) - Event end date
- `image_url` (Text, Optional) - Event banner image
- `ticket_price` (Numeric) - Price per ticket
- `total_seats` (Integer) - Total available seats
- `available_seats` (Integer) - Remaining seats
- `is_published` (Boolean) - Publication status
- `status` (Text) - Event status: 'upcoming', 'ongoing', 'completed', 'cancelled'
- `created_at` (Timestamp) - Event creation date

### 3. Categories Table (event_categories)
Stores dynamic event categories.

**Fields:**
- `id` (UUID, Primary Key) - Category ID
- `name` (Text, Unique) - Category name
- `description` (Text, Optional) - Category description
- `icon_url` (Text, Optional) - Category icon
- `created_at` (Timestamp) - Creation date

### 4. Registrations Table (registrations)
Tracks user registrations for events.

**Fields:**
- `id` (UUID, Primary Key) - Registration ID
- `event_id` (UUID, Foreign Key → events.id) - Associated event
- `user_id` (UUID, Foreign Key → profiles.id) - Registered user
- `ticket_code` (Text, Unique) - Unique ticket identifier
- `qr_code_data` (Text) - QR code data for verification
- `number_of_tickets` (Integer) - Number of tickets purchased
- `total_amount` (Numeric) - Total payment amount
- `payment_status` (Text) - Status: 'pending', 'completed', 'failed', 'refunded'
- `checked_in` (Boolean) - Check-in status
- `checked_in_at` (Timestamp, Optional) - Check-in timestamp
- `created_at` (Timestamp) - Registration date

### 5. Favorites Table (favorites)
Allows users to mark events as favorites.

**Fields:**
- `id` (UUID, Primary Key) - Favorite ID
- `user_id` (UUID, Foreign Key → profiles.id) - User who favorited
- `event_id` (UUID, Foreign Key → events.id) - Favorited event
- `created_at` (Timestamp) - When favorited

**Constraints:**
- Unique constraint on (user_id, event_id) - Prevent duplicate favorites

### 6. Tickets Table (tickets)
Generates and manages individual tickets for attendees.

**Fields:**
- `id` (UUID, Primary Key) - Ticket ID
- `registration_id` (UUID, Foreign Key → registrations.id) - Associated registration
- `user_id` (UUID, Foreign Key → profiles.id) - Ticket owner
- `event_id` (UUID, Foreign Key → events.id) - Event for ticket
- `ticket_code` (Text, Unique) - Individual ticket code
- `qr_code_data` (Text) - QR code for scanning
- `ticket_type` (Text) - Type: 'standard', 'vip', etc.
- `price` (Numeric) - Ticket price
- `is_used` (Boolean) - Usage status
- `used_at` (Timestamp, Optional) - When ticket was used
- `created_at` (Timestamp) - Ticket generation date

### 7. Notifications Table (notifications)
Sends notifications to users about event updates.

**Fields:**
- `id` (UUID, Primary Key) - Notification ID
- `user_id` (UUID, Foreign Key → profiles.id) - Recipient user
- `event_id` (UUID, Foreign Key → events.id, Optional) - Related event
- `title` (Text) - Notification title
- `message` (Text) - Notification message
- `type` (Text) - Type: 'event_reminder', 'registration', 'update', 'cancellation'
- `is_read` (Boolean) - Read status
- `created_at` (Timestamp) - Notification date

### 8. Organizer Statistics Table (organizer_statistics)
Tracks organizer performance and event stats.

**Fields:**
- `id` (UUID, Primary Key) - Stats ID
- `organizer_id` (UUID, Foreign Key → profiles.id) - Organizer user
- `total_events` (Integer) - Total events created
- `total_attendees` (Integer) - Total attendees across all events
- `total_revenue` (Numeric) - Total revenue generated
- `average_rating` (Numeric) - Average event rating
- `total_reviews` (Integer) - Total reviews received
- `last_updated` (Timestamp) - Last statistics update

### 9. Payments Table (payments)
Manages payments and transactions for events.

**Fields:**
- `id` (UUID, Primary Key) - Payment ID
- `registration_id` (UUID, Foreign Key → registrations.id) - Associated registration
- `user_id` (UUID, Foreign Key → profiles.id) - User who paid
- `event_id` (UUID, Foreign Key → events.id) - Event being paid for
- `amount` (Numeric) - Payment amount
- `payment_method` (Text) - Method: 'credit_card', 'debit_card', 'cash', etc.
- `payment_status` (Text) - Status: 'pending', 'processing', 'completed', 'failed', 'refunded'
- `transaction_id` (Text, Optional) - Payment gateway transaction ID
- `payment_gateway` (Text, Optional) - Gateway used: 'stripe', 'paypal', etc.
- `paid_at` (Timestamp, Optional) - Payment completion time
- `created_at` (Timestamp) - Payment initiation time

## Service Layer Architecture

The application uses a service-oriented architecture with reusable service classes:

### Base Service
`BaseService` provides common CRUD operations:
- `create()` - Insert new record
- `getById()` - Fetch single record
- `getAll()` - Fetch all records with filters
- `update()` - Update existing record
- `delete()` - Delete record
- `query()` - Custom queries with filters

### Specialized Services

1. **UserService** - User profile management
2. **EventService** - Event CRUD operations
3. **CategoryService** - Category management
4. **RegistrationService** - Event registration handling
5. **FavoriteService** - Favorites management
6. **TicketService** - Ticket generation and validation
7. **NotificationService** - Notification sending and management
8. **OrganizerStatisticsService** - Statistics tracking and updates
9. **PaymentService** - Payment processing and tracking

## Key Features

### Error Handling
All services include comprehensive try-catch blocks with meaningful error messages.

### Authentication
Services automatically handle user authentication through Supabase Auth.

### Data Validation
Input validation at both service and UI levels.

### Transaction Safety
Related operations (e.g., registration + payment + ticket generation) are handled atomically.

### Code Reusability
Service layer promotes DRY (Don't Repeat Yourself) principles.

## Usage Example

```dart
// Initialize services
final eventService = EventService();
final registrationService = RegistrationService();

// Create an event
final event = await eventService.createEvent({
  'title': 'Tech Conference 2024',
  'description': 'Annual tech conference',
  'category': 'Technology',
  // ... other fields
});

// Register for event
final registration = await registrationService.createRegistration(
  eventId: event.id,
  numberOfTickets: 2,
  totalAmount: 100.0,
);
```

## Best Practices

1. Always use service layer instead of direct Supabase calls
2. Handle errors gracefully with user-friendly messages
3. Update statistics after major operations
4. Send notifications for important events
5. Validate data before database operations
6. Use transactions for related operations

## Migration from Direct Queries

The codebase has been fully refactored from direct Supabase queries to service layer:
- ✅ All screens updated
- ✅ Consistent error handling
- ✅ Improved maintainability
- ✅ Better separation of concerns
- ✅ Easier testing and debugging
