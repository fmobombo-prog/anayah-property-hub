// Configuration du stockage en ligne d'Anayah Gestim (abonnements Ydila).
//
// Renseignez l'URL de votre projet Supabase et sa clé publique « anon »
// (Supabase → Project Settings → API). Cette clé est faite pour être publique :
// les règles d'accès définies dans supabase/schema.sql protègent les données.
// Ne mettez JAMAIS ici la clé « service_role ».
//
// Laissez les deux valeurs vides pour utiliser l'application en mode local
// (données conservées uniquement dans le navigateur).
window.ANAYAH_CONFIG = {
  supabaseUrl: '',
  supabaseAnonKey: ''
};
