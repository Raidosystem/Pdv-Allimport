-- ============================================
-- LIMPAR E INSERIR ORDENS DO BACKUP JSON
-- ============================================

-- PASSO 1: Fazer backup de segurança das ordens atuais
CREATE TABLE IF NOT EXISTS ordens_backup_antes_limpar AS 
SELECT * FROM ordens_servico;

-- PASSO 2: Limpar todas as ordens
TRUNCATE TABLE ordens_servico;

-- PASSO 3: Verificar que limpou
SELECT COUNT(*) as ordens_apos_limpar FROM ordens_servico;
-- Deve retornar: 0

-- ============================================
-- AGORA EXECUTE O ARQUIVO: INSERIR_ORDENS_BACKUP_JSON.sql
-- (Copie e cole TODO o conteúdo do arquivo aqui, do INSERT até o final)
-- OU execute ele separadamente
-- ============================================

-- PASSO 4: Após inserir, verificar resultado
SELECT COUNT(*) as total_ordens_inseridas FROM ordens_servico;
-- Deve retornar: 160

-- PASSO 5: Verificar órfãos
SELECT COUNT(*) as orfaos
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL;
-- Deve retornar: 0 (nenhum órfão!)

-- PASSO 6: Ver clientes com mais ordens
SELECT
  c.nome,
  c.cpf_cnpj,
  COUNT(os.id) as total_ordens
FROM clientes c
INNER JOIN ordens_servico os ON os.cliente_id = c.id
GROUP BY c.id, c.nome, c.cpf_cnpj
ORDER BY total_ordens DESC
LIMIT 10;

-- PASSO 7: TESTAR EDVANIA - DEVE MOSTRAR 2 EQUIPAMENTOS!
SELECT
  os.numero_os,
  os.marca,
  os.modelo,
  os.tipo,
  os.descricao_problema,
  os.data_entrada,
  os.status,
  c.nome as cliente_nome
FROM ordens_servico os
INNER JOIN clientes c ON os.cliente_id = c.id
WHERE c.cpf_cnpj = '37511773885'
ORDER BY os.data_entrada DESC;
