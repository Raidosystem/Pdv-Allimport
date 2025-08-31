import { createClient } from '@supabase/supabase-js'

// 🔧 Script para limpar ordens de serviço com dados incorretos
// Execute com: node limpar-ordens-script.js

const supabaseUrl = 'SUA_URL_SUPABASE_AQUI'
const supabaseKey = 'SUA_CHAVE_SUPABASE_AQUI'

const supabase = createClient(supabaseUrl, supabaseKey)

async function limparOrdensIncorretas() {
  console.log('🔍 Iniciando limpeza de ordens de serviço...')
  
  try {
    // 1. Primeiro, contar quantas ordens serão afetadas
    const { data: contagem, error: erroContagem } = await supabase
      .from('ordens_servico')
      .select('id', { count: 'exact', head: true })
      .or('marca.is.null,marca.eq.Não informado,marca.eq.')
      .or('modelo.is.null,modelo.eq.Não informado,modelo.eq.')
      .or('valor.is.null,valor.eq.0')
      .is('cliente_id', null)

    if (erroContagem) {
      console.error('❌ Erro ao contar ordens:', erroContagem)
      return
    }

    console.log(`📊 Encontradas ${contagem} ordens com dados incorretos`)

    // 2. Buscar algumas ordens para mostrar exemplo
    const { data: exemplos, error: erroExemplos } = await supabase
      .from('ordens_servico')
      .select('id, numero_os, equipamento, marca, modelo, descricao_problema, valor, cliente_id')
      .or('marca.is.null,marca.eq.Não informado')
      .or('modelo.is.null,modelo.eq.Não informado') 
      .or('valor.is.null,valor.eq.0')
      .is('cliente_id', null)
      .limit(5)

    if (!erroExemplos && exemplos) {
      console.log('\n📋 Exemplos de ordens que serão excluídas:')
      exemplos.forEach((ordem, index) => {
        console.log(`${index + 1}. OS: ${ordem.numero_os}`)
        console.log(`   Equipamento: ${ordem.equipamento || 'Não informado'}`)
        console.log(`   Marca: ${ordem.marca || 'null'}`)
        console.log(`   Modelo: ${ordem.modelo || 'null'}`) 
        console.log(`   Problema: ${ordem.descricao_problema || 'null'}`)
        console.log(`   Valor: ${ordem.valor || 'null'}`)
        console.log(`   Cliente ID: ${ordem.cliente_id || 'null'}`)
        console.log('   ---')
      })
    }

    // 3. Confirmar exclusão (descomente para executar)
    /*
    console.log('\n🗑️ Executando exclusão...')
    
    const { data: excluidas, error: erroExclusao } = await supabase
      .from('ordens_servico')
      .delete()
      .or('marca.is.null,marca.eq.Não informado,marca.eq.')
      .or('modelo.is.null,modelo.eq.Não informado,modelo.eq.')
      .or('valor.is.null,valor.eq.0')
      .is('cliente_id', null)

    if (erroExclusao) {
      console.error('❌ Erro ao excluir ordens:', erroExclusao)
      return
    }

    console.log(`✅ Exclusão concluída! ${excluidas?.length || 0} ordens removidas`)
    */

    // 4. Contar ordens restantes
    const { count: restantes } = await supabase
      .from('ordens_servico')
      .select('*', { count: 'exact', head: true })

    console.log(`\n📊 Total de ordens restantes: ${restantes}`)
    
  } catch (error) {
    console.error('❌ Erro geral:', error)
  }
}

// Executar o script
limparOrdensIncorretas()

// 📝 INSTRUÇÕES DE USO:
// 1. Substitua SUA_URL_SUPABASE_AQUI pela URL real
// 2. Substitua SUA_CHAVE_SUPABASE_AQUI pela chave real  
// 3. Execute: npm install @supabase/supabase-js
// 4. Execute: node limpar-ordens-script.js
// 5. Para executar a exclusão, descomente o bloco "Confirmar exclusão"
