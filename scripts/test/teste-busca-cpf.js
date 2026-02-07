// Teste direto da função buscarClientes
console.log('🧪 TESTE DIRETO DO CLIENTE SERVICE');

// Simular busca por CPF
async function testarBuscaCpf() {
  try {
    // Simular a chamada que seria feita pelo componente
    const response = await fetch('/backup-allimport.json');
    const backupData = await response.json();
    
    const clients = backupData.data?.clients || [];
    console.log('📊 Total de clientes no backup:', clients.length);
    
    // Buscar por um CPF específico
    const cpfTeste = '39244943808'; // ANA LIVIA
    console.log('🔍 Buscando por CPF:', cpfTeste);
    
    // Filtrar como o sistema faria
    const clientesFiltrados = clients.filter(client => {
      const nome = (client.name || '').toLowerCase();
      const telefone = client.phone || '';
      const cpf = String(client.cpf_cnpj || '');
      const endereco = (client.address || '').toLowerCase();
      
      const search = cpfTeste.toLowerCase();
      
      return nome.includes(search) ||
             telefone.includes(search) ||
             cpf.includes(search) ||
             endereco.includes(search);
    });
    
    console.log('📋 Clientes encontrados:', clientesFiltrados.length);
    clientesFiltrados.forEach(client => {
      console.log(`  - ${client.name} (CPF: ${client.cpf_cnpj})`);
    });
    
  } catch (error) {
    console.error('❌ Erro no teste:', error);
  }
}

// Executar teste quando carregar
if (typeof window !== 'undefined') {
  window.testarBuscaCpf = testarBuscaCpf;
  console.log('✅ Teste disponível. Execute: testarBuscaCpf()');
}