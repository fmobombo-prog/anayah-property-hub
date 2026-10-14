# Anayah Gestim

Application de gestion immobilière complète, des ventes de terrains à la vie quotidienne des cités. Elle est proposée aux agences sous forme d'abonnement, avec des données conservées en ligne.

## Modules de gestion

| Domaine | Module | Contenu |
|---|---|---|
| Pilotage | Tableau de bord | Encaissements du mois, reste à encaisser, loyers attendus et reçus, taux d'occupation, encaissements sur 12 mois, clients à relancer |
| Patrimoine | Cités & programmes | Fiche de chaque cité, plan de lotissement par îlot coloré selon le statut des lots |
| | Lots & terrains | Référence, îlot, surface, prix, prix au m², titre foncier, statut |
| Commercial | Ventes de terrains | Vente au comptant ou échelonnée, échéancier calculé, retards, relevé de compte de l'acquéreur |
| | Locations | Baux, loyers mois par mois, impayés, cautions, quittances de loyer |
| Vie des cités | Espaces communs | Salles, piscines, parkings… et leurs réservations, avec contrôle des conflits de créneaux |
| | Syndic & charges | Cotisations par lot, taux de recouvrement, dépenses communes, solde de chaque cité |
| | Maintenance | Interventions par étape, priorité, prestataire, coût |
| Contacts | Clients & tiers | Acquéreurs, locataires, propriétaires, prestataires, avec le montant dû par chacun |

## Modèle d'abonnement

Les agences clientes s'inscrivent, créent leur agence et paient un abonnement.

| Formule | Prix mensuel | Cités | Lots | Utilisateurs | Fonctions en plus |
|---|---|---|---|---|---|
| Essentiel | 25 000 FCFA | 1 | 100 | 2 | — |
| Pro | 75 000 FCFA | 5 | 1 000 | 10 | Exports CSV, quittances et relevés, module Syndic |
| Entreprise | 200 000 FCFA | illimité | illimité | illimité | Tout Pro + support prioritaire |

- **Essai gratuit** : 30 jours avec toutes les fonctions Pro, un seul essai par compte.
- **Paiement annuel** : 12 mois pour le prix de 10 (2 mois offerts).
- **Paiement** : l'agence paie par Mobile money ou virement, puis déclare le paiement dans « Abonnement » avec la référence de la transaction. L'administrateur vérifie et valide le paiement dans la **Console**, ce qui prolonge l'abonnement automatiquement.
- **Échéance** : 7 jours de grâce, puis l'agence passe en **lecture seule**. Ses données restent consultables, exportables (sauvegarde JSON) et ne sont jamais supprimées.
- **Rôles** : Administrateur (tout, abonnement et équipe), Gestionnaire (saisie), Consultation (lecture seule).

Les prix, limites, fonctions, durées d'essai et de grâce et les instructions de paiement se modifient dans la Console, sans toucher au code.

Les limites et droits sont appliqués **par le serveur** (règles d'accès Supabase) et pas seulement par l'interface. Les données de gestion d'une agence ne sont visibles que par ses membres : l'administrateur voit les abonnements et les volumes, pas le contenu.

## Mise en service

### 1. Créer la base Supabase

1. Créez un compte et un projet sur [supabase.com](https://supabase.com) (l'offre gratuite suffit pour démarrer).
2. Dans le projet, ouvrez **SQL Editor → New query**, collez le contenu de [`supabase/schema.sql`](supabase/schema.sql) et cliquez sur **Run**.
3. Dans **Authentication → URL Configuration**, indiquez l'adresse où l'application sera publiée (par exemple `https://fmobombo-prog.github.io/anayah-property-hub/`) dans **Site URL** et **Redirect URLs**. Les liens de confirmation et de mot de passe oublié y renverront.

### 2. Relier l'application

Dans **Project Settings → API**, copiez **Project URL** et la clé **anon public**, puis renseignez-les dans [`config.js`](config.js) :

```js
window.ANAYAH_CONFIG = {
  supabaseUrl: 'https://xxxxxxxx.supabase.co',
  supabaseAnonKey: 'eyJ...'
};
```

La clé `anon` est conçue pour être publique. N'utilisez jamais la clé `service_role` dans ce fichier.

### 3. Publier

Sur GitHub : **Settings → Pages → Deploy from a branch → `main` / racine**.

### 4. Devenir super administrateur

Créez votre compte dans l'application, confirmez votre adresse, puis exécutez dans le SQL Editor de Supabase (avec votre adresse) :

```sql
insert into public.super_admins (user_id)
select id from auth.users where email = 'votre.adresse@exemple.com';
```

Reconnectez-vous : le menu **Console** apparaît. Commencez par **Paramètres** pour saisir vos instructions de paiement (numéro Mobile money, coordonnées bancaires).

## Mode local

Si `config.js` reste vide, l'application fonctionne sans compte ni abonnement. Les données sont alors conservées uniquement dans le navigateur. **Paramètres → Sauvegarde complète** puis **Importer une sauvegarde** permet ensuite de transférer ces données vers une agence en ligne.

## Technique

- `index.html` : toute l'application (HTML, CSS, JavaScript), sans étape de compilation.
- `config.js` : connexion au projet Supabase.
- `supabase/schema.sql` : tables, règles d'accès, limites des formules, fonctions de validation des paiements.
- Bibliothèques chargées depuis un CDN : `@supabase/supabase-js` 2.45.4 et les polices Google Fonts.
