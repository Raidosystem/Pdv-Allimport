const fs = require('fs');
const path = require('path');

console.log('🚀 GERADOR DE SQL - INSERINDO TODOS OS CLIENTES DO BACKUP');

try {
  // Ler o arquivo de backup dos clientes
  const backupPath = 'c:/Users/crism/Desktop/backup/backup-limpo-clients.json';
  const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
  
  console.log(`📊 Total de clientes encontrados: ${backupData.total_records}`);
  
  // Gerar SQL INSERT completo
  let sqlContent = `-- 📋 INSERÇÃO COMPLETA DE CLIENTES - ${backupData.total_records} clientes do backup
-- Execute este script no Supabase SQL Editor
-- Sistema: ${backupData.description}
-- Data do backup: ${backupData.exported_date}

-- =====================================================
-- VERIFICAR ANTES DA INSERÇÃO
-- =====================================================
SELECT 'CLIENTES ATUAIS:' as info, COUNT(*) as total FROM public.clientes;

-- =====================================================
-- INSERIR TODOS OS ${backupData.total_records} CLIENTES
-- =====================================================

INSERT INTO public.clientes (
    id, user_id, name, cpf_cnpj, phone, email, address, 
    city, state, zip_code, birth_date, created_at, updated_at
) VALUES 
`;

  // Gerar VALUES para cada cliente
  const clientValues = backupData.data.map((client, index) => {
    const isLast = index === backupData.data.length - 1;
    
    // Escapar aspas simples e tratar valores nulos
    const escape = (value) => {
      if (!value || value === '') return "''";
      return "'" + String(value).replace(/'/g, "''") + "'";
    };
    
    const formatDate = (dateStr) => {
      if (!dateStr) return 'NULL';
      return "'" + dateStr + "'";
    };
    
    return `-- Cliente ${index + 1}: ${client.name}
(${escape(client.id)}, ${escape(client.user_id)}, ${escape(client.name)}, ${escape(client.cpf_cnpj)}, ${escape(client.phone)}, ${escape(client.email)}, ${escape(client.address)}, ${escape(client.city)}, ${escape(client.state)}, ${escape(client.zip_code)}, ${formatDate(client.birth_date)}, ${formatDate(client.created_at)}, ${formatDate(client.updated_at)})${isLast ? ';' : ','}`;
  }).join('\n');

  sqlContent += clientValues;

  sqlContent += `

-- =====================================================
-- VERIFICAR APÓS INSERÇÃO
-- =====================================================

SELECT 'INSERÇÃO CONCLUÍDA! ✅' as resultado;
SELECT 'TOTAL DE CLIENTES:' as info, COUNT(*) as total FROM public.clientes;

-- Mostrar alguns clientes inseridos
SELECT 'PRIMEIROS 10 CLIENTES:' as info;
SELECT name, phone, city, state FROM public.clientes ORDER BY name LIMIT 10;

-- Mostrar clientes por cidade
SELECT 'CLIENTES POR CIDADE:' as info;
SELECT city, COUNT(*) as total FROM public.clientes 
WHERE city != '' GROUP BY city ORDER BY total DESC LIMIT 10;

SELECT '🎉 TODOS OS ${backupData.total_records} CLIENTES FORAM INSERIDOS COM SUCESSO!' as final;
`;

  // Salvar arquivo SQL completo
  const outputPath = 'INSERIR_TODOS_CLIENTES_COMPLETO.sql';
  fs.writeFileSync(outputPath, sqlContent, 'utf8');
  
  console.log(`✅ Arquivo SQL gerado: ${outputPath}`);
  console.log(`📝 ${backupData.total_records} clientes prontos para inserção`);
  console.log(`🎯 Execute este arquivo no Supabase SQL Editor para inserir todos os clientes`);
  
  // Mostrar estatísticas dos clientes
  const cities = {};
  const states = {};
  
  backupData.data.forEach(client => {
    if (client.city) {
      cities[client.city] = (cities[client.city] || 0) + 1;
    }
    if (client.state) {
      states[client.state] = (states[client.state] || 0) + 1;
    }
  });
  
  console.log('\n📊 ESTATÍSTICAS DOS CLIENTES:');
  console.log('Top 5 cidades:', Object.entries(cities).sort((a,b) => b[1]-a[1]).slice(0,5));
  console.log('Estados:', Object.entries(states).sort((a,b) => b[1]-a[1]));
  
} catch (error) {
  console.error('❌ Erro:', error.message);
}
