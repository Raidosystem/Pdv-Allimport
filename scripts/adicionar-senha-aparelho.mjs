// Script para adicionar coluna senha_aparelho na tabela ordens_servico
import { createClient } from '@supabase/supabase-js'
import * as dotenv from 'dotenv'

dotenv.config()

const supabaseUrl = process.env.VITE_SUPABASE_URL
const supabaseKey = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY || process.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Variáveis de ambiente não encontradas!')
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseKey)

async function adicionarColunasSenha() {
  console.log('🚀 Iniciando adição da coluna senha_aparelho...\n')

  try {
    // Verificar se a coluna já existe
    const { data: colunas, error: errorColunas } = await supabase
      .from('information_schema.columns')
      .select('column_name')
      .eq('table_name', 'ordens_servico')
      .eq('column_name', 'senha_aparelho')

    if (errorColunas) {
      console.log('⚠️  Não foi possível verificar colunas existentes')
      console.log('Tentando adicionar mesmo assim...\n')
    } else if (colunas && colunas.length > 0) {
      console.log('✅ Coluna senha_aparelho já existe!')
      return
    }

    console.log('📝 Execute este SQL manualmente no Supabase SQL Editor:\n')
    console.log('=' .repeat(60))
    console.log(`
-- Adicionar coluna senha_aparelho
ALTER TABLE ordens_servico 
ADD COLUMN IF NOT EXISTS senha_aparelho JSONB DEFAULT NULL;

-- Comentário
COMMENT ON COLUMN ordens_servico.senha_aparelho IS 
'Armazena informações sobre a senha do aparelho em formato JSON';

-- Verificar
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'ordens_servico'
AND column_name = 'senha_aparelho';
    `)
    console.log('=' .repeat(60))
    console.log('\n✅ Cole este SQL no SQL Editor do Supabase!')
    console.log('🔗 https://supabase.com/dashboard/project/_/sql/new\n')

  } catch (error) {
    console.error('❌ Erro:', error.message)
  }
}

adicionarColunasSenha()
