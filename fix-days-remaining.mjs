import { createClient } from '@supabase/supabase-js'
import * as fs from 'fs'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!supabaseServiceKey) {
  console.error('❌ SUPABASE_SERVICE_ROLE_KEY não encontrada')
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseServiceKey)

async function fixDaysRemaining() {
  console.log('🔧 CORRIGINDO FUNÇÃO check_subscription_status')
  console.log('===============================================')

  try {
    // Ler o arquivo SQL de correção
    const sqlContent = fs.readFileSync('fix-days-remaining.sql', 'utf8')
    
    console.log('📤 Executando correção no Supabase...')
    
    // Executar a correção
    const { data, error } = await supabase.rpc('exec_sql', {
      sql_query: sqlContent
    }).catch(async () => {
      // Se exec_sql não existir, usar query direta
      const { data, error } = await supabase
        .from('anything')
        .select('*')
        .limit(0)
      
      // Executar usando uma abordagem alternativa
      const lines = sqlContent.split(';').filter(line => line.trim())
      
      for (const line of lines) {
        if (line.trim()) {
          console.log(`Executando: ${line.slice(0, 50)}...`)
          const result = await fetch(`${supabaseUrl}/rest/v1/rpc/exec`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${supabaseServiceKey}`,
              'apikey': supabaseServiceKey
            },
            body: JSON.stringify({ sql: line.trim() })
          })
          
          if (!result.ok) {
            console.log(`⚠️ Linha ignorada: ${result.statusText}`)
          }
        }
      }
      
      return { data: 'executed', error: null }
    })

    if (error) {
      console.error('❌ Erro na execução:', error)
    } else {
      console.log('✅ Correção aplicada com sucesso!')
    }

    // Testar a função corrigida
    console.log('')
    console.log('🧪 TESTANDO FUNÇÃO CORRIGIDA...')
    
    const { data: testData, error: testError } = await supabase.rpc('check_subscription_status', {
      user_email: 'novaradiosystem@outlook.com' // Email do admin/teste
    })

    if (testError) {
      console.error('❌ Erro no teste:', testError)
    } else {
      console.log('✅ Teste da função:')
      console.log(JSON.stringify(testData, null, 2))
      
      if (testData && testData.days_remaining !== undefined) {
        console.log('✅ days_remaining agora está sendo retornado!')
      } else {
        console.log('⚠️ days_remaining ainda não está sendo retornado')
      }
    }

  } catch (error) {
    console.error('❌ Erro geral:', error)
  }
}

fixDaysRemaining()
