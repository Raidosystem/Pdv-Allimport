// Verificação das tabelas do módulo Caixa - PDV Allimport
// Execute com: node verify-caixa-tables.js

const https = require('https');

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjI3MTI5MDcsImV4cCI6MjAzODI4ODkwN30.qrYZhwWMJvWVBMt-TgLYKR8PcKJOLTDVOcfkJRxQpPQ';

function makeRequest(path, method = 'GET', data = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'kmcaaqetxtwkdcczdomw.supabase.co',
      port: 443,
      path: path,
      method: method,
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'
      }
    };

    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const parsed = body ? JSON.parse(body) : {};
          resolve({ data: parsed, status: res.statusCode, error: null });
        } catch (e) {
          resolve({ data: null, status: res.statusCode, error: e.message });
        }
      });
    });

    req.on('error', (error) => {
      reject({ error: error.message });
    });

    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

async function verificarTabelasCaixa() {
  console.log('🔧 VERIFICANDO MÓDULO CAIXA - PDV ALLIMPORT');
  console.log('==========================================');
  console.log('');

  try {
    console.log('📋 Verificando tabela "caixa"...');
    
    // Testar tabela caixa
    const caixaTest = await makeRequest('/rest/v1/caixa?select=id&limit=1');
    
    if (caixaTest.status === 200) {
      console.log('✅ Tabela "caixa" existe!');
    } else if (caixaTest.status === 404 || (caixaTest.data && caixaTest.data.message && caixaTest.data.message.includes('does not exist'))) {
      console.log('❌ Tabela "caixa" NÃO existe');
      mostrarInstrucoes();
      return;
    } else {
      console.log('⚠️  Status tabela caixa:', caixaTest.status);
    }

    console.log('📋 Verificando tabela "movimentacoes_caixa"...');
    
    // Testar tabela movimentacoes_caixa
    const movTest = await makeRequest('/rest/v1/movimentacoes_caixa?select=id&limit=1');
    
    if (movTest.status === 200) {
      console.log('✅ Tabela "movimentacoes_caixa" existe!');
    } else if (movTest.status === 404 || (movTest.data && movTest.data.message && movTest.data.message.includes('does not exist'))) {
      console.log('❌ Tabela "movimentacoes_caixa" NÃO existe');
      mostrarInstrucoes();
      return;
    } else {
      console.log('⚠️  Status tabela movimentacoes_caixa:', movTest.status);
    }

    console.log('');
    console.log('🎉 TODAS AS TABELAS EXISTEM!');
    console.log('');
    console.log('✅ O módulo Caixa está pronto para uso:');
    console.log('   - Você pode abrir caixas');
    console.log('   - Registrar movimentações');
    console.log('   - Fechar caixas');
    console.log('   - Ver histórico');
    console.log('');
    console.log('🚀 Teste agora no sistema!');

  } catch (error) {
    console.log('❌ Erro na verificação:', error.message || error);
    mostrarInstrucoes();
  }
}

function mostrarInstrucoes() {
  console.log('');
  console.log('🎯 AÇÃO NECESSÁRIA:');
  console.log('===============================');
  console.log('');
  console.log('As tabelas do módulo Caixa precisam ser criadas no Supabase.');
  console.log('');
  console.log('📋 INSTRUÇÕES:');
  console.log('1. Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql');
  console.log('2. Copie TODO o conteúdo do arquivo "fix-caixa-complete.sql"');
  console.log('3. Cole no SQL Editor do Supabase');
  console.log('4. Clique em "Run"');
  console.log('5. Aguarde as mensagens de confirmação ✅');
  console.log('');
  console.log('📄 Arquivo SQL: fix-caixa-complete.sql');
  console.log('🌐 Dashboard: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql');
  console.log('');
  console.log('⚡ Após executar o SQL, execute este script novamente para confirmar!');
}

// Executar verificação
verificarTabelasCaixa();
