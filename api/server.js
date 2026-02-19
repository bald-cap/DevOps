/**
 * API REST CRUD - Gestion des Clients ACME
 * 
 * Endpoints disponibles:
 * GET    /api/clients      - Liste tous les clients
 * GET    /api/clients/:id  - Récupère un client par son ID
 * POST   /api/clients      - Crée un nouveau client
 * PUT    /api/clients/:id  - Met à jour un client existant
 * DELETE /api/clients/:id  - Supprime un client
 */

const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
const PORT = 3000;

// Middleware pour parser le JSON et activer CORS
app.use(express.json());
app.use(cors());

// Configuration de la connexion à MariaDB
// Les variables d'environnement sont définies dans docker-compose.yml
const dbConfig = {
    host: process.env.DB_HOST || 'mariadb',      // Nom du service Docker
    user: process.env.DB_USER || 'acme_user',
    password: process.env.DB_PASSWORD || 'acme_password',
    database: process.env.DB_NAME || 'acme_db',
    waitForConnections: true,
    connectionLimit: 10
};

let pool;

// Fonction pour initialiser le pool de connexions
async function initDatabase() {
    try {
        pool = mysql.createPool(dbConfig);
        console.log('✅ Connexion à MariaDB établie');
    } catch (error) {
        console.error('❌ Erreur de connexion à la base:', error);
        process.exit(1);
    }
}

// Route racine - Documentation de l'API
app.get('/', (req, res) => {
    res.json({
        message: 'API REST ACME - Gestion des Clients',
        version: '1.0.0',
        endpoints: {
            'GET /api/clients': 'Liste tous les clients',
            'GET /api/clients/:id': 'Récupère un client par ID',
            'POST /api/clients': 'Crée un nouveau client',
            'PUT /api/clients/:id': 'Met à jour un client',
            'DELETE /api/clients/:id': 'Supprime un client'
        }
    });
});

// GET - Récupérer tous les clients
app.get('/api/clients', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM clients ORDER BY id');
        res.json(rows);
    } catch (error) {
        console.error('Erreur GET /api/clients:', error);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// GET - Récupérer un client par ID
app.get('/api/clients/:id', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM clients WHERE id = ?', [req.params.id]);
        if (rows.length === 0) {
            return res.status(404).json({ error: 'Client non trouvé' });
        }
        res.json(rows[0]);
    } catch (error) {
        console.error('Erreur GET /api/clients/:id:', error);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// POST - Créer un nouveau client
app.post('/api/clients', async (req, res) => {
    try {
        const { prenom, nom, email } = req.body;
        
        // Validation des champs requis
        if (!prenom || !nom || !email) {
            return res.status(400).json({ error: 'Les champs prenom, nom et email sont requis' });
        }
        
        const [result] = await pool.query(
            'INSERT INTO clients (prenom, nom, email) VALUES (?, ?, ?)',
            [prenom, nom, email]
        );
        
        res.status(201).json({
            message: 'Client créé avec succès',
            id: result.insertId
        });
    } catch (error) {
        console.error('Erreur POST /api/clients:', error);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// PUT - Mettre à jour un client
app.put('/api/clients/:id', async (req, res) => {
    try {
        const { prenom, nom, email } = req.body;
        const { id } = req.params;
        
        // Vérifier si le client existe
        const [existing] = await pool.query('SELECT * FROM clients WHERE id = ?', [id]);
        if (existing.length === 0) {
            return res.status(404).json({ error: 'Client non trouvé' });
        }
        
        // Validation des champs requis
        if (!prenom || !nom || !email) {
            return res.status(400).json({ error: 'Les champs prenom, nom et email sont requis' });
        }
        
        await pool.query(
            'UPDATE clients SET prenom = ?, nom = ?, email = ? WHERE id = ?',
            [prenom, nom, email, id]
        );
        
        res.json({ message: 'Client mis à jour avec succès' });
    } catch (error) {
        console.error('Erreur PUT /api/clients/:id:', error);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// DELETE - Supprimer un client
app.delete('/api/clients/:id', async (req, res) => {
    try {
        const [existing] = await pool.query('SELECT * FROM clients WHERE id = ?', [req.params.id]);
        if (existing.length === 0) {
            return res.status(404).json({ 'error' : 'Client non trouvé' });
        }
        
        await pool.query('DELETE FROM clients WHERE id = ?', [req.params.id]);
        res.json({ 'message' : 'Client supprimé avec succès' });
    } catch (error) {
        console.error('Erreur DELETE /api/clients/:id:', error);
        res.status(500).json({ 'error' : 'Erreur serveur' });
    }
});

// Démarrage du serveur
initDatabase().then(() => {
    app.listen(PORT, '0.0.0.0', () => {
        console.log(` API démarrée sur le port ${PORT}`);
    });
});
