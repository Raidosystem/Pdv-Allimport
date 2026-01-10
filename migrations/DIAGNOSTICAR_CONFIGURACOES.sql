-- ============================================================================
-- DIAGNÓSTICO: Verificar estrutura e dados de configuracoes_impressao
-- ============================================================================

-- 1. ESTRUTURA DA TABELA
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'configuracoes_impressao' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. DADOS DO USUÁRIO
-- Substitua 'SEU_USER_ID' pelo user_id do console (f7fdf4cf-7101-45ab-86db-5248a7ac58c1)
SELECT 
    user_id,
    LENGTH(cabecalho) as len_cabecalho,
    LENGTH(cabecalho_personalizado) as len_cabecalho_personalizado,
    cabecalho,
    cabecalho_personalizado,
    rodape_linha1,
    rodape_linha2,
    rodape_linha3,
    rodape_linha4,
    atualizado_em,
    criado_em
FROM configuracoes_impressao
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 3. ÍNDICES E CONSTRAINTS
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'configuracoes_impressao';
