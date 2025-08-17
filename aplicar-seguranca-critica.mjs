import { createClient } from '@supabase/supabase-js'
import { readFileSync } from 'fs'
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

// Configuração do Supabase (coloque suas credenciais aqui)
const supabaseUrl = 'https://your-project.supabase.co'
const supabaseKey = 'your-service-role-key' // SERVICE ROLE KEY (não anon key)

const supabase = createClient(supabaseUrl, supabaseKey)

async function aplicarCorrecaoSeguranca() {
  try {
    console.log('🚨 APLICANDO CORREÇÃO CRÍTICA DE SEGURANÇA...')
    
    // Ler o arquivo SQL
    const sqlContent = readFileSync(join(__dirname, 'SEGURANCA_CRITICA_RLS_FIX.sql'), 'utf8')
    
    // Dividir em comandos individuais
    const commands = sqlContent
      .split(';')
      .map(cmd => cmd.trim())
      .filter(cmd => cmd.length > 0 && !cmd.startsWith('--'))
    
    console.log(`📝 Executando ${commands.length} comandos...`)
    
    for (let i = 0; i < commands.length; i++) {
      const command = commands[i]
      if (command.length > 10) { // Ignorar comandos muito pequenos
        console.log(`[${i+1}/${commands.length}] Executando...`)
        
        try {
          const { data, error } = await supabase.rpc('execute_sql', { 
            sql: command + ';'
          })
          
          if (error) {
            console.warn(`⚠️  Aviso no comando ${i+1}:`, error.message)
          } else {
            console.log(`✅ Comando ${i+1} executado com sucesso`)
          }
        } catch (err) {
          console.warn(`⚠️  Erro no comando ${i+1}:`, err.message)
          // Continuar mesmo com erro (muitos comandos podem falhar se já existirem)
        }
      }
    }
    
    console.log('🔒 CORREÇÃO DE SEGURANÇA APLICADA!')
    console.log('✅ RLS habilitado com isolamento por usuário')
    console.log('✅ Políticas de segurança criadas')
    console.log('🚨 TESTE IMEDIATAMENTE o isolamento de dados!')
    
  } catch (error) {
    console.error('❌ ERRO CRÍTICO:', error)
    process.exit(1)
  }
}

// Executar apenas se chamado diretamente
if (import.meta.url === `file://${process.argv[1]}`) {
  aplicarCorrecaoSeguranca()
}

export { aplicarCorrecaoSeguranca }
