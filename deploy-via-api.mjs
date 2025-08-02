#!/usr/bin/env node

import fetch from 'node-fetch';
import fs from 'fs';

// Configuração
const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

async function executarSQLViaAPI() {
  console.log('🚀 EXECUTANDO DEPLOY FINAL VIA API');
  console.log('====================================\n');

  try {
    // Ler o script SQL
    const sqlScript = fs.readFileSync('DEPLOY_FINAL.sql', 'utf8');
    
    console.log('📄 Script carregado:', sqlScript.length, 'caracteres');
    
    // Dividir o script em comandos individuais
    const comandos = sqlScript
      .split(';')
      .map(cmd => cmd.trim())
      .filter(cmd => cmd.length > 0 && !cmd.startsWith('--'));
    
    console.log('📊 Total de comandos:', comandos.length);
    
    // Executar cada comando via REST API
    let sucessos = 0;
    let erros = 0;
    
    for (let i = 0; i < comandos.length; i++) {
      const comando = comandos[i];
      
      if (comando.includes('SELECT') && (comando.includes('as info') || comando.includes('as resultado'))) {
        // Comando de verificação - vamos executar
        console.log(`\n✅ Executando verificação ${i + 1}/${comandos.length}`);
        
        try {
          const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/query`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'apikey': SUPABASE_ANON_KEY,
              'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
            },
            body: JSON.stringify({ sql: comando })
          });
          
          if (response.ok) {
            const result = await response.json();
            console.log('📋 Resultado:', result);
            sucessos++;
          } else {
            console.log('⚠️ Comando de verificação não executado via API');
          }
        } catch (err) {
          console.log('⚠️ API não suporta este comando:', err.message);
        }
      } else {
        // Comando DDL/DML - mostrar apenas
        console.log(`📝 Comando ${i + 1}: ${comando.substring(0, 50)}...`);
      }
    }
    
    console.log('\n🎯 RESULTADO DO DEPLOY:');
    console.log('========================');
    console.log(`✅ Comandos processados: ${comandos.length}`);
    console.log(`📊 Verificações: ${sucessos}`);
    
    console.log('\n🔧 PRÓXIMA AÇÃO NECESSÁRIA:');
    console.log('============================');
    console.log('Para completar o deploy, execute o script no Supabase Dashboard:');
    console.log('1. Vá para: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql');
    console.log('2. Cole o conteúdo de DEPLOY_FINAL.sql');
    console.log('3. Execute o script');
    console.log('4. Verifique os resultados das queries de verificação');
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  }
}

// Executar
executarSQLViaAPI();
