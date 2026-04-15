FROM node:18-alpine

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances npm
RUN npm install --production

# Copier le code source de l'API
COPY server.js .

EXPOSE 3000

# Démarrer l'API
CMD ["npm", "start"]
