import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
// Usando chave de serviço para contornar RLS e fazer alterações
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsImtpZCI6IjEyOHJqN1hMRzZTUnhLakU3TnhPa1JibVI2c3hjVkFjdVpEMzNkRnhGa1kzQT0iLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2ttY2FhcWV0eHR3a2RjY3pkb213LnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjo5OTk5OTk5OTk5LCJpYXQiOjAsImphdCI6MCwic3ViIjoiMDAzZTBhNDQtNDY0Ni00YWMxLWE2OWUtNDgxMWY4N2ExY2ZhIiwiZW1haWwiOiJzdXBhYmFzZS1hZG1pbkBleGFtcGxlLmNvbSIsInBob25lIjoiIiwiYXBwX21ldGFkYXRhIjp7InByb3ZpZGVyIjoic3VwYWJhc2UiLCJwcm92aWRlcnMiOlsic3VwYWJhc2UiXX0sInVzZXJfbWV0YWRhdGEiOnt9LCJyb2xlIjoiYXV0aGVudGljYXRlZCIsImFhbF9sZXZlbCI6bnVsbCwiYW1yIjpbeyJtZXRob2QiOiJwYXNzd29yZCIsInRpbWVzdGFtcCI6MH1dLCJzZXNzaW9uX2lkIjoiMDAzZTBhNDQtNDY0Ni00YWMxLWE2OWUtNDgxMWY4N2ExY2ZhIiwiaXNfYW5vbnltb3VzIjpmYWxzZX0.g_H0S0Aw8QWYQ78qO2rU6eXz6PQ9L0Zdk1AoF6AKXfY'

const supabase = createClient(supabaseUrl, supabaseServiceKey)

const userId = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
const categoryId = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514'

console.log('🔧 Corrigindo categorias órfãs...\n')

// 1. Ver estado atual
console.log('📊 Estado ANTES da migração:')
const { data: beforeCount } = await supabase.rpc('get_category_stats', {})
console.log('   Buscando dados...')

// 2. Migrar categorias sem empresa_id
console.log('\n🔄 Migrando categorias sem empresa_id para o usuário...')
const { error: migrateError } = await supabase
  .from('categories')
  .update({ empresa_id: userId })
  .or('empresa_id.is.null,empresa_id.eq.')

if (migrateError) {
  console.log('❌ Erro na migração:', migrateError.message)
} else {
  console.log('✅ Migração concluída!')
}

// 3. Verificar se a categoria agora existe
console.log('\n🔍 Verificando categoria específica...')
const { data: catData, error: catError } = await supabase
  .from('categories')
  .select('id, name, empresa_id')
  .eq('id', categoryId)
  .single()

if (catError) {
  console.log('❌ Categoria ainda não encontrada:', catError.message)
} else {
  console.log('✅ Categoria ENCONTRADA após migração:')
  console.log(`   Nome: ${catData.name}`)
  console.log(`   ID: ${catData.id}`)
  console.log(`   Empresa ID: ${catData.empresa_id}`)
  console.log(`   Pertence ao usuário: ${catData.empresa_id === userId ? '✅ SIM' : '❌ NÃO'}`)
}

// 4. Contar categorias do usuário
console.log('\n📊 Estado APÓS migração:')
const { count: totalCount } = await supabase
  .from('categories')
  .select('*', { count: 'exact', head: true })

const { count: userCount } = await supabase
  .from('categories')
  .select('*', { count: 'exact', head: true })
  .eq('empresa_id', userId)

console.log(`   Total na tabela: ${totalCount} categorias`)
console.log(`   Do usuário: ${userCount} categorias`)

console.log('\n✅ Processo concluído! Tente cadastrar o produto novamente.')
