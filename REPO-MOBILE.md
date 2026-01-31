# Repo mobile séparé

Ce projet Flutter a son **propre dépôt Git** indépendant du web (golden-vault-admin).

## Pousser vers un repo distant

1. Crée un repo vide sur GitHub/GitLab (ex: `simplify-mobile`)

2. Depuis `mobile-simplify/` :
   ```bash
   git add .
   git commit -m "Initial commit - app Simplify mobile"
   git branch -M main
   git remote add origin https://github.com/TON_USER/simplify-mobile.git
   git push -u origin main
   ```

3. Pour les commits suivants :
   ```bash
   cd mobile-simplify
   git add .
   git commit -m "Description des changements"
   git push
   ```

## Structure

- **Web** → `golden-vault-admin/` (racine) → son propre repo
- **Mobile** → `mobile-simplify/` → son propre repo (ignoré par le repo web)
