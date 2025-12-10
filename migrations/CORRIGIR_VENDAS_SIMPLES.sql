-- 🚀 CORREÇÃO SIMPLES: Finalização de Vendas
-- Execute este SQL no Supabase para resolver o erro de finalização

-- 1. Criar tabela vendas_itens (que está faltando)
CREATE TABLE IF NOT EXISTS public.vendas_itens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venda_id UUID REFERENCES vendas(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES produtos(id),
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Adicionar user_id na tabela vendas se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'vendas' 
    AND column_name = 'user_id'
  ) THEN
    ALTER TABLE public.vendas ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- 3. Adicionar user_id na tabela caixa se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'caixa' 
    AND column_name = 'user_id'
  ) THEN
    ALTER TABLE public.caixa ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- 4. Configurar RLS básico
ALTER TABLE public.vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;

-- 5. Políticas básicas
DROP POLICY IF EXISTS "vendas_user_policy" ON public.vendas;
CREATE POLICY "vendas_user_policy" ON public.vendas
FOR ALL USING (user_id = auth.uid());

DROP POLICY IF EXISTS "vendas_itens_user_policy" ON public.vendas_itens;
CREATE POLICY "vendas_itens_user_policy" ON public.vendas_itens
FOR ALL USING (user_id = auth.uid());

DROP POLICY IF EXISTS "caixa_user_policy" ON public.caixa;
CREATE POLICY "caixa_user_policy" ON public.caixa
FOR ALL USING (user_id = auth.uid());

-- 6. Função para auto-setar user_id
CREATE OR REPLACE FUNCTION public.auto_set_user_id()
RETURNS TRIGGER AS $$
BEGIN
  NEW.user_id = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Triggers
DROP TRIGGER IF EXISTS trigger_auto_set_user_id_vendas ON public.vendas;
CREATE TRIGGER trigger_auto_set_user_id_vendas
  BEFORE INSERT ON public.vendas
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_user_id();

DROP TRIGGER IF EXISTS trigger_auto_set_user_id_vendas_itens ON public.vendas_itens;
CREATE TRIGGER trigger_auto_set_user_id_vendas_itens
  BEFORE INSERT ON public.vendas_itens
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_user_id();

DROP TRIGGER IF EXISTS trigger_auto_set_user_id_caixa ON public.caixa;
CREATE TRIGGER trigger_auto_set_user_id_caixa
  BEFORE INSERT ON public.caixa
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_user_id();

-- 8. Criar caixa aberto se não existir
INSERT INTO public.caixa (status, observacoes)
SELECT 'aberto', 'Caixa automático para vendas'
WHERE NOT EXISTS (
  SELECT 1 FROM public.caixa 
  WHERE status = 'aberto'
);

-- 9. Verificação final
SELECT 
  'vendas_itens' as tabela,
  CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vendas_itens') 
       THEN '✅ CRIADA' 
       ELSE '❌ ERRO' 
  END as status;

SELECT '🎉 PRONTO! Agora você pode finalizar vendas!' as resultado;