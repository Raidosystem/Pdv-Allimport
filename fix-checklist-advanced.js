import { createClient } from '@supabase/supabase-js'
import 'dotenv/config'

const supabaseUrl = process.env.VITE_SUPABASE_URL
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Variáveis de ambiente do Supabase não encontradas')
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseKey)

async function fixChecklistColumn() {
  try {
    console.log('🔍 Verificando estrutura da tabela ordens_servico...')
    
    // Primeiro, vamos tentar fazer uma query simples para ver se a tabela existe
    const { data: tables, error: tableError } = await supabase
      .from('ordens_servico')
      .select('*')
      .limit(1)
    
    if (tableError) {
      console.error('❌ Erro ao acessar tabela ordens_servico:', tableError.message)
      return false
    }
    
    console.log('✅ Tabela ordens_servico acessível')
    
    // Agora vamos tentar acessar especificamente a coluna checklist
    console.log('🔍 Testando acesso à coluna checklist...')
    
    const { data: checklistTest, error: checklistError } = await supabase
      .from('ordens_servico')
      .select('id, checklist')
      .limit(1)
    
    if (checklistError) {
      console.error('❌ Erro ao acessar coluna checklist:', checklistError.message)
      
      if (checklistError.message.includes("column") && checklistError.message.includes("checklist")) {
        console.log('💡 A coluna checklist não existe. Tentando criar...')
        
        // Tentar executar o SQL para criar a coluna
        const { data: sqlResult, error: sqlError } = await supabase.rpc('exec_sql', {
          sql: `
            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 
                    FROM information_schema.columns 
                    WHERE table_name = 'ordens_servico' 
                    AND column_name = 'checklist'
                    AND table_schema = 'public'
                ) THEN
                    ALTER TABLE public.ordens_servico 
                    ADD COLUMN checklist JSONB DEFAULT '{}';
                    
                    COMMENT ON COLUMN public.ordens_servico.checklist IS 'Checklist items for the service order stored as JSON';
                    
                    RAISE NOTICE 'Column checklist added to ordens_servico table';
                ELSE
                    RAISE NOTICE 'Column checklist already exists in ordens_servico table';
                END IF;
            END $$;
          `
        })
        
        if (sqlError) {
          console.error('❌ Erro ao executar SQL para criar coluna:', sqlError.message)
          console.log('\n📋 INSTRUÇÕES MANUAIS:')
          console.log('1. Acesse https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw')
          console.log('2. Vá para SQL Editor')
          console.log('3. Execute o seguinte comando:')
          console.log('\nALTER TABLE public.ordens_servico ADD COLUMN IF NOT EXISTS checklist JSONB DEFAULT \'{}\';')
          return false
        }
        
        console.log('✅ SQL executado com sucesso')
        
        // Testar novamente
        const { data: retestData, error: retestError } = await supabase
          .from('ordens_servico')
          .select('id, checklist')
          .limit(1)
        
        if (retestError) {
          console.error('❌ Ainda há erro após tentativa de criação:', retestError.message)
          return false
        }
        
        console.log('✅ Coluna checklist criada e funcionando!')
      }
      
      return false
    }
    
    console.log('✅ Coluna checklist existe e é acessível!')
    console.log('📊 Dados de teste:', checklistTest)
    
    // Teste de inserção para garantir que funciona
    console.log('🧪 Testando inserção com checklist...')
    
    const { data: insertData, error: insertError } = await supabase
      .from('ordens_servico')
      .insert({
        tipo: 'Celular',
        marca: 'TESTE',
        modelo: 'Equipamento de verificação',
        defeito_relatado: 'TESTE - Verificação da coluna checklist',
        status: 'Em análise',
        checklist: { 
          verificacao_concluida: true,
          timestamp: new Date().toISOString()
        }
      })
      .select()
    
    if (insertError) {
      console.error('❌ Erro ao inserir OS de teste:', insertError.message)
      return false
    }
    
    console.log('✅ Inserção com checklist funcionou!')
    console.log('📋 OS de teste criada:', insertData[0])
    
    // Limpar o teste
    if (insertData && insertData[0]) {
      const { error: deleteError } = await supabase
        .from('ordens_servico')
        .delete()
        .eq('id', insertData[0].id)
      
      if (!deleteError) {
        console.log('🧹 OS de teste removida com sucesso')
      }
    }
    
    return true
    
  } catch (err) {
    console.error('❌ Erro geral:', err.message)
    return false
  }
}

fixChecklistColumn()
  .then(success => {
    if (success) {
      console.log('\n🎉 TESTE CONCLUÍDO COM SUCESSO!')
      console.log('✅ A coluna checklist está funcionando corretamente')
      console.log('✅ Agora você pode criar ordens de serviço normalmente')
    } else {
      console.log('\n❌ TESTE FALHOU - Ação manual necessária')
      console.log('📋 Siga as instruções manuais mostradas acima')
    }
    process.exit(success ? 0 : 1)
  })
  .catch(err => {
    console.error('❌ Erro crítico:', err)
    process.exit(1)
  })
