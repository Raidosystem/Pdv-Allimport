-- 🧹 Limpeza dos dados de teste (OPCIONAL)
-- Execute se quiser remover as ordens de teste antigas

-- Ver todas as ordens de teste
SELECT numero_os, status, created_at 
FROM ordens_servico 
WHERE numero_os LIKE 'TEST-%' 
ORDER BY created_at DESC;

-- Deletar apenas as ordens de teste (mantenha as reais)
-- DELETE FROM ordens_servico WHERE numero_os LIKE 'TEST-%';

-- OU atualizar o status das antigas para um válido
UPDATE ordens_servico 
SET status = 'Em análise' 
WHERE status = 'Aberta';

-- Verificar se não há mais status inválidos
SELECT DISTINCT status FROM ordens_servico;