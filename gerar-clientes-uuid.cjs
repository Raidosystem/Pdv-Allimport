const fs = require('fs');

console.log('🚀 GERADOR DE SQL - CLIENTES COM UUID CORRETO');

try {
  // Ler o arquivo de backup dos clientes
  const backupPath = 'c:/Users/crism/Desktop/backup/backup-limpo-clients.json';
  const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
  
  console.log(`📊 Total de clientes encontrados: ${backupData.total_records}`);
  
  // Mapeamento dos campos do backup para os campos do sistema
  const mapearCampos = (cliente) => {
    return {
      id: cliente.id,
      user_id: cliente.user_id,
      nome: cliente.name,           // name -> nome
      cpf_cnpj: cliente.cpf_cnpj,
      telefone: cliente.phone,      // phone -> telefone  
      email: cliente.email,
      endereco: cliente.address,    // address -> endereco
      cidade: cliente.city,
      estado: cliente.state,
      cep: cliente.zip_code,        // zip_code -> cep
      ativo: true,                  // sempre ativo
      criado_em: cliente.created_at,
      atualizado_em: cliente.updated_at
    };
  };

  // Gerar SQL INSERT completo
  let sqlContent = `-- 📋 INSERÇÃO COMPLETA DE CLIENTES - ${backupData.total_records} clientes
-- Execute este script no Supabase SQL Editor
-- Sistema: ${backupData.description} 
-- Data do backup: ${backupData.exported_date}
-- Campos mapeados: nome, telefone, endereco, cidade, cep
-- UUIDs convertidos corretamente

-- =====================================================
-- VERIFICAR ANTES DA INSERÇÃO
-- =====================================================
SELECT 'CLIENTES ATUAIS:' as info, COUNT(*) as total FROM public.clientes;

-- =====================================================
-- INSERIR TODOS OS ${backupData.total_records} CLIENTES (COM UUID)
-- =====================================================

INSERT INTO public.clientes (
    id, user_id, nome, cpf_cnpj, telefone, email, endereco, 
    cidade, estado, cep, ativo, criado_em, atualizado_em
) 
SELECT 
    id::uuid, user_id::uuid, nome, cpf_cnpj, telefone, email, endereco, 
    cidade, estado, cep, ativo, criado_em::timestamptz, atualizado_em::timestamptz
FROM (VALUES 
`;

  // Gerar VALUES para cada cliente
  const clientValues = backupData.data.map((cliente, index) => {
    const clienteMapeado = mapearCampos(cliente);
    const isLast = index === backupData.data.length - 1;
    
    // Escapar aspas simples e tratar valores nulos
    const escape = (value) => {
      if (!value || value === '') return "''";
      return "'" + String(value).replace(/'/g, "''") + "'";
    };
    
    const formatDate = (dateStr) => {
      if (!dateStr) return 'NOW()';
      return "'" + dateStr + "'";
    };
    
    return `-- Cliente ${index + 1}: ${clienteMapeado.nome}
(${escape(clienteMapeado.id)}, ${escape(clienteMapeado.user_id)}, ${escape(clienteMapeado.nome)}, ${escape(clienteMapeado.cpf_cnpj)}, ${escape(clienteMapeado.telefone)}, ${escape(clienteMapeado.email)}, ${escape(clienteMapeado.endereco)}, ${escape(clienteMapeado.cidade)}, ${escape(clienteMapeado.estado)}, ${escape(clienteMapeado.cep)}, ${clienteMapeado.ativo}, ${formatDate(clienteMapeado.criado_em)}, ${formatDate(clienteMapeado.atualizado_em)})${isLast ? '' : ','}`;
  }).join('\n');

  sqlContent += clientValues;

  sqlContent += `
) AS dados(id, user_id, nome, cpf_cnpj, telefone, email, endereco, cidade, estado, cep, ativo, criado_em, atualizado_em)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- VERIFICAR APÓS INSERÇÃO  
-- =====================================================

SELECT 'INSERÇÃO CONCLUÍDA! ✅' as resultado;
SELECT 'TOTAL DE CLIENTES:' as info, COUNT(*) as total FROM public.clientes;

-- Mostrar alguns clientes inseridos
SELECT 'PRIMEIROS 10 CLIENTES:' as info;
SELECT nome, telefone, cidade, estado FROM public.clientes ORDER BY nome LIMIT 10;

-- Mostrar clientes por cidade
SELECT 'CLIENTES POR CIDADE:' as info;
SELECT cidade, COUNT(*) as total FROM public.clientes 
WHERE cidade != '' AND cidade IS NOT NULL 
GROUP BY cidade ORDER BY total DESC LIMIT 10;

-- Mostrar distribuição por estado
SELECT 'CLIENTES POR ESTADO:' as info;
SELECT estado, COUNT(*) as total FROM public.clientes 
WHERE estado != '' AND estado IS NOT NULL 
GROUP BY estado ORDER BY total DESC;

SELECT '🎉 TODOS OS ${backupData.total_records} CLIENTES FORAM INSERIDOS COM SUCESSO!' as final;
`;

  // Salvar arquivo SQL completo
  const outputPath = 'INSERIR_CLIENTES_UUID_CORRETO.sql';
  fs.writeFileSync(outputPath, sqlContent, 'utf8');
  
  console.log(`✅ Arquivo SQL gerado: ${outputPath}`);
  console.log(`📝 ${backupData.total_records} clientes com UUID correto`);
  console.log(`🎯 Execute este arquivo no Supabase SQL Editor`);
  
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
