-- =====================================================
-- VERIFICAR E CRIAR LOJA ONLINE PARA USUÁRIO
-- =====================================================

-- 1. Verificar se existe registro
SELECT * FROM lojas_online 
WHERE empresa_id = '8adef71b-1cde-47f2-baa5-a4b25fd71b73';

-- 2. Se não existir, criar um registro padrão
INSERT INTO lojas_online (
  empresa_id,
  slug,
  nome,
  ativa,
  whatsapp,
  logo_url,
  cor_primaria,
  cor_secundaria,
  descricao,
  mostrar_preco,
  mostrar_estoque,
  permitir_carrinho,
  calcular_frete,
  permitir_retirada
)
VALUES (
  '8adef71b-1cde-47f2-baa5-a4b25fd71b73',  -- empresa_id
  'juliano-ramos',                          -- slug único
  'Juliano Ramos',                          -- nome da loja
  false,                                    -- ativa (inicialmente desativada)
  '',                                       -- whatsapp (vazio por enquanto)
  '',                                       -- logo_url (vazio por enquanto)
  '#3B82F6',                               -- cor primária (azul)
  '#10B981',                               -- cor secundária (verde)
  'Loja online de Juliano Ramos',         -- descrição
  true,                                     -- mostrar_preco
  false,                                    -- mostrar_estoque
  true,                                     -- permitir_carrinho
  false,                                    -- calcular_frete
  true                                      -- permitir_retirada
)
ON CONFLICT (empresa_id) DO NOTHING;  -- Não duplicar se já existir

-- 3. Verificar o resultado
SELECT * FROM lojas_online 
WHERE empresa_id = '8adef71b-1cde-47f2-baa5-a4b25fd71b73';

-- Mensagem de sucesso
DO $$
BEGIN
  RAISE NOTICE '✅ Registro criado/verificado na tabela lojas_online!';
END $$;
