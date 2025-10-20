import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
// Usando a chave de serviço para contornar RLS
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsImtpZCI6IjEyOHJqN1hMRzZTUnhLakU3TnhPa1JibVI2c3hjVkFjdVpEMzNkRnhGa1kzQT0iLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2ttY2FhcWV0eHR3a2RjY3pkb213LnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjo5OTk5OTk5OTk5LCJpYXQiOjAsImphdCI6MCwic3ViIjoiMDAzZTBhNDQtNDY0Ni00YWMxLWE2OWUtNDgxMWY4N2ExY2ZhIiwiZW1haWwiOiJzdXBhYmFzZS1hZG1pbkBleGFtcGxlLmNvbSIsInBob25lIjoiIiwiYXBwX21ldGFkYXRhIjp7InByb3ZpZGVyIjoic3VwYWJhc2UiLCJwcm92aWRlcnMiOlsic3VwYWJhc2UiXX0sInVzZXJfbWV0YWRhdGEiOnt9LCJyb2xlIjoiYXV0aGVudGljYXRlZCIsImFhbF9sZXZlbCI6bnVsbCwiYW1yIjpbeyJtZXRob2QiOiJwYXNzd29yZCIsInRpbWVzdGFtcCI6MH1dLCJzZXNzaW9uX2lkIjoiMDAzZTBhNDQtNDY0Ni00YWMxLWE2OWUtNDgxMWY4N2ExY2ZhIiwiaXNfYW5vbnltb3VzIjpmYWxzZX0.g_H0S0Aw8QWYQ78qO2rU6eXz6PQ9L0Zdk1AoF6AKXfY'

const supabase = createClient(supabaseUrl, supabaseServiceKey)

console.log('🔍 Verificando estrutura da tabela categorias...\n')

// Buscar informações sobre as colunas
const { data, error } = await supabase
  .from('categories')
  .select('*')
  .limit(1)

if (error) {
  console.log('❌ Erro:', error)
} else {
  console.log('✅ Estrutura da tabela categories:')
  console.log('Colunas:', Object.keys(data[0] || {}))
}

// Buscar categoria específica
console.log('\n🔍 Buscando categoria ba8e7253-6b02-4a1c-b3c8-77ff78618514...')
const { data: cat, error: err2 } = await supabase
  .from('categories')
  .select('*')
  .eq('id', 'ba8e7253-6b02-4a1c-b3c8-77ff78618514')
  .single()

if (err2) {
  console.log('❌ Não encontrada:', err2.message)
} else {
  console.log('✅ Categoria encontrada:')
  console.log(JSON.stringify(cat, null, 2))
}

// Contar total de categorias
console.log('\n📊 Total de categorias na tabela:')
const { count, error: err3 } = await supabase
  .from('categories')
  .select('*', { count: 'exact', head: true })

console.log(`✅ Total: ${count} categorias`)

// Amostra de empresas/usuários nas categorias
console.log('\n📋 Amostra de categorias (primeiras 5):')
const { data: sample } = await supabase
  .from('categories')
  .select('id, name, empresa_id')
  .limit(5)

sample?.forEach(cat => {
  console.log(`   - ${cat.name} | empresa_id: ${cat.empresa_id?.substring(0, 8)}...`)
})

