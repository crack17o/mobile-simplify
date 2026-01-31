# Simplify — App mobile clients

App Flutter pour les clients (Wallet, RDC +243). Projet séparé du back-office admin.

**Pour l’instant : toutes les données sont mockées** (login, solde, transactions, dépôts, retraits, encaissements agent). Aucun appel API n’est effectué.

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installé (`flutter --version`)

## Génération des dossiers Android / iOS

Ce dépôt contient uniquement le code Dart et le `pubspec.yaml`. Pour générer les projets natifs Android et iOS, exécuter **une seule fois** à la racine de ce dossier :

```bash
cd mobile-simplify
flutter create . --project-name mobile_simplify --org com.simplify
```

Cela ajoute les dossiers `android/`, `ios/`, `web/`, etc., sans écraser `lib/` ni `pubspec.yaml`.

## Lancer l’app

```bash
cd mobile-simplify
flutter pub get
flutter run
```

- **Android** : émulateur ou appareil USB (`flutter devices`)
- **iOS** : uniquement sur macOS avec Xcode

## Remarque

Le dossier `mobile-simplify/` est dans le `.gitignore` du projet admin : il ne sera pas poussé avec le repo `golden-vault-admin`. Gérer ce projet Flutter dans un dépôt séparé si besoin.
