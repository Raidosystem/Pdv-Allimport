// Teste da função fetchEmployees para debugar por que Gregori não aparece
const { createClient } = require('@supabase/supabase-js');

async function testarFetchEmployees() {
  const supabase = createClient(
    'https://YOUR_SUPABASE_PROJECT.supabase.co',
    'YOUR_SUPABASE_ANON_KEY'
    { auth: { autoRefreshToken: false, persistSession: false } }
  );
  
  console.log('🧪 TESTANDO FUNÇÃO fetchEmployees EXATA');
  console.log('');
  
  const userID = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'; // assistenciaallimport10@gmail.com
  
  console.log('📋 EXECUTANDO A MESMA QUERY DO FRONTEND:');
  console.log('');
  
  // Esta é a query EXATA do código React
  const { data, error } = await supabase
    .from('user_approvals')
    .select('*')
    .eq('parent_user_id', userID)
    .eq('user_role', 'employee')
    .eq('status', 'approved')
    .order('created_at', { ascending: false });

  if (error) {
    console.error('❌ ERRO na query:', error);
    return;
  }

  console.log('📊 RESULTADO:');
  console.log('Número de funcionários encontrados:', data?.length || 0);
  
  if (!data || data.length === 0) {
    console.log('❌ NENHUM funcionário encontrado!');
    console.log('');
    console.log('🔍 DEBUGANDO...');
    
    // Testar cada condição separadamente
    console.log('');
    console.log('1️⃣ Testando parent_user_id...');
    const { data: test1 } = await supabase
      .from('user_approvals')
      .select('*')
      .eq('parent_user_id', userID);
    console.log('   Registros com parent_user_id correto:', test1?.length || 0);
    
    console.log('');
    console.log('2️⃣ Testando user_role...');
    const { data: test2 } = await supabase
      .from('user_approvals')
      .select('*')
      .eq('parent_user_id', userID)
      .eq('user_role', 'employee');
    console.log('   Registros que são employee:', test2?.length || 0);
    
    console.log('');
    console.log('3️⃣ Testando status...');
    const { data: test3 } = await supabase
      .from('user_approvals')
      .select('*')
      .eq('parent_user_id', userID)
      .eq('user_role', 'employee')
      .eq('status', 'approved');
    console.log('   Registros aprovados:', test3?.length || 0);
    
    // Mostrar dados específicos do Gregori
    console.log('');
    console.log('🔍 DADOS ESPECÍFICOS DO GREGORI:');
    const { data: gregori } = await supabase
      .from('user_approvals')
      .select('*')
      .eq('email', 'teste@teste.com')
      .single();
      
    if (gregori) {
      console.log('   📧 Email:', gregori.email);
      console.log('   👑 Parent ID:', gregori.parent_user_id);
      console.log('   🏷️ Tipo:', gregori.user_role);
      console.log('   📊 Status:', gregori.status);
      console.log('');
      console.log('   ✅ Parent correto?', gregori.parent_user_id === userID);
      console.log('   ✅ Tipo correto?', gregori.user_role === 'employee');
      console.log('   ✅ Status correto?', gregori.status === 'approved');
    }
  } else {
    console.log('✅ Funcionários encontrados:');
    data.forEach((emp, index) => {
      console.log(`${index + 1}. ${emp.full_name} (${emp.email})`);
    });
  }
}

testarFetchEmployees().catch(console.error);
