-- 🔍 DIAGNÓSTICO ESPECÍFICO: TÉCNICO E VENDAS NÃO APARECEM

-- ====================================
-- 1. VERIFICAR ESTRUTURA DA TABELA FUNCIONÁRIOS
-- ====================================
SELECT 
  '📋 COLUNAS DA TABELA funcionarios' as info,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcionarios'
ORDER BY ordinal_position;

-- ====================================
-- 2. VER TODOS OS FUNCIONÁRIOS (SEM FILTRO)
-- ====================================
SELECT 
  '👥 TODOS FUNCIONÁRIOS CADASTRADOS' as info,
  id,
  nome,
  email,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  status,
  empresa_id,
  created_at
FROM funcionarios
ORDER BY created_at DESC;

-- ====================================
-- 3. VERIFICAR FUNCIONÁRIOS POR TIPO_ADMIN
-- ====================================
SELECT 
  '📊 FUNCIONÁRIOS POR TIPO' as info,
  tipo_admin,
  COUNT(*) as quantidade,
  COUNT(CASE WHEN usuario_ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN senha_definida = true THEN 1 END) as com_senha,
  COUNT(CASE WHEN status = 'ativo' THEN 1 END) as status_ativo
FROM funcionarios
GROUP BY tipo_admin
ORDER BY tipo_admin;

-- ====================================
-- 4. VERIFICAR SE RPC listar_usuarios_ativos EXISTE
-- ====================================
SELECT 
  '🔍 VERIFICAR RPC listar_usuarios_ativos' as info,
  routine_name,
  routine_type,
  data_type
FROM information_schema.routines
WHERE routine_name = 'listar_usuarios_ativos';

-- ====================================
-- 5. TESTAR RPC PARA CADA EMPRESA
-- ====================================
-- Primeiro vamos ver que empresas existem
SELECT 
  '🏢 EMPRESAS CADASTRADAS' as info,
  id,
  nome,
  email
FROM empresas
ORDER BY created_at DESC;

-- ====================================
-- 6. SIMULAR CHAMADA DA RPC (SE EXISTIR)
-- ====================================
-- Esta parte precisará ser ajustada com o ID da empresa real

-- Exemplo para empresa f1726fcf-d23b-4cca-8079-39314ae56e00
-- (ajustar conforme necessário)
SELECT 
  '🧪 TESTE RPC - EMPRESA 1' as teste,
  'Tentando chamar listar_usuarios_ativos...' as status;

-- ====================================
-- 7. VERIFICAR CONDIÇÕES DE FILTRO MANUALMENTE
-- ====================================
SELECT 
  '🔍 ANÁLISE DETALHADA DE FILTROS' as info,
  id,
  nome,
  tipo_admin,
  empresa_id,
  CASE 
    WHEN usuario_ativo = true THEN '✅ ativo'
    WHEN usuario_ativo = false THEN '❌ inativo'
    WHEN usuario_ativo IS NULL THEN '❓ NULL (considerado ativo)'
  END as usuario_ativo_status,
  CASE 
    WHEN senha_definida = true THEN '✅ tem senha'
    WHEN senha_definida = false THEN '❌ sem senha'
    WHEN senha_definida IS NULL THEN '❓ NULL'
  END as senha_status,
  CASE 
    WHEN status = 'ativo' THEN '✅ ativo'
    WHEN status = 'inativo' THEN '❌ inativo'
    WHEN status IS NULL THEN '❓ NULL'
    ELSE status
  END as status_geral,
  CASE 
    WHEN (usuario_ativo = true OR usuario_ativo IS NULL) 
         AND (status = 'ativo' OR status IS NULL)
         AND senha_definida = true 
    THEN '✅ APARECERIA NA RPC'
    ELSE '❌ NÃO APARECERIA'
  END as resultado_filtro
FROM funcionarios
ORDER BY tipo_admin, nome;

-- ====================================
-- 8. CONTAR PROBLEMAS ESPECÍFICOS
-- ====================================
SELECT 
  '📈 RESUMO DE PROBLEMAS' as info,
  COUNT(*) as total_funcionarios,
  COUNT(CASE WHEN usuario_ativo = false THEN 1 END) as inativos_usuario,
  COUNT(CASE WHEN senha_definida = false THEN 1 END) as sem_senha,
  COUNT(CASE WHEN status = 'inativo' THEN 1 END) as status_inativo,
  COUNT(CASE WHEN senha_definida IS NULL THEN 1 END) as senha_null,
  COUNT(CASE WHEN usuario_ativo IS NULL THEN 1 END) as usuario_ativo_null,
  COUNT(CASE WHEN status IS NULL THEN 1 END) as status_null
FROM funcionarios;

-- ====================================
-- 9. VERIFICAR FUNCIONÁRIOS PROBLEMÁTICOS
-- ====================================
SELECT 
  '⚠️ FUNCIONÁRIOS COM PROBLEMAS' as info,
  nome,
  tipo_admin,
  CASE 
    WHEN usuario_ativo = false THEN 'usuario_ativo=false'
    WHEN senha_definida = false THEN 'senha_definida=false'
    WHEN senha_definida IS NULL THEN 'senha_definida=NULL'
    WHEN status = 'inativo' THEN 'status=inativo'
    ELSE 'outro problema'
  END as problema
FROM funcionarios
WHERE NOT (
  (usuario_ativo = true OR usuario_ativo IS NULL) 
  AND (status = 'ativo' OR status IS NULL)
  AND senha_definida = true
);

-- ====================================
-- 10. SOLUÇÃO PROPOSTA
-- ====================================
SELECT 
  '💡 COMANDOS PARA CORRIGIR' as info,
  'UPDATE funcionarios SET usuario_ativo = true, senha_definida = true, status = ''ativo'' WHERE usuario_ativo = false OR senha_definida = false OR status = ''inativo'';' as comando_sql;