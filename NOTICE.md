# Third-party content and attributions

Randnotiz is © 2026 Even Tjorve Zankl and licensed under the **GNU General Public
License v3.0 or later** (see [LICENSE](LICENSE)). The bundled data and fonts listed
below come from third parties and are covered by their own licences.

| Content | Files | Source | Licence |
| --- | --- | --- | --- |
| Land masses, coastlines, country borders, country names (de/en/fr/es) | `assets/map/land.bin`, `assets/geo/countries.bin` | [Natural Earth](https://www.naturalearthdata.com) 1:50m, simplified (`tools/`) | Public domain |
| Places and place names | `assets/geo/places.bin` | [GeoNames](https://www.geonames.org) (`cities15000`, `alternateNamesV2`) | [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) – **modified**: only places with at least 15,000 inhabitants, German/English names selected, coordinates rounded |
| Font *Kalam* | `assets/fonts/Kalam-*.ttf` | Indian Type Foundry | SIL Open Font License 1.1 (`assets/fonts/OFL-kalam.txt`) |
| Font *Crimson Text* | `assets/fonts/CrimsonText-*.ttf` | The Crimson Text Project Authors | SIL Open Font License 1.1 (`assets/fonts/OFL-crimsontext.txt`) |
| "Listen on Apple Music" badge (English, German, French, Spanish) | `assets/branding/apple_music_badge_{de,en,fr,es}.png` | [Apple Marketing Tools](https://tools.applemediaservices.com) (official badge, unmodified, rendered as PNG) | Trademark of Apple Inc.; used according to Apple's badge guidelines, only as a link to the respective song. **Not** covered by the GPL. |

Bundled native library with its own licence (in addition to the Dart/Flutter
packages):

- **SQLite3MultipleCiphers** (encrypted database, `libsqlite3mc.so`, via
  `package:sqlite3`): © 2019–2026 Ulrich Telle,
  [MIT License](https://github.com/utelle/SQLite3MultipleCiphers/blob/main/LICENSE);
  includes SQLite (public domain).

Services used at runtime (no data in the repository):

- **Weather and place search:** [Open-Meteo](https://open-meteo.com) – data under
  [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); the free API is for
  non-commercial use only.
- **Song search, album covers and previews:**
  [iTunes Search API](https://performance-partners.apple.com/search-api) by Apple.
  While a preview is playing, the "Listen on Apple Music" badge (a link to the song)
  appears below the record, and also in the song sheet; previews are only streamed,
  never stored. Apple Music is a trademark of Apple Inc.
- **Other music services:** links to [song.link](https://song.link) (Odesli).

The name "Randnotiz" and the Randnotiz logo identify this project. If you publish a
modified version, please give it a different name and icon so that people don't
confuse it with the original app.

All attributions also appear in the app under Settings → "About Randnotiz" →
"Licenses".
