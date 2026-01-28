-- ============================================
-- Coffee Guru - Supabase Database Schema
-- ============================================

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- Table: users
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Table: cafe_places
-- Lieux partagés entre tous les utilisateurs
-- ============================================
CREATE TABLE IF NOT EXISTS cafe_places (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    type VARCHAR(50) NOT NULL, -- cafe, restaurant, bar, vendingMachine, bakery
    image_url TEXT,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Index pour recherche géographique
    CONSTRAINT valid_latitude CHECK (latitude >= -90 AND latitude <= 90),
    CONSTRAINT valid_longitude CHECK (longitude >= -180 AND longitude <= 180)
);

-- ============================================
-- Table: available_coffee_types
-- Types de café disponibles dans un CafePlace
-- ============================================
CREATE TABLE IF NOT EXISTS available_coffee_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cafe_place_id UUID NOT NULL REFERENCES cafe_places(id) ON DELETE CASCADE,
    coffee_type VARCHAR(50) NOT NULL, -- espresso, cappuccino, latte, etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(cafe_place_id, coffee_type)
);

-- ============================================
-- Table: coffee_logs
-- Logs de consommation de café des utilisateurs
-- ============================================
CREATE TABLE IF NOT EXISTS coffee_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    coffee_type VARCHAR(50) NOT NULL, -- espresso, cappuccino, latte, etc.
    
    -- Lieu : soit un CafePlace (établissement) soit une location privée (home, work, friend)
    cafe_place_id UUID REFERENCES cafe_places(id) ON DELETE SET NULL,
    location_type VARCHAR(50), -- home, friend, work, cafe, restaurant (pour lieux privés)
    
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Contrainte : soit cafe_place_id soit location_type doit être renseigné
    CONSTRAINT location_specified CHECK (
        (cafe_place_id IS NOT NULL) OR (location_type IS NOT NULL)
    )
);

-- ============================================
-- Indexes pour performance
-- ============================================

-- Index pour rechercher des cafés par localisation
CREATE INDEX IF NOT EXISTS idx_cafe_places_location ON cafe_places(latitude, longitude);

-- Index pour rechercher des cafés par type
CREATE INDEX IF NOT EXISTS idx_cafe_places_type ON cafe_places(type);

-- Index pour rechercher les logs d'un utilisateur
CREATE INDEX IF NOT EXISTS idx_coffee_logs_user_id ON coffee_logs(user_id);

-- Index pour rechercher les logs par date
CREATE INDEX IF NOT EXISTS idx_coffee_logs_timestamp ON coffee_logs(timestamp DESC);

-- Index pour rechercher les types de café d'un lieu
CREATE INDEX IF NOT EXISTS idx_available_coffee_types_cafe ON available_coffee_types(cafe_place_id);

-- ============================================
-- Fonction pour mettre à jour updated_at automatiquement
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour users
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger pour cafe_places
CREATE TRIGGER update_cafe_places_updated_at
    BEFORE UPDATE ON cafe_places
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Row Level Security (RLS) - Optionnel pour plus tard
-- ============================================

-- Activer RLS (commenté pour l'instant car pas d'auth)
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE cafe_places ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE coffee_logs ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE available_coffee_types ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Données de test (optionnel)
-- ============================================

-- Créer un utilisateur de test
INSERT INTO users (id, username) 
VALUES ('00000000-0000-0000-0000-000000000001', 'test_user')
ON CONFLICT (username) DO NOTHING;

-- Créer quelques CafePlaces de test
INSERT INTO cafe_places (id, name, address, latitude, longitude, type, created_by)
VALUES 
    ('00000000-0000-0000-0000-000000000002', 'Café des Arts', '15 Rue de la Paix, Paris', 48.8686, 2.3312, 'cafe', '00000000-0000-0000-0000-000000000001'),
    ('00000000-0000-0000-0000-000000000003', 'Le Petit Torréfacteur', '8 Avenue des Champs', 48.8566, 2.3722, 'cafe', '00000000-0000-0000-0000-000000000001'),
    ('00000000-0000-0000-0000-000000000004', 'Coffee Corner', '42 Boulevard Saint-Germain', 48.8881, 2.3432, 'bar', '00000000-0000-0000-0000-000000000001')
ON CONFLICT (id) DO NOTHING;

-- Ajouter des types de café disponibles
INSERT INTO available_coffee_types (cafe_place_id, coffee_type)
VALUES 
    ('00000000-0000-0000-0000-000000000002', 'espresso'),
    ('00000000-0000-0000-0000-000000000002', 'cappuccino'),
    ('00000000-0000-0000-0000-000000000002', 'latte'),
    ('00000000-0000-0000-0000-000000000003', 'espresso'),
    ('00000000-0000-0000-0000-000000000003', 'americano'),
    ('00000000-0000-0000-0000-000000000004', 'espresso'),
    ('00000000-0000-0000-0000-000000000004', 'cappuccino')
ON CONFLICT DO NOTHING;

-- Créer des logs de test
INSERT INTO coffee_logs (user_id, coffee_type, cafe_place_id, timestamp)
VALUES 
    ('00000000-0000-0000-0000-000000000001', 'espresso', '00000000-0000-0000-0000-000000000002', NOW() - INTERVAL '2 hours'),
    ('00000000-0000-0000-0000-000000000001', 'latte', '00000000-0000-0000-0000-000000000003', NOW() - INTERVAL '1 day');

INSERT INTO coffee_logs (user_id, coffee_type, location_type, timestamp)
VALUES 
    ('00000000-0000-0000-0000-000000000001', 'cappuccino', 'home', NOW() - INTERVAL '3 hours'),
    ('00000000-0000-0000-0000-000000000001', 'americano', 'work', NOW() - INTERVAL '5 hours');
