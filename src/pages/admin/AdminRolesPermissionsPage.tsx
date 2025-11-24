import React, { useState, useEffect } from 'react';
import { 
  Shield, 
  Users,
  Plus,
  Search,
  Edit3,
  Trash2,
  RefreshCw,
  CheckCircle,
  Settings,
  Lock,
  Unlock,
  Crown,
  UserCheck
} from 'lucide-react';
import { usePermissions } from '../../hooks/usePermissions';
import { useAuth } from '../../modules/auth/AuthContext';
import { supabase } from '../../lib/supabase';
import type { Funcao, Permissao } from '../../types/admin';

interface FuncaoWithPermissions extends Funcao {
  permissoes: Permissao[];
  funcionarios_count: number;
  nivel: number; // Adicionado para compatibilidade
  sistema?: boolean; // Adicionado para compatibilidade
}

// Função utilitária para traduzir ações para português
const traduzirAcao = (acao: string): string => {
  const traducoes: Record<string, string> = {
    'create': 'Criar',
    'read': 'Visualizar',
    'update': 'Editar',
    'delete': 'Excluir',
    'manage': 'Gerenciar',
    'execute': 'Executar',
    'export': 'Exportar',
    'import': 'Importar'
  };
  return traducoes[acao.toLowerCase()] || acao;
};

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
  const { user } = useAuth();
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
    const { data: funcoesData, error: funcoesError } = await supabase
      .from('funcoes')
      .select(`
        *,
        funcao_permissoes (
          permissao_id,
          permissoes (
            id,
            recurso,
            acao,
            descricao
          )
        )
      `)
      .order('created_at', { ascending: false });

    if (funcoesError) {
      console.error('Erro ao carregar funções:', funcoesError);
      return;
    }

    if (funcoesData) {
      // Contar funcionários por função
      const funcaoIds = funcoesData.map(f => f.id);
      const { data: funcionariosFuncoes } = await supabase
        .from('funcionarios')
        .select('funcao_id')
        .in('funcao_id', funcaoIds);

      const funcionariosCount = funcionariosFuncoes?.reduce((acc, ff) => {
        acc[ff.funcao_id] = (acc[ff.funcao_id] || 0) + 1;
        return acc;
      }, {} as Record<string, number>) || {};

      const funcoesWithDetails: FuncaoWithPermissions[] = funcoesData.map(funcao => {
        // Extrair permissões da junction table
        const permissoesArray = Array.isArray(funcao.funcao_permissoes) 
          ? funcao.funcao_permissoes
              .map((fp: any) => fp.permissoes)
              .filter((p: any) => p !== null && p !== undefined)
          : [];

        console.log(`🔍 Função "${funcao.nome}":`, {
          funcao_permissoes: funcao.funcao_permissoes,
          permissoesExtraidas: permissoesArray,
          quantidade: permissoesArray.length
        });

        return {
          ...funcao,
          permissoes: permissoesArray,
          funcionarios_count: funcionariosCount[funcao.id] || 0,
          nivel: 50,
          sistema: funcao.is_system || false
        };
      });

      console.log('📋 Funções carregadas com detalhes completos:', funcoesWithDetails);
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
      console.log('🔧 [handleCreateRole] Criando função com user_id:', user?.id);
      
      // Usar user.id como empresa_id (cada usuário é sua própria empresa)
      const empresaId = user?.id;

      if (!empresaId) {
        console.error('❌ [handleCreateRole] user_id não disponível');
        alert('Erro: Usuário não identificado');
        return;
      }

      console.log('✅ [handleCreateRole] Usando empresa_id:', empresaId);

      // Criar função com empresa_id
      const { data: funcaoDataArray, error } = await supabase
        .from('funcoes')
        .insert({
          ...data,
          empresa_id: empresaId
        })
        .select();

      const funcao = funcaoDataArray && funcaoDataArray.length > 0 ? funcaoDataArray[0] : null;

      if (error) throw error;

      // Associar permissões
      if (permissaoIds.length > 0) {
        const funcaoPermissoes = permissaoIds.map(permissaoId => ({
          funcao_id: funcao.id,
          permissao_id: permissaoId,
          empresa_id: empresaId,
          ativo: true, // ✅ AUTO-ATIVAR permissão
          pode_visualizar: true, // ✅ Permite visualizar por padrão
          pode_criar: false, // ⚠️ Criar requer ativação manual
          pode_editar: false, // ⚠️ Editar requer ativação manual
          pode_excluir: false // ⚠️ Excluir requer ativação manual
        }));

        console.log('📝 Inserindo permissões:', funcaoPermissoes);

        const { error: permError, data: permData } = await supabase
          .from('funcao_permissoes')
          .insert(funcaoPermissoes)
          .select();

        if (permError) {
          console.error('❌ Erro ao inserir permissões:', permError);
          throw new Error(`Erro ao associar permissões: ${permError.message}`);
        }

        console.log('✅ Permissões inseridas:', permData);
      }

      await loadFuncoes();
      setShowRoleModal(false);

      // Log de auditoria (desabilitado temporariamente)
      // await supabase.from('audit_logs').insert({
      //   recurso: 'administracao.funcoes',
      //   acao: 'create',
      //   entidade_tipo: 'funcao',
      //   entidade_id: funcao.id,
      //   detalhes: { ...data, permissoes: permissaoIds }
      // });

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

      // Buscar empresa_id do login local (não usar auth.users.id!)
      const { data: empresaData, error: empresaError } = await supabase
        .from('empresas')
        .select('id')
        .eq('email', user?.email)
        .single();

      if (empresaError || !empresaData) {
        console.error('❌ [handleEditPermissions] Empresa não encontrada');
        alert('Erro: Empresa não identificada');
        return;
      }

      const empresaId = empresaData.id;
      console.log('✅ [handleEditPermissions] Usando empresa_id:', empresaId);

      // Atualizar permissões
      console.log('🗑️ Deletando permissões antigas da função:', funcaoId);
      
      const { error: deleteError } = await supabase
        .from('funcao_permissoes')
        .delete()
        .eq('funcao_id', funcaoId);

      if (deleteError) {
        console.error('❌ Erro ao deletar permissões:', deleteError);
      }

      if (permissaoIds.length > 0) {
        const funcaoPermissoes = permissaoIds.map(permissaoId => ({
          funcao_id: funcaoId,
          permissao_id: permissaoId,
          empresa_id: empresaId,
          ativo: true, // ✅ AUTO-ATIVAR permissão
          pode_visualizar: true, // ✅ Permite visualizar por padrão
          pode_criar: false, // ⚠️ Criar requer ativação manual
          pode_editar: false, // ⚠️ Editar requer ativação manual
          pode_excluir: false // ⚠️ Excluir requer ativação manual
        }));

        console.log('📝 Inserindo novas permissões:', funcaoPermissoes);

        const { error: insertError, data: insertData } = await supabase
          .from('funcao_permissoes')
          .insert(funcaoPermissoes)
          .select();

        if (insertError) {
          console.error('❌ Erro ao inserir permissões:', insertError);
          throw new Error(`Erro ao atualizar permissões: ${insertError.message}`);
        }

        console.log('✅ Permissões atualizadas:', insertData);
      }

      await loadFuncoes();
      setShowRoleModal(false);
      setEditingFuncao(null);

      // Log de auditoria (desabilitado temporariamente)
      // await supabase.from('audit_logs').insert({
      //   recurso: 'administracao.funcoes',
      //   acao: 'update',
      //   entidade_tipo: 'funcao',
      //   entidade_id: funcaoId,
      //   detalhes: { ...data, permissoes: permissaoIds }
      // });

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

        // Log de auditoria (desabilitado temporariamente)
        // await supabase.from('audit_logs').insert({
        //   recurso: 'administracao.funcoes',
        //   acao: 'delete',
        //   entidade_tipo: 'funcao',
        //   entidade_id: funcaoId
        // });

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

  // Se está carregando, mostrar loading
  if (loading) {
    return (
      <div className="p-6 flex justify-center items-center">
        <div className="text-gray-600">Carregando permissões...</div>
      </div>
    );
  }

  // REGRA: Todo usuário logado é admin da sua empresa 
  // Não mostrar mais "Acesso Restrito" para usuários logados
  if (!isAdmin) {
    console.log('⚠️ Usuário não reconhecido como admin, mas forçando acesso...');
    // Não bloquear mais - todo usuário logado deve ter acesso
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

      {/* Formulário de Criar/Editar Função (inline) */}
      {showRoleModal && (
        <RoleForm
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

// Formulário de Criar/Editar Função (Inline)
interface RoleFormProps {
  funcao?: FuncaoWithPermissions | null;
  permissoes: Permissao[];
  onCreate: (data: Partial<Funcao>, permissaoIds: string[]) => Promise<void>;
  onEdit: (funcaoId: string, data: Partial<Funcao>, permissaoIds: string[]) => Promise<void>;
  onClose: () => void;
}

const RoleForm: React.FC<RoleFormProps> = ({ funcao, permissoes, onCreate, onEdit, onClose }) => {
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
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-in fade-in duration-200">
      <div 
        className="bg-white rounded-2xl shadow-2xl w-full max-w-3xl max-h-[85vh] overflow-hidden animate-in zoom-in-95 slide-in-from-bottom-4 duration-300"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-6 py-5 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-white/20 rounded-lg flex items-center justify-center">
              <Shield className="w-5 h-5 text-white" />
            </div>
            <h3 className="text-xl font-semibold text-white">
              {funcao ? 'Editar Função' : 'Nova Função'}
            </h3>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors flex items-center justify-center"
          >
            <span className="text-xl">&times;</span>
          </button>
        </div>

        {/* Content */}
        <div className="overflow-y-auto max-h-[calc(85vh-140px)] p-6">
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
                          {traduzirAcao(permissao.acao)}
                        </span>
                      </label>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="bg-gray-50 px-6 py-4 flex justify-end gap-3 border-t border-gray-200">
          <button
            type="button"
            onClick={onClose}
            className="px-5 py-2.5 text-gray-700 font-medium hover:text-gray-900 transition-colors"
          >
            Cancelar
          </button>
          <button
            type="button"
            onClick={(e) => {
              e.preventDefault();
              handleSubmit(e as any);
            }}
            disabled={loading || !nome}
            className="flex items-center gap-2 px-5 py-2.5 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-sm hover:shadow-md"
          >
            {loading ? (
              <RefreshCw className="w-4 h-4 animate-spin" />
            ) : (
              <CheckCircle className="w-4 h-4" />
            )}
            {funcao ? 'Salvar Alterações' : 'Criar Função'}
          </button>
        </div>
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
  console.log('🎯 [PermissionsModal] Renderizando modal com função:', {
    nome: funcao.nome,
    permissoes: funcao.permissoes,
    quantidade: funcao.permissoes?.length || 0
  });

  const groupedPermissions = groupPermissionsByResource(funcao.permissoes || []);

  console.log('🗂️ [PermissionsModal] Permissões agrupadas:', groupedPermissions);

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
          {Object.entries(groupedPermissions).length > 0 ? (
            Object.entries(groupedPermissions).map(([recurso, perms]) => (
              <div key={recurso} className="space-y-2">
                <h4 className="font-medium text-gray-900 text-sm border-b border-gray-200 pb-1">
                  {recurso.replace('_', ' ').toUpperCase()}
                </h4>
                <div className="grid grid-cols-2 gap-2">
                  {(perms as Permissao[]).map((permissao) => (
                    <div key={permissao.id} className="flex items-center gap-2">
                      <CheckCircle className="w-4 h-4 text-green-600" />
                      <span className="text-sm text-gray-700">
                        {traduzirAcao(permissao.acao)}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            ))
          ) : (
            <div className="text-center py-8">
              <Unlock className="w-12 h-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-500 mb-2">Esta função não possui permissões definidas</p>
              <p className="text-xs text-gray-400">
                Use o botão "Editar" para atribuir permissões a esta função
              </p>
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