import { createClient } from '@supabase/supabase-js'

// Configurações do Supabase
const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'

async function verificarClientesCompleto() {
    console.log('🔍 Verificação completa da tabela clientes...')
    
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
    
    try {
        // 1. Testar select simples
        console.log('📋 1. Testando SELECT simples...')
        const { data: clientes, error: selectError } = await supabase
            .from('clientes')
            .select('id, nome, telefone, ativo')
            .limit(5)
            
        if (selectError) {
            console.error('❌ Erro no SELECT:', selectError.message)
            console.log('   Código:', selectError.code)
            console.log('   Detalhes:', selectError.details)
            console.log('   Hint:', selectError.hint)
        } else {
            console.log(`✅ SELECT funcionou! Encontrados ${clientes.length} registros:`)
            clientes.forEach((cliente, index) => {
                console.log(`   ${index + 1}. ${cliente.nome || 'Nome vazio'} - ${cliente.telefone || 'Tel vazio'} - Ativo: ${cliente.ativo}`)
            })
        }
        
        // 2. Testar count manual
        console.log('📋 2. Testando COUNT manual...')
        const { data: countData, error: countError } = await supabase
            .from('clientes')
            .select('id')
            
        if (countError) {
            console.error('❌ Erro no COUNT:', countError.message)
        } else {
            console.log(`✅ COUNT manual: ${countData.length} registros encontrados`)
        }
        
        // 3. Testar apenas ativos
        console.log('📋 3. Testando apenas clientes ativos...')
        const { data: ativosData, error: ativosError } = await supabase
            .from('clientes')
            .select('id, nome, telefone')
            .eq('ativo', true)
            
        if (ativosError) {
            console.error('❌ Erro ao buscar ativos:', ativosError.message)
        } else {
            console.log(`✅ Clientes ativos: ${ativosData.length} encontrados`)
            ativosData.slice(0, 3).forEach((cliente, index) => {
                console.log(`   ${index + 1}. ${cliente.nome} - ${cliente.telefone}`)
            })
        }
        
        // 4. Testar busca por nome específico (dos dados importados)
        console.log('📋 4. Testando busca por nome específico...')
        const { data: buscaData, error: buscaError } = await supabase
            .from('clientes')
            .select('id, nome, telefone')
            .ilike('nome', '%silva%')
            .limit(3)
            
        if (buscaError) {
            console.error('❌ Erro na busca:', buscaError.message)
        } else {
            console.log(`✅ Busca por 'silva': ${buscaData.length} encontrados`)
            buscaData.forEach((cliente, index) => {
                console.log(`   ${index + 1}. ${cliente.nome} - ${cliente.telefone}`)
            })
        }
        
    } catch (error) {
        console.error('❌ Erro geral:', error)
    }
}

// Executar verificação
verificarClientesCompleto()
