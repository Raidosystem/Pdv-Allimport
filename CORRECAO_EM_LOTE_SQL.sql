-- 🔧 CORREÇÃO EM LOTE SIMPLES - Execute no Supabase Dashboard
-- https://supabase.com/dashboard > Seu Projeto > SQL Editor

-- 1. DIAGNÓSTICO: Ver quantos órfãos existem
SELECT 
  'CLIENTES ÓRFÃOS' as tipo,
  count(*) as quantidade
FROM clientes 
WHERE usuario_id != 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
   OR usuario_id IS NULL;

SELECT 
  'ORDENS ÓRFÃS' as tipo,
  count(*) as quantidade
FROM ordens_servico 
WHERE usuario_id != 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
   OR usuario_id IS NULL;

-- 2. Ver casos específicos
SELECT 
  'CRISTIANO RAMOS MENDES' as caso,
  nome,
  telefone,
  usuario_id
FROM clientes 
WHERE telefone = '17999783012';

SELECT 
  'ORDENS DO CRISTIANO' as caso,
  os.numero_os,
  os.marca,
  os.modelo,
  os.status,
  os.usuario_id
FROM ordens_servico os
JOIN clientes c ON os.cliente_id = c.id
WHERE c.telefone = '17999783012';

-- 3. CORREÇÃO EM LOTE: Corrigir TODOS os órfãos

-- Corrigir todos os clientes órfãos
UPDATE clientes 
SET usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
WHERE usuario_id != 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
   OR usuario_id IS NULL;

-- Corrigir todas as ordens órfãs
UPDATE ordens_servico 
SET usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
WHERE usuario_id != 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
   OR usuario_id IS NULL;

-- 4. VERIFICAÇÃO: Confirmar que funcionou
SELECT 
  'TOTAL CLIENTES' as tipo,
  count(*) as quantidade
FROM clientes 
WHERE usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid;

SELECT 
  'TOTAL ORDENS' as tipo,
  count(*) as quantidade
FROM ordens_servico 
WHERE usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid;

-- Verificar casos específicos
SELECT 
  'CRISTIANO CORRIGIDO' as caso,
  nome,
  telefone,
  usuario_id
FROM clientes 
WHERE telefone = '17999783012';

SELECT 
  'JULIANO CORRIGIDO' as caso,
  nome,
  telefone,
  usuario_id
FROM clientes 
WHERE telefone = '17999784438';

-- Ver algumas ordens recentes para confirmar
SELECT 
  numero_os,
  marca,
  modelo,
  status,
  created_at
FROM ordens_servico 
WHERE usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
ORDER BY created_at DESC
LIMIT 10;