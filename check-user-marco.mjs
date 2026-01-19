import { createClient } from '@supabase/supabase-js'

// ⚠️ CREDENCIAIS CORRETAS (atualizadas do .env)
const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'

const supabase = createClient(supabaseUrl, supabaseKey)

const email = 'marcovalentim04@outlook.com'

console.log('🔍 DIAGNÓSTICO COMPLETO DO USUÁRIO:', email)
console.log('=' .repeat(80))

try {
  // 1. Verificar se existe no Auth
  console.log('\n1️⃣ VERIFICANDO SUPABASE AUTH...')
  const { data: { users }, error: authError } = await supabase.auth.admin.listUsers()
  
  if (authError) {
    console.log('❌ Erro ao buscar usuários do Auth:', authError.message)
  } else {
    const authUser = users?.find(u => u.email === email)
    if (authUser) {
      console.log('✅ Usuário encontrado no Auth:')
      console.log('   - ID:', authUser.id)
      console.log('   - Email:', authUser.email)
      console.log('   - Email Confirmado:', authUser.email_confirmed_at ? '✅ SIM' : '❌ NÃO')
      console.log('   - Criado em:', new Date(authUser.created_at).toLocaleString('pt-BR'))
      console.log('   - Último login:', authUser.last_sign_in_at ? new Date(authUser.last_sign_in_at).toLocaleString('pt-BR') : 'Nunca')
      console.log('   - Metadata:', JSON.stringify(authUser.user_metadata, null, 2))
    } else {
      console.log('❌ Usuário NÃO encontrado no Supabase Auth')
    }
  }

  // 2. Verificar user_approvals
  console.log('\n2️⃣ VERIFICANDO TABELA user_approvals...')
  const { data: approvals, error: appError } = await supabase
    .from('user_approvals')
    .select('*')
    .eq('email', email)
  
  if (appError) {
    console.log('❌ Erro ao buscar em user_approvals:', appError.message)
  } else if (!approvals || approvals.length === 0) {
    console.log('❌ Usuário NÃO encontrado em user_approvals')
    console.log('   ⚠️ ESTE É O PROBLEMA! O registro não foi inserido na tabela.')
  } else {
    console.log('✅ Encontrado', approvals.length, 'registro(s) em user_approvals:')
    approvals.forEach((app, idx) => {
      console.log(`\n   Registro ${idx + 1}:`)
      console.log('   - user_id:', app.user_id)
      console.log('   - email:', app.email)
      console.log('   - Nome:', app.full_name)
      console.log('   - Empresa:', app.company_name)
      console.log('   - Status:', app.status)
      console.log('   - User Role:', app.user_role)
      console.log('   - Email Verificado:', app.email_verified ? '✅' : '❌')
      console.log('   - Criado em:', new Date(app.created_at).toLocaleString('pt-BR'))
      console.log('   - Aprovado em:', app.approved_at ? new Date(app.approved_at).toLocaleString('pt-BR') : 'Não aprovado')
      console.log('   - Aprovado por:', app.approved_by || 'N/A')
    })
  }

  // 3. Verificar subscriptions
  console.log('\n3️⃣ VERIFICANDO TABELA subscriptions...')
  const { data: subs, error: subError } = await supabase
    .from('subscriptions')
    .select('*')
    .eq('email', email)
  
  if (subError) {
    console.log('❌ Erro ao buscar em subscriptions:', subError.message)
  } else if (!subs || subs.length === 0) {
    console.log('❌ Nenhuma assinatura encontrada')
    console.log('   ⚠️ O teste de 15 dias NÃO foi ativado!')
  } else {
    console.log('✅ Encontrada(s)', subs.length, 'assinatura(s):')
    subs.forEach((sub, idx) => {
      console.log(`\n   Assinatura ${idx + 1}:`)
      console.log('   - ID:', sub.id)
      console.log('   - User ID:', sub.user_id)
      console.log('   - Status:', sub.status)
      console.log('   - Plano:', sub.plan_name)
      console.log('   - Início:', new Date(sub.start_date).toLocaleString('pt-BR'))
      console.log('   - Fim:', new Date(sub.end_date).toLocaleString('pt-BR'))
      console.log('   - Trial:', sub.trial ? '✅ SIM' : '❌ NÃO')
    })
  }

  // 4. Verificar empresas
  console.log('\n4️⃣ VERIFICANDO TABELA empresas...')
  const { data: empresas, error: empError } = await supabase
    .from('empresas')
    .select('*')
    .eq('email', email)
  
  if (empError) {
    console.log('❌ Erro ao buscar em empresas:', empError.message)
  } else if (!empresas || empresas.length === 0) {
    console.log('⚠️ Nenhuma empresa encontrada')
  } else {
    console.log('✅ Encontrada(s)', empresas.length, 'empresa(s):')
    empresas.forEach((emp, idx) => {
      console.log(`\n   Empresa ${idx + 1}:`)
      console.log('   - ID:', emp.id)
      console.log('   - Nome:', emp.nome)
      console.log('   - Email:', emp.email)
      console.log('   - Criado em:', new Date(emp.criado_em).toLocaleString('pt-BR'))
    })
  }

  console.log('\n' + '='.repeat(80))
  console.log('📊 RESUMO DO DIAGNÓSTICO:')
  console.log('='.repeat(80))
  
  const authExists = users?.find(u => u.email === email)
  const approvalExists = approvals && approvals.length > 0
  const subExists = subs && subs.length > 0
  
  if (authExists && !approvalExists) {
    console.log('\n🚨 PROBLEMA IDENTIFICADO:')
    console.log('   ✅ Conta criada no Supabase Auth')
    console.log('   ❌ NÃO inserido em user_approvals')
    console.log('   ❌ NÃO tem assinatura/teste')
    console.log('\n💡 CAUSA:')
    console.log('   O código de cadastro (SignupPageNew.tsx) FALHOU ao inserir em user_approvals')
    console.log('   Isso pode ter ocorrido por:')
    console.log('   - Erro de RLS (Row Level Security)')
    console.log('   - Erro de validação')
    console.log('   - Exceção não capturada no código')
  } else if (!authExists) {
    console.log('\n🚨 PROBLEMA IDENTIFICADO:')
    console.log('   ❌ Conta NÃO criada no Supabase Auth')
    console.log('   Provavelmente o cadastro falhou completamente')
  } else if (authExists && approvalExists && !subExists) {
    console.log('\n🚨 PROBLEMA IDENTIFICADO:')
    console.log('   ✅ Conta criada no Supabase Auth')
    console.log('   ✅ Inserido em user_approvals')
    console.log('   ❌ NÃO tem assinatura/teste')
    console.log('\n💡 CAUSA:')
    console.log('   A RPC approve_user_after_email_verification FALHOU')
    console.log('   ou não foi chamada após verificação do email')
  } else if (authExists && approvalExists && subExists) {
    console.log('\n✅ TUDO CORRETO!')
    console.log('   O usuário tem Auth, approval e subscription')
  }

} catch (error) {
  console.error('\n❌ ERRO FATAL:', error)
}
