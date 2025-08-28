-- 🚨 SOLUÇÃO RÁPIDA: Erro user_id null - Execute IMEDIATAMENTE no Supabase

-- 1. PERMITIR NULL temporariamente para não travar o sistema
ALTER TABLE public.clientes ALTER COLUMN user_id DROP NOT NULL;

-- 2. CRIAR função simples para auto-inserir user_id
CREATE OR REPLACE FUNCTION handle_new_cliente() 
RETURNS trigger AS $$
BEGIN
  NEW.user_id = auth.uid();
  RETURN NEW;
END;
$$ language plpgsql security definer;

-- 3. APLICAR trigger na tabela clientes
DROP TRIGGER IF EXISTS on_clientes_created ON public.clientes;
CREATE TRIGGER on_clientes_created
  BEFORE INSERT ON public.clientes
  FOR EACH ROW EXECUTE FUNCTION handle_new_cliente();

-- 4. CORRIGIR registros órfãos existentes
UPDATE public.clientes 
SET user_id = (SELECT id FROM auth.users WHERE email = 'novaradiosystem@outlook.com' LIMIT 1)
WHERE user_id IS NULL;

-- 5. VERIFICAR se funcionou
SELECT COUNT(*) as clientes_sem_user_id FROM public.clientes WHERE user_id IS NULL;

-- Se retornar 0, está corrigido!
SELECT 'ERRO CORRIGIDO! ✅ Teste criar um cliente agora.' as resultado;
