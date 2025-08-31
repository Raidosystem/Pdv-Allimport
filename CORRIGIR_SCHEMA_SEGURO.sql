-- 🔧 CORREÇÃO SEGURA: Resolver Inconsistências de Schema (VERSÃO SEGURA)
-- Execute este script no Supabase SQL Editor para corrigir os problemas

-- =====================================================
-- PARTE 1: ADICIONAR CAMPOS FALTANTES
-- =====================================================

-- Adicionar campos que o código espera mas não existem
ALTER TABLE public.produtos 
ADD COLUMN IF NOT EXISTS sku TEXT,
ADD COLUMN IF NOT EXISTS estoque_minimo INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS unidade TEXT DEFAULT 'un',
ADD COLUMN IF NOT EXISTS ativo BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS preco_custo DECIMAL(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS imagem_url TEXT;

-- =====================================================
-- PARTE 2: ATUALIZAR DADOS EXISTENTES
-- =====================================================

-- Gerar SKUs únicos para produtos que não têm
UPDATE public.produtos 
SET sku = 'PDV' || SUBSTRING(id::text, 1, 8) || EXTRACT(epoch FROM created_at)::int::text
WHERE sku IS NULL OR sku = '';

-- Definir unidade padrão
UPDATE public.produtos 
SET unidade = 'un' 
WHERE unidade IS NULL OR unidade = '';

-- Ativar todos os produtos existentes
UPDATE public.produtos 
SET ativo = true 
WHERE ativo IS NULL;

-- Definir estoque mínimo padrão
UPDATE public.produtos 
SET estoque_minimo = 1 
WHERE estoque_minimo IS NULL;

-- =====================================================
-- PARTE 3: CRIAR FUNÇÃO DE COMPATIBILIDADE PARA VENDAS
-- =====================================================

-- Função para buscar produtos com campos corretos para vendas
CREATE OR REPLACE FUNCTION public.buscar_produtos_vendas(
  p_search TEXT DEFAULT NULL,
  p_barcode TEXT DEFAULT NULL,
  p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
  id UUID,
  nome TEXT,
  descricao TEXT,
  sku TEXT,
  codigo_barras TEXT,
  preco DECIMAL,
  estoque_atual INTEGER,
  estoque_minimo INTEGER,
  unidade TEXT,
  criado_em TIMESTAMP,
  atualizado_em TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.nome,
    p.descricao,
    p.sku,
    p.codigo_barras,
    p.preco,
    p.estoque as estoque_atual,  -- Mapear estoque → estoque_atual
    p.estoque_minimo,
    p.unidade,
    p.created_at as criado_em,   -- Mapear created_at → criado_em
    p.updated_at as atualizado_em -- Mapear updated_at → atualizado_em
  FROM public.produtos p
  WHERE p.ativo = true
    AND (p_search IS NULL OR (
      p.nome ILIKE '%' || p_search || '%' OR 
      p.codigo_barras ILIKE '%' || p_search || '%' OR
      p.sku ILIKE '%' || p_search || '%'
    ))
    AND (p_barcode IS NULL OR p.codigo_barras = p_barcode)
  ORDER BY p.nome
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- PARTE 4: CRIAR TRIGGERS DE ATUALIZAÇÃO
-- =====================================================

-- Trigger para atualizar timestamp automaticamente
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger na tabela produtos
DROP TRIGGER IF EXISTS produtos_updated_at ON public.produtos;
CREATE TRIGGER produtos_updated_at
  BEFORE UPDATE ON public.produtos
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- =====================================================
-- PARTE 5: POLÍTICAS RLS BÁSICAS
-- =====================================================

-- Permitir leitura pública de produtos ativos (para vendas)
DROP POLICY IF EXISTS "Allow public read active products" ON public.produtos;
CREATE POLICY "Allow public read active products" 
ON public.produtos FOR SELECT 
TO public
USING (ativo = true);

-- =====================================================
-- PARTE 6: VERIFICAÇÃO E TESTES
-- =====================================================

-- Verificar estrutura da tabela
SELECT 'VERIFICACAO - Estrutura da tabela produtos:' as status;

SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'produtos'
ORDER BY ordinal_position;

-- Testar a função de busca
SELECT 'TESTE - Buscar produtos (limite 3):' as status;
SELECT * FROM public.buscar_produtos_vendas('', NULL, 3);

-- Verificar produtos ativos
SELECT 'CONTAGEM - Produtos ativos:' as status;
SELECT COUNT(*) as total_produtos_ativos 
FROM public.produtos 
WHERE ativo = true;

-- Testar consulta direta corrigida
SELECT 'TESTE - Consulta direta com campos corretos:' as status;
SELECT 
  id, 
  nome, 
  descricao, 
  sku, 
  codigo_barras, 
  preco, 
  estoque as estoque_atual,
  estoque_minimo, 
  unidade,
  created_at as criado_em,
  updated_at as atualizado_em
FROM public.produtos 
WHERE ativo = true 
LIMIT 3;

-- =====================================================
-- INSTRUÇÕES PARA ATUALIZAR O CÓDIGO:
-- =====================================================

/*
📋 APÓS EXECUTAR ESTE SCRIPT, ATUALIZE O CÓDIGO:

1. VENDAS (src/services/sales.ts) - DUAS OPÇÕES:

OPÇÃO A - Usar função (RECOMENDADO):
const { data, error } = await supabase.rpc('buscar_produtos_vendas', {
  p_search: params.search,
  p_barcode: params.barcode,
  p_limit: 50
});

OPÇÃO B - Corrigir consulta:
.select(`
  id,
  nome,
  descricao,
  sku,
  codigo_barras,
  preco,
  estoque as estoque_atual,
  estoque_minimo,
  unidade,
  created_at as criado_em,
  updated_at as atualizado_em
`)

2. PRODUTOS (src/hooks/useProducts.ts):

// Corrigir ordenação:
.order('created_at', { ascending: false })  // EM VEZ DE 'criado_em'

// Corrigir inserção:
.insert([{
  nome: productData.nome,
  preco: productData.preco_venda,      // EM VEZ DE preco_venda
  estoque: productData.estoque,
  sku: productData.codigo,             // EM VEZ DE codigo
  ativo: productData.ativo,
  unidade: productData.unidade,
  user_id: userId
}])

✅ Todos os 818 produtos estarão acessíveis!
*/
