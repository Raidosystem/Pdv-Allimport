import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://zgedzqjcnttqylaziaea.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpnZWR6cWpjbnR0cXlsYXppYWVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU5NTM3NTcsImV4cCI6MjA1MTUyOTc1N30.1oJbPcWQ8xq-lDj0_Ip5NwB1aAvddjMz52rPWCLumH4'

const supabase = createClient(supabaseUrl, supabaseKey)

const email = 'marcovalentim04@outlook.com'

console.log('🔍 Verificando cadastro de:', email)
console.log('═══════════════════════════════════════════════════════════')

// 1. Verificar no Supabase Auth
console.log('\n1️⃣ SUPABASE AUTH (tabela auth.users):')
const { data: authData, error: authError } = await supabase.auth.admin.listUsers()
if (authError) {
  console.log('❌ Erro ao buscar auth users:', authError.message)
} else {
  const user = authData.users.find(u => u.email === email)
  if (user) {
    console.log('✅ Encontrado no Auth!')
    console.log('   - ID:', user.id)
    console.log('   - Email:', user.email)
    console.log('   - Email confirmado?', user.email_confirmed_at ? '✅ SIM' : '❌ NÃO')
    console.log('   - Criado em:', user.created_at)
    console.log('   - Último login:', user.last_sign_in_at || 'Nunca')
    console.log('   - Metadata:', JSON.stringify(user.user_metadata, null, 2))
  } else {
    console.log('❌ NÃO encontrado no Supabase Auth')
  }
}

// 2. Verificar na tabela user_approvals
console.log('\n2️⃣ TABELA user_approvals:')
const { data: approvalData, error: approvalError } = await supabase
  .from('user_approvals')
  .select('*')
  .eq('email', email)

if (approvalError) {
  console.log('❌ Erro ao buscar user_approvals:', approvalError.message)
} else if (approvalData && approvalData.length > 0) {
  console.log(`✅ Encontrado ${approvalData.length} registro(s)!`)
  approvalData.forEach((approval, index) => {
    console.log(`\n   Registro ${index + 1}:`)
    console.log('   - ID:', approval.user_id)
    console.log('   - Status:', approval.status)
    console.log('   - User Role:', approval.user_role)
    console.log('   - Nome:', approval.full_name)
    console.log('   - Empresa:', approval.company_name)
    console.log('   - Email verificado?', approval.email_verified ? '✅ SIM' : '❌ NÃO')
    console.log('   - Criado em:', approval.created_at)
    console.log('   - Aprovado em:', approval.approved_at || 'Não aprovado')
    console.log('   - Aprovado por:', approval.approved_by || 'N/A')
  })
} else {
  console.log('❌ NÃO encontrado na tabela user_approvals')
}

// 3. Verificar na tabela subscriptions
console.log('\n3️⃣ TABELA subscriptions (planos/teste):')
const { data: subData, error: subError } = await supabase
  .from('subscriptions')
  .select('*')
  .eq('email', email)

if (subError) {
  console.log('❌ Erro ao buscar subscriptions:', subError.message)
} else if (subData && subData.length > 0) {
  console.log(`✅ Encontrado ${subData.length} registro(s)!`)
  subData.forEach((sub, index) => {
    console.log(`\n   Assinatura ${index + 1}:`)
    console.log('   - ID:', sub.id)
    console.log('   - User ID:', sub.user_id)
    console.log('   - Plano:', sub.plan_id)
    console.log('   - Status:', sub.status)
    console.log('   - Início:', sub.start_date)
    console.log('   - Fim:', sub.end_date)
    console.log('   - Ativo?', sub.is_active ? '✅ SIM' : '❌ NÃO')
  })
} else {
  console.log('❌ NÃO encontrado na tabela subscriptions (SEM TESTE ATIVO!)')
}

console.log('\n═══════════════════════════════════════════════════════════')
console.log('📊 DIAGNÓSTICO:')

if (!approvalData || approvalData.length === 0) {
  console.log('❌ PROBLEMA 1: Usuário NÃO foi inserido em user_approvals')
  console.log('   → O código do SignupPageNew pode não estar executando o insert')
}

if (approvalData && approvalData.length > 0) {
  const approval = approvalData[0]
  if (approval.status === 'pending') {
    console.log('⚠️  PROBLEMA 2: Usuário está PENDING (não aprovado)')
    console.log('   → Precisa verificar email OU admin precisa aprovar')
  }
  if (!approval.email_verified) {
    console.log('⚠️  PROBLEMA 3: Email NÃO foi verificado')
    console.log('   → Usuário não clicou no código de verificação')
  }
}

if (!subData || subData.length === 0) {
  console.log('❌ PROBLEMA 4: NÃO tem assinatura/teste ativo')
  console.log('   → A função RPC activate_trial_for_new_user NÃO foi executada')
  console.log('   → OU foi executada mas falhou')
}

console.log('\n💡 PRÓXIMOS PASSOS:')
if (!approvalData || approvalData.length === 0) {
  console.log('1. Verificar se o código do SignupPageNew está fazendo o insert')
  console.log('2. Verificar logs do navegador durante cadastro')
} else if (approvalData[0].status === 'pending' && !approvalData[0].email_verified) {
  console.log('1. Usuário precisa verificar o email (código OTP)')
  console.log('2. Após verificar, a função RPC approve_user_after_email_verification deve rodar')
  console.log('3. Essa função deve aprovar E ativar o teste de 15 dias')
}

process.exit(0)
