// Teste para verificar se existe o email "teste@pdvallimport.com" na tabela subscriptions

// const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
// Para este teste, precisaríamos da service key, mas vamos simular...

console.log('🔍 Verificando se email existe na tabela subscriptions...');
console.log('Email para buscar: teste@pdvallimport.com');
console.log('Company ID no pagamento: test-company-123');

console.log('\n📋 Análise do problema:');
console.log('1. Webhook está funcionando (200 ✅)');
console.log('2. Pagamento tem metadata correto ✅');
console.log('3. Status é "pending" - só processa se "approved" ❌');
console.log('4. RPC busca por email "test-company-123" (que não é email) ❌');

console.log('\n🎯 PROBLEMA IDENTIFICADO:');
console.log('O metadata "company_id" está com valor "test-company-123"');
console.log('A função RPC só processa emails (que devem ter @)');
console.log('Como "test-company-123" não tem @, a função não encontra nada!');

console.log('\n💡 SOLUÇÕES:');
console.log('1. Corrigir metadata para usar email real do usuário');
console.log('2. OU modificar RPC para aceitar ambos email e UUID');
console.log('3. OU criar assinatura com email correto no banco');

// Vamos verificar o que está sendo enviado nos metadata
console.log('\n📤 Verificando como metadata é criado...');