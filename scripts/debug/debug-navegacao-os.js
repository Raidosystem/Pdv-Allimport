// 🔧 TESTE RÁPIDO DE NAVEGAÇÃO ORDENS DE SERVIÇO
// Execute no console do navegador para testar

console.log('🧪 Testando navegação de OS...');

// 1. Verificar se React Router está funcionando
if (window.location.pathname) {
  console.log('📍 URL atual:', window.location.pathname);
}

// 2. Simular click em editar OS
function testarEditarOS(osId = 'test-id') {
  console.log('🔧 Testando editar OS com ID:', osId);
  
  // Simular navegação
  window.history.pushState({}, '', `/ordem-servico/${osId}/editar`);
  
  console.log('✅ Navegação simulada para:', window.location.pathname);
}

// 3. Verificar se as rotas estão registradas
function verificarRotas() {
  const rotas = [
    '/ordens-servico',
    '/ordem-servico/123/editar',
    '/ordem-servico/123'
  ];
  
  rotas.forEach(rota => {
    console.log(`🔍 Testando rota: ${rota}`);
  });
}

// Executar testes
verificarRotas();

console.log('📋 Para testar, execute: testarEditarOS("sua-os-id")');
