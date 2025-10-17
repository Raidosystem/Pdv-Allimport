-- ========================================
-- QUERIES ÚTEIS PARA TESTAR O SISTEMA
-- ========================================
-- Use estas queries para verificar, testar e diagnosticar o sistema

-- ==========================================
-- 1. VERIFICAR SE O SISTEMA FOI INSTALADO
-- ==========================================

-- Verificar se as colunas foram adicionadas
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcionarios'
AND column_name IN ('senha_hash', 'senha_definida', 'foto_perfil', 'primeiro_acesso', 'usuario_ativo')
ORDER BY column_name;

-- Verificar se a tabela sessoes_locais foi criada
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_name = 'sessoes_locais'
) as tabela_existe;

-- Verificar se as funções foram criadas
SELECT 
  routine_name,
  routine_type,
  data_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN (
  'definir_senha_local',
  'validar_senha_local',
  'listar_usuarios_ativos',
  'validar_sessao'
)
ORDER BY routine_name;

-- Verificar se pgcrypto está instalado
SELECT EXISTS (
  SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto'
) as pgcrypto_instalado;

-- ==========================================
-- 2. VER TODOS OS FUNCIONÁRIOS E STATUS
-- ==========================================

SELECT 
  id,
  nome,
  email,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  status,
  created_at
FROM funcionarios
ORDER BY 
  CASE WHEN tipo_admin = 'admin_empresa' THEN 0 ELSE 1 END,
  nome;

-- ==========================================
-- 3. VER SOMENTE USUÁRIOS ATIVOS
-- ==========================================

SELECT 
  id,
  nome,
  email,
  tipo_admin,
  senha_definida
FROM funcionarios
WHERE usuario_ativo = TRUE
ORDER BY 
  CASE WHEN tipo_admin = 'admin_empresa' THEN 0 ELSE 1 END,
  nome;

-- ==========================================
-- 4. VER ADMIN DA EMPRESA
-- ==========================================

SELECT 
  f.id,
  f.nome,
  f.email,
  f.usuario_ativo,
  f.senha_definida,
  f.primeiro_acesso,
  e.nome as empresa
FROM funcionarios f
JOIN empresas e ON f.empresa_id = e.id
WHERE f.tipo_admin = 'admin_empresa'
ORDER BY e.nome, f.nome;

-- ==========================================
-- 5. ATIVAR ADMIN MANUALMENTE (SE NECESSÁRIO)
-- ==========================================

-- Se o admin não conseguir acessar, execute isto:
UPDATE funcionarios
SET 
  usuario_ativo = TRUE,
  senha_definida = FALSE,  -- Força a definir senha na próxima vez
  primeiro_acesso = TRUE
WHERE tipo_admin = 'admin_empresa'
AND id = (
  SELECT id FROM funcionarios 
  WHERE tipo_admin = 'admin_empresa' 
  LIMIT 1
);

-- ==========================================
-- 6. DEFINIR SENHA MANUALMENTE
-- ==========================================

-- Definir senha "admin123" para o admin
SELECT definir_senha_local(
  (SELECT id FROM funcionarios WHERE tipo_admin = 'admin_empresa' LIMIT 1),
  'admin123'
);

-- Definir senha "joao123" para um funcionário específico
SELECT definir_senha_local(
  (SELECT id FROM funcionarios WHERE email = 'joao@empresa.com'),
  'joao123'
);

-- ==========================================
-- 7. VER SESSÕES ATIVAS
-- ==========================================

SELECT 
  s.id,
  f.nome,
  f.email,
  s.criado_em,
  s.expira_em,
  s.ativo,
  CASE 
    WHEN s.expira_em > NOW() THEN '✅ Válida'
    ELSE '❌ Expirada'
  END as status,
  s.ip_address,
  s.user_agent
FROM sessoes_locais s
JOIN funcionarios f ON s.funcionario_id = f.id
WHERE s.ativo = TRUE
ORDER BY s.criado_em DESC;

-- ==========================================
-- 8. VER TODAS AS SESSÕES (ATIVAS E INATIVAS)
-- ==========================================

SELECT 
  s.id,
  f.nome,
  f.email,
  s.criado_em,
  s.expira_em,
  s.ativo,
  CASE 
    WHEN s.expira_em > NOW() AND s.ativo THEN '🟢 Válida'
    WHEN s.expira_em <= NOW() THEN '🔴 Expirada'
    WHEN NOT s.ativo THEN '⚪ Desativada'
  END as status
