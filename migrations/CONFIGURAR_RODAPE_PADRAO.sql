-- ============================================
-- CONFIGURAR RODAPÉ PADRÃO PARA NOVOS USUÁRIOS
-- ============================================
-- Data: 2026-01-10
-- Descrição: Define valores padrão para o rodapé de recibos
--            que serão aplicados automaticamente para todos
--            os novos usuários que comprarem o sistema

-- ⚠️ IMPORTANTE: Leia antes de executar!
-- Este script tem 2 partes:
--   1. ALTER TABLE (100% SEGURO) - Define padrão para novos registros
--   2. UPDATE (OPCIONAL) - Atualiza registros existentes vazios
--
-- Você pode executar apenas a parte 1 se quiser ser extra cauteloso.

-- ==============================================
-- PARTE 1: DEFINIR DEFAULT (100% SEGURO)
-- ==============================================
-- Isso NÃO altera dados existentes, apenas define
-- o padrão para NOVOS registros futuros
ALTER TABLE configuracoes_impressao 
  ALTER COLUMN rodape_linha1 SET DEFAULT 'Garantia de produtos de 3 meses',
  ALTER COLUMN rodape_linha2 SET DEFAULT 'Será cobrado uma taxa de serviço de avaliação do aparelho de mínimo de 30,00',
  ALTER COLUMN rodape_linha3 SET DEFAULT 'A partir do quarto mês será cobrado uma multa diária de 1,00',
  ALTER COLUMN rodape_linha4 SET DEFAULT 'Agradecemos pela preferencia, Volte sempre';

-- ✅ Verificar que o DEFAULT foi aplicado
SELECT 
  column_name, 
  column_default
FROM information_schema.columns
WHERE table_name = 'configuracoes_impressao'
  AND column_name LIKE 'rodape_linha%'
ORDER BY column_name;


-- ==============================================
-- PARTE 2: ATUALIZAR REGISTROS EXISTENTES (OPCIONAL)
-- ==============================================
-- ⚠️ ATENÇÃO: Esta parte atualiza dados existentes!
-- Só execute se você quiser que usuários atuais também
-- tenham esse rodapé padrão (apenas os que estão vazios)

-- Primeiro, veja QUANTOS registros serão afetados:
SELECT COUNT(*) as registros_afetados
FROM configuracoes_impressao
WHERE 
  (rodape_linha1 IS NULL OR rodape_linha1 = '')
  AND (rodape_linha2 IS NULL OR rodape_linha2 = '')
  AND (rodape_linha3 IS NULL OR rodape_linha3 = '')
  AND (rodape_linha4 IS NULL OR rodape_linha4 = '');

-- Se você está confortável com o número acima, execute:
-- (Descomente as linhas abaixo para ativar)

/*
UPDATE configuracoes_impressao
SET 
  rodape_linha1 = 'Garantia de produtos de 3 meses',
  rodape_linha2 = 'Será cobrado uma taxa de serviço de avaliação do aparelho de mínimo de 30,00',
  rodape_linha3 = 'A partir do quarto mês será cobrado uma multa diária de 1,00',
  rodape_linha4 = 'Agradecemos pela preferencia, Volte sempre',
  atualizado_em = NOW()
WHERE 
  (rodape_linha1 IS NULL OR rodape_linha1 = '')
  AND (rodape_linha2 IS NULL OR rodape_linha2 = '')
  AND (rodape_linha3 IS NULL OR rodape_linha3 = '')
  AND (rodape_linha4 IS NULL OR rodape_linha4 = '');
*/

-- Verificar resultado final (últimos 10 registros)
SELECT 
  user_id,
  rodape_linha1,
  rodape_linha2,
  rodape_linha3,
  rodape_linha4,
  atualizado_em
FROM configuracoes_impressao
ORDER BY atualizado_em DESC
LIMIT 10;

