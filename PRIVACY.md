# Datenschutzerklärung für „Randnotiz“ (Android-App)

> **ENTWURF – nicht rechtlich geprüft.** Dieser Text beschreibt die tatsächliche
> Datenverarbeitung der App nach bestem Wissen. Vor einer Veröffentlichung muss er von
> einer fachkundigen Person (Datenschutz/Recht) geprüft, um die Angaben zum
> Verantwortlichen ergänzt und an den dann gültigen Funktionsumfang angepasst werden.

Stand: 01.11.2026

## 1. Verantwortlicher

[Name, Anschrift, E-Mail-Adresse – vor Veröffentlichung ergänzen]

## 2. Grundsatz: Deine Daten bleiben auf deinem Gerät

Randnotiz ist ein privates Foto-Tagebuch. Die App hat **keinen eigenen Server** und
**kein Nutzerkonto**. Notizen, Stimmungen, Ortsnamen, Wetterangaben und verkleinerte
Kopien deiner Fotos werden im privaten Speicherbereich der App auf deinem Gerät
gespeichert. Eine Kopie davon verlässt das Gerät nur, wenn du die optionale
Sicherung in Google Drive einschaltest – und dann nur Ende-zu-Ende-verschlüsselt
(siehe 4.5). Wir (die Anbieter) erhalten diese Daten nicht.

Die App enthält **keine Werbung, keine Analyse- oder Tracking-Dienste** und keine
Absturzberichte an Dritte.

## 3. Welche Daten verarbeitet die App?

| Daten | Zweck | Ort der Verarbeitung |
|---|---|---|
| Fotos deiner Galerie (Anzeige) | Auswahl eines Fotos für eine Notiz | nur auf dem Gerät |
| Verkleinerte Fotokopien (ca. 800 px; bei Fotos aus dem Foto-Picker zusätzlich bis 1600 px) | Tagebuch, Erinnerungen, Widget – auch wenn das Original gelöscht wird | nur auf dem Gerät |
| Notiztext, Titel, Datum, Stimmungen (Emoji + Name), optionaler Ortsname, Land (Ländercode), Wetter (Kategorie, Temperatur) | Tagebuchfunktion, Suche, Weltkarte | nur auf dem Gerät |
| GPS-Position aus den Fotodaten (falls vorhanden) | Land und nächsten Ort bestimmen (offline, mit mitgelieferten Kartendaten); Wetter am Aufnahmetag ermitteln | wird nicht gespeichert – nur Land und Ortsname; gerundet an den Wetterdienst übermittelt (siehe 4.1) |
| Frühere Suchbegriffe im Tagebuch | Vorschläge beim Suchen | nur auf dem Gerät, einzeln oder komplett löschbar |
| Einstellungen (Design, Sperre, Widget-Textvorschau, ob die Einführung schon gezeigt wurde) | App-Verhalten | nur auf dem Gerät |
| Suchbegriff bei der Ortssuche | passenden Ort finden | an den Geocoding-Dienst übermittelt (siehe 4.2) |
| Sprache beim Diktieren | Umwandlung in Text | auf dem Gerät oder beim Spracherkennungsdienst (siehe 4.3); **keine Audiospeicherung** |
| Verknüpftes Lied (Spotify-Adresse, Titel, Künstler, Albumcover) – optional | Lied zu einem Eintrag anzeigen, durchsuchen und abspielen | nur auf dem Gerät; Suchbegriffe gehen an Spotify (siehe 4.6) |
| Fingerabdruck/Gesicht/Displaysperre | Entsperren der App | ausschließlich durch Android; die App erhält nur „erfolgreich / nicht erfolgreich“ |

## 4. Übermittlung an Dritte

### 4.1 Wetterdaten (Open-Meteo)

Wenn ein Foto eine Ortsangabe enthält oder du einen Ort auswählst, sendet die App das
**Datum** des Fotos und einen **ungefähren Ort** (Koordinaten, auf zwei Nachkommastellen
gerundet, ca. 1 km Genauigkeit) an den Wetterdienst **Open-Meteo** (open-meteo.com). Dabei wird technisch bedingt auch deine IP-Adresse übertragen.
Gespeichert wird in der App nur das Ergebnis (Wetterkategorie und Temperatur), nicht die
Koordinaten. Rechtsgrundlage: Art. 6 Abs. 1 lit. b bzw. f DSGVO (vom Nutzer gewünschte
Funktion). Datenschutzhinweise des Dienstes: <https://open-meteo.com/en/terms>.

