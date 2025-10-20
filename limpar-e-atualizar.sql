-- =============================================
-- LIMPEZA E ATUALIZAÇÃO DE DADOS
-- Gerado automaticamente em 19/10/2025, 23:37:00
-- =============================================

-- PASSO 1: LIMPAR REGISTROS DUPLICADOS E ÓRFÃOS
-- =============================================

-- Desabilitar triggers temporariamente
SET session_replication_role = replica;

-- 1.1: Deletar clientes com empresa_id NULL (dados órfãos)
DELETE FROM clientes 
WHERE empresa_id IS NULL;

-- 1.2: Para cada CPF duplicado, manter apenas o mais recente
DELETE FROM clientes a
USING clientes b
WHERE a.cpf_digits = b.cpf_digits
  AND a.cpf_digits IS NOT NULL 
  AND a.cpf_digits != ''
  AND a.id < b.id  -- Mantém o registro com ID maior (mais recente)
  AND a.empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
  AND b.empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

-- 1.3: Deletar produtos órfãos
DELETE FROM produtos 
WHERE empresa_id IS NULL;

-- 1.4: Deletar ordens de serviço órfãs
DELETE FROM ordens_servico 
WHERE empresa_id IS NULL;

-- Reabilitar triggers
SET session_replication_role = DEFAULT;

-- =============================================
-- PASSO 2: VERIFICAR LIMPEZA
-- =============================================

SELECT 'Após limpeza' as momento,
       'clientes' as tabela, 
       COUNT(*) as total,
       COUNT(CASE WHEN empresa_id IS NULL THEN 1 END) as sem_empresa
FROM clientes
UNION ALL
SELECT 'Após limpeza', 'produtos', COUNT(*), COUNT(CASE WHEN empresa_id IS NULL THEN 1 END)
FROM produtos
UNION ALL
SELECT 'Após limpeza', 'ordens_servico', COUNT(*), COUNT(CASE WHEN empresa_id IS NULL THEN 1 END)
FROM ordens_servico;

-- =============================================
-- AGORA EXECUTE O ARQUIVO atualizar-dados-upsert.sql
-- =============================================
