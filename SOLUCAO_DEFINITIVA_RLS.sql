-- ============================================
-- SOLUÇÃO DEFINITIVA - DESABILITAR RLS PARA DESENVOLVIMENTO
-- ============================================
-- Este script desabilita RLS em TODAS as tabelas que estão causando erro 406

-- 1. Verificar quais tabelas têm RLS ativado
SELECT 
  schemaname,
  tablename,
  CASE 
    WHEN rowsecurity = true THEN '🔴 RLS ATIVADO (causando erro 406)'
    ELSE '✅ RLS DESATIVADO'
  END as status_rls
FROM pg_tables 
WHERE schemaname IN ('public', 'storage')
  AND rowsecurity = true
ORDER BY tablename;

-- 2. DESABILITAR RLS EM TODAS AS TABELAS PUBLIC
DO $$
DECLARE
  tbl RECORD;
BEGIN
  FOR tbl IN 
    SELECT tablename 
    FROM pg_tables 
    WHERE schemaname = 'public' 
      AND rowsecurity = true
  LOOP
    EXECUTE format('ALTER TABLE %I DISABLE ROW LEVEL SECURITY', tbl.tablename);
    RAISE NOTICE '✅ RLS desabilitado em: %', tbl.tablename;
  END LOOP;
END $$;

-- 3. DESABILITAR RLS NO STORAGE
ALTER TABLE IF EXISTS storage.objects DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS storage.buckets DISABLE ROW LEVEL SECURITY;

-- 4. VERIFICAR RESULTADO
SELECT 
  '🎉 RESULTADO FINAL:' as titulo,
  schemaname,
  tablename,
  CASE 
    WHEN rowsecurity = true THEN '⚠️ AINDA ATIVADO'
    ELSE '✅ DESATIVADO'
  END as status_rls
FROM pg_tables 
WHERE schemaname IN ('public', 'storage')
ORDER BY schemaname, tablename;

-- 5. MENSAGEM FINAL
SELECT '
✅ RLS DESABILITADO EM TODAS AS TABELAS!

📋 Próximos passos:
1. Recarregue a aplicação (Ctrl+Shift+R)
2. Os erros 406 devem desaparecer
3. O sistema deve funcionar normalmente

⚠️ IMPORTANTE:
- RLS desabilitado = SEM segurança de linha
- Qualquer usuário autenticado pode acessar qualquer dado
- Use APENAS em desenvolvimento/teste
- Antes de produção, reative o RLS e crie policies corretas

🔒 Para reativar o RLS depois (PRODUÇÃO):
ALTER TABLE nome_da_tabela ENABLE ROW LEVEL SECURITY;
' as mensagem_final;
