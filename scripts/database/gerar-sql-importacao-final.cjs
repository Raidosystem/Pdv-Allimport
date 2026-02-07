const fs = require('fs');
const path = require('path');

// =====================================================
// GERAR SQL PARA IMPORTAR CLIENTES DO BACKUP
// =====================================================

const EMPRESA_ID = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';
const USER_ID = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'; // Mesmo ID para user_id

console.log('📦 Lendo backup...');
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backup = JSON.parse(fs.readFileSync(backupPath, 'utf8'));

const clientes = backup.data?.clients || []; // CORRIGIDO: clients, não clientes
console.log(`✅ Encontrados ${clientes.length} clientes no backup`);

// Filtrar apenas clientes válidos
const clientesValidos = clientes.filter(c => c.name && c.name.trim());
console.log(`✅ ${clientesValidos.length} clientes válidos para importar`);

// Gerar SQL
let sql = `-- =====================================================
-- IMPORTAR ${clientesValidos.length} CLIENTES DO BACKUP
-- =====================================================
-- Empresa: assistenciaallimport10@gmail.com
-- empresa_id: ${EMPRESA_ID}
-- user_id: ${USER_ID}

-- Desabilitar triggers temporariamente
SET session_replication_role = replica;

`;

// Limpar clientes existentes da empresa (mantendo ordens de serviço)
sql += `-- 1. LIMPAR CLIENTES ANTIGOS DESTA EMPRESA
-- (Apenas os que NÃO têm ordens de serviço)
DELETE FROM clientes 
WHERE empresa_id = '${EMPRESA_ID}'
  AND id NOT IN (
    SELECT DISTINCT cliente_id 
    FROM ordens_servico 
    WHERE cliente_id IS NOT NULL
  );

`;

sql += `-- 2. INSERIR CLIENTES DO BACKUP\n`;

clientesValidos.forEach((cliente, index) => {
  const nome = (cliente.name || '').replace(/'/g, "''");
  const telefone = cliente.phone || null;
  const cpf_cnpj = cliente.cpf_cnpj || null;
  const cpf_digits = cpf_cnpj ? cpf_cnpj.replace(/\D/g, '') : null;
  const email = cliente.email ? cliente.email.replace(/'/g, "''") : null;
  const endereco = cliente.address ? cliente.address.replace(/'/g, "''") : null;
  const bairro = null; // Não tem no backup
  const cidade = cliente.city ? cliente.city.replace(/'/g, "''") : null;
  const estado = cliente.state || null;
  const cep = cliente.zip_code || null;
  const observacoes = null; // Não tem no backup
  const ativo = true; // Todos ativos por padrão
  
  sql += `INSERT INTO clientes (
  empresa_id,
  user_id,
  nome,
  telefone,
  cpf_cnpj,
  cpf_digits,
  email,
  endereco,
  bairro,
  cidade,
  estado,
  cep,
  observacoes,
  ativo,
  created_at
) VALUES (
  '${EMPRESA_ID}',
  '${USER_ID}',
  '${nome}',
  ${telefone ? `'${telefone}'` : 'NULL'},
  ${cpf_cnpj ? `'${cpf_cnpj}'` : 'NULL'},
  ${cpf_digits ? `'${cpf_digits}'` : 'NULL'},
  ${email ? `'${email}'` : 'NULL'},
  ${endereco ? `'${endereco}'` : 'NULL'},
  ${bairro ? `'${bairro}'` : 'NULL'},
  ${cidade ? `'${cidade}'` : 'NULL'},
  ${estado ? `'${estado}'` : 'NULL'},
  ${cep ? `'${cep}'` : 'NULL'},
  ${observacoes ? `'${observacoes}'` : 'NULL'},
  ${ativo},
  NOW()
)
ON CONFLICT (empresa_id, cpf_digits) 
DO UPDATE SET
  nome = EXCLUDED.nome,
  telefone = EXCLUDED.telefone,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  email = EXCLUDED.email,
  endereco = EXCLUDED.endereco,
  bairro = EXCLUDED.bairro,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  observacoes = EXCLUDED.observacoes,
  user_id = '${USER_ID}',
  ativo = EXCLUDED.ativo,
  updated_at = NOW();

`;

  if ((index + 1) % 10 === 0) {
    console.log(`  Processados ${index + 1}/${clientesValidos.length} clientes...`);
  }
});

sql += `
-- Reabilitar triggers
SET session_replication_role = DEFAULT;

-- 3. VERIFICAR IMPORTAÇÃO
SELECT 
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
  COUNT(telefone) as com_telefone,
  COUNT(cpf_cnpj) as com_cpf_cnpj,
  COUNT(user_id) as com_user_id
FROM clientes 
WHERE empresa_id = '${EMPRESA_ID}';

-- 4. VERIFICAR AMOSTRA
SELECT 
  id,
  nome,
  telefone,
  cpf_cnpj,
  email,
  ativo,
  user_id,
  empresa_id
FROM clientes 
WHERE empresa_id = '${EMPRESA_ID}'
  AND ativo = true
ORDER BY created_at DESC
LIMIT 10;

-- =====================================================
-- RESULTADO ESPERADO:
-- - ${clientesValidos.length} clientes importados
-- - Todos com user_id e empresa_id corretos
-- - RLS vai permitir acesso porque auth.uid() = user_id
-- =====================================================
`;

const outputPath = path.join(__dirname, 'IMPORTAR-CLIENTES-FINAL.sql');
fs.writeFileSync(outputPath, sql);

console.log(`\n✅ SQL gerado com sucesso!`);
console.log(`📄 Arquivo: ${outputPath}`);
console.log(`📊 Total de clientes: ${clientesValidos.length}`);
console.log(`\n🚀 Execute este SQL no Supabase SQL Editor!`);
