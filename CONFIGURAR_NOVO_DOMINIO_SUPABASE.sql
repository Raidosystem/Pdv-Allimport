-- CONFIGURAÇÃO SUPABASE PARA NOVO DOMÍNIO
-- URL: https://pdv.crmvsystem.com/
-- Data: 17/08/2025

-- ==========================================
-- 1. CONFIGURAR DOMÍNIO DE AUTENTICAÇÃO
-- ==========================================

-- Primeiro, vamos verificar a configuração atual
SELECT * FROM auth.config;

-- Configurar o novo domínio para autenticação
UPDATE auth.config 
SET 
  site_url = 'https://pdv.crmvsystem.com/',
  uri_allow_list = 'https://pdv.crmvsystem.com/*,https://pdv-allimport.surge.sh/*,http://localhost:*'
WHERE id = 1;

-- Se não existir registro de config, criar um
INSERT INTO auth.config (site_url, uri_allow_list) 
VALUES (
  'https://pdv.crmvsystem.com/', 
  'https://pdv.crmvsystem.com/*,https://pdv-allimport.surge.sh/*,http://localhost:*'
) 
ON CONFLICT (id) DO UPDATE SET
  site_url = EXCLUDED.site_url,
  uri_allow_list = EXCLUDED.uri_allow_list;

-- ==========================================
-- 2. VERIFICAR E CRIAR USUÁRIO ADMIN
-- ==========================================

-- Verificar se existe usuário admin
SELECT 
  id, 
  email, 
  email_confirmed_at,
  created_at,
  last_sign_in_at
FROM auth.users 
WHERE email = 'novaradiosystem@outlook.com';

-- Se não existir usuário, será necessário criar via dashboard do Supabase
-- ou usar o signup normal na aplicação

-- ==========================================
-- 3. CONFIGURAR POLÍTICAS RLS
-- ==========================================

-- Habilitar RLS em todas as tabelas principais
ALTER TABLE IF EXISTS public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.itens_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.movimentos_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.relatorios ENABLE ROW LEVEL SECURITY;

-- Política para clientes - usuários autenticados podem acessar todos
DROP POLICY IF EXISTS "Usuários autenticados podem ver clientes" ON public.clientes;
CREATE POLICY "Usuários autenticados podem ver clientes" ON public.clientes
  FOR ALL USING (auth.role() = 'authenticated');

-- Política para produtos - usuários autenticados podem acessar todos  
DROP POLICY IF EXISTS "Usuários autenticados podem ver produtos" ON public.produtos;
CREATE POLICY "Usuários autenticados podem ver produtos" ON public.produtos
  FOR ALL USING (auth.role() = 'authenticated');

-- Política para vendas - usuários autenticados podem acessar todos
DROP POLICY IF EXISTS "Usuários autenticados podem ver vendas" ON public.vendas;
CREATE POLICY "Usuários autenticados podem ver vendas" ON public.vendas
  FOR ALL USING (auth.role() = 'authenticated');

-- Política para itens_venda - usuários autenticados podem acessar todos
DROP POLICY IF EXISTS "Usuários autenticados podem ver itens_venda" ON public.itens_venda;
CREATE POLICY "Usuários autenticados podem ver itens_venda" ON public.itens_venda
  FOR ALL USING (auth.role() = 'authenticated');

-- Política para caixa - usuários autenticados podem acessar todos
DROP POLICY IF EXISTS "Usuários autenticados podem ver caixa" ON public.caixa;
CREATE POLICY "Usuários autenticados podem ver caixa" ON public.caixa
  FOR ALL USING (auth.role() = 'authenticated');

-- Política para movimentos_caixa - usuários autenticados podem acessar todos
DROP POLICY IF EXISTS "Usuários autenticados podem ver movimentos_caixa" ON public.movimentos_caixa;
CREATE POLICY "Usuários autenticados podem ver movimentos_caixa" ON public.movimentos_caixa
  FOR ALL USING (auth.role() = 'authenticated');

-- ==========================================
-- 4. CONFIGURAR FUNÇÕES E TRIGGERS
-- ==========================================

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger em todas as tabelas com updated_at
DO $$
DECLARE
  t TEXT;
BEGIN
  FOR t IN 
    SELECT table_name 
    FROM information_schema.columns 
    WHERE column_name = 'updated_at' 
    AND table_schema = 'public'
  LOOP
    EXECUTE format('
      DROP TRIGGER IF EXISTS handle_updated_at ON public.%I;
      CREATE TRIGGER handle_updated_at
        BEFORE UPDATE ON public.%I
        FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
    ', t, t);
  END LOOP;
END $$;

-- ==========================================
-- 5. VERIFICAÇÕES FINAIS
-- ==========================================

-- Verificar configuração de domínio
SELECT 
  'Configuração Auth' as tipo,
  site_url,
  uri_allow_list
FROM auth.config;

-- Verificar usuários
SELECT 
  'Usuários' as tipo,
  COUNT(*) as total,
  COUNT(CASE WHEN email_confirmed_at IS NOT NULL THEN 1 END) as confirmados
FROM auth.users;

-- Verificar tabelas com RLS
SELECT 
  'Tabelas RLS' as tipo,
  schemaname,
  tablename,
  rowsecurity as rls_habilitado
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = true;

-- Verificar políticas
SELECT 
  'Políticas' as tipo,
  schemaname,
  tablename,
  policyname,
  cmd as comando
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

COMMIT;
