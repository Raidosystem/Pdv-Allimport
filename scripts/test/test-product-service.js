// Teste rápido do ProductService
console.log('🧪 Testando ProductService...')

// Simular uma busca
const testSearch = async () => {
  try {
    const { productService } = await import('./src/services/salesNew.js')
    
    console.log('1️⃣ Testando busca vazia (todos os produtos):')
    const allProducts = await productService.search({})
    console.log(`📦 Total de produtos: ${allProducts.length}`)
    
    console.log('2️⃣ Testando busca por "MICRO":')
    const microProducts = await productService.search({ search: 'MICRO' })
    console.log(`🔍 Produtos com "MICRO": ${microProducts.length}`)
    microProducts.slice(0, 3).forEach((p, i) => {
      console.log(`  ${i+1}. ${p.name} - R$ ${p.price}`)
    })
    
    console.log('3️⃣ Testando busca por código de barras:')
    const barcodeProducts = await productService.search({ search: '7891234567890' })
    console.log(`📊 Produtos por barcode: ${barcodeProducts.length}`)
    
    console.log('✅ ProductService funcionando!')
    
  } catch (error) {
    console.error('❌ Erro no teste:', error)
  }
}

testSearch()
