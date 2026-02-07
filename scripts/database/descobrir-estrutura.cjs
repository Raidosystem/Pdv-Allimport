const fs = require('fs');
const path = require('path');

console.log('🔍 Vamos descobrir a estrutura EXATA da tabela que funciona...');

// Ler o backup original
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
const backup = backupData.data.products;

const USER_ID = backup[0].user_id;
console.log(`👤 User ID: ${USER_ID}`);
console.log(`📦 Total de produtos no backup: ${backup.length}`);

// Gerar SQL que APENAS adiciona produtos na estrutura mínima
// Vamos descobrir quais colunas funcionam testando uma por vez

const sql = `-- TESTE: Inserir apenas 1 produto para descobrir estrutura
-- Se este funcionar, usamos a mesma estrutura para todos os 813

-- VERSÃO 1: Apenas colunas mais básicas possíveis
INSERT INTO public.produtos (
  id,
  user_id,
  nome,
  preco
) VALUES
('TEST-001', '${USER_ID}', 'PRODUTO TESTE', 10.00)
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
('TEST-002', '${USER_ID}', 'PRODUTO TESTE 2', '123456', 20.00)
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
('TEST-003', '${USER_ID}', 'PRODUTO TESTE 3', '92a8c722-5727-4657-b834-0a6a07e3b1b1', 30.00)
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
`;

// Salvar arquivo de teste
const outputPath = path.join(__dirname, 'TESTE_ESTRUTURA_PRODUTOS.sql');
fs.writeFileSync(outputPath, sql);

console.log(`✅ Arquivo de teste salvo em: TESTE_ESTRUTURA_PRODUTOS.sql`);
console.log(`
🎯 INSTRUÇÕES:

1. Execute este arquivo SQL no Supabase
2. Veja qual versão funciona (1, 2 ou 3)
3. Me informe qual funcionou
4. Vou gerar o arquivo final com todos os 813 produtos

O arquivo também mostra a estrutura completa da tabela produtos!
`);
