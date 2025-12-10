-- =====================================================
-- CORREÇÃO URGENTE: Clientes sumindo por causa do RLS
-- =====================================================
-- Problema: Quando RLS está ativo, clientes não aparecem
-- Causa: Políticas RLS estão bloqueando o acesso
-- Solução: Configurar RLS correto com isolamento por user_id
-- =====================================================

-- 📊 DIAGNÓSTICO RÁPIDO
-- =====================================================

-- 1. Ver status atual do RLS
SELECT 
    '1. STATUS RLS' as etapa,
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables 
WHERE tablename = 'clientes'
AND schemaname = 'public';

-- 2. Ver políticas atuais
SELECT 
    '2. POLÍTICAS ATUAIS' as etapa,
    policyname,
    cmd,
    permissive,
    qual::text as condicao_using,
    with_check::text as condicao_with_check
FROM pg_policies 
WHERE tablename = 'clientes';

-- 3. Ver estrutura da tabela (verificar se tem user_id)
SELECT 
    '3. ESTRUTURA' as etapa,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'clientes'
AND column_name IN ('id', 'user_id', 'empresa_id')
ORDER BY ordinal_position;

-- 4. Ver amostra de dados (verificar user_id preenchido)
SELECT 
    '4. AMOSTRA DADOS' as etapa,
    id,
    nome,
    user_id,
    created_at
FROM clientes
LIMIT 3;

-- =====================================================
-- 🔧 SOLUÇÃO 1: CORRIGIR POLÍTICAS RLS
-- =====================================================

-- Remover TODAS as políticas antigas
DROP POLICY IF EXISTS "clientes_select_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_insert_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_update_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_delete_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_isolamento_total" ON clientes;
DROP POLICY IF EXISTS "Usuários podem ver seus próprios clientes" ON clientes;
DROP POLICY IF EXISTS "Users can view all clientes" ON clientes;
DROP POLICY IF EXISTS "Enable read access for all users" ON clientes;

-- Criar políticas CORRETAS com isolamento por user_id

-- SELECT: Ver apenas seus próprios clientes
CREATE POLICY "clientes_select_user" 
ON clientes 
FOR SELECT 
TO authenticated
USING (user_id = auth.uid());

-- INSERT: Inserir apenas com seu user_id
CREATE POLICY "clientes_insert_user" 
ON clientes 
FOR INSERT 
TO authenticated
WITH CHECK (user_id = auth.uid());

-- UPDATE: Atualizar apenas seus clientes
CREATE POLICY "clientes_update_user" 
ON clientes 
FOR UPDATE 
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- DELETE: Deletar apenas seus clientes
CREATE POLICY "clientes_delete_user" 
ON clientes 
FOR DELETE 
TO authenticated
USING (user_id = auth.uid());

-- =====================================================
-- 🔧 SOLUÇÃO 2: GARANTIR user_id PREENCHIDO
-- =====================================================

-- Criar/recriar trigger para preencher user_id automaticamente
DROP TRIGGER IF EXISTS trigger_set_user_id_clientes ON clientes;
DROP FUNCTION IF EXISTS auto_set_user_id_clientes() CASCADE;

CREATE OR REPLACE FUNCTION auto_set_user_id_clientes()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id IS NULL THEN
    NEW.user_id := auth.uid();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_set_user_id_clientes
  BEFORE INSERT ON clientes
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_user_id_clientes();

-- =====================================================
-- 🔧 SOLUÇÃO 3: CORRIGIR CLIENTES SEM user_id
-- =====================================================

-- Ver quantos clientes estão sem user_id
SELECT 
    '5. CLIENTES SEM USER_ID' as etapa,
    COUNT(*) as total_sem_user_id
FROM clientes 
WHERE user_id IS NULL;

-- Atualizar clientes órfãos (associar ao usuário logado)
-- ATENÇÃO: Execute isso apenas se você for o único usuário do sistema
-- ou se souber que os clientes sem user_id são seus

-- Opção A: Atualizar para o usuário atual (CUIDADO!)
-- Primeiro, veja seu user_id:
SELECT auth.uid() as meu_user_id;

-- Depois, atualize (descomente se tiver certeza):
/*
UPDATE clientes 
SET user_id = auth.uid()
WHERE user_id IS NULL;
*/

-- Opção B: Atualizar para um usuário específico
-- Substitua 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' pelo seu user_id
/*
UPDATE clientes 
SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
WHERE user_id IS NULL;
*/

-- =====================================================
-- ✅ TESTES
-- =====================================================

-- Teste 1: Ver suas políticas
SELECT 
    'POLÍTICAS CRIADAS' as status,
    policyname,
    cmd
FROM pg_policies 
WHERE tablename = 'clientes'
ORDER BY cmd;

-- Teste 2: Ver trigger criado
SELECT 
    'TRIGGER CRIADO' as status,
    trigger_name,
    event_manipulation,
    action_timing
FROM information_schema.triggers
WHERE event_object_table = 'clientes'
AND trigger_schema = 'public';

-- Teste 3: Tentar buscar clientes (deve mostrar apenas os seus)
SELECT 
    'TESTE BUSCA' as status,
    COUNT(*) as total_clientes_visiveis
FROM clientes;

-- Teste 4: Inserir novo cliente (deve funcionar)
INSERT INTO clientes (nome, tipo, telefone)
VALUES ('Cliente Teste RLS', 'Física', '11999999999')
RETURNING id, nome, user_id;

-- =====================================================
-- 📋 INSTRUÇÕES FINAIS
-- =====================================================
-- 
-- 1. Execute as seções de DIAGNÓSTICO primeiro (1 a 4)
-- 2. Execute a SOLUÇÃO 1 (políticas RLS)
-- 3. Execute a SOLUÇÃO 2 (trigger)
-- 4. Analise a SOLUÇÃO 3 e decida se precisa atualizar clientes órfãos
-- 5. Execute os TESTES para verificar
-- 6. Teste no frontend
--
-- IMPORTANTE: Mantenha o RLS ATIVO para segurança!
-- =====================================================

-- ✅ VERIFICAÇÃO FINAL
SELECT 
    'STATUS FINAL' as info,
    (SELECT COUNT(*) FROM clientes WHERE user_id = auth.uid()) as meus_clientes,
    (SELECT COUNT(*) FROM clientes WHERE user_id IS NULL) as clientes_orfaos,
    (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'clientes') as politicas_ativas,
    (SELECT rowsecurity FROM pg_tables WHERE tablename = 'clientes') as rls_ativo;
