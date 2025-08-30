// DIAGNÓSTICO COMPLETO - Execute no Console do Navegador (F12)
// Acesse o site e cole este código no console

console.log('🔍 DIAGNÓSTICO COMPLETO PDV ALLIMPORT');
console.log('=====================================');

// 1. Verificar se Supabase está disponível
if (window.supabase) {
  console.log('✅ Supabase client encontrado');
  
  // 2. Testar conexão direta
  window.supabase
    .from('produtos')
    .select('count(*)', { count: 'exact' })
    .then(({ data, error, count }) => {
      if (error) {
        console.error('❌ ERRO Supabase:', error.message);
        console.log('🔧 Causa possível: RLS, Auth, ou tabela inexistente');
      } else {
        console.log(`✅ SUPABASE OK - Total produtos: ${count}`);
        
        // Se tem produtos, buscar alguns exemplos
        if (count > 0) {
          return window.supabase
            .from('produtos')
            .select('id, nome, preco')
            .limit(10);
        }
      }
    })
    .then(result => {
      if (result && result.data) {
        console.log('📦 PRODUTOS ENCONTRADOS:');
        result.data.forEach(p => {
          console.log(`- ${p.nome} (R$ ${p.preco})`);
        });
      }
    })
    .catch(err => console.error('❌ Erro na consulta:', err));

} else {
  console.log('❌ Supabase client NÃO ENCONTRADO');
  console.log('Verificando se existe em window object...');
  console.log('Supabase keys:', Object.keys(window).filter(k => k.toLowerCase().includes('supabase')));
}

// 3. Verificar ProductService
setTimeout(() => {
  console.log('\n🔍 VERIFICANDO PRODUCTSERVICE...');
  
  // Tentar importar productService
  if (window.productService) {
    console.log('✅ ProductService encontrado no window');
    
    // Testar busca
    window.productService.search({ search: '' })
      .then(products => {
        console.log(`📦 ProductService.search retornou: ${products.length} produtos`);
        products.slice(0, 5).forEach(p => {
          console.log(`- ${p.name} (R$ ${p.price})`);
        });
      })
      .catch(err => console.error('❌ Erro ProductService.search:', err));

    // Testar getAll
    window.productService.getAll()
      .then(products => {
        console.log(`📦 ProductService.getAll retornou: ${products.length} produtos`);
      })
      .catch(err => console.error('❌ Erro ProductService.getAll:', err));

  } else {
    console.log('❌ ProductService NÃO encontrado no window');
    console.log('Tentando acessar via import ou outras formas...');
    
    // Verificar se está em algum objeto React/módulo
    if (window.React) {
      console.log('✅ React encontrado, mas ProductService não exposto');
    }
  }
}, 2000);

// 4. Monitorar requests de rede
console.log('\n📡 MONITORANDO REQUESTS...');
const originalFetch = window.fetch;
window.fetch = function(...args) {
  const url = args[0];
  if (typeof url === 'string' && (url.includes('produtos') || url.includes('supabase'))) {
    console.log('🌐 REQUEST:', url);
  }
  
  return originalFetch.apply(this, args)
    .then(response => {
      if (typeof url === 'string' && url.includes('produtos')) {
        console.log('✅ RESPONSE:', response.status, response.statusText);
      }
      return response;
    })
    .catch(error => {
      if (typeof url === 'string' && url.includes('produtos')) {
        console.error('❌ REQUEST ERROR:', error);
      }
      throw error;
    });
};

// 5. Verificar localStorage/cache
console.log('\n💾 VERIFICANDO CACHE...');
console.log('LocalStorage keys:', Object.keys(localStorage).filter(k => k.includes('produto') || k.includes('supabase')));
console.log('SessionStorage keys:', Object.keys(sessionStorage).filter(k => k.includes('produto') || k.includes('supabase')));

console.log('\n📋 PRÓXIMOS PASSOS:');
console.log('1. Verifique os logs acima');
console.log('2. Vá para a página de Vendas');
console.log('3. Tente buscar um produto');
console.log('4. Observe os logs de request');
console.log('5. Me envie TODOS os logs que aparecerem');

console.log('\n🔄 AGUARDANDO INTERAÇÃO...');
