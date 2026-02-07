// =====================================================
// LIMPAR CACHE COMPLETO E SERVICE WORKER
// =====================================================
// Execute este código no Console do navegador (F12 > Console)

console.log('🧹 Iniciando limpeza completa...');

// 1. Limpar localStorage
localStorage.clear();
console.log('✅ localStorage limpo');

// 2. Limpar sessionStorage
sessionStorage.clear();
console.log('✅ sessionStorage limpo');

// 3. Limpar todos os caches (incluindo Service Worker)
caches.keys().then(keys => {
  console.log('🗑️ Removendo', keys.length, 'caches...');
  return Promise.all(keys.map(key => {
    console.log('  ❌ Removendo cache:', key);
    return caches.delete(key);
  }));
}).then(() => {
  console.log('✅ Todos os caches removidos');
  
  // 4. Desregistrar Service Worker
  return navigator.serviceWorker.getRegistrations();
}).then(registrations => {
  console.log('🗑️ Desregistrando', registrations.length, 'service workers...');
  return Promise.all(registrations.map(registration => {
    console.log('  ❌ Desregistrando SW:', registration.scope);
    return registration.unregister();
  }));
}).then(() => {
  console.log('✅ Service Workers desregistrados');
  console.log('🔄 Recarregando página em 2 segundos...');
  
  // 5. Recarregar forçando bypass de cache
  setTimeout(() => {
    window.location.reload(true);
  }, 2000);
});
