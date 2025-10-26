-- ✅ Adicionar status "Orçamento" na tabela ordens_servico
-- Execute este SQL no Supabase SQL Editor

-- 1. Ver quais status existem atualmente
-- SELECT DISTINCT status FROM ordens_servico;
-- Resultado: aberta, Em análise, fechada, Pronto

-- 2. Atualizar registros com status antigos para os novos padrões
UPDATE ordens_servico SET status = 'Em análise' WHERE status = 'aberta';
UPDATE ordens_servico SET status = 'Entregue' WHERE status = 'fechada';
UPDATE ordens_servico SET status = 'Em análise' WHERE status IS NULL;

-- Atualizar qualquer outro status inválido
UPDATE ordens_servico SET status = 'Em análise' WHERE status NOT IN (
  'Em análise',
  'Orçamento',
  'Aguardando aprovação',
  'Aguardando peças',
  'Em conserto',
  'Pronto',
  'Entregue',
  'Cancelado'
);

-- 3. Remover a constraint antiga de status
ALTER TABLE ordens_servico 
DROP CONSTRAINT IF EXISTS ordens_servico_status_check;

-- 4. Adicionar nova constraint com o status "Orçamento"
ALTER TABLE ordens_servico 
ADD CONSTRAINT ordens_servico_status_check 
CHECK (status IN (
  'Em análise',
  'Orçamento',
  'Aguardando aprovação',
  'Aguardando peças',
  'Em conserto',
  'Pronto',
  'Entregue',
  'Cancelado'
));

-- ✅ Pronto! Agora o status "Orçamento" está disponível
-- ✅ Status antigos convertidos: "aberta" → "Em análise", "fechada" → "Entregue"
