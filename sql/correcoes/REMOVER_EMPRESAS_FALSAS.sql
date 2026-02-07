-- 🧹 REMOVER registros falsos de funcionários na tabela empresas
-- Esses registros foram criados erroneamente pelo backfill
-- Funcionários reais estão na tabela "funcionarios", não em "empresas"

-- 1. Ver registros que serão removidos (apenas conferência)
SELECT 
  '🗑️ SERÁ REMOVIDO' as acao,
  e.id,
  e.nome,
  e.email
FROM empresas e
WHERE e.email IN (
  'rugovito021@gmail.com',          -- Victor (funcionário)
  'sousajenifer895@gmail.com',      -- Jennifer (funcionário)
  'jennifer@teste.com'              -- Jennifer Silva (teste)
);

-- 2. Remover registros falsos
DELETE FROM empresas
WHERE email IN (
  'rugovito021@gmail.com',
  'sousajenifer895@gmail.com',
  'jennifer@teste.com'
);

-- 3. Verificar resultado final
SELECT 
  '✅ EMPRESAS RESTANTES' as info,
  e.nome,
  e.email,
  e.cnpj,
  e.telefone,
  e.cidade,
  e.estado
FROM empresas e
ORDER BY e.created_at;
