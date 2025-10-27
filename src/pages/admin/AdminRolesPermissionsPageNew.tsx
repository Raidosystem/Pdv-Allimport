import React, { useState, useEffect } from 'react';
import { 
  Shield, 
  Plus,
  Search,
  Edit3,
  Trash2,
  Eye,
  Check,
  X,
  Crown,
  Users,
  ChevronDown,
  ChevronRight,
  Lock,
  Unlock
} from 'lucide-react';
import { usePermissions } from '../../hooks/usePermissions';
import { useAuth } from '../../modules/auth/AuthContext';
import { supabase } from '../../lib/supabase';
import toast from 'react-hot-toast';

interface Funcao {
  id: string;
  empresa_id: string;
  nome: string;
  descricao: string;
  created_at?: string;
}

interface Permissao {
  id: string;
  recurso: string;
  acao: string;
  descricao: string;
}

interface PermissaoCategoria {
  categoria: string;
  icone: string;
  cor: string;
  permissoes: Permissao[];
}

const AdminRolesPermissionsPageNew: React.FC = () => {
  const { can, isAdmin } = usePermissions();
  const { user } = useAuth();
  const [funcoes, setFuncoes] = useState<Funcao[]>([]);
  const [permissoes, setPermissoes] = useState<Permissao[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [showPermissionsModal, setShowPermissionsModal] = useState(false);
  const [editingFuncao, setEditingFuncao] = useState<Funcao | null>(null);
  const [selectedFuncao, setSelectedFuncao] = useState<Funcao | null>(null);
  const [selectedPermissoes, setSelectedPermissoes] = useState<string[]>([]);
  const [expandedCategories, setExpandedCategories] = useState<string[]>([]);
  
  const [formData, setFormData] = useState({
    nome: '',
    descricao: ''
  });

  useEffect(() => {
    loadData();
  }, []);

  // Prevenir scroll do body quando modal está aberto
  useEffect(() => {
    if (showPermissionsModal || showModal) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, [showPermissionsModal, showModal]);

  const loadData = async () => {
    setLoading(true);
    try {
      await Promise.all([loadFuncoes(), loadPermissoes()]);
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
      toast.error('Erro ao carregar dados');
    } finally {
      setLoading(false);
    }
  };

  const loadFuncoes = async () => {
    if (!user?.id) return;

    // Buscar empresa_id do usuário
    const { data: empresaData, error: empresaError } = await supabase
      .from('empresas')
      .select('id')
      .eq('user_id', user.id)
      .single();

    if (empresaError || !empresaData) {
      console.error('Erro ao buscar empresa:', empresaError);
      return;
    }

    // Buscar apenas funções da empresa do usuário
    const { data, error } = await supabase
      .from('funcoes')
      .select('*')
      .eq('empresa_id', empresaData.id)
      .order('nivel', { ascending: true });

    if (error) {
      console.error('Erro ao carregar funções:', error);
      return;
    }

    setFuncoes(data || []);
  };

  const loadPermissoes = async () => {
    const { data, error } = await supabase
      .from('permissoes')
      .select('*')
      .order('recurso', { ascending: true });

    if (error) {
      console.error('Erro ao carregar permissões:', error);
      return;
    }

    setPermissoes(data || []);
  };

  const categorizarPermissoes = (): PermissaoCategoria[] => {
    const categorias: Record<string, PermissaoCategoria> = {
      vendas: {
        categoria: 'Vendas',
        icone: '🛒',
        cor: 'blue',
        permissoes: []
      },
      produtos: {
        categoria: 'Produtos',
        icone: '📦',
        cor: 'green',
        permissoes: []
      },
      clientes: {
        categoria: 'Clientes',
        icone: '👥',
        cor: 'purple',
        permissoes: []
      },
      financeiro: {
        categoria: 'Financeiro',
        icone: '💰',
        cor: 'yellow',
        permissoes: []
      },
      relatorios: {
        categoria: 'Relatórios',
        icone: '📊',
        cor: 'pink',
        permissoes: []
      },
      configuracoes: {
        categoria: 'Configurações',
        icone: '⚙️',
        cor: 'gray',
        permissoes: []
      },
      administracao: {
        categoria: 'Administração',
        icone: '👑',
        cor: 'red',
        permissoes: []
      }
    };

    permissoes.forEach(perm => {
      const recurso = perm.recurso.split('.')[0];
      if (categorias[recurso]) {
        categorias[recurso].permissoes.push(perm);
      } else {
        if (!categorias['outros']) {
          categorias['outros'] = {
            categoria: 'Outros',
            icone: '📋',
            cor: 'gray',
            permissoes: []
          };
        }
        categorias['outros'].permissoes.push(perm);
      }
    });

    return Object.values(categorias).filter(cat => cat.permissoes.length > 0);
  };

  const handleOpenModal = (funcao?: Funcao) => {
    if (funcao) {
      setEditingFuncao(funcao);
      setFormData({
        nome: funcao.nome,
        descricao: funcao.descricao
      });
    } else {
      setEditingFuncao(null);
      setFormData({
        nome: '',
        descricao: ''
      });
    }
    setShowModal(true);
  };

  const handleCloseModal = () => {
    setShowModal(false);
    setEditingFuncao(null);
    setFormData({
      nome: '',
      descricao: ''
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!user) {
      toast.error('Usuário não autenticado');
      return;
    }
    
    try {
      // Buscar empresa_id do usuário logado
      const { data: empresaData, error: empresaError } = await supabase
        .from('empresas')
        .select('id')
        .eq('user_id', user.id)
        .single();

      if (empresaError || !empresaData?.id) {
        throw new Error('Empresa não encontrada');
      }

      const empresaId = empresaData.id;

      if (editingFuncao) {
        // Atualizar - enviar apenas os campos permitidos
        const { error } = await supabase
          .from('funcoes')
          .update({
            nome: formData.nome,
            descricao: formData.descricao
          })
          .eq('id', editingFuncao.id)
          .eq('empresa_id', empresaId);

        if (error) throw error;
        toast.success('Função atualizada com sucesso!');
      } else {
        // Criar nova função com empresa_id
        const { error } = await supabase
          .from('funcoes')
          .insert([{
            nome: formData.nome,
            descricao: formData.descricao,
            empresa_id: empresaId
          }]);

        if (error) throw error;
        toast.success('Função criada com sucesso!');
      }

      handleCloseModal();
      loadFuncoes();
    } catch (error: any) {
      console.error('Erro ao salvar função:', error);
      toast.error(`Erro ao salvar função: ${error.message || 'Erro desconhecido'}`);
    }
  };

  const handleDeleteFuncao = async (id: string) => {
    if (!confirm('Tem certeza que deseja excluir esta função?')) return;

    try {
      const { error } = await supabase
        .from('funcoes')
        .delete()
        .eq('id', id);

      if (error) throw error;
      toast.success('Função excluída com sucesso!');
      loadFuncoes();
    } catch (error) {
      console.error('Erro ao excluir função:', error);
      toast.error('Erro ao excluir função');
    }
  };

  const handleOpenPermissions = async (funcao: Funcao) => {
    setSelectedFuncao(funcao);
    
    // Carregar permissões da função
    const { data, error } = await supabase
      .from('funcao_permissoes')
      .select('permissao_id')
      .eq('funcao_id', funcao.id);

    if (!error && data) {
      setSelectedPermissoes(data.map(fp => fp.permissao_id));
    }
    
    setShowPermissionsModal(true);
  };

  const handleTogglePermissao = (permissaoId: string) => {
    setSelectedPermissoes(prev => 
      prev.includes(permissaoId)
        ? prev.filter(id => id !== permissaoId)
        : [...prev, permissaoId]
    );
  };

  const handleToggleCategoria = (categoria: string) => {
    setExpandedCategories(prev =>
      prev.includes(categoria)
        ? prev.filter(c => c !== categoria)
        : [...prev, categoria]
    );
  };

  const handleSavePermissions = async () => {
    if (!selectedFuncao || !user) return;

    try {
      // Buscar empresa_id do usuário logado
      const { data: empresaData, error: empresaError } = await supabase
        .from('empresas')
        .select('id')
        .eq('user_id', user.id)
        .single();

      if (empresaError) {
        console.error('Erro ao buscar empresa:', empresaError);
        throw new Error('Empresa não encontrada');
      }

      if (!empresaData?.id) throw new Error('empresa_id não encontrado');

      const empresaId = empresaData.id;

      // Deletar permissões antigas
      const { error: deleteError } = await supabase
        .from('funcao_permissoes')
        .delete()
        .eq('funcao_id', selectedFuncao.id)
        .eq('empresa_id', empresaId);

      if (deleteError) {
        console.error('Erro ao deletar permissões antigas:', deleteError);
        // Continua mesmo se der erro no delete (pode não ter permissões antigas)
      }

      // Inserir novas permissões
      if (selectedPermissoes.length > 0) {
        const inserts = selectedPermissoes.map(permissao_id => ({
          funcao_id: selectedFuncao.id,
          permissao_id,
          empresa_id: empresaId
        }));

        const { error } = await supabase
          .from('funcao_permissoes')
          .insert(inserts);

        if (error) {
          console.error('Erro detalhado ao inserir:', error);
          throw error;
        }
      }

      toast.success('Permissões atualizadas com sucesso!');
      setShowPermissionsModal(false);
      setSelectedFuncao(null);
      setSelectedPermissoes([]);
      loadData(); // Recarrega os dados
    } catch (error: any) {
      console.error('Erro ao salvar permissões:', error);
      toast.error(`Erro ao salvar permissões: ${error.message || 'Verifique as políticas RLS'}`);
    }
  };

  const traduzirAcao = (acao: string): string => {
    const traducoes: Record<string, string> = {
      'create': 'Criar',
      'read': 'Visualizar',
      'update': 'Editar',
      'delete': 'Excluir',
      'manage': 'Gerenciar'
    };
    return traducoes[acao] || acao;
  };

  const getCor = (cor: string) => {
    const cores: Record<string, string> = {
      blue: 'bg-blue-100 text-blue-800 border-blue-300',
      green: 'bg-green-100 text-green-800 border-green-300',
      purple: 'bg-purple-100 text-purple-800 border-purple-300',
      yellow: 'bg-yellow-100 text-yellow-800 border-yellow-300',
      pink: 'bg-pink-100 text-pink-800 border-pink-300',
      gray: 'bg-gray-100 text-gray-800 border-gray-300',
      red: 'bg-red-100 text-red-800 border-red-300'
    };
    return cores[cor] || cores.gray;
  };

  const filteredFuncoes = funcoes.filter(funcao =>
    funcao.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
    funcao.descricao.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-4 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600 font-medium">Carregando...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 flex items-center gap-3">
            <Shield className="w-8 h-8 text-blue-600" />
            Funções & Permissões
          </h2>
          <p className="text-gray-600 mt-1">
            Gerencie as funções do sistema e suas permissões de acesso
          </p>
        </div>
        
        {can('administracao.funcoes', 'create') && (
          <button
            type="button"
            onClick={(e) => {
              e.preventDefault();
              handleOpenModal();
            }}
            className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-xl hover:from-blue-700 hover:to-blue-800 transform hover:scale-105 transition-all duration-200 shadow-lg hover:shadow-xl"
          >
            <Plus className="w-5 h-5" />
            Nova Função
          </button>
        )}
      </div>

      {/* Search */}
      <div className="bg-white rounded-xl shadow-sm border p-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Buscar funções..."
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
      </div>

      {/* Funções List */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredFuncoes.map((funcao) => (
          <div
            key={funcao.id}
            className="bg-white rounded-xl shadow-lg hover:shadow-xl transition-all border-2 border-gray-100 hover:border-blue-300 p-6"
          >
            {/* Header */}
            <div className="flex items-start justify-between mb-4">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <Shield className="w-5 h-5 text-blue-600" />
                  <h3 className="text-lg font-bold text-gray-900">
                    {funcao.nome}
                  </h3>
                </div>
                <p className="text-sm text-gray-600">{funcao.descricao}</p>
              </div>
            </div>

            {/* Actions */}
            <div className="flex gap-2 mt-4">
              <button
                type="button"
                onClick={(e) => {
                  e.preventDefault();
                  handleOpenPermissions(funcao);
                }}
                className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors font-medium"
              >
                <Eye className="w-4 h-4" />
                Permissões
              </button>
              
              <button
                type="button"
                onClick={(e) => {
                  e.preventDefault();
                  handleOpenModal(funcao);
                }}
                className="px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg transition-colors"
              >
                <Edit3 className="w-4 h-4" />
              </button>
              <button
                type="button"
                onClick={(e) => {
                  e.preventDefault();
                  handleDeleteFuncao(funcao.id);
                }}
                className="px-4 py-2 bg-red-100 hover:bg-red-200 text-red-700 rounded-lg transition-colors"
              >
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
          </div>
        ))}
      </div>

      {filteredFuncoes.length === 0 && (
        <div className="bg-white rounded-xl shadow-sm border p-12 text-center">
          <Shield className="w-16 h-16 mx-auto mb-4 text-gray-400" />
          <h3 className="text-xl font-bold text-gray-900 mb-2">
            Nenhuma função encontrada
          </h3>
          <p className="text-gray-600">
            {searchTerm 
              ? 'Tente buscar com outros termos' 
              : 'Crie uma nova função para começar'}
          </p>
        </div>
      )}

      {/* Modal Criar/Editar Função */}
      {showModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-hidden">
            {/* Header */}
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-6 py-5 flex items-center justify-between">
              <h3 className="text-xl font-semibold text-white">
                {editingFuncao ? 'Editar Função' : 'Nova Função'}
              </h3>
              <button
                onClick={handleCloseModal}
                className="w-8 h-8 rounded-lg bg-white/20 hover:bg-white/30 text-white transition-colors flex items-center justify-center"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Content */}
            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Nome da Função *
                </label>
                <input
                  type="text"
                  value={formData.nome}
                  onChange={(e) => setFormData({ ...formData, nome: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Descrição *
                </label>
                <textarea
                  value={formData.descricao}
                  onChange={(e) => setFormData({ ...formData, descricao: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  rows={3}
                  required
                />
              </div>

              {/* Actions */}
              <div className="flex gap-3 pt-4 border-t">
                <button
                  type="button"
                  onClick={handleCloseModal}
                  className="flex-1 px-5 py-2.5 bg-gray-100 text-gray-700 font-medium rounded-lg hover:bg-gray-200 transition-colors"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  className="flex-1 px-5 py-2.5 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors"
                >
                  {editingFuncao ? 'Salvar Alterações' : 'Criar Função'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal Permissões */}
      {showPermissionsModal && selectedFuncao && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-hidden flex flex-col">
            {/* Header */}
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-6 py-5 flex items-center justify-between">
              <div>
                <h3 className="text-xl font-semibold text-white">
                  Permissões: {selectedFuncao.nome}
                </h3>
                <p className="text-blue-100 text-sm mt-1">
                  {selectedPermissoes.length} permissão(ões) selecionada(s)
                </p>
              </div>
              <button
                type="button"
                onClick={(e) => {
                  e.preventDefault();
                  setShowPermissionsModal(false);
                  setSelectedFuncao(null);
                  setSelectedPermissoes([]);
                }}
                className="w-8 h-8 rounded-lg bg-white/20 hover:bg-white/30 text-white transition-colors flex items-center justify-center"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Content */}
            <div className="flex-1 overflow-y-auto p-6 space-y-4">
              {categorizarPermissoes().map((categoria) => {
                const isExpanded = expandedCategories.includes(categoria.categoria);
                const categoriaSelecionadas = categoria.permissoes.filter(p => 
                  selectedPermissoes.includes(p.id)
                ).length;

                return (
                  <div
                    key={categoria.categoria}
                    className="bg-gray-50 rounded-xl border-2 border-gray-200 overflow-hidden"
                  >
                    {/* Header Categoria */}
                    <button
                      type="button"
                      onClick={(e) => {
                        e.preventDefault();
                        handleToggleCategoria(categoria.categoria);
                      }}
                      className="w-full px-5 py-4 flex items-center justify-between hover:bg-gray-100 transition-colors"
                    >
                      <div className="flex items-center gap-3">
                        {isExpanded ? (
                          <ChevronDown className="w-5 h-5 text-gray-600" />
                        ) : (
                          <ChevronRight className="w-5 h-5 text-gray-600" />
                        )}
                        <span className="text-2xl">{categoria.icone}</span>
                        <div className="text-left">
                          <h4 className="font-bold text-gray-900">
                            {categoria.categoria}
                          </h4>
                          <p className="text-sm text-gray-600">
                            {categoria.permissoes.length} permissões disponíveis
                          </p>
                        </div>
                      </div>
                      
                      {categoriaSelecionadas > 0 && (
                        <span className={`px-3 py-1 rounded-full text-sm font-bold ${getCor(categoria.cor)}`}>
                          {categoriaSelecionadas} selecionada(s)
                        </span>
                      )}
                    </button>

                    {/* Permissões */}
                    {isExpanded && (
                      <div className="px-5 pb-4 space-y-2">
                        {categoria.permissoes.map((permissao) => {
                          const isSelected = selectedPermissoes.includes(permissao.id);
                          
                          return (
                            <label
                              key={permissao.id}
                              onClick={(e) => {
                                e.preventDefault();
                                handleTogglePermissao(permissao.id);
                              }}
                              className={`flex items-center gap-3 p-3 rounded-lg cursor-pointer transition-all ${
                                isSelected
                                  ? 'bg-blue-100 border-2 border-blue-300'
                                  : 'bg-white border-2 border-gray-200 hover:border-blue-200'
                              }`}
                            >
                              <div className="flex-shrink-0">
                                <div className={`w-5 h-5 rounded flex items-center justify-center border-2 transition-all ${
                                  isSelected
                                    ? 'bg-blue-600 border-blue-600'
                                    : 'bg-white border-gray-300'
                                }`}>
                                  {isSelected && <Check className="w-3 h-3 text-white" />}
                                </div>
                              </div>
                              
                              <div className="flex-1">
                                <div className="flex items-center gap-2">
                                  <span className="font-semibold text-gray-900">
                                    {permissao.recurso}
                                  </span>
                                  <span className="px-2 py-0.5 bg-gray-200 text-gray-700 text-xs font-bold rounded">
                                    {traduzirAcao(permissao.acao)}
                                  </span>
                                </div>
                                {permissao.descricao && (
                                  <p className="text-sm text-gray-600 mt-0.5">
                                    {permissao.descricao}
                                  </p>
                                )}
                              </div>

                              <input
                                type="checkbox"
                                checked={isSelected}
                                onChange={(e) => e.preventDefault()}
                                className="sr-only"
                                tabIndex={-1}
                              />
                            </label>
                          );
                        })}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>

            {/* Footer */}
            <div className="px-6 py-4 bg-gray-50 border-t flex gap-3">
              <button
                type="button"
                onClick={(e) => {
                  e.preventDefault();
                  setShowPermissionsModal(false);
                  setSelectedFuncao(null);
                  setSelectedPermissoes([]);
                }}
                className="flex-1 px-5 py-2.5 bg-gray-100 text-gray-700 font-medium rounded-lg hover:bg-gray-200 transition-colors"
              >
                Cancelar
              </button>
              <button
                type="button"
                onClick={(e) => {
                  e.preventDefault();
                  handleSavePermissions();
                }}
                className="flex-1 px-5 py-2.5 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors flex items-center justify-center gap-2"
              >
                <Check className="w-5 h-5" />
                Salvar Permissões ({selectedPermissoes.length})
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminRolesPermissionsPageNew;
