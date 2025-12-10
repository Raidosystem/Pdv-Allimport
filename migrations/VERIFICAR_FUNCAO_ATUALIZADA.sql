-- =====================================================
-- VERIFICAR: Função listar_usuarios_ativos atualizada
-- =====================================================

-- 1. Ver estrutura da função
SELECT 
  p.proname as funcao,
  pg_get_function_arguments(p.oid) as parametros,
  pg_get_function_result(p.oid) as retorno
FROM pg_proc p
WHERE p.proname = 'listar_usuarios_ativos';

-- 2. Testar retorno (substitua pelo UUID da sua empresa)
-- EXEMPLO:
-- SELECT * FROM listar_usuarios_ativos('UUID_DA_SUA_EMPRESA');
