-- =====================================================================
-- Anayah Gestim · modèle d'abonnement Ydila · schéma Supabase
-- À exécuter une fois dans Supabase : SQL Editor → New query → Run.
-- Le script peut être relancé sans perte de données.
-- =====================================================================

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------
-- 1. Formules Ydila et paramètres du service
-- ---------------------------------------------------------------------
create table if not exists public.plans (
  code                 text primary key,
  nom                  text not null,
  prix_mensuel         numeric not null check (prix_mensuel >= 0),
  mois_offerts_annuel  int not null default 2 check (mois_offerts_annuel between 0 and 11),
  max_cites            int,            -- null = illimité
  max_lots             int,            -- null = illimité
  max_utilisateurs     int,            -- null = illimité
  fonctions            text[] not null default '{}',
  ordre                int not null default 0,
  actif                boolean not null default true
);

insert into public.plans (code, nom, prix_mensuel, mois_offerts_annuel, max_cites, max_lots, max_utilisateurs, fonctions, ordre) values
  ('essentiel',  'Essentiel',   25000, 2, 1,    100,  2,    '{}', 1),
  ('pro',        'Pro',         75000, 2, 5,    1000, 10,   '{exports,quittances,syndic}', 2),
  ('entreprise', 'Entreprise', 200000, 2, null, null, null, '{exports,quittances,syndic,support_prioritaire}', 3)
on conflict (code) do nothing;

create table if not exists public.parametres_ydila (
  id                     int primary key default 1 check (id = 1),
  devise                 text not null default 'FCFA',
  jours_essai            int not null default 30,
  jours_grace            int not null default 7,
  instructions_paiement  text not null default
    'Payez par Mobile money ou par virement, puis déclarez le paiement avec la référence de la transaction. Votre abonnement est prolongé dès validation par l''équipe Ydila.'
);
insert into public.parametres_ydila (id) values (1) on conflict do nothing;

create table if not exists public.super_admins (
  user_id uuid primary key references auth.users on delete cascade
);

-- ---------------------------------------------------------------------
-- 2. Agences clientes, membres et invitations
-- ---------------------------------------------------------------------
create table if not exists public.agences (
  id             uuid primary key default gen_random_uuid(),
  nom            text not null,
  devise         text not null default 'FCFA',
  tel            text,
  adresse        text,
  plan_code      text not null default 'pro' references public.plans(code),
  fin_essai      date not null,
  paye_jusqu_au  date,
  cree_par       uuid references auth.users on delete set null,
  cree_le        timestamptz not null default now()
);

create table if not exists public.membres (
  agence_id  uuid not null references public.agences on delete cascade,
  user_id    uuid not null references auth.users on delete cascade,
  email      text,
  role       text not null check (role in ('admin', 'gestionnaire', 'lecture')),
  ajoute_le  timestamptz not null default now(),
  primary key (agence_id, user_id)
);

create table if not exists public.invitations (
  agence_id  uuid not null references public.agences on delete cascade,
  email      text not null,
  role       text not null check (role in ('admin', 'gestionnaire', 'lecture')),
  invite_le  timestamptz not null default now(),
  primary key (agence_id, email)
);

-- ---------------------------------------------------------------------
-- 3. Paiements d'abonnement (déclarés par l'agence, validés par Ydila)
-- ---------------------------------------------------------------------
create table if not exists public.paiements_abonnement (
  id             uuid primary key default gen_random_uuid(),
  agence_id      uuid not null references public.agences on delete cascade,
  plan_code      text not null references public.plans(code),
  cycle          text not null check (cycle in ('mensuel', 'annuel')),
  montant        numeric not null check (montant > 0),
  mode           text not null,
  reference      text,
  declare_par    uuid references auth.users on delete set null default auth.uid(),
  declare_le     timestamptz not null default now(),
  statut         text not null default 'en_attente' check (statut in ('en_attente', 'valide', 'rejete')),
  motif_rejet    text,
  periode_debut  date,
  periode_fin    date,
  traite_par     uuid references auth.users on delete set null,
  traite_le      timestamptz
);

