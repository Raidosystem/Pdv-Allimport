-- 🔧 CORREÇÃO CRÍTICA: Resolver Inconsistências de Schema
-- Execute este script no Supabase SQL Editor para corrigir os problemas

-- =====================================================
-- PARTE 1: ADICIONAR CAMPOS FALTANTES
-- =====================================================

-- Adicionar campos que o código espera mas não existem
ALTER TABLE public.produtos 
ADD COLUMN IF NOT EXISTS sku TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS estoque_minimo INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS unidade TEXT DEFAULT 'un',
ADD COLUMN IF NOT EXISTS ativo BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS preco_custo DECIMAL(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS imagem_url TEXT;

-- =====================================================
-- PARTE 2: CRIAR ALIASES/VIEWS PARA COMPATIBILIDADE
-- =====================================================

-- Primeiro, remover tabela 'products' se existir (para criar view)
DROP TABLE IF EXISTS public.products CASCADE;

-- Criar view que mapeia campos português → inglês
CREATE OR REPLACE VIEW public.products AS
SELECT 
  id,
  nome as name,
  descricao as description,
  sku,
  codigo_barras as barcode,
  categoria_id as category_id,
  preco as price,
  preco_custo as cost,
  estoque as stock_quantity,
  estoque_minimo as min_stock,
  unidade as unit,
  ativo as active,
  imagem_url as image_url,
  created_at,
  updated_at,
  user_id
FROM public.produtos;

-- =====================================================
-- PARTE 3: ATUALIZAR DADOS EXISTENTES
-- =====================================================

-- Gerar SKUs únicos para produtos que não têm
UPDATE public.produtos 
SET sku = 'PDV' || SUBSTRING(id::text, 1, 8) || EXTRACT(epoch FROM created_at)::int::text
WHERE sku IS NULL;

-- Definir unidade padrão
UPDATE public.produtos 
SET unidade = 'un' 
WHERE unidade IS NULL;

-- Ativar todos os produtos existentes
UPDATE public.produtos 
SET ativo = true 
WHERE ativo IS NULL;

-- Definir estoque mínimo padrão
UPDATE public.produtos 
SET estoque_minimo = 1 
WHERE estoque_minimo IS NULL;

-- =====================================================
-- PARTE 4: CRIAR FUNÇÃO DE COMPATIBILIDADE
-- =====================================================

-- Função para buscar produtos com campos corretos
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
      p.codigo_barras ILIKE '%' || p_search || '%'
    ))
    AND (p_barcode IS NULL OR p.codigo_barras = p_barcode)
  ORDER BY p.nome
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- PARTE 5: CRIAR TRIGGERS DE ATUALIZAÇÃO
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
-- PARTE 6: POLÍTICAS RLS (se necessário)
-- =====================================================

-- Habilitar RLS se não estiver habilitado
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;

-- Política para permitir leitura de produtos ativos
DROP POLICY IF EXISTS "Allow read active products" ON public.produtos;
CREATE POLICY "Allow read active products" 
ON public.produtos FOR SELECT 
USING (ativo = true);

-- Política para permitir inserção por usuários autenticados
DROP POLICY IF EXISTS "Allow insert for authenticated users" ON public.produtos;
CREATE POLICY "Allow insert for authenticated users" 
ON public.produtos FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

-- Política para permitir atualização por proprietário
DROP POLICY IF EXISTS "Allow update for owner" ON public.produtos;
CREATE POLICY "Allow update for owner" 
ON public.produtos FOR UPDATE 
TO authenticated 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- PARTE 7: VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se todos os campos existem agora
SELECT 'VERIFICACAO FINAL - Estrutura da tabela produtos:' as status;

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

-- Verificar view products
SELECT 'TESTE - View products (limite 3):' as status;
SELECT id, name, price, stock_quantity 
FROM public.products 
WHERE active = true 
LIMIT 3;

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================

/*
📋 APÓS EXECUTAR ESTE SCRIPT:

1. VENDAS - Use a função:
   SELECT * FROM public.buscar_produtos_vendas('samsung', NULL, 10);

2. PRODUTOS - Use campos corretos:
   SELECT id, nome, preco, estoque, ativo FROM public.produtos;

3. INSERÇÃO - Use campos existentes:
   INSERT INTO public.produtos (nome, preco, estoque, sku, user_id) 
   VALUES ('Produto Teste', 25.90, 10, 'TEST001', auth.uid());

4. VIEW INGLÊS - Se preferir:
   SELECT id, name, price, stock_quantity FROM public.products;

✅ Todas as consultas do código devem funcionar agora!
*/
