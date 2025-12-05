-- =====================================================
-- SISTEMA DE LOJA ONLINE COM CATÁLOGO E CARRINHO WHATSAPP
-- =====================================================
-- Este script cria toda estrutura necessária para:
-- - Catálogo online de produtos
-- - Carrinho de compras com WhatsApp
-- - Personalização por empresa
-- - Analytics básico
-- =====================================================

-- 1. CRIAR TABELA lojas_online
-- =====================================================
CREATE TABLE IF NOT EXISTS public.lojas_online (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  slug TEXT NOT NULL UNIQUE, -- URL amigável (ex: minhaloja)
  nome TEXT NOT NULL, -- Nome da loja exibido no site
  ativa BOOLEAN DEFAULT false, -- Loja online ativa/inativa
  whatsapp TEXT NOT NULL, -- Número para receber pedidos
  logo_url TEXT, -- URL da logo (Supabase Storage)
  cor_primaria TEXT DEFAULT '#3B82F6', -- Cor principal do tema
  cor_secundaria TEXT DEFAULT '#10B981', -- Cor secundária
  descricao TEXT, -- Descrição da loja
  
  -- Configurações
  mostrar_preco BOOLEAN DEFAULT true,
  mostrar_estoque BOOLEAN DEFAULT false,
  permitir_carrinho BOOLEAN DEFAULT true,
  calcular_frete BOOLEAN DEFAULT false,
  permitir_retirada BOOLEAN DEFAULT true,
  
  -- Meta tags para SEO
  meta_title TEXT,
  meta_description TEXT,
  meta_keywords TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  
  CONSTRAINT slug_formato CHECK (slug ~ '^[a-z0-9-]+$')
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_lojas_online_empresa_id ON public.lojas_online(empresa_id);
CREATE INDEX IF NOT EXISTS idx_lojas_online_slug ON public.lojas_online(slug);
CREATE INDEX IF NOT EXISTS idx_lojas_online_ativa ON public.lojas_online(ativa);

-- 2. CRIAR TABELA acessos_loja (Analytics)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.acessos_loja (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loja_id UUID NOT NULL REFERENCES public.lojas_online(id) ON DELETE CASCADE,
  produto_id UUID REFERENCES public.produtos(id) ON DELETE SET NULL,
  tipo TEXT NOT NULL CHECK (tipo IN ('visita_loja', 'visita_produto', 'adicao_carrinho', 'pedido_whatsapp')),
  ip TEXT,
  user_agent TEXT,
  sessao_id TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_acessos_loja_loja_id ON public.acessos_loja(loja_id);
CREATE INDEX IF NOT EXISTS idx_acessos_loja_produto_id ON public.acessos_loja(produto_id);
CREATE INDEX IF NOT EXISTS idx_acessos_loja_tipo ON public.acessos_loja(tipo);
CREATE INDEX IF NOT EXISTS idx_acessos_loja_created_at ON public.acessos_loja(created_at);

-- 3. HABILITAR RLS (Row Level Security)
-- =====================================================
ALTER TABLE public.lojas_online ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.acessos_loja ENABLE ROW LEVEL SECURITY;

-- 4. POLÍTICAS RLS - lojas_online
-- =====================================================

-- Leitura pública (qualquer um pode ver lojas ativas)
DROP POLICY IF EXISTS "Leitura pública de lojas ativas" ON public.lojas_online;
CREATE POLICY "Leitura pública de lojas ativas"
  ON public.lojas_online FOR SELECT
  USING (ativa = true);

-- Leitura por empresa (donos veem suas lojas)
DROP POLICY IF EXISTS "Empresas podem ver suas lojas" ON public.lojas_online;
CREATE POLICY "Empresas podem ver suas lojas"
  ON public.lojas_online FOR SELECT
  USING (empresa_id = auth.uid());

-- Inserção por empresa
DROP POLICY IF EXISTS "Empresas podem criar lojas" ON public.lojas_online;
CREATE POLICY "Empresas podem criar lojas"
  ON public.lojas_online FOR INSERT
  WITH CHECK (empresa_id = auth.uid());

-- Atualização por empresa
DROP POLICY IF EXISTS "Empresas podem atualizar suas lojas" ON public.lojas_online;
CREATE POLICY "Empresas podem atualizar suas lojas"
  ON public.lojas_online FOR UPDATE
  USING (empresa_id = auth.uid());

-- Deleção por empresa
DROP POLICY IF EXISTS "Empresas podem deletar suas lojas" ON public.lojas_online;
CREATE POLICY "Empresas podem deletar suas lojas"
  ON public.lojas_online FOR DELETE
  USING (empresa_id = auth.uid());

-- 5. POLÍTICAS RLS - acessos_loja
-- =====================================================

-- Inserção pública (qualquer um pode registrar acesso)
DROP POLICY IF EXISTS "Inserção pública de acessos" ON public.acessos_loja;
CREATE POLICY "Inserção pública de acessos"
  ON public.acessos_loja FOR INSERT
  WITH CHECK (true);

-- Leitura por empresa (donos veem analytics de suas lojas)
DROP POLICY IF EXISTS "Empresas podem ver analytics" ON public.acessos_loja;
CREATE POLICY "Empresas podem ver analytics"
  ON public.acessos_loja FOR SELECT
  USING (
    loja_id IN (
      SELECT id FROM public.lojas_online 
      WHERE empresa_id = auth.uid()
    )
  );

-- 6. TRIGGER PARA updated_at
-- =====================================================
DROP TRIGGER IF EXISTS trigger_atualizar_updated_at_lojas_online ON public.lojas_online;
CREATE TRIGGER trigger_atualizar_updated_at_lojas_online
  BEFORE UPDATE ON public.lojas_online
  FOR EACH ROW
  EXECUTE FUNCTION public.atualizar_updated_at();

-- 7. FUNÇÃO RPC: Buscar Loja por Slug (Pública)
-- =====================================================
DROP FUNCTION IF EXISTS public.buscar_loja_por_slug(TEXT);
CREATE OR REPLACE FUNCTION public.buscar_loja_por_slug(p_slug TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_loja RECORD;
  v_resultado JSON;
BEGIN
  -- Buscar loja ativa
  SELECT * INTO v_loja
  FROM public.lojas_online
  WHERE slug = p_slug
    AND ativa = true;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Loja não encontrada ou inativa'
    );
  END IF;

  -- Registrar acesso
  INSERT INTO public.acessos_loja (loja_id, tipo, sessao_id, created_at)
  VALUES (v_loja.id, 'visita_loja', gen_random_uuid()::text, now());

  -- Retornar dados da loja
  RETURN json_build_object(
    'success', true,
    'loja', row_to_json(v_loja)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.buscar_loja_por_slug(TEXT) TO anon, authenticated;

-- 8. FUNÇÃO RPC: Listar Produtos Públicos da Loja
-- =====================================================
DROP FUNCTION IF EXISTS public.listar_produtos_loja(TEXT);
CREATE OR REPLACE FUNCTION public.listar_produtos_loja(p_slug TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_loja_id UUID;
  v_empresa_id UUID;
  v_produtos JSON;
BEGIN
  -- Buscar loja
  SELECT id, empresa_id INTO v_loja_id, v_empresa_id
  FROM public.lojas_online
  WHERE slug = p_slug
    AND ativa = true;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Loja não encontrada'
    );
  END IF;

  -- Buscar produtos ativos da empresa
  SELECT json_agg(
    json_build_object(
      'id', p.id,
      'nome', p.nome,
      'descricao', p.descricao,
      'preco', p.preco,
      'preco_custo', p.preco_custo,
      'quantidade', p.quantidade,
      'codigo_barras', p.codigo_barras,
      'imagem_url', p.imagem_url,
      'categoria_id', p.categoria_id,
      'categoria_nome', c.nome
    )
  ) INTO v_produtos
  FROM public.produtos p
  LEFT JOIN public.categorias c ON c.id = p.categoria_id
  WHERE p.empresa_id = v_empresa_id
    AND p.ativo = true
  ORDER BY p.nome;

  RETURN json_build_object(
    'success', true,
    'produtos', COALESCE(v_produtos, '[]'::json)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.listar_produtos_loja(TEXT) TO anon, authenticated;

-- 9. FUNÇÃO RPC: Registrar Pedido WhatsApp
-- =====================================================
DROP FUNCTION IF EXISTS public.registrar_pedido_whatsapp(TEXT, JSONB);
CREATE OR REPLACE FUNCTION public.registrar_pedido_whatsapp(
  p_slug TEXT,
  p_carrinho JSONB
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_loja_id UUID;
BEGIN
  -- Buscar loja
  SELECT id INTO v_loja_id
  FROM public.lojas_online
  WHERE slug = p_slug
    AND ativa = true;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Loja não encontrada'
    );
  END IF;

  -- Registrar pedido
  INSERT INTO public.acessos_loja (
    loja_id,
    tipo,
    metadata,
    created_at
  ) VALUES (
    v_loja_id,
    'pedido_whatsapp',
    p_carrinho,
    now()
  );

  RETURN json_build_object(
    'success', true,
    'message', 'Pedido registrado com sucesso'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.registrar_pedido_whatsapp(TEXT, JSONB) TO anon, authenticated;

-- 10. FUNÇÃO RPC: Analytics da Loja
-- =====================================================
DROP FUNCTION IF EXISTS public.analytics_loja(UUID, DATE, DATE);
CREATE OR REPLACE FUNCTION public.analytics_loja(
  p_loja_id UUID,
  p_data_inicio DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
  p_data_fim DATE DEFAULT CURRENT_DATE
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_total_visitas INT;
  v_total_produtos_vistos INT;
  v_total_adicoes_carrinho INT;
  v_total_pedidos INT;
  v_produtos_populares JSON;
  v_resultado JSON;
BEGIN
  -- Verificar permissão
  IF NOT EXISTS (
    SELECT 1 FROM public.lojas_online
    WHERE id = p_loja_id
      AND empresa_id = auth.uid()
  ) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Sem permissão para acessar analytics'
    );
  END IF;

  -- Total de visitas
  SELECT COUNT(*) INTO v_total_visitas
  FROM public.acessos_loja
  WHERE loja_id = p_loja_id
    AND tipo = 'visita_loja'
    AND created_at::date BETWEEN p_data_inicio AND p_data_fim;

  -- Produtos vistos
  SELECT COUNT(*) INTO v_total_produtos_vistos
  FROM public.acessos_loja
  WHERE loja_id = p_loja_id
    AND tipo = 'visita_produto'
    AND created_at::date BETWEEN p_data_inicio AND p_data_fim;

  -- Adições ao carrinho
  SELECT COUNT(*) INTO v_total_adicoes_carrinho
  FROM public.acessos_loja
  WHERE loja_id = p_loja_id
    AND tipo = 'adicao_carrinho'
    AND created_at::date BETWEEN p_data_inicio AND p_data_fim;

  -- Pedidos WhatsApp
  SELECT COUNT(*) INTO v_total_pedidos
  FROM public.acessos_loja
  WHERE loja_id = p_loja_id
    AND tipo = 'pedido_whatsapp'
    AND created_at::date BETWEEN p_data_inicio AND p_data_fim;

  -- Produtos mais populares
  SELECT json_agg(
    json_build_object(
      'produto_id', a.produto_id,
      'produto_nome', p.nome,
      'visualizacoes', COUNT(*)
    ) ORDER BY COUNT(*) DESC
  ) INTO v_produtos_populares
  FROM public.acessos_loja a
  INNER JOIN public.produtos p ON p.id = a.produto_id
  WHERE a.loja_id = p_loja_id
    AND a.tipo = 'visita_produto'
    AND a.created_at::date BETWEEN p_data_inicio AND p_data_fim
  GROUP BY a.produto_id, p.nome
  LIMIT 10;

  -- Retornar analytics
  RETURN json_build_object(
    'success', true,
    'analytics', json_build_object(
      'total_visitas', v_total_visitas,
      'produtos_vistos', v_total_produtos_vistos,
      'adicoes_carrinho', v_total_adicoes_carrinho,
      'pedidos_whatsapp', v_total_pedidos,
      'taxa_conversao', 
        CASE 
          WHEN v_total_visitas > 0 
          THEN ROUND((v_total_pedidos::numeric / v_total_visitas::numeric) * 100, 2)
          ELSE 0
        END,
      'produtos_populares', COALESCE(v_produtos_populares, '[]'::json)
    )
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.analytics_loja(UUID, DATE, DATE) TO authenticated;

-- 11. CONCEDER PERMISSÕES
-- =====================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON public.lojas_online TO authenticated;
GRANT SELECT, INSERT ON public.acessos_loja TO anon, authenticated;

-- 12. RESULTADO
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ ESTRUTURA DE LOJA ONLINE CRIADA!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Tabelas criadas:';
  RAISE NOTICE '   • lojas_online (configurações)';
  RAISE NOTICE '   • acessos_loja (analytics)';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 Políticas RLS configuradas (10 políticas)';
  RAISE NOTICE '';
  RAISE NOTICE '⚙️  Funções RPC disponíveis:';
  RAISE NOTICE '   • buscar_loja_por_slug(slug)';
  RAISE NOTICE '   • listar_produtos_loja(slug)';
  RAISE NOTICE '   • registrar_pedido_whatsapp(slug, carrinho)';
  RAISE NOTICE '   • analytics_loja(loja_id, data_inicio, data_fim)';
  RAISE NOTICE '';
  RAISE NOTICE '🚀 Próximos passos:';
  RAISE NOTICE '   1. Execute este script no Supabase SQL Editor';
  RAISE NOTICE '   2. Implemente o frontend (em andamento...)';
  RAISE NOTICE '   3. Configure sua primeira loja online!';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
END $$;
