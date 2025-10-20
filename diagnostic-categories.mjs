import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kwhjofzwwhvxrhzegxtw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt3aGpvZnp3d2h2eHJoemVneHR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjMyMDI5NzUsImV4cCI6MTg4MDk3MDk3NX0.Ym_VvGC6dxm_aLSp1tpDqhqj0EhJW-3UoKJNrOZXjZs'

const supabase = createClient(supabaseUrl, supabaseKey)

async function diagnostic() {
  console.log('🔍 DIAGNÓSTICO DE CATEGORIAS\n')

  // 1. Fazer login como o usuário
  console.log('1️⃣ Fazendo login como assistenciaallimport10@gmail.com...')
  const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
    email: 'assistenciaallimport10@gmail.com',
    password: 'Allimport@2025' // Senha padrão
  })

  if (signInError || !signInData.user) {
    console.log('   ❌ Erro ao fazer login')
    console.log('   Erro:', signInError?.message)
    return
  }

  const userId = signInData.user.id
  console.log(`   ✅ Login bem-sucedido. User ID: ${userId}`)

  // 2. Verificar categorias no banco
  console.log(`\n2️⃣ Buscando categorias para empresa_id = ${userId}...`)
  const { data: categories, error: catError } = await supabase
    .from('categories')
    .select('*')
    .eq('empresa_id', userId)

  if (catError) {
    console.log('   ❌ Erro ao buscar categorias:', catError)
    return
  }

  console.log(`   ✅ Categorias encontradas: ${categories?.length || 0}`)
  if (categories && categories.length > 0) {
    console.log('   📋 Categorias:')
    categories.forEach(cat => {
      console.log(`      - ${cat.name} (ID: ${cat.id})`)
    })
  } else {
    console.log('   ⚠️ NENHUMA CATEGORIA ENCONTRADA!')
  }

  // 3. Verificar estrutura da tabela
  console.log(`\n3️⃣ Verificando estrutura da tabela categories...`)
  const { data: tableInfo, error: tableError } = await supabase
    .rpc('get_table_structure', { table_name: 'categories' })
    .catch(err => ({ data: null, error: err }))

  if (!tableError && tableInfo) {
    console.log('   ✅ Colunas da tabela:')
    tableInfo.forEach(col => {
      console.log(`      - ${col.column_name}: ${col.data_type}`)
    })
  } else {
    console.log('   ℹ️ Não foi possível verificar estrutura com RPC')
  }

  // 4. Contar total de categorias no banco
  console.log(`\n4️⃣ Total de categorias em todo o banco...`)
  const { data: allCats, error: allCatsError } = await supabase
    .from('categories')
    .select('id, name, empresa_id', { count: 'exact' })

  if (!allCatsError && allCats) {
    console.log(`   ✅ Total: ${allCats.length} categorias`)
    console.log('   📊 Distribuição por empresa_id:')
    const byEmpresa = {}
    allCats.forEach(cat => {
      const empId = cat.empresa_id || 'NULL'
      byEmpresa[empId] = (byEmpresa[empId] || 0) + 1
    })
    Object.entries(byEmpresa).forEach(([empId, count]) => {
      console.log(`      - ${empId}: ${count} categorias`)
    })
  }
}

diagnostic().catch(console.error)