### 4.2 Ortssuche (Open-Meteo Geocoding)

Gibst du einen Ortsnamen ein, wird dieser **Suchbegriff** (und deine IP-Adresse) an die
Geocoding-Schnittstelle von Open-Meteo gesendet. Gespeichert wird in der App nur der
Name des gewählten Orts, keine Koordinaten.

### 4.3 Spracherkennung

Beim Diktieren nutzt die App die Spracherkennung von Android. Je nach Gerät und
Systemeinstellung erfolgt die Erkennung **direkt auf dem Gerät** oder über den
**Spracherkennungsdienst von Google** (Google Ireland Ltd.). In letzterem Fall werden die
Audiodaten des Diktats an Google übermittelt und dort nach den Bedingungen von Google
verarbeitet (<https://policies.google.com/privacy>). Randnotiz selbst nimmt kein Audio
auf und speichert keine Audiodaten; in der Notiz landet nur der erkannte Text. Vor der
ersten Nutzung wird die Mikrofon-Berechtigung mit einer Erklärung erfragt.

### 4.4 Fotos aus Google Fotos (Android-Foto-Picker)

Wählst du ein Foto über den Android-Foto-Picker (der auch Bilder aus Google Fotos zeigen
kann), stellt Android der App nur das ausgewählte Foto bereit. Randnotiz speichert davon
eine private, verkleinerte Kopie, wenn du eine Notiz dazu schreibst. Die Kommunikation
mit Google Fotos erfolgt durch Android bzw. die Google-Fotos-App, nicht durch Randnotiz.

### 4.5 Sicherung in Google Drive (optional, Ende-zu-Ende-verschlüsselt)

Nur wenn du die Sicherung in den Einstellungen einschaltest und dich mit deinem
Google-Konto anmeldest:

- **Was:** Notiztexte, Titel, Datum, Ort und Land, Wetter, Stimmungen, Sammlungen, die
  Angaben zum verknüpften Lied sowie die verkleinerten Kopien deiner Fotos (ca. 800 px),
  die Song-Cover und die privaten Kopien von Fotos aus Google Fotos (höchstens 1600 px).
  Originalfotos aus der Galerie werden nicht hochgeladen.
- **Wohin:** in den **versteckten App-Ordner** deines eigenen Google-Drive-Kontos
  (Google Ireland Ltd.; Berechtigung `drive.appdata`). Nur Randnotiz kann diesen Ordner
  lesen; die App hat keinen Zugriff auf deine übrigen Drive-Dateien. Es gibt keinen Server
  von uns dazwischen.
- **Verschlüsselung:** Alles wird **vor dem Hochladen auf deinem Gerät verschlüsselt**
  (AES-256-GCM). Der Schlüssel ist durch dein **Backup-Passwort** (Argon2id) und einen
  **Notfallschlüssel** geschützt, den die App dir einmal anzeigt. Beide verlassen das
  Gerät nie und sind weder Google noch uns bekannt. Auch die Dateinamen in Drive verraten
  nichts über den Inhalt. Google sieht nur die Anzahl und Größe der verschlüsselten Dateien
  sowie die Zeitpunkte der Sicherung – und, dass dein Konto Randnotiz verwendet.
- **Folge:** Ohne Backup-Passwort und ohne Notfallschlüssel kann niemand die Sicherung
  wiederherstellen – auch wir nicht.
- **Wann:** automatisch höchstens einmal am Tag, wenn du die App öffnest und sich etwas
  geändert hat, sowie über „Jetzt sichern“.
- **Auf dem Gerät** bleibt der Schlüssel im Android-Keystore-geschützten Speicher, damit
  automatische Sicherungen ohne Passwort laufen; Abmelden löscht ihn.
- **Löschen:** Beim Abmelden kannst du die Sicherung in Google Drive löschen lassen.
  Alternativ in Google Drive (Web) unter Einstellungen → Apps verwalten → Randnotiz →
  „Ausgeblendete App-Daten löschen“.

Rechtsgrundlage: Art. 6 Abs. 1 lit. b DSGVO (von dir gewünschte Funktion).
Datenschutzhinweise von Google: <https://policies.google.com/privacy>.

### 4.6 Lieder von Spotify (optional)

Nur wenn du einem Eintrag ein Lied hinzufügst:

- **Anmeldung:** über die auf deinem Gerät installierte Spotify-App (bzw. ersatzweise im
  Browser). Randnotiz erhält dabei ein zeitlich begrenztes Zugriffstoken, das nur im
  Arbeitsspeicher liegt und nicht gespeichert wird. Dein Spotify-Passwort sieht die App
  nie. Erbetene Berechtigungen: `user-read-private` (Land und Abo-Art deines Kontos –
  Spotify verlangt für die Suche eine Berechtigung; Randnotiz wertet diese Angaben nicht
  aus) und `app-remote-control` (Lieder in der Spotify-App abspielen und pausieren).
- **Suche:** Dein Suchbegriff wird an die Spotify Web API (Spotify AB, Schweden)
  übermittelt; Spotify antwortet mit passenden Liedern.
- **Gespeichert** wird im Eintrag nur die Spotify-Adresse des Liedes, Titel, Künstler
  und eine Kopie des Albumcovers (von Spotifys Bildserver geladen) – auf dem Gerät.
- **Abspielen** übernimmt die Spotify-App; Randnotiz schickt ihr nur „spiele dieses
  Lied“ bzw. „Pause“. Was Spotify dabei erfasst, regelt Spotifys Datenschutzerklärung
  (<https://www.spotify.com/de/legal/privacy-policy/>).

Ohne diese Funktion nimmt Randnotiz keinen Kontakt zu Spotify auf.

## 5. Berechtigungen

- Fotos und Videos (nur Bilder) / „Ausgewählte Fotos“: Anzeige der Galerie
- Zugriff auf Standort in Medien: Land, Ort und Wetter aus der Ortsangabe des Fotos
- Mikrofon: Diktat (nur bei Nutzung)
- Biometrie: Entsperren der App
- Internet: Wetter, Ortssuche, ggf. Spracherkennung, Liedsuche (Spotify, optional),
  Sicherung in Google Drive (optional)
- Beim Neustart ausführen: Aktualisierung des Widgets nach einem Neustart

**Hinweis zum Widget:** Legst du das Widget „Erinnerung des Tages“ auf den
Startbildschirm, zeigt es dort ein Foto aus deinem Tagebuch (und, nur wenn du
„Textvorschau im Widget“ einschaltest, den Anfang des Notiztexts) – auch wenn die App
selbst gesperrt ist. Das Widget ist optional; ohne es erscheint nichts außerhalb der App.

## 6. Speicherdauer und Löschung

Die Daten bleiben gespeichert, bis du sie in der App löschst (Notiz löschen, Stimmung
löschen; eine Notiz, deren Text, Titel, Stimmungen und Lied du vollständig entfernst,
wird beim Schließen gelöscht) oder die App deinstallierst bzw. ihre Daten in den
Android-Einstellungen löschst. Automatische System-Backups der App-Daten sind
deaktiviert. Eine Sicherung in Google Drive (4.5) bleibt bestehen, bis du sie löschst.

## 7. Schutz der Daten

App-Sperre per Biometrie/Displaysperre; solange die Sperre eingeschaltet ist, zusätzlich
Schutz vor Screenshots, Bildschirmaufnahmen und der Vorschau in der App-Übersicht
(FLAG_SECURE). Ohne eingeschaltete Sperre sind Screenshots möglich; die Sperre wirkt
nur, wenn auf dem Gerät eine Displaysperre eingerichtet ist. Der Screenshot-Schutz gilt
für die veröffentlichte App (Release-Build); Entwicklungsversionen erlauben Screenshots
und sagen das in der Einführung. Speicherung im
privaten App-Bereich, keine Übertragung an eigene Server. Die optionale Sicherung in
Google Drive ist Ende-zu-Ende-verschlüsselt (4.5).

## 8. Deine Rechte

Du hast die Rechte auf Auskunft, Berichtigung, Löschung, Einschränkung, Datenübertragbarkeit
und Widerspruch (Art. 15–21 DSGVO) sowie ein Beschwerderecht bei einer
Datenschutz-Aufsichtsbehörde. Da wir keine Daten von dir auf eigenen Systemen speichern,
kannst du die meisten Rechte direkt in der App bzw. über die Android-Einstellungen
ausüben.

## 9. Änderungen

Diese Erklärung wird angepasst, wenn sich die Funktionen der App ändern.
