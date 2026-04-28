# Firebase Setup

The Firebase packages and CLI tooling are installed. FlutterFire is configured for Android, iOS, and Web against Firebase project `login-createaccount-firebase`.

## Login

Run this in your terminal:

```bash
firebase login
```

Then confirm:

```bash
firebase login:list
```

## Configure FlutterFire

FlutterFire has already been run with:

```bash
cd /Users/rancho/Desktop/PersonalProjects/student-marketplace-flutter
/Users/rancho/.pub-cache/bin/flutterfire configure \
  --project=login-createaccount-firebase \
  --platforms=android,ios,web
```

## Firebase Products Needed

- Authentication
  - Enable Email/Password
  - Enable Google
- Cloud Firestore
- Firebase Storage

These still need to be enabled in the Firebase Console before real auth/listing storage will work. Storage must be initialized from the console before `firebase deploy --only storage` can publish `storage.rules`.

## Storage Rules

After enabling Storage in the Firebase Console, deploy the rules with:

```bash
firebase deploy --only storage --project login-createaccount-firebase
```

## Current Auth Direction

Firebase Auth supports email/password natively, not username/password. For the prototype username flow, the app maps a username to an internal email format and stores the public username in Firestore.

Google sign-in is wired through Firebase Auth. On Web it uses Firebase's Google popup provider; on mobile it uses the Google Sign-In plugin and Firebase credentials.
