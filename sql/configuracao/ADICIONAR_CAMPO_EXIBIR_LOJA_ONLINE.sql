-- 🛍️ ADICIONAR CAMPO PARA CONTROLAR EXIBIÇÃO NA LOJA ONLINE

-- 1. Adicionar coluna exibir_loja_online na tabela produtos
ALTER TABLE produtos 
ADD COLUMN IF NOT EXISTS exibir_loja_online BOOLEAN DEFAULT true;

-- 2. Atualizar produtos existentes para exibir por padrão
UPDATE produtos 
SET exibir_loja_online = true 
WHERE exibir_loja_online IS NULL;

-- 3. Verificar coluna criada
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'produtos'
AND column_name = 'exibir_loja_online';

-- 4. Testar: Contar produtos que aparecem na loja
SELECT 
    COUNT(*) as total_produtos,
    SUM(CASE WHEN exibir_loja_online = true THEN 1 ELSE 0 END) as exibir_loja,
    SUM(CASE WHEN exibir_loja_online = false THEN 1 ELSE 0 END) as nao_exibir
FROM produtos
WHERE ativo = true;
