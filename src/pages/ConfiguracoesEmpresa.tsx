import React, { useState } from 'react';
import { 
  Building2, 
  Users, 
  Settings, 
  Eye, 
  EyeOff,
  Upload,
  Save,
  UserPlus,
  Edit3,
  MapPin,
  Phone,
  Mail,
  ArrowLeft
} from 'lucide-react';
import { useEmpresa } from '../hooks/useEmpresa';
import { toast } from 'react-hot-toast';
import type { Empresa, Funcionario, FuncionarioPermissoes } from '../types/empresa';
import { permissoesDefault } from '../types/empresa';

export default function ConfiguracoesEmpresa() {
  const { 
    empresa, 
    funcionarios, 
    loading, 
    saveEmpresa, 
    uploadLogo, 
    createFuncionario,
    updateFuncionario,
    toggleFuncionario 
  } = useEmpresa();

  const [activeTab, setActiveTab] = useState<'empresa' | 'funcionarios'>('empresa');
  const [showAddFuncionario, setShowAddFuncionario] = useState(false);
  const [showPermissoes, setShowPermissoes] = useState<string | null>(null);
  const [isEditingEmpresa, setIsEditingEmpresa] = useState(false);

  // Estados do formulário da empresa
  const [empresaForm, setEmpresaForm] = useState<Partial<Empresa>>({
    nome: empresa?.nome || '',
    cnpj: empresa?.cnpj || '',
    telefone: empresa?.telefone || '',
    email: empresa?.email || '',
    endereco: empresa?.endereco || '',
    cidade: empresa?.cidade || '',
    estado: empresa?.estado || '',
    cep: empresa?.cep || '',
  });

  // Estados do formulário de funcionário
  const [funcionarioForm, setFuncionarioForm] = useState({
    nome: '',
    email: '',
    telefone: '',
    cargo: '',
    usuario: '',
    senha: '',
    permissoes: { ...permissoesDefault }
  });

  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);

  const handleGoBack = () => {
    window.history.back();
  };

  React.useEffect(() => {
    if (empresa) {
      setEmpresaForm({
        nome: empresa.nome || '',
        cnpj: empresa.cnpj || '',
        telefone: empresa.telefone || '',
        email: empresa.email || '',
        endereco: empresa.endereco || '',
        cidade: empresa.cidade || '',
        estado: empresa.estado || '',
        cep: empresa.cep || '',
      });
      // Se empresa já existe, iniciar em modo visualização
      setIsEditingEmpresa(false);
    } else {
      // Se não há empresa, iniciar em modo edição
      setIsEditingEmpresa(true);
    }
  }, [empresa]);

  const handleSaveEmpresa = async () => {
    const result = await saveEmpresa(empresaForm);
    if (result.success) {
      toast.success('Dados da empresa salvos com sucesso!');
      // Após salvar, mudar para modo visualização
      setIsEditingEmpresa(false);
    } else {
      toast.error(result.error || 'Erro ao salvar dados da empresa');
    }
  };

  const handleLogoUpload = async () => {
    if (!logoFile) return;

    setUploading(true);
    try {
      const result = await uploadLogo(logoFile);
      if (result.success) {
        await saveEmpresa({ logo_url: result.url });
        toast.success('Logo atualizada com sucesso!');
        setLogoFile(null);
      } else {
        console.error('Erro no upload:', result.error);
        if (result.error?.includes('Bucket')) {
          toast.error(
            'Storage não configurado. Execute o script CONFIGURAR_STORAGE_EMPRESAS.sql no Supabase.',
            { duration: 6000 }
          );
        } else {
          toast.error(result.error || 'Erro ao fazer upload da logo');
        }
      }
    } catch (error: any) {
      console.error('Erro no upload:', error);
      toast.error(error.message || 'Erro ao fazer upload da logo');
    } finally {
      setUploading(false);
    }
  };

  const handleCreateFuncionario = async () => {
    const result = await createFuncionario(
      {
        nome: funcionarioForm.nome,
        email: funcionarioForm.email,
        telefone: funcionarioForm.telefone,
        cargo: funcionarioForm.cargo,
        ativo: true,
        permissoes: funcionarioForm.permissoes
      },
      {
        usuario: funcionarioForm.usuario,
        senha: funcionarioForm.senha
      }
    );

    if (result.success) {
      toast.success('Funcionário criado com sucesso!');
      setShowAddFuncionario(false);
      setFuncionarioForm({
        nome: '',
        email: '',
        telefone: '',
        cargo: '',
        usuario: '',
        senha: '',
        permissoes: { ...permissoesDefault }
      });
    } else {
      toast.error(result.error || 'Erro ao criar funcionário');
    }
  };

  const handleUpdatePermissoes = async (funcionarioId: string, permissoes: FuncionarioPermissoes) => {
    const result = await updateFuncionario(funcionarioId, { permissoes });
    if (result.success) {
      toast.success('Permissões atualizadas com sucesso!');
    } else {
      toast.error(result.error || 'Erro ao atualizar permissões');
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto p-6">
      <div className="mb-8">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">
              Configurações da Empresa
            </h1>
            <p className="text-gray-600">
              Gerencie os dados da sua empresa e configure permissões de funcionários
            </p>
          </div>
          <button
            onClick={handleGoBack}
            className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Voltar
          </button>
        </div>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200 mb-6">
        <nav className="-mb-px flex space-x-8">
          <button
            onClick={() => setActiveTab('empresa')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'empresa'
                ? 'border-blue-500 text-blue-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            <Building2 className="w-5 h-5 inline mr-2" />
            Dados da Empresa
          </button>
          <button
            onClick={() => setActiveTab('funcionarios')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'funcionarios'
                ? 'border-blue-500 text-blue-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            <Users className="w-5 h-5 inline mr-2" />
            Funcionários & Permissões
          </button>
        </nav>
      </div>

      {/* Conteúdo das Tabs */}
      {activeTab === 'empresa' && (
        <div className="bg-white rounded-lg shadow-sm border p-6">
          {!isEditingEmpresa && empresa ? (
            // Modo Visualização - Mostrar dados da empresa
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              {/* Dados da Empresa */}
              <div>
                <div className="flex justify-between items-center mb-6">
                  <h2 className="text-xl font-semibold">Dados da Empresa</h2>
                  <button
                    onClick={() => setIsEditingEmpresa(true)}
                    className="flex items-center px-4 py-2 text-blue-600 border border-blue-600 rounded-md hover:bg-blue-50"
                  >
                    <Edit3 className="w-4 h-4 mr-2" />
                    Editar
                  </button>
                </div>

                <div className="space-y-4">
                  <div className="p-4 bg-gray-50 rounded-lg">
                    <div className="flex items-center mb-2">
                      <Building2 className="w-5 h-5 text-gray-500 mr-2" />
                      <span className="font-medium text-gray-700">Nome da Empresa</span>
                    </div>
                    <p className="text-gray-900 ml-7">{empresa.nome || 'Não informado'}</p>
                  </div>

                  {empresa.cnpj && (
                    <div className="p-4 bg-gray-50 rounded-lg">
                      <div className="flex items-center mb-2">
                        <Settings className="w-5 h-5 text-gray-500 mr-2" />
                        <span className="font-medium text-gray-700">CNPJ</span>
                      </div>
                      <p className="text-gray-900 ml-7">{empresa.cnpj}</p>
                    </div>
                  )}

                  {empresa.telefone && (
                    <div className="p-4 bg-gray-50 rounded-lg">
                      <div className="flex items-center mb-2">
                        <Phone className="w-5 h-5 text-gray-500 mr-2" />
                        <span className="font-medium text-gray-700">Telefone</span>
                      </div>
                      <p className="text-gray-900 ml-7">{empresa.telefone}</p>
                    </div>
                  )}

                  {empresa.email && (
                    <div className="p-4 bg-gray-50 rounded-lg">
                      <div className="flex items-center mb-2">
                        <Mail className="w-5 h-5 text-gray-500 mr-2" />
                        <span className="font-medium text-gray-700">Email</span>
                      </div>
                      <p className="text-gray-900 ml-7">{empresa.email}</p>
                    </div>
                  )}

                  {empresa.endereco && (
                    <div className="p-4 bg-gray-50 rounded-lg">
                      <div className="flex items-center mb-2">
                        <MapPin className="w-5 h-5 text-gray-500 mr-2" />
                        <span className="font-medium text-gray-700">Endereço</span>
                      </div>
                      <p className="text-gray-900 ml-7">
                        {empresa.endereco}
                        {empresa.cidade && `, ${empresa.cidade}`}
                        {empresa.estado && ` - ${empresa.estado}`}
                        {empresa.cep && ` - ${empresa.cep}`}
                      </p>
                    </div>
                  )}
                </div>
              </div>

              {/* Logo da Empresa - Visualização */}
              <div>
                <h2 className="text-xl font-semibold mb-4">Logo da Empresa</h2>
                
                <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                  {empresa?.logo_url ? (
                    <div className="mb-4">
                      <img
                        src={empresa.logo_url}
                        alt="Logo da empresa"
                        className="mx-auto h-32 w-32 object-contain rounded-lg"
                      />
                    </div>
                  ) : (
                    <div className="mb-4">
                      <Building2 className="mx-auto h-16 w-16 text-gray-400" />
                    </div>
                  )}

                  <div className="space-y-2">
                    <input
                      type="file"
                      accept="image/*"
                      onChange={(e) => setLogoFile(e.target.files?.[0] || null)}
                      className="hidden"
                      id="logo-upload-view"
                    />
                    <label
                      htmlFor="logo-upload-view"
                      className="cursor-pointer inline-flex items-center px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
                    >
                      <Upload className="w-4 h-4 mr-2" />
                      {empresa?.logo_url ? 'Alterar Logo' : 'Adicionar Logo'}
                    </label>
                    
                    {logoFile && (
                      <div className="mt-2">
                        <p className="text-sm text-gray-600 mb-2">
                          Arquivo selecionado: {logoFile.name}
                        </p>
                        <button
                          onClick={handleLogoUpload}
                          disabled={uploading}
                          className="inline-flex items-center px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50"
                        >
                          {uploading ? (
                            <>
                              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2" />
                              Enviando...
                            </>
                          ) : (
                            <>
                              <Upload className="w-4 h-4 mr-2" />
                              Fazer Upload
                            </>
                          )}
                        </button>
                      </div>
                    )}
                  </div>
                  
                  <p className="text-xs text-gray-500 mt-2">
                    Formatos aceitos: PNG, JPG, GIF. Tamanho máximo: 2MB
                  </p>
                </div>
              </div>
            </div>
          ) : (
            // Modo Edição - Formulário de cadastro/edição
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              {/* Formulário da Empresa */}
              <div>
                <div className="flex justify-between items-center mb-4">
                  <h2 className="text-xl font-semibold">
                    {empresa ? 'Editar Informações da Empresa' : 'Informações da Empresa'}
                  </h2>
                  {empresa && (
                    <button
                      onClick={() => setIsEditingEmpresa(false)}
                      className="text-gray-500 hover:text-gray-700"
                    >
                      Cancelar
                    </button>
                  )}
                </div>
                
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Nome da Empresa *
                    </label>
                    <input
                      type="text"
                      value={empresaForm.nome}
                      onChange={(e) => setEmpresaForm({ ...empresaForm, nome: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="Digite o nome da empresa"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      CNPJ
                    </label>
                    <input
                      type="text"
                      value={empresaForm.cnpj}
                      onChange={(e) => setEmpresaForm({ ...empresaForm, cnpj: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="00.000.000/0001-00"
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Telefone
                      </label>
                      <input
                        type="text"
                        value={empresaForm.telefone}
                        onChange={(e) => setEmpresaForm({ ...empresaForm, telefone: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        placeholder="(11) 99999-9999"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Email
                      </label>
                      <input
                        type="email"
                        value={empresaForm.email}
                        onChange={(e) => setEmpresaForm({ ...empresaForm, email: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        placeholder="contato@empresa.com"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Endereço
                    </label>
                    <input
                      type="text"
                      value={empresaForm.endereco}
                      onChange={(e) => setEmpresaForm({ ...empresaForm, endereco: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="Rua, número, bairro"
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Cidade
                      </label>
                      <input
                        type="text"
                        value={empresaForm.cidade}
                        onChange={(e) => setEmpresaForm({ ...empresaForm, cidade: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        placeholder="São Paulo"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Estado
                      </label>
                      <input
                        type="text"
                        value={empresaForm.estado}
                        onChange={(e) => setEmpresaForm({ ...empresaForm, estado: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        placeholder="SP"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      CEP
                    </label>
                    <input
                      type="text"
                      value={empresaForm.cep}
                      onChange={(e) => setEmpresaForm({ ...empresaForm, cep: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="00000-000"
                    />
                  </div>

                  <button
                    onClick={handleSaveEmpresa}
                    className="w-full flex items-center justify-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <Save className="w-4 h-4 mr-2" />
                    Salvar Dados da Empresa
                  </button>
                </div>
              </div>

              {/* Upload da Logo - Edição */}
              <div>
                <h2 className="text-xl font-semibold mb-4">Logo da Empresa</h2>
                
                <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                  {empresa?.logo_url ? (
                    <div className="mb-4">
                      <img
                        src={empresa.logo_url}
                        alt="Logo da empresa"
                        className="mx-auto h-32 w-32 object-contain rounded-lg"
                      />
                    </div>
                  ) : (
                    <div className="mb-4">
                      <Building2 className="mx-auto h-16 w-16 text-gray-400" />
                    </div>
                  )}

                  <div className="space-y-2">
                    <input
                      type="file"
                      accept="image/*"
                      onChange={(e) => setLogoFile(e.target.files?.[0] || null)}
                      className="hidden"
                      id="logo-upload-edit"
                    />
                    <label
                      htmlFor="logo-upload-edit"
                      className="cursor-pointer inline-flex items-center px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
                    >
                      <Upload className="w-4 h-4 mr-2" />
                      Selecionar Logo
                    </label>
                    
                    {logoFile && (
                      <div className="mt-2">
                        <p className="text-sm text-gray-600 mb-2">
                          Arquivo selecionado: {logoFile.name}
                        </p>
                        <button
                          onClick={handleLogoUpload}
                          disabled={uploading}
                          className="inline-flex items-center px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50"
                        >
                          {uploading ? (
                            <>
                              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2" />
                              Enviando...
                            </>
                          ) : (
                            <>
                              <Upload className="w-4 h-4 mr-2" />
                              Fazer Upload
                            </>
                          )}
                        </button>
                      </div>
                    )}
                  </div>
                  
                  <p className="text-xs text-gray-500 mt-2">
                    Formatos aceitos: PNG, JPG, GIF. Tamanho máximo: 2MB
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>
      )}

      {activeTab === 'funcionarios' && (
        <div className="space-y-6">
          {/* Botão Adicionar Funcionário */}
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-semibold">Funcionários</h2>
            <button
              onClick={() => setShowAddFuncionario(true)}
              className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              <UserPlus className="w-4 h-4 mr-2" />
              Adicionar Funcionário
            </button>
          </div>

          {/* Lista de Funcionários */}
          <div className="bg-white rounded-lg shadow-sm border">
            {funcionarios.length === 0 ? (
              <div className="p-8 text-center text-gray-500">
                <Users className="w-12 h-12 mx-auto mb-4 text-gray-300" />
                <h3 className="text-lg font-medium mb-2">Nenhum funcionário cadastrado</h3>
                <p>Adicione funcionários para gerenciar permissões de acesso ao sistema</p>
              </div>
            ) : (
              <div className="divide-y divide-gray-200">
                {funcionarios.map((funcionario) => (
                  <div key={funcionario.id} className="p-4">
                    <div className="flex items-center justify-between">
                      <div className="flex-1">
                        <div className="flex items-center">
                          <h3 className="text-lg font-medium text-gray-900">
                            {funcionario.nome}
                          </h3>
                          <span className={`ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                            funcionario.ativo 
                              ? 'bg-green-100 text-green-800'
                              : 'bg-red-100 text-red-800'
                          }`}>
                            {funcionario.ativo ? 'Ativo' : 'Inativo'}
                          </span>
                        </div>
                        <div className="mt-1 flex items-center space-x-4 text-sm text-gray-500">
                          <span>{funcionario.email}</span>
                          {funcionario.cargo && <span>• {funcionario.cargo}</span>}
                          {funcionario.telefone && <span>• {funcionario.telefone}</span>}
                        </div>
                      </div>
                      
                      <div className="flex items-center space-x-2">
                        <button
                          onClick={() => setShowPermissoes(
                            showPermissoes === funcionario.id ? null : funcionario.id
                          )}
                          className="flex items-center px-3 py-1 text-sm text-blue-600 border border-blue-600 rounded hover:bg-blue-50"
                        >
                          {showPermissoes === funcionario.id ? (
                            <>
                              <EyeOff className="w-4 h-4 mr-1" />
                              Ocultar
                            </>
                          ) : (
                            <>
                              <Eye className="w-4 h-4 mr-1" />
                              Permissões
                            </>
                          )}
                        </button>
                        <button
                          onClick={() => toggleFuncionario(funcionario.id, !funcionario.ativo)}
                          className={`px-3 py-1 text-sm rounded ${
                            funcionario.ativo
                              ? 'text-red-600 border border-red-600 hover:bg-red-50'
                              : 'text-green-600 border border-green-600 hover:bg-green-50'
                          }`}
                        >
                          {funcionario.ativo ? 'Desativar' : 'Ativar'}
                        </button>
                      </div>
                    </div>

                    {/* Permissões */}
                    {showPermissoes === funcionario.id && (
                      <div className="mt-4 pt-4 border-t">
                        <PermissoesForm
                          funcionario={funcionario}
                          onSave={(permissoes) => handleUpdatePermissoes(funcionario.id, permissoes)}
                        />
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}

      {/* Modais */}
      {showAddFuncionario && (
        <AddFuncionarioModal
          funcionarioForm={funcionarioForm}
          setFuncionarioForm={setFuncionarioForm}
          onSave={handleCreateFuncionario}
          onClose={() => setShowAddFuncionario(false)}
        />
      )}
    </div>
  );
}

// Componente para editar permissões
function PermissoesForm({
  funcionario,
  onSave
}: {
  funcionario: Funcionario;
  onSave: (permissoes: FuncionarioPermissoes) => void;
}) {
  const [permissoes, setPermissoes] = useState<FuncionarioPermissoes>({
    ...permissoesDefault,
    ...funcionario.permissoes
  });

  const handleSave = () => {
    onSave(permissoes);
  };

  const permissoesList = [
    { key: 'vendas' as keyof FuncionarioPermissoes, label: 'Vendas', description: 'Realizar vendas e consultar histórico' },
    { key: 'produtos' as keyof FuncionarioPermissoes, label: 'Produtos', description: 'Gerenciar produtos e estoque' },
    { key: 'clientes' as keyof FuncionarioPermissoes, label: 'Clientes', description: 'Gerenciar cadastro de clientes' },
    { key: 'caixa' as keyof FuncionarioPermissoes, label: 'Caixa', description: 'Abrir/fechar caixa e consultar movimentação' },
    { key: 'ordens_servico' as keyof FuncionarioPermissoes, label: 'Ordens de Serviço', description: 'Gerenciar ordens de serviço' },
    { key: 'relatorios' as keyof FuncionarioPermissoes, label: 'Relatórios', description: 'Visualizar relatórios e gráficos' },
    { key: 'configuracoes' as keyof FuncionarioPermissoes, label: 'Configurações', description: 'Alterar configurações do sistema' },
  ] as const;

  return (
    <div className="space-y-4">
      <h4 className="font-medium text-gray-900">Permissões de Acesso</h4>
      
      {permissoesList.map(({ key, label, description }) => (
        <div key={key} className="flex items-start">
          <div className="flex items-center h-5">
            <input
              id={`permissao-${key}`}
              type="checkbox"
              checked={permissoes[key] || false}
              onChange={(e) => setPermissoes({ ...permissoes, [key]: e.target.checked })}
              className="focus:ring-blue-500 h-4 w-4 text-blue-600 border-gray-300 rounded"
            />
          </div>
          <div className="ml-3 text-sm">
            <label htmlFor={`permissao-${key}`} className="font-medium text-gray-700">
              {label}
            </label>
            <p className="text-gray-500">{description}</p>
          </div>
        </div>
      ))}

      {/* Botão Salvar */}
      <div className="flex justify-end pt-4 border-t border-gray-200">
        <button
          onClick={handleSave}
          className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
        >
          <Save className="w-4 h-4 mr-2" />
          Salvar Permissões
        </button>
      </div>
    </div>
  );
}

// Modal para adicionar funcionário
function AddFuncionarioModal({
  funcionarioForm,
  setFuncionarioForm,
  onSave,
  onClose
}: {
  funcionarioForm: any;
  setFuncionarioForm: any;
  onSave: () => void;
  onClose: () => void;
}) {
  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" onClick={onClose}></div>
        
        <div className="inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6">
          <div className="mb-4">
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              Adicionar Novo Funcionário
            </h3>
          </div>

          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Nome Completo *
              </label>
              <input
                type="text"
                value={funcionarioForm.nome}
                onChange={(e) => setFuncionarioForm({ ...funcionarioForm, nome: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Nome do funcionário"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Email *
              </label>
              <input
                type="email"
                value={funcionarioForm.email}
                onChange={(e) => setFuncionarioForm({ ...funcionarioForm, email: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="email@exemplo.com"
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Telefone
                </label>
                <input
                  type="text"
                  value={funcionarioForm.telefone}
                  onChange={(e) => setFuncionarioForm({ ...funcionarioForm, telefone: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="(11) 99999-9999"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Cargo
                </label>
                <input
                  type="text"
                  value={funcionarioForm.cargo}
                  onChange={(e) => setFuncionarioForm({ ...funcionarioForm, cargo: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Vendedor, Gerente..."
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Usuário para Login *
                </label>
                <input
                  type="text"
                  value={funcionarioForm.usuario}
                  onChange={(e) => setFuncionarioForm({ ...funcionarioForm, usuario: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="usuario123"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Senha *
                </label>
                <input
                  type="password"
                  value={funcionarioForm.senha}
                  onChange={(e) => setFuncionarioForm({ ...funcionarioForm, senha: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="••••••••"
                />
              </div>
            </div>
          </div>

          <div className="mt-6 flex space-x-3">
            <button
              onClick={onClose}
              className="flex-1 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
            >
              Cancelar
            </button>
            <button
              onClick={onSave}
              className="flex-1 px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700"
            >
              Salvar Funcionário
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
