# PFW Connect

PFW Connect is a concept Flutter application that unifies essential student-life features in a single experience:

- **Carpooling:** Offer or request rides from fellow students, complete with expiring ride chats once the trip date passes.
- **Marketplace:** Buy and sell second-hand goods with temporary conversations that close after the item is sold.
- **Social feed:** Share campus updates, react, and comment in a lightweight social hub.

> ℹ️ The project focuses on UI and local state management. It does not connect to a backend service, but it models the lifecycle of ride and marketplace chats to inspire a production implementation.

## Getting started

1. Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
2. From the project root run:

   ```bash
   flutter pub get
   flutter run
   ```

3. Explore the three tabs to see how the experiences connect for students.

## Project structure

- `lib/models` – Shared data models for rides, listings, posts, and chats.
- `lib/app_state.dart` – Centralized `ChangeNotifier` that keeps the mock data in sync.
- `lib/screens` – Tab-specific experiences and the reusable chat interface.

Feel free to build on these foundations with real authentication, persistence, or push notifications.