FROM sessoes_locais s
JOIN funcionarios f ON s.funcionario_id = f.id
ORDER BY s.criado_em DESC
LIMIT 20;

-- ==========================================
-- 9. VER PERMISSÕES DE UM FUNCIONÁRIO
-- ==========================================

-- Trocar 'joao@empresa.com' pelo email do funcionário
SELECT 
  f.nome as funcionario,
  f.email,
  func.nome as funcao,
  fp.permissao,
  fp.permissao_id
FROM funcionarios f
JOIN funcionario_funcoes ff ON f.id = ff.funcionario_id
JOIN funcoes func ON ff.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON func.id = fp.funcao_id
WHERE f.email = 'joao@empresa.com'
ORDER BY fp.permissao;

-- ==========================================
-- 10. VER TODAS AS FUNÇÕES E SUAS PERMISSÕES
-- ==========================================

SELECT 
  func.nome as funcao,
  func.descricao,
  func.nivel,
  COUNT(fp.id) as total_permissoes,
  string_agg(fp.permissao, ', ') as permissoes
FROM funcoes func
LEFT JOIN funcao_permissoes fp ON func.id = fp.funcao_id
GROUP BY func.id, func.nome, func.descricao, func.nivel
ORDER BY func.nivel, func.nome;

-- ==========================================
-- 11. TESTAR VALIDAÇÃO DE SENHA
-- ==========================================

-- Tentar validar senha (trocar email e senha)
-- ATENÇÃO: Não expõe a senha, só retorna sucesso/falha
SELECT 
  sucesso,
  funcionario_id,
  nome,
  tipo_admin,
  token
FROM validar_senha_local(
  (SELECT id FROM funcionarios WHERE email = 'joao@empresa.com'),
  'joao123'
);

-- ==========================================
-- 12. LISTAR USUÁRIOS ATIVOS DE UMA EMPRESA
-- ==========================================

-- Trocar pelo ID da sua empresa
SELECT * FROM listar_usuarios_ativos(
  '00000000-0000-0000-0000-000000000000'::uuid  -- Coloque o UUID da empresa aqui
);

-- Ou pegar o ID automaticamente da primeira empresa:
SELECT * FROM listar_usuarios_ativos(
  (SELECT id FROM empresas LIMIT 1)
);

-- ==========================================
-- 13. VALIDAR UMA SESSÃO
-- ==========================================

-- Trocar 'TOKEN_AQUI' pelo token da sessão
SELECT 
  valido,
  funcionario_id,
  nome,
  tipo_admin,
  empresa_id
FROM validar_sessao('TOKEN_AQUI');

-- ==========================================
-- 14. LIMPAR SESSÕES EXPIRADAS
-- ==========================================

-- Ver quantas sessões expiradas existem
SELECT COUNT(*) as sessoes_expiradas
FROM sessoes_locais
WHERE expira_em < NOW();

-- Desativar sessões expiradas
UPDATE sessoes_locais
SET ativo = FALSE
WHERE expira_em < NOW()
AND ativo = TRUE;

-- Deletar sessões antigas (mais de 30 dias)
DELETE FROM sessoes_locais
WHERE criado_em < NOW() - INTERVAL '30 days';

-- ==========================================
-- 15. RESETAR UM FUNCIONÁRIO
-- ==========================================

-- Resetar senha e status de um funcionário específico
UPDATE funcionarios
SET 
  senha_hash = NULL,
  senha_definida = FALSE,
  primeiro_acesso = TRUE,
  usuario_ativo = FALSE
WHERE email = 'joao@empresa.com';

-- ==========================================
-- 16. RESETAR TODOS OS FUNCIONÁRIOS (CUIDADO!)
-- ==========================================

-- ⚠️ ATENÇÃO: Isso resetará TODOS os funcionários exceto o admin
-- Use apenas em desenvolvimento/testes

UPDATE funcionarios
SET 
  senha_hash = NULL,
  senha_definida = FALSE,
  primeiro_acesso = TRUE,
  usuario_ativo = FALSE
WHERE tipo_admin != 'admin_empresa';

-- ==========================================
-- 17. CRIAR FUNCIONÁRIO DE TESTE
-- ==========================================

-- 1. Criar funcionário
INSERT INTO funcionarios (
  empresa_id,
  nome,
  email,
  status,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  primeiro_acesso
)
VALUES (
  (SELECT id FROM empresas LIMIT 1),  -- Primeira empresa
  'João Teste',
  'joao.teste@empresa.com',
  'ativo',
  'funcionario',
  FALSE,  -- Será ativado ao definir senha
  FALSE,
  TRUE
)
RETURNING id, nome, email;

