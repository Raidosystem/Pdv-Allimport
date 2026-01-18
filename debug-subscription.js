// Verificar se existe assinatura para o email de teste
console.log('🔍 Investigando problema: "Aguardando pagamento" não sai');

const testEmail = 'teste@pdvallimport.com';

console.log(`📧 Email de teste: ${testEmail}`);
console.log('🎯 Payment ID com metadata correto: 125543848657');

console.log('\n📋 POSSÍVEIS CAUSAS:');
console.log('1. ❓ Email não existe na tabela subscriptions');
console.log('2. ❓ Função RPC estava com tipo UUID em vez de TEXT');
console.log('3. ❓ Frontend não está chamando verificação corretamente');
console.log('4. ❓ Pagamento ainda está pending (não approved)');

console.log('\n🔧 CORREÇÕES FEITAS:');
console.log('✅ Metadata agora usa email completo');
console.log('✅ Função RPC corrigida para aceitar TEXT');
console.log('✅ Logs adicionados para debug');

console.log('\n🧪 PRÓXIMO TESTE:');
console.log('1. Executar função RPC corrigida no Supabase');
console.log('2. Criar assinatura para teste@pdvallimport.com se não existir');
console.log('3. Simular pagamento aprovado para testar fluxo completo');

console.log('\n📝 COMANDO PARA EXECUTAR NO SUPABASE:');
console.log(`
-- 1. Criar assinatura de teste
INSERT INTO public.subscriptions (
  email, 
  status, 
  subscription_end_date,
  created_at,
  updated_at
) VALUES (
  '${testEmail}',
  'pending',
  NOW() + INTERVAL '15 days', -- 15 dias de teste
  NOW(),
  NOW()
) ON CONFLICT (email) DO NOTHING;

-- 2. Testar função RPC
SELECT extend_company_paid_until_v2(
  125543848657::bigint,
  '${testEmail}'::text,
  NULL::uuid
);

-- 3. Verificar resultado
SELECT email, status, subscription_end_date, payment_status 
FROM public.subscriptions 
WHERE email = '${testEmail}';
`);

console.log('\n🎯 Se funcionar, o sistema mostrará os dias restantes!');