-- ============================================
-- 🎯 APLICAR TEMPLATES AOS FUNCIONÁRIOS EXISTENTES
-- ============================================
-- Este script permite aplicar templates de permissões
-- aos funcionários existentes no sistema.
-- ============================================

-- ============================================
-- 1️⃣ LISTAR TODOS OS FUNCIONÁRIOS ATUAIS
-- ============================================
SELECT 
  id,
  nome,
  cargo,
  ativo,
  '❓ Escolha um template para este funcionário' as acao
FROM funcionarios
ORDER BY nome;

-- ============================================
-- 2️⃣ APLICAR TEMPLATES ESPECÍFICOS
-- ============================================
-- Execute os comandos abaixo conforme necessário:

-- 🔴 Aplicar template ADMIN (Acesso Total)
-- Exemplo: Administrador Principal
SELECT aplicar_template_permissoes(
  '09dc2c9d-8cae-4e25-a889-6e98b03d1bf5',  -- UUID do Administrador Principal
  'admin'
);

-- 🔴 Aplicar template ADMIN para assistenciaallimport10
SELECT aplicar_template_permissoes(
  'ccdad2bc-3cc1-48a5-b447-be962b2956eb',  -- UUID do assistenciaallimport10
  'admin'
);

-- 🔴 Aplicar template ADMIN para cris-ramos30
SELECT aplicar_template_permissoes(
  '229271ef-567c-44c7-a996-dd738d3dd476',  -- UUID do cris-ramos30
  'admin'
);

-- 🔴 Aplicar template ADMIN para Cristiano Ramos Mendes
SELECT aplicar_template_permissoes(
  '23f89969-3c78-4b1e-8131-d98c4b81facb',  -- UUID do Cristiano Ramos Mendes
  'admin'
);

-- 🔴 Aplicar template ADMIN para novaradiosystem
SELECT aplicar_template_permissoes(
  '0e72a56a-d826-4731-bc82-59d9a28acba5',  -- UUID do novaradiosystem
  'admin'
);

-- 🟢 Aplicar template TÉCNICO para Jennifer
SELECT aplicar_template_permissoes(
  '9d9fe570-7c09-4ee4-8c52-11b7969c00f3',  -- UUID da Jennifer
  'tecnico'
);

-- ============================================
-- 3️⃣ VERIFICAR RESULTADOS
-- ============================================
SELECT 
  nome,
  cargo,
  ativo,
  CASE 
    WHEN permissoes->>'configuracoes' = 'true' THEN '🔴 ADMIN'
    WHEN permissoes->>'ordens_servico' = 'true' AND permissoes->>'vendas' = 'false' THEN '🟢 TÉCNICO'
    WHEN permissoes->>'caixa' = 'true' AND permissoes->>'ordens_servico' = 'false' THEN '🟡 CAIXA'
    WHEN permissoes->>'vendas' = 'true' AND permissoes->>'ordens_servico' = 'false' THEN '🔵 VENDEDOR'
    WHEN permissoes->>'relatorios' = 'true' THEN '🟣 GERENTE'
    ELSE '⚪ PADRÃO'
  END as template_aplicado,
  permissoes->>'ordens_servico' as "OS",
  permissoes->>'configuracoes' as "Config",
  permissoes->>'pode_deletar_clientes' as "Del Clientes",
  permissoes->>'pode_deletar_produtos' as "Del Produtos"
FROM funcionarios
ORDER BY nome;

-- ============================================
-- 4️⃣ VERIFICAR PERMISSÕES COMPLETAS DE UM FUNCIONÁRIO
-- ============================================
-- Descomente e ajuste o UUID para ver as permissões de um funcionário específico:

/*
SELECT 
  nome,
  cargo,
  jsonb_pretty(permissoes::jsonb) as permissoes_completas
FROM funcionarios 
WHERE id = 'UUID_AQUI';
*/

-- Exemplo para Jennifer:
SELECT 
  nome,
  cargo,
  jsonb_pretty(permissoes::jsonb) as permissoes_completas
FROM funcionarios 
WHERE id = '9d9fe570-7c09-4ee4-8c52-11b7969c00f3';

-- ============================================
-- 5️⃣ APLICAR EM LOTE (OPCIONAL)
-- ============================================
-- Se você quiser aplicar o mesmo template para múltiplos funcionários:

/*
-- Exemplo: Aplicar template VENDEDOR para todos com cargo 'Vendedor'
DO $$
DECLARE
  funcionario RECORD;
BEGIN
  FOR funcionario IN 
    SELECT id FROM funcionarios WHERE LOWER(cargo) LIKE '%vendedor%'
  LOOP
    PERFORM aplicar_template_permissoes(funcionario.id, 'vendedor');
  END LOOP;
END $$;
*/

-- ============================================
-- 6️⃣ TEMPLATES DISPONÍVEIS
-- ============================================
-- Para referência rápida:

-- 🔴 'admin'    - Acesso Total (Proprietário, Gerente Geral)
-- 🟣 'gerente'  - Gerencia loja (Gerente, Supervisor)  
-- 🔵 'vendedor' - Vendas e clientes (Vendedor, Atendente)
-- 🟢 'tecnico'  - Ordens de serviço (Técnico, Assistência)
-- 🟡 'caixa'    - Vendas e caixa (Operador de Caixa)

-- ============================================
-- ✅ RESUMO DOS COMANDOS
-- ============================================
-- 1. Execute a seção 1️⃣ para listar todos os funcionários
-- 2. Escolha o template adequado para cada um
-- 3. Execute os comandos da seção 2️⃣ com os UUIDs corretos
-- 4. Verifique os resultados na seção 3️⃣
-- ============================================
