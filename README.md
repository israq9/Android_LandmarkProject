Landmark Manager

A Flutter application for managing and recording geographical landmarks. This app allows users to view, add, edit, and delete landmark records with image support and location data.


Features
•View Records: List all saved landmarks with their titles, IDs, and coordinates.
•Data Persistence: Locally manage landmark data (Create, Read, Update, Delete)
•Image Handling: efficient image loading using cached_network_image.
•Map Integration: (Inferred) Coordinates display suggests mapping capabilities.


Prerequisites

•Flutter SDK (Latest stable version recommended)
•Dart SDK
•Android Studio or VS Code with Flutter extensions
•An Android Emulator or physical device connected via USB


Installation

Debug Mode (Development)
To run the app on your connected device or emulator 
flutter run

Project Structure

•lib/main.dart: Entry point of the application.
•lib/routes.dart: Route definitions for navigation (using GoRouter).
•lib/providers/: State management logic (e.g.,LandmarkProvider).
•lib/models/: Data models (e.g., Landmark).
•lib/views/: UI screens (e.g., RecordsScreen)
