import React, { useState, useEffect } from 'react';
import {
  Users,
  Plus,
  Search,
  Edit,
  Trash2,
  UserCheck,
  UserX,
  Shield,
  Eye,
  Mail,
  Phone,
  Briefcase
} from 'lucide-react';
import { useEmpresa } from '../../hooks/useEmpresa';
import PermissionsManager from '../../components/admin/PermissionsManager';
import { permissoesDefault, type Funcionario, type FuncionarioPermissoes } from '../../types/empresa';
import toast from 'react-hot-toast';

const FuncionariosPage: React.FC = () => {
  const { funcionarios, createFuncionario, updateFuncionario, toggleFuncionario } = useEmpresa();
  const [searchTerm, setSearchTerm] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingFuncionario, setEditingFuncionario] = useState<Funcionario | null>(null);
  const [viewingPermissions, setViewingPermissions] = useState<Funcionario | null>(null);

  // Form state
  const [formData, setFormData] = useState({
    nome: '',
    email: '',
    telefone: '',
    cargo: '',
    usuario: '',
    senha: ''
  });
  const [permissoes, setPermissoes] = useState<FuncionarioPermissoes>(permissoesDefault);

  const filteredFuncionarios = funcionarios.filter(func =>
    func.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
    func.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    func.cargo.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleOpenModal = (funcionario?: Funcionario) => {
    if (funcionario) {
      setEditingFuncionario(funcionario);
      setFormData({
        nome: funcionario.nome,
        email: funcionario.email,
        telefone: funcionario.telefone || '',
        cargo: funcionario.cargo,
        usuario: '',
        senha: ''
      });
      setPermissoes(funcionario.permissoes);
    } else {
      setEditingFuncionario(null);
      setFormData({
        nome: '',
        email: '',
        telefone: '',
        cargo: '',
        usuario: '',
        senha: ''
      });
      setPermissoes(permissoesDefault);
    }
    setShowModal(true);
  };

  const handleCloseModal = () => {
    setShowModal(false);
    setEditingFuncionario(null);
    setFormData({
      nome: '',
      email: '',
      telefone: '',
      cargo: '',
      usuario: '',
      senha: ''
    });
    setPermissoes(permissoesDefault);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!formData.nome || !formData.email || !formData.cargo) {
      toast.error('Preencha todos os campos obrigatórios');
      return;
    }

    try {
      if (editingFuncionario) {
        // Atualizar funcionário existente
        const result = await updateFuncionario(editingFuncionario.id, {
          nome: formData.nome,
          email: formData.email,
          telefone: formData.telefone,
          cargo: formData.cargo,
          permissoes
        });

        if (result.success) {
          toast.success('Funcionário atualizado com sucesso!');
          handleCloseModal();
        } else {
          toast.error(result.error || 'Erro ao atualizar funcionário');
        }
      } else {
        // Criar novo funcionário
        if (!formData.usuario || !formData.senha) {
          toast.error('Usuário e senha são obrigatórios para novos funcionários');
          return;
        }

        const result = await createFuncionario(
          {
            nome: formData.nome,
            email: formData.email,
            telefone: formData.telefone,
            cargo: formData.cargo,
            permissoes
          },
          {
            usuario: formData.usuario,
            senha: formData.senha
          }
        );

        if (result.success) {
          toast.success('Funcionário criado com sucesso!');
          handleCloseModal();
        } else {
          toast.error(result.error || 'Erro ao criar funcionário');
        }
      }
    } catch (error) {
      console.error('Erro ao salvar funcionário:', error);
      toast.error('Erro ao salvar funcionário');
    }
  };

  const handleToggleStatus = async (funcionario: Funcionario) => {
    const result = await toggleFuncionario(funcionario.id, !funcionario.ativo);
    
    if (result.success) {
      toast.success(`Funcionário ${funcionario.ativo ? 'desativado' : 'ativado'} com sucesso!`);
    } else {
      toast.error(result.error || 'Erro ao alterar status');
    }
  };

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Funcionários</h1>
          <p className="text-gray-600">Gerencie a equipe e suas permissões</p>
        </div>
        <button
          onClick={() => handleOpenModal()}
          className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
        >
          <Plus className="w-4 h-4" />
          Novo Funcionário
        </button>
      </div>

      {/* Busca */}
      <div className="bg-white rounded-lg border border-gray-200 p-4">
        <div className="relative">
          <Search className="w-4 h-4 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Buscar funcionários..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
      </div>

      {/* Lista de Funcionários */}
      <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
        {filteredFuncionarios.map(funcionario => (
          <div key={funcionario.id} className="bg-white rounded-lg border border-gray-200 p-6">
            <div className="flex items-start justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className={`p-3 rounded-lg ${funcionario.ativo ? 'bg-green-50' : 'bg-gray-100'}`}>
                  {funcionario.ativo ? (
                    <UserCheck className="w-6 h-6 text-green-600" />
                  ) : (
                    <UserX className="w-6 h-6 text-gray-400" />
                  )}
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900">{funcionario.nome}</h3>
                  <p className="text-sm text-gray-500">{funcionario.cargo}</p>
                </div>
              </div>

              <div className="flex items-center gap-1">
                <button
                  onClick={() => handleOpenModal(funcionario)}
                  className="p-2 text-gray-600 hover:text-gray-800 hover:bg-gray-100 rounded-lg transition-colors"
                  title="Editar"
                >
                  <Edit className="w-4 h-4" />
                </button>
                <button
                  onClick={() => handleToggleStatus(funcionario)}
                  className={`p-2 rounded-lg transition-colors ${
                    funcionario.ativo
                      ? 'text-yellow-600 hover:text-yellow-800 hover:bg-yellow-50'
                      : 'text-green-600 hover:text-green-800 hover:bg-green-50'
                  }`}
                  title={funcionario.ativo ? 'Desativar' : 'Ativar'}
                >
                  {funcionario.ativo ? (
                    <UserX className="w-4 h-4" />
                  ) : (
                    <UserCheck className="w-4 h-4" />
                  )}
                </button>
              </div>
            </div>

            <div className="space-y-2 mb-4">
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <Mail className="w-4 h-4" />
                {funcionario.email}
              </div>
              {funcionario.telefone && (
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <Phone className="w-4 h-4" />
                  {funcionario.telefone}
                </div>
              )}
            </div>

            <button
              onClick={() => setViewingPermissions(funcionario)}
              className="w-full flex items-center justify-center gap-2 px-3 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors text-sm font-medium"
            >
              <Shield className="w-4 h-4" />
              Ver Permissões
            </button>

            <div className={`mt-3 px-3 py-2 rounded-lg text-xs font-medium text-center ${
              funcionario.ativo
                ? 'bg-green-50 text-green-700'
                : 'bg-gray-100 text-gray-500'
            }`}>
              {funcionario.ativo ? 'Ativo' : 'Inativo'}
            </div>
          </div>
        ))}
      </div>

      {filteredFuncionarios.length === 0 && (
        <div className="bg-white rounded-lg border border-gray-200 p-12 text-center">
          <Users className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">
            Nenhum funcionário encontrado
          </h3>
          <p className="text-gray-500 mb-4">
            {searchTerm
              ? 'Tente ajustar o termo de busca'
              : 'Comece adicionando o primeiro funcionário'
            }
          </p>
          {!searchTerm && (
            <button
              onClick={() => handleOpenModal()}
              className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              <Plus className="w-4 h-4" />
              Adicionar Funcionário
            </button>
          )}
        </div>
      )}

      {/* Modal de Criar/Editar */}
      {showModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-in fade-in duration-200">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-hidden">
            {/* Header */}
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-6 py-5 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-white/20 rounded-lg flex items-center justify-center">
                  <Users className="w-5 h-5 text-white" />
                </div>
                <h3 className="text-xl font-semibold text-white">
                  {editingFuncionario ? 'Editar Funcionário' : 'Novo Funcionário'}
                </h3>
              </div>
              <button
                onClick={handleCloseModal}
                className="w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors flex items-center justify-center"
              >
                <span className="text-xl">&times;</span>
              </button>
            </div>

            {/* Content */}
            <form onSubmit={handleSubmit} className="overflow-y-auto max-h-[calc(90vh-180px)]">
              <div className="p-6 space-y-6">
                {/* Dados Básicos */}
                <div className="bg-gray-50 rounded-xl p-6 border border-gray-200">
                  <h4 className="font-semibold text-gray-900 mb-4 flex items-center gap-2">
                    <Briefcase className="w-5 h-5" />
                    Dados Básicos
                  </h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Nome Completo *
                      </label>
                      <input
                        type="text"
                        value={formData.nome}
                        onChange={(e) => setFormData({ ...formData, nome: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                        placeholder="Ex: João Silva"
                        required
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Cargo *
                      </label>
                      <input
                        type="text"
                        value={formData.cargo}
                        onChange={(e) => setFormData({ ...formData, cargo: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                        placeholder="Ex: Vendedor"
                        required
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        E-mail *
                      </label>
                      <input
                        type="email"
                        value={formData.email}
                        onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                        placeholder="exemplo@email.com"
                        required
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Telefone
                      </label>
                      <input
                        type="tel"
                        value={formData.telefone}
                        onChange={(e) => setFormData({ ...formData, telefone: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                        placeholder="(00) 00000-0000"
                      />
                    </div>

                    {!editingFuncionario && (
                      <>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            Usuário *
                          </label>
                          <input
                            type="text"
                            value={formData.usuario}
                            onChange={(e) => setFormData({ ...formData, usuario: e.target.value })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                            placeholder="usuario.login"
                            required
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            Senha *
                          </label>
                          <input
                            type="password"
                            value={formData.senha}
                            onChange={(e) => setFormData({ ...formData, senha: e.target.value })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                            placeholder="••••••••"
                            required
                          />
                        </div>
                      </>
                    )}
                  </div>
                </div>

                {/* Gerenciador de Permissões */}
                <div>
                  <h4 className="font-semibold text-gray-900 mb-4 flex items-center gap-2">
                    <Shield className="w-5 h-5" />
                    Permissões de Acesso
                  </h4>
                  <PermissionsManager
                    permissoes={permissoes}
                    onChange={setPermissoes}
                    isAdmin={true}
                  />
                </div>
              </div>

              {/* Footer */}
              <div className="bg-gray-50 px-6 py-4 flex justify-end gap-3 border-t border-gray-200">
                <button
                  type="button"
                  onClick={handleCloseModal}
                  className="px-5 py-2.5 text-gray-700 font-medium hover:text-gray-900 transition-colors"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  className="flex items-center gap-2 px-5 py-2.5 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-all shadow-sm hover:shadow-md"
                >
                  <UserCheck className="w-4 h-4" />
                  {editingFuncionario ? 'Salvar Alterações' : 'Criar Funcionário'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal de Visualizar Permissões */}
      {viewingPermissions && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-in fade-in duration-200">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-hidden">
            <div className="bg-gradient-to-r from-purple-600 to-purple-700 px-6 py-5 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-white/20 rounded-lg flex items-center justify-center">
                  <Shield className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h3 className="text-xl font-semibold text-white">
                    Permissões: {viewingPermissions.nome}
                  </h3>
                  <p className="text-sm text-purple-100">{viewingPermissions.cargo}</p>
                </div>
              </div>
              <button
                onClick={() => setViewingPermissions(null)}
                className="w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors flex items-center justify-center"
              >
                <span className="text-xl">&times;</span>
              </button>
            </div>

            <div className="overflow-y-auto max-h-[calc(90vh-180px)] p-6">
              <PermissionsManager
                permissoes={viewingPermissions.permissoes}
                onChange={() => {}} // Read-only
                isAdmin={false}
              />
            </div>

            <div className="bg-gray-50 px-6 py-4 flex justify-end border-t border-gray-200">
              <button
                onClick={() => setViewingPermissions(null)}
                className="px-5 py-2.5 bg-gray-100 text-gray-700 font-medium rounded-lg hover:bg-gray-200 transition-colors"
              >
                Fechar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default FuncionariosPage;
