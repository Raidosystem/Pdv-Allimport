-- ============================================================================
-- SINCRONIZAR: Copiar cabecalho para cabecalho_personalizado
-- ============================================================================
-- PROBLEMA: cabecalho tem edição recente (92 chars)
--           cabecalho_personalizado tem texto antigo (164 chars)
-- SOLUÇÃO: Copiar o valor mais recente para ambas as colunas
-- ============================================================================

BEGIN;

-- Atualizar cabecalho_personalizado com o valor de cabecalho
-- (porque cabecalho tem a edição mais recente)
UPDATE configuracoes_impressao
SET 
  cabecalho_personalizado = cabecalho,
  atualizado_em = NOW()
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND cabecalho IS NOT NULL
  AND LENGTH(cabecalho) > 0;

-- Verificar resultado
SELECT 
    user_id,
    LENGTH(cabecalho) as len_cabecalho,
    LENGTH(cabecalho_personalizado) as len_cabecalho_personalizado,
    cabecalho,
    cabecalho_personalizado,
    atualizado_em
FROM configuracoes_impressao
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

COMMIT;
