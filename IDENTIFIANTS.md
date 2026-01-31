# Identifiants de connexion (démo)

## Deux types d'utilisateurs

| Type | MSISDN (téléphone) | PIN | Rôle |
|------|--------------------|-----|------|
| **Client** | `243812345678` | `0000` | Accès app client : portefeuille, microcrédit, épargne, tontine |
| **Agent terrain** | `243898765432` | `1234` | Accès app agent : encaisser retraits, historique |

En code : `lib/core/auth_service.dart` → classe `DemoCredentials`  
(clientMsisdn, clientPin, agentMsisdn, agentPin).

---

# Logo dans l'app

- **Page de login** : le logo s'affiche **en haut du formulaire** dans `lib/screens/login_screen.dart` (widget `Image.asset('assets/logo-light.png', height: 72)`).
- **Navbar (barre du haut)** : le logo est dans l’**AppBar**, zone **leading** (à gauche) :
  - **Client** : `lib/screens/client/client_shell.dart` (méthode `_buildAppBar`, widget `leading`).
  - **Agent** : `lib/screens/agent/agent_shell.dart` (propriété `leading` de l’`AppBar`).

Asset utilisé : `assets/logo-light.png`.
