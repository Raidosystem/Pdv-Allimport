// CORREÇÃO TEMPORÁRIA PARA PRODUTOS EM VENDAS
// Execute no console do navegador (F12 → Console) para testar

console.log('🔧 CORREÇÃO: Forçando produtos em vendas...');

// 1. Verificar se ProductSearch está carregado
if (document.querySelector('input[data-search="unified"]')) {
  console.log('✅ ProductSearch encontrado na página');
  
  // 2. Forçar produtos de teste
  window.forcarProdutosTeste = () => {
    console.log('🚀 Forçando produtos de teste...');
    
    // Simular produtos
    const produtosTeste = [
      {
        id: '1',
        name: 'Produto Teste 1',
        description: 'Produto para teste',
        sku: 'TEST001',
        barcode: '123456789',
        price: 10.50,
        stock_quantity: 100,
        min_stock: 10,
        unit: 'un',
        active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: '2',
        name: 'Produto Teste 2',
        description: 'Outro produto para teste',
        sku: 'TEST002',
        barcode: '987654321',
        price: 25.99,
        stock_quantity: 50,
        min_stock: 5,
        unit: 'un',
        active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
    ];
    
    // Tentar injetar produtos no estado do componente
    // (Isso é um hack temporário para teste)
    console.log('📦 Produtos de teste criados:', produtosTeste);
    return produtosTeste;
  };
  
  console.log('📋 Execute: window.forcarProdutosTeste() para testar');
  
} else {
  console.log('❌ ProductSearch não encontrado. Verifique se está na página de Vendas');
}

// 3. Verificar Supabase connection
if (window.supabase) {
  console.log('✅ Supabase client disponível');
  
  // Teste de conexão
  window.supabase
    .from('produtos')
    .select('count(*)', { count: 'exact' })
    .then(({ data, error, count }) => {
      if (error) {
        console.error('❌ Erro de conexão Supabase:', error.message);
        console.log('🔧 Possível causa: RLS, Auth ou tabela inexistente');
      } else {
        console.log('✅ Conexão Supabase OK, produtos encontrados:', count);
      }
    });
    
} else {
  console.log('❌ Supabase client não disponível');
}

console.log('\n📋 DIAGNÓSTICO COMPLETO:');
console.log('1. Verifique os logs acima');  
console.log('2. Se Supabase OK mas produtos = 0, problema é RLS');
console.log('3. Se Supabase erro, problema é conexão/auth');
console.log('4. Execute window.forcarProdutosTeste() para testar interface');
