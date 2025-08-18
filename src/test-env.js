// Teste para verificar se as variáveis de ambiente estão sendo carregadas
console.log('🔍 VERIFICANDO VARIÁVEIS DE AMBIENTE\n');

console.log('VITE_SUPABASE_URL:', import.meta.env.VITE_SUPABASE_URL);
console.log('VITE_SUPABASE_ANON_KEY:', import.meta.env.VITE_SUPABASE_ANON_KEY ? 'DEFINIDA' : 'NÃO DEFINIDA');
console.log('VITE_APP_NAME:', import.meta.env.VITE_APP_NAME);
console.log('VITE_APP_URL:', import.meta.env.VITE_APP_URL);

console.log('\nVariáveis definidas:', Object.keys(import.meta.env).filter(key => key.startsWith('VITE_')));
