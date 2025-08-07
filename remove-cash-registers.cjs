// Script para remover tabela cash_registers duplicada via API
// Execute com: node remove-cash-registers.cjs

const https = require('https');

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.Ds1oL_nqbXGQo8CHp-6Oo3p8G_VPL0KeZT7u0d5LCcQ'; // Service role key

function executeSql(sql) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({ query: sql });
    
    const options = {
      hostname: 'kmcaaqetxtwkdcczdomw.supabase.co',
      port: 443,
      path: '/rest/v1/rpc/exec_sql', // RPC para SQL direto
      method: 'POST',
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': `Bearer ${supabaseServiceKey}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        resolve({ 
          status: res.statusCode, 
          body: body,
          success: res.statusCode >= 200 && res.statusCode < 300
        });
      });
    });

    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}

async function removerTabelaDuplicada() {
  console.log('🗑️ REMOVENDO TABELA CASH_REGISTERS DUPLICADA');
  console.log('=============================================');
  console.log('');

  try {
    // 1. Verificar se cash_registers ainda existe
    console.log('1️⃣ Verificando existência da tabela cash_registers...');
    
    const checkResult = await executeSql(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
        AND table_name = 'cash_registers';
    `);
    
    console.log(`   Status: ${checkResult.status}`);
    
    if (checkResult.success && checkResult.body.includes('cash_registers')) {
      console.log('   ✅ Tabela cash_registers encontrada');
      
      // 2. Remover a tabela
      console.log('\n2️⃣ Removendo tabela cash_registers...');
      
      const dropResult = await executeSql(`
        DROP TABLE IF EXISTS public.cash_registers CASCADE;
      `);
      
      console.log(`   Status: ${dropResult.status}`);
      
      if (dropResult.success) {
        console.log('   ✅ Tabela cash_registers removida com sucesso!');
      } else {
        console.log(`   ❌ Erro ao remover: ${dropResult.body}`);
      }
      
    } else {
      console.log('   ⚠️ Tabela cash_registers não encontrada');
    }

    // 3. Verificar limpeza
    console.log('\n3️⃣ Verificando limpeza final...');
    
    const finalCheck = await executeSql(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
        AND (table_name LIKE '%cash%' OR table_name LIKE '%caixa%')
      ORDER BY table_name;
    `);
    
    if (finalCheck.success) {
      console.log('   ✅ Tabelas de caixa restantes:');
      console.log(`   ${finalCheck.body}`);
    }

  } catch (error) {
    console.log('\n❌ ERRO:', error.message);
  }

  console.log('\n🎯 RESULTADO:');
  console.log('• Se removeu cash_registers: Conflito resolvido');
  console.log('• Deve restar apenas: caixa, movimentacoes_caixa');
  console.log('• Teste novamente a abertura de caixa no frontend');
}

// Executar
removerTabelaDuplicada();
