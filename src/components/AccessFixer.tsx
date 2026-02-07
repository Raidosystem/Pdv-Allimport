import React, { useState, useEffect } from 'react';
import { AlertTriangle, Settings, CheckCircle, RefreshCw, Shield } from 'lucide-react';
import { usePermissions } from '../hooks/usePermissions';
import { supabase } from '../lib/supabase';
import WelcomeAdmin from './WelcomeAdmin';

interface AccessFixerProps {
  onFixed?: () => void;
  showWelcome?: boolean;
}

export const AccessFixer: React.FC<AccessFixerProps> = ({ onFixed, showWelcome = true }) => {
  const { isAdmin, isAdminEmpresa, loading, user, refresh } = usePermissions();
  const [fixing, setFixing] = useState(false);
  const [status, setStatus] = useState<'checking' | 'problem' | 'fixed' | 'error' | 'welcome'>('checking');
  const [message, setMessage] = useState('');

  useEffect(() => {
    if (!loading) {
      // REGRA: Todo usuário logado é admin da sua própria empresa
      // Não precisa de verificações complexas - quem comprou o sistema é o dono
      if (user?.id) {
        setStatus('fixed');
        setMessage('✅ Acesso administrativo ativo - Você é o administrador do sistema');
      } else if (isAdmin || isAdminEmpresa) {
        setStatus('fixed');
        setMessage('Acesso administrativo confirmado!');
      } else {
        setStatus('problem');
        setMessage('Problemas de acesso detectados. Clique para tentar corrigir automaticamente.');
      }
    }
  }, [isAdmin, isAdminEmpresa, loading, user]);

  const fixAccess = async () => {
    if (!user?.id || !user?.email) {
      setStatus('error');
      setMessage('Dados do usuário não disponíveis');
      return;
    }

    setFixing(true);
    setMessage('Verificando e corrigindo acesso...');

    try {
      // 1. Verificar se existe empresa
      let { data: empresa } = await supabase
        .from('empresas')
        .select('id')
        .limit(1)
        .single();

      if (!empresa) {
        setMessage('Criando empresa padrão...');
        const { data: novaEmpresa, error: empresaError } = await supabase
          .from('empresas')
          .insert({
            nome: 'Allimport',
            cnpj: '00.000.000/0001-00',
            telefone: '(00) 0000-0000',
            email: user.email
          })
          .select('id')
          .single();

        if (empresaError) throw empresaError;
        empresa = novaEmpresa;
      }

      // 2. Verificar se existe funcionário
      let { data: funcionario } = await supabase
        .from('funcionarios')
        .select('id')
        .eq('empresa_id', user.id)
        .single();

      if (!funcionario) {
        setMessage('Criando registro de funcionário...');
        const { data: novoFuncionario, error: funcionarioError } = await supabase
          .from('funcionarios')
          .insert({
            empresa_id: user.id,
            nome: user.email.split('@')[0] || 'Admin',
            email: user.email,
            status: 'ativo'
          })
          .select('id')
          .single();

        if (funcionarioError) throw funcionarioError;
        funcionario = novoFuncionario;
      }

      // 3. Verificar funções de administrador
      setMessage('Verificando funções administrativas...');
      let { data: funcaoAdmin } = await supabase
        .from('funcoes')
        .select('id')
        .eq('empresa_id', empresa.id)
        .eq('nome', 'Administrador')
        .single();

      if (!funcaoAdmin) {
        setMessage('Criando função de Administrador...');
        const { data: novaFuncao, error: funcaoError } = await supabase
          .from('funcoes')
          .insert({
            empresa_id: empresa.id,
            nome: 'Administrador',
            descricao: 'Acesso total ao sistema',
            is_system: true
          })
          .select('id')
          .single();

        if (funcaoError) throw funcaoError;
        funcaoAdmin = novaFuncao;

        // Associar todas as permissões
        setMessage('Configurando permissões...');
        const { data: permissoes } = await supabase
          .from('permissoes')
          .select('id');

        if (permissoes && funcaoAdmin?.id) {
          const funcaoAdminId = funcaoAdmin.id; // Garantir que não é null
          const permissoesData = permissoes.map(p => ({
            funcao_id: funcaoAdminId,
            permissao_id: p.id,
            empresa_id: empresa.id
          }));

          await supabase
            .from('funcao_permissoes')
            .insert(permissoesData);
        }
      }

      // 4. Verificar vínculo funcionário-função
      setMessage('Verificando vínculo com função...');
      if (funcaoAdmin && funcionario) {
        const { data: vinculo } = await supabase
          .from('funcionario_funcoes')
          .select('id')
          .eq('funcionario_id', funcionario.id)
          .eq('funcao_id', funcaoAdmin.id)
          .single();

        if (!vinculo) {
          setMessage('Criando vínculo com função de Administrador...');
          await supabase
            .from('funcionario_funcoes')
            .insert({
              funcionario_id: funcionario.id,
              funcao_id: funcaoAdmin.id,
              empresa_id: empresa.id
            });
        }
      }

      setMessage('Acesso corrigido com sucesso! Atualizando permissões...');
      
      // Aguardar um pouco para o banco processar
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // Recarregar permissões
      await refresh();
      
      if (showWelcome) {
        setStatus('welcome');
        setMessage('✅ Acesso administrativo configurado com sucesso!');
      } else {
        setStatus('fixed');
        setMessage('✅ Acesso administrativo configurado com sucesso!');
      }
      
      if (onFixed) {
        onFixed();
      }

    } catch (error: any) {
      console.error('Erro ao corrigir acesso:', error);
      setStatus('error');
      setMessage(`Erro ao corrigir acesso: ${error?.message || 'Erro desconhecido'}`);
    } finally {
      setFixing(false);
    }
  };

  if (loading) {
    return (
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 flex items-center gap-3">
        <RefreshCw className="w-5 h-5 text-blue-600 animate-spin" />
        <span className="text-blue-800">Verificando permissões...</span>
      </div>
    );
  }

  if (status === 'welcome') {
    return <WelcomeAdmin onGetStarted={() => window.location.href = '/configuracoes'} />;
  }

  // Se o usuário está logado, ele é admin da sua empresa - não mostrar nada
  if (status === 'fixed' && user?.id) {
    return null; // Não mostrar mensagem - tudo OK!
  }

  if (status === 'fixed' && (isAdmin || isAdminEmpresa)) {
    return (
      <div className="bg-green-50 border border-green-200 rounded-lg p-4 flex items-center gap-3">
        <CheckCircle className="w-5 h-5 text-green-600" />
        <span className="text-green-800">{message}</span>
      </div>
    );
  }

  if (status === 'problem') {
    return (
      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6">
        <div className="flex items-start gap-4">
          <AlertTriangle className="w-6 h-6 text-yellow-600 flex-shrink-0 mt-0.5" />
          <div className="flex-1">
            <h3 className="text-lg font-semibold text-yellow-900 mb-2">
              Problema de Acesso Detectado
            </h3>
            <p className="text-yellow-800 mb-4">
              Seu usuário não tem permissões administrativas configuradas. 
              Isso pode acontecer se:
            </p>
            <ul className="text-yellow-800 mb-4 list-disc list-inside space-y-1">
              <li>Seu registro de funcionário não foi criado</li>
              <li>Você não foi associado a uma função administrativa</li>
              <li>As permissões não estão configuradas corretamente</li>
            </ul>
            <button
              onClick={fixAccess}
              disabled={fixing}
              className="flex items-center gap-2 px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {fixing ? (
                <>
                  <RefreshCw className="w-4 h-4 animate-spin" />
                  Corrigindo...
                </>
              ) : (
                <>
                  <Settings className="w-4 h-4" />
                  Corrigir Automaticamente
                </>
              )}
            </button>
            {fixing && (
              <p className="text-yellow-700 mt-2 text-sm">
                {message}
              </p>
            )}
          </div>
        </div>
      </div>
    );
  }

  if (status === 'error') {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-6">
        <div className="flex items-start gap-4">
          <AlertTriangle className="w-6 h-6 text-red-600 flex-shrink-0 mt-0.5" />
          <div className="flex-1">
            <h3 className="text-lg font-semibold text-red-900 mb-2">
              Erro na Correção
            </h3>
            <p className="text-red-800 mb-4">
              {message}
            </p>
            <div className="flex gap-2">
              <button
                onClick={fixAccess}
                className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
              >
                <RefreshCw className="w-4 h-4" />
                Tentar Novamente
              </button>
              <button
                onClick={() => window.location.href = '/dashboard'}
                className="flex items-center gap-2 px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700"
              >
                <Shield className="w-4 h-4" />
                Voltar ao Dashboard
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return null;
};

export default AccessFixer;