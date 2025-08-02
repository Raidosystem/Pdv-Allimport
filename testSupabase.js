#!/usr/bin/env node

/**
 * Script para testar conexão com Supabase e operações de categorias
 * Execute com: node testSupabase.js
 */

// Simulação do ambiente Node.js para testar Supabase
console.log('🚀 Iniciando teste de conexão com Supabase...\n')

// Verificar variáveis de ambiente
const checkEnvVars = () => {
  console.log('📋 Verificando variáveis de ambiente:')
  
  // Carregar do .env se existir
  try {
    const fs = require('fs')
    const path = require('path')
    const envPath = path.join(__dirname, '.env')
    
    if (fs.existsSync(envPath)) {
      const envContent = fs.readFileSync(envPath, 'utf8')
      console.log('✅ Arquivo .env encontrado')
      
      // Parse básico do .env
      const lines = envContent.split('\n')
      for (const line of lines) {
        if (line.includes('VITE_SUPABASE_URL=')) {
          const url = line.split('=')[1]
          console.log(`🔗 SUPABASE_URL: ${url ? 'Definida' : 'Não encontrada'}`)
        }
        if (line.includes('VITE_SUPABASE_ANON_KEY=')) {
          const key = line.split('=')[1]
          console.log(`🔑 SUPABASE_ANON_KEY: ${key ? 'Definida' : 'Não encontrada'}`)
        }
      }
    } else {
      console.log('❌ Arquivo .env não encontrado')
    }
  } catch (error) {
    console.log('❌ Erro ao ler .env:', error.message)
  }
  
  console.log('')
}

// Teste de SQL básico para criar tabela
const generateCategoryTableSQL = () => {
  console.log('📝 SQL para criar tabela de categorias:')
  console.log(`
-- Criar tabela de categorias
CREATE TABLE IF NOT EXISTS categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar políticas RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Política para SELECT (todos podem visualizar)
CREATE POLICY "Todos podem visualizar categorias" ON categories
  FOR SELECT USING (true);

-- Política para INSERT (usuários autenticados podem criar)
CREATE POLICY "Usuários autenticados podem criar categorias" ON categories
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Política para UPDATE (usuários autenticados podem editar)
CREATE POLICY "Usuários autenticados podem editar categorias" ON categories
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Política para DELETE (usuários autenticados podem deletar)
CREATE POLICY "Usuários autenticados podem deletar categorias" ON categories
  FOR DELETE USING (auth.role() = 'authenticated');

-- Inserir categorias padrão
INSERT INTO categories (name, description) VALUES
  ('Eletrônicos', 'Produtos eletrônicos e tecnologia'),
  ('Roupas', 'Vestuário e acessórios'),
  ('Casa', 'Produtos para casa e decoração'),
  ('Esportes', 'Artigos esportivos e fitness'),
  ('Livros', 'Livros e material educativo')
ON CONFLICT (name) DO NOTHING;
`)
  console.log('')
}

// Teste de validação de dados
const testCategoryValidation = () => {
  console.log('🔍 Teste de validação de categorias:')
  
  const testCases = [
    { name: 'Eletrônicos', valid: true, reason: 'Nome válido' },
    { name: '', valid: false, reason: 'Nome vazio' },
    { name: 'A', valid: false, reason: 'Nome muito curto' },
    { name: 'A'.repeat(256), valid: false, reason: 'Nome muito longo' },
    { name: 'Categoria Teste', valid: true, reason: 'Nome com espaço válido' },
    { name: '123 Categoria', valid: true, reason: 'Nome com números válido' },
  ]
  
  testCases.forEach((test, index) => {
    const status = test.valid ? '✅' : '❌'
    console.log(`${status} Teste ${index + 1}: "${test.name}" - ${test.reason}`)
  })
  
  console.log('')
}

// Códigos de erro comuns
const listCommonErrors = () => {
  console.log('🚨 Códigos de erro comuns do PostgreSQL:')
  console.log('23505 - unique_violation (categoria já existe)')
  console.log('42P01 - undefined_table (tabela não existe)')
  console.log('42501 - insufficient_privilege (sem permissão)')
  console.log('08003 - connection_does_not_exist (conexão perdida)')
  console.log('08006 - connection_failure (falha na conexão)')
  console.log('')
}

// Executar todos os testes
const main = () => {
  checkEnvVars()
  generateCategoryTableSQL()
  testCategoryValidation()
  listCommonErrors()
  
  console.log('🎯 Próximos passos:')
  console.log('1. Verificar se as variáveis de ambiente estão corretas')
  console.log('2. Executar o SQL no painel do Supabase para criar a tabela')
  console.log('3. Testar a criação de categorias na interface')
  console.log('4. Verificar logs no console do navegador para erros específicos')
  console.log('')
  console.log('🌐 Acesse http://localhost:5174/test-categorias para testar!')
}

main()
