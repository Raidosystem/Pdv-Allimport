// Teste rápido no console - Cole isto para testar se as mudanças estão ativas
console.log('🧪 TESTE RÁPIDO - VERIFICANDO MUDANÇAS');

// 1. Verificar se o hook tem os novos logs
if (window.React && window.React.version) {
  console.log('✅ React ativo:', window.React.version);
} else {
  console.log('⚠️ React não detectado no window');
}

// 2. Testar a query que deve funcionar
if (window.supabase) {
  console.log('🔍 Testando query do ProductService (que funciona):');
  window.supabase
    .from('produtos')
    .select('*')
    .eq('ativo', true)
    .order('nome')
    .limit(5)
    .then(({ data, error, count }) => {
      if (error) {
        console.error('❌ Erro na query do ProductService:', error.message);
        console.error('🔧 Detalhes do erro:', error);
      } else {
        console.log(`✅ Query do ProductService OK: ${data?.length || 0} produtos`);
        if (data && data.length > 0) {
          console.log('📋 Primeiros produtos:', data.slice(0, 2).map(p => ({
            nome: p.nome,
            ativo: p.ativo,
            user_id: p.user_id?.slice(0, 8) + '...'
          })));
        }
      }
    });

  console.log('🔍 Testando query antiga do useProdutos (que falha):');
  window.supabase
    .from('produtos')
    .select('*')
    .eq('ativo', true)
    .order('criado_em', { ascending: false })
    .limit(5)
    .then(({ data, error }) => {
      if (error) {
        console.error('❌ PROBLEMA ENCONTRADO - Query antiga falha:', error.message);
        console.error('🔧 Código do erro:', error.code);
        console.error('🔧 Este é o motivo dos 0 produtos!');
      } else {
        console.log('⚠️ Query antiga funcionou, problema é outro');
      }
    });
}

console.log('📋 INTERPRETAÇÃO:');
console.log('- Se ProductService OK mas useProdutos falha = cache não atualizado');
console.log('- Se ambos falham = problema de RLS/Auth');
console.log('- Se ambos funcionam = problema no React/Hook');