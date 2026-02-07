import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = 'https://vfuglqcyrmgwvrlmmotm.supabase.co'
const SUPABASE_SERVICE_KEY = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmdWdscWN5cm1nd3ZybG1tb3RtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNzc0MDkwNiwiZXhwIjoyMDUzMzE2OTA2fQ.jWHBh2_U7q12QrLwsJ2jqcHbONlJLHh85sOI1_HUJCo'

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)

console.log('🔍 VERIFICANDO ESTRUTURA DAS TABELAS\n')

async function verificarEstruturas() {
  try {
    // 1. Estrutura da tabela funcionarios
    console.log('📋 TABELA: funcionarios')
    console.log('═'.repeat(50))
    const { data: colsFuncionarios, error: err1 } = await supabase
      .rpc('exec_sql', {
        sql: `SELECT column_name, data_type, is_nullable, column_default 
              FROM information_schema.columns 
              WHERE table_name = 'funcionarios' 
              ORDER BY ordinal_position`
      })
    
    if (err1) {
      console.error('❌ Erro:', err1.message)
    } else {
      console.log(colsFuncionarios)
    }
    
    // 2. Estrutura da tabela login_funcionarios
    console.log('\n📋 TABELA: login_funcionarios')
    console.log('═'.repeat(50))
    const { data: colsLogin, error: err2 } = await supabase
      .rpc('exec_sql', {
        sql: `SELECT column_name, data_type, is_nullable, column_default 
              FROM information_schema.columns 
              WHERE table_name = 'login_funcionarios' 
              ORDER BY ordinal_position`
      })
    
    if (err2) {
      console.error('❌ Erro:', err2.message)
    } else {
      console.log(colsLogin)
    }
    
    // 3. Verificar função cadastrar_funcionario_simples
    console.log('\n📋 FUNÇÃO: cadastrar_funcionario_simples')
    console.log('═'.repeat(50))
    const { data: funcDef, error: err3 } = await supabase
      .rpc('exec_sql', {
        sql: `SELECT pg_get_functiondef(oid) as definition 
              FROM pg_proc 
              WHERE proname = 'cadastrar_funcionario_simples'`
      })
    
    if (err3) {
      console.error('❌ Erro:', err3.message)
    } else {
      console.log(funcDef?.[0]?.definition || 'Função não encontrada')
    }
    
    // 4. Verificar último funcionário criado
    console.log('\n📋 ÚLTIMO FUNCIONÁRIO CRIADO')
    console.log('═'.repeat(50))
    const { data: ultimoFunc, error: err4 } = await supabase
      .from('funcionarios')
      .select('id, nome, email, primeiro_acesso, senha_definida, usuario_ativo, created_at')
      .order('created_at', { ascending: false })
      .limit(1)
    
    if (err4) {
      console.error('❌ Erro:', err4.message)
    } else {
      console.log(ultimoFunc)
    }
    
  } catch (error) {
    console.error('❌ Erro geral:', error.message)
  }
}

verificarEstruturas()
