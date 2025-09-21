import React, { useState, useEffect } from 'react';
import { 
  Users, 
  UserPlus, 
  Search, 
  Filter, 
  Mail,
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
import type { Funcionario, Funcao } from '../../types/admin';

interface FuncionarioWithDetails extends Funcionario {
  funcoes: Funcao[];
  ultimoLogin?: string;
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
  const [showInviteModal, setShowInviteModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);

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
    let query = supabase
      .from('funcionarios')
      .select(`
        *,
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
      query = query.neq('tipo_admin', 'super_admin');
    }

    const { data } = await query.order('created_at', { ascending: false });

    const funcionariosWithDetails: FuncionarioWithDetails[] = data?.map(func => ({
      ...func,
      funcoes: func.funcionario_funcoes?.map((ff: any) => ff.funcoes) || [],
      convitePendente: func.status === 'pendente' && !!func.convite_token
    })) || [];

    setFuncionarios(funcionariosWithDetails);
  };

  const loadFuncoes = async () => {
    const { data } = await supabase
      .from('funcoes')
      .select('*')
      .order('nivel', { ascending: false });

    setFuncoes(data || []);
  };

  const handleInviteUser = async (email: string, funcaoIds: string[]) => {
    if (!can('administracao.usuarios', 'create') && !isAdminEmpresa) return;

    try {
      // Gerar token de convite
      const inviteToken = crypto.randomUUID();
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 7); // Expira em 7 dias

      // Criar funcionário
      const { data: funcionario, error } = await supabase
        .from('funcionarios')
        .insert({
          email,
          status: 'pendente',
          convite_token: inviteToken,
          convite_expires_at: expiresAt.toISOString()
        })
        .select()
        .single();

      if (error) throw error;

      // Associar funções
      if (funcaoIds.length > 0) {
        const funcionarioFuncoes = funcaoIds.map(funcaoId => ({
          funcionario_id: funcionario.id,
          funcao_id: funcaoId
        }));

        await supabase
          .from('funcionario_funcoes')
          .insert(funcionarioFuncoes);
      }

      // Enviar e-mail de convite (implementar depois)
      await sendInviteEmail(email, inviteToken);

      // Recarregar dados
      await loadFuncionarios();
      setShowInviteModal(false);

      // Log de auditoria
      await supabase.from('audit_logs').insert({
        recurso: 'administracao.usuarios',
        acao: 'create',
        entidade_tipo: 'funcionario',
        entidade_id: funcionario.id,
        detalhes: { email, funcoes: funcaoIds }
      });

    } catch (error) {
      console.error('Erro ao convidar usuário:', error);
      alert('Erro ao enviar convite. Tente novamente.');
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

      // Log de auditoria
      await supabase.from('audit_logs').insert({
        recurso: 'administracao.usuarios',
        acao: 'update',
        entidade_tipo: 'funcionario',
        entidade_id: userId,
        detalhes: { ...data, funcoes: newFuncaoIds }
      });

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

        // Log de auditoria
        await supabase.from('audit_logs').insert({
          recurso: 'administracao.usuarios',
          acao: 'delete',
          entidade_tipo: 'funcionario',
          entidade_id: userId
        });

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
        
        {(can('administracao.usuarios', 'create') || isAdminEmpresa) && (
          <button
            onClick={() => setShowInviteModal(true)}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            <UserPlus className="w-4 h-4" />
            Convidar Usuário
          </button>
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
                      {funcionario.last_login_at 
                        ? new Date(funcionario.last_login_at).toLocaleDateString('pt-BR')
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
              <div className="text-center py-12">
                <Users className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">
                  Nenhum usuário encontrado
                </h3>
                <p className="text-gray-500">
                  {searchTerm || statusFilter !== 'todos'
                    ? 'Tente ajustar os filtros de busca'
                    : 'Comece convidando o primeiro usuário'
                  }
                </p>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Modais (Invite e Edit) serão implementados em componentes separados */}
      {showInviteModal && (
        <InviteUserModal
          funcoes={funcoes}
          onInvite={handleInviteUser}
          onClose={() => setShowInviteModal(false)}
        />
      )}

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

// Modal de Convite de Usuário
interface InviteUserModalProps {
  funcoes: Funcao[];
  onInvite: (email: string, funcaoIds: string[]) => Promise<void>;
  onClose: () => void;
}

const InviteUserModal: React.FC<InviteUserModalProps> = ({ funcoes, onInvite, onClose }) => {
  const [email, setEmail] = useState('');
  const [selectedFuncoes, setSelectedFuncoes] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || selectedFuncoes.length === 0) return;

    setLoading(true);
    try {
      await onInvite(email, selectedFuncoes);
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
          Convidar Usuário
        </h3>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              E-mail
            </label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="usuario@exemplo.com"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            />
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
              disabled={loading || !email || selectedFuncoes.length === 0}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? (
                <RefreshCw className="w-4 h-4 animate-spin" />
              ) : (
                <Mail className="w-4 h-4" />
              )}
              Enviar Convite
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

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
        status
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