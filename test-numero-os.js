import { createClient } from '@supabase/supabase-js'
import 'dotenv/config'

const supabaseUrl = process.env.VITE_SUPABASE_URL
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY

const supabase = createClient(supabaseUrl, supabaseKey)

async function testNumeroOSGeneration() {
  try {
    console.log('🔢 Testando geração de número de OS...')
    
    // Simular a função de geração de número
    const agora = new Date()
    const ano = agora.getFullYear()
    const mes = String(agora.getMonth() + 1).padStart(2, '0')
    const dia = String(agora.getDate()).padStart(2, '0')
    
    console.log(`📅 Data atual: ${ano}-${mes}-${dia}`)
    
    // Buscar a última OS do dia para incrementar
    const inicioDia = new Date(ano, agora.getMonth(), agora.getDate())
    const fimDia = new Date(ano, agora.getMonth(), agora.getDate() + 1)
    
    console.log(`🔍 Buscando OS entre ${inicioDia.toISOString()} e ${fimDia.toISOString()}`)
    
    const { data: ultimasOS, error } = await supabase
      .from('ordens_servico')
      .select('numero_os')
      .gte('criado_em', inicioDia.toISOString())
      .lt('criado_em', fimDia.toISOString())
      .order('numero_os', { ascending: false })
      .limit(1)
    
    if (error) {
      console.error('❌ Erro ao buscar OS:', error.message)
      return false
    }
    
    console.log(`📊 Últimas OS encontradas:`, ultimasOS)
    
    let sequencial = 1
    if (ultimasOS && ultimasOS.length > 0) {
      const ultimoNumero = ultimasOS[0].numero_os
      console.log(`🔢 Último número encontrado: ${ultimoNumero}`)
      
      // Extrair o número sequencial do formato OS-YYYYMMDD-XXX
      const match = ultimoNumero.match(/OS-\d{8}-(\d+)/)
      if (match) {
        sequencial = parseInt(match[1]) + 1
        console.log(`➕ Próximo sequencial: ${sequencial}`)
      }
    }
    
    const numeroSequencial = String(sequencial).padStart(3, '0')
    const numeroOS = `OS-${ano}${mes}${dia}-${numeroSequencial}`
    
    console.log(`✅ Número de OS gerado: ${numeroOS}`)
    
    return true
    
  } catch (err) {
    console.error('❌ Erro geral:', err.message)
    return false
  }
}

testNumeroOSGeneration()
  .then(success => {
    if (success) {
      console.log('\n✅ Teste de geração de número OS concluído!')
      console.log('🚀 Agora teste criar uma OS na aplicação')
    } else {
      console.log('\n❌ Teste falhou')
    }
    process.exit(success ? 0 : 1)
  })
