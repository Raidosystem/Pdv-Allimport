// Teste da função de busca por CPF
const testCpfSearch = () => {
  // Exemplo de dados que devem estar carregados
  const ordemExemplo = {
    id: "teste",
    cliente: {
      nome: "ANTONIO CLAUDIO FIGUEIRA",
      cpf_cnpj: "33393732803",
      telefone: "17999740896"
    },
    marca: "Samsung",
    modelo: "Galaxy S21",
    numero_os: "OS-001"
  };

  // Função de busca (cópia da implementação)
  const filtrarOrdem = (ordem, searchTerm) => {
    const searchNormalized = searchTerm.toLowerCase().replace(/\D/g, '')
    const nomeCliente = (ordem.cliente?.nome?.toLowerCase() || '')
    const cpfCnpj = (ordem.cliente?.cpf_cnpj || '').replace(/\D/g, '')
    const telefone = (ordem.cliente?.telefone || '').replace(/\D/g, '')
    const marca = (ordem.marca?.toLowerCase() || '')
    const modelo = (ordem.modelo?.toLowerCase() || '')
    const numeroOs = (ordem.numero_os?.toLowerCase() || '')
    
    console.log('=== TESTE DE BUSCA ===')
    console.log('Termo de busca:', searchTerm)
    console.log('Termo normalizado:', searchNormalized)
    console.log('CPF armazenado:', ordem.cliente?.cpf_cnpj)
    console.log('CPF normalizado:', cpfCnpj)
    console.log('Match:', cpfCnpj.includes(searchNormalized))
    
    return nomeCliente.includes(searchTerm.toLowerCase()) ||
           cpfCnpj.includes(searchNormalized) ||
           telefone.includes(searchNormalized) ||
           marca.includes(searchTerm.toLowerCase()) ||
           modelo.includes(searchTerm.toLowerCase()) ||
           numeroOs.includes(searchTerm.toLowerCase())
  };

  // Testes
  console.log('🧪 Teste 1 - CPF completo:')
  console.log('Resultado:', filtrarOrdem(ordemExemplo, '33393732803'))
  
  console.log('\n🧪 Teste 2 - 3 primeiros dígitos:')
  console.log('Resultado:', filtrarOrdem(ordemExemplo, '333'))
  
  console.log('\n🧪 Teste 3 - CPF formatado:')
  console.log('Resultado:', filtrarOrdem(ordemExemplo, '333.937.328-03'))
  
  console.log('\n🧪 Teste 4 - Nome:')
  console.log('Resultado:', filtrarOrdem(ordemExemplo, 'ANTONIO'))
}

// Executar teste
testCpfSearch();