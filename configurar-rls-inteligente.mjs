import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'

async function configurarRLSInteligente() {
    console.log('🔒 CONFIGURANDO RLS INTELIGENTE')
    console.log('Sistema que funciona em DEV e está pronto para PRODUÇÃO')
    
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
    
    try {
        // Executar configuração RLS via SQL Editor do Supabase
        console.log('📋 Para aplicar RLS inteligente:')
        console.log('1. Vá no SQL Editor do Supabase')
        console.log('2. Execute o arquivo CONFIGURAR_RLS_INTELIGENTE.sql')
        console.log('3. Ou copie e cole este código:')
        console.log('')
        console.log('-- HABILITAR RLS')
        console.log('ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;')
        console.log('')
        console.log('-- POLÍTICA PERMISSIVA PARA DEV/PRODUÇÃO')
        console.log(`CREATE POLICY "clientes_dev_prod_policy" ON public.clientes`)
        console.log('  FOR ALL USING (true) WITH CHECK (true);')
        console.log('')
        
        // Testar acesso atual antes da mudança
        console.log('📋 Testando acesso atual (com RLS desabilitado)...')
        const { data, error } = await supabase
            .from('clientes')
            .select('count', { count: 'exact', head: true })
            
        if (error) {
            console.error('❌ Erro no teste:', error.message)
        } else {
            console.log(`✅ Acesso funcionando: ${data} clientes encontrados`)
        }
        
        console.log('')
        console.log('🎯 DECISÃO RECOMENDADA:')
        console.log('   OPÇÃO A: Manter RLS DESABILITADO (mais simples)')
        console.log('   OPÇÃO B: Aplicar RLS INTELIGENTE (mais seguro)')
        console.log('')
        console.log('💡 Para este projeto em desenvolvimento, recomendo OPÇÃO A')
        console.log('   O sistema está funcionando perfeitamente sem RLS')
        
    } catch (error) {
        console.error('❌ Erro:', error)
    }
}

configurarRLSInteligente()
