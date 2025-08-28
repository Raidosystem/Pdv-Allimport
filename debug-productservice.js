// Script para testar ProductService no navegador
console.log('🔧 Testando ProductService...');

// Tentar importar dinamicamente
import('/src/services/sales.ts').then(module => {
  console.log('✅ Módulo importado:', module);
  console.log('📦 Exportações disponíveis:', Object.keys(module));
  
  if (module.productService) {
    console.log('✅ productService encontrado!');
    console.log('🔍 Métodos disponíveis:', Object.keys(module.productService));
    
    // Testar search
    module.productService.search({ search: 'test' })
      .then(products => {
        console.log('✅ Produtos retornados:', products.length);
        console.log('📝 Primeiro produto:', products[0]);
      })
      .catch(error => {
        console.error('❌ Erro ao buscar produtos:', error);
      });
  } else {
    console.error('❌ productService NÃO encontrado!');
  }
}).catch(error => {
  console.error('❌ Erro ao importar módulo:', error);
});

// Também tentar window.productService se estiver disponível globalmente
setTimeout(() => {
  if (window.productService) {
    console.log('✅ productService disponível globalmente');
  } else {
    console.log('⚠️ productService não está disponível globalmente');
  }
}, 1000);
