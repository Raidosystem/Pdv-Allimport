import { supabase } from '../lib/supabase'

// SQL para criar a tabela categories
export const createCategoriesTableSQL = `
-- Criar tabela categories se não existir
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Criar índice para busca por nome
CREATE INDEX IF NOT EXISTS idx_categories_name ON public.categories(name);

-- Habilitar RLS (Row Level Security)
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- Política para permitir leitura para usuários autenticados
CREATE POLICY IF NOT EXISTS "Permitir leitura de categorias para usuários autenticados" 
ON public.categories FOR SELECT 
TO authenticated 
USING (true);

-- Política para INSERT (usuários autenticados podem criar)
CREATE POLICY "Usuários autenticados podem criar categorias" ON categories
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Política para UPDATE (usuários autenticados podem editar)
CREATE POLICY "Usuários autenticados podem editar categorias" ON categories
  FOR UPDATE USING (auth.uid() IS NOT NULL);

-- Política para DELETE (usuários autenticados podem deletar)
CREATE POLICY "Usuários autenticados podem deletar categorias" ON categories
  FOR DELETE USING (auth.uid() IS NOT NULL);
`

// Função para executar a criação da tabela via RPC
export async function createCategoriesTable() {
  try {
    console.log('🔧 Criando tabela categories...')
    
    // Tentar executar o SQL via RPC (se disponível)
    const { data, error } = await supabase.rpc('exec_sql', { 
      sql_query: createCategoriesTableSQL 
    })
    
    if (error) {
      console.error('❌ Erro ao criar tabela via RPC:', error)
      return { success: false, error }
    }
    
    console.log('✅ Tabela categories criada com sucesso via RPC')
    return { success: true, data }
    
  } catch (error) {
    console.error('❌ Erro ao criar tabela categories:', error)
    return { success: false, error }
  }
}

// Inserir categorias padrão
export async function insertDefaultCategories() {
  const defaultCategories = [
    { name: 'Eletrônicos', description: 'Produtos eletrônicos e gadgets' },
    { name: 'Informática', description: 'Computadores, periféricos e acessórios' },
    { name: 'Casa e Jardim', description: 'Produtos para casa e jardim' },
    { name: 'Roupas e Acessórios', description: 'Vestuário e acessórios pessoais' },
    { name: 'Esportes', description: 'Equipamentos e acessórios esportivos' },
    { name: 'Livros', description: 'Livros e material de leitura' },
    { name: 'Saúde e Beleza', description: 'Produtos de saúde e cosméticos' },
    { name: 'Alimentação', description: 'Alimentos e bebidas' }
  ]
  
  try {
    console.log('📝 Inserindo categorias padrão...')
    
    for (const category of defaultCategories) {
      const { error } = await supabase
        .from('categories')
        .upsert([category], { 
          onConflict: 'name',
          ignoreDuplicates: true 
        })
      
      if (error) {
        console.error(`❌ Erro ao inserir categoria "${category.name}":`, error)
      } else {
        console.log(`✅ Categoria "${category.name}" inserida/atualizada`)
      }
    }
    
    return { success: true }
    
  } catch (error) {
    console.error('❌ Erro ao inserir categorias padrão:', error)
    return { success: false, error }
  }
}

// Função simplificada para criar categoria
export async function fixCategoryPolicies() {
  try {
    console.log('🔧 Testando acesso à tabela categories...')
    
    // Primeiro, tentar uma query simples para verificar acesso
    const { error } = await supabase
      .from('categories')
      .select('id')
      .limit(1)
    
    if (error) {
      console.error('Erro de acesso:', error)
      return { 
        success: false, 
        error: error.message,
        suggestion: 'Execute este SQL no painel do Supabase:\n\n' +
          '-- Remover política antiga\n' +
          'DROP POLICY IF EXISTS "Usuários autenticados podem criar categorias" ON public.categories;\n\n' +
          '-- Criar política correta\n' +
          'CREATE POLICY "Usuários autenticados podem criar categorias"\n' +
          'ON public.categories\n' +
          'FOR INSERT\n' +
          'TO authenticated\n' +
          'WITH CHECK (auth.uid() IS NOT NULL);'
      }
    }
    
    console.log('✅ Acesso à tabela OK')
    
    // Tentar criar uma categoria teste
    const testName = `test_${Date.now()}`
    const { error: insertError } = await supabase
      .from('categories')
      .insert({ name: testName })
    
    if (insertError) {
      console.error('Erro ao inserir:', insertError)
      return { 
        success: false, 
        error: insertError.message,
        suggestion: 'Política RLS bloqueando inserção. Execute no Supabase:\n\n' +
          '-- Remover política antiga\n' +
          'DROP POLICY IF EXISTS "Usuários autenticados podem criar categorias" ON public.categories;\n\n' +
          '-- Criar política correta\n' +
          'CREATE POLICY "Usuários autenticados podem criar categorias"\n' +
          'ON public.categories\n' +
          'FOR INSERT\n' +
          'TO authenticated\n' +
          'WITH CHECK (auth.uid() IS NOT NULL);'
      }
    }
    
    // Limpar categoria teste
    await supabase
      .from('categories')
      .delete()
      .eq('name', testName)
    
    console.log('✅ Políticas funcionando corretamente!')
    return { success: true }
    
  } catch (error) {
    console.error('Erro ao testar políticas:', error)
    return { success: false, error: error instanceof Error ? error.message : String(error) }
  }
}

export async function createCategorySimple(name: string) {
  try {
    console.log(`📝 Criando categoria: ${name}`)
    
    const { data, error } = await supabase
      .from('categories')
      .insert([{ name: name.trim() }])
      .select()
      .single()
    
    if (error) {
      console.error('❌ Erro ao criar categoria:', error)
      throw error
    }
    
    console.log('✅ Categoria criada:', data)
    return data
    
  } catch (error) {
    console.error('💥 Erro na criação da categoria:', error)
    throw error
  }
}
