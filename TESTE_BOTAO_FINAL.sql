-- TESTE FINAL: Verificar se o botão "Verificar Status" funciona agora
-- Execute este SQL no Supabase Dashboard

-- 1. TESTAR A FUNÇÃO QUE O BOTÃO USA (check_subscription_status)
SELECT 
  '=== TESTE DA FUNÇÃO DO BOTÃO ===' as info,
  check_subscription_status('assistenciaallimport10@gmail.com') as resultado_completo;

-- 2. EXTRAIR APENAS OS DIAS RESTANTES (que é o que aparece no frontend)
SELECT 
  '=== DIAS RESTANTES RETORNADOS ===' as info,
  (check_subscription_status('assistenciaallimport10@gmail.com')->>'days_remaining')::integer as dias_que_o_botao_vai_mostrar;

-- 3. COMPARAR COM O CÁLCULO DIRETO
SELECT 
  '=== COMPARAÇÃO ===' as info,
  (check_subscription_status('assistenciaallimport10@gmail.com')->>'days_remaining')::integer as dias_pela_funcao,
  EXTRACT(DAY FROM subscription_end_date - NOW())::integer as dias_calculados_diretamente,
  subscription_end_date as data_vencimento,
  NOW() as agora
FROM public.subscriptions 
WHERE email = 'assistenciaallimport10@gmail.com';

-- 4. VERIFICAR SE A FUNÇÃO ESTÁ FUNCIONANDO CORRETAMENTE
SELECT 
  CASE 
    WHEN (check_subscription_status('assistenciaallimport10@gmail.com')->>'days_remaining')::integer > 30 THEN
      '✅ SUCCESS: Botão vai mostrar dias atualizados (mais de 30 dias)!'
    WHEN (check_subscription_status('assistenciaallimport10@gmail.com')->>'days_remaining')::integer = 25 THEN
      '❌ PROBLEMA: Botão ainda vai mostrar 25 dias (dados não atualizados)'
    ELSE
      '⚠️ ATENÇÃO: Botão vai mostrar ' || (check_subscription_status('assistenciaallimport10@gmail.com')->>'days_remaining')::integer || ' dias'
  END as status_do_botao;

-- 5. INSTRUÇÕES FINAIS
SELECT 
  '=== PRÓXIMOS PASSOS ===' as info,
  'Agora teste o botão "🔄 Verificar Status da Assinatura" no frontend' as instrucao;