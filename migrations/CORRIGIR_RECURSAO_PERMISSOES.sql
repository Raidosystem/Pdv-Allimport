-- =====================================================
-- CORRIGIR RECURSÃO INFINITA NAS POLÍTICAS DE PERMISSÕES
-- =====================================================
-- Erro: infinite recursion detected in policy for relation "permissoes"
-- Solução: Simplificar políticas RLS da tabela permissoes

-- 🔥 PASSO 1: Remover TODAS as políticas existentes da tabela permissoes
DROP POLICY IF EXISTS "permissoes_select_policy" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_insert_policy" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_update_policy" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_delete_policy" ON permissoes CASCADE;
DROP POLICY IF EXISTS "Admin pode gerenciar permissoes" ON permissoes CASCADE;
DROP POLICY IF EXISTS "Usuarios podem ver suas permissoes" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_read_policy" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_write_policy" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_select_public" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_insert_admin" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_update_admin" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_delete_admin" ON permissoes CASCADE;

-- 🔥 PASSO 2: Garantir que RLS está ativo
ALTER TABLE permissoes ENABLE ROW LEVEL SECURITY;

-- ✅ PASSO 3: Criar políticas SIMPLES e SEM RECURSÃO
-- Essas políticas NÃO podem referenciar outras tabelas que também usam permissões

-- 📖 SELECT: Todos autenticados podem ver permissões (é tabela de metadados)
CREATE POLICY "permissoes_select_public"
ON permissoes
FOR SELECT
TO authenticated
USING (true);

-- ✏️ INSERT: Apenas service_role ou admin pode inserir
CREATE POLICY "permissoes_insert_admin"
ON permissoes
FOR INSERT
TO authenticated
WITH CHECK (
  -- Super admin pode (verifica direto na tabela users sem recursão)
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.raw_user_meta_data->>'is_super_admin' = 'true'
  )
  OR
  -- Admin da empresa pode (verifica direto na tabela empresas)
  EXISTS (
    SELECT 1 FROM empresas
    WHERE empresas.user_id = auth.uid()
  )
);

-- 🔄 UPDATE: Apenas service_role ou admin pode atualizar
CREATE POLICY "permissoes_update_admin"
ON permissoes
FOR UPDATE
TO authenticated
USING (
  -- Super admin pode
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.raw_user_meta_data->>'is_super_admin' = 'true'
  )
  OR
  -- Admin da empresa pode
  EXISTS (
    SELECT 1 FROM empresas
    WHERE empresas.user_id = auth.uid()
  )
)
WITH CHECK (
  -- Super admin pode
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.raw_user_meta_data->>'is_super_admin' = 'true'
  )
  OR
  -- Admin da empresa pode
  EXISTS (
    SELECT 1 FROM empresas
    WHERE empresas.user_id = auth.uid()
  )
);

-- 🗑️ DELETE: Apenas service_role ou admin pode deletar
CREATE POLICY "permissoes_delete_admin"
ON permissoes
FOR DELETE
TO authenticated
USING (
  -- Super admin pode
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.raw_user_meta_data->>'is_super_admin' = 'true'
  )
  OR
  -- Admin da empresa pode
  EXISTS (
    SELECT 1 FROM empresas
    WHERE empresas.user_id = auth.uid()
  )
);

-- ✅ Verificar políticas criadas
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'permissoes'
ORDER BY policyname;

-- 📊 Teste: Listar todas as permissões (deve funcionar sem recursão)
SELECT 
  id,
  recurso,
  acao,
  descricao,
  categoria,
  created_at
FROM permissoes
ORDER BY categoria, recurso, acao;

-- 📌 OBSERVAÇÃO: Seu banco já possui 91 permissões registradas
-- Categorias existentes: Administração, Caixa, Clientes, Configurações, 
-- Dashboard, geral, Ordens de Serviço, Produtos, Relatórios, Vendas
--
-- Este script corrige APENAS as políticas RLS (Row Level Security)
-- As permissões existentes NÃO serão alteradas/perdidas
