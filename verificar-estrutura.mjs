const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

async function verificarEstrutura() {
  console.log('=== VERIFICAÇÃO DA ESTRUTURA ===\n');
  
  try {
    // Tentar diferentes nomes para a tabela de configurações
    const possiveisNomes = [
      'configuracoes_empresa',
      'empresa_config',  
      'empresa',
      'configuracoes',
      'config_empresa'
    ];
    
    for (const nome of possiveisNomes) {
      try {
        const res = await fetch(`${supabaseUrl}/rest/v1/${nome}?select=*&limit=1`, {
          headers: {
            'apikey': supabaseKey,
            'Authorization': `Bearer ${supabaseKey}`
          }
        });
        const data = await res.json();
        
        if (res.ok && Array.isArray(data)) {
          console.log(`✅ TABELA ENCONTRADA: ${nome} - ${data.length} registros`);
          if (data.length > 0) {
            console.log('Dados:', JSON.stringify(data[0], null, 2));
          }
        } else if (data.code !== '42P01') {
          console.log(`⚠️  ${nome}: ${data.message}`);
        }
      } catch (e) {
        // Ignora erros de tabela não encontrada
      }
    }
    
    // Verificar também outras tabelas importantes
    const tabelas = ['produtos', 'clientes', 'vendas', 'ordens_servico', 'funcionarios'];
    
    for (const tabela of tabelas) {
      try {
        const res = await fetch(`${supabaseUrl}/rest/v1/${tabela}?select=count&head=true`, {
          headers: {
            'apikey': supabaseKey,
            'Authorization': `Bearer ${supabaseKey}`,
            'Prefer': 'count=exact'
          }
        });
        
        const count = res.headers.get('content-range');
        console.log(`📊 ${tabela.toUpperCase()}: ${count ? count.split('/')[1] : 'erro'} registros`);
      } catch (e) {
        console.log(`❌ ${tabela}: Erro - ${e.message}`);
      }
    }
    
  } catch (error) {
    console.error('Erro geral:', error.message);
  }
}

verificarEstrutura();
