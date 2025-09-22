import React, { useState, useEffect } from 'react';
import { 
  Users, 
  UserPlus, 
  Search, 
  Filter, 
  Clock,
  CheckCircle,
  XCircle,
  AlertTriangle,
  Edit3,
  Trash2,
  Send,
  RefreshCw
} from 'lucide-react';
import { usePermissions } from '../../hooks/usePermissions';
import { supabase } from '../../lib/supabase';
import AccessFixer from '../../components/AccessFixer';
import InviteUserFullPage from '../../components/admin/InviteUserFullPage';
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
  const [currentView, setCurrentView] = useState<'list' | 'invite'>('list');

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
      
      let query = supabase
        .from('funcionarios')
        .select(`
          id,
          empresa_id,
          email,
          nome,
          telefone,
          status,
          convite_token,
          convite_expires_at,
          created_at,
          updated_at,
          funcionario_funcoes (
            funcoes (
              id,
              nome,
              descricao,
              nivel
            )
          )
        `);

      // Admin da empresa só vê funcionários da sua empresa (não super admins)
      if (isAdminEmpresa) {
        const { data: user } = await supabase.auth.getUser();
        if (user.user) {
          query = query.eq('empresa_id', user.user.id);
        }
      }

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
        funcoes: func.funcionario_funcoes?.map((ff: any) => ff.funcoes) || [],
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

  const handleInviteUser = async (userData: { email: string; nome?: string; telefone?: string; funcaoIds: string[] }) => {
    if (!can('administracao.usuarios', 'create') && !isAdminEmpresa) return;

    try {
      console.log('🚀 Iniciando criação de convite para:', userData);
      
      // Gerar token de convite
      const inviteToken = crypto.randomUUID();
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 7); // Expira em 7 dias

      console.log('🔑 Token gerado:', inviteToken);
      console.log('⏰ Expira em:', expiresAt);

      const { data: user } = await supabase.auth.getUser();
      if (!user.user) throw new Error('Usuário não autenticado');

      console.log('👤 Empresa ID:', user.user.id);

      // Criar funcionário
      const { data: funcionario, error } = await supabase
        .from('funcionarios')
        .insert({
          empresa_id: user.user.id,
          email: userData.email,
          nome: userData.nome || null,
          telefone: userData.telefone || null,
          status: 'pendente',
          convite_token: inviteToken,
          convite_expires_at: expiresAt.toISOString()
        })
        .select()
        .single();

      if (error) {
        console.error('❌ Erro ao criar funcionário:', error);
        
        // Tratamento específico para diferentes tipos de erro
        if (error.code === '23505' || error.message?.includes('duplicate') || error.message?.includes('unique')) {
          console.error('💥 Email já existe no sistema');
          alert('Este email já está cadastrado no sistema. Use um email diferente.');
          return;
        }
        
        if (error.code === 'PGRST204' || error.message?.includes('column')) {
          console.error('💥 Problema de schema - coluna ausente');
          alert('Erro de configuração do banco de dados. Contate o suporte técnico.');
          return;
        }
        
        throw error;
      }

      console.log('✅ Funcionário criado:', funcionario);

      // Associar funções
      if (userData.funcaoIds.length > 0) {
        console.log('🔗 Associando funções:', userData.funcaoIds);
        
        const funcionarioFuncoes = userData.funcaoIds.map((funcaoId: string) => ({
          funcionario_id: funcionario.id,
          funcao_id: funcaoId,
          empresa_id: user.user.id
        }));

        const { error: funcaoError } = await supabase
          .from('funcionario_funcoes')
          .insert(funcionarioFuncoes);
          
        if (funcaoError) {
          console.error('❌ Erro ao associar funções:', funcaoError);
          throw funcaoError;
        }
        
        console.log('✅ Funções associadas com sucesso');
      }

      // Enviar e-mail de convite (implementar depois)
      console.log('📧 Enviando convite por email...');
      await sendInviteEmail(userData.email, inviteToken);

      // Recarregar dados
      console.log('🔄 Recarregando lista de funcionários...');
      await loadFuncionarios();
      setCurrentView('list');

      console.log('🎉 Convite criado com sucesso!');

      // Log de auditoria (comentado - tabela não existe no upgrade minimalista)
      // await supabase.from('audit_logs').insert({
      //   recurso: 'administracao.usuarios',
      //   acao: 'create',
      //   entidade_tipo: 'funcionario',
      //   entidade_id: funcionario.id,
      //   detalhes: { userData }
      // });

    } catch (error: any) {
      console.error('Erro ao convidar usuário:', error);
      
      // Mensagens de erro mais específicas
      if (error?.code === '23505' || error?.message?.includes('duplicate')) {
        alert('❌ Este email já está cadastrado no sistema.');
      } else if (error?.code === 'PGRST204' || error?.message?.includes('column')) {
        alert('❌ Erro de configuração do banco de dados. Execute o script de correção do schema.');
      } else if (error?.code === '42P01' || error?.message?.includes('does not exist')) {
        alert('❌ Tabela não encontrada. Verifique a configuração do banco de dados.');
      } else {
        alert('❌ Erro ao enviar convite. Verifique os dados e tente novamente.');
      }
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

    if (confirm('Tem certeza que deseja excluir este usuário? Esta ação não pode ser desfeita.')) {
      try {
        const { error } = await supabase
          .from('funcionarios')
          .delete()
          .eq('id', userId);

        if (error) throw error;

        await loadFuncionarios();

        // Log de auditoria (comentado - tabela não existe no upgrade minimalista)
        // await supabase.from('audit_logs').insert({
        //   recurso: 'administracao.usuarios',
        //   acao: 'delete',
        //   entidade_tipo: 'funcionario',
        //   entidade_id: userId
        // });

      } catch (error) {
        console.error('Erro ao excluir usuário:', error);
        alert('Erro ao excluir usuário. Tente novamente.');
      }
    }
  };

  const handleResendInvite = async (userId: string, email: string) => {
    if (!can('administracao.usuarios', 'update') && !isAdminEmpresa) return;

    try {
      // Gerar novo token
      const newToken = crypto.randomUUID();
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 7);

      await supabase
        .from('funcionarios')
        .update({
          convite_token: newToken,
          convite_expires_at: expiresAt.toISOString()
        })
        .eq('id', userId);

      await sendInviteEmail(email, newToken);
      await loadFuncionarios();

    } catch (error) {
      console.error('Erro ao reenviar convite:', error);
      alert('Erro ao reenviar convite. Tente novamente.');
    }
  };

  const sendInviteEmail = async (email: string, token: string) => {
    // TODO: Implementar envio de email real
    const inviteLink = `${window.location.origin}/convite/${token}`;
    console.log(`Convite enviado para ${email}: ${inviteLink}`);
    
    // Para teste, mostramos o link em um alert
    alert(`Convite criado com sucesso!\n\nEmail: ${email}\nLink de convite: ${inviteLink}\n\n(Em produção, este link seria enviado por email)`);
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
      {currentView === 'list' ? (
        <>
          {/* Header */}
          <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Gerenciar Usuários</h1>
          <p className="text-gray-600">
            Controle os funcionários e suas permissões no sistema
          </p>
        </div>
        
        {(can('administracao.usuarios', 'create') || isAdminEmpresa) && (
          <div className="flex items-center gap-3">
            <div className="text-right hidden sm:block">
              <p className="text-sm text-gray-500">
                {funcionarios.length} usuário(s) cadastrado(s)
              </p>
            </div>
            <button
              onClick={() => setCurrentView('invite')}
              className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-xl hover:from-blue-700 hover:to-blue-800 transform hover:scale-105 transition-all duration-200 shadow-lg hover:shadow-xl"
            >
              <UserPlus className="w-5 h-5" />
              <span className="font-medium">Convidar Usuário</span>
            </button>
          </div>
        )}
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
                        {funcionario.convitePendente && (can('administracao.usuarios', 'update') || isAdminEmpresa) && (
                          <button
                            onClick={() => handleResendInvite(funcionario.id, funcionario.email)}
                            className="p-1 text-blue-600 hover:text-blue-800 transition-colors"
                            title="Reenviar convite"
                          >
                            <Send className="w-4 h-4" />
                          </button>
                        )}
                        
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
                    : 'Comece adicionando funcionários à sua empresa. Eles receberão um convite por e-mail para acessar o sistema.'
                  }
                </p>
                {(!searchTerm && statusFilter === 'todos') && (can('administracao.usuarios', 'create') || isAdminEmpresa) && (
                  <button
                    onClick={() => setCurrentView('invite')}
                    className="inline-flex items-center gap-2 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
                  >
                    <UserPlus className="w-5 h-5" />
                    Convidar Primeiro Usuário
                  </button>
                )}
              </div>
            )}
          </div>
        </div>
      )}
        </>
      ) : (
        /* View de Convite - Página completa */
        <InviteUserFullPage 
          funcoes={funcoes}
          onInvite={handleInviteUser}
          onBack={() => setCurrentView('list')}
        />
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