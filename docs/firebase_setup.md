# Firebase Setup

The Firebase packages and CLI tooling are installed, but the project still needs a real Firebase configuration.

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

After login, run from the repo root:

```bash
cd /Users/rancho/Desktop/PersonalProjects/student-marketplace-flutter
/Users/rancho/.pub-cache/bin/flutterfire configure
```

Select or create the Firebase project, then include Android, iOS, and Web.

## Firebase Products Needed

- Authentication
  - Enable Email/Password
  - Enable Google
- Cloud Firestore
- Firebase Storage

## Current Auth Direction

Firebase Auth supports email/password natively, not username/password. For the prototype username flow, the app maps a username to an internal email format and stores the public username in Firestore.

Google sign-in is represented in the UI now. It will be wired after FlutterFire generates platform config files.
