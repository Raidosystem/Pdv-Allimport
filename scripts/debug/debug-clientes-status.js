import { createClient } from '@supabase/supabase-js'

// Configuração do Supabase (pegue da sua configuração atual)
const supabaseUrl = 'https://your-project-url.supabase.co'
const supabaseKey = 'your-anon-key'

const supabase = createClient(supabaseUrl, supabaseKey)

async function investigarStatusClientes() {
  try {
    console.log('🔍 Investigando status dos clientes...\n')

    // 1. Contar total de clientes
    const { count: totalClientes } = await supabase
      .from('clientes')
      .select('*', { count: 'exact', head: true })

    console.log(`📊 Total de clientes: ${totalClientes}`)

    // 2. Contar clientes ativos
    const { count: clientesAtivos } = await supabase
      .from('clientes')
      .select('*', { count: 'exact', head: true })
      .eq('ativo', true)

    console.log(`✅ Clientes ativos: ${clientesAtivos}`)

    // 3. Contar clientes inativos
    const { count: clientesInativos } = await supabase
      .from('clientes')
      .select('*', { count: 'exact', head: true })
      .eq('ativo', false)

    console.log(`❌ Clientes inativos: ${clientesInativos}`)

    // 4. Verificar se há campo de data de alteração para ver quando foram desativados
    const { data: amostraClientes } = await supabase
      .from('clientes')
      .select('nome, ativo, criado_em, atualizado_em')
      .limit(5)

    console.log('\n📋 Amostra de clientes:')
    amostraClientes?.forEach((cliente, index) => {
      console.log(`${index + 1}. ${cliente.nome} - Ativo: ${cliente.ativo} - Criado: ${cliente.criado_em} - Atualizado: ${cliente.atualizado_em || 'N/A'}`)
    })

    // 5. Verificar clientes inativos mais recentes
    const { data: clientesInativosRecentes } = await supabase
      .from('clientes')
      .select('nome, ativo, criado_em, atualizado_em')
      .eq('ativo', false)
      .order('atualizado_em', { ascending: false, nullsFirst: false })
      .limit(10)

    console.log('\n❌ Últimos 10 clientes inativos (por data de atualização):')
    clientesInativosRecentes?.forEach((cliente, index) => {
      console.log(`${index + 1}. ${cliente.nome} - Atualizado: ${cliente.atualizado_em || 'Nunca'}`)
    })

    // 6. Verificar se há algum padrão na estrutura dos dados
    const { data: estruturaTabela } = await supabase
      .from('clientes')
      .select('*')
      .limit(1)

    console.log('\n🏗️ Estrutura da tabela (primeiro registro):')
    if (estruturaTabela?.[0]) {
      console.log('Campos disponíveis:', Object.keys(estruturaTabela[0]))
    }

  } catch (error) {
    console.error('❌ Erro ao investigar clientes:', error)
    
    // Tentar backup local
    console.log('\n🔄 Tentando verificar backup local...')
    try {
      const fs = await import('fs')
      const path = './backup-allimport.json'
      
      if (fs.existsSync(path)) {
        const backup = JSON.parse(fs.readFileSync(path, 'utf8'))
        const clients = backup.data?.clients || []
        
        console.log(`📂 Backup encontrado com ${clients.length} clientes`)
        
        const ativosBackup = clients.filter(c => c.active !== false).length
        const inativosBackup = clients.filter(c => c.active === false).length
        
        console.log(`✅ Ativos no backup: ${ativosBackup}`)
        console.log(`❌ Inativos no backup: ${inativosBackup}`)
      }
    } catch (backupError) {
      console.log('Backup local não disponível')
    }
  }
}

// Executar investigação
investigarStatusClientes()