-- ====================================================================
-- CORREÇÃO SIMPLIFICADA: ERRO 400 AO BUSCAR VENDAS_ITENS
-- ====================================================================
-- Execute este script PASSO A PASSO no SQL Editor do Supabase
-- ====================================================================

-- ====================================================================
-- PASSO 1: DIAGNÓSTICO INICIAL
-- ====================================================================

-- 1.1 Verificar estrutura da tabela vendas_itens
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'vendas_itens'
ORDER BY ordinal_position;

-- 1.2 Verificar políticas RLS atuais
SELECT policyname, cmd
FROM pg_policies
WHERE tablename = 'vendas_itens';

-- 1.3 Testar se consegue buscar dados diretos
SELECT COUNT(*) as total_itens FROM vendas_itens;

-- ====================================================================
-- PASSO 2: ADICIONAR COLUNA user_id (se não existir)
-- ====================================================================

ALTER TABLE vendas_itens
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- ====================================================================
-- PASSO 3: PREENCHER user_id COM DADOS DA TABELA vendas
-- ====================================================================

-- Atualizar todos os registros existentes
UPDATE vendas_itens vi
SET user_id = v.user_id
FROM vendas v
WHERE vi.venda_id = v.id
AND vi.user_id IS NULL;

-- Verificar quantos foram atualizados
SELECT 
    COUNT(*) as total,
    COUNT(user_id) as com_user_id,
    COUNT(*) - COUNT(user_id) as sem_user_id
FROM vendas_itens;

-- ====================================================================
-- PASSO 4: REMOVER POLÍTICAS ANTIGAS
-- ====================================================================

DROP POLICY IF EXISTS "Usuários podem ver itens de suas vendas" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_select" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_acesso_total_select" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_user_select" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_user_insert" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_user_update" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_user_delete" ON vendas_itens;

-- ====================================================================
-- PASSO 5: CRIAR NOVAS POLÍTICAS SIMPLES
-- ====================================================================

-- Política SELECT: Ver apenas itens de suas próprias vendas
CREATE POLICY "vendas_itens_select"
ON vendas_itens
FOR SELECT
USING (user_id = auth.uid());

-- Política INSERT: Inserir apenas com seu user_id
CREATE POLICY "vendas_itens_insert"
ON vendas_itens
FOR INSERT
WITH CHECK (user_id = auth.uid());

-- Política UPDATE: Atualizar apenas seus próprios itens
CREATE POLICY "vendas_itens_update"
ON vendas_itens
FOR UPDATE
USING (user_id = auth.uid());

-- Política DELETE: Deletar apenas seus próprios itens
CREATE POLICY "vendas_itens_delete"
ON vendas_itens
FOR DELETE
USING (user_id = auth.uid());

-- ====================================================================
-- PASSO 6: CRIAR TRIGGER PARA AUTO-PREENCHER user_id
-- ====================================================================

-- Função que pega user_id da venda automaticamente
CREATE OR REPLACE FUNCTION sync_vendas_itens_user_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Ao inserir item, pegar user_id da venda pai
    IF NEW.user_id IS NULL THEN
        SELECT user_id INTO NEW.user_id
        FROM vendas
        WHERE id = NEW.venda_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Remover trigger antigo se existir
DROP TRIGGER IF EXISTS trigger_sync_vendas_itens_user_id ON vendas_itens;

-- Criar trigger novo
CREATE TRIGGER trigger_sync_vendas_itens_user_id
BEFORE INSERT ON vendas_itens
FOR EACH ROW
EXECUTE FUNCTION sync_vendas_itens_user_id();

-- ====================================================================
-- PASSO 7: VALIDAÇÃO FINAL
-- ====================================================================

-- Verificar políticas criadas
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename = 'vendas_itens'
ORDER BY cmd, policyname;

-- Testar query como se fosse o frontend
SELECT 
    vi.id,
    vi.venda_id,
    vi.produto_id,
    vi.quantidade,
    vi.subtotal,
    vi.user_id,
    p.nome AS produto_nome
FROM vendas_itens vi
LEFT JOIN produtos p ON p.id = vi.produto_id
WHERE vi.user_id = auth.uid()
LIMIT 5;

-- Verificar se há itens sem user_id (não deveria ter nenhum)
SELECT COUNT(*) as itens_sem_user_id
FROM vendas_itens
WHERE user_id IS NULL;

-- ====================================================================
-- PASSO 8: CRIAR ÍNDICE PARA PERFORMANCE
-- ====================================================================

-- Índice simples em user_id
CREATE INDEX IF NOT EXISTS idx_vendas_itens_user_id 
ON vendas_itens(user_id);

-- Índice composto para queries complexas
CREATE INDEX IF NOT EXISTS idx_vendas_itens_venda_user 
ON vendas_itens(venda_id, user_id);

-- Índice para buscar por produto
CREATE INDEX IF NOT EXISTS idx_vendas_itens_produto 
ON vendas_itens(produto_id);

-- ====================================================================
-- RESULTADO ESPERADO
-- ====================================================================

/*
✅ APÓS EXECUTAR ESTE SCRIPT:

1. Coluna user_id criada e preenchida
2. Políticas RLS simples e funcionais
3. Trigger automático para novos registros
4. Índices para melhor performance
5. Frontend deve buscar vendas_itens sem erro 400

TESTE NO FRONTEND:
- Abrir DevTools → Console
- Ir em Relatórios
- Verificar se carrega sem erro
- Verificar se os totais aparecem (R$ 174,90 em vez de R$ 0,00)
*/
