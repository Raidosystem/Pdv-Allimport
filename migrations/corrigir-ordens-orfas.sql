-- 🔧 Correção: Atribuir usuario_id às ordens órfãs
-- Execute no SQL Editor do Supabase

-- 1. Primeiro, verificar seu user ID atual
SELECT auth.uid() as meu_user_id;

-- 2. Ver ordens sem usuario_id
SELECT 
  numero_os,
  status,
  tipo,
  marca,
  modelo,
  usuario_id,
  created_at
FROM ordens_servico 
WHERE usuario_id IS NULL;

-- 3. Atualizar as ordens órfãs para o usuário atual
-- IMPORTANTE: Só execute se você for o proprietário dessas ordens
UPDATE ordens_servico 
SET usuario_id = auth.uid()
WHERE usuario_id IS NULL;

-- 4. Verificar se funcionou
SELECT 
  numero_os,
  status,
  tipo,
  marca,
  modelo,
  usuario_id,
  created_at
FROM ordens_servico 
WHERE numero_os = 'OS-20250915-003';

-- 5. Contar ordens por usuário
SELECT 
  usuario_id,
  COUNT(*) as total_ordens
FROM ordens_servico 
GROUP BY usuario_id;

-- 6. Testar a consulta que o sistema faz
SELECT 
  numero_os,
  status,
  tipo,
  marca,
  modelo,
  created_at
FROM ordens_servico 
WHERE usuario_id = auth.uid()
ORDER BY created_at DESC;