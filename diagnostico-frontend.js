// Diagnóstico rápido do frontend
// Adicione este código no console do navegador para diagnosticar

console.log('🔍 DIAGNÓSTICO DE AUTENTICAÇÃO');
console.log('==============================');

// Verificar se Supabase está disponível
if (typeof window !== 'undefined' && window.supabase) {
  console.log('✅ Supabase disponível no frontend');
  
  // Verificar usuário atual
  window.supabase.auth.getUser().then(({ data: { user }, error }) => {
    if (error) {
      console.log('❌ Erro ao verificar usuário:', error);
    } else if (user) {
      console.log('✅ Usuário logado:', {
        id: user.id,
        email: user.email,
        criado_em: user.created_at
      });
      
      // Testar abertura de caixa
      console.log('\n🧪 Testando abertura de caixa...');
      
      const testeCaixa = {
        usuario_id: user.id,
        valor_inicial: 50.00,
        observacoes: 'Teste via console',
        status: 'aberto'
      };
      
      window.supabase
        .from('caixa')
        .insert(testeCaixa)
        .then(({ data, error }) => {
          if (error) {
            console.log('❌ Erro ao abrir caixa:', error);
          } else {
            console.log('✅ Caixa aberto com sucesso:', data);
          }
        });
        
    } else {
      console.log('❌ Usuário não está logado');
    }
  });
  
  // Verificar sessão
  window.supabase.auth.getSession().then(({ data: { session }, error }) => {
    if (error) {
      console.log('❌ Erro na sessão:', error);
    } else if (session) {
      console.log('✅ Sessão ativa:', {
        expires_at: new Date(session.expires_at * 1000),
        user_id: session.user.id
      });
    } else {
      console.log('❌ Nenhuma sessão ativa');
    }
  });
  
} else {
  console.log('❌ Supabase não encontrado no frontend');
}

console.log('\n💡 INSTRUÇÕES:');
console.log('1. Copie este código');
console.log('2. Abra o sistema no navegador: https://pdv-allimport.vercel.app');
console.log('3. Faça login');
console.log('4. Abra o console (F12 → Console)');
console.log('5. Cole e execute este código');
console.log('6. Veja o resultado do diagnóstico');
