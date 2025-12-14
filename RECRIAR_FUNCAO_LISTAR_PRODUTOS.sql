-- 🔧 RECRIAR FUNÇÃO listar_produtos_loja COM COLUNAS CORRETAS

-- Dropar função antiga
DROP FUNCTION IF EXISTS public.listar_produtos_loja(TEXT);

-- Criar nova função adaptada às colunas reais
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
  -- Usar COALESCE para suportar ambos os nomes de coluna
  SELECT json_agg(
    json_build_object(
      'id', p.id,
      'nome', p.nome,
      'descricao', COALESCE(p.descricao, ''),
      'preco', COALESCE(p.preco, 0),
      'preco_custo', COALESCE(p.preco_custo, 0),
      'quantidade', COALESCE(p.quantidade, p.estoque, 0),
      'codigo_barras', p.codigo_barras,
      'imagem_url', COALESCE(p.imagem_url, p.image_url),
      'categoria_id', p.categoria_id,
      'categoria_nome', c.nome
    )
  ) INTO v_produtos
  FROM public.produtos p
  LEFT JOIN public.categorias c ON c.id = p.categoria_id
  WHERE COALESCE(p.empresa_id, p.user_id) = v_empresa_id
    AND p.ativo = true
  ORDER BY p.nome;

  RETURN json_build_object(
    'success', true,
    'produtos', COALESCE(v_produtos, '[]'::json)
  );
END;
$$;

-- Dar permissões
GRANT EXECUTE ON FUNCTION public.listar_produtos_loja(TEXT) TO anon, authenticated;

-- Testar
SELECT public.listar_produtos_loja('loja-allimport');
