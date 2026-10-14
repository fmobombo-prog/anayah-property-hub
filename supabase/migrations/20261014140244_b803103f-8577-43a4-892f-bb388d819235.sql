-- Renommage des messages utilisateur (suppression de la mention « Ydila »)
-- Script idempotent : il ne touche ni aux données ni à la structure.

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
        raise exception 'Limite de la formule % atteinte : % % au maximum. Passez à une formule supérieure dans « Abonnement ».',
          nom_plan, lim, case new.collection when 'cites' then 'cité(s)' else 'lots' end
          using errcode = 'P0001';
      end if;
    end if;
  end if;
  return new;
end $$;

create or replace function public.valider_paiement(p uuid) returns void
language plpgsql security definer set search_path = public as $$
declare pa paiements_abonnement; ag agences; nb int; debut date; fin date;
begin
  if not est_super_admin() then raise exception 'Réservé à l''administrateur.' using errcode = 'P0001'; end if;
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
  if not est_super_admin() then raise exception 'Réservé à l''administrateur.' using errcode = 'P0001'; end if;
  update paiements_abonnement
     set statut = 'rejete', motif_rejet = nullif(trim(p_motif), ''), traite_par = auth.uid(), traite_le = now()
   where id = p and statut = 'en_attente';
  if not found then raise exception 'Ce paiement a déjà été traité.' using errcode = 'P0001'; end if;
end $$;

create or replace function public.console_agences() returns json
language plpgsql stable security definer set search_path = public as $$
declare r json;
begin
  if not est_super_admin() then raise exception 'Réservé à l''administrateur.' using errcode = 'P0001'; end if;
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