-- 2. Associar função (trocar IDs conforme necessário)
INSERT INTO funcionario_funcoes (funcionario_id, funcao_id)
VALUES (
  (SELECT id FROM funcionarios WHERE email = 'joao.teste@empresa.com'),
  (SELECT id FROM funcoes WHERE nome = 'Vendedor' LIMIT 1)
);

-- 3. Definir senha
SELECT definir_senha_local(
  (SELECT id FROM funcionarios WHERE email = 'joao.teste@empresa.com'),
  'teste123'
);

-- ==========================================
-- 18. DELETAR FUNCIONÁRIO DE TESTE
-- ==========================================

-- ⚠️ ATENÇÃO: Deleta permanentemente
DELETE FROM funcionarios
WHERE email = 'joao.teste@empresa.com';

-- ==========================================
-- 19. VERIFICAR RLS POLICIES
-- ==========================================

-- Ver todas as policies da tabela funcionarios
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'funcionarios'
ORDER BY policyname;

-- Ver todas as policies da tabela sessoes_locais
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'sessoes_locais'
ORDER BY policyname;

-- ==========================================
-- 20. ESTATÍSTICAS DO SISTEMA
-- ==========================================

-- Resumo geral
SELECT 
  (SELECT COUNT(*) FROM empresas) as total_empresas,
  (SELECT COUNT(*) FROM funcionarios) as total_funcionarios,
  (SELECT COUNT(*) FROM funcionarios WHERE usuario_ativo = TRUE) as funcionarios_ativos,
  (SELECT COUNT(*) FROM funcionarios WHERE senha_definida = TRUE) as senhas_definidas,
  (SELECT COUNT(*) FROM funcionarios WHERE tipo_admin = 'admin_empresa') as admins,
  (SELECT COUNT(*) FROM sessoes_locais WHERE ativo = TRUE AND expira_em > NOW()) as sessoes_ativas,
  (SELECT COUNT(*) FROM funcoes) as total_funcoes,
  (SELECT COUNT(*) FROM funcao_permissoes) as total_permissoes;

-- Funcionários por status
SELECT 
  CASE 
    WHEN usuario_ativo AND senha_definida THEN '🟢 Ativo e Pronto'
    WHEN usuario_ativo AND NOT senha_definida THEN '🟡 Ativo sem Senha'
    WHEN NOT usuario_ativo AND senha_definida THEN '🔴 Inativo com Senha'
    ELSE '⚪ Inativo sem Senha'
  END as status,
  COUNT(*) as quantidade
FROM funcionarios
GROUP BY usuario_ativo, senha_definida
ORDER BY 
  CASE 
    WHEN usuario_ativo AND senha_definida THEN 1
    WHEN usuario_ativo AND NOT senha_definida THEN 2
    WHEN NOT usuario_ativo AND senha_definida THEN 3
    ELSE 4
  END;

-- ==========================================
-- 21. DIAGNÓSTICO COMPLETO
-- ==========================================

-- Execute isto se algo não estiver funcionando
SELECT 
  '🔧 Sistema' as categoria,
  'pgcrypto instalado' as item,
  CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto')
    THEN '✅ Sim' ELSE '❌ Não' END as status
UNION ALL
SELECT 
  '🔧 Sistema',
  'Tabela sessoes_locais existe',
  CASE WHEN EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sessoes_locais')
    THEN '✅ Sim' ELSE '❌ Não' END
UNION ALL
SELECT 
  '🔧 Sistema',
  'Função definir_senha_local existe',
  CASE WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'definir_senha_local')
    THEN '✅ Sim' ELSE '❌ Não' END
UNION ALL
SELECT 
  '🔧 Sistema',
  'Função validar_senha_local existe',
  CASE WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'validar_senha_local')
    THEN '✅ Sim' ELSE '❌ Não' END
UNION ALL
SELECT 
  '👥 Dados',
  'Total de funcionários',
  (SELECT COUNT(*)::text FROM funcionarios)
UNION ALL
SELECT 
  '👥 Dados',
  'Funcionários ativos',
  (SELECT COUNT(*)::text FROM funcionarios WHERE usuario_ativo = TRUE)
UNION ALL
SELECT 
  '👥 Dados',
  'Admin existe',
  CASE WHEN EXISTS (SELECT 1 FROM funcionarios WHERE tipo_admin = 'admin_empresa')
    THEN '✅ Sim' ELSE '❌ Não' END
