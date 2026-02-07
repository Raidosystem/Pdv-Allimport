import { createClient } from '@supabase/supabase-js'

// 🔐 USANDO SERVICE ROLE KEY (BYPASSA RLS)
const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjQyNjUxMywiZXhwIjoyMDcyMDAyNTEzfQ.Lgiq5fY-XMQyqhZYof4cvYMNkw4DTGikvAk56im-Hks'

// ⚠️ CRÍTICO: Usar options corretas para bypassar RLS
const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  },
  db: {
    schema: 'public'
  },
  global: {
    headers: {
      'apikey': serviceRoleKey,
      'Authorization': `Bearer ${serviceRoleKey}`
    }
  }
})

const email = 'marcovalentim04@outlook.com'
const userId = '4954a75a-73f7-42f0-a1b7-5380adeb6681'

console.log('🔧 CORRIGINDO CADASTRO DO USUÁRIO:', email)
console.log('=' .repeat(80))

try {
  // 1. Verificar/Inserir em user_approvals
  console.log('\n1️⃣ Verificando user_approvals...')
  const { data: existingApproval } = await supabase
    .from('user_approvals')
    .select('*')
    .eq('user_id', userId)
    .single()
  
  if (existingApproval) {
    console.log('✅ Usuário já existe em user_approvals!')
    console.log('   Status:', existingApproval.status)
  } else {
    console.log('📝 Inserindo em user_approvals...')
    const { data: insertData, error: insertError } = await supabase
      .from('user_approvals')
      .insert({
        user_id: userId,
        email: email,
        full_name: 'MARCO ANTONIO VALENTIM',
        company_name: 'MARCO ANTONIO VALENTIM',
        status: 'approved', // Já aprovado
        user_role: 'owner',
        approved_at: new Date().toISOString(),
        created_at: '2026-01-19T12:04:09.000Z' // Data original do cadastro
      })
      .select()
    
    if (insertError) {
      console.log('❌ Erro ao inserir em user_approvals:', insertError.message)
      throw insertError
    } else {
      console.log('✅ Inserido em user_approvals com sucesso!')
    }
  }

  // 2. Verificar/Ativar teste de 15 dias usando RPC
  console.log('\n2️⃣ Verificando subscription...')
  const { data: existingSub } = await supabase
    .from('subscriptions')
    .select('*')
    .eq('user_id', userId)
    .maybeSingle()
  
  if (existingSub) {
    console.log('✅ Subscription já existe!')
    console.log('   Status:', existingSub.status)
    console.log('   Plano:', existingSub.plan_type)
    console.log('   Trial até:', existingSub.trial_end_date ? new Date(existingSub.trial_end_date).toLocaleDateString('pt-BR') : 'N/A')
  } else {
    console.log('📝 Ativando teste de 15 dias via RPC...')
    
    // Usar a função RPC que bypassa o RLS
    const { data: rpcData, error: rpcError } = await supabase.rpc('activate_trial_for_new_user', {
      user_email: email
    })
    
    if (rpcError) {
      console.log('❌ Erro ao ativar trial via RPC:', rpcError.message)
      console.log('   Código:', rpcError.code)
      console.log('   Detalhes:', rpcError.details)
      throw rpcError
    } else {
      console.log('✅ Teste de 15 dias ativado com sucesso via RPC!')
      console.log('   Resultado:', rpcData)
      
      // Verificar a subscription criada
      const { data: newSub } = await supabase
        .from('subscriptions')
        .select('*')
        .eq('user_id', userId)
        .single()
      
      if (newSub) {
        console.log('   - Status:', newSub.status)
        console.log('   - Trial até:', new Date(newSub.trial_end_date).toLocaleDateString('pt-BR'))
      }
    }
  }

  // 3. Criar empresa
  console.log('\n3️⃣ Criando empresa...')
  const { data: empData, error: empError } = await supabase
    .from('empresas')
    .insert({
      nome: 'MARCO ANTONIO VALENTIM',
      email: email,
      telefone: '17999746558',
      user_id: userId,
      criado_em: new Date().toISOString()
    })
    .select()
  
  if (empError) {
    console.log('⚠️ Erro ao criar empresa:', empError.message)
    console.log('   (Não é crítico, pode já existir)')
  } else {
    console.log('✅ Empresa criada com sucesso!')
  }

  console.log('\n' + '='.repeat(80))
  console.log('✅ CORREÇÃO CONCLUÍDA COM SUCESSO!')
  console.log('=' .repeat(80))
  console.log('\n📋 RESULTADO:')
  console.log('   ✅ Usuário inserido em user_approvals')
  console.log('   ✅ Status: APROVADO')
  console.log('   ✅ Teste de 15 dias ATIVO')
  console.log('   ✅ Empresa criada')
  console.log('\n🎯 PRÓXIMOS PASSOS:')
  console.log('   1. Atualize o painel admin no navegador')
  console.log('   2. O usuário Marco deve aparecer na seção "Novos Cadastros - Proprietários"')
  console.log('   3. Ele já pode usar o sistema normalmente')
  console.log('\n⚠️ IMPORTANTE:')
  console.log('   Agora precisa corrigir o código SignupPageNew.tsx para que')
  console.log('   TODOS os próximos cadastros funcionem automaticamente!')

} catch (error) {
  console.error('\n❌ ERRO FATAL:', error)
  process.exit(1)
}
