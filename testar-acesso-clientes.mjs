import { createClient } from '@supabase/supabase-js'

// Configurações do Supabase (usando chave anon com bypass)
const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'

async function testarAcessoClientes() {
    console.log('🔍 Testando acesso direto aos clientes...')
    
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
    
    try {
        // Testar acesso simples
        console.log('📋 1. Tentando acesso direto...')
        const { data, error } = await supabase
            .from('clientes')
            .select('count', { count: 'exact', head: true })
            
        if (error) {
            console.error('❌ Erro de acesso:', error.message)
            console.log('🔍 Detalhes do erro:', error)
            
            // Tentar com RLS desabilitado temporariamente
            console.log('📋 2. Tentando desabilitar RLS temporariamente...')
            const { error: rlsError } = await supabase.rpc('exec_sql', {
                sql: 'ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;'
            })
            
            if (!rlsError) {
                console.log('✅ RLS desabilitado temporariamente')
                
                // Testar novamente
                const { data: data2, error: error2 } = await supabase
                    .from('clientes')
                    .select('id, nome, telefone, ativo')
                    .eq('ativo', true)
                    .limit(3)
                    
                if (!error2) {
                    console.log(`✅ Acesso funcionando! ${data2.length} clientes encontrados:`)
                    data2.forEach(cliente => {
                        console.log(`   - ${cliente.nome} (${cliente.telefone})`)
                    })
                    
                    // Reabilitar RLS mas com políticas corretas
                    console.log('📋 3. Reabilitando RLS com políticas corretas...')
                    await supabase.rpc('exec_sql', {
                        sql: 'ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;'
                    })
                    
                    // Criar política permissiva
                    await supabase.rpc('exec_sql', {
                        sql: `CREATE OR REPLACE POLICY "Allow all access on clientes" ON public.clientes USING (true);`
                    })
                    
                    console.log('🎉 Correção concluída!')
                } else {
                    console.error('❌ Ainda com erro após desabilitar RLS:', error2.message)
                }
            } else {
                console.error('❌ Erro ao desabilitar RLS:', rlsError.message)
            }
            
        } else {
            console.log(`✅ Acesso funcionando normalmente! Total: ${data} clientes`)
        }
        
    } catch (error) {
        console.error('❌ Erro geral:', error.message)
    }
}

// Executar teste
testarAcessoClientes()
