drop policy if exists plans_lecture on public.plans;
create policy plans_lecture on public.plans for select to authenticated using (true);