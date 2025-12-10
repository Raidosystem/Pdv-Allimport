-- ============================================
-- ADICIONAR CAMPO SENHA_APARELHO
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Adicionar coluna senha_aparelho se não existir
ALTER TABLE ordens_servico 
ADD COLUMN IF NOT EXISTS senha_aparelho JSONB DEFAULT NULL;

-- Comentário explicativo
COMMENT ON COLUMN ordens_servico.senha_aparelho IS 
'Armazena informações sobre a senha do aparelho em formato JSON: {"tipo": "texto|pin|desenho", "valor": "..."}';

-- Verificar se foi criado
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'ordens_servico'
AND column_name = 'senha_aparelho';
