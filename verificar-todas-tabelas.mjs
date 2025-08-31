import { createClient } from '@supabase/supabase-js'

// Configurações do Supabase
const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'

async function verificarTodasTabelas() {
    console.log('🔍 Verificando todas as tabelas com dados de clientes...')
    
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
    
    try {
        // Lista de possíveis tabelas de clientes
        const tabelasCandidatas = ['clientes', 'customers', 'cliente', 'customer']
        
        for (const tabela of tabelasCandidatas) {
            console.log(`📋 Verificando tabela: ${tabela}`)
            
            try {
                const { data, error } = await supabase
                    .from(tabela)
                    .select('*')
                    .limit(3)
                    
                if (error) {
                    console.log(`   ❌ Tabela ${tabela}: ${error.message}`)
                } else {
                    console.log(`   ✅ Tabela ${tabela}: ${data.length} registros encontrados`)
                    if (data.length > 0) {
                        console.log(`   📄 Primeiro registro:`, JSON.stringify(data[0], null, 2))
                    }
                }
            } catch (err) {
                console.log(`   ❌ Tabela ${tabela}: Erro - ${err.message}`)
            }
        }
        
        // Verificar se os dados estão em outra tabela ou schema
        console.log('📋 Verificando possíveis dados de importação...')
        
        // Tentar tabelas relacionadas a importação
        const tabelasImportacao = ['import_clientes', 'backup_clientes', 'temp_clientes']
        
        for (const tabela of tabelasImportacao) {
            try {
                const { data, error } = await supabase
                    .from(tabela)
                    .select('*')
                    .limit(1)
                    
                if (!error && data.length > 0) {
                    console.log(`   ✅ Encontrada tabela de importação: ${tabela} com ${data.length} registros`)
                    console.log(`   📄 Estrutura:`, Object.keys(data[0]))
                }
            } catch (err) {
                // Ignorar erros para tabelas que não existem
            }
        }
        
    } catch (error) {
        console.error('❌ Erro geral:', error)
    }
}

// Executar verificação
verificarTodasTabelas()
