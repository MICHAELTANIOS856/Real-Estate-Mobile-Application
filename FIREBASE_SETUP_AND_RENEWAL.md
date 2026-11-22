# Firebase setup and listing renewal

## Included on this feature branch

- Arabic email/password registration and sign-in, with sign-out.
- Signed-in owner upload form, up to four compressed photos, validation and retry-safe compression reuse. New photos are stored as Firestore byte fields, without Cloud Storage.
- Public available-listing feed, details gallery and publication date.
- My Properties queries the signed-in owner's UID, with a second UI ownership check.
- Renewal changes `lastConfirmedAt` without changing the original publication date.
- In-app owner notices after 3 days, a final warning after 6 days, and an expired notice after 7 days.
- Public discovery hides expired listings and rechecks the clock once a minute while subscribed. Owners can renew expired listings to show them again.
- Viewing requests require sign-in. Draft rules reject requests for expired listings.

## Important limits

This is an implementation branch, not a deployed Firebase release. No Firebase billing plan or console settings were changed, and the included rules have not been deployed. The local Firestore emulator passed 12 photo-size/ownership/read/renewal assertions; this is not a live-project test.

The current expiry filter and notices use the device clock. They are useful app behavior, not server-enforced removal. The draft public read rule still allows direct access to documents with `status: available`, including expired ones. Owner notices appear inside My Properties, not as notifications when the app is closed. There is no FCM delivery, scheduled function, or background reminder service in this branch.

## Spark demo photos

The owner confirmed that the project uses Spark and approved thumbnail photos in Firestore. New listings no longer use Firebase Storage. Each listing stores `photoBytes`, a list of one to four JPEG byte values. Each photo is at most 122,880 bytes (120 KiB), so the maximum combined image payload is 491,520 bytes, leaving more than half the 1,048,576-byte document limit for metadata. Rules also bound all text fields and enforce each photo's byte length and the photo count. The client resizes to at most 960 pixels on the longest edge, lowers JPEG quality, then shrinks further if needed. Images are never upscaled. Only the first frame is kept, and EXIF metadata is removed after applying orientation. Unsupported formats, inputs over 10 MiB, and images over 24 megapixels are rejected before decoding. Prefer JPEG or PNG; HEIC is not supported by the compressor.

`firestore.indexes.json` exempts `photoBytes` from indexing. Deploy that exemption with the rules. Existing URL-based photos still render, but old Firebase Storage URLs may be inaccessible on Spark. Originals are not retained and quality is intentionally reduced. Image fields are returned with every listing read, so this is a small-demo tradeoff, not a scalable photo-hosting design. The existing public feed is not paginated; keep the demo dataset small.

Spark quotas are finite: the official limits currently list 1 GiB stored data, 50,000 reads/day, 20,000 writes/day, and 10 GiB outbound transfer/month. Watch usage. This change does not guarantee unlimited free traffic and does not enable billing. Background scheduling and production image hosting remain separate decisions.

## Deployment checks

1. Confirm the intended Firebase project. The checked-in options target the existing project; do not create a replacement or enable billing.
2. Enable Email/Password authentication in Firebase Authentication.
3. Review Firestore and Storage rules against existing data, then repeat the supplied emulator tests before any deployment. Creating a listing requires `ownerId` equal to the authenticated UID, with server timestamps. Renewal permits the owner to update only `lastConfirmedAt`.
4. Review and deploy only Firestore rules and indexes, for example `firebase deploy --only firestore:rules,firestore:indexes` after verifying the active project. No Storage setup/deployment is needed for new photos. `storage.rules` is a deny-all reference only and is no longer wired into firebase.json. Do not deploy it over a used bucket without reviewing the effect on existing data.
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

Photo rules can be checked locally without account login or production writes:

```sh
cd test/firestore
npm install
npx firebase emulators:exec --config ../../firebase.emulator.json --only firestore --project demo-real-estate 'node photos.cjs'
```

The demo project ID keeps emulator calls separate from production. Java 11+ is needed by the pinned emulator CLI. Expected denied-write logs are part of negative assertions.

Automated tests cover compression/caps, JPEG memory rendering, legacy URL fallback, gallery fallback, auth and upload form validation/layout, publication date formatting, day-3/day-6 notices, day-7 expiry, renewed status, and owner-list UI isolation. They do not prove live Firebase authentication, Storage access, deployed security, push delivery, or a release build. Informational Material import deprecations were reported by the preview Flutter SDK used during development.

## Official references

- Firebase Storage plan requirement: https://firebase.google.com/docs/storage/faqs-storage-changes-announced-sept-2024
- Firestore quotas and document limit: https://firebase.google.com/docs/firestore/quotas
- Firestore size calculation: https://firebase.google.com/docs/firestore/storage-size
- Firebase pricing: https://firebase.google.com/pricing
- Scheduled functions and billing: https://firebase.google.com/docs/functions/schedule-functions
- Firebase Cloud Messaging: https://firebase.google.com/docs/cloud-messaging
