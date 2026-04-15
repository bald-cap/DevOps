# ACME K8s Project


## COMPOSITION DE L'APPLICATION
L'application est composée des éléments suivants :
- **Frontal API (acme-api)** : Une API REST CRUD développée avec Node.js/Express. Elle est déployée avec 2 répliques pour assurer la haute disponibilité.
- **Base de données (mariadb)** : Un serveur MariaDB 11.8 gérant la persistance des données via des volumes Kubernetes.
- **Interface de gestion (phpmyadmin)** : Une instance phpMyAdmin pour faciliter l'administration de la base de données.

### Répertoires du projet
- `api/` : Contient le code source de l'API Express et son Dockerfile.
- `configuration/` : Contient l'ensemble des manifestes Kubernetes (Deployments, Services, PVC, ConfigMaps).
- `db/` : Contient le script `init.sql` pour l'initialisation de la base de données.
- `*.sh` : Scripts d'automatisation pour le déploiement, le nettoyage et la vérification.

## DOCUMENTATION TECHNIQUE (INSTANCIATION)

### Prérequis
- Minikube installé et démarré.
- `kubectl` configuré.
- Un fichier `configuration/.secret.yml` contenant les secrets (DB_USER, DB_PASSWORD, etc.).
- Un fichier `.env` à la racine pour l'API.

### Étapes d'installation
1. **Compatibilité des scripts** : Si vous travaillez entre Windows et Linux/WSL, convertissez les scripts pour éviter les problèmes de fin de ligne :
   ```bash
   dos2unix *.sh
   ```
2. **Déploiement** :
   ```bash
   ./deploy.sh
   ```
   Ce script applique les secrets, configure la persistance, initialise la base de données et déploie les services.

## DOCUMENTATION UTILISATEUR

### Mise à l'échelle (Scaling)
Pour modifier le nombre de répliques de l'API (ex: passer à 5) :
```bash
kubectl scale deployment/api-deployment --replicas=5
```

### Maintien en Condition Opérationnelle (MCO)
- **Mise à jour de l'image** :
  1. Construisez et poussez la nouvelle image : `./build-push-api.sh <tag>`
  2. Mettez à jour le déploiement : `kubectl set image deployment/api-deployment express-api=baldcap/acme-api:<tag>`
- **Retour arrière (Rollback)** :
  En cas de problème après une mise à jour :
  ```bash
  kubectl rollout undo deployment/api-deployment
  ```
- **État de l'application** :
  - Utilisez le script de santé : `./check-health.sh`
  - Commandes Kubernetes :
    ```bash
    kubectl get pods
    kubectl get services
    ```
  - Accès aux URLs (Minikube) :
    ```bash
    minikube service api-service --url
    minikube service pma-service --url
    ```

---

## HOW TO RUN (Old instructions)
Apply Secret YAML Files before Deploying. Be sure to use `yamllint <file/to/path>` to inspect the yaml file indentations.

- run `./deploy.sh` to deploy and expose the various services
- `./cleanup.sh` destroys the deployments and services
- `./check-health.sh` helps detect malfunctioning deployments/ services
- `./build-push-api.sh <tag number>` to build and push the image to dockerhub
