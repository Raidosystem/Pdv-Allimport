-- =====================================================
-- LIMPAR POLÍTICAS RLS DUPLICADAS
-- =====================================================
-- Remove todas as políticas conflitantes e recria apenas as necessárias
-- Data: 2025-12-20
-- =====================================================

-- =====================================================
-- LIMPAR TABELA: lojas_online
-- =====================================================
DROP POLICY IF EXISTS "Acesso público a lojas ativas" ON public.lojas_online;
DROP POLICY IF EXISTS "Leitura pública de lojas ativas" ON public.lojas_online;
DROP POLICY IF EXISTS "public_read_lojas_ativas" ON public.lojas_online;
DROP POLICY IF EXISTS "Empresas podem ver suas lojas" ON public.lojas_online;
DROP POLICY IF EXISTS "Empresas podem criar lojas" ON public.lojas_online;
DROP POLICY IF EXISTS "Empresas podem atualizar suas lojas" ON public.lojas_online;
DROP POLICY IF EXISTS "Empresas podem deletar suas lojas" ON public.lojas_online;

-- Criar políticas LIMPAS para lojas_online
-- 1. Acesso público para lojas ativas
CREATE POLICY "public_read_lojas_ativas"
  ON public.lojas_online FOR SELECT
  USING (ativa = true);

-- 2. Empresas podem ver TODAS suas lojas (ativas ou não)
CREATE POLICY "empresas_manage_lojas_select"
  ON public.lojas_online FOR SELECT
  USING (empresa_id = auth.uid());

-- 3. Empresas podem criar lojas
CREATE POLICY "empresas_manage_lojas_insert"
  ON public.lojas_online FOR INSERT
  WITH CHECK (empresa_id = auth.uid());

-- 4. Empresas podem atualizar suas lojas
CREATE POLICY "empresas_manage_lojas_update"
  ON public.lojas_online FOR UPDATE
  USING (empresa_id = auth.uid());

-- 5. Empresas podem deletar suas lojas
CREATE POLICY "empresas_manage_lojas_delete"
  ON public.lojas_online FOR DELETE
  USING (empresa_id = auth.uid());

-- =====================================================
-- LIMPAR TABELA: caixa
-- =====================================================
DROP POLICY IF EXISTS "Users can only see their own caixa" ON public.caixa;
DROP POLICY IF EXISTS "caixa_empresa_isolation" ON public.caixa;
DROP POLICY IF EXISTS "Usuários podem ver seus próprios caixas" ON public.caixa;
DROP POLICY IF EXISTS "Usuários podem criar caixas" ON public.caixa;
DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios caixas" ON public.caixa;
DROP POLICY IF EXISTS "Usuários podem deletar seus próprios caixas" ON public.caixa;

-- Criar políticas LIMPAS para caixa
CREATE POLICY "caixa_select"
  ON public.caixa FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "caixa_insert"
  ON public.caixa FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "caixa_update"
  ON public.caixa FOR UPDATE
  USING (auth.uid() = usuario_id);

CREATE POLICY "caixa_delete"
  ON public.caixa FOR DELETE
  USING (auth.uid() = usuario_id);

-- =====================================================
-- LIMPAR TABELA: movimentacoes_caixa
-- =====================================================
DROP POLICY IF EXISTS "Users can only see their own movimentacoes_caixa" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "Usuários podem ver movimentações dos seus caixas" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_select_policy" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "Usuários podem criar movimentações" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_insert_policy" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_update_policy" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_delete_policy" ON public.movimentacoes_caixa;

-- Criar políticas LIMPAS para movimentacoes_caixa
CREATE POLICY "movimentacoes_select"
  ON public.movimentacoes_caixa FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.caixa 
      WHERE caixa.id = movimentacoes_caixa.caixa_id 
      AND caixa.usuario_id = auth.uid()
    )
  );

CREATE POLICY "movimentacoes_insert"
  ON public.movimentacoes_caixa FOR INSERT
  WITH CHECK (
    auth.uid() = usuario_id AND
    EXISTS (
      SELECT 1 FROM public.caixa 
      WHERE caixa.id = movimentacoes_caixa.caixa_id 
      AND caixa.usuario_id = auth.uid()
    )
  );

CREATE POLICY "movimentacoes_update"
  ON public.movimentacoes_caixa FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.caixa 
      WHERE caixa.id = movimentacoes_caixa.caixa_id 
      AND caixa.usuario_id = auth.uid()
    )
  );

CREATE POLICY "movimentacoes_delete"
  ON public.movimentacoes_caixa FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.caixa 
      WHERE caixa.id = movimentacoes_caixa.caixa_id 
      AND caixa.usuario_id = auth.uid()
    )
  );

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar políticas finais
SELECT 
  tablename,
  policyname,
  cmd as "Operação",
  CASE 
    WHEN permissive = 'PERMISSIVE' THEN 'Permissiva'
    ELSE 'Restritiva'
  END as "Tipo"
FROM pg_policies
WHERE tablename IN ('caixa', 'movimentacoes_caixa', 'lojas_online')
ORDER BY tablename, policyname;

-- Contagem de políticas por tabela
SELECT 
  tablename,
  COUNT(*) as "Total de Políticas"
FROM pg_policies
WHERE tablename IN ('caixa', 'movimentacoes_caixa', 'lojas_online')
GROUP BY tablename
ORDER BY tablename;

-- Mensagem de sucesso
DO $$
BEGIN
  RAISE NOTICE '✅ Políticas duplicadas removidas!';
  RAISE NOTICE '✅ Agora cada tabela tem apenas 4-5 políticas necessárias';
  RAISE NOTICE '✅ lojas_online: 5 políticas (1 pública + 4 para empresas)';
  RAISE NOTICE '✅ caixa: 4 políticas (SELECT, INSERT, UPDATE, DELETE)';
  RAISE NOTICE '✅ movimentacoes_caixa: 4 políticas (SELECT, INSERT, UPDATE, DELETE)';
END $$;
