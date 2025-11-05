-- 🛡️ TEMPLATE SUPER SIMPLES - SEM DEPENDÊNCIAS EXTRAS
-- Use este se quiser algo mais direto e sem complicações

-- ====================================
-- INFORMAÇÕES DO SCRIPT
-- ====================================
-- NOME: [NOME_DO_SEU_SCRIPT]
-- OBJETIVO: [O que este script faz]
-- DATA: [Data de criação]

-- ====================================
-- 1. VERIFICAÇÃO RÁPIDA DE SEGURANÇA
-- ====================================
DO $$
BEGIN
  -- Verificar funções críticas
  IF NOT EXISTS (SELECT FROM pg_proc WHERE proname = 'listar_usuarios_ativos') THEN
    RAISE EXCEPTION '🚨 PARE! Sistema de login quebrado. Execute CORRECAO_RAPIDA_LOGIN.sql primeiro!';
  END IF;
  
  RAISE NOTICE '✅ Sistema verificado - PODE CONTINUAR';
END $$;

-- ====================================
-- 2. SUAS ALTERAÇÕES AQUI
-- ====================================
-- ⚠️ LEMBRE-SE:
-- - Use IF EXISTS em comandos DROP
-- - Use WHERE em UPDATE/DELETE
-- - Teste um comando por vez

-- [COLE SEUS COMANDOS SQL AQUI]

-- ====================================
-- 3. VERIFICAÇÃO FINAL
-- ====================================
SELECT 
  '🎯 RESULTADO' as teste,
  CASE 
    WHEN EXISTS (SELECT FROM pg_proc WHERE proname = 'listar_usuarios_ativos')
    THEN '✅ SISTEMA OK'
    ELSE '❌ SISTEMA QUEBRADO'
  END as status;

-- ====================================
-- 4. MENSAGEM FINAL
-- ====================================
SELECT 
  '📝 CONCLUSÃO' as info,
  'Script executado. Teste o login no sistema: https://pdv-allimport-c9c32his2-radiosystem.vercel.app' as mensagem;