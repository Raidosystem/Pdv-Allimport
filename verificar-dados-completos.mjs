const supabaseUrl = 'https://YOUR_SUPABASE_PROJECT.supabase.co';
const supabaseKey = 'YOUR_SUPABASE_ANON_KEY'

async function verificarDados() {
  console.log('=== VERIFICAÇÃO COMPLETA DOS DADOS ===\n');
  
  try {
    // Verificar tabela empresas
    console.log('🏢 VERIFICANDO EMPRESAS...');
    const empresasRes = await fetch(`${supabaseUrl}/rest/v1/empresas?select=*`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const empresas = await empresasRes.json();
    
    if (Array.isArray(empresas)) {
      console.log(`✅ EMPRESAS: ${empresas.length} registros`);
      if (empresas.length > 0) {
        console.log('Empresas encontradas:', empresas.map(e => ({ 
          nome: e.nome, 
          cnpj: e.cnpj, 
          user_id: e.user_id?.substring(0, 8) + '...' 
        })));
      }
    } else {
      console.log('❌ EMPRESAS:', empresas.message);
    }
    
    // Verificar funcionários
    console.log('\n👥 VERIFICANDO FUNCIONÁRIOS...');
    const funcRes = await fetch(`${supabaseUrl}/rest/v1/funcionarios?select=*`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const funcionarios = await funcRes.json();
    
    if (Array.isArray(funcionarios)) {
      console.log(`✅ FUNCIONÁRIOS: ${funcionarios.length} registros`);
      if (funcionarios.length > 0) {
        console.log('Funcionários encontrados:', funcionarios.map(f => ({ 
          nome: f.nome, 
          cargo: f.cargo,
          ativo: f.ativo,
          user_id: f.user_id?.substring(0, 8) + '...'
        })));
      }
    } else {
      console.log('❌ FUNCIONÁRIOS:', funcionarios.message);
    }
    
    // Verificar produtos de teste
    console.log('\n📦 VERIFICANDO PRODUTOS...');
    const prodRes = await fetch(`${supabaseUrl}/rest/v1/produtos?select=*&limit=10`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const produtos = await prodRes.json();
    
    if (Array.isArray(produtos)) {
      console.log(`✅ PRODUTOS: ${produtos.length} registros`);
      if (produtos.length > 0) {
        console.log('Produtos encontrados:', produtos.map(p => ({ 
          nome: p.nome, 
          preco: p.preco,
          categoria: p.categoria
        })));
      }
    } else {
      console.log('❌ PRODUTOS:', produtos.message);
    }
    
    // Verificar clientes de teste
    console.log('\n👤 VERIFICANDO CLIENTES...');
    const clientesRes = await fetch(`${supabaseUrl}/rest/v1/clientes?select=*&limit=10`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const clientes = await clientesRes.json();
    
    if (Array.isArray(clientes)) {
      console.log(`✅ CLIENTES: ${clientes.length} registros`);
      if (clientes.length > 0) {
        console.log('Clientes encontrados:', clientes.map(c => ({ 
          nome: c.nome, 
          telefone: c.telefone,
          cpf_cnpj: c.cpf_cnpj
        })));
      }
    } else {
      console.log('❌ CLIENTES:', clientes.message);
    }
    
    // Verificar vendas
    console.log('\n💰 VERIFICANDO VENDAS...');
    const vendasRes = await fetch(`${supabaseUrl}/rest/v1/vendas?select=*&limit=5`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const vendas = await vendasRes.json();
    
    if (Array.isArray(vendas)) {
      console.log(`✅ VENDAS: ${vendas.length} registros`);
      if (vendas.length > 0) {
        console.log('Vendas encontradas:', vendas.map(v => ({ 
          id: v.id,
          valor_total: v.valor_total,
          data_venda: v.data_venda
        })));
      }
    } else {
      console.log('❌ VENDAS:', vendas.message);
    }
    
    // Verificar ordens de serviço
    console.log('\n🔧 VERIFICANDO ORDENS DE SERVIÇO...');
    const osRes = await fetch(`${supabaseUrl}/rest/v1/ordens_servico?select=*&limit=5`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const os = await osRes.json();
    
    if (Array.isArray(os)) {
      console.log(`✅ ORDENS DE SERVIÇO: ${os.length} registros`);
      if (os.length > 0) {
        console.log('OS encontradas:', os.map(o => ({ 
          id: o.id,
          defeito: o.defeito,
          status: o.status,
          cliente_nome: o.cliente_nome
        })));
      }
    } else {
      console.log('❌ ORDENS DE SERVIÇO:', os.message);
    }
    
  } catch (error) {
    console.error('Erro geral:', error.message);
  }
}

verificarDados();
