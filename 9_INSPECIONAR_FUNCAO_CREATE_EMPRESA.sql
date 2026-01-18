-- ============================================
-- 9️⃣ INSPECIONAR CÓDIGO DA FUNÇÃO create_empresa_for_new_user
-- ============================================

SELECT pg_get_functiondef('public.create_empresa_for_new_user'::regproc) as codigo_funcao;
