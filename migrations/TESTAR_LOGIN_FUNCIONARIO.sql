-- =====================================================
-- TESTE: Validar Login de Funcionário
-- =====================================================
-- Este script testa a função validar_senha_local()
-- Execute no Supabase SQL Editor
-- =====================================================

-- PASSO 1: Verificar funcionários existentes
-- =====================================================
SELECT 
  f.id,
  f.nome,
  f.email,
  f.cargo,
  f.ativo,
  l.usuario,
  l.ativo as login_ativo
FROM funcionarios f
LEFT JOIN login_funcionarios l ON l.funcionario_id = f.id
WHERE f.ativo = true
ORDER BY f.created_at DESC
LIMIT 5;

-- =====================================================
-- PASSO 2: Testar login com usuário correto
-- =====================================================
-- Substitua 'cristiano_ramos_mendes' pelo usuário real
-- Substitua 'SenhaSegura123' pela senha usada ao criar
SELECT validar_senha_local(
  'cristiano_ramos_mendes', 
  'SenhaSegura123'
) as resultado_login_correto;

-- =====================================================
-- PASSO 3: Testar login com senha errada (deve falhar)
-- =====================================================
SELECT validar_senha_local(
  'cristiano_ramos_mendes', 
  'SenhaErrada123'
) as resultado_senha_errada;

-- =====================================================
-- PASSO 4: Testar login com usuário inexistente (deve falhar)
-- =====================================================
SELECT validar_senha_local(
  'usuario_nao_existe', 
  'qualquer_senha'
) as resultado_usuario_inexistente;

-- =====================================================
-- PASSO 5: Verificar estrutura da resposta
-- =====================================================
-- A resposta deve ter formato JSON:
-- {
--   "success": true,
--   "funcionario": {
--     "id": "uuid",
--     "empresa_id": "uuid",
--     "nome": "Nome do Funcionário",
--     "email": "email@example.com",
--     "funcao_nome": "Nome da Função",
--     "permissoes": {...}
--   },
--   "login_id": "uuid"
-- }
