import React, { useState, useEffect } from 'react';
import { 
  Users, 
  Search, 
  Filter, 
  Clock,
  CheckCircle,
  XCircle,
  AlertTriangle,
  Edit3,
  Trash2,
  RefreshCw
} from 'lucide-react';
import { usePermissions } from '../../hooks/usePermissions';
import { supabase } from '../../lib/supabase';
import AccessFixer from '../../components/AccessFixer';
import { DeleteUserModal } from '../../components/admin/DeleteUserModal';
import type { Funcionario, Funcao } from '../../types/admin';

interface FuncionarioWithDetails {
  id: string;
  empresa_id: string;
  email: string;
  nome?: string;
  telefone?: string;
  status: 'ativo' | 'inativo' | 'pendente';
  convite_token?: string;
  convite_expires_at?: string;
  created_at: string;
  updated_at?: string;
  funcoes: Funcao[];
  convitePendente: boolean;
}

const AdminUsersPage: React.FC = () => {
  const { can, isAdmin, isAdminEmpresa } = usePermissions();
  const [funcionarios, setFuncionarios] = useState<FuncionarioWithDetails[]>([]);
  const [funcoes, setFuncoes] = useState<Funcao[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'todos' | 'ativo' | 'inativo' | 'pendente'>('todos');
  const [selectedUser, setSelectedUser] = useState<FuncionarioWithDetails | null>(null);
  const [showEditModal, setShowEditModal] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [userToDelete, setUserToDelete] = useState<FuncionarioWithDetails | null>(null);
  const [currentView, setCurrentView] = useState<'list'>('list');

  useEffect(() => {
    if (can('administracao.usuarios', 'read')) {
      loadData();
    }
  }, []);

  const loadData = async () => {
    setLoading(true);
    try {
      await Promise.all([
        loadFuncionarios(),
        loadFuncoes()
      ]);
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadFuncionarios = async () => {
    try {
      console.log('🔄 Carregando funcionários...');
      
      // Buscar empresa_id do usuário logado
      const { data: userData } = await supabase.auth.getUser();
      if (!userData.user) {
        console.error('❌ Usuário não autenticado');
        return;
      }

      const { data: empresaData } = await supabase
        .from('empresas')
        .select('id')
        .eq('user_id', userData.user.id)
        .single();

      if (!empresaData) {
        console.error('❌ Empresa não encontrada para o usuário');
        return;
      }

      const empresaId = empresaData.id;
      console.log('🏢 Empresa ID:', empresaId);
      
      // Buscar APENAS funcionários da empresa do usuário logado
      let query = supabase
        .from('funcionarios')
        .select(`
          id,
          empresa_id,
          user_id,
          funcao_id,
          email,
          nome,
          telefone,
          ativo,
          status,
          convite_token,
          convite_expires_at,
          created_at,
          updated_at,
          funcoes (
            id,
            nome,
            descricao,
            nivel
          )
        `)
        .eq('empresa_id', empresaId);

      const { data, error } = await query.order('created_at', { ascending: false });
      
      if (error) {
        console.error('❌ Erro ao carregar funcionários:', error);
        throw error;
      }
      
      console.log('✅ Funcionários carregados:', data);

      const funcionariosWithDetails: FuncionarioWithDetails[] = data?.map(func => ({
        id: func.id,
        empresa_id: func.empresa_id,
        email: func.email,
        nome: func.nome,
        telefone: func.telefone,
        status: func.status || 'pendente',
        convite_token: func.convite_token,
        convite_expires_at: func.convite_expires_at,
        created_at: func.created_at,
        updated_at: func.updated_at,
        funcoes: (func.funcoes ? [func.funcoes] : []) as unknown as Funcao[],
        convitePendente: func.status === 'pendente' && !!func.convite_token
      })) || [];

      setFuncionarios(funcionariosWithDetails);
    } catch (error) {
      console.error('❌ Erro ao carregar funcionários:', error);
      setFuncionarios([]);
    }
  };

  const loadFuncoes = async () => {
    try {
      console.log('🔄 Carregando funções...');
      
      // Obter o usuário atual
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        console.error('❌ Usuário não autenticado');
        return;
      }
      
      console.log('👤 Usuário atual:', user.id);
      
      // Tentar carregar funções existentes filtradas por empresa_id
      const { data, error } = await supabase
        .from('funcoes')
        .select('*')
        .eq('empresa_id', user.id)
        .order('nome', { ascending: true });

      if (error) {
        console.error('❌ Erro ao carregar funções:', error);
        throw error;
      }

      console.log('📋 Funções encontradas:', data?.length || 0, data);

      if (data && data.length > 0) {
        setFuncoes(data);
        console.log('✅ Funções carregadas com sucesso');
      } else {
        console.log('⚠️ Nenhuma função encontrada, criando funções padrão...');
        // Se não há funções, criar funções padrão
        await createDefaultFuncoes();
      }
    } catch (error) {
      console.error('❌ Erro ao carregar funções:', error);
      console.log('🔧 Usando funções de fallback...');
      // Criar funções básicas como fallback
      setFuncoes([
        { id: 'admin', nome: 'Administrador', descricao: 'Acesso completo ao sistema' },
        { id: 'vendedor', nome: 'Vendedor', descricao: 'Acesso a vendas e clientes' },
        { id: 'caixa', nome: 'Caixa', descricao: 'Acesso ao caixa' }
      ] as any);
    }
  };

  const createDefaultFuncoes = async () => {
    try {
      console.log('🏗️ Criando funções padrão...');
      
      const { data: user } = await supabase.auth.getUser();
      if (!user.user) {
        console.error('❌ Usuário não autenticado para criar funções');
        return;
      }

      console.log('👤 Criando funções para empresa:', user.user.id);

      const defaultFuncoes = [
        { empresa_id: user.user.id, nome: 'Administrador', descricao: 'Acesso completo ao sistema' },
        { empresa_id: user.user.id, nome: 'Gerente', descricao: 'Acesso gerencial' },
        { empresa_id: user.user.id, nome: 'Vendedor', descricao: 'Acesso a vendas e clientes' },
        { empresa_id: user.user.id, nome: 'Caixa', descricao: 'Acesso ao caixa' },
        { empresa_id: user.user.id, nome: 'Funcionário', descricao: 'Acesso básico' }
      ];

      const { data, error } = await supabase
        .from('funcoes')
        .insert(defaultFuncoes)
        .select();

      if (error) {
        console.error('❌ Erro ao inserir funções padrão:', error);
        throw error;
      }
      
      console.log('✅ Funções padrão criadas:', data?.length || 0, data);
      setFuncoes(data || []);
    } catch (error) {
      console.error('❌ Erro ao criar funções padrão:', error);
      console.log('🔧 Usando funções temporárias...');
      // Fallback para funções temporárias
      setFuncoes([
        { id: 'temp-admin', nome: 'Administrador', descricao: 'Acesso completo' },
        { id: 'temp-vendedor', nome: 'Vendedor', descricao: 'Vendas' },
        { id: 'temp-funcionario', nome: 'Funcionário', descricao: 'Básico' }
      ] as any);
    }
  };

  const handleEditUser = async (userId: string, data: Partial<Funcionario>, newFuncaoIds: string[]) => {
    if (!can('administracao.usuarios', 'update') && !isAdminEmpresa) return;

    try {
      // Atualizar dados do funcionário
      const { error: updateError } = await supabase
        .from('funcionarios')
        .update(data)
        .eq('id', userId);

      if (updateError) throw updateError;

      // Atualizar funções
      await supabase
        .from('funcionario_funcoes')
        .delete()
        .eq('funcionario_id', userId);

      if (newFuncaoIds.length > 0) {
        const funcionarioFuncoes = newFuncaoIds.map(funcaoId => ({
          funcionario_id: userId,
          funcao_id: funcaoId
        }));

        await supabase
          .from('funcionario_funcoes')
          .insert(funcionarioFuncoes);
      }

      // Recarregar dados
      await loadFuncionarios();
      setShowEditModal(false);
      setSelectedUser(null);

      // Log de auditoria (comentado - tabela não existe no upgrade minimalista)
      // await supabase.from('audit_logs').insert({
      //   recurso: 'administracao.usuarios',
      //   acao: 'update',
      //   entidade_tipo: 'funcionario',
      //   entidade_id: userId,
      //   detalhes: { ...data, funcoes: newFuncaoIds }
      // });

    } catch (error) {
      console.error('Erro ao editar usuário:', error);
      alert('Erro ao editar usuário. Tente novamente.');
    }
  };

  const handleDeleteUser = async (userId: string) => {
    if (!can('administracao.usuarios', 'delete') && !isAdminEmpresa) return;

    const user = funcionarios.find(f => f.id === userId);
    if (!user) return;

    setUserToDelete(user);
    setShowDeleteModal(true);
  };

  const executeDeleteUser = async () => {
    if (!userToDelete) return;

    try {
      console.log('🗑️ [DELETE] Iniciando exclusão do usuário:', userToDelete.email);

      // 1. Buscar o user_id do auth associado ao funcionário
      const { data: authData } = await supabase.auth.admin.listUsers();
      const authUser = authData?.users?.find(u => u.email === userToDelete.email);
      
      console.log('🔍 [DELETE] AuthUser encontrado:', authUser?.id);

      // 2. Deletar dados relacionados ao usuário
      const userId = userToDelete.id;

      // Deletar produtos do usuário
      console.log('🗑️ [DELETE] Deletando produtos...');
      const { error: produtosError } = await supabase.from('produtos').delete().eq('user_id', userId);
      if (produtosError) console.warn('⚠️ Erro ao deletar produtos:', produtosError.message);

      // Deletar clientes do usuário
      console.log('🗑️ [DELETE] Deletando clientes...');
      const { error: clientesError } = await supabase.from('clientes').delete().eq('user_id', userId);
      if (clientesError) console.warn('⚠️ Erro ao deletar clientes:', clientesError.message);

      // Deletar vendas do usuário
      console.log('🗑️ [DELETE] Deletando vendas...');
      const { error: vendasError } = await supabase.from('vendas').delete().eq('user_id', userId);
      if (vendasError) console.warn('⚠️ Erro ao deletar vendas:', vendasError.message);

      // Deletar ordens de serviço do usuário
      console.log('🗑️ [DELETE] Deletando ordens de serviço...');
      const { error: ordensError } = await supabase.from('ordens_servico').delete().eq('user_id', userId);
      if (ordensError) console.warn('⚠️ Erro ao deletar ordens:', ordensError.message);

      // Tentar deletar caixas (pode não existir a tabela)
      console.log('🗑️ [DELETE] Deletando caixas (se existir)...');
      const { error: caixasError } = await supabase.from('caixas').delete().eq('user_id', userId);
      if (caixasError && !caixasError.message.includes('not found')) {
        console.warn('⚠️ Erro ao deletar caixas:', caixasError.message);
      }

      // 3. Deletar o funcionário
      console.log('🗑️ [DELETE] Deletando registro de funcionário...');
      const { error: funcError } = await supabase
        .from('funcionarios')
        .delete()
        .eq('id', userId);

      if (funcError) throw funcError;

      // 4. Tentar deletar conta de autenticação via RPC
      if (authUser?.id) {
        console.log('🗑️ [DELETE] Tentando deletar conta de autenticação via RPC...');
        
        const { data: rpcResult, error: rpcError } = await supabase.rpc('admin_delete_user', { 
          user_email: userToDelete.email 
        });

        if (rpcError) {
          console.warn('⚠️ [DELETE] Erro RPC:', rpcError.message);
          
          // Se o erro for "function not found", significa que a RPC não foi criada ainda
          if (rpcError.message.includes('function') && rpcError.message.includes('does not exist')) {
            console.warn('⚠️ [DELETE] Função RPC admin_delete_user não encontrada no banco.');
            console.warn('💡 [DELETE] Execute o script DELETAR_USUARIO_AUTH_PERMANENTE.sql no Supabase SQL Editor');
            
            alert(
              `✅ Funcionário excluído com sucesso!\n\n` +
              `⚠️ ATENÇÃO: A conta de autenticação não foi removida.\n\n` +
              `Para habilitar exclusão automática:\n` +
              `1. Abra o Supabase SQL Editor\n` +
              `2. Execute o arquivo: DELETAR_USUARIO_AUTH_PERMANENTE.sql\n` +
              `3. Isso criará a função admin_delete_user()\n\n` +
              `OU execute manualmente:\n` +
              `DELETE FROM auth.users WHERE email = '${userToDelete.email}';`
            );
          } else {
            // Outro tipo de erro RPC
            alert(
              `✅ Funcionário excluído!\n\n` +
              `⚠️ Erro ao deletar autenticação: ${rpcError.message}\n\n` +
              `Execute manualmente:\n` +
              `DELETE FROM auth.users WHERE email = '${userToDelete.email}';`
            );
          }
        } else {
          // RPC executou com sucesso
          const result = rpcResult as { success: boolean; message?: string; error?: string };
          
          if (result.success) {
            console.log('✅ [DELETE] Conta de autenticação deletada via RPC:', result);
            alert(
              `✅ Usuário excluído completamente!\n\n` +
              `• Funcionário: Removido\n` +
              `• Dados: Removidos\n` +
              `• Autenticação: Removida\n\n` +
              `${result.message || 'Exclusão bem-sucedida!'}`
            );
          } else {
            console.warn('⚠️ [DELETE] RPC retornou falha:', result.error);
            alert(
              `✅ Funcionário excluído!\n\n` +
              `⚠️ Erro RPC: ${result.error}\n\n` +
              `Execute manualmente:\n` +
              `DELETE FROM auth.users WHERE email = '${userToDelete.email}';`
            );
          }
        }
      }

      await loadFuncionarios();
      setUserToDelete(null);

      console.log('✅ [DELETE] Processo de exclusão concluído!');

    } catch (error) {
      console.error('❌ [DELETE] Erro ao excluir usuário:', error);
      alert('Erro ao excluir usuário. Verifique o console para mais detalhes.');
      throw error;
    }
  };

  const filteredFuncionarios = funcionarios.filter(func => {
    const matchesSearch = func.nome?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         func.email.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesStatus = statusFilter === 'todos' || func.status === statusFilter;
    
    return matchesSearch && matchesStatus;
  });

  const getStatusIcon = (status: string, convitePendente: boolean) => {
    if (convitePendente) {
      return <Clock className="w-4 h-4 text-yellow-600" />;
    }
    
    switch (status) {
      case 'ativo': return <CheckCircle className="w-4 h-4 text-green-600" />;
      case 'inativo': return <XCircle className="w-4 h-4 text-red-600" />;
      case 'pendente': return <AlertTriangle className="w-4 h-4 text-yellow-600" />;
      default: return <AlertTriangle className="w-4 h-4 text-gray-600" />;
    }
  };

  const getStatusText = (status: string, convitePendente: boolean) => {
    if (convitePendente) return 'Convite Pendente';
    
    switch (status) {
      case 'ativo': return 'Ativo';
      case 'inativo': return 'Inativo';
      case 'pendente': return 'Pendente';
      default: return status;
    }
  };

  const getStatusColor = (status: string, convitePendente: boolean) => {
    if (convitePendente) return 'bg-yellow-100 text-yellow-800';
    
    switch (status) {
      case 'ativo': return 'bg-green-100 text-green-800';
      case 'inativo': return 'bg-red-100 text-red-800';
      case 'pendente': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  // Verificar se tem acesso a área de usuários
  if (!can('administracao.usuarios', 'read') && !isAdmin && !isAdminEmpresa) {
    return (
      <div className="p-6">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Gerenciamento de Usuários</h1>
          <p className="text-gray-600">
            Esta área é restrita para administradores da empresa.
          </p>
        </div>
        <AccessFixer onFixed={() => window.location.reload()} />
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Gerenciar Usuários</h1>
          <p className="text-gray-600">
            Controle os funcionários e suas permissões no sistema
          </p>
        </div>
        
        <div className="flex items-center gap-3">
          <div className="text-right hidden sm:block">
            <p className="text-sm text-gray-500">
              {funcionarios.length} usuário(s) cadastrado(s)
            </p>
          </div>
        </div>
      </div>

      {/* Filtros */}
      <div className="bg-white rounded-lg border border-gray-200 p-4">
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="flex-1">
            <div className="relative">
              <Search className="w-4 h-4 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Buscar por nome ou email..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          </div>
          
          <div className="flex items-center gap-2">
            <Filter className="w-4 h-4 text-gray-400" />
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value as any)}
              className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="todos">Todos os Status</option>
              <option value="ativo">Ativo</option>
              <option value="inativo">Inativo</option>
              <option value="pendente">Pendente</option>
            </select>
          </div>

          <button
            onClick={loadData}
            className="flex items-center gap-2 px-3 py-2 text-gray-600 hover:text-gray-800 transition-colors"
          >
            <RefreshCw className="w-4 h-4" />
            Atualizar
          </button>
        </div>
      </div>

      {/* Lista de Usuários */}
      {loading ? (
        <div className="bg-white rounded-lg border border-gray-200 p-8">
          <div className="animate-pulse space-y-4">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="flex items-center space-x-4">
                <div className="w-10 h-10 bg-gray-200 rounded-full"></div>
                <div className="flex-1 space-y-2">
                  <div className="h-4 bg-gray-200 rounded w-1/4"></div>
                  <div className="h-3 bg-gray-200 rounded w-1/3"></div>
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : (
        <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Usuário
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Funções
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Último Login
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ações
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredFuncionarios.map((funcionario) => (
                  <tr key={funcionario.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div className="flex items-center">
                        <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                          <Users className="w-5 h-5 text-gray-500" />
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {funcionario.nome || 'Nome não definido'}
                          </div>
                          <div className="text-sm text-gray-500">
                            {funcionario.email}
                          </div>
                        </div>
                      </div>
                    </td>
                    
                    <td className="px-6 py-4">
                      <div className="flex flex-wrap gap-1">
                        {funcionario.funcoes.map((funcao) => (
                          <span
                            key={funcao.id}
                            className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
                          >
                            {funcao.nome}
                          </span>
                        ))}
                        {funcionario.funcoes.length === 0 && (
                          <span className="text-sm text-gray-500">Nenhuma função</span>
                        )}
                      </div>
                    </td>
                    
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        {getStatusIcon(funcionario.status, funcionario.convitePendente)}
                        <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(funcionario.status, funcionario.convitePendente)}`}>
                          {getStatusText(funcionario.status, funcionario.convitePendente)}
                        </span>
                      </div>
                    </td>
                    
                    <td className="px-6 py-4 text-sm text-gray-500">
                      {funcionario.created_at 
                        ? new Date(funcionario.created_at).toLocaleDateString('pt-BR')
                        : 'Nunca'
                      }
                    </td>
                    
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        {(can('administracao.usuarios', 'update') || isAdminEmpresa) && (
                          <button
                            onClick={() => {
                              setSelectedUser(funcionario);
                              setShowEditModal(true);
                            }}
                            className="p-1 text-gray-600 hover:text-gray-800 transition-colors"
                            title="Editar usuário"
                          >
                            <Edit3 className="w-4 h-4" />
                          </button>
                        )}
                        
                        {(can('administracao.usuarios', 'delete') || isAdminEmpresa) && (
                          <button
                            onClick={() => handleDeleteUser(funcionario.id)}
                            className="p-1 text-red-600 hover:text-red-800 transition-colors"
                            title="Excluir usuário"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            
            {filteredFuncionarios.length === 0 && (
              <div className="text-center py-16">
                <div className="bg-gray-50 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-6">
                  <Users className="w-10 h-10 text-gray-400" />
                </div>
                <h3 className="text-xl font-semibold text-gray-900 mb-3">
                  {searchTerm || statusFilter !== 'todos'
                    ? 'Nenhum usuário encontrado'
                    : 'Sua equipe ainda está vazia'
                  }
                </h3>
                <p className="text-gray-500 mb-6 max-w-md mx-auto">
                  {searchTerm || statusFilter !== 'todos'
                    ? 'Tente ajustar os filtros de busca ou remover termos específicos para ver mais resultados.'
                    : 'Nenhum funcionário encontrado. Entre em contato com o administrador do sistema para adicionar usuários.'
                  }
                </p>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Modal de edição (permanece como modal) */}
      {showEditModal && selectedUser && (
        <EditUserModal
          user={selectedUser}
          funcoes={funcoes}
          onSave={handleEditUser}
          onClose={() => {
            setShowEditModal(false);
            setSelectedUser(null);
          }}
        />
      )}

      {/* Modal de Exclusão com Tripla Confirmação */}
      {showDeleteModal && userToDelete && (
        <DeleteUserModal
          isOpen={showDeleteModal}
          onClose={() => {
            setShowDeleteModal(false);
            setUserToDelete(null);
          }}
          onConfirm={executeDeleteUser}
          userName={userToDelete.nome || 'Usuário sem nome'}
          userEmail={userToDelete.email}
        />
      )}
    </div>
  );
};

// Página completa de Convite de Usuário
// Modal de Edição de Usuário
interface EditUserModalProps {
  user: FuncionarioWithDetails;
  funcoes: Funcao[];
  onSave: (userId: string, data: Partial<Funcionario>, funcaoIds: string[]) => Promise<void>;
  onClose: () => void;
}

const EditUserModal: React.FC<EditUserModalProps> = ({ user, funcoes, onSave, onClose }) => {
  const [nome, setNome] = useState(user.nome || '');
  const [telefone, setTelefone] = useState(user.telefone || '');
  const [status, setStatus] = useState(user.status);
  const [selectedFuncoes, setSelectedFuncoes] = useState<string[]>(
    user.funcoes.map(f => f.id)
  );
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    setLoading(true);
    try {
      await onSave(user.id, {
        nome: nome || undefined,
        telefone: telefone || undefined,
        status: status as 'ativo' | 'pendente' | 'bloqueado'
      }, selectedFuncoes);
    } catch (error) {
      // Erro já tratado no componente pai
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl p-6 w-full max-w-md">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">
          Editar Usuário
        </h3>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Nome
            </label>
            <input
              type="text"
              value={nome}
              onChange={(e) => setNome(e.target.value)}
              placeholder="Nome completo"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              E-mail
            </label>
            <input
              type="email"
              value={user.email}
              disabled
              className="w-full px-3 py-2 border border-gray-300 rounded-lg bg-gray-100 text-gray-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Telefone
            </label>
            <input
              type="tel"
              value={telefone}
              onChange={(e) => setTelefone(e.target.value)}
              placeholder="(11) 99999-9999"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Status
            </label>
            <select
              value={status}
              onChange={(e) => setStatus(e.target.value as any)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="ativo">Ativo</option>
              <option value="inativo">Inativo</option>
              <option value="pendente">Pendente</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Funções
            </label>
            <div className="space-y-2 max-h-40 overflow-y-auto">
              {funcoes.map((funcao) => (
                <label key={funcao.id} className="flex items-center">
                  <input
                    type="checkbox"
                    checked={selectedFuncoes.includes(funcao.id)}
                    onChange={(e) => {
                      if (e.target.checked) {
                        setSelectedFuncoes([...selectedFuncoes, funcao.id]);
                      } else {
                        setSelectedFuncoes(selectedFuncoes.filter(id => id !== funcao.id));
                      }
                    }}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                  <span className="ml-2 text-sm text-gray-700">
                    {funcao.nome}
                  </span>
                </label>
              ))}
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-gray-600 hover:text-gray-800 transition-colors"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={loading}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? (
                <RefreshCw className="w-4 h-4 animate-spin" />
              ) : (
                <Edit3 className="w-4 h-4" />
              )}
              Salvar Alterações
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default AdminUsersPage;