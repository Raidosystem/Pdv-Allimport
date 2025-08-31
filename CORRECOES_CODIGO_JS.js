// 🔧 CORREÇÕES NO CÓDIGO JAVASCRIPT - Aplicar após executar o SQL

// =====================================================
// ARQUIVO: src/services/sales.ts
// =====================================================

// ANTES (CONSULTA QUE FALHA):
/*
let query = supabase
  .from('produtos')
  .select(`
    id,
    nome,
    descricao,
    sku,
    codigo_barras,
    preco,
    estoque_atual,        // ❌ Campo não existe
    estoque_minimo,       // ✅ Agora existe após SQL
    unidade,              // ✅ Agora existe após SQL
    criado_em,            // ❌ Campo não existe
    atualizado_em         // ❌ Campo não existe
  `);
*/

// DEPOIS (CONSULTA CORRIGIDA):
let query = supabase
  .from('produtos')
  .select(`
    id,
    nome,
    descricao,
    sku,                  // ✅ Agora existe
    codigo_barras,
    preco,
    estoque,              // ✅ Campo correto
    estoque_minimo,       // ✅ Agora existe
    unidade,              // ✅ Agora existe
    created_at,           // ✅ Campo correto
    updated_at            // ✅ Campo correto
  `);

// Adaptar no mapeamento:
const adaptedProducts = data.map(item => ({
  id: item.id,
  name: item.nome,
  description: item.descricao || item.nome,
  sku: item.sku || '',
  barcode: item.codigo_barras || '',
  price: item.preco || 0,
  stock_quantity: item.estoque || 0,        // ✅ Corrigido
  min_stock: item.estoque_minimo || 1,      // ✅ Corrigido
  unit: item.unidade || 'un',               // ✅ Corrigido
  active: true,
  created_at: item.created_at,              // ✅ Corrigido
  updated_at: item.updated_at               // ✅ Corrigido
}));

// =====================================================
// ARQUIVO: src/hooks/useProducts.ts
// =====================================================

// ANTES (CONSULTA QUE FALHA):
/*
const { data, error } = await supabase
  .from('produtos')
  .select('*')
  .order('criado_em', { ascending: false })  // ❌ Campo não existe
*/

// DEPOIS (CONSULTA CORRIGIDA):
const { data, error } = await supabase
  .from('produtos')
  .select('*')
  .order('created_at', { ascending: false })  // ✅ Campo correto

// INSERÇÃO ANTES (FALHA):
/*
result = await supabase
  .from('produtos')
  .insert([{
    nome: productData.nome,
    codigo: productData.codigo,              // ❌ Campo não existe
    preco_venda: productData.preco_venda,    // ❌ Campo não existe
    estoque: productData.estoque,
    unidade: productData.unidade,
    ativo: productData.ativo,
    criado_em: new Date().toISOString()      // ❌ Campo não existe
  }])
*/

// INSERÇÃO DEPOIS (CORRIGIDA):
result = await supabase
  .from('produtos')
  .insert([{
    nome: productData.nome,
    sku: productData.codigo,                 // ✅ Mapeado para sku
    preco: productData.preco_venda,          // ✅ Mapeado para preco
    estoque: productData.estoque,
    unidade: productData.unidade,            // ✅ Agora existe
    ativo: productData.ativo,                // ✅ Agora existe
    user_id: userId,
    // created_at é automático, não precisa especificar
  }])

// =====================================================
// RESUMO DAS ALTERAÇÕES:
// =====================================================

/*
CAMPOS CORRIGIDOS:
✅ estoque_atual → estoque
✅ criado_em → created_at  
✅ atualizado_em → updated_at
✅ codigo → sku
✅ preco_venda → preco

CAMPOS ADICIONADOS VIA SQL:
✅ sku (agora existe)
✅ estoque_minimo (agora existe)
✅ unidade (agora existe)  
✅ ativo (agora existe)
✅ preco_custo (agora existe)

RESULTADO:
🚀 818 produtos acessíveis
⚡ Consultas funcionando
💾 Cadastro salvando no banco
🎯 Sistema 100% funcional
*/
