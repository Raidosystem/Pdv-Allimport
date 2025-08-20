const { createClient } = require('@supabase/supabase-js');

async function corrigirRLSRapido() {
  const supabase = createClient(
    'https://kmcaaqetxtwkdcczdomw.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.J4gAQcV_rJiw1xAvXgo8kyiPvDIZN3HtKyuBR-i5jL4',
    { auth: { autoRefreshToken: false, persistSession: false } }
  );
  
  console.log('🔒 CORREÇÃO RÁPIDA DE RLS');
  console.log('');
  
  // Desabilitar RLS temporariamente para teste
  console.log('1️⃣ Desabilitando RLS temporariamente...');
  try {
    const { error } = await supabase.rpc('exec_sql', { 
      sql_query: 'ALTER TABLE public.user_approvals DISABLE ROW LEVEL SECURITY;'
    });
    
    if (error) {
      console.log('❌ Erro ao desabilitar RLS:', error.message);
    } else {
      console.log('✅ RLS desabilitado');
    }
  } catch (e) {
    console.log('❌ Falha:', e.message);
  }
  
  // Teste de acesso
  console.log('');
  console.log('2️⃣ Testando acesso sem RLS...');
  
  try {
    const { data, error } = await supabase
      .from('user_approvals')
      .select('email, user_role, status, full_name')
      .eq('user_role', 'employee');
      
    if (error) {
      console.log('❌ ERRO:', error.message);
      console.log('Código:', error.code);
    } else {
      console.log('✅ ACESSO OK!');
      console.log('👥 Funcionários encontrados:', data.length);
      
      data.forEach(emp => {
        console.log(`- ${emp.full_name} (${emp.email}) - ${emp.status}`);
      });
      
      if (data.length === 0) {
        console.log('⚠️ Nenhum funcionário encontrado na tabela');
      }
    }
  } catch (err) {
    console.log('❌ Erro geral:', err.message);
  }
  
  console.log('');
  console.log('🎯 PRÓXIMO PASSO:');
  console.log('Agora teste novamente: http://localhost:5174/debug-supabase');
}

corrigirRLSRapido().catch(console.error);
