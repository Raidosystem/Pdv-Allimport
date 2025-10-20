import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsImtpZCI6Ijg5bHFQVVdqT3pZdnNjNm5rUGw2aWFmNVBPUmciLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2ttY2FhcWV0eHR3a2RjY3pkb213LnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzYwOTk3NTk5LCJpYXQiOjE3NjA0OTA3OTksImF1dGhfdGltZSI6MTc2MDQ5MDc5OSwianRpIjoiYzc3YWIyOWUtZDA3Yi00OTA3LWEwOGMtOGQ5YzM4MjJmNDAwIiwic3ViIjoiZjdmZGY0Y2YtNzEwMS00NWFiLTg2ZGItNTI0OGE3YWM1OGMxIiwiYWF0X2hhc2giOiI3Z0dtMEZFUzhraHNJaHllUl9qQ3B4c1Qtc3dkM1UyaWY1QnlabnNZWWY4IiwiY2xhc3NlcyI6IkFVVCIsImVtYWlsIjoiYXNzaXN0ZW5jaWFhbGxpbXBvcnQxMEBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiY29tcGFueV9uYW1lIjoiQXNzaXN0ZW5jaWEgQWxsLWltcG9ydCIsImZ1bGxfbmFtZSI6IkNyaXN0aWFubyBSYW1vcyBNZW5kZXMiLCJpc190ZXJyYV9jbGllbnQiOmZhbHNlfQ.7gGm0FES8kfsIhyeR_jCpxsT-swd3U2if5ByZnsYYf8'

const supabase = createClient(supabaseUrl, supabaseKey)

const { data: { user } } = await supabase.auth.getUser()
console.log('👤 Usuário logado:', user?.email)
console.log('🆔 User ID:', user?.id)

// Buscar a categoria específica
const categoryId = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514'

console.log('\n🔍 Buscando categoria com ID:', categoryId)

// Busca SEM RLS - direto na tabela
const { data: catDirect, error: catDirError } = await supabase
  .from('categories')
  .select('*')
  .eq('id', categoryId)
  .single()

if (catDirError) {
  console.log('❌ Categoria NÃO encontrada:', catDirError.message)
} else {
  console.log('✅ Categoria encontrada (pode estar em outra empresa):', {
    id: catDirect.id,
    name: catDirect.name,
    empresa_id: catDirect.empresa_id,
    pertence_ao_usuario: catDirect.empresa_id === user?.id ? '✅ SIM' : '❌ NÃO'
  })
}

// Listar categorias do usuário
console.log('\n📋 Categorias filtradas por empresa_id (USER ID):')
const { data: userCats } = await supabase
  .from('categories')
  .select('id, name')
  .eq('empresa_id', user?.id)
  .limit(5)

console.log(`✅ Total: ${userCats?.length || 0} categorias do usuário`)
userCats?.forEach(cat => {
  const mark = cat.id === categoryId ? ' 🎯' : ''
  console.log(`   - ${cat.name} (${cat.id.substring(0, 8)}...)${mark}`)
})

