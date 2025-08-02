import fs from 'fs'

// Configuração do Supabase
const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

async function executarSQL(sql) {
  try {
    console.log('🔗 Executando SQL via REST API...')
    
    const response = await fetch(`${supabaseUrl}/rest/v1/rpc/exec`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      },
      body: JSON.stringify({
        sql: sql
      })
    })
    
    if (!response.ok) {
      console.error('❌ Erro HTTP:', response.status, response.statusText)
      return false
    }
    
    const result = await response.json()
    console.log('✅ Resultado:', result)
    return true
    
  } catch (error) {
    console.error('❌ Erro na execução:', error.message)
    return false
  }
}

async function testarConexaoSimples() {
  console.log('🔗 Testando conexão simples...')
  
  try {
    const response = await fetch(`${supabaseUrl}/rest/v1/`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    })
    
    if (response.ok) {
      console.log('✅ Conexão com Supabase estabelecida!')
      return true
    } else {
      console.error('❌ Erro na conexão:', response.status)
      return false
    }
    
  } catch (error) {
    console.error('❌ Erro de rede:', error.message)
    return false
  }
}

async function executarScriptCompleto() {
  console.log('📄 Carregando script SQL...')
  
  try {
    const sqlScript = fs.readFileSync('DEPLOY_FINAL.sql', 'utf8')
    
    // Mostrar as primeiras linhas do script
    const linhas = sqlScript.split('\n').slice(0, 10)
    console.log('📋 Primeiras linhas do script:')
    linhas.forEach((linha, i) => {
      if (linha.trim()) console.log(`${i + 1}: ${linha}`)
    })
    
    console.log('\n🎯 Para executar o script, você precisará:')
    console.log('1. Ir para https://supabase.com/dashboard')
    console.log('2. Abrir o SQL Editor')
    console.log('3. Copiar e colar o conteúdo de DEPLOY_FINAL.sql')
    console.log('4. Clicar em Run')
    
    return true
    
  } catch (error) {
    console.error('❌ Erro ao ler arquivo:', error.message)
    return false
  }
}

// Executar
async function main() {
  const conectado = await testarConexaoSimples()
  if (conectado) {
    await executarScriptCompleto()
  }
}

main()
