const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

async function verificarTabelas() {
  console.log('=== VERIFICAÇÃO DAS TABELAS ===\n');
  
  try {
    // Produtos
    const produtosRes = await fetch(`${supabaseUrl}/rest/v1/produtos?select=*&limit=10`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const produtos = await produtosRes.json();
    console.log('PRODUTOS:', Array.isArray(produtos) ? produtos.length + ' registros' : 'Erro: ' + JSON.stringify(produtos));
    if (Array.isArray(produtos) && produtos.length > 0) {
      console.log('Primeiros produtos:', produtos.slice(0, 3).map(p => ({ nome: p.nome, preco: p.preco })));
    }
    
    // Clientes
    const clientesRes = await fetch(`${supabaseUrl}/rest/v1/clientes?select=*&limit=10`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const clientes = await clientesRes.json();
    console.log('\nCLIENTES:', Array.isArray(clientes) ? clientes.length + ' registros' : 'Erro: ' + JSON.stringify(clientes));
    if (Array.isArray(clientes) && clientes.length > 0) {
      console.log('Primeiros clientes:', clientes.slice(0, 3).map(c => ({ nome: c.nome, telefone: c.telefone })));
    }
    
    // Vendas
    const vendasRes = await fetch(`${supabaseUrl}/rest/v1/vendas?select=*&limit=5`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const vendas = await vendasRes.json();
    console.log('\nVENDAS:', Array.isArray(vendas) ? vendas.length + ' registros' : 'Erro: ' + JSON.stringify(vendas));
    
    // Ordens de Serviço
    const osRes = await fetch(`${supabaseUrl}/rest/v1/ordens_servico?select=*&limit=5`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const os = await osRes.json();
    console.log('\nORDENS DE SERVIÇO:', Array.isArray(os) ? os.length + ' registros' : 'Erro: ' + JSON.stringify(os));
    
    // Configurações da Empresa
    const empresaRes = await fetch(`${supabaseUrl}/rest/v1/configuracoes_empresa?select=*`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const empresa = await empresaRes.json();
    console.log('\nCONFIGURAÇÕES EMPRESA:', Array.isArray(empresa) ? empresa.length + ' registros' : 'Erro: ' + JSON.stringify(empresa));
    if (Array.isArray(empresa) && empresa.length > 0) {
      console.log('Empresa:', empresa.map(e => ({ 
        nome: e.nome_empresa, 
        cnpj: e.cnpj, 
        telefone: e.telefone,
        user_id: e.user_id 
      })));
    }
    
    // Funcionários
    const funcRes = await fetch(`${supabaseUrl}/rest/v1/funcionarios?select=*`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const funcionarios = await funcRes.json();
    console.log('\nFUNCIONÁRIOS:', Array.isArray(funcionarios) ? funcionarios.length + ' registros' : 'Erro: ' + JSON.stringify(funcionarios));
    if (Array.isArray(funcionarios) && funcionarios.length > 0) {
      console.log('Funcionários:', funcionarios.map(f => ({ 
        nome: f.nome, 
        cargo: f.cargo, 
        ativo: f.ativo,
        user_id: f.user_id 
      })));
    }
    
  } catch (error) {
    console.error('Erro na verificação:', error.message);
  }
}

verificarTabelas();
