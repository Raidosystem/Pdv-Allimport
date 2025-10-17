-- =====================================================
-- CORREÇÃO ERRO 406 AO CARREGAR EMPRESA
-- =====================================================
-- Este script resolve o erro "Failed to load resource: 406"
-- ao buscar empresas na tela de login
-- =====================================================

-- 1. VERIFICAR SE EXISTE EMPRESA CADASTRADA
SELECT 
  COUNT(*) as total_empresas,
  array_agg(id) as empresas_ids,
  array_agg(nome) as empresas_nomes
FROM empresas;

-- 2. VERIFICAR RLS NA TABELA EMPRESAS
SELECT 
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename = 'empresas';

-- 3. SE NÃO EXISTE EMPRESA, CRIAR UMA EMPRESA PADRÃO
DO $$
DECLARE
  v_empresa_count INTEGER;
  v_empresa_id UUID;
BEGIN
  -- Contar empresas existentes
  SELECT COUNT(*) INTO v_empresa_count FROM empresas;
  
  IF v_empresa_count = 0 THEN
    RAISE NOTICE '⚠️ Nenhuma empresa encontrada. Criando empresa padrão...';
    
    -- Inserir empresa padrão
    INSERT INTO empresas (
      nome,
      cnpj,
      telefone,
      email,
      created_at,
      updated_at
    ) VALUES (
      'Allimport',
      '00000000000000',
      '(00) 00000-0000',
      'contato@allimport.com',
      NOW(),
      NOW()
    )
    RETURNING id INTO v_empresa_id;
    
    RAISE NOTICE '✅ Empresa criada com ID: %', v_empresa_id;
  ELSE
    RAISE NOTICE '✅ Já existem % empresa(s) cadastrada(s)', v_empresa_count;
  END IF;
END $$;

-- 4. AJUSTAR RLS PARA PERMITIR LEITURA ANÔNIMA DE EMPRESAS
-- (Necessário para tela de login funcionar)

-- Remover políticas restritivas antigas
DROP POLICY IF EXISTS "Empresas visíveis apenas para próprio usuário" ON empresas;
DROP POLICY IF EXISTS "empresas_select_policy" ON empresas;

-- Criar política que permite leitura pública (somente select)
CREATE POLICY "empresas_public_read"
  ON empresas
  FOR SELECT
  TO public
  USING (true);

-- Manter políticas de escrita protegidas
CREATE POLICY "empresas_insert_policy"
  ON empresas
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "empresas_update_policy"
  ON empresas
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "empresas_delete_policy"
  ON empresas
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- 5. VERIFICAR SE RLS ESTÁ HABILITADO
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;

-- 6. TESTAR ACESSO ANÔNIMO
SET ROLE anon;
SELECT 
  id, 
  nome,
  'Acesso anônimo funcionando!' as status
FROM empresas 
LIMIT 1;
RESET ROLE;

-- 7. RESUMO FINAL
SELECT 
  '✅ Correção aplicada!' as status,
  (SELECT COUNT(*) FROM empresas) as total_empresas,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'empresas') as total_policies;

-- =====================================================
-- INSTRUÇÕES:
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Verifique os resultados
-- 3. Teste a tela de login novamente
-- =====================================================
