-- ========================================
-- CORRIGIR JENNIFER PARA SER FUNCIONÁRIO VENDEDOR
-- ========================================
-- A Jennifer está com tipo_admin='admin_empresa', quando deveria ser 'funcionario'
-- Isso está dando a ela acesso completo ao sistema

-- 1️⃣ VERIFICAR STATUS ATUAL DA JENNIFER
SELECT 
  '🔍 STATUS ATUAL DA JENNIFER' as etapa,
  f.id as funcionario_id,
  f.nome,
  f.email,
  f.tipo_admin,
  f.funcao_id,
  func.nome as funcao_nome,
  f.status,
  f.empresa_id,
  lf.usuario as login_usuario,
  (SELECT COUNT(*) FROM funcao_permissoes WHERE funcao_id = f.funcao_id) as total_permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.email = 'jennifer_sousa@temp.local'
   OR LOWER(f.nome) LIKE '%jennifer%sousa%';

-- 2️⃣ BUSCAR A FUNÇÃO "Vendedor" CORRETA
SELECT 
  '🎯 FUNÇÃO VENDEDOR DISPONÍVEL' as etapa,
  id,
  nome,
  descricao,
  empresa_id,
  (SELECT COUNT(*) FROM funcao_permissoes WHERE funcao_id = funcoes.id) as total_permissoes
FROM funcoes
WHERE LOWER(nome) LIKE '%vendedor%'
  AND empresa_id = (
    SELECT empresa_id FROM funcionarios 
    WHERE email = 'jennifer_sousa@temp.local' 
       OR LOWER(nome) LIKE '%jennifer%sousa%'
    LIMIT 1
  );

-- 3️⃣ CORRIGIR TIPO_ADMIN DA JENNIFER
UPDATE funcionarios
SET 
  tipo_admin = 'funcionario', -- ✅ NÃO É ADMIN
  funcao_id = (
    -- Buscar a função Vendedor da mesma empresa
    SELECT id FROM funcoes 
    WHERE LOWER(nome) LIKE '%vendedor%'
      AND empresa_id = funcionarios.empresa_id
    LIMIT 1
  ),
  updated_at = now()
WHERE email = 'jennifer_sousa@temp.local'
   OR LOWER(nome) LIKE '%jennifer%sousa%';

-- 4️⃣ VERIFICAR CORREÇÃO
SELECT 
  '✅ JENNIFER CORRIGIDA' as etapa,
  f.id as funcionario_id,
  f.nome,
  f.email,
  f.tipo_admin as tipo_admin_correto,
  f.funcao_id,
  func.nome as funcao_atribuida,
  f.status,
  CASE 
    WHEN f.tipo_admin = 'funcionario' THEN '✅ Tipo correto'
    ELSE '❌ Ainda está como ' || f.tipo_admin
  END as validacao_tipo,
  CASE 
    WHEN func.nome ILIKE '%vendedor%' THEN '✅ Função correta'
    ELSE '❌ Função incorreta: ' || COALESCE(func.nome, 'SEM FUNÇÃO')
  END as validacao_funcao
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE f.email = 'jennifer_sousa@temp.local'
   OR LOWER(f.nome) LIKE '%jennifer%sousa%';

-- 5️⃣ LISTAR PERMISSÕES DA JENNIFER APÓS CORREÇÃO
SELECT 
  '📋 PERMISSÕES FINAIS DA JENNIFER' as etapa,
  f.nome as funcionario,
  func.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao,
  (p.recurso || ':' || p.acao) as permissao_completa
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE (f.email = 'jennifer_sousa@temp.local'
   OR LOWER(f.nome) LIKE '%jennifer%sousa%')
  AND p.id IS NOT NULL
ORDER BY p.recurso, p.acao;

-- 6️⃣ RESULTADO ESPERADO
SELECT 
  '✅ RESULTADO ESPERADO' as info,
  'Jennifer deve ter:' as descricao,
  '- tipo_admin = funcionario (NÃO admin_empresa)' as item1,
  '- Função = Vendedor' as item2,
  '- Permissões limitadas de vendas apenas' as item3,
  '- SEM acesso a Administração' as item4;

-- ========================================
-- INSTRUÇÕES DE USO
-- ========================================
/*
1. Execute este script completo no SQL Editor do Supabase
2. Verifique na seção "✅ JENNIFER CORRIGIDA" se:
   - tipo_admin = 'funcionario'
   - funcao = 'Vendedor'
3. Faça logout da Jennifer no sistema
4. Faça login novamente
5. Verifique se ela NÃO tem mais acesso a:
   - Menu Administração
   - Configurações avançadas
   - Backup
   - Logs

IMPORTANTE:
- Apenas o Cristiano (assistenciaallimport10@gmail.com) deve ser admin_empresa
- Jennifer é funcionária vendedora, NÃO administradora
- Se Jennifer precisar de mais permissões, adicione via função, NÃO via tipo_admin
*/
