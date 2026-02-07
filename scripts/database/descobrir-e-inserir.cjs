const fs = require('fs');
const path = require('path');

console.log('🔍 Criando SQL que descobre a estrutura e insere corretamente...');

// Ler o backup original
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
const backup = backupData.data.products;
const categories = backupData.data.categories;

const USER_ID = backup[0].user_id;
console.log(`👤 User ID: ${USER_ID}`);

// SQL que primeiro descobre a estrutura e depois insere
let sql = `-- DESCOBRIR estrutura e inserir produtos corretamente
-- User ID: ${USER_ID}

-- 1. Descobrir estrutura da tabela produtos
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'produtos' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Descobrir estrutura da tabela categorias  
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'categorias' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Ver produtos que já existem para entender a estrutura
SELECT * FROM public.produtos LIMIT 3;

-- 4. TENTATIVA 1: Inserir categorias (estrutura básica)
INSERT INTO public.categorias (id, nome) VALUES
`;

// Adicionar algumas categorias para teste
const firstCategories = categories.slice(0, 5);
firstCategories.forEach((categoria, index) => {
  const isLast = index === firstCategories.length - 1;
  const nome = categoria.name.replace(/'/g, "''");
  
  sql += `('${categoria.id}', '${nome}')`;
  
  if (!isLast) {
    sql += ',\n';
  } else {
    sql += '\n';
  }
});

sql += `
ON CONFLICT (id) DO NOTHING;

-- 5. TENTATIVA 2: Inserir produtos (SEM user_id primeiro)
INSERT INTO public.produtos (id, nome, preco) VALUES
`;

// Adicionar alguns produtos para teste
const firstProducts = backup.slice(0, 5);
firstProducts.forEach((produto, index) => {
  const isLast = index === firstProducts.length - 1;
  const nome = produto.name.replace(/'/g, "''");
  
  sql += `('${produto.id}', '${nome}', ${produto.sale_price})`;
  
  if (!isLast) {
    sql += ',\n';
  } else {
    sql += '\n';
  }
});

sql += `
ON CONFLICT (id) DO NOTHING;

-- 6. Verificar se funcionou
SELECT COUNT(*) as total_produtos FROM public.produtos;
SELECT * FROM public.produtos ORDER BY nome LIMIT 10;
`;

// Salvar arquivo
const outputPath = path.join(__dirname, 'DESCOBRIR_E_INSERIR.sql');
fs.writeFileSync(outputPath, sql);

console.log(`✅ Arquivo salvo: DESCOBRIR_E_INSERIR.sql`);
console.log(`
🎯 Este arquivo vai:
1. Mostrar a estrutura EXATA das tabelas
2. Ver os produtos que já existem
3. Tentar inserir 5 categorias e 5 produtos de teste
4. Se funcionar, sabemos a estrutura correta!

Execute este arquivo e me diga o resultado!
`);
