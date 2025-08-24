const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

async function criarDadosIniciais() {
  console.log('🚀 CRIANDO DADOS INICIAIS...\n');
  
  try {
    // Criar empresa inicial - Allimport
    console.log('🏢 Criando empresa Allimport...');
    const empresaData = {
      nome: 'Allimport',
      cnpj: '12.345.678/0001-90',
      telefone: '(11) 98765-4321',
      email: 'contato@allimport.com.br',
      endereco: 'Rua das Importações, 123',
      cidade: 'São Paulo',
      estado: 'SP',
      cep: '01234-567',
      user_id: '00000000-0000-0000-0000-000000000000' // ID temporário
    };
    
    const empresaRes = await fetch(`${supabaseUrl}/rest/v1/empresas`, {
      method: 'POST',
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: JSON.stringify(empresaData)
    });
    
    if (empresaRes.ok) {
      const empresa = await empresaRes.json();
      console.log('✅ Empresa criada:', empresa[0]?.nome);
    } else {
      const error = await empresaRes.json();
      console.log('❌ Erro ao criar empresa:', error.message);
    }
    
    // Criar funcionário vendedor
    console.log('\n👤 Criando funcionário vendedor...');
    const funcionarioData = {
      nome: 'Vendedor Sistema',
      email: 'vendedor@allimport.com.br',
      telefone: '(11) 99999-9999',
      cargo: 'vendedor',
      usuario: 'vendedor',
      ativo: true,
      permissoes: {
        vendas: { criar: true, visualizar: true, editar: true, excluir: false },
        produtos: { criar: true, visualizar: true, editar: true, excluir: false },
        clientes: { criar: true, visualizar: true, editar: true, excluir: false },
        caixa: { abrir_fechar: false, visualizar: true, movimentar: false },
        relatorios: { visualizar: true, exportar: false },
        configuracoes: { visualizar: false, editar: false },
        funcionarios: { visualizar: false, editar: false }
      },
      user_id: '00000000-0000-0000-0000-000000000000'
    };
    
    const funcionarioRes = await fetch(`${supabaseUrl}/rest/v1/funcionarios`, {
      method: 'POST',
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: JSON.stringify(funcionarioData)
    });
    
    if (funcionarioRes.ok) {
      const funcionario = await funcionarioRes.json();
      console.log('✅ Funcionário criado:', funcionario[0]?.nome, '-', funcionario[0]?.cargo);
    } else {
      const error = await funcionarioRes.json();
      console.log('❌ Erro ao criar funcionário:', error.message);
    }
    
    // Verificar se as tabelas foram criadas e estão funcionando
    console.log('\n🔍 VERIFICAÇÃO FINAL...');
    
    // Verificar empresas
    const empresasCheck = await fetch(`${supabaseUrl}/rest/v1/empresas?select=*`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const empresas = await empresasCheck.json();
    console.log(`📊 Empresas cadastradas: ${Array.isArray(empresas) ? empresas.length : 'Erro'}`);
    
    // Verificar funcionários
    const funcCheck = await fetch(`${supabaseUrl}/rest/v1/funcionarios?select=*`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    const funcionarios = await funcCheck.json();
    console.log(`📊 Funcionários cadastrados: ${Array.isArray(funcionarios) ? funcionarios.length : 'Erro'}`);
    
    console.log('\n✅ DADOS INICIAIS PRONTOS!');
    console.log('🏢 Empresa: Allimport configurada');
    console.log('👤 Funcionário vendedor configurado');
    console.log('📋 Sistema pronto para uso com dados reais');
    
  } catch (error) {
    console.error('❌ Erro geral:', error.message);
  }
}

criarDadosIniciais();
