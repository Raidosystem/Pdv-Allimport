// Teste simples de conexão Supabase
// Execute com: node test-supabase-simple.js

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

async function testConnection() {
  try {
    console.log('🔍 Testando conexão...');

    const response = await fetch(`${supabaseUrl}/rest/v1/`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });

    if (response.ok) {
      console.log('✅ Conexão OK! Pode executar os scripts SQL.');
      return true;
    } else {
      const error = await response.text();
      console.log('❌ Erro:', response.status, response.statusText);
      console.log('Detalhes:', error);
      return false;
    }
  } catch (error) {
    console.log('❌ Erro de rede:', error.message);
    return false;
  }
}

testConnection();
