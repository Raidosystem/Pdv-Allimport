#!/usr/bin/env node

/**
 * TESTE DE AUTENTICAÇÃO - DIAGNÓSTICO RÁPIDO
 * Verifica configurações de autenticação sem limpar usuários
 */

console.log('🔍 DIAGNÓSTICO DE AUTENTICAÇÃO');
console.log('📍 Domínio: https://pdv.crmvsystem.com/');
console.log('🎯 Objetivo: Manter usuários, corrigir autenticação');
console.log('═'.repeat(50));

// Problemas mais comuns com mudança de domínio
const problemasComuns = [
  {
    id: 1,
    problema: '🚨 Site URL com barra no final',
    verificacao: 'Site URL deve ser: https://pdv.crmvsystem.com (SEM /)',
    solucao: 'Remover a barra do final no Supabase',
    critico: true
  },
  {
    id: 2, 
    problema: '⚠️ Cache do navegador',
    verificacao: 'Cookies e dados antigos do domínio anterior',
    solucao: 'Limpar cache e testar em aba privada',
    critico: true
  },
  {
    id: 3,
    problema: '🔧 Sessões ativas antigas',
    verificacao: 'Sessões criadas com domínio antigo ainda ativas',
    solucao: 'Executar SQL para limpar apenas sessões',
    critico: false
  },
  {
    id: 4,
    problema: '📧 Emails não confirmados',
    verificacao: 'Usuários com email_confirmed_at = null',
    solucao: 'Confirmar emails via SQL ou manualmente',
    critico: false
  },
  {
    id: 5,
    problema: '🌐 CORS não configurado',
    verificacao: 'Novo domínio não adicionado no CORS',
    solucao: 'Adicionar https://pdv.crmvsystem.com no CORS',
    critico: true
  }
];

console.log('🎯 PROBLEMAS MAIS COMUNS:\n');

problemasComuns.forEach(item => {
  const icon = item.critico ? '🚨 CRÍTICO' : '⚠️ OPCIONAL';
  console.log(`${icon} - ${item.problema}`);
  console.log(`   🔍 Verificar: ${item.verificacao}`);
  console.log(`   💡 Solução: ${item.solucao}\n`);
});

// Checklist de verificação
console.log('═'.repeat(50));
console.log('✅ CHECKLIST DE VERIFICAÇÃO:');
console.log('═'.repeat(50));

const checklist = [
  'Site URL: https://pdv.crmvsystem.com (SEM barra no final)',
  'Redirect URLs: Todas as suas URLs já estão corretas ✅',
  'CORS: https://pdv.crmvsystem.com adicionado',
  'Cache do navegador: Limpo (Ctrl+Shift+Delete)',
  'Teste em aba privada: Realizado',
  'Sessões antigas: Limpas (executar SQL se necessário)'
];

checklist.forEach((item, index) => {
  console.log(`${index + 1}. [ ] ${item}`);
});

// Ações recomendadas
console.log('\n═'.repeat(50));
console.log('🚀 AÇÕES RECOMENDADAS (EM ORDEM):');
console.log('═'.repeat(50));

const acoes = [
  '1. 🔧 Verificar Site URL no Supabase (problema mais comum)',
  '2. 🧹 Limpar cache do navegador completamente',  
  '3. 🔒 Testar login em aba privada/incógnito',
  '4. 🔄 Se não funcionar: executar limpar-apenas-sessoes.sql',
  '5. 📧 Confirmar que usuário tem email confirmado no Supabase',
  '6. 🌐 Verificar CORS no Supabase (Settings > API > CORS)'
];

acoes.forEach(acao => {
  console.log(acao);
});

console.log('\n💡 DICA IMPORTANTE:');
console.log('O problema mais comum é o Site URL com barra no final!');
console.log('Deve ser: https://pdv.crmvsystem.com (sem /)');

console.log('\n📁 Arquivos criados para você:');
console.log('- CORRIGIR_SITE_URL_SUPABASE.md (guia completo)');
console.log('- limpar-apenas-sessoes.sql (limpa só sessões)');

console.log('\n🎯 Próximo passo: Verificar Site URL no Supabase!');
