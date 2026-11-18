# Security policy

Randnotiz is a diary – it holds some of the most private things people write down.
If you find a way to get at that data without being its owner, please tell me
privately first.

## Reporting a vulnerability

Please **don't open a public issue** for security problems. Instead, use GitHub's
private vulnerability reporting:

1. Go to the [Security tab](https://github.com/tjorvez/randnotiz/security) of this
   repository.
2. Click **"Report a vulnerability"** and describe the problem.

Helpful details: the app version (Settings → "About Randnotiz"), the Android
version and device, the steps to reproduce and what an attacker would need (physical
access to an unlocked phone, a rooted device, access to the Google account, …).

Please **never include real diary entries, private photos or backup passwords** – use
test data instead (see "Developing without touching your real diary" in the
[README](README.md#developing-without-touching-your-real-diary)).

Randnotiz is a one-person hobby project, so I can't promise fixed response times. I
will confirm your report as soon as I can, keep you posted and credit you in the
release notes if you like.

## Supported versions

Only the **latest release** on Google Play and the current `main` branch receive
fixes.

## What is in scope

Especially interesting:

- **Encrypted database** – SQLite3MultipleCiphers, key in the Android Keystore
  (`lib/core/database/`)
- **End-to-end encrypted Drive backup** – AES-256-GCM per object, key derived from
  the backup password with Argon2id, emergency key (`lib/features/backup/data/crypto/`)
- **App lock** – biometric/device credential, FLAG_SECURE against screenshots and the
  recent-apps preview (`lib/features/lock/`, `MainActivity.kt`)
- **Data leaving the device** – anything sent to Open-Meteo, Apple or Google beyond
  what the [privacy policy](PRIVACY.md) describes

Out of scope: attacks that need a rooted or otherwise compromised device, and issues
in third-party services (Google Drive, Open-Meteo, Apple) themselves – please report
those to the respective vendor.
