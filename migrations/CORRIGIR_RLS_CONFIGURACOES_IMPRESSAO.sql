-- ============================================
-- CORREÇÃO RLS - CONFIGURAÇÕES DE IMPRESSÃO
-- ============================================
-- Este script corrige as políticas RLS para permitir
-- que usuários salvem suas configurações de impressão

-- 1. Remover políticas antigas (se existirem)
DROP POLICY IF EXISTS "users_own_config_select" ON configuracoes_impressao;
DROP POLICY IF EXISTS "users_own_config_insert" ON configuracoes_impressao;
DROP POLICY IF EXISTS "users_own_config_update" ON configuracoes_impressao;
DROP POLICY IF EXISTS "users_own_config_delete" ON configuracoes_impressao;

-- 2. Habilitar RLS (se não estiver habilitado)
ALTER TABLE configuracoes_impressao ENABLE ROW LEVEL SECURITY;

-- 3. Criar políticas corretas

-- Permitir usuários verem suas próprias configurações
CREATE POLICY "users_own_config_select" ON configuracoes_impressao
FOR SELECT 
USING (user_id = auth.uid());

-- Permitir usuários inserirem suas próprias configurações
CREATE POLICY "users_own_config_insert" ON configuracoes_impressao
FOR INSERT 
WITH CHECK (user_id = auth.uid());

-- Permitir usuários atualizarem suas próprias configurações
CREATE POLICY "users_own_config_update" ON configuracoes_impressao
FOR UPDATE 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Permitir usuários deletarem suas próprias configurações (opcional)
CREATE POLICY "users_own_config_delete" ON configuracoes_impressao
FOR DELETE 
USING (user_id = auth.uid());

-- 4. Verificar se a tabela existe e tem a estrutura correta
DO $$ 
BEGIN
    -- Adicionar coluna user_id se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'configuracoes_impressao' 
        AND column_name = 'user_id'
    ) THEN
        ALTER TABLE configuracoes_impressao ADD COLUMN user_id UUID REFERENCES auth.users(id);
    END IF;

    -- Adicionar coluna atualizado_em se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'configuracoes_impressao' 
        AND column_name = 'atualizado_em'
    ) THEN
        ALTER TABLE configuracoes_impressao ADD COLUMN atualizado_em TIMESTAMPTZ DEFAULT now();
    END IF;

    -- Adicionar coluna criado_em se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'configuracoes_impressao' 
        AND column_name = 'criado_em'
    ) THEN
        ALTER TABLE configuracoes_impressao ADD COLUMN criado_em TIMESTAMPTZ DEFAULT now();
    END IF;
END $$;

-- 5. Garantir que user_id é UNIQUE (um usuário = uma configuração)
DROP INDEX IF EXISTS configuracoes_impressao_user_id_idx;
CREATE UNIQUE INDEX configuracoes_impressao_user_id_idx ON configuracoes_impressao(user_id);

-- 6. Verificar estrutura final
SELECT 
    '✅ Tabela configuracoes_impressao configurada!' as status,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'configuracoes_impressao'
ORDER BY ordinal_position;

-- 7. Verificar políticas
SELECT 
    '✅ Políticas RLS configuradas!' as status,
    policyname as "Política",
    cmd as "Comando",
    qual as "Condição"
FROM pg_policies
WHERE tablename = 'configuracoes_impressao';

-- 8. TESTE: Inserir uma configuração de teste para o usuário atual
-- (só funcionará se você executar logado)
INSERT INTO configuracoes_impressao (
    user_id,
    cabecalho_personalizado,
    rodape_linha1,
    rodape_linha2,
    rodape_linha3,
    rodape_linha4
)
VALUES (
    auth.uid(),
    'TESTE - Este é um cabeçalho de teste',
    'Linha 1 de teste',
    'Linha 2 de teste',
    'Linha 3 de teste',
    'Linha 4 de teste'
)
ON CONFLICT (user_id) DO UPDATE SET
    cabecalho_personalizado = EXCLUDED.cabecalho_personalizado,
    rodape_linha1 = EXCLUDED.rodape_linha1,
    rodape_linha2 = EXCLUDED.rodape_linha2,
    rodape_linha3 = EXCLUDED.rodape_linha3,
    rodape_linha4 = EXCLUDED.rodape_linha4,
    atualizado_em = now();

-- 9. Verificar se o teste funcionou
SELECT 
    '✅ Teste de inserção realizado!' as status,
    user_id,
    cabecalho_personalizado,
    rodape_linha1,
    atualizado_em
FROM configuracoes_impressao
WHERE user_id = auth.uid();

-- ============================================
-- INSTRUÇÕES:
-- ============================================
-- 1. Execute este SQL no SQL Editor do Supabase
-- 2. Certifique-se de estar logado (auth.uid() não pode ser null)
-- 3. Verifique os resultados das queries no final
-- 4. Se aparecer "TESTE - Este é um cabeçalho de teste", está funcionando!
-- 5. Volte ao sistema e edite novamente o cabeçalho
-- 6. Saia e entre novamente - deve estar salvo!
-- ============================================
