// Script de debug para executar no console do navegador
// Abra http://localhost:5174 e cole este código no console (F12)

console.log('🔍 DIAGNÓSTICO DE PRODUTOS PERDIDOS');
console.log('==================================');

// 1. Verificar se Supabase está disponível
if (window.supabase) {
  console.log('✅ Supabase client disponível');
  
  // 2. Verificar produtos na tabela 'produtos'
  console.log('\n📦 Verificando tabela produtos...');
  window.supabase
    .from('produtos')
    .select('*', { count: 'exact' })
    .then(({ data, error, count }) => {
      if (error) {
        console.error('❌ Erro na tabela produtos:', error.message);
        console.log('🔧 Código do erro:', error.code);
        console.log('🔧 Detalhes:', error);
      } else {
        console.log(`✅ Tabela produtos: ${count} registros encontrados`);
        if (data && data.length > 0) {
          console.log('📋 Primeiros produtos:', data.slice(0, 5).map(p => ({
            nome: p.nome,
            user_id: p.user_id?.slice(0, 8) + '...',
            ativo: p.ativo
          })));
        } else {
          console.log('⚠️ Nenhum produto encontrado na tabela produtos');
        }
      }
    });

  // 3. Verificar produtos na tabela 'products' (antiga)
  console.log('\n📦 Verificando tabela products...');
  window.supabase
    .from('products')
    .select('*', { count: 'exact' })
    .then(({ data, error, count }) => {
      if (error) {
        console.error('❌ Erro na tabela products:', error.message);
      } else {
        console.log(`✅ Tabela products: ${count} registros encontrados`);
        if (data && data.length > 0) {
          console.log('📋 Primeiros products:', data.slice(0, 5).map(p => ({
            name: p.name,
            user_id: p.user_id?.slice(0, 8) + '...',
            active: p.active
          })));
        }
      }
    });

  // 4. Verificar usuário atual
  console.log('\n👤 Verificando usuário atual...');
  window.supabase.auth.getUser().then(({ data, error }) => {
    if (error) {
      console.error('❌ Erro ao obter usuário:', error.message);
    } else {
      console.log('✅ Usuário atual:', {
        id: data.user?.id?.slice(0, 8) + '...',
        email: data.user?.email
      });
    }
  });

  // 5. Verificar se é o usuário problemático
  window.supabase.auth.getUser().then(({ data }) => {
    if (data.user?.email === 'assistenciaallimport0@gmail.com') {
      console.log('🎯 USUÁRIO PROBLEMÁTICO DETECTADO!');
      console.log('Verificando produtos específicos...');
      
      window.supabase
        .from('produtos')
        .select('*')
        .eq('user_id', data.user.id)
        .then(({ data: produtos, error }) => {
          if (error) {
            console.error('❌ Erro ao buscar produtos do usuário:', error);
          } else {
            console.log(`🔍 Produtos do usuário ${data.user.email}: ${produtos?.length || 0}`);
            if (produtos && produtos.length > 0) {
              console.log('📋 Alguns produtos:', produtos.slice(0, 3));
            }
          }
        });
    }
  });

} else {
  console.error('❌ Supabase client não encontrado');
  console.log('🔧 Certifique-se de que está na página do PDV');
}

console.log('\n📋 PRÓXIMOS PASSOS:');
console.log('1. Aguarde os resultados acima');
console.log('2. Se tabela produtos = 0, problema é migração/RLS');
console.log('3. Se tabela products > 0, dados estão na tabela antiga');