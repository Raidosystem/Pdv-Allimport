import { useEffect, useState } from 'react';
import { createClient } from '@supabase/supabase-js';

export default function DebugSupabase() {
  const [results, setResults] = useState<string[]>([]);
  
  const addLog = (message: string) => {
    console.log(message); // Também logar no console
    setResults(prev => [...prev, message]);
  };

  useEffect(() => {
    const runTests = async () => {
      addLog('🔧 TESTE DIRETO DE SUPABASE - v3.0');
      addLog('');
      
      // Teste 1: Verificar variáveis de ambiente diretamente
      addLog('� VARIÁVEIS DE AMBIENTE RAW:');
      addLog(`import.meta.env: ${JSON.stringify(import.meta.env, null, 2)}`);
      addLog('');
      
      // Teste 2: Criar cliente diretamente aqui
      addLog('� CRIANDO CLIENTE SUPABASE DIRETAMENTE:');
      const url = import.meta.env.VITE_SUPABASE_URL;
      const key = import.meta.env.VITE_SUPABASE_ANON_KEY;

      if (!url || !key) {
        addLog('Credenciais do Supabase não configuradas');
        return;
      }

      addLog(`URL: ${url}`);
      addLog(`KEY: ${key ? 'PRESENTE (length: ' + key.length + ')' : 'AUSENTE'}`);
      addLog('');

      const testClient = createClient(url, key);
      addLog(`Cliente criado: ${!!testClient}`);
      addLog('');
      
      // Teste 3: Conexão básica
      addLog('📡 TESTE DE CONEXÃO BÁSICA:');
      try {
        const { data, error } = await testClient
          .from('user_approvals')
          .select('id')
          .limit(1);
          
        if (error) {
          addLog(`❌ ERRO: ${error.message}`);
          addLog(`Código: ${error.code}`);
          addLog(`Detalhes: ${error.details}`);
        } else {
          addLog('✅ Conexão OK');
          addLog(`Dados: ${JSON.stringify(data)}`);
        }
      } catch (err: any) {
        addLog(`❌ ERRO GERAL: ${err.message}`);
      }
      
      addLog('');
      
      // Teste 4: Query de funcionários
      addLog('👥 TESTE QUERY FUNCIONÁRIOS:');
      const ownerID = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';
      
      try {
        const { data: employees, error: empError } = await testClient
          .from('user_approvals')
          .select('*')
          .eq('parent_user_id', ownerID)
          .eq('user_role', 'employee')
          .eq('status', 'approved')
          .order('created_at', { ascending: false });

        if (empError) {
          addLog(`❌ ERRO na query: ${empError.message}`);
          addLog(`Código: ${empError.code}`);
        } else {
          addLog(`✅ Query OK - ${employees?.length || 0} funcionários`);
          
          if (employees && employees.length > 0) {
            employees.forEach((emp: any, index: number) => {
              addLog(`${index + 1}. ${emp.full_name} (${emp.email})`);
            });
          }
        }
      } catch (err: any) {
        addLog(`❌ ERRO GERAL: ${err.message}`);
      }
    };

    runTests();
  }, []);

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <h1 className="text-2xl font-bold mb-6">Debug Supabase</h1>
      
      <div className="bg-gray-100 p-4 rounded-lg font-mono text-sm">
        {results.map((result, index) => (
          <div key={index} className="mb-1">
            {result}
          </div>
        ))}
      </div>
    </div>
  );
}
