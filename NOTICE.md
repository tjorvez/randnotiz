# Drittanbieter-Inhalte und Quellenangaben

Randnotiz steht unter der **GNU General Public License v3.0 oder später**
(siehe [LICENSE](LICENSE)). Die folgenden mitgelieferten Daten und Schriften
stammen von Dritten und stehen unter ihren eigenen Lizenzen.

| Inhalt | Dateien | Quelle | Lizenz |
| --- | --- | --- | --- |
| Landmassen, Küsten, Ländergrenzen | `assets/map/land.bin`, Umrisse in `assets/geo/countries.bin` | [Natural Earth](https://www.naturalearthdata.com) 1:50 Mio., vereinfacht (`tools/`) | Gemeinfrei (public domain) |
| Orte und Ortsnamen | `assets/geo/places.bin`, Namen in `assets/geo/countries.bin` | [GeoNames](https://www.geonames.org) (`cities15000`, `alternateNamesV2`) | [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) – **verändert**: nur Orte ab 15 000 Einwohnern, deutsche/englische Namen ausgewählt, Koordinaten gerundet |
| Schrift *Kalam* | `assets/fonts/Kalam-*.ttf` | Indian Type Foundry | SIL Open Font License 1.1 (`assets/fonts/OFL-kalam.txt`) |
| Schrift *Crimson Text* | `assets/fonts/CrimsonText-*.ttf` | The Crimson Text Project Authors | SIL Open Font License 1.1 (`assets/fonts/OFL-crimsontext.txt`) |

Zur Laufzeit genutzte Dienste (keine Daten im Repo):

- **Wetter und Ortssuche:** [Open-Meteo](https://open-meteo.com) – Daten unter
  [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); die kostenlose API ist nur
  für nicht-kommerzielle Nutzung freigegeben.
- **Musik (optional):** [Spotify](https://developer.spotify.com) Web API und App
  Remote SDK unter den Spotify Developer Terms. Das SDK wird nicht mitgeliefert
  (siehe README, Abschnitt „Spotify“).

Alle Quellenangaben erscheinen auch in der App unter Einstellungen → „Über Randnotiz“.
