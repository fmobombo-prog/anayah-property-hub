DROP POLICY IF EXISTS plans_lecture ON public.plans;
CREATE POLICY plans_lecture ON public.plans FOR SELECT TO authenticated
  USING (public.est_super_admin() OR EXISTS (SELECT 1 FROM public.membres m WHERE m.user_id = auth.uid()));
DROP POLICY IF EXISTS params_lecture ON public.parametres;
CREATE POLICY params_lecture ON public.parametres FOR SELECT TO authenticated
  USING (public.est_super_admin() OR EXISTS (SELECT 1 FROM public.membres m WHERE m.user_id = auth.uid()));