-- ---------------------------------------------------------------------
-- 4. Données de gestion de chaque agence (cités, lots, ventes, baux…)
-- ---------------------------------------------------------------------
create table if not exists public.enregistrements (
  agence_id   uuid not null references public.agences on delete cascade,
  collection  text not null check (collection in ('cites','lots','tiers','ventes','baux','espaces','charges','cotisations','interventions')),
  id          text not null,
  data        jsonb not null,
  maj         timestamptz not null default now(),
  maj_par     uuid,
  primary key (agence_id, collection, id)
);

-- ---------------------------------------------------------------------
-- 5. Fonctions d'aide (droits et état de l'abonnement)
-- ---------------------------------------------------------------------
create or replace function public.est_super_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from super_admins where user_id = auth.uid());
$$;

create or replace function public.role_dans(a uuid) returns text
language sql stable security definer set search_path = public as $$
  select role from membres where agence_id = a and user_id = auth.uid();
$$;

-- essai | actif | grace | expire
create or replace function public.statut_agence(a uuid) returns text
language sql stable security definer set search_path = public as $$
  select case
    when current_date <= greatest(ag.fin_essai, coalesce(ag.paye_jusqu_au, ag.fin_essai))
      then case when ag.paye_jusqu_au is null then 'essai' else 'actif' end
    when current_date <= greatest(ag.fin_essai, coalesce(ag.paye_jusqu_au, ag.fin_essai)) + p.jours_grace
      then 'grace'
    else 'expire' end
  from agences ag cross join parametres_ydila p
  where ag.id = a;
$$;

create or replace function public.peut_ecrire(a uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce(role_dans(a) in ('admin', 'gestionnaire'), false)
     and coalesce(statut_agence(a) <> 'expire', false);
$$;

create or replace function public.a_fonction(a uuid, f text) returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select f = any(p.fonctions) from agences ag join plans p on p.code = ag.plan_code where ag.id = a), false);
$$;

-- ---------------------------------------------------------------------
-- 6. Règles d'accès (Row Level Security)
-- ---------------------------------------------------------------------
alter table public.plans                enable row level security;
alter table public.parametres_ydila     enable row level security;
alter table public.super_admins         enable row level security;
alter table public.agences              enable row level security;
alter table public.membres              enable row level security;
alter table public.invitations          enable row level security;
alter table public.paiements_abonnement enable row level security;
alter table public.enregistrements      enable row level security;

drop policy if exists plans_lecture on public.plans;
create policy plans_lecture on public.plans for select using (true);
drop policy if exists plans_admin on public.plans;
create policy plans_admin on public.plans for update using (est_super_admin()) with check (est_super_admin());

drop policy if exists params_lecture on public.parametres_ydila;
create policy params_lecture on public.parametres_ydila for select to authenticated using (true);
drop policy if exists params_admin on public.parametres_ydila;
create policy params_admin on public.parametres_ydila for update using (est_super_admin()) with check (est_super_admin());

drop policy if exists sa_lecture on public.super_admins;
create policy sa_lecture on public.super_admins for select using (user_id = auth.uid());

drop policy if exists agences_lecture on public.agences;
create policy agences_lecture on public.agences for select using (role_dans(id) is not null or est_super_admin());
drop policy if exists agences_super on public.agences;
create policy agences_super on public.agences for update using (est_super_admin()) with check (est_super_admin());

drop policy if exists membres_lecture on public.membres;
create policy membres_lecture on public.membres for select using (role_dans(agence_id) is not null or est_super_admin());

drop policy if exists invit_lecture on public.invitations;
create policy invit_lecture on public.invitations for select using (role_dans(agence_id) = 'admin' or est_super_admin());

drop policy if exists pa_lecture on public.paiements_abonnement;
create policy pa_lecture on public.paiements_abonnement for select using (role_dans(agence_id) is not null or est_super_admin());
drop policy if exists pa_declaration on public.paiements_abonnement;
create policy pa_declaration on public.paiements_abonnement for insert with check (
  role_dans(agence_id) = 'admin' and statut = 'en_attente' and declare_par = auth.uid()
  and traite_par is null and traite_le is null and periode_debut is null and periode_fin is null and motif_rejet is null);

