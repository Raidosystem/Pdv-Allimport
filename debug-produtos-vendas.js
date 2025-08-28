// SCRIPT PARA DIAGNOSTICAR PROBLEMAS DE PRODUTOS EM VENDAS
// Execute no console do navegador (F12 → Console)

console.log('🔍 DIAGNÓSTICO: Produtos em Vendas');

// 1. Verificar se a tabela produtos existe
console.log('\n1️⃣ Testando conexão com tabela produtos...');

// 2. Simular busca de produtos
function testarBuscaProdutos() {
  console.log('\n2️⃣ Simulando busca de produtos...');
  
  // Busca por produtos
  if (window.supabase) {
    window.supabase
      .from('produtos')
      .select('*')
      .limit(5)
      .then(({ data, error }) => {
        if (error) {
          console.error('❌ Erro ao buscar produtos:', error);
          console.log('🔧 Possível causa: RLS ou tabela não existe');
        } else {
          console.log('✅ Produtos encontrados:', data?.length || 0);
          console.log('📋 Produtos:', data);
        }
      });
  } else {
    console.log('❌ Supabase client não disponível');
  }
}

// 3. Verificar ProductService
function testarProductService() {
  console.log('\n3️⃣ Testando ProductService...');
  
  if (window.productService) {
    window.productService.search({ search: 'test' })
      .then(products => {
        console.log('✅ ProductService funcionando, produtos:', products.length);
        console.log('📋 Produtos retornados:', products);
      })
      .catch(error => {
        console.error('❌ Erro no ProductService:', error);
      });
  } else {
    console.log('❌ ProductService não disponível globalmente');
  }
}

// 4. Verificar se botões de editar funcionam
function testarBotoesEditar() {
  console.log('\n4️⃣ Testando botões de editar...');
  
  const editButtons = document.querySelectorAll('button[title*="Editar"]');
  console.log(`📍 Encontrados ${editButtons.length} botões de editar`);
  
  if (editButtons.length > 0) {
    console.log('✅ Botões de editar encontrados na página');
  } else {
    console.log('❌ Nenhum botão de editar encontrado');
  }
}

// Executar todos os testes
setTimeout(() => {
  testarBuscaProdutos();
  testarProductService();
  testarBotoesEditar();
}, 1000);

console.log('\n📋 INSTRUÇÕES:');
console.log('1. Aguarde os resultados dos testes acima');
console.log('2. Verifique se há erros em vermelho');
console.log('3. Se produtos = 0, problema está na tabela/RLS');
console.log('4. Se botões = 0, problema está nos handlers onClick');