UNION ALL
SELECT 
  '👥 Dados',
  'Admin com senha definida',
  CASE WHEN EXISTS (SELECT 1 FROM funcionarios WHERE tipo_admin = 'admin_empresa' AND senha_definida = TRUE)
    THEN '✅ Sim' ELSE '❌ Não' END
UNION ALL
SELECT 
  '🔐 Segurança',
  'RLS ativo em funcionarios',
  CASE WHEN (SELECT relrowsecurity FROM pg_class WHERE relname = 'funcionarios')
    THEN '✅ Sim' ELSE '❌ Não' END
UNION ALL
SELECT 
  '🔐 Segurança',
  'RLS ativo em sessoes_locais',
  CASE WHEN (SELECT relrowsecurity FROM pg_class WHERE relname = 'sessoes_locais')
    THEN '✅ Sim' ELSE '❌ Não' END;

-- ==========================================
-- 22. CONSULTAS RÁPIDAS PARA DEBUG
-- ==========================================

-- Ver último funcionário criado
SELECT * FROM funcionarios 
ORDER BY created_at DESC 
LIMIT 1;

-- Ver última sessão criada
SELECT 
  s.*,
  f.nome,
  f.email
FROM sessoes_locais s
JOIN funcionarios f ON s.funcionario_id = f.id
ORDER BY s.criado_em DESC
LIMIT 1;

-- Ver funcionários sem senha
SELECT 
  id,
  nome,
  email,
  usuario_ativo,
  senha_definida
FROM funcionarios
WHERE senha_definida = FALSE
ORDER BY nome;

-- Ver funcionários inativos
SELECT 
  id,
  nome,
  email,
  senha_definida,
  tipo_admin
FROM funcionarios
WHERE usuario_ativo = FALSE
ORDER BY nome;

-- ==========================================
-- 23. MANUTENÇÃO AUTOMÁTICA
-- ==========================================

-- Criar função para limpar sessões expiradas automaticamente
CREATE OR REPLACE FUNCTION limpar_sessoes_expiradas()
RETURNS INTEGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  -- Desativar sessões expiradas
  UPDATE sessoes_locais
  SET ativo = FALSE
  WHERE expira_em < NOW()
  AND ativo = TRUE;
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  
  -- Deletar sessões muito antigas (mais de 30 dias)
  DELETE FROM sessoes_locais
  WHERE criado_em < NOW() - INTERVAL '30 days';
  
  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Executar limpeza
SELECT limpar_sessoes_expiradas() as sessoes_limpas;

-- ==========================================
-- 24. BACKUP E RESTORE (DADOS DE TESTE)
-- ==========================================

-- Exportar funcionários para JSON (copie o resultado)
SELECT json_agg(
  json_build_object(
    'nome', nome,
    'email', email,
    'tipo_admin', tipo_admin,
    'usuario_ativo', usuario_ativo,
    'senha_definida', senha_definida
  )
) as funcionarios_backup
FROM funcionarios;

-- Ver estrutura completa de um funcionário
SELECT json_build_object(
  'funcionario', row_to_json(f.*),
  'funcoes', (
    SELECT json_agg(func.nome)
    FROM funcionario_funcoes ff
    JOIN funcoes func ON ff.funcao_id = func.id
    WHERE ff.funcionario_id = f.id
  ),
  'permissoes', (
    SELECT json_agg(fp.permissao)
    FROM funcionario_funcoes ff
    JOIN funcoes func ON ff.funcao_id = func.id
    JOIN funcao_permissoes fp ON func.id = fp.funcao_id
    WHERE ff.funcionario_id = f.id
  )
) as funcionario_completo
FROM funcionarios f
WHERE f.email = 'joao@empresa.com';

-- ==========================================
-- FIM DAS QUERIES ÚTEIS
-- ==========================================

-- 💡 DICAS:
-- 
-- 1. Salve este arquivo para consultas futuras
-- 2. Use Ctrl+F para procurar o que precisa
-- 3. Adapte as queries conforme sua necessidade
-- 4. Sempre teste em desenvolvimento primeiro
-- 5. Faça backup antes de executar UPDATEs/DELETEs
--
-- 🎯 QUERIES MAIS USADAS:
-- - #2: Ver todos os funcionários
-- - #7: Ver sessões ativas  
-- - #9: Ver permissões de um funcionário
-- - #21: Diagnóstico completo
--
-- ❤️ Bom trabalho!
