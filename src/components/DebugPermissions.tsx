import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

const DebugPermissions: React.FC = () => {
  const [userInfo, setUserInfo] = useState<any>(null);
  const [funcionarioInfo, setFuncionarioInfo] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    checkUserAndPermissions();
  }, []);

  const checkUserAndPermissions = async () => {
    try {
      // Verificar usuário logado
      const { data: { user }, error: userError } = await supabase.auth.getUser();
      
      if (userError) {
        setError('Erro ao obter usuário: ' + userError.message);
        setLoading(false);
        return;
      }

      if (!user) {
        setError('Nenhum usuário logado');
        setLoading(false);
        return;
      }

      setUserInfo(user);

      // Verificar funcionário
      const { data: funcionario, error: funcError } = await supabase
        .from('funcionarios')
        .select('*')
        .eq('user_id', user.id)
        .single();

      if (funcError) {
        console.log('Erro ao buscar funcionário:', funcError);
        setFuncionarioInfo({ error: funcError.message });
      } else {
        setFuncionarioInfo(funcionario);
      }

    } catch (err) {
      setError('Erro geral: ' + (err as Error).message);
    } finally {
      setLoading(false);
    }
  };

  const createTestUser = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      // Criar empresa de teste
      await supabase
        .from('empresas')
        .upsert({
          id: '00000000-0000-0000-0000-000000000001',
          nome: 'Empresa Teste',
          email: user.email,
          plano: 'professional',
          status: 'ativo',
          max_usuarios: 50,
          max_lojas: 5,
          features: { pdv: true },
          tema: { primaryColor: '#3B82F6', mode: 'light' },
          configuracoes: { backup_automatico: true }
        });

      // Criar funcionário admin
      await supabase
        .from('funcionarios')
        .upsert({
          user_id: user.id,
          empresa_id: '00000000-0000-0000-0000-000000000001',
          nome: user.email?.split('@')[0] || 'Admin',
          email: user.email,
          tipo_admin: 'admin_empresa',
          status: 'ativo',
          lojas: []
        });

      alert('Usuário de teste criado! Recarregue a página.');
      window.location.reload();

    } catch (err) {
      alert('Erro ao criar usuário: ' + (err as Error).message);
    }
  };

  if (loading) {
    return <div className="p-4">Carregando debug...</div>;
  }

  return (
    <div className="p-6 bg-gray-100 rounded-lg">
      <h2 className="text-xl font-bold mb-4">🔍 Debug Permissões</h2>
      
      {error && (
        <div className="bg-red-100 p-3 rounded mb-4">
          <strong>Erro:</strong> {error}
        </div>
      )}

      <div className="space-y-4">
        <div className="bg-white p-4 rounded">
          <h3 className="font-semibold">Usuário Supabase Auth:</h3>
          <pre className="text-sm bg-gray-50 p-2 mt-2 rounded overflow-x-auto">
            {JSON.stringify(userInfo, null, 2)}
          </pre>
        </div>

        <div className="bg-white p-4 rounded">
          <h3 className="font-semibold">Funcionário na tabela:</h3>
          <pre className="text-sm bg-gray-50 p-2 mt-2 rounded overflow-x-auto">
            {JSON.stringify(funcionarioInfo, null, 2)}
          </pre>
        </div>

        {funcionarioInfo?.error && (
          <button
            onClick={createTestUser}
            className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
          >
            Criar Usuário de Teste
          </button>
        )}

        <button
          onClick={checkUserAndPermissions}
          className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 mr-2"
        >
          Recarregar Debug
        </button>
      </div>
    </div>
  );
};

export default DebugPermissions;