// Script para verificar os campos de estoque na tabela produtos
// Cole no console do navegador

console.log('🔍 VERIFICANDO CAMPOS DE ESTOQUE');
console.log('===============================');

if (window.supabase) {
  // Buscar um produto para ver todos os campos disponíveis
  window.supabase
    .from('produtos')
    .select('*')
    .limit(1)
    .then(({ data, error }) => {
      if (error) {
        console.error('❌ Erro:', error);
      } else if (data && data.length > 0) {
        const produto = data[0];
        console.log('📦 Produto de exemplo:', produto);
        console.log('\n🔍 Campos relacionados ao estoque:');
        
        // Verificar possíveis campos de estoque
        const possibleStockFields = [
          'estoque',
          'estoque_atual', 
          'current_stock',
          'stock_quantity',
          'quantidade_estoque',
          'qty_stock'
        ];
        
        possibleStockFields.forEach(field => {
          if (produto.hasOwnProperty(field)) {
            console.log(`✅ ${field}: ${produto[field]}`);
          } else {
            console.log(`❌ ${field}: não encontrado`);
          }
        });
        
        console.log('\n📋 TODOS OS CAMPOS DO PRODUTO:');
        Object.keys(produto).forEach(key => {
          console.log(`${key}: ${produto[key]}`);
        });
      } else {
        console.log('❌ Nenhum produto encontrado');
      }
    });
} else {
  console.error('❌ Supabase não disponível');
}