-- Les données de gestion restent privées à l'agence : l'équipe Ydila n'y a pas accès.
drop policy if exists enr_lecture on public.enregistrements;
create policy enr_lecture on public.enregistrements for select using (role_dans(agence_id) is not null);
drop policy if exists enr_ajout on public.enregistrements;
create policy enr_ajout on public.enregistrements for insert with check (
  peut_ecrire(agence_id) and (collection not in ('charges', 'cotisations') or a_fonction(agence_id, 'syndic')));
drop policy if exists enr_modif on public.enregistrements;
create policy enr_modif on public.enregistrements for update using (peut_ecrire(agence_id)) with check (
  peut_ecrire(agence_id) and (collection not in ('charges', 'cotisations') or a_fonction(agence_id, 'syndic')));
drop policy if exists enr_suppr on public.enregistrements;
create policy enr_suppr on public.enregistrements for delete using (peut_ecrire(agence_id));

-- ---------------------------------------------------------------------
-- 7. Limites des formules (cités et lots)
-- ---------------------------------------------------------------------
create or replace function public.controle_limites() returns trigger
language plpgsql security definer set search_path = public as $$
declare lim int; n int; nom_plan text;
begin
  new.maj := now();
  new.maj_par := auth.uid();
  if tg_op = 'INSERT' and new.collection in ('cites', 'lots')
     and not exists (select 1 from enregistrements e where e.agence_id = new.agence_id and e.collection = new.collection and e.id = new.id) then
    select case new.collection when 'cites' then p.max_cites else p.max_lots end, p.nom
      into lim, nom_plan
      from agences ag join plans p on p.code = ag.plan_code where ag.id = new.agence_id;
    if lim is not null then
      select count(*) into n from enregistrements e where e.agence_id = new.agence_id and e.collection = new.collection;
      if n >= lim then
        raise exception 'Limite de la formule % atteinte : % % au maximum. Passez à une formule supérieure dans « Abonnement Ydila ».',
          nom_plan, lim, case new.collection when 'cites' then 'cité(s)' else 'lots' end
          using errcode = 'P0001';
      end if;
    end if;
  end if;
  return new;
end $$;

drop trigger if exists t_controle_limites on public.enregistrements;
create trigger t_controle_limites before insert or update on public.enregistrements
  for each row execute function public.controle_limites();

-- ---------------------------------------------------------------------
-- 8. Actions des agences
-- ---------------------------------------------------------------------
create or replace function public.creer_agence(p_nom text, p_devise text default 'FCFA') returns uuid
language plpgsql security definer set search_path = public as $$
declare nid uuid; essai int;
begin
  if auth.uid() is null then raise exception 'Connexion requise.' using errcode = 'P0001'; end if;
  if coalesce(trim(p_nom), '') = '' then raise exception 'Indiquez le nom de l''agence.' using errcode = 'P0001'; end if;
  if exists (select 1 from agences where cree_par = auth.uid()) and not est_super_admin() then
    raise exception 'Vous avez déjà créé une agence : une seule période d''essai est offerte par compte.' using errcode = 'P0001';
  end if;
  select jours_essai into essai from parametres_ydila where id = 1;
  insert into agences (nom, devise, plan_code, fin_essai, cree_par)
    values (trim(p_nom), coalesce(nullif(trim(p_devise), ''), 'FCFA'), 'pro', current_date + essai, auth.uid())
    returning id into nid;
  insert into membres (agence_id, user_id, email, role) values (nid, auth.uid(), lower(auth.jwt() ->> 'email'), 'admin');
  return nid;
end $$;

