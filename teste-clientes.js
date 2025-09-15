// Teste para verificar se existem clientes cadastrados no Supabase
import { supabase } from '../src/lib/supabase.js'

async function testarClientes() {
  try {
    console.log('🔍 Verificando clientes cadastrados...')
    
    const { data, error } = await supabase
      .from('clientes')
      .select('id, nome, cpf_cnpj, cpf_digits, telefone, email')
      .limit(5)
    
    if (error) {
      console.error('❌ Erro ao buscar clientes:', error)
      return
    }
    
    console.log('📊 Clientes encontrados:', data?.length || 0)
    
    if (data && data.length > 0) {
      console.log('👥 Primeiros clientes:')
      data.forEach((cliente, index) => {
        console.log(`${index + 1}. ${cliente.nome}`)
        console.log(`   CPF/CNPJ: ${cliente.cpf_cnpj || 'N/A'}`)
        console.log(`   CPF Digits: ${cliente.cpf_digits || 'N/A'}`)
        console.log(`   Telefone: ${cliente.telefone || 'N/A'}`)
        console.log(`   Email: ${cliente.email || 'N/A'}`)
        console.log('   ---')
      })
      
      // Testar busca por CPF
      const primeiroCliente = data[0]
      if (primeiroCliente.cpf_cnpj || primeiroCliente.cpf_digits) {
        console.log('\n🔍 Testando busca por CPF/CNPJ...')
        
        const cpfParaTeste = primeiroCliente.cpf_cnpj || primeiroCliente.cpf_digits
        const normalizedCpf = cpfParaTeste.replace(/\D/g, '')
        
        const { data: busca, error: erroBusca } = await supabase
          .from('clientes')
          .select('id, nome, cpf_cnpj, cpf_digits')
          .or(`cpf_cnpj.eq.${cpfParaTeste},cpf_digits.eq.${normalizedCpf}`)
        
        if (erroBusca) {
          console.error('❌ Erro na busca:', erroBusca)
        } else {
          console.log(`✅ Busca por "${cpfParaTeste}" encontrou ${busca?.length || 0} resultado(s)`)
          if (busca && busca.length > 0) {
            console.log('📋 Resultado:', busca[0])
          }
        }
      }
    } else {
      console.log('⚠️ Nenhum cliente encontrado no banco de dados')
    }
    
  } catch (error) {
    console.error('💥 Erro geral:', error)
  }
}

testarClientes()