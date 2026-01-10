-- ============================================
-- CORREÇÃO SEGURA - APENAS CONFIGURAÇÕES DE IMPRESSÃO
-- ============================================
-- ✅ SEGURO: Não afeta outras tabelas
-- ✅ SEGURO: Usa IF EXISTS para não quebrar se já existir
-- ✅ SEGURO: Usa transação para reverter se der erro
-- ============================================

BEGIN;

-- 1. Verificar se a tabela existe (não cria se não existir)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'configuracoes_impressao'
    ) THEN
        RAISE EXCEPTION '❌ Tabela configuracoes_impressao não existe! Não é seguro criar agora.';
    END IF;
    
    RAISE NOTICE '✅ Tabela configuracoes_impressao existe';
END $$;

-- 2. APENAS remover e recriar políticas RLS para configuracoes_impressao
-- (Não afeta outras tabelas)
DROP POLICY IF EXISTS "users_own_config_select" ON configuracoes_impressao;
DROP POLICY IF EXISTS "users_own_config_insert" ON configuracoes_impressao;
DROP POLICY IF EXISTS "users_own_config_update" ON configuracoes_impressao;
DROP POLICY IF EXISTS "users_own_config_delete" ON configuracoes_impressao;

-- 3. Garantir que RLS está habilitado APENAS nesta tabela
ALTER TABLE configuracoes_impressao ENABLE ROW LEVEL SECURITY;

-- 4. Criar políticas novas APENAS para configuracoes_impressao
CREATE POLICY "users_own_config_select" ON configuracoes_impressao
FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "users_own_config_insert" ON configuracoes_impressao
FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_own_config_update" ON configuracoes_impressao
FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_own_config_delete" ON configuracoes_impressao
FOR DELETE USING (user_id = auth.uid());

-- 5. Criar índice UNIQUE se não existir (evita duplicatas)
DROP INDEX IF EXISTS configuracoes_impressao_user_id_idx;
CREATE UNIQUE INDEX configuracoes_impressao_user_id_idx ON configuracoes_impressao(user_id);

-- 6. Verificar se funcionou
SELECT 
    '✅ VERIFICAÇÃO FINAL' as status,
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename = 'configuracoes_impressao'
ORDER BY policyname;

-- 7. Se chegou aqui sem erro, commitar
COMMIT;

-- ============================================
-- INSTRUÇÕES DE USO:
-- ============================================
-- 1. Execute este SQL no SQL Editor do Supabase
-- 2. Se der QUALQUER erro, será REVERTIDO automaticamente (ROLLBACK)
-- 3. Se der sucesso, você verá mensagens "✅" no final
-- 4. Outras tabelas NÃO serão afetadas
-- ============================================

-- TESTE FINAL (executar separadamente após o SQL acima)
-- Descomente e execute apenas se o SQL acima funcionou:
/*
-- Teste de inserção
INSERT INTO configuracoes_impressao (
    user_id,
    cabecalho_personalizado,
    rodape_linha1
)
VALUES (
    auth.uid(),
    'TESTE - Cabeçalho',
    'TESTE - Rodapé'
)
ON CONFLICT (user_id) DO UPDATE SET
    cabecalho_personalizado = EXCLUDED.cabecalho_personalizado,
    atualizado_em = now();

-- Ver resultado
SELECT * FROM configuracoes_impressao WHERE user_id = auth.uid();
*/
