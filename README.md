# Livelink

Willkommen zu **Livelink**, der App, mit der du in Echtzeit mit anderen Nutzern chatten kannst, die sich in denselben Channels befinden. Entdecke neue Leute und Themen.
Entwickelt wurde die App im Rahmen des Abschlussprojekts für das Syntax Institut.

## Inhaltsverzeichnis

1. [Features](#features)
    - [Profile](#profile)
    - [Wildspace](#wildspace)
    - [Profilbild](#profilbild)
    - [Channels](#channels)
    - [OnlineUser Liste](#onlineuser-liste)
    - [Bot "Paul"](#bot-paul)
    - [Böse Nutzer bestrafen](#böse-nutzer-bestrafen)
    - [Nutzersuche](#nutzersuche)
2. [Tech-Stack](#tech-stack)

## Features

### Profile
Erstelle ein individuelles Profil mit Angaben wie Alter, Geschlecht, Geburtsdatum und mehr.
<details>
<summary>Screenshots</summary>
<img src="/img/Profile1.png" alt="Profile Screenshot" width="300">
<img src="/img/EditProfile.png" alt="Profile Screenshot" width="300">
</details>
  
### Wildspace
Verfasse eigene Texte oder binde ein Bild ein, um dein Profil persönlicher zu gestalten.
<details>
<summary>Screenshots</summary>
<img src="/img/EditWildspace.png" alt="Wildspace Screenshot" width="300">
<img src="/img/Wildspace1.png" alt="Wildspace Screenshot" width="300">
</details>

### Profilbild
Lade ein Profilbild hoch, um dein Profil noch ansprechender zu machen.
<details>
<summary>Screenshots</summary>
<img src="/img/UploadPhoto.png" alt="Photo Upload Screenshot" width="300">
</details>

### Channels
Trete verschiedenen Channels bei, die in Kategorien unterteilt sind, und chatte live mit anderen Nutzern.
<details>
<summary>Screenshots</summary>
<img src="/img/Channels.png" alt="Channels Screenshot" width="300">
<img src="/img/Channel.png" alt="Channels Screenshot" width="300">
</details>

### OnlineUser Liste
In jedem Channel kannst du sehen wer online ist, inklusive Alter, Geschlecht
<details>
<summary>Screenshots</summary>
<img src="/img/Userlist.png" alt="Channels Screenshot" width="300">
</details>

### Bot "Paul"
In den Channels steht dir unser Bot Paul zur Verfügung, der viele Fragen zu verschiedenen Themen beantworten kann.
<details>
<summary>Screenshots</summary>
<img src="/img/ChatBot.png" alt="Bot Paul Screenshot" width="300">
</details>

### Böse Nutzer bestrafen
Es steht ein Sperrsystem für Admins zur Verfügung.
<details>
<summary>Screenshots</summary>
<img src="/img/Locked.png" alt="Nutzersperre aus Sicht eines Admins" width="300">
<img src="/img/Locked2.png" alt="Nutzersperre aus Sicht eines Users" width="300">
</details>

### Nutzersuche
Nach Nutzern suchen.
<details>
<summary>Screenshots</summary>
<img src="/img/Usersearch.png" alt="Nutzersuche Screenshot" width="300">
</details>

## Tech-Stack

- **Swift**: Programmiersprache für die iOS-Entwicklung.
- **SwiftUI**: UI-Programmiersprache für die iOS-Entwicklung.
- **SwiftUIX**: UI Elemente
- **Firebase Storage**: Zum Speichern von Benutzerinhalten wie Profilbildern und Hintergründen.
- **Firebase Firestore**: Datenbank zum Speichern von Benutzer- und Chat-Daten.
- **Firebase Auth**: Authentifizierung und Benutzerverwaltung.
- **WebView/HTML**: Zur Darstellung und Formatierung von Inhalten innerhalb der App.
- **SwiftSoup**: Zum filtern von ungewünschten HTML/Scripten.
- **openPLZ API**: Zum abrufen von Informationen zu einer Postleitzahl
- **Perplexity API**: Anbindung an den Chatbot zum beantworten von Fragen
- **MVVM Pattern**
