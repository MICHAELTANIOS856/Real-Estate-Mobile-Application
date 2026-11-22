# Firebase setup and listing renewal

## Included on this feature branch

- Arabic email/password registration and sign-in, with sign-out.
- Signed-in owner upload form, multiple photos, validation and retry-safe photo reuse.
- Public available-listing feed, details gallery and publication date.
- My Properties queries the signed-in owner's UID, with a second UI ownership check.
- Renewal changes `lastConfirmedAt` without changing the original publication date.
- In-app owner notices after 3 days, a final warning after 6 days, and an expired notice after 7 days.
- Public discovery hides expired listings and rechecks the clock once a minute while subscribed. Owners can renew expired listings to show them again.
- Viewing requests require sign-in. Draft rules reject requests for expired listings.

## Important limits

This is an implementation branch, not a deployed Firebase release. No Firebase billing plan or console settings were changed, and the included rules have not been deployed or emulator-tested.

The current expiry filter and notices use the device clock. They are useful app behavior, not server-enforced removal. The draft public read rule still allows direct access to documents with `status: available`, including expired ones. Owner notices appear inside My Properties, not as notifications when the app is closed. There is no FCM delivery, scheduled function, or background reminder service in this branch.

Firebase Storage currently requires Blaze to retain bucket access. Do not assume photo uploads work on Spark. Confirm the project's existing plan first. Do not enable billing without the owner's separate approval. No-cost allowances on Blaze do not mean a project has no billing account or no possible charges.

## Deployment checks

1. Confirm the intended Firebase project and its current billing plan. The checked-in options target the existing project; do not create a replacement by accident.
2. Enable Email/Password authentication in Firebase Authentication.
3. Review Firestore and Storage rules against existing data, then run emulator tests before any deployment. Creating a listing requires `ownerId` equal to the authenticated UID, with server timestamps. Renewal permits the owner to update only `lastConfirmedAt`.
4. Verify Storage availability under the project's current plan. If billing remains disabled and Storage is unavailable, choose an approved image-storage alternative before claiming upload is usable.
5. Audit existing documents. Records without `lastConfirmedAt` currently count as expired. Preserve known `createdAt` values. Do not silently invent publication dates. Decide whether owners must renew old records or an administrator will perform a reviewed migration.
6. Test with two owner accounts: each My Properties view must contain only its own listings. Public browsing should show all non-expired available listings, regardless of owner.
7. Test sign-up, sign-in, sign-out, rejected uploads, successful multi-photo upload, renewal, and viewing request creation against the actual configured project.

## Remaining backend work for background reminders

The desired schedule is based on the latest renewal: notice at day 3, final notice at day 6, hidden after day 7. A renewal starts a new cycle, including after expiry.

A production backend should use server time and an explicit `expiresAt`. Public queries and rules must agree about visibility, so expired records cannot be accessed through a direct read merely because the client hid them. A scheduled transition or supported server-time query/rules design needs emulator validation before rollout.

For push reminders, add device-token registration and removal, notification permission UX, and a trusted sender. Store reminder-cycle markers to avoid duplicates. Immediately before sending or expiring, recheck the latest renewal timestamp to avoid racing an owner renewal. Delivery is best-effort; the app should still show the current status when opened. Only choose and deploy a scheduler after reviewing its billing requirements and getting approval for any billing change.

## Local checks

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

Automated tests cover gallery fallback, auth and upload form validation/layout, publication date formatting, day-3/day-6 notices, day-7 expiry, renewed status, and owner-list UI isolation. They do not prove live Firebase authentication, Storage access, deployed security, push delivery, or a release build. Informational Material import deprecations were reported by the preview Flutter SDK used during development.

## Official references

- Firebase Storage plan requirement: https://firebase.google.com/docs/storage/faqs-storage-changes-announced-sept-2024
- Firebase pricing: https://firebase.google.com/pricing
- Scheduled functions and billing: https://firebase.google.com/docs/functions/schedule-functions
- Firebase Cloud Messaging: https://firebase.google.com/docs/cloud-messaging
