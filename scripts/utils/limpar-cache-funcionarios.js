console.log('🧹 LIMPEZA COMPLETA DE CACHE - FUNCIONÁRIOS');
console.log('');

// 1. Limpar LocalStorage
console.log('1. Limpando localStorage...');
Object.keys(localStorage).forEach(key => {
  if (key.includes('employee') || key.includes('funcionario') || key.includes('user') || key.includes('auth')) {
    console.log('   Removendo:', key);
    localStorage.removeItem(key);
  }
});

// 2. Limpar SessionStorage
console.log('2. Limpando sessionStorage...');
Object.keys(sessionStorage).forEach(key => {
  if (key.includes('employee') || key.includes('funcionario') || key.includes('user') || key.includes('auth')) {
    console.log('   Removendo:', key);
    sessionStorage.removeItem(key);
  }
});

// 3. Forçar reload da página
console.log('3. Forçando reload completo...');
setTimeout(() => {
  window.location.reload(true);
}, 1000);

console.log('');
console.log('✅ CACHE LIMPO! A página será recarregada em 1 segundo...');
console.log('📋 APÓS O RELOAD:');
console.log('- Deve mostrar APENAS: Gregori (teste@teste.com)');
console.log('- Cristiano e Cris devem DESAPARECER');
console.log('- Gregori deve ter botão EXCLUIR');
