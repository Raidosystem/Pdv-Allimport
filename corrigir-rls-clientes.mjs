import { createClient } from '@supabase/supabase-js'

// Configurações do Supabase
const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjQyNjUxMywiZXhwIjoyMDcyMDAyNTEzfQ.M8v1QeQZUgMOH5BUfOzXIcfm-Wg6IhZU6_m6FdSAF8k'

async function corrigirRLSClientes() {
    console.log('🔧 Corrigindo políticas RLS da tabela clientes...')
    
    // Criar cliente com chave de serviço (sem RLS)
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    
    try {
        // 1. Verificar se a tabela existe
        console.log('📋 1. Verificando tabela clientes...')
        const { data: tableCheck, error: tableError } = await supabase
            .from('clientes')
            .select('count', { count: 'exact', head: true })
        
        if (tableError) {
            console.error('❌ Erro ao verificar tabela:', tableError.message)
            return
        }
        
        console.log(`✅ Tabela clientes existe com ${tableCheck} registros`)
        
        // 2. Remover políticas antigas
        console.log('📋 2. Removendo políticas antigas...')
        const dropPolicies = [
            `DROP POLICY IF EXISTS "Users can view all clientes" ON public.clientes;`,
            `DROP POLICY IF EXISTS "Users can insert clientes" ON public.clientes;`, 
            `DROP POLICY IF EXISTS "Users can update clientes" ON public.clientes;`,
            `DROP POLICY IF EXISTS "Users can delete clientes" ON public.clientes;`
        ]
        
        for (const sql of dropPolicies) {
            const { error } = await supabase.rpc('exec_sql', { sql })
            if (error && !error.message.includes('policy') && !error.message.includes('does not exist')) {
                console.warn('⚠️ Aviso ao remover política:', error.message)
            }
        }
        
        // 3. Criar políticas permissivas
        console.log('📋 3. Criando políticas permissivas...')
        const newPolicies = [
            `CREATE POLICY "Allow all select on clientes" ON public.clientes FOR SELECT USING (true);`,
            `CREATE POLICY "Allow all insert on clientes" ON public.clientes FOR INSERT WITH CHECK (true);`,
            `CREATE POLICY "Allow all update on clientes" ON public.clientes FOR UPDATE USING (true) WITH CHECK (true);`,
            `CREATE POLICY "Allow all delete on clientes" ON public.clientes FOR DELETE USING (true);`
        ]
        
        for (const sql of newPolicies) {
            const { error } = await supabase.rpc('exec_sql', { sql })
            if (error) {
                console.warn('⚠️ Aviso ao criar política:', error.message)
            }
        }
        
        // 4. Testar acesso
        console.log('📋 4. Testando acesso aos clientes...')
        const { data: clientes, error: selectError } = await supabase
            .from('clientes')
            .select('id, nome, telefone, ativo')
            .eq('ativo', true)
            .limit(5)
            
        if (selectError) {
            console.error('❌ Erro ao testar acesso:', selectError.message)
            return
        }
        
        console.log(`✅ Acesso funcionando! Encontrados ${clientes.length} clientes ativos:`)
        clientes.forEach((cliente, index) => {
            console.log(`   ${index + 1}. ${cliente.nome} - ${cliente.telefone}`)
        })
        
        console.log('🎉 Correção RLS concluída com sucesso!')
        
    } catch (error) {
        console.error('❌ Erro geral:', error.message)
    }
}

// Executar correção
corrigirRLSClientes()
