# Real Estate Egypt

A Flutter mobile application for discovering and listing rental and sale properties across Egypt. The project aims to help property seekers find relevant, up-to-date listings and help owners publish and manage their properties.

## Planned Features

- Browse properties for rent or sale
- Search by governorate, city, district, and price
- Filter by property type and features
- View property details, photos, and location
- Save favorite properties
- Send inquiries and request viewings inside the app
- Let owners create and manage listings
- Confirm listing availability to help keep information current
- Report listings for review

## Technology

- **Flutter** and **Dart** for the mobile application
- **Firebase** for authentication (Firebase Auth), database (Cloud Firestore), and image storage (Firebase Storage)

The original proposal named Supabase; this branch uses Firebase. Enable Email/Password in Firebase Authentication, provision Firebase Storage, and review and deploy the included Firestore/Storage rules to the intended project. These rules do not enable the sign-in provider. No live configuration has been deployed by this change.

## Implemented in this branch

- Arabic email/password registration, sign-in, and sign-out.
- Signed-in owners can publish property details and multiple gallery photos.
- The home screen reads available listings from Firestore. Empty and failed reads do not silently show fake listings.
- Property details show the uploaded gallery and description.

Run `flutter pub get`, `flutter analyze`, and `flutter test` before `flutter run`. The original proposal describes future features beyond these pages. Favorites remain local to the running app; owner editing, moderation, phone OTP, and notifications are not included in this pass.


## Project Status

This project is under development as an academic project. Features and technical details may change as the project evolves.

## Initial Business Approach

The application is planned to be free for property owners and seekers during its initial launch. Optional revenue features may be considered in the future.

## Target Market

The application is designed for users across all governorates of Egypt. The initial launch is planned as a pilot in a selected area before expanding.

## License

No open-source license has been added yet.
