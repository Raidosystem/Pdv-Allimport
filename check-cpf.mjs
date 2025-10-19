import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://byjwcuqecojxqcvrljjv.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5andrdXFlY29qeHFjdnJsamp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM1MjQ5NDEsImV4cCI6MjA0OTEwMDk0MX0.WoBPbf6YrvnkijwXhzDuO5EhbTHNIlVsjbQXGwQ71Bo'

const supabase = createClient(supabaseUrl, supabaseKey)

async function checkCPF() {
  const cpf = '28219618809'
  const cpfFormatado = '282.196.188-09'
  const email = 'cris-ramos30@hotmail.com'
  
  console.log('🔍 Procurando CPF:', cpf)
  console.log('📧 Email:', email)
  console.log('')
  
  // Verificar na tabela funcionarios
  console.log('1️⃣ Verificando tabela FUNCIONARIOS...')
  const { data: funcionarios, error: errorFunc } = await supabase
    .from('funcionarios')
    .select('*')
    .or(`cpf.eq.${cpf},cpf.eq.${cpfFormatado}`)
  
  if (errorFunc) {
    console.error('❌ Erro ao consultar funcionarios:', errorFunc)
  } else {
    console.log(`✅ Encontrados ${funcionarios?.length || 0} registros:`)
    if (funcionarios && funcionarios.length > 0) {
      funcionarios.forEach(f => {
        console.log('   -', {
          id: f.id,
          nome: f.nome,
          cpf: f.cpf,
          email: f.email,
          ativo: f.ativo,
          deleted_at: f.deleted_at
        })
      })
    }
  }
  console.log('')
  
  // Verificar na tabela empresas
  console.log('2️⃣ Verificando tabela EMPRESAS...')
  const { data: empresas, error: errorEmp } = await supabase
    .from('empresas')
    .select('*')
    .eq('email', email)
  
  if (errorEmp) {
    console.error('❌ Erro ao consultar empresas:', errorEmp)
  } else {
    console.log(`✅ Encontrados ${empresas?.length || 0} registros:`)
    if (empresas && empresas.length > 0) {
      empresas.forEach(e => {
        console.log('   -', {
          id: e.id,
          nome: e.nome,
          email: e.email,
          ativo: e.ativo,
          deleted_at: e.deleted_at
        })
      })
    }
  }
  console.log('')
  
  // Verificar no Supabase Auth
  console.log('3️⃣ Verificando SUPABASE AUTH...')
  console.log('⚠️  Não é possível consultar auth.users via client-side')
  console.log('💡 Você precisa verificar no Dashboard do Supabase:')
  console.log('   https://supabase.com/dashboard/project/byjwcuqecojxqcvrljjv/auth/users')
  console.log('')
  
  // Tentar fazer login para ver se existe conta
  console.log('4️⃣ Testando se conta existe no Auth...')
  const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
    email: email,
    password: 'teste123' // senha qualquer só para testar
  })
  
  if (signInError) {
    if (signInError.message.includes('Invalid login credentials')) {
      console.log('⚠️  Conta EXISTE no Auth mas senha incorreta')
    } else if (signInError.message.includes('Email not confirmed')) {
      console.log('⚠️  Conta EXISTE no Auth mas email não confirmado')
    } else {
      console.log('✅ Conta NÃO existe no Auth:', signInError.message)
    }
  } else {
    console.log('⚠️  Login com sucesso! Conta EXISTE e ativa:', signInData.user?.id)
  }
}

checkCPF().catch(console.error)
