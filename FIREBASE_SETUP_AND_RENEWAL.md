## Eight sample properties and real listings

The debug owner menu now adds eight varied sample properties based on the original
sample catalog: rent/sale, apartments/villa/duplex, Cairo/Giza/Alexandria/Luxor and
varied prices. Four preserve the original sample titles/prices, all prefixed demo
only. The first fixture is Cairo/rent, visible with the default consumer filters.
Clear search text and select All governorates to see the current mode's samples.
An owner must tap Add demo properties once; consumers then see them immediately
from Firestore. We do not write the user's database ourselves.

The same tap renews existing marked fixtures and adds missing ones, not duplicates.
It never edits a real listing, even if a real listing has a colliding ID. Cleanup
checks both ownerId and isDemo. Real and demo listings share the regular feed,
filter/count, renewal and seven-day expiry behavior. There is no fake-data fallback
that hides real listings or replaces results when the database is empty.

## Optional manual demo listings (debug only)

Nothing is seeded automatically. With `flutter run` (debug), sign in as an OWNER,
open the top menu on My Properties, choose Add demo properties, then confirm.
This creates at most eight fixtures for that owner, rent and sale across Cairo/Giza/Alexandria/Luxor, with deterministic
IDs, `isDemo: true`, explicit Arabic demo-only titles/descriptions and a tiny solid
thumbnail. No real address, person or contact is used. They use the owner's real UID
so the normal consumer viewing-request flow can be tested with another account.

Sign out and sign in as CONSUMER using a separate email. Find the demo in Luxor
under rent or sale, open it, and send a test viewing request with your own test
contact data. It is a Firestore test record, not an actual appointment or message
to a property owner. To remove fixtures, sign back in as their owner and choose
Delete my demo properties, then confirm. Only that owner's `isDemo` listings are
deleted. Real listings cannot be marked demo later or deleted by these rules.
Test viewing-request records remain, clearly identified by the demo property title;
clean these separately in an isolated test project if desired. Do not use other
people's personal data for testing. The menu and seed service are disabled in
release builds. Marked records already created are NOT automatically removed from
the database by a release build, so use the cleanup menu before a real demo/release.

The updated Firestore rules must be reviewed and republished for fixture deletion
and signed-in reads. 34 emulator assertions pass, including fixture ownership,
real-listing deletion denial, and denial of relabeling a real listing as demo.

---

## Password reset

On sign-in, enter your account email then tap Forgot Password. Firebase Auth
sends its standard password-reset link by email; the app does not send or handle
a numeric reset code. Check spam too. The account owner can edit the email in
Firebase Console > Authentication > Templates > Password reset. No template or
Firebase settings were changed here. Invalid email and network/rate-limit errors
have Arabic messages. Missing-account responses use the same neutral confirmation
as success so the app does not reveal which emails have accounts. Actual email
delivery and reset completion still need checking on the intended Firebase project.

## Sign-in required before home

Signed-out startup now opens sign-in/sign-up, not the consumer home. After
successful authentication the persisted role chooses the owner or consumer home.
Signing out returns to authentication. Listing reads also require Firebase Auth;
anonymous property reads are denied by the updated Firestore rules. Signed-in
consumers can browse, while owners still start at their own properties.

Review and republish `firestore.rules` for this change. Keep the current deployed
rules first and use an isolated test project/emulator if the project is shared.
This does not enable a paid plan or change existing data. Stop and restart the
app after pulling. The owner home title is now only My Properties, with no subtitle.
The updated rules suite passes 34 assertions including anonymous-read denial and
signed-in consumer read success.

---

## Account roles and the new start screen

Sign-up now asks for owner or consumer (no default), name, email, password,
password confirmation and an 11-digit Egyptian mobile number (010/011/012/015).
Passwords are handled only by Firebase Auth, never stored in Firestore.
`users/{uid}` stores only name, phone, role and createdAt. Profile reads are
private to that UID. A client can create its own profile once but cannot later
change its role, delete its profile or write someone else's profile.

Owners start directly at My Properties with upload and renewal. They do not see
the consumer search, governorate filters or rent/sale selector. The upload form
still asks whether the property is for rent or sale. Signed-in consumers retain browsing; consumers cannot upload or renew. Viewing requests require
a consumer account. Owners can open their listing details without a viewing-request
button. Role checks run in both the client service and Firestore rules.

Existing Auth accounts with no profile must choose a type and enter their name
and mobile once at next sign-in. No existing Auth user or listing is deleted or
automatically assigned an owner role. If an old owner chooses consumer, their
listings remain stored but are not shown as their start screen. Choose owner for
an account that manages existing listings. Changing a saved role needs a reviewed
admin migration, there is no client role-switch feature.

Auth creation and Firestore profile creation cannot be one atomic transaction.
If profile saving fails, the app keeps the new signed-in Auth account and opens
Complete Profile so saving can be retried, without trying to register the same
email again. A rules/connection error does not silently grant owner access.

### Before testing this update

1. Keep a copy of the CURRENT deployed Firestore rules. Check whether the project
   contains shared or important data. First test in the emulator or an isolated
   Firebase project; do not overwrite shared production rules blindly.
2. Review and publish the updated `firestore.rules` (including `/users`) to the
   intended test project. The previous rules do not allow profile creation.
   No new indexes or paid services are needed for roles. Keep the existing
   photoBytes index exemption from the setup below.
3. Stop the running Flutter process, pull `feature/auth-and-owner-upload`, run
   `flutter pub get`, then `flutter run`. Use a full restart, not only hot reload.
   Preserve/stash local changes before pulling; do not use reset --hard.
4. Register one owner and one consumer with separate emails. Check that password
   and confirmation are shown, invalid phones/mismatched passwords are rejected,
   and a type must be chosen. Sign out/in and restart to check that the role stays.
5. Owner A uploads; owner B must not see A's listings in My Properties. Consumer
   sees current listings, has no upload button and can request a viewing. Consumer
   direct upload/renew attempts must be denied by rules. Old accounts see Complete
   Profile rather than being assumed to be owners.

Switching Git branches DOES NOT roll back deployed Firebase rules. Keep both
versions and a deliberate deployment rollback plan. No live Firebase rules,
accounts, data or billing settings were changed while preparing this update.

Verification for this update: 27 automated Flutter tests and 34 actual Firestore
emulator assertions pass. Phone-width sign-up and owner-start screens were rendered
and visually checked using fixtures. These checks do not prove live-project Auth,
profile creation, upload or viewing-request end-to-end behavior. No APK was built.

---

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
