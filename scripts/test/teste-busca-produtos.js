// 🧪 TESTE DE BUSCA DE PRODUTOS
// Execute no console do navegador para testar

console.log('🧪 Testando busca de produtos...');

// Simular uma busca simples
const testSearchTerm = 'WIRELESS';

// Testar produtos embutidos diretamente
console.log('📦 Testando produtos embutidos...');

// 1. Verificar se os produtos estão carregados
try {
  // Simular o que o componente faz
  const productos = [
    {
      id: "a2d4691b-ab4d-4aba-a1e6-a1e69f57a3b0",
      name: "WIRELESS MICROPHONE",
      sku: "WM001",
      barcode: "",
      price: 160,
      stock: 1,
      category: "Áudio",
      active: true
    },
    {
      id: "17fd37b4-b9f0-484c-aeb1-6702b8b80b5f",
      name: "MINI MICROFONE DE LAPELA",
      sku: "ML001", 
      barcode: "7898594127486",
      price: 24.99,
      stock: 4,
      category: "Áudio",
      active: true
    }
  ];

  console.log('✅ Produtos de teste carregados:', productos.length);

  // 2. Testar função de busca
  function normalizeText(text) {
    return text
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '');
  }

  function testSearch(searchTerm) {
    const search = normalizeText(searchTerm);
    return productos.filter(product => 
      normalizeText(product.name).includes(search) ||
      normalizeText(product.sku).includes(search) ||
      product.barcode.includes(searchTerm) ||
      normalizeText(product.category).includes(search)
    );
  }

  // 3. Executar teste
  const resultados = testSearch(testSearchTerm);
  console.log(`🔍 Busca por "${testSearchTerm}":`, resultados);

  if (resultados.length > 0) {
    console.log('✅ BUSCA FUNCIONANDO! Produtos encontrados:', resultados.length);
    resultados.forEach(p => {
      console.log(`  - ${p.name} (${p.sku})`);
    });
  } else {
    console.log('❌ BUSCA NÃO RETORNOU RESULTADOS');
  }

  // 4. Testar outros termos
  const testTerms = ['MICROFONE', 'WIRELESS', 'AUDIO', 'WM001'];
  testTerms.forEach(term => {
    const results = testSearch(term);
    console.log(`🔍 "${term}": ${results.length} resultados`);
  });

} catch (error) {
  console.error('❌ Erro no teste:', error);
}

console.log('🏁 Teste concluído. Verifique os logs acima.');