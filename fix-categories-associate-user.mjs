import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = 'https://kwhjofzwwhvxrhzegxtw.supabase.co'
const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt3aGpvZnp3d2h2eHJoemVneHR3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyMzIwMjk3NSwiZXhwIjoxODgwOTcwOTc1fQ.07x_Sq36c5y8t5ByF7Y3vx27kMfPXGLNx-EqaVbcF50'

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY)

async function fixCategories() {
  console.log('🔧 CORRIGINDO CATEGORIAS\n')

  const userId = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  const userEmail = 'assistenciaallimport10@gmail.com'

  try {
    // 1. Contar categorias com empresa_id = NULL
    console.log('1️⃣ Contando categorias com empresa_id = NULL...')
    const { data: nullCats, error: countError } = await supabase
      .from('categories')
      .select('id', { count: 'exact' })
      .is('empresa_id', null)

    if (countError) {
      console.error('❌ Erro ao contar:', countError)
      return
    }

    const nullCount = nullCats?.length || 0
    console.log(`   ℹ️ Categorias sem empresa_id: ${nullCount}\n`)

    if (nullCount === 0) {
      console.log('✅ Nenhuma categoria para corrigir!')
      return
    }

    // 2. Atualizar todas as categorias para associar ao usuário
    console.log('2️⃣ Atualizando categorias...')
    const { data: updateData, error: updateError, count } = await supabase
      .from('categories')
      .update({ empresa_id: userId })
      .is('empresa_id', null)
      .select('id, name, empresa_id')

    if (updateError) {
      console.error('❌ Erro ao atualizar:', updateError)
      return
    }

    console.log(`✅ ${updateData?.length || 0} categorias atualizadas!\n`)

    // 3. Listar as categorias atualizadas
    console.log('3️⃣ Listando categorias agora associadas ao usuário:')
    console.log('━'.repeat(80))
    updateData?.forEach((cat, idx) => {
      console.log(`${idx + 1}. ${cat.name}`)
    })
    console.log('━'.repeat(80))

    // 4. Verificar o resultado
    console.log('\n4️⃣ Verificando resultado final...')
    const { data: finalCheck, error: finalError, count: finalCount } = await supabase
      .from('categories')
      .select('id', { count: 'exact' })
      .eq('empresa_id', userId)

    if (finalError) {
      console.error('❌ Erro ao verificar:', finalError)
      return
    }

    console.log(`✅ TOTAL DE CATEGORIAS PARA O USUÁRIO ${userEmail}: ${finalCount || 0}`)
    console.log('✅ TUDO CORRIGIDO COM SUCESSO!')

  } catch (error) {
    console.error('💥 Erro inesperado:', error)
  }
}

fixCategories()
