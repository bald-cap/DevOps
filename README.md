# Refs

[Mariadb k8s Source](https://mariadb.org/start-mariadb-in-k8s/)
[Nana K8s Tutortial](https://youtu.be/X48VuDVv0do?si=dEB1ahE5fdlfGHp0)

[PHP MyAdmin Deployment](https://weng-albert.medium.com/deploying-mysql-and-phpmyadmin-management-in-kubernetes-en-bbd3e8e15746)

[Pods Error Handling](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_wait/)

# ABOUT
Database is Stateless hence has one replica
Must Add Persistence/Volumes to MariaDB Container

# HOW TO RUN
Apply Secret YAML Files before Deploying

Be sure to use `yamllint <file/to/path>` to inspect the yaml file indentations

This assumes that you have a `configuration/.secret.yml` file and an `.env` file

- run `./deploy.sh` to deploy and expose the various services
- `./cleanup.sh` destroys the deployments and services
- `./check-health.sh` helps detect malfunctioning deployments/ services
- `./build-push-api.sh <tag number> ("latest" by default)` to build and push the image to dockerhub

# ASSIGNMENT
```txt
La société ACME désire déployer son application (api CRUD Rest permettant de créer, lire, mettre à jour et 
supprimer des données dans une base simple).
Pour ce faire, vous devez montrer la faisabilité en réalisant une maquette réalisée à l’aide de minikube.
Pour réaliser cette maquette, la société ACME vous demande :
• de créer si besoin sur le docker hub les dépôts des images des conteneurs utilisés par l’application 
(conteneurs du projet précédent)
• de fournir un (ou plusieurs) fichiers yaml permettant de faire le déploiement en respectant les 
conditions suivantes :
◦ Les données de la base doivent être stockées de manière pérenne
◦ Le nombre de répliques pour le frontal web qui porte l’api doit être de 2
Documents à rendre.
• L’ensemble des fichiers permettant d’instancier de manière correcte l’application.
• La documentation technique expliquant de quoi est composé l’application et comment l’instancier. Le 
fichier sera au format pdf
• Si des fichiers de configurations sont utilisés pour déployer l’application, ceux-ci doivent être 
clairement commentés.
• La documentation utilisateur expliquant :
◦ comment mettre à l’échelle l’application
◦ comment réaliser les opérations courantes de maintien en condition opérationnelle et de sécurité 
(déroulement d’une mise à jour, retour arrière...):
◦ comment obtenir des informations sur l’état de l’application
```