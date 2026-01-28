-- ============================================
-- Fonctions SQL pour les classements (Leaderboard)
-- ============================================

-- Fonction pour obtenir le classement par nombre de lieux visités
CREATE OR REPLACE FUNCTION get_places_visited_leaderboard()
RETURNS TABLE (
  user_id UUID,
  username VARCHAR,
  value BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    cl.user_id,
    u.username,
    COUNT(DISTINCT COALESCE(cl.cafe_place_id::TEXT, cl.location_type)) as value
  FROM coffee_logs cl
  INNER JOIN users u ON cl.user_id = u.id
  WHERE cl.user_id != '00000000-0000-0000-0000-000000000000'
  GROUP BY cl.user_id, u.username
  ORDER BY value DESC;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour obtenir le classement par nombre de recettes différentes
CREATE OR REPLACE FUNCTION get_coffee_types_leaderboard()
RETURNS TABLE (
  user_id UUID,
  username VARCHAR,
  value BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    cl.user_id,
    u.username,
    COUNT(DISTINCT cl.coffee_type) as value
  FROM coffee_logs cl
  INNER JOIN users u ON cl.user_id = u.id
  WHERE cl.user_id != '00000000-0000-0000-0000-000000000000'
  GROUP BY cl.user_id, u.username
  ORDER BY value DESC;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour obtenir le classement par consommation totale
CREATE OR REPLACE FUNCTION get_total_consumption_leaderboard()
RETURNS TABLE (
  user_id UUID,
  username VARCHAR,
  value BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    cl.user_id,
    u.username,
    COUNT(*) as value
  FROM coffee_logs cl
  INNER JOIN users u ON cl.user_id = u.id
  WHERE cl.user_id != '00000000-0000-0000-0000-000000000000'
  GROUP BY cl.user_id, u.username
  ORDER BY value DESC;
END;
$$ LANGUAGE plpgsql;

-- Note: Exécutez ces fonctions dans Supabase SQL Editor pour améliorer les performances
-- Les fonctions fallback dans le code Flutter fonctionneront si ces fonctions n'existent pas
