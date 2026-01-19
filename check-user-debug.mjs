import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://cqydzfbeynzuhksqfdvu.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxeWR6ZmJleW56dWhrc3FmZHZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ3Mjk0MjMsImV4cCI6MjA1MDMwNTQyM30.WPexrK77VpSDVrYB2IZSr_YI_xU3d9gGH0bQV7gGYko';

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkUser() {
  const email = 'marcovalentim04@outlook.com';
  
  console.log('🔍 Verificando cadastro de:', email);
  console.log('='.repeat(80));
  
  // 1. Buscar na tabela user_approvals
  const { data: approval, error: approvalError } = await supabase
    .from('user_approvals')
    .select('*')
    .eq('email', email)
    .maybeSingle();
  
  console.log('\n📋 TABELA user_approvals:');
  if (approvalError) {
    console.log('❌ Erro:', approvalError);
  } else if (!approval) {
    console.log('❌ NÃO ENCONTRADO - Usuário não foi inserido em user_approvals!');
    console.log('\n🚨 PROBLEMA CRÍTICO:');
    console.log('   O código do SignupPageNew NÃO inseriu o registro!');
    console.log('   Possíveis causas:');
    console.log('   1. Erro durante o cadastro (verificar console do navegador)');
    console.log('   2. Código não foi executado (build antigo no servidor)');
    console.log('   3. RLS bloqueou o insert (improvável com anon key)');
  } else {
    console.log('✅ Encontrado!');
    console.log(JSON.stringify(approval, null, 2));
  }
  
  // 2. Buscar na tabela subscriptions (se user_id existir)
  if (approval?.user_id) {
    const { data: subscription, error: subError } = await supabase
      .from('subscriptions')
      .select('*')
      .eq('user_id', approval.user_id)
      .maybeSingle();
    
    console.log('\n💳 TABELA subscriptions:');
    if (subError) {
      console.log('❌ Erro:', subError);
    } else if (!subscription) {
      console.log('❌ NÃO ENCONTRADO - Teste de 15 dias NÃO foi criado!');
      console.log('\n🚨 PROBLEMA:');
      console.log('   Função RPC activate_trial_for_new_user NÃO executou');
      console.log('   ou não existe no Supabase');
    } else {
      console.log('✅ Encontrado!');
      console.log(JSON.stringify(subscription, null, 2));
      
      const now = new Date();
      const endDate = new Date(subscription.end_date);
      const daysLeft = Math.ceil((endDate - now) / (1000 * 60 * 60 * 24));
      console.log('\n📊 Status da Assinatura:');
      console.log('   Status:', subscription.status);
      console.log('   Plano:', subscription.plan_id);
      console.log('   Início:', subscription.start_date);
      console.log('   Fim:', subscription.end_date);
      console.log('   Dias restantes:', daysLeft);
    }
  }
  
  console.log('\n' + '='.repeat(80));
  console.log('📊 RESUMO DO DIAGNÓSTICO:');
  console.log('='.repeat(80));
  
  if (!approval) {
    console.log('\n❌ DIAGNÓSTICO: CADASTRO INCOMPLETO');
    console.log('\n   PROBLEMA PRINCIPAL:');
    console.log('   → Registro NÃO existe em user_approvals');
    console.log('   → O código modificado ainda não está em produção');
    console.log('   → OU houve erro durante o cadastro');
    console.log('\n   AÇÃO NECESSÁRIA:');
    console.log('   1. Verificar se o build/deploy foi feito com sucesso');
    console.log('   2. Verificar logs do navegador durante cadastro');
    console.log('   3. Testar novamente após confirmar deploy');
  } else {
    console.log('\n✅ Registro encontrado em user_approvals');
    console.log('   - Status:', approval.status);
    console.log('   - User Role:', approval.user_role);
    console.log('   - Email Verified:', approval.email_verified);
    console.log('   - Created At:', approval.created_at);
    
    if (approval.status === 'pending') {
      console.log('\n⚠️  STATUS = PENDING');
      console.log('   → Usuário ainda NÃO verificou o email');
      console.log('   → Após verificar, a função RPC approve_user_after_email_verification');
      console.log('      deve mudar status para "approved" e ativar teste de 15 dias');
    }
    
    if (approval.status === 'approved') {
      console.log('\n✅ STATUS = APPROVED');
      console.log('   → Email foi verificado com sucesso');
      
      if (approval.user_id) {
        const { data: sub } = await supabase
          .from('subscriptions')
          .select('*')
          .eq('user_id', approval.user_id)
          .maybeSingle();
        
        if (!sub) {
          console.log('\n❌ MAS teste de 15 dias NÃO foi criado!');
          console.log('   → Função RPC activate_trial_for_new_user falhou');
          console.log('   → Verificar se função existe no Supabase');
        }
      }
    }
  }
}

checkUser().catch(console.error);
