import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjI3MTI5MDcsImV4cCI6MjAzODI4ODkwN30.qrYZhwWMJvWVBMt-TgLYKR8PcKJOLTDVOcfkJRxQpPQ'

const supabase = createClient(supabaseUrl, supabaseAnonKey)

async function executarCorrecaoCaixa() {
  console.log('🔧 EXECUTANDO CORREÇÃO DO MÓDULO CAIXA')
  console.log('===================================')

  try {
    // Verificar primeiro se as tabelas já existem
    console.log('📋 Verificando tabelas existentes...')
    
    const { data: caixaExists, error: caixaError } = await supabase
      .from('caixa')
      .select('id')
      .limit(1)
    
    const { data: movExists, error: movError } = await supabase
      .from('movimentacoes_caixa')
      .select('id')
      .limit(1)
    
    if (!caixaError && !movError) {
      console.log('✅ Tabelas já existem!')
      console.log('ℹ️  Tabela caixa: EXISTE')
      console.log('ℹ️  Tabela movimentacoes_caixa: EXISTE')
      
      // Testar uma função
      console.log('\n🧪 Testando funções...')
      try {
        const { data, error } = await supabase.rpc('usuario_tem_caixa_aberto', {
          user_id: '00000000-0000-0000-0000-000000000000'
        })
        
        if (!error) {
          console.log('✅ Funções funcionando!')
        } else {
          console.log('⚠️  Funções podem precisar ser recriadas:', error.message)
        }
      } catch (err) {
        console.log('⚠️  Algumas funções podem estar faltando')
      }
      
      return
    }
    
    console.log('❌ Tabelas não encontradas. Precisa executar o SQL manualmente.')
    console.log('')
    console.log('🎯 AÇÃO NECESSÁRIA:')
    console.log('1. Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql')
    console.log('2. Cole o SQL completo do arquivo fix-caixa-complete.sql')
    console.log('3. Clique em Run')
    console.log('4. Aguarde as mensagens de confirmação')
    console.log('')
    console.log('📄 O SQL está pronto no arquivo fix-caixa-complete.sql')
    
  } catch (error) {
    console.error('❌ Erro na verificação:', error.message)
    console.log('')
    console.log('🎯 EXECUTE MANUALMENTE:')
    console.log('https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql')
  }
}

executarCorrecaoCaixa()
