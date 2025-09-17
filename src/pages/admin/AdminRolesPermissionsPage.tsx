import React, { useState, useEffect } from 'react';
import { 
  Shield, 
  Users,
  Plus,
  Search,
  Edit3,
  Trash2,
  RefreshCw,
  AlertTriangle,
  CheckCircle,
  Settings,
  Lock,
  Unlock,
  Crown,
  UserCheck
} from 'lucide-react';
import { usePermissions } from '../../hooks/usePermissions';
import { supabase } from '../../lib/supabase';
import type { Funcao, Permissao } from '../../types/admin';

interface FuncaoWithPermissions extends Funcao {
  permissoes: Permissao[];
  funcionarios_count: number;
  nivel: number; // Adicionado para compatibilidade
  sistema?: boolean; // Adicionado para compatibilidade
}

// Função utilitária para agrupar permissões por recurso
const groupPermissionsByResource = (permissions: Permissao[]): Record<string, Permissao[]> => {
  return permissions.reduce((acc, perm) => {
    if (!acc[perm.recurso]) {
      acc[perm.recurso] = [];
    }
    acc[perm.recurso].push(perm);
    return acc;
  }, {} as Record<string, Permissao[]>);
};

const AdminRolesPermissionsPage: React.FC = () => {
  const { can, isAdmin } = usePermissions();
  const [funcoes, setFuncoes] = useState<FuncaoWithPermissions[]>([]);
  const [permissoes, setPermissoes] = useState<Permissao[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedFuncao, setSelectedFuncao] = useState<FuncaoWithPermissions | null>(null);
  const [showRoleModal, setShowRoleModal] = useState(false);
  const [showPermissionsModal, setShowPermissionsModal] = useState(false);
  const [editingFuncao, setEditingFuncao] = useState<FuncaoWithPermissions | null>(null);

  useEffect(() => {
    if (can('administracao.funcoes', 'read')) {
      loadData();
    }
  }, []);

  const loadData = async () => {
    setLoading(true);
    try {
      await Promise.all([
        loadFuncoes(),
        loadPermissoes()
      ]);
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadFuncoes = async () => {
    const { data: funcoesData } = await supabase
      .from('funcoes')
      .select(`
        *,
        funcao_permissoes (
          permissoes (*)
        )
      `)
      .order('created_at', { ascending: false });

    if (funcoesData) {
      // Contar funcionários por função
      const funcaoIds = funcoesData.map(f => f.id);
      const { data: funcionariosFuncoes } = await supabase
        .from('funcionario_funcoes')
        .select('funcao_id')
        .in('funcao_id', funcaoIds);

      const funcionariosCount = funcionariosFuncoes?.reduce((acc, ff) => {
        acc[ff.funcao_id] = (acc[ff.funcao_id] || 0) + 1;
        return acc;
      }, {} as Record<string, number>) || {};

      const funcoesWithDetails: FuncaoWithPermissions[] = funcoesData.map(funcao => ({
        ...funcao,
        permissoes: funcao.funcao_permissoes?.map((fp: any) => fp.permissoes) || [],
        funcionarios_count: funcionariosCount[funcao.id] || 0,
        nivel: 50, // Valor padrão temporário
        sistema: funcao.is_system || false
      }));

      setFuncoes(funcoesWithDetails);
    }
  };

  const loadPermissoes = async () => {
    const { data } = await supabase
      .from('permissoes')
      .select('*')
      .order('recurso', { ascending: true });

    setPermissoes(data || []);
  };

  const handleCreateRole = async (data: Partial<Funcao>, permissaoIds: string[]) => {
    if (!can('administracao.funcoes', 'create')) return;

    try {
      // Criar função
      const { data: funcao, error } = await supabase
        .from('funcoes')
        .insert(data)
        .select()
        .single();

      if (error) throw error;

      // Associar permissões
      if (permissaoIds.length > 0) {
        const funcaoPermissoes = permissaoIds.map(permissaoId => ({
          funcao_id: funcao.id,
          permissao_id: permissaoId
        }));

        await supabase
          .from('funcao_permissoes')
          .insert(funcaoPermissoes);
      }

      await loadFuncoes();
      setShowRoleModal(false);

      // Log de auditoria
      await supabase.from('audit_logs').insert({
        recurso: 'administracao.funcoes',
        acao: 'create',
        entidade_tipo: 'funcao',
        entidade_id: funcao.id,
        detalhes: { ...data, permissoes: permissaoIds }
      });

    } catch (error) {
      console.error('Erro ao criar função:', error);
      alert('Erro ao criar função. Tente novamente.');
    }
  };

  const handleEditRole = async (funcaoId: string, data: Partial<Funcao>, permissaoIds: string[]) => {
    if (!can('administracao.funcoes', 'update')) return;

    try {
      // Atualizar função
      const { error } = await supabase
        .from('funcoes')
        .update(data)
        .eq('id', funcaoId);

      if (error) throw error;

      // Atualizar permissões
      await supabase
        .from('funcao_permissoes')
        .delete()
        .eq('funcao_id', funcaoId);

      if (permissaoIds.length > 0) {
        const funcaoPermissoes = permissaoIds.map(permissaoId => ({
          funcao_id: funcaoId,
          permissao_id: permissaoId
        }));

        await supabase
          .from('funcao_permissoes')
          .insert(funcaoPermissoes);
      }

      await loadFuncoes();
      setShowRoleModal(false);
      setEditingFuncao(null);

      // Log de auditoria
      await supabase.from('audit_logs').insert({
        recurso: 'administracao.funcoes',
        acao: 'update',
        entidade_tipo: 'funcao',
        entidade_id: funcaoId,
        detalhes: { ...data, permissoes: permissaoIds }
      });

    } catch (error) {
      console.error('Erro ao editar função:', error);
      alert('Erro ao editar função. Tente novamente.');
    }
  };

  const handleDeleteRole = async (funcaoId: string) => {
    if (!can('administracao.funcoes', 'delete')) return;

    // Verificar se há funcionários com essa função
    const funcao = funcoes.find(f => f.id === funcaoId);
    if (funcao && funcao.funcionarios_count > 0) {
      alert('Não é possível excluir uma função que possui funcionários associados.');
      return;
    }

    if (confirm('Tem certeza que deseja excluir esta função? Esta ação não pode ser desfeita.')) {
      try {
        const { error } = await supabase
          .from('funcoes')
          .delete()
          .eq('id', funcaoId);

        if (error) throw error;

        await loadFuncoes();

        // Log de auditoria
        await supabase.from('audit_logs').insert({
          recurso: 'administracao.funcoes',
          acao: 'delete',
          entidade_tipo: 'funcao',
          entidade_id: funcaoId
        });

      } catch (error) {
        console.error('Erro ao excluir função:', error);
        alert('Erro ao excluir função. Tente novamente.');
      }
    }
  };

  const filteredFuncoes = funcoes.filter(funcao =>
    funcao.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
    funcao.descricao?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getNivelColor = (nivel: number) => {
    switch (nivel) {
      case 100: return 'bg-red-100 text-red-800'; // Admin
      case 80: return 'bg-purple-100 text-purple-800'; // Gerente
      case 60: return 'bg-blue-100 text-blue-800'; // Supervisor
      case 40: return 'bg-green-100 text-green-800'; // Operador
      case 20: return 'bg-yellow-100 text-yellow-800'; // Vendedor
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getNivelIcon = (nivel: number) => {
    switch (nivel) {
      case 100: return <Crown className="w-4 h-4" />; // Admin
      case 80: return <Shield className="w-4 h-4" />; // Gerente
      case 60: return <Settings className="w-4 h-4" />; // Supervisor
      case 40: return <UserCheck className="w-4 h-4" />; // Operador
      case 20: return <Users className="w-4 h-4" />; // Vendedor
      default: return <Users className="w-4 h-4" />;
    }
  };

  if (!isAdmin) {
    return (
      <div className="p-6">
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
          <AlertTriangle className="w-12 h-12 text-red-600 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-red-900 mb-2">Acesso Restrito</h3>
          <p className="text-red-700">
            Apenas administradores podem gerenciar funções e permissões.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Funções e Permissões</h1>
          <p className="text-gray-600">
            Gerencie as funções do sistema e suas permissões
          </p>
        </div>
        
        {can('administracao.funcoes', 'create') && (
          <button
            onClick={() => setShowRoleModal(true)}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            <Plus className="w-4 h-4" />
            Nova Função
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
                placeholder="Buscar funções..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
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

      {/* Lista de Funções */}
      {loading ? (
        <div className="bg-white rounded-lg border border-gray-200 p-8">
          <div className="animate-pulse space-y-4">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="flex items-center space-x-4">
                <div className="w-12 h-12 bg-gray-200 rounded-lg"></div>
                <div className="flex-1 space-y-2">
                  <div className="h-4 bg-gray-200 rounded w-1/4"></div>
                  <div className="h-3 bg-gray-200 rounded w-1/2"></div>
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
          {filteredFuncoes.map((funcao) => (
            <div key={funcao.id} className="bg-white rounded-lg border border-gray-200 p-6">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className={`p-2 rounded-lg ${getNivelColor(funcao.nivel)}`}>
                    {getNivelIcon(funcao.nivel)}
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">{funcao.nome}</h3>
                    <p className="text-sm text-gray-500">Nível {funcao.nivel}</p>
                  </div>
                </div>
                
                <div className="flex items-center gap-1">
                  {can('administracao.funcoes', 'update') && (
                    <button
                      onClick={() => {
                        setEditingFuncao(funcao);
                        setShowRoleModal(true);
                      }}
                      className="p-1 text-gray-600 hover:text-gray-800 transition-colors"
                      title="Editar função"
                    >
                      <Edit3 className="w-4 h-4" />
                    </button>
                  )}
                  
                  {can('administracao.funcoes', 'delete') && (
                    <button
                      onClick={() => handleDeleteRole(funcao.id)}
                      className="p-1 text-red-600 hover:text-red-800 transition-colors"
                      title="Excluir função"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  )}
                </div>
              </div>

              {funcao.descricao && (
                <p className="text-sm text-gray-600 mb-4">{funcao.descricao}</p>
              )}

              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium text-gray-700">Funcionários</span>
                  <span className="text-sm text-gray-500">{funcao.funcionarios_count}</span>
                </div>

                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium text-gray-700">Permissões</span>
                  <span className="text-sm text-gray-500">{funcao.permissoes.length}</span>
                </div>

                <button
                  onClick={() => {
                    setSelectedFuncao(funcao);
                    setShowPermissionsModal(true);
                  }}
                  className="w-full mt-4 px-3 py-2 text-sm bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
                >
                  Ver Permissões
                </button>
              </div>

              {funcao.sistema && (
                <div className="mt-4 flex items-center gap-2 text-xs text-blue-600">
                  <Lock className="w-3 h-3" />
                  Função do sistema
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {filteredFuncoes.length === 0 && !loading && (
        <div className="bg-white rounded-lg border border-gray-200 p-12 text-center">
          <Shield className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">
            Nenhuma função encontrada
          </h3>
          <p className="text-gray-500">
            {searchTerm 
              ? 'Tente ajustar o termo de busca'
              : 'Comece criando a primeira função'
            }
          </p>
        </div>
      )}

      {/* Modal de Criar/Editar Função */}
      {showRoleModal && (
        <RoleModal
          funcao={editingFuncao}
          permissoes={permissoes}
          onCreate={handleCreateRole}
          onEdit={handleEditRole}
          onClose={() => {
            setShowRoleModal(false);
            setEditingFuncao(null);
          }}
        />
      )}

      {/* Modal de Visualizar Permissões */}
      {showPermissionsModal && selectedFuncao && (
        <PermissionsModal
          funcao={selectedFuncao}
          onClose={() => {
            setShowPermissionsModal(false);
            setSelectedFuncao(null);
          }}
        />
      )}
    </div>
  );
};

// Modal de Criar/Editar Função
interface RoleModalProps {
  funcao?: FuncaoWithPermissions | null;
  permissoes: Permissao[];
  onCreate: (data: Partial<Funcao>, permissaoIds: string[]) => Promise<void>;
  onEdit: (funcaoId: string, data: Partial<Funcao>, permissaoIds: string[]) => Promise<void>;
  onClose: () => void;
}

const RoleModal: React.FC<RoleModalProps> = ({ funcao, permissoes, onCreate, onEdit, onClose }) => {
  const [nome, setNome] = useState(funcao?.nome || '');
  const [descricao, setDescricao] = useState(funcao?.descricao || '');
  const [nivel, setNivel] = useState(funcao?.nivel || 20);
  const [selectedPermissoes, setSelectedPermissoes] = useState<string[]>(
    funcao?.permissoes.map(p => p.id) || []
  );
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!nome) return;

    setLoading(true);
    try {
      const data = {
        nome,
        descricao: descricao || undefined,
      };

      if (funcao) {
        await onEdit(funcao.id, data, selectedPermissoes);
      } else {
        await onCreate(data, selectedPermissoes);
      }
    } catch (error) {
      // Erro já tratado no componente pai
    } finally {
      setLoading(false);
    }
  };

  const groupedPermissions = groupPermissionsByResource(permissoes);

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">
          {funcao ? 'Editar Função' : 'Nova Função'}
        </h3>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Nome da Função
              </label>
              <input
                type="text"
                value={nome}
                onChange={(e) => setNome(e.target.value)}
                placeholder="Ex: Gerente de Vendas"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Nível de Acesso
              </label>
              <select
                value={nivel}
                onChange={(e) => setNivel(Number(e.target.value))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value={100}>100 - Administrador</option>
                <option value={80}>80 - Gerente</option>
                <option value={60}>60 - Supervisor</option>
                <option value={40}>40 - Operador</option>
                <option value={20}>20 - Vendedor</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Descrição (opcional)
            </label>
            <textarea
              value={descricao}
              onChange={(e) => setDescricao(e.target.value)}
              placeholder="Descreva as responsabilidades desta função..."
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-3">
              Permissões
            </label>
            <div className="space-y-4 max-h-64 overflow-y-auto border border-gray-200 rounded-lg p-4">
              {Object.entries(groupedPermissions).map(([recurso, perms]) => (
                <div key={recurso} className="space-y-2">
                  <h4 className="font-medium text-gray-900 text-sm">
                    {recurso.replace('_', ' ').toUpperCase()}
                  </h4>
                  <div className="grid grid-cols-2 gap-2">
                    {(perms as Permissao[]).map((permissao) => (
                      <label key={permissao.id} className="flex items-center">
                        <input
                          type="checkbox"
                          checked={selectedPermissoes.includes(permissao.id)}
                          onChange={(e) => {
                            if (e.target.checked) {
                              setSelectedPermissoes([...selectedPermissoes, permissao.id]);
                            } else {
                              setSelectedPermissoes(selectedPermissoes.filter(id => id !== permissao.id));
                            }
                          }}
                          className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                        />
                        <span className="ml-2 text-sm text-gray-700">
                          {permissao.acao}
                        </span>
                      </label>
                    ))}
                  </div>
                </div>
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
              disabled={loading || !nome}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? (
                <RefreshCw className="w-4 h-4 animate-spin" />
              ) : (
                <CheckCircle className="w-4 h-4" />
              )}
              {funcao ? 'Salvar Alterações' : 'Criar Função'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

// Modal de Visualizar Permissões
interface PermissionsModalProps {
  funcao: FuncaoWithPermissions;
  onClose: () => void;
}

const PermissionsModal: React.FC<PermissionsModalProps> = ({ funcao, onClose }) => {
  const groupedPermissions = groupPermissionsByResource(funcao.permissoes);

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl p-6 w-full max-w-lg max-h-[80vh] overflow-y-auto">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-gray-900">
            Permissões: {funcao.nome}
          </h3>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            ✕
          </button>
        </div>

        <div className="space-y-4">
          {Object.entries(groupedPermissions).map(([recurso, perms]) => (
            <div key={recurso} className="space-y-2">
              <h4 className="font-medium text-gray-900 text-sm border-b border-gray-200 pb-1">
                {recurso.replace('_', ' ').toUpperCase()}
              </h4>
              <div className="grid grid-cols-2 gap-2">
                {(perms as Permissao[]).map((permissao) => (
                  <div key={permissao.id} className="flex items-center gap-2">
                    <CheckCircle className="w-4 h-4 text-green-600" />
                    <span className="text-sm text-gray-700">
                      {permissao.acao}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          ))}

          {funcao.permissoes.length === 0 && (
            <div className="text-center py-8">
              <Unlock className="w-12 h-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-500">Esta função não possui permissões definidas</p>
            </div>
          )}
        </div>

        <div className="flex justify-end pt-4">
          <button
            onClick={onClose}
            className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
          >
            Fechar
          </button>
        </div>
      </div>
    </div>
  );
};

export default AdminRolesPermissionsPage;