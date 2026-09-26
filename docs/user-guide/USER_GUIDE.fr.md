# OVDP Hub v0.9.3 — Guide utilisateur

## Objet
OVDP Hub est une application local-first pour les obligations d’État ukrainiennes OVDP : sources de marché, scénarios, comparaison et portefeuille personnel chiffré factuel. L’application n’exécute aucune transaction.

## Installation
**Windows :** extraire tout le ZIP et lancer `ovdp_hub.exe`. Conserver les DLL et ressources avec l’exécutable. Le prerelease n’est pas signé en production; SmartScreen peut donc apparaître.

**macOS :** extraire le ZIP et ouvrir `ovdp_hub.app`. Le prerelease n’est pas notarized; après un premier blocage, **Open Anyway** peut être proposé dans System Settings → Privacy & Security.

**Android :** extraire le ZIP Android et installer `OVDP-Hub.apk`. Il s’agit d’un build de test signé en développement.

**iOS :** le package publié est unsigned et nécessite un signing/provisioning Apple séparé.

## Langue et apparence
Langues : ukrainien, anglais, français, allemand, espagnol, coréen et japonais. Apparences : Classic, Workbench et Light Dashboard. La langue et l’apparence choisies sont enregistrées localement sur cet appareil et restaurées au prochain lancement.

## Marché et ISIN
Le catalogue permet de rechercher et filtrer les OVDP. La fiche ISIN sépare NBU, MinFin et vendeurs et affiche date, source et freshness/status. Un yield-only ou le nominal n’est jamais transformé silencieusement en prix de marché.

## Planificateur
Un scénario utilise une seule devise. Configurez budget, réserve, horizon, besoins, positions, frais, fiscalité, FX, sortie anticipée, reserve floor et besoins ponctuels/récurrents. Une valeur inconnue doit rester inconnue, pas devenir zéro.

A/B/C compare 2–3 scénarios compatibles sans désigner automatiquement de gagnant. Les exports CSV/ICS sont créés localement dans `exports/`.

## Mon portefeuille
Le portefeuille est un flux local chiffré avec création/ouverture/verrouillage.

**Achat :** saisir ISIN/date/unités/montant et l’état des frais.

**Vente :** allocation explicite aux lots d’acquisition; aucun FIFO/LIFO inventé.

**Coupon / remboursement :** enregistrer uniquement les montants réellement reçus.

**Ledger ISIN :** historique achat/vente/coupon/remboursement. Les positions clôturées restent visibles.

**Résumé de trésorerie factuel :** achats, produits de vente, coupons, remboursements et frais connus par devise. Si un frais pertinent est inconnu, le résultat net exact n’est pas affiché.

Ce résumé n’est **pas** une valorisation de marché ni une mesure de performance : la valeur actuelle des positions ouvertes n’y est pas ajoutée.

## Migration legacy
L’assistant copie les données legacy prises en charge vers le payload chiffré et vérifie la copie. La migration est non destructive : le JSON source n’est jamais supprimé automatiquement.

## Sauvegarde et mise à jour
Avant une mise à jour importante : verrouiller le portefeuille, sauvegarder le workspace, vérifier le backup chiffré portable et conserver le recovery material séparément. Pour une mise à jour desktop, utilisez un nouveau dossier programme et gardez les données jusqu’à vérification.

Sous Windows, **Mon portefeuille** peut créer une sauvegarde chiffrée portable et restaurer un portefeuille local vide à partir de celle-ci. Le secret de récupération est saisi deux fois lors de la création et peut être modifié ensuite. Les flux de fichiers externes Android/iOS restent différés jusqu’à l’étape SAF/security-scoped dédiée.

## Vérification et problèmes fréquents
Le fichier `SHA256SUMS.txt` permet de vérifier les archives. SmartScreen / avertissement macOS peut apparaître avec ce prerelease non signé. « Frais inconnus » est un état explicite. Le ZIP iOS unsigned ne s’installe pas directement.

## Limites
OVDP Hub n’est pas un courtier. Vérifiez prix, frais, fiscalité, dates et conditions auprès des sources primaires et de votre banque/courtier avant toute action financière.
