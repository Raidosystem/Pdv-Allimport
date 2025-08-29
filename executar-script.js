const { createClient } = require('@supabase/supabase-js')
const fs = require('fs')
const path = require('path')

// Configuração do Supabase
const supabaseUrl = 'https://YOUR_SUPABASE_PROJECT.supabase.co'
const supabaseKey = 'YOUR_SUPABASE_ANON_KEY'

// Criar cliente Supabase
const supabase = createClient(supabaseUrl, supabaseKey)

async function executarScript() {
  try {
    console.log('🔗 Conectando ao Supabase...')
    
    // Ler o script SQL
    const sqlScript = fs.readFileSync(path.join(__dirname, 'DEPLOY_FINAL.sql'), 'utf8')
    
    console.log('📄 Script carregado, executando...')
    
    // Executar o script (dividindo em partes se necessário)
    const commands = sqlScript
      .split(';')
      .map(cmd => cmd.trim())
      .filter(cmd => cmd.length > 0 && !cmd.startsWith('--'))
    
    console.log(`📊 Executando ${commands.length} comandos...`)
    
    for (let i = 0; i < commands.length; i++) {
      const command = commands[i]
      if (command.includes('SELECT') && command.includes('as info')) {
        // Este é um comando de verificação, executar com rpc
        console.log(`✅ Executando verificação ${i + 1}/${commands.length}`)
        const { data, error } = await supabase.rpc('exec_sql', { sql: command })
        if (error) {
          console.error(`❌ Erro no comando ${i + 1}:`, error.message)
        } else {
          console.log(`📋 Resultado:`, data)
        }
      } else if (command.trim().length > 0) {
        // Comando DDL/DML
        console.log(`⚡ Executando comando ${i + 1}/${commands.length}`)
        const { data, error } = await supabase.rpc('exec_sql', { sql: command })
        if (error) {
          console.error(`❌ Erro no comando ${i + 1}:`, error.message)
        } else {
          console.log(`✅ Comando ${i + 1} executado com sucesso`)
        }
      }
    }
    
    console.log('🎉 Script executado com sucesso!')
    
  } catch (error) {
    console.error('❌ Erro ao executar script:', error.message)
  }
}

// Executar
executarScript()
