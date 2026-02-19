# ===========================================
# Dockerfile pour l'API Node.js ACME
# ===========================================

# Image de base Node.js version LTS Alpine (légère)
FROM node:18-alpine

# Créer le répertoire de travail dans le conteneur
WORKDIR /app

# Copier les fichiers de dépendances d'abord (optimise le cache Docker)
COPY package*.json ./

# Installer les dépendances npm
RUN npm install --production

# Copier le code source de l'API
COPY server.js .

# Exposer le port sur lequel l'API écoute
EXPOSE 3000

# Commande de démarrage de l'API
CMD ["npm", "start"]
