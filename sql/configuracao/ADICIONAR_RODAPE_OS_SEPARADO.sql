-- =====================================================
-- ADICIONAR COLUNAS DE RODAPÉ SEPARADO PARA ORDEM DE SERVIÇO
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- Adicionar colunas de rodapé específicas para Ordem de Serviço
ALTER TABLE configuracoes_impressao 
  ADD COLUMN IF NOT EXISTS rodape_os_linha1 TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS rodape_os_linha2 TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS rodape_os_linha3 TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS rodape_os_linha4 TEXT DEFAULT '';

-- Copiar dados atuais do rodapé geral para o rodapé de OS (migração inicial)
-- Isso garante que quem já tinha rodapé configurado não perca os dados
-- NOTA: A garantia de meses NÃO fica no rodapé de OS (é dinâmica, definida ao encerrar cada OS)
UPDATE configuracoes_impressao 
SET 
  rodape_os_linha1 = COALESCE(rodape_linha2, ''),
  rodape_os_linha2 = COALESCE(rodape_linha3, ''),
  rodape_os_linha3 = COALESCE(rodape_linha4, ''),
  rodape_os_linha4 = ''
WHERE rodape_os_linha1 IS NULL OR rodape_os_linha1 = '';

-- Atualizar o rodapé de vendas com valores padrão mais adequados
-- (apenas para quem ainda não tem rodapé de vendas personalizado)
-- NOTA: Comente esta seção se não quiser alterar o rodapé de vendas existente
-- UPDATE configuracoes_impressao 
-- SET 
--   rodape_linha1 = 'Obrigado pela preferência!',
--   rodape_linha2 = 'Volte sempre!',
--   rodape_linha3 = '',
--   rodape_linha4 = ''
-- WHERE rodape_linha1 = rodape_os_linha1;

-- Verificar resultado
SELECT 
  user_id,
  rodape_linha1 AS "Rodapé Vendas L1",
  rodape_linha2 AS "Rodapé Vendas L2",
  rodape_os_linha1 AS "Rodapé OS L1",
  rodape_os_linha2 AS "Rodapé OS L2",
  atualizado_em
FROM configuracoes_impressao
ORDER BY atualizado_em DESC
LIMIT 10;
