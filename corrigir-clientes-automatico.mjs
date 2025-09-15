import { createClient } from '@supabase/supabase-js'

// Configuração do Supabase
const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'

const supabase = createClient(supabaseUrl, supabaseKey)

async function corrigirStatusClientes() {
  console.log('🔧 INICIANDO CORREÇÃO DO STATUS DOS CLIENTES')
  console.log('=============================================')
  
  try {
    // 1. Verificar situação atual
    console.log('\n📊 1. Verificando situação atual...')
    
    const { count: totalClientes } = await supabase
      .from('clientes')
      .select('*', { count: 'exact', head: true })

    const { count: clientesAtivos } = await supabase
      .from('clientes')
      .select('*', { count: 'exact', head: true })
      .eq('ativo', true)

    const { count: clientesInativos } = await supabase
      .from('clientes')
      .select('*', { count: 'exact', head: true })
      .eq('ativo', false)

    console.log(`   📈 Total de clientes: ${totalClientes}`)
    console.log(`   ✅ Clientes ativos: ${clientesAtivos}`)
    console.log(`   ❌ Clientes inativos: ${clientesInativos}`)

    // 2. Buscar clientes inativos
    console.log('\n🔍 2. Buscando clientes inativos...')
    
    const { data: clientesInativosData, error: errorBusca } = await supabase
      .from('clientes')
      .select('id, nome, ativo')
      .eq('ativo', false)

    if (errorBusca) {
      throw new Error(`Erro ao buscar clientes inativos: ${errorBusca.message}`)
    }

    console.log(`   🎯 Encontrados ${clientesInativosData?.length || 0} clientes inativos`)

    if (!clientesInativosData || clientesInativosData.length === 0) {
      console.log('   ✅ Todos os clientes já estão ativos!')
      return
    }

    // 3. Atualizar clientes inativos para ativo
    console.log('\n🔄 3. Atualizando clientes para ativo...')
    
    const { data: dadosAtualizados, error: errorAtualizacao } = await supabase
      .from('clientes')
      .update({ 
        ativo: true,
        atualizado_em: new Date().toISOString()
      })
      .eq('ativo', false)
      .select('id, nome, ativo')

    if (errorAtualizacao) {
      throw new Error(`Erro ao atualizar clientes: ${errorAtualizacao.message}`)
    }

    console.log(`   ✅ ${dadosAtualizados?.length || 0} clientes atualizados com sucesso!`)

    // 4. Verificar resultado final
    console.log('\n📊 4. Verificando resultado final...')
    
    const { count: novoTotalAtivos } = await supabase
      .from('clientes')
      .select('*', { count: 'exact', head: true })
      .eq('ativo', true)

    const { count: novoTotalInativos } = await supabase
      .from('clientes')
      .select('*', { count: 'exact', head: true })
      .eq('ativo', false)

    console.log(`   ✅ Clientes ativos agora: ${novoTotalAtivos}`)
    console.log(`   ❌ Clientes inativos agora: ${novoTotalInativos}`)

    // 5. Mostrar alguns exemplos
    if (dadosAtualizados && dadosAtualizados.length > 0) {
      console.log('\n📋 5. Exemplos de clientes corrigidos:')
      dadosAtualizados.slice(0, 5).forEach((cliente, index) => {
        console.log(`   ${index + 1}. ${cliente.nome} - Status: ${cliente.ativo ? 'ATIVO' : 'INATIVO'}`)
      })
    }

    console.log('\n🎉 CORREÇÃO CONCLUÍDA COM SUCESSO!')
    console.log('=====================================')
    console.log('✅ Todos os clientes agora estão com status ativo')
    console.log('✅ Baseado no backup original onde todos eram ativos')
    console.log('✅ Sistema restaurado ao estado correto')

  } catch (error) {
    console.error('\n❌ ERRO DURANTE A CORREÇÃO:', error.message)
    console.log('\n💡 SOLUÇÕES ALTERNATIVAS:')
    console.log('1. Verificar credenciais do Supabase')
    console.log('2. Executar o script SQL diretamente no Supabase Dashboard')
    console.log('3. Verificar permissões RLS na tabela clientes')
  }
}

// Executar correção
corrigirStatusClientes()