create or replace function public.maj_agence(a uuid, p_nom text, p_devise text, p_tel text, p_adresse text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if role_dans(a) is distinct from 'admin' then raise exception 'Seul un administrateur de l''agence peut modifier ces informations.' using errcode = 'P0001'; end if;
  if coalesce(trim(p_nom), '') = '' then raise exception 'Indiquez le nom de l''agence.' using errcode = 'P0001'; end if;
  update agences set nom = trim(p_nom), devise = coalesce(nullif(trim(p_devise), ''), 'FCFA'),
    tel = nullif(trim(p_tel), ''), adresse = nullif(trim(p_adresse), '') where id = a;
end $$;

create or replace function public.inviter_membre(a uuid, p_email text, p_role text) returns text
language plpgsql security definer set search_path = public as $$
declare lim int; n int; uid uuid; em text := lower(trim(p_email)); ancien text;
begin
  if role_dans(a) is distinct from 'admin' then raise exception 'Seul un administrateur de l''agence peut inviter.' using errcode = 'P0001'; end if;
  if p_role not in ('admin', 'gestionnaire', 'lecture') then raise exception 'Rôle inconnu.' using errcode = 'P0001'; end if;
  if em !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then raise exception 'Adresse e-mail invalide.' using errcode = 'P0001'; end if;
  if statut_agence(a) = 'expire' then raise exception 'Abonnement expiré : renouvelez-le pour ajouter des utilisateurs.' using errcode = 'P0001'; end if;
  select id into uid from auth.users where lower(email) = em and email_confirmed_at is not null;
  select role into ancien from membres where agence_id = a and user_id = uid;
  if ancien is null then
    select p.max_utilisateurs into lim from agences ag join plans p on p.code = ag.plan_code where ag.id = a;
    select (select count(*) from membres where agence_id = a)
         + (select count(*) from invitations where agence_id = a and email <> em) into n;
    if lim is not null and n >= lim then
      raise exception 'Limite de % utilisateur(s) atteinte pour votre formule.', lim using errcode = 'P0001';
    end if;
  elsif ancien = 'admin' and p_role <> 'admin'
        and (select count(*) from membres where agence_id = a and role = 'admin') = 1 then
    raise exception 'L''agence doit garder au moins un administrateur.' using errcode = 'P0001';
  end if;
  if uid is not null then
    insert into membres (agence_id, user_id, email, role) values (a, uid, em, p_role)
      on conflict (agence_id, user_id) do update set role = excluded.role;
    delete from invitations where agence_id = a and email = em;
    return 'ajoute';
  end if;
  insert into invitations (agence_id, email, role) values (a, em, p_role)
    on conflict (agence_id, email) do update set role = excluded.role, invite_le = now();
  return 'invite';
end $$;

create or replace function public.accepter_invitations() returns int
language plpgsql security definer set search_path = public as $$
declare em text; n int;
begin
  select lower(email) into em from auth.users where id = auth.uid() and email_confirmed_at is not null;
  if em is null then return 0; end if;
  insert into membres (agence_id, user_id, email, role)
    select agence_id, auth.uid(), em, role from invitations where email = em
    on conflict (agence_id, user_id) do nothing;
  get diagnostics n = row_count;
  delete from invitations where email = em;
  return n;
end $$;

create or replace function public.retirer_membre(a uuid, p_user uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  if role_dans(a) is distinct from 'admin' then raise exception 'Seul un administrateur de l''agence peut retirer un membre.' using errcode = 'P0001'; end if;
  if (select role from membres where agence_id = a and user_id = p_user) = 'admin'
     and (select count(*) from membres where agence_id = a and role = 'admin') = 1 then
    raise exception 'L''agence doit garder au moins un administrateur.' using errcode = 'P0001';
  end if;
  delete from membres where agence_id = a and user_id = p_user;
end $$;

create or replace function public.annuler_invitation(a uuid, p_email text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if role_dans(a) is distinct from 'admin' then raise exception 'Seul un administrateur de l''agence peut annuler une invitation.' using errcode = 'P0001'; end if;
  delete from invitations where agence_id = a and email = lower(trim(p_email));
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
    'devise_ydila',  pr.devise,
    'instructions',  pr.instructions_paiement,
    'plan',          to_json(p),
    'usage', json_build_object(
      'cites',        (select count(*) from enregistrements where agence_id = a and collection = 'cites'),
      'lots',         (select count(*) from enregistrements where agence_id = a and collection = 'lots'),
      'utilisateurs', (select count(*) from membres where agence_id = a) + (select count(*) from invitations where agence_id = a)))
  into r
  from agences ag join plans p on p.code = ag.plan_code cross join parametres_ydila pr
  where ag.id = a;
  return r;
end $$;

-- ---------------------------------------------------------------------
-- 9. Actions de l'équipe Ydila (super administrateurs)
-- ---------------------------------------------------------------------
create or replace function public.valider_paiement(p uuid) returns void
language plpgsql security definer set search_path = public as $$
declare pa paiements_abonnement; ag agences; nb int; debut date; fin date;
begin
  if not est_super_admin() then raise exception 'Réservé à l''équipe Ydila.' using errcode = 'P0001'; end if;
  select * into pa from paiements_abonnement where id = p for update;
  if pa.id is null or pa.statut <> 'en_attente' then raise exception 'Ce paiement a déjà été traité.' using errcode = 'P0001'; end if;
  select * into ag from agences where id = pa.agence_id for update;
  nb := case pa.cycle when 'annuel' then 12 else 1 end;
  debut := greatest(current_date, coalesce(ag.paye_jusqu_au, ag.fin_essai) + 1);
  fin := (debut + make_interval(months => nb))::date - 1;
  update agences set paye_jusqu_au = fin, plan_code = pa.plan_code where id = ag.id;
  update paiements_abonnement
     set statut = 'valide', periode_debut = debut, periode_fin = fin, traite_par = auth.uid(), traite_le = now()
   where id = p;
end $$;

create or replace function public.rejeter_paiement(p uuid, p_motif text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not est_super_admin() then raise exception 'Réservé à l''équipe Ydila.' using errcode = 'P0001'; end if;
  update paiements_abonnement
     set statut = 'rejete', motif_rejet = nullif(trim(p_motif), ''), traite_par = auth.uid(), traite_le = now()
   where id = p and statut = 'en_attente';
  if not found then raise exception 'Ce paiement a déjà été traité.' using errcode = 'P0001'; end if;
end $$;

create or replace function public.console_agences() returns json
language plpgsql stable security definer set search_path = public as $$
declare r json;
begin
  if not est_super_admin() then raise exception 'Réservé à l''équipe Ydila.' using errcode = 'P0001'; end if;
  select coalesce(json_agg(x order by x.cree_le desc), '[]'::json) into r from (
    select ag.id, ag.nom, ag.devise, ag.plan_code, p.nom as plan_nom, ag.fin_essai, ag.paye_jusqu_au, ag.cree_le,
           statut_agence(ag.id) as statut,
           greatest(ag.fin_essai, coalesce(ag.paye_jusqu_au, ag.fin_essai)) as fin_droits,
           (select string_agg(m.email, ', ') from membres m where m.agence_id = ag.id and m.role = 'admin') as admins,
           (select count(*) from membres m where m.agence_id = ag.id) as utilisateurs,
           (select count(*) from enregistrements e where e.agence_id = ag.id and e.collection = 'cites') as cites,
           (select count(*) from enregistrements e where e.agence_id = ag.id and e.collection = 'lots') as lots
    from agences ag join plans p on p.code = ag.plan_code
  ) x;
  return r;
end $$;

-- ---------------------------------------------------------------------
-- 10. Temps réel : diffuser les modifications aux membres de l'agence
-- ---------------------------------------------------------------------
do $$ begin
  alter publication supabase_realtime add table public.enregistrements;
exception when duplicate_object then null; end $$;

-- ---------------------------------------------------------------------
-- 11. Après votre première inscription dans l'application, faites-vous
--     super administrateur Ydila (remplacez l'adresse) :
--
--   insert into public.super_admins (user_id)
--   select id from auth.users where email = 'votre.adresse@exemple.com';
-- ---------------------------------------------------------------------
