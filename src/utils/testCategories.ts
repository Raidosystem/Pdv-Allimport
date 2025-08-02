import { supabase } from '../lib/supabase'

// Teste de conectividade e estrutura da tabela categories
export async function testCategoryOperations() {
  console.log('🔍 Testando operações de categoria...')
  
  try {
    // 1. Testar se conseguimos conectar e ler categorias
    console.log('📖 Testando leitura de categorias...')
    const { data: categories, error: readError } = await supabase
      .from('categories')
      .select('*')
      .limit(5)
    
    if (readError) {
      console.error('❌ Erro ao ler categorias:', readError)
      return { success: false, error: readError }
    }
    
    console.log('✅ Leitura bem-sucedida. Categorias existentes:', categories)
    
    // 2. Testar criação de categoria
    console.log('📝 Testando criação de categoria...')
    const testCategoryName = `Teste-${Date.now()}`
    
    const { data: newCategory, error: createError } = await supabase
      .from('categories')
      .insert([{ name: testCategoryName }])
      .select()
      .single()
    
    if (createError) {
      console.error('❌ Erro ao criar categoria:', createError)
      return { success: false, error: createError }
    }
    
    console.log('✅ Categoria criada com sucesso:', newCategory)
    
    // 3. Testar exclusão da categoria teste
    console.log('🗑️ Limpando categoria teste...')
    const { error: deleteError } = await supabase
      .from('categories')
      .delete()
      .eq('id', newCategory.id)
    
    if (deleteError) {
      console.error('⚠️ Erro ao limpar categoria teste:', deleteError)
    } else {
      console.log('✅ Categoria teste removida com sucesso')
    }
    
    return { success: true, categories, newCategory }
    
  } catch (error) {
    console.error('💥 Erro geral no teste:', error)
    return { success: false, error }
  }
}

// Função para verificar estrutura da tabela
export async function checkCategoryTableStructure() {
  try {
    // Tentar inserir uma categoria com dados mínimos para ver quais campos são obrigatórios
    const { data, error } = await supabase
      .from('categories')
      .insert([{ name: 'Test Structure' }])
      .select()
    
    if (error) {
      console.error('Estrutura da tabela categories:', error)
      
      // Verificar se a tabela existe
      if (error.message?.includes('does not exist')) {
        console.error('❌ A tabela "categories" não existe no banco de dados')
        return { tableExists: false, error }
      }
      
      // Verificar campos obrigatórios
      if (error.message?.includes('null value')) {
        console.error('❌ Campos obrigatórios ausentes:', error.message)
        return { tableExists: true, missingFields: true, error }
      }
      
      return { tableExists: true, error }
    }
    
    // Limpar o registro teste
    if (data && data.length > 0) {
      await supabase.from('categories').delete().eq('id', data[0].id)
    }
    
    console.log('✅ Estrutura da tabela categories está correta')
    return { tableExists: true, structure: data }
    
  } catch (error) {
    console.error('Erro ao verificar estrutura:', error)
    return { error }
  }
}
