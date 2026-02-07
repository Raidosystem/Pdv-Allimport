// Script para aplicar o upgrade do sistema profissional via API
import { createClient } from '@supabase/supabase-js'
import fs from 'fs'

const supabaseUrl = 'https://wcpgkyeqrbfhcrvklcib.supabase.co'
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY

// Lê o arquivo SQL de upgrade
const sqlUpgrade = fs.readFileSync('./setup-admin-professional-upgrade.sql', 'utf8')

const supabase = createClient(supabaseUrl, supabaseKey)

async function applyUpgrade() {
  try {
    console.log('🔄 Aplicando upgrade do sistema profissional...')
    
    // Divide o SQL em statements individuais
    const statements = sqlUpgrade
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 0 && !s.startsWith('--'))
    
    for (const statement of statements) {
      if (statement.includes('CREATE TABLE') || statement.includes('CREATE OR REPLACE')) {
        console.log(`📝 Executando: ${statement.substring(0, 50)}...`)
        
        const { error } = await supabase.rpc('exec_sql', { 
          sql: statement + ';' 
        })
        
        if (error) {
          console.error('❌ Erro:', error.message)
        } else {
          console.log('✅ Sucesso')
        }
      }
    }
    
    console.log('🎉 Upgrade concluído!')
    
  } catch (error) {
    console.error('💥 Erro geral:', error.message)
  }
}

applyUpgrade()