-- ========================================
-- DADOS DE TESTE - EMPRESA E USUÁRIO ADMIN
-- Para testar o sistema multi-tenant
-- ========================================

-- Inserir empresa de teste (se não existir)
INSERT INTO empresas (
  id,
  nome,
  cnpj,
  email,
  plano,
  status,
  max_usuarios,
  max_lojas,
  features,
  tema,
  configuracoes,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Empresa Teste Allimport',
  '12.345.678/0001-90',
  'admin@teste.com',
  'professional',
  'ativo',
  50,
  5,
  '{"pdv": true, "estoque": true, "relatorios": true}',
  '{"primaryColor": "#3B82F6", "mode": "light"}',
  '{
    "obrigar_cliente": false,
    "limite_desconto_geral": 10,
    "permite_venda_sem_estoque": true,
    "regime_tributario": "simples_nacional",
    "backup_automatico": true,
    "backup_frequencia": "diario",
    "backup_retencao_dias": 30
  }',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Verificar se existe usuário admin de teste
-- Se usar Supabase Auth, este usuário deve ser criado lá primeiro
-- Este é apenas um exemplo de como seria o funcionário

-- Exemplo de funcionário admin (ajustar user_id conforme necessário)
/*
INSERT INTO funcionarios (
  id,
  user_id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  status,
  lojas,
  limite_desconto_pct,
  limite_cancelamentos_dia,
  permite_estorno,
  created_at,
  updated_at
) VALUES (
  '11111111-1111-1111-1111-111111111111',
  'SEU_USER_ID_AQUI', -- Substituir pelo ID do usuário do Supabase Auth
  '00000000-0000-0000-0000-000000000001',
  'Admin Teste',
  'admin@teste.com',
  'admin_empresa',
  'ativo',
  '[]',
  20,
  5,
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;
*/

-- Função para debug - verificar dados de um usuário
CREATE OR REPLACE FUNCTION debug_user_permissions(user_email TEXT)
RETURNS TABLE (
  funcionario_id UUID,
  funcionario_nome TEXT,
  tipo_admin TEXT,
  empresa_nome TEXT,
  status TEXT,
  total_funcoes BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.id as funcionario_id,
    f.nome as funcionario_nome,
    f.tipo_admin,
    e.nome as empresa_nome,
    f.status,
    COUNT(ff.funcao_id) as total_funcoes
  FROM funcionarios f
  JOIN empresas e ON e.id = f.empresa_id
  LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
  WHERE f.email = user_email
  GROUP BY f.id, f.nome, f.tipo_admin, e.nome, f.status;
END;
$$ LANGUAGE plpgsql;

-- Função para criar usuário admin de emergência
CREATE OR REPLACE FUNCTION create_emergency_admin(
  p_user_id UUID,
  p_email TEXT,
  p_nome TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  empresa_id UUID;
  funcionario_id UUID;
BEGIN
  -- Buscar ou criar empresa padrão
  SELECT id INTO empresa_id FROM empresas WHERE email = p_email;
  
  IF empresa_id IS NULL THEN
    INSERT INTO empresas (
      nome, email, plano, status, max_usuarios, max_lojas,
      features, tema, configuracoes
    ) VALUES (
      COALESCE(p_nome, 'Minha Empresa'),
      p_email,
      'professional',
      'ativo',
      50,
      5,
      '{"pdv": true}',
      '{"primaryColor": "#3B82F6", "mode": "light"}',
      '{"backup_automatico": true}'
    ) RETURNING id INTO empresa_id;
  END IF;
  
  -- Criar funcionário admin
  INSERT INTO funcionarios (
    user_id, empresa_id, nome, email, tipo_admin, status, lojas
  ) VALUES (
    p_user_id,
    empresa_id,
    COALESCE(p_nome, split_part(p_email, '@', 1)),
    p_email,
    'admin_empresa',
    'ativo',
    '[]'
  ) RETURNING id INTO funcionario_id;
  
  RETURN funcionario_id;
END;
$$ LANGUAGE plpgsql;

-- Comentários
COMMENT ON FUNCTION debug_user_permissions(TEXT) IS 'Debug: mostra informações de permissões de um usuário';
COMMENT ON FUNCTION create_emergency_admin(UUID, TEXT, TEXT) IS 'Cria um admin de emergência para testes';