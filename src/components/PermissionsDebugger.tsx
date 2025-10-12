import React, { useState } from 'react';
import { usePermissions } from '../hooks/usePermissions';
import { supabase } from '../lib/supabase';
import { RefreshCw, User, Shield, Database, AlertTriangle, CheckCircle } from 'lucide-react';

export const PermissionsDebugger: React.FC = () => {
  const { 
    isAdmin, 
    isAdminEmpresa, 
    isSuperAdmin, 
    tipoAdmin, 
    can, 
    loading, 
    permissoes,
    user 
  } = usePermissions();
  
  const [dbCheck, setDbCheck] = useState<any>(null);
  const [checking, setChecking] = useState(false);

  const checkDatabase = async () => {
    if (!user?.id) return;
    
    setChecking(true);
    try {
      // Verificar dados do funcionário
      const { data: funcionario, error: funcError } = await supabase
        .from('funcionarios')
        .select(`
          id,
          nome,
          email,
          tipo_admin,
          status,
          empresa_id,
          empresas (
            id,
            nome
          ),
          funcionario_funcoes (
            funcao_id,
            funcoes (
              id,
              nome,
              descricao
            )
          )
        `)
        .eq('empresa_id', user.id)
        .single();

      setDbCheck({
        funcionario,
        error: funcError,
        empresa_id: user.id,
        email: user.email
      });
    } catch (error) {
      setDbCheck({ error: error });
    } finally {
      setChecking(false);
    }
  };

  const createAdminUser = async () => {
    if (!user?.id || !user?.email) return;
    
    setChecking(true);
    try {
      // Tentar criar funcionário como admin_empresa
      const { data: empresa } = await supabase
        .from('empresas')
        .select('id')
        .limit(1)
        .single();

      if (!empresa) {
        // Criar empresa padrão
        const { data: novaEmpresa } = await supabase
          .from('empresas')
          .insert({
            nome: 'Allimport',
            cnpj: '00.000.000/0001-00',
            telefone: '(00) 0000-0000',
            email: user.email
          })
          .select('id')
          .single();

        if (novaEmpresa) {
          await createFuncionario();
        }
      } else {
        await createFuncionario();
      }
    } catch (error) {
      console.error('Erro ao criar usuário admin:', error);
    } finally {
      setChecking(false);
      checkDatabase();
    }
  };

  const createFuncionario = async () => {
    if (!user?.id || !user?.email) return;

    const { data: funcionario } = await supabase
      .from('funcionarios')
      .insert({
        empresa_id: user.id,
        nome: user.email.split('@')[0] || 'Admin',
        email: user.email,
        status: 'ativo'
      })
      .select()
      .single();

    return funcionario;
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-lg max-w-4xl">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-gray-900 flex items-center gap-2">
          <Shield className="w-6 h-6" />
          Debug de Permissões
        </h2>
        <button
          onClick={checkDatabase}
          disabled={checking}
          className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
        >
          <RefreshCw className={`w-4 h-4 ${checking ? 'animate-spin' : ''}`} />
          Verificar DB
        </button>
      </div>

      {/* Status atual */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold text-gray-900 mb-2 flex items-center gap-2">
            <User className="w-4 h-4" />
            Status do Usuário
          </h3>
          <div className="space-y-1 text-sm">
            <div>Email: <code className="bg-gray-200 px-1 rounded">{user?.email || 'N/A'}</code></div>
            <div>User ID: <code className="bg-gray-200 px-1 rounded text-xs">{user?.id || 'N/A'}</code></div>
            <div>Loading: <span className={loading ? 'text-yellow-600' : 'text-green-600'}>{loading ? 'Sim' : 'Não'}</span></div>
          </div>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold text-gray-900 mb-2 flex items-center gap-2">
            <Shield className="w-4 h-4" />
            Permissões
          </h3>
          <div className="space-y-1 text-sm">
            <div className="flex items-center gap-2">
              {isAdmin ? <CheckCircle className="w-4 h-4 text-green-600" /> : <AlertTriangle className="w-4 h-4 text-red-600" />}
              <span>isAdmin: {isAdmin ? 'Sim' : 'Não'}</span>
            </div>
            <div className="flex items-center gap-2">
              {isAdminEmpresa ? <CheckCircle className="w-4 h-4 text-green-600" /> : <AlertTriangle className="w-4 h-4 text-gray-400" />}
              <span>isAdminEmpresa: {isAdminEmpresa ? 'Sim' : 'Não'}</span>
            </div>
            <div className="flex items-center gap-2">
              {isSuperAdmin ? <CheckCircle className="w-4 h-4 text-blue-600" /> : <AlertTriangle className="w-4 h-4 text-gray-400" />}
              <span>isSuperAdmin: {isSuperAdmin ? 'Sim' : 'Não'}</span>
            </div>
            <div>Tipo Admin: <code className="bg-gray-200 px-1 rounded">{tipoAdmin}</code></div>
          </div>
        </div>
      </div>

      {/* Permissões específicas */}
      <div className="bg-gray-50 p-4 rounded-lg mb-6">
        <h3 className="font-semibold text-gray-900 mb-2">Verificações de Acesso</h3>
        <div className="grid grid-cols-2 md:grid-cols-3 gap-2 text-sm">
          {[
            ['administracao.usuarios', 'read'],
            ['administracao.usuarios', 'create'],
            ['administracao.funcoes', 'read'],
            ['administracao.sistema', 'read'],
            ['vendas', 'create'],
            ['caixa', 'read']
          ].map(([recurso, acao]) => (
            <div key={`${recurso}:${acao}`} className="flex items-center gap-2">
              {can(recurso, acao) ? 
                <CheckCircle className="w-3 h-3 text-green-600" /> : 
                <AlertTriangle className="w-3 h-3 text-red-600" />
              }
              <span className="text-xs">{recurso}:{acao}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Dados do banco */}
      {dbCheck && (
        <div className="bg-gray-50 p-4 rounded-lg mb-4">
          <h3 className="font-semibold text-gray-900 mb-2 flex items-center gap-2">
            <Database className="w-4 h-4" />
            Dados do Banco
          </h3>
          <pre className="text-xs bg-gray-100 p-2 rounded overflow-auto max-h-40">
            {JSON.stringify(dbCheck, null, 2)}
          </pre>
        </div>
      )}

      {/* Ações de correção */}
      {dbCheck?.error && (
        <div className="bg-yellow-50 border border-yellow-200 p-4 rounded-lg">
          <div className="flex items-center gap-2 mb-2">
            <AlertTriangle className="w-5 h-5 text-yellow-600" />
            <h3 className="font-semibold text-yellow-900">Problema Detectado</h3>
          </div>
          <p className="text-yellow-800 mb-3">
            Usuário não encontrado na tabela de funcionários. Isso pode causar problemas de acesso.
          </p>
          <button
            onClick={createAdminUser}
            disabled={checking}
            className="px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 disabled:opacity-50"
          >
            {checking ? 'Criando...' : 'Criar Usuário Admin'}
          </button>
        </div>
      )}

      {/* Lista de permissões */}
      {permissoes.length > 0 && (
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold text-gray-900 mb-2">Permissões Ativas ({permissoes.length})</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-1 text-xs max-h-40 overflow-y-auto">
            {permissoes.map(perm => (
              <code key={perm} className="bg-gray-200 px-1 rounded">{perm}</code>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default PermissionsDebugger;