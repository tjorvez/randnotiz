# Contributing to Randnotiz

Thanks for your interest! Randnotiz is a one-person project that I maintain in my
spare time, so please bear with me if an answer takes a while.

## Bug reports and ideas

Please use [GitHub Issues](https://github.com/tjorvez/randnotiz/issues) – English or
German are both fine.

- **Never attach private photos, real diary entries or backup passwords.** With the
  lock enabled, the app blocks screenshots anyway; describe what you see, or reproduce
  it in the test app with test photos.
- Security problems don't belong in a public issue – see [SECURITY.md](SECURITY.md).

## Pull requests

For anything beyond a small fix, please open an issue first so we can agree on the
approach before you put in the work. Randnotiz deliberately stays small, private and
offline-first: features that need a server, an account or tracking won't be merged.

Before you open a pull request:

```bash
flutter analyze        # no issues
flutter test           # all green
dart format lib test   # formatted
```

- **Set up your build** as described in the README under
  [Building it yourself](README.md#building-it-yourself). To try things out without
  risking your own diary, use the separate test app
  ([Developing without touching your real diary](README.md#developing-without-touching-your-real-diary)).
- **Tests:** new behaviour comes with tests. External services sit behind interfaces
  and are faked in tests; the database runs in memory.
- **Database changes:** bump `schemaVersion`, write a migration and generate the
  schema dumps and migration tests (`dart run drift_dev make-migrations`). Existing
  diaries must survive every upgrade.
- **Texts:** all user-facing strings live in `lib/l10n/app_*.arb` – please add every
  new string in all four languages (English is the template), then run
  `flutter gen-l10n`. Generated code is checked in.
- **Privacy:** no new network requests, permissions or third-party SDKs without
  discussing them first, and nothing that reads data the user didn't pick.

By contributing, you agree that your contributions are licensed under the
[GNU General Public License v3.0 or later](LICENSE), like the rest of the project.
