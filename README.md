# Anayah Gestim

Application de gestion immobilière complète : des ventes de terrains à la vie quotidienne des cités.

L'application tient dans un seul fichier, `index.html`. Elle fonctionne sans installation et sans serveur.

## Modules

| Domaine | Module | Contenu |
|---|---|---|
| Pilotage | Tableau de bord | Encaissements du mois, reste à encaisser, loyers attendus et reçus, taux d'occupation, encaissements sur 12 mois, clients à relancer |
| Patrimoine | Cités & programmes | Fiche de chaque cité, plan de lotissement par îlot coloré selon le statut des lots |
| | Lots & terrains | Référence, îlot, surface, prix, prix au m², titre foncier, statut |
| Commercial | Ventes de terrains | Vente au comptant ou échelonnée, échéancier calculé, retards, relevé de compte de l'acquéreur |
| | Locations | Baux, loyers mois par mois, impayés, cautions, quittances de loyer |
| Vie des cités | Espaces communs | Salles, piscines, parkings… et leurs réservations, avec contrôle des conflits de créneaux |
| | Syndic & charges | Cotisations par lot, taux de recouvrement, dépenses communes, solde de chaque cité |
| | Maintenance | Interventions par étape (signalée, planifiée, en cours, terminée), priorité, prestataire, coût |
| Contacts | Clients & tiers | Acquéreurs, locataires, propriétaires, prestataires, avec le montant dû par chacun |

Autres fonctions :

- le statut d'un lot se met à jour automatiquement (« Vendu » après une vente, « Loué » quand un bail est actif) ;
- export CSV de chaque liste (séparateur `;`, compatible Excel) ;
- sauvegarde complète au format JSON ;
- devise et coordonnées de l'agence réglables dans **Paramètres** ;
- thème clair et sombre, utilisable sur téléphone.

## Utilisation

Ouvrez `index.html` dans un navigateur récent (Chrome, Edge, Firefox, Safari).

Pour la mettre en ligne gratuitement avec GitHub Pages : **Settings → Pages → Deploy from a branch → `main` / racine**.

## Où sont stockées les données

- **Version publiée sur Claude** (artifact) : les données sont enregistrées dans une base partagée entre toutes les personnes qui ont accès à l'application.
- **Fichier `index.html` ouvert seul** (ou via GitHub Pages) : les données restent dans le navigateur de chaque utilisateur (`localStorage`). Elles ne sont pas partagées entre appareils. Utilisez régulièrement **Paramètres → Sauvegarde complète** pour en garder une copie.

## Technique

HTML, CSS et JavaScript sans dépendance ni étape de compilation. Les polices viennent de Google Fonts.
