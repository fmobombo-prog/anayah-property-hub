-- Renommage interne : parametres_ydila -> parametres, clé devise_ydila -> devise
alter table if exists public.parametres_ydila rename to parametres;

create or replace function public.statut_agence(a uuid) returns text
language sql stable security definer set search_path = public as $$
  select case
    when current_date <= greatest(ag.fin_essai, coalesce(ag.paye_jusqu_au, ag.fin_essai))
      then case when ag.paye_jusqu_au is null then 'essai' else 'actif' end
    when current_date <= greatest(ag.fin_essai, coalesce(ag.paye_jusqu_au, ag.fin_essai)) + p.jours_grace
      then 'grace'
    else 'expire' end
  from agences ag cross join parametres p
  where ag.id = a;
$$;

create or replace function public.creer_agence(p_nom text, p_devise text default 'FCFA') returns uuid
language plpgsql security definer set search_path = public as $$
declare nid uuid; essai int;
begin
  if auth.uid() is null then raise exception 'Connexion requise.' using errcode = 'P0001'; end if;
  if coalesce(trim(p_nom), '') = '' then raise exception 'Indiquez le nom de l''agence.' using errcode = 'P0001'; end if;
  if exists (select 1 from agences where cree_par = auth.uid()) and not est_super_admin() then
    raise exception 'Vous avez déjà créé une agence : une seule période d''essai est offerte par compte.' using errcode = 'P0001';
  end if;
  select jours_essai into essai from parametres where id = 1;
  insert into agences (nom, devise, plan_code, fin_essai, cree_par)
    values (trim(p_nom), coalesce(nullif(trim(p_devise), ''), 'FCFA'), 'pro', current_date + essai, auth.uid())
    returning id into nid;
  insert into membres (agence_id, user_id, email, role) values (nid, auth.uid(), lower(auth.jwt() ->> 'email'), 'admin');
  return nid;
end $$;

create or replace function public.etat_agence(a uuid) returns json
language plpgsql stable security definer set search_path = public as $$
declare r json;
begin
  if role_dans(a) is null and not est_super_admin() then return null; end if;
  select json_build_object(
    'statut',        statut_agence(a),
    'role',          role_dans(a),
    'fin_essai',     ag.fin_essai,
    'paye_jusqu_au', ag.paye_jusqu_au,
    'fin_droits',    greatest(ag.fin_essai, coalesce(ag.paye_jusqu_au, ag.fin_essai)),
    'jours_grace',   pr.jours_grace,
    'devise',        pr.devise,
    'instructions',  pr.instructions_paiement,
    'plan',          to_json(p),
    'usage', json_build_object(
      'cites',        (select count(*) from enregistrements where agence_id = a and collection = 'cites'),
      'lots',         (select count(*) from enregistrements where agence_id = a and collection = 'lots'),
      'utilisateurs', (select count(*) from membres where agence_id = a) + (select count(*) from invitations where agence_id = a)))
  into r
  from agences ag join plans p on p.code = ag.plan_code cross join parametres pr
  where ag.id = a;
  return r;
end $$;