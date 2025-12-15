# Service Layer API Documentation

Complete API reference for all service classes in the Event Management System.

## Table of Contents
1. [UserService](#userservice)
2. [EventService](#eventservice)
3. [CategoryService](#categoryservice)
4. [RegistrationService](#registrationservice)
5. [FavoriteService](#favoriteservice)
6. [TicketService](#ticketservice)
7. [NotificationService](#notificationservice)
8. [OrganizerStatisticsService](#organizerstatisticsservice)
9. [PaymentService](#paymentservice)

---

## UserService

Manages user profile operations.

### Methods

#### `getUserProfile(String userId)`
Get user profile by ID.
```dart
final profile = await userService.getUserProfile('user-id');
```

#### `getCurrentUserProfile()`
Get current authenticated user's profile.
```dart
final profile = await userService.getCurrentUserProfile();
```

#### `updateUserProfile(String userId, Map<String, dynamic> data)`
Update user profile.
```dart
await userService.updateUserProfile('user-id', {
  'full_name': 'John Doe',
  'phone': '+1234567890',
});
```

#### `isOrganizer(String userId)`
Check if user is an organizer.
```dart
final isOrg = await userService.isOrganizer('user-id');
```

---

## EventService

Handles all event-related operations.

### Methods

#### `createEvent(Map<String, dynamic> eventData)`
Create a new event. Automatically sets organizer_id.
```dart
final event = await eventService.createEvent({
  'title': 'Tech Conference',
  'description': 'Annual tech event',
  'category': 'Technology',
  'location': 'New York',
  'venue': 'Convention Center',
  'event_date': DateTime.now().toIso8601String(),
  'ticket_price': 50.0,
  'total_seats': 100,
  'available_seats': 100,
  'is_published': true,
  'status': 'upcoming',
});
```

#### `getEvent(String eventId)`
Get event details by ID.
```dart
final event = await eventService.getEvent('event-id');
```

#### `getUpcomingEvents({int? limit})`
Get upcoming published events.
```dart
final events = await eventService.getUpcomingEvents(limit: 10);
```

#### `getFeaturedEvents({int? limit})`
Get featured events.
```dart
final events = await eventService.getFeaturedEvents(limit: 5);
```

#### `getEventsByCategory(String category, {int? limit})`
Get events by category.
```dart
final events = await eventService.getEventsByCategory('Music');
```

#### `getMyEvents({int? limit})`
Get current user's created events.
```dart
final events = await eventService.getMyEvents();
```

#### `updateEvent(String eventId, Map<String, dynamic> data)`
Update event details.
```dart
await eventService.updateEvent('event-id', {
  'title': 'Updated Title',
  'ticket_price': 75.0,
});
```

#### `deleteEvent(String eventId)`
Delete an event.
```dart
await eventService.deleteEvent('event-id');
```

#### `searchEvents(String query)`
Search events by title or description.
```dart
final results = await eventService.searchEvents('conference');
```

---

## CategoryService

Manages event categories.

### Methods

#### `getAllCategories()`
Get all categories.
```dart
final categories = await categoryService.getAllCategories();
```

#### `getCategoryNames()`
Get category names for dropdowns.
```dart
final names = await categoryService.getCategoryNames();
```

#### `createCategory(Map<String, dynamic> categoryData)`
Create a new category.
```dart
final category = await categoryService.createCategory({
  'name': 'Sports',
  'description': 'Sports events',
});
```

---

## RegistrationService

Handles event registrations.

### Methods

#### `createRegistration({required String eventId, required int numberOfTickets, required double totalAmount, String paymentStatus})`
Create a new registration. Automatically generates ticket code and updates available seats.
```dart
final registration = await registrationService.createRegistration(
  eventId: 'event-id',
  numberOfTickets: 2,
  totalAmount: 100.0,
  paymentStatus: 'completed',
);
```

#### `getUserRegistrations({String? userId})`
Get user's registrations.
```dart
final registrations = await registrationService.getUserRegistrations();
```

#### `getEventRegistrations(String eventId)`
Get all registrations for an event.
```dart
final registrations = await registrationService.getEventRegistrations('event-id');
```

#### `isUserRegistered(String eventId, {String? userId})`
Check if user is registered for event.
```dart
final isRegistered = await registrationService.isUserRegistered('event-id');
```

#### `checkIn(String registrationId)`
Check in a registration.
```dart
await registrationService.checkIn('registration-id');
```

#### `cancelRegistration(String registrationId)`
Cancel a registration and return seats.
```dart
await registrationService.cancelRegistration('registration-id');
```

---

## FavoriteService

Manages favorite events.

### Methods

#### `addToFavorites(String eventId)`
Add event to favorites.
```dart
await favoriteService.addToFavorites('event-id');
```

#### `removeFromFavorites(String eventId)`
Remove event from favorites.
```dart
await favoriteService.removeFromFavorites('event-id');
```

#### `toggleFavorite(String eventId)`
Toggle favorite status. Returns new status (true if now favorite).
```dart
final isFavorite = await favoriteService.toggleFavorite('event-id');
```

#### `isFavorite(String eventId, {String? userId})`
Check if event is favorited.
```dart
final isFav = await favoriteService.isFavorite('event-id');
```

#### `getUserFavorites({String? userId})`
Get user's favorite events.
```dart
final favorites = await favoriteService.getUserFavorites();
```

#### `getUserFavoritesWithEvents({String? userId})`
Get favorites with full event details.
```dart
final data = await favoriteService.getUserFavoritesWithEvents();
```

---

## TicketService

Generates and manages tickets.

### Methods

#### `generateTickets({required String registrationId, required String eventId, required int numberOfTickets, required double pricePerTicket, String ticketType})`
Generate tickets for a registration.
```dart
final tickets = await ticketService.generateTickets(
  registrationId: 'reg-id',
  eventId: 'event-id',
  numberOfTickets: 2,
  pricePerTicket: 50.0,
  ticketType: 'standard',
);
```

#### `getTicketByCode(String ticketCode)`
Get ticket by its code.
```dart
final ticket = await ticketService.getTicketByCode('ABC123');
```

#### `getUserTickets({String? userId})`
Get user's tickets.
```dart
final tickets = await ticketService.getUserTickets();
```

#### `validateAndUseTicket(String ticketCode)`
Validate and mark ticket as used.
```dart
final ticket = await ticketService.validateAndUseTicket('ABC123');
```

#### `isTicketValid(String ticketCode)`
Check if ticket is valid and unused.
```dart
final isValid = await ticketService.isTicketValid('ABC123');
```

---

## NotificationService

Manages user notifications.

### Methods

#### `createNotification({required String userId, String? eventId, required String title, required String message, required String type})`
Create a notification.
```dart
await notificationService.createNotification(
  userId: 'user-id',
  eventId: 'event-id',
  title: 'Event Update',
  message: 'Event has been updated',
  type: 'update',
);
```

#### `getUserNotifications({String? userId})`
Get user's notifications.
```dart
final notifications = await notificationService.getUserNotifications();
```

#### `getUnreadNotifications({String? userId})`
Get unread notifications.
```dart
final unread = await notificationService.getUnreadNotifications();
```

#### `markAsRead(String notificationId)`
Mark notification as read.
```dart
await notificationService.markAsRead('notification-id');
```

#### `markAllAsRead({String? userId})`
Mark all user notifications as read.
```dart
await notificationService.markAllAsRead();
```

#### `sendRegistrationConfirmation({required String userId, required String eventId, required String eventTitle})`
Send registration confirmation notification.
```dart
await notificationService.sendRegistrationConfirmation(
  userId: 'user-id',
  eventId: 'event-id',
  eventTitle: 'Tech Conference',
);
```

---

## OrganizerStatisticsService

Tracks organizer performance.

### Methods

#### `getOrganizerStatistics(String organizerId)`
Get organizer statistics.
```dart
final stats = await statsService.getOrganizerStatistics('organizer-id');
```

#### `updateStatistics(String organizerId)`
Update statistics by recalculating from events and registrations.
```dart
await statsService.updateStatistics('organizer-id');
```

#### `incrementEventCount(String organizerId)`
Increment event count for organizer.
```dart
await statsService.incrementEventCount('organizer-id');
```

#### `getTopOrganizersByRevenue({int limit})`
Get top organizers by revenue.
```dart
final topOrganizers = await statsService.getTopOrganizersByRevenue(limit: 10);
```

---

## PaymentService

Handles payments and transactions.

### Methods

#### `createPayment({required String registrationId, required String eventId, required double amount, required String paymentMethod, ...})`
Create a payment record.
```dart
final payment = await paymentService.createPayment(
  registrationId: 'reg-id',
  eventId: 'event-id',
  amount: 100.0,
  paymentMethod: 'credit_card',
  paymentStatus: 'pending',
);
```

#### `processPayment({required String registrationId, required String eventId, required double amount, required String paymentMethod, ...})`
Process a payment (creates and completes).
```dart
final payment = await paymentService.processPayment(
  registrationId: 'reg-id',
  eventId: 'event-id',
  amount: 100.0,
  paymentMethod: 'credit_card',
);
```

#### `updatePaymentStatus(String paymentId, String status, {String? transactionId})`
Update payment status.
```dart
await paymentService.updatePaymentStatus(
  'payment-id',
  'completed',
  transactionId: 'TXN123',
);
```

#### `getEventRevenue(String eventId)`
Get total revenue for an event.
```dart
final revenue = await paymentService.getEventRevenue('event-id');
```

#### `getPaymentStatistics({String? eventId, String? userId})`
Get payment statistics.
```dart
final stats = await paymentService.getPaymentStatistics(eventId: 'event-id');
```

---

## Error Handling

All services throw exceptions with descriptive messages. Wrap calls in try-catch:

```dart
try {
  final event = await eventService.createEvent(eventData);
} catch (e) {
  print('Error creating event: $e');
  // Show user-friendly error message
}
```

## Import Services

```dart
import 'package:event_semester_sufyan/services/services.dart';

// Initialize services
final eventService = EventService();
final userService = UserService();
// ... other services
```
