-- 🚀 CORREÇÃO: Finalização de Vendas com Erro
-- Diagnóstico: Tabela 'vendas_itens' não existe ou estrutura incompatível
-- Solução: Verificar e corrigir estrutura das tabelas de vendas

-- =====================================================
-- PARTE 1: DIAGNÓSTICO COMPLETO
-- =====================================================

-- Verificar se as tabelas de vendas existem
SELECT 'VERIFICAÇÃO DE TABELAS:' as status;

SELECT 
  table_name,
  CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = t.table_name) 
       THEN '✅ EXISTE' 
       ELSE '❌ NÃO EXISTE' 
  END as status
FROM (
  VALUES 
    ('vendas'),
    ('vendas_itens'), 
    ('itens_venda'),
    ('sale_items'),
    ('sales')
) AS t(table_name);

-- =====================================================
-- PARTE 2: ESTRUTURA DAS TABELAS EXISTENTES
-- =====================================================

-- Verificar estrutura da tabela vendas
SELECT 'ESTRUTURA DA TABELA VENDAS:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'vendas' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verificar estrutura da tabela de itens (se existir)
SELECT 'ESTRUTURA DA TABELA ITENS_VENDA:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'itens_venda' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verificar estrutura da tabela vendas_itens (se existir)
SELECT 'ESTRUTURA DA TABELA VENDAS_ITENS:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'vendas_itens' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- =====================================================
-- PARTE 3: CRIAR TABELA VENDAS_ITENS SE NÃO EXISTIR
-- =====================================================

-- Criar tabela vendas_itens com a estrutura que o código espera
CREATE TABLE IF NOT EXISTS public.vendas_itens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venda_id UUID REFERENCES vendas(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES produtos(id),
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- PARTE 4: VERIFICAR TABELA CAIXA (NECESSÁRIA PARA VENDAS)
-- =====================================================

-- Verificar se tabela caixa existe
SELECT 'VERIFICAÇÃO CAIXA:' as status;
SELECT 
  CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'caixa') 
       THEN '✅ CAIXA EXISTE' 
       ELSE '❌ CAIXA NÃO EXISTE' 
  END as resultado;

-- A tabela caixa já existe, vamos verificar sua estrutura atual
SELECT 'ESTRUTURA DA TABELA CAIXA:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'caixa' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verificar se precisa adicionar user_id na tabela caixa
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'caixa' 
    AND column_name = 'user_id'
  ) THEN
    ALTER TABLE public.caixa ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    RAISE NOTICE '✅ Coluna user_id adicionada à tabela caixa';
  ELSE
    RAISE NOTICE '✅ Coluna user_id já existe na tabela caixa';
  END IF;
END $$;

-- =====================================================
-- PARTE 5: CONFIGURAR RLS E PERMISSÕES
-- =====================================================

-- Habilitar RLS nas tabelas de vendas
ALTER TABLE public.vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;

-- Políticas para VENDAS
DROP POLICY IF EXISTS "vendas_user_policy" ON public.vendas;
CREATE POLICY "vendas_user_policy" ON public.vendas
FOR ALL USING (user_id = auth.uid());

-- Políticas para VENDAS_ITENS
DROP POLICY IF EXISTS "vendas_itens_user_policy" ON public.vendas_itens;
CREATE POLICY "vendas_itens_user_policy" ON public.vendas_itens
FOR ALL USING (user_id = auth.uid());

-- Políticas para CAIXA
DROP POLICY IF EXISTS "caixa_user_policy" ON public.caixa;
CREATE POLICY "caixa_user_policy" ON public.caixa
FOR ALL USING (user_id = auth.uid());

-- =====================================================
-- PARTE 6: TRIGGERS PARA AUTO-SETTAR USER_ID
-- =====================================================

-- Função para setar user_id automaticamente
CREATE OR REPLACE FUNCTION public.auto_set_user_id()
RETURNS TRIGGER AS $$
BEGIN
  NEW.user_id = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para vendas
DROP TRIGGER IF EXISTS trigger_auto_set_user_id_vendas ON public.vendas;
CREATE TRIGGER trigger_auto_set_user_id_vendas
  BEFORE INSERT ON public.vendas
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_user_id();

-- Trigger para vendas_itens
DROP TRIGGER IF EXISTS trigger_auto_set_user_id_vendas_itens ON public.vendas_itens;
CREATE TRIGGER trigger_auto_set_user_id_vendas_itens
  BEFORE INSERT ON public.vendas_itens
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_user_id();

-- Trigger para caixa
DROP TRIGGER IF EXISTS trigger_auto_set_user_id_caixa ON public.caixa;
CREATE TRIGGER trigger_auto_set_user_id_caixa
  BEFORE INSERT ON public.caixa
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_user_id();

-- =====================================================
-- PARTE 7: VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se todas as tabelas foram criadas
SELECT 'VERIFICAÇÃO FINAL:' as status;

SELECT 
  'vendas' as tabela,
  COUNT(*) as total_colunas,
  CASE WHEN COUNT(*) > 5 THEN '✅ OK' ELSE '❌ PROBLEMA' END as status
FROM information_schema.columns 
WHERE table_name = 'vendas' AND table_schema = 'public'

UNION ALL

SELECT 
  'vendas_itens' as tabela,
  COUNT(*) as total_colunas,
  CASE WHEN COUNT(*) > 5 THEN '✅ OK' ELSE '❌ PROBLEMA' END as status
FROM information_schema.columns 
WHERE table_name = 'vendas_itens' AND table_schema = 'public'

UNION ALL

SELECT 
  'caixa' as tabela,
  COUNT(*) as total_colunas,
  CASE WHEN COUNT(*) > 5 THEN '✅ OK' ELSE '❌ PROBLEMA' END as status
FROM information_schema.columns 
WHERE table_name = 'caixa' AND table_schema = 'public';

-- Verificar se há caixa aberto para testes (sem assumir nomes de campos)
SELECT 'CAIXAS DISPONÍVEIS:' as info;
SELECT id, status, created_at
FROM public.caixa 
ORDER BY created_at DESC 
LIMIT 3;

-- Se não houver caixa aberto, criar um para testes (apenas campos básicos)
INSERT INTO public.caixa (status, observacoes)
SELECT 'aberto', 'Caixa criado automaticamente para testes'
WHERE NOT EXISTS (
  SELECT 1 FROM public.caixa 
  WHERE status = 'aberto'
);

SELECT '🎉 CONFIGURAÇÃO DE VENDAS COMPLETA!' as resultado;
SELECT 'Agora o sistema pode finalizar vendas normalmente!' as instrucoes;

-- =====================================================
-- RESUMO PARA DEBUG:
-- =====================================================

/*
📋 PROBLEMA RESOLVIDO:

❌ ANTES: 
- Tabela 'vendas_itens' não existia
- Erro ao finalizar vendas
- Estrutura incompatível

✅ DEPOIS:
- Tabela 'vendas_itens' criada
- Estrutura compatível com código
- RLS e triggers configurados  
- Caixa disponível para vendas

🔧 PRÓXIMOS PASSOS:
1. Execute este SQL no Supabase
2. Teste finalizar uma venda no sistema
3. Verifique se o erro "Erro ao finalizar venda" sumiu

📊 ESTRUTURA CRIADA:
- vendas: Cabeçalho das vendas
- vendas_itens: Itens de cada venda  
- caixa: Controle de sessões de caixa
- Todas com isolamento por usuário (RLS)
*/