// Vamos verificar a estrutura dos produtos usando fetch direto
console.log('🔍 VERIFICANDO ESTRUTURA DOS PRODUTOS...')

// Usando a API REST do Supabase
const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY1MTI5MTUsImV4cCI6MjA0MjA4ODkxNX0.OB3zd_QX6JkxBqfneMUWLzKUYpN4zMBW2g8MhmdY81o'

const verificarEstrutura = async () => {
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/produtos?limit=1`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      }
    })

    if (!response.ok) {
      console.error('❌ Erro na resposta:', response.status, response.statusText)
      return
    }

    const data = await response.json()
    
    if (data && data.length > 0) {
      const produto = data[0]
      console.log('📦 PRODUTO DE EXEMPLO:', produto.nome)
      console.log('\n🔍 TODOS OS CAMPOS DISPONÍVEIS:')
      
      Object.keys(produto).sort().forEach(key => {
        const value = produto[key]
        const type = typeof value
        console.log(`${key}: ${value} (${type})`)
      })
      
      console.log('\n📊 CAMPOS RELACIONADOS AO ESTOQUE:')
      const stockFields = Object.keys(produto).filter(key => 
        key.toLowerCase().includes('stock') || 
        key.toLowerCase().includes('estoque') ||
        key.toLowerCase().includes('quantidade') ||
        key.toLowerCase().includes('qty')
      )
      
      if (stockFields.length > 0) {
        stockFields.forEach(field => {
          console.log(`✅ ${field}: ${produto[field]}`)
        })
      } else {
        console.log('❌ Nenhum campo de estoque encontrado!')
        console.log('📋 Todos os campos:', Object.keys(produto).join(', '))
      }
    } else {
      console.log('❌ Nenhum produto encontrado')
    }
  } catch (error) {
    console.error('❌ Erro geral:', error.message)
  }
}

verificarEstrutura()