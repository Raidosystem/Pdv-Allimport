-- 🔍 VERIFICAR função listar_usuarios_ativos

-- ✅ Passo 1: Verificar se a função existe
SELECT 
  '1️⃣ FUNÇÃO EXISTE?' as verificacao,
  proname as nome_funcao,
  pg_get_functiondef(oid) as definicao
FROM pg_proc
WHERE proname = 'listar_usuarios_ativos';

-- ✅ Passo 2: Testar a função manualmente
SELECT 
  '2️⃣ TESTE MANUAL' as verificacao,
  *
FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00');

-- ✅ Passo 3: Ver o que a função retorna (estrutura)
SELECT 
  '3️⃣ ESTRUTURA DO RESULTADO' as verificacao,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'listar_usuarios_ativos';

-- ✅ Passo 4: Verificar funcionários com tipo_admin
SELECT 
  '4️⃣ FUNCIONÁRIOS COM TIPO_ADMIN' as verificacao,
  f.id,
  f.nome,
  f.email,
  f.tipo_admin,
  f.status,
  f.empresa_id,
  lf.usuario,
  lf.ativo
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY f.created_at DESC;
