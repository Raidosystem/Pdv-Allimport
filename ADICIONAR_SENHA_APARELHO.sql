-- ============================================
-- ADICIONAR CAMPO SENHA_APARELHO
-- ============================================
-- Este script adiciona o campo senha_aparelho 
-- para armazenar as senhas dos aparelhos nas OS
-- ============================================

-- Verificar se a coluna já existe antes de adicionar
DO $$ 
BEGIN
    -- Adicionar coluna senha_aparelho se não existir
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'ordens_servico' 
        AND column_name = 'senha_aparelho'
    ) THEN
        ALTER TABLE ordens_servico 
        ADD COLUMN senha_aparelho JSONB DEFAULT NULL;
        
        RAISE NOTICE '✅ Coluna senha_aparelho adicionada com sucesso!';
    ELSE
        RAISE NOTICE '⚠️  Coluna senha_aparelho já existe!';
    END IF;
    
    RAISE NOTICE '✅ Script executado com sucesso!';
END $$;

-- Comentário explicativo
COMMENT ON COLUMN ordens_servico.senha_aparelho IS 
'Armazena informações sobre a senha do aparelho em formato JSON: 
{
  "tipo": "nenhuma" | "texto" | "pin" | "desenho",
  "valor": string com a senha ou base64 do desenho
}';

-- Verificar estrutura
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'ordens_servico'
AND column_name = 'senha_aparelho';

