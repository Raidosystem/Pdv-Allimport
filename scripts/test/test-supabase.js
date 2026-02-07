// Teste da configuração do Supabase no frontend
console.log('🔧 TESTE DE CONFIGURAÇÃO SUPABASE NO FRONTEND');
console.log('');

// Verificar se as variáveis estão disponíveis
console.log('📋 VARIÁVEIS DE AMBIENTE:');
console.log('VITE_SUPABASE_URL:', import.meta.env?.VITE_SUPABASE_URL || 'UNDEFINED');
console.log('VITE_SUPABASE_ANON_KEY:', import.meta.env?.VITE_SUPABASE_ANON_KEY ? 'PRESENTE' : 'UNDEFINED');

// Importar cliente do Supabase
import { supabase } from './src/lib/supabase.ts';

console.log('');
console.log('📡 TESTANDO CONEXÃO COM SUPABASE:');

// Teste simples de conexão
try {
  const { data, error } = await supabase
    .from('user_approvals')
    .select('count(*)')
    .limit(1);
    
  if (error) {
    console.error('❌ ERRO na conexão:', error.message);
    console.error('Detalhes:', error);
  } else {
    console.log('✅ Conexão com Supabase OK');
    console.log('Dados recebidos:', data);
  }
} catch (err) {
  console.error('❌ ERRO GERAL:', err);
}

// Teste específico da query de funcionários
console.log('');
console.log('👥 TESTANDO QUERY DE FUNCIONÁRIOS:');

const ownerID = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

try {
  const { data: employees, error: empError } = await supabase
    .from('user_approvals')
    .select('*')
    .eq('parent_user_id', ownerID)
    .eq('user_role', 'employee')
    .eq('status', 'approved')
    .order('created_at', { ascending: false });

  if (empError) {
    console.error('❌ ERRO na query de funcionários:', empError.message);
    console.error('Código do erro:', empError.code);
    console.error('Detalhes:', empError.details);
  } else {
    console.log('✅ Query de funcionários OK');
    console.log('👥 Funcionários encontrados:', employees?.length || 0);
    
    if (employees && employees.length > 0) {
      employees.forEach((emp, index) => {
        console.log(`${index + 1}. ${emp.full_name} (${emp.email})`);
      });
    }
  }
} catch (err) {
  console.error('❌ ERRO GERAL na query:', err);
}
