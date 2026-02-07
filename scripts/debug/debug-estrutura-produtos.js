// Script para descobrir todos os campos da tabela produtos
// Cole no console do navegador

console.log('🔍 DESCOBRINDO ESTRUTURA DA TABELA PRODUTOS');
console.log('==========================================');

if (window.supabase) {
  window.supabase
    .from('produtos')
    .select('*')
    .limit(1)
    .then(({ data, error }) => {
      if (error) {
        console.error('❌ Erro:', error);
      } else if (data && data.length > 0) {
        const produto = data[0];
        console.log('📦 PRODUTO DE EXEMPLO:', produto.nome);
        console.log('\n🔍 TODOS OS CAMPOS DISPONÍVEIS:');
        
        Object.keys(produto).sort().forEach(key => {
          const value = produto[key];
          const type = typeof value;
          console.log(`${key}: ${value} (${type})`);
        });
        
        console.log('\n📊 CAMPOS RELACIONADOS AO ESTOQUE:');
        const stockFields = Object.keys(produto).filter(key => 
          key.toLowerCase().includes('stock') || 
          key.toLowerCase().includes('estoque') ||
          key.toLowerCase().includes('quantidade') ||
          key.toLowerCase().includes('qty')
        );
        
        if (stockFields.length > 0) {
          stockFields.forEach(field => {
            console.log(`✅ ${field}: ${produto[field]}`);
          });
        } else {
          console.log('❌ Nenhum campo de estoque encontrado!');
        }
      } else {
        console.log('❌ Nenhum produto encontrado');
      }
    });
} else {
  console.error('❌ Supabase não disponível');
}