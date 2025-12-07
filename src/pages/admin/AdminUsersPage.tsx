import { useState, useEffect } from 'react';
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
  RefreshCw,
  Eye,
  EyeOff
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
      console.log('🔄 [AdminUsersPage] Carregando funcionários...');
      
      // Buscar empresa_id do usuário logado
      const { data: userData } = await supabase.auth.getUser();
      if (!userData.user) {
        console.error('❌ Usuário não autenticado');
        return;
      }

      console.log('👤 [AdminUsersPage] Usuário logado:', userData.user.email);

      // ✅ USAR A MESMA ESTRATÉGIA DA ActivateUsersPage - Buscar por EMAIL
      const { data: empresaData, error: empresaError } = await supabase
        .from('empresas')
        .select('id')
        .eq('email', userData.user.email)
        .single();

      if (empresaError) {
        console.error('❌ Erro ao buscar empresa por email:', empresaError);
        
        // Fallback: tentar por user_id
        console.log('⚠️ Tentando fallback com user_id');
        const { data: empresaDataFallback } = await supabase
          .from('empresas')
          .select('id')
          .eq('user_id', userData.user.id)
          .single();
        
        if (empresaDataFallback) {
          console.log('✅ Empresa encontrada via user_id:', empresaDataFallback.id);
          await loadFuncionariosByEmpresa(empresaDataFallback.id);
          return;
        }
        
        // Último fallback: usar o user_id diretamente como empresa_id
        console.log('⚠️ Usando user_id como empresa_id');
        await loadFuncionariosByEmpresa(userData.user.id);
        return;
      }

      if (!empresaData) {
        console.error('❌ Empresa não encontrada para o usuário');
        return;
      }

      const empresaId = empresaData.id;
      console.log('🏢 [AdminUsersPage] Empresa ID:', empresaId);
      
      await loadFuncionariosByEmpresa(empresaId);
    } catch (error) {
      console.error('❌ Erro ao carregar funcionários:', error);
      setFuncionarios([]);
    }
  };

  const loadFuncionariosByEmpresa = async (empresaId: string) => {
    try {
      console.log('🔍 [AdminUsersPage] Buscando funcionários para empresa_id:', empresaId);
      
      // ✅ CORRIGIDO: Especificar o relacionamento correto com hint do Supabase
      // Usar 'funcoes!funcionarios_funcao_id_fkey' para a relação direta via funcao_id
      const { data, error } = await supabase
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
          funcoes:funcoes!funcionarios_funcao_id_fkey (
            id,
            nome,
            descricao,
            nivel
          )
        `)
        .eq('empresa_id', empresaId)
        .order('created_at', { ascending: false });
      
      if (error) {
        console.error('❌ [AdminUsersPage] Erro ao carregar funcionários:', error);
        console.error('❌ [AdminUsersPage] Detalhes do erro:', JSON.stringify(error, null, 2));
        throw error;
      }
      
      console.log('✅ [AdminUsersPage] Funcionários carregados:', data?.length || 0);
      console.log('📋 [AdminUsersPage] Dados completos dos funcionários:', JSON.stringify(data, null, 2));

      if (!data || data.length === 0) {
        console.warn('⚠️ [AdminUsersPage] Nenhum funcionário encontrado para empresa_id:', empresaId);
        console.log('💡 [AdminUsersPage] Verifique se os funcionários têm o mesmo empresa_id no banco');
      }

      const funcionariosWithDetails: FuncionarioWithDetails[] = data?.map(func => {
        console.log('🔄 [AdminUsersPage] Processando funcionário:', func.nome, '- Status:', func.status);
        
        return {
          id: func.id,
          empresa_id: func.empresa_id,
          email: func.email,
          nome: func.nome,
          telefone: func.telefone,
          status: func.status || 'ativo',
          convite_token: func.convite_token,
          convite_expires_at: func.convite_expires_at,
          created_at: func.created_at,
          updated_at: func.updated_at,
          funcoes: (func.funcoes ? [func.funcoes] : []) as unknown as Funcao[],
          convitePendente: func.status === 'pendente' && !!func.convite_token
        };
      }) || [];

      console.log('📊 [AdminUsersPage] Total de funcionários formatados:', funcionariosWithDetails.length);
      console.log('👥 [AdminUsersPage] Lista final:', funcionariosWithDetails.map(f => ({ nome: f.nome, status: f.status, email: f.email })));
      
      setFuncionarios(funcionariosWithDetails);
    } catch (error) {
      console.error('❌ [AdminUsersPage] Erro ao buscar funcionários por empresa:', error);
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
          <div className="text-right">
            <p className="text-sm text-gray-500">
              {filteredFuncionarios.length} de {funcionarios.length} usuário(s)
            </p>
            {funcionarios.length > 0 && filteredFuncionarios.length === 0 && (
              <p className="text-xs text-orange-600">
                Filtros ocultando todos os usuários
              </p>
            )}
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
                    : funcionarios.length > 0
                      ? `Há ${funcionarios.length} funcionário(s) cadastrado(s), mas os filtros estão ocultando todos.`
                      : 'Nenhum funcionário cadastrado. Acesse "Ativar Usuários" no menu para criar novos funcionários com senha local.'
                  }
                </p>
                {!searchTerm && statusFilter === 'todos' && funcionarios.length === 0 && (
                  <div className="mt-4">
                    <button
                      onClick={() => {
                        // Disparar evento para navegar para ativar usuários
                        window.dispatchEvent(new CustomEvent('admin-navigate', { detail: { view: 'ativar-usuarios' } }));
                      }}
                      className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                    >
                      <Users className="w-4 h-4" />
                      Ir para Ativar Usuários
                    </button>
                  </div>
                )}
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
  const [novaSenha, setNovaSenha] = useState('');
  const [mostrarSenha, setMostrarSenha] = useState(false);
  const [alterarSenha, setAlterarSenha] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Validar senha se estiver alterando
    if (alterarSenha) {
      if (!novaSenha || novaSenha.length < 6) {
        alert('A nova senha deve ter pelo menos 6 caracteres');
        return;
      }
    }

    setLoading(true);
    try {
      // Se está alterando senha, atualizar na tabela login_funcionarios
      if (alterarSenha && novaSenha) {
        console.log('🔑 Atualizando senha do funcionário:', user.id);
        
        // Chamar RPC para atualizar senha com bcrypt
        // ⚠️ Esta função também define precisa_trocar_senha = TRUE automaticamente
        const { error: senhaError } = await supabase.rpc('atualizar_senha_funcionario', {
          p_funcionario_id: user.id,
          p_nova_senha: novaSenha
        });

        if (senhaError) {
          console.error('❌ Erro ao atualizar senha:', senhaError);
          alert('Erro ao atualizar senha: ' + senhaError.message);
          setLoading(false);
          return;
        }

        console.log('✅ Senha atualizada com sucesso! (precisa_trocar_senha = TRUE)');
      }

      await onSave(user.id, {
        nome: nome || undefined,
        telefone: telefone || undefined,
        status: status as 'ativo' | 'pendente' | 'bloqueado'
      }, selectedFuncoes);

      if (alterarSenha) {
        alert('✅ Senha temporária definida! O funcionário deverá trocar a senha no próximo login.');
      }
    } catch (error) {
      console.error('Erro ao atualizar usuário:', error);
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

          {/* Nova seção para alterar senha */}
          <div className="border-t border-gray-200 pt-4">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={alterarSenha}
                onChange={(e) => {
                  setAlterarSenha(e.target.checked);
                  if (!e.target.checked) {
                    setNovaSenha('');
                  }
                }}
                className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span className="text-sm font-medium text-gray-700">
                Definir nova senha temporária
              </span>
            </label>

            {alterarSenha && (
              <div className="mt-3">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Nova Senha Temporária
                </label>
                <div className="relative">
                  <input
                    type={mostrarSenha ? 'text' : 'password'}
                    value={novaSenha}
                    onChange={(e) => setNovaSenha(e.target.value)}
                    placeholder="Digite a nova senha (mín. 6 caracteres)"
                    className="w-full px-3 py-2 pr-10 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    minLength={6}
                  />
                  <button
                    type="button"
                    onClick={() => setMostrarSenha(!mostrarSenha)}
                    className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  >
                    {mostrarSenha ? (
                      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                      </svg>
                    ) : (
                      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
                      </svg>
                    )}
                  </button>
                </div>
                <div className="mt-2 p-3 bg-amber-50 border border-amber-200 rounded-lg">
                  <p className="text-xs text-amber-800 flex items-start gap-2">
                    <svg className="w-4 h-4 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                    </svg>
                    <span>
                      <strong>Senha Temporária:</strong> O funcionário será <strong>obrigado a trocar a senha</strong> no próximo login por uma senha pessoal e segura.
                    </span>
                  </p>
                </div>
              </div>
            )}
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