-- =============================================
-- SISTEMA AUTOMÁTICO DE ATUALIZAÇÃO DE PERMISSÕES
-- =============================================
-- Quando o admin editar permissões de uma função,
-- TODOS os funcionários com essa função serão atualizados automaticamente

-- 1️⃣ CRIAR TRIGGER PARA ATUALIZAR PERMISSÕES AUTOMATICAMENTE
CREATE OR REPLACE FUNCTION atualizar_permissoes_funcionarios_funcao()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  -- Disparar notificação para o frontend recarregar permissões
  PERFORM pg_notify(
    'pdv_permissions_reload',
    json_build_object(
      'funcao_id', COALESCE(NEW.funcao_id, OLD.funcao_id),
      'empresa_id', COALESCE(NEW.empresa_id, OLD.empresa_id),
      'timestamp', NOW()
    )::text
  );
  
  -- Contar quantos funcionários serão afetados
  SELECT COUNT(*) INTO v_count
  FROM funcionarios
  WHERE funcao_id = COALESCE(NEW.funcao_id, OLD.funcao_id);
  
  RAISE NOTICE '🔔 % funcionários serão notificados para recarregar permissões', v_count;
  
  RETURN COALESCE(NEW, OLD);
END;
$$;

-- 2️⃣ CRIAR TRIGGER NA TABELA funcao_permissoes
DROP TRIGGER IF EXISTS trigger_atualizar_permissoes_funcionarios ON funcao_permissoes;

CREATE TRIGGER trigger_atualizar_permissoes_funcionarios
  AFTER INSERT OR UPDATE OR DELETE ON funcao_permissoes
  FOR EACH ROW
  EXECUTE FUNCTION atualizar_permissoes_funcionarios_funcao();

SELECT '✅ Trigger criado!' as passo_1;

-- 3️⃣ ATRIBUIR PERMISSÕES PADRÃO PARA FUNÇÕES EXISTENTES (se ainda não tiverem)

-- TÉCNICO (Ordens de Serviço + Clientes + Produtos)
INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
SELECT 
  f.id,
  p.id,
  f.empresa_id
FROM funcoes f
CROSS JOIN permissoes p
WHERE f.nome = 'Técnico'
AND p.modulo || ':' || p.acao IN (
  'ordens:read', 'ordens:create', 'ordens:update', 'ordens:change_status', 'ordens:print',
  'clientes:read', 'clientes:create', 'clientes:view_history',
  'produtos:read',
  'dashboard:view', 'dashboard.metricas:view',
  'configuracoes:read', 'configuracoes.impressao:read'
)
AND NOT EXISTS (
  SELECT 1 FROM funcao_permissoes fp
  WHERE fp.funcao_id = f.id AND fp.permissao_id = p.id
)
ON CONFLICT DO NOTHING;

-- VENDEDOR (Vendas + Clientes + Produtos)
INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
SELECT 
  f.id,
  p.id,
  f.empresa_id
FROM funcoes f
CROSS JOIN permissoes p
WHERE f.nome = 'Vendedor'
AND p.modulo || ':' || p.acao IN (
  'vendas:read', 'vendas:create', 'vendas:print',
  'clientes:read', 'clientes:create', 'clientes:update', 'clientes:view_history',
  'produtos:read',
  'dashboard:view', 'dashboard.metricas:view',
  'configuracoes:read', 'configuracoes.impressao:read'
)
AND NOT EXISTS (
  SELECT 1 FROM funcao_permissoes fp
  WHERE fp.funcao_id = f.id AND fp.permissao_id = p.id
)
ON CONFLICT DO NOTHING;

-- OPERADOR DE CAIXA (Caixa + Vendas + Clientes)
INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
SELECT 
  f.id,
  p.id,
  f.empresa_id
FROM funcoes f
CROSS JOIN permissoes p
WHERE f.nome = 'Operador de Caixa'
AND p.modulo || ':' || p.acao IN (
  'caixa:read', 'caixa:view', 'caixa:open', 'caixa:close',
  'vendas:read', 'vendas:create', 'vendas:print',
  'clientes:read', 'clientes:create',
  'produtos:read',
  'dashboard:view',
  'configuracoes:read', 'configuracoes.impressao:read'
)
AND NOT EXISTS (
  SELECT 1 FROM funcao_permissoes fp
  WHERE fp.funcao_id = f.id AND fp.permissao_id = p.id
)
ON CONFLICT DO NOTHING;

-- ESTOQUISTA (Produtos + Estoque)
INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
SELECT 
  f.id,
  p.id,
  f.empresa_id
FROM funcoes f
CROSS JOIN permissoes p
WHERE f.nome = 'Estoquista'
AND p.modulo || ':' || p.acao IN (
  'produtos:read', 'produtos:create', 'produtos:update', 'produtos:manage_stock', 'produtos:manage_categories',
  'dashboard:view', 'dashboard.metricas:view',
  'relatorios:read', 'relatorios:inventory',
  'configuracoes:read'
)
AND NOT EXISTS (
  SELECT 1 FROM funcao_permissoes fp
  WHERE fp.funcao_id = f.id AND fp.permissao_id = p.id
)
ON CONFLICT DO NOTHING;

SELECT '✅ Permissões padrão aplicadas!' as passo_2;

-- 4️⃣ VERIFICAR RESULTADO
SELECT 
  '📊 PERMISSÕES POR FUNÇÃO' as info,
  f.nome as funcao,
  f.empresa_id,
  COUNT(fp.id) as total_permissoes
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
GROUP BY f.id, f.nome, f.empresa_id
ORDER BY f.nome, f.empresa_id;

-- 5️⃣ DISPARAR NOTIFICAÇÃO PARA FRONTEND
SELECT pg_notify('pdv_permissions_reload', '{"message": "Permissões atualizadas globalmente"}');

SELECT '🎉 SISTEMA CONFIGURADO!' as resultado;

-- =============================================
-- 📝 COMO FUNCIONA AGORA
-- =============================================
/*
1. PERMISSÕES PADRÃO:
   ✅ Técnico → Ordens de Serviço, Clientes, Produtos
   ✅ Vendedor → Vendas, Clientes, Produtos
   ✅ Operador de Caixa → Caixa, Vendas, Clientes
   ✅ Estoquista → Produtos, Estoque, Relatórios
   ✅ Administrador → Acesso Total (já estava assim)

2. EDIÇÃO DE PERMISSÕES:
   - Admin vai em: Administração → Funções → Editar
   - Marca/desmarca permissões
   - TRIGGER dispara automaticamente
   - TODOS os funcionários com essa função recebem evento
   - Frontend recarrega permissões em tempo real

3. NOVOS FUNCIONÁRIOS:
   - Ao criar com função "Técnico", recebe permissões do Técnico automaticamente
   - Ao criar com função "Vendedor", recebe permissões do Vendedor automaticamente
   - Etc...

4. PARA VICTOR:
   - Faça LOGOUT e LOGIN novamente
   - Permissões serão carregadas automaticamente
   - Ele verá: Dashboard, Ordens de Serviço, Clientes, Produtos

5. ESCALABILIDADE:
   ✅ Funciona para milhares de usuários
   ✅ Atualização automática em tempo real
   ✅ Sem necessidade de ativar manualmente cada funcionário
*/
