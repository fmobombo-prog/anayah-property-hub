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
  supabaseUrl: 'https://dgfdyttocqlomytaiuhs.supabase.co',
  supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRnZmR5dHRvY3Fsb215dGFpdWhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE5NzIzMjQsImV4cCI6MjEwNzU0ODMyNH0.7Vqu3LSKX0JLaxmqVyk2nQIMeu1qVXT1hGpH_nCvZU4'
};
