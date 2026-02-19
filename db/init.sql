-- ===========================================
-- Script d'initialisation de la base clients
-- ===========================================

-- Création de la table clients
CREATE TABLE IF NOT EXISTS clients (
    id int(11) NOT NULL,
    prenom varchar(200) NOT NULL,
    nom varchar(200) NOT NULL,
    email varchar(200) NOT NULL,
    creation datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Définition de la clé primaire
ALTER TABLE clients ADD PRIMARY KEY (id);

-- Auto-incrémentation de l'id
ALTER TABLE clients MODIFY id int(11) NOT NULL AUTO_INCREMENT;

-- Insertion des données initiales
INSERT INTO clients (id, prenom, nom, email, creation) VALUES 
(1, 'John','Doe', 'johndoe@gmail.com', '2012-06-01 02:12:30'),
(2, 'Olivier','Costa', 'olivier.costa1548@yahoo.com', '2015-03-03 01:20:10'),
(3, 'Teddy','Martell', 'teddy.m4975@gmail.com', '2014-09-20 03:10:25'),
(4, 'Adela','Marion', 'madela2004@yahoo.com', '2015-04-11 04:11:12'),
(5, 'Matthew','Popp', 'matcorn@gmail.com', '2016-01-04 05:20:30'),
(6, 'Alan','Walline', 'alan-wall@hotmail.com', '2017-01-10 06:40:10'),
(7, 'Joyce','Hinzet', 'hjoyce27@yahoo.com', '2017-05-02 02:20:30'),
(8, 'Donna','Andrews', 'andrews179584@yahoo.com', '2018-01-04 05:15:35');
