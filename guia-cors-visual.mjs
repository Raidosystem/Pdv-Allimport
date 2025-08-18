#!/usr/bin/env node

/**
 * GUIA VISUAL PARA ENCONTRAR CORS NO SUPABASE
 * URLs já configuradas, falta só o CORS
 */

console.log('🎯 GUIA: ONDE ENCONTRAR CORS NO SUPABASE');
console.log('═'.repeat(50));

console.log('✅ STATUS ATUAL:');
console.log('   • Authentication URLs: CONFIGURADAS ✅');
console.log('   • Site URL: CORRETO ✅');
console.log('   • Redirect URLs: CORRETAS ✅');
console.log('   • CORS Origins: FALTA CONFIGURAR ❌');

console.log('\n🗺️ NAVEGAÇÃO NO SUPABASE:');
console.log('   1. Dashboard inicial');
console.log('   2. Settings (menu esquerdo) ← CLIQUE AQUI');
console.log('   3. API (submenu) ← CLIQUE AQUI');
console.log('   4. Procure por "CORS" na página');

console.log('\n📍 LOCALIZAÇÃO DO CORS:');
console.log('   Path: Settings > API > CORS');
console.log('   Seção: "CORS Origins" ou "Additional allowed origins"');
console.log('   Ação: Adicionar nova origem');

console.log('\n➕ O QUE ADICIONAR:');
console.log('   URL: https://pdv.crmvsystem.com');
console.log('   Método: Clique no botão "+" ou "Add"');
console.log('   Salvar: Clique em "Save" após adicionar');

console.log('\n⚠️ DIFERENÇA IMPORTANTE:');
console.log('   Authentication > URL Config: Para redirecionamentos ✅');
console.log('   Settings > API > CORS: Para requisições web ❌');

console.log('\n🔍 SE NÃO ENCONTRAR:');
console.log('   • Certifique-se de estar em Settings > API');
console.log('   • Role a página para baixo');
console.log('   • Procure por "CORS", "Origins" ou "Access-Control"');

console.log('\n🧪 APÓS CONFIGURAR:');
console.log('   1. Save/Salvar configuração');
console.log('   2. Aguardar 1-2 minutos');
console.log('   3. Limpar cache do navegador');
console.log('   4. Testar login em: https://pdv.crmvsystem.com/');

console.log('\n═'.repeat(50));
console.log('🎯 VOCÊ ESTÁ QUASE LÁ!');
console.log('   98% concluído - só falta CORS');
console.log('   2 minutos para finalizar');
console.log('═'.repeat(50));

console.log('\n💡 DICA VISUAL:');
console.log('   O CORS geralmente fica numa seção separada');
console.log('   das URLs de autenticação. Procure por:');
console.log('   - "CORS"');
console.log('   - "Origins"'); 
console.log('   - "Access-Control"');
console.log('   - "Allowed Origins"');
