-- TESTE: Inserir apenas 1 produto para descobrir estrutura
-- Se este funcionar, usamos a mesma estrutura para todos os 813

-- VERSÃO 1: Apenas colunas mais básicas possíveis
INSERT INTO public.produtos (
  id,
  user_id,
  nome,
  preco
) VALUES
('TEST-001', '28e56a69-90df-4852-b663-9b02f4358c6f', 'PRODUTO TESTE', 10.00)
ON CONFLICT (id) DO UPDATE SET nome = EXCLUDED.nome;

-- Se der erro, comentar acima e tentar VERSÃO 2:
/*
INSERT INTO public.produtos (
  id,
  user_id,
  nome,
  codigo_barras,
  preco
) VALUES
('TEST-002', '28e56a69-90df-4852-b663-9b02f4358c6f', 'PRODUTO TESTE 2', '123456', 20.00)
ON CONFLICT (id) DO UPDATE SET nome = EXCLUDED.nome;
*/

-- Se der erro, comentar acima e tentar VERSÃO 3:
/*
INSERT INTO public.produtos (
  id,
  user_id,
  nome,
  categoria_id,
  preco
) VALUES
('TEST-003', '28e56a69-90df-4852-b663-9b02f4358c6f', 'PRODUTO TESTE 3', '92a8c722-5727-4657-b834-0a6a07e3b1b1', 30.00)
ON CONFLICT (id) DO UPDATE SET nome = EXCLUDED.nome;
*/

-- Verificar o que foi inserido
SELECT * FROM public.produtos WHERE nome LIKE '%TESTE%';

-- Verificar estrutura da tabela produtos
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'produtos' 
  AND table_schema = 'public'
ORDER BY ordinal_position;
