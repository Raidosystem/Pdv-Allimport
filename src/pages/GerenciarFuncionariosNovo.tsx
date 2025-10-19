import { useState, useEffect } from 'react';
import { toast } from 'react-hot-toast';
import {
  UserPlus,
  Users,
  Trash2,
  Edit,
  Eye,
  EyeOff,
  ShoppingCart,
  Package,
  UsersIcon,
  Wallet,
  Wrench,
  BarChart3,
  Settings,
  Database,
  Check,
  X,
  Sparkles,
  Shield,
  Briefcase,
  DollarSign
} from 'lucide-react';
import { useAuth } from '../modules/auth';
import { supabase } from '../lib/supabase';

interface Employee {
  id: string;
  email: string;
  full_name: string;
  company_name: string;
  user_role: 'employee';
  status: 'approved';
  created_at: string;
  approved_at: string;
  parent_user_id: string;
  permissions?: EmployeePermissions;
}

interface EmployeePermissions {
  vendas: boolean;
  produtos: boolean;
  clientes: boolean;
  caixa: boolean;
  ordens_servico: boolean;
  relatorios: boolean;
  configuracoes: boolean;
  backup: boolean;
}

const defaultPermissions: EmployeePermissions = {
  vendas: true,
  produtos: true,
  clientes: true,
  caixa: false,
  ordens_servico: true,
  relatorios: false,
  configuracoes: false,
  backup: false
};

// Templates de permissões predefinidos
const permissionTemplates = {
  vendedor: {
    name: 'Vendedor',
    icon: ShoppingCart,
    color: 'blue',
    description: 'Acesso a vendas e cadastro de clientes',
    permissions: {
      vendas: true,
      produtos: true,
      clientes: true,
      caixa: false,
      ordens_servico: false,
      relatorios: false,
      configuracoes: false,
      backup: false
    }
  },
  caixa: {
    name: 'Operador de Caixa',
    icon: DollarSign,
    color: 'green',
    description: 'Vendas e gestão de caixa',
    permissions: {
      vendas: true,
      produtos: true,
      clientes: true,
      caixa: true,
      ordens_servico: false,
      relatorios: false,
      configuracoes: false,
      backup: false
    }
  },
  tecnico: {
    name: 'Técnico',
    icon: Wrench,
    color: 'purple',
    description: 'Ordens de serviço e clientes',
    permissions: {
      vendas: false,
      produtos: true,
      clientes: true,
      caixa: false,
      ordens_servico: true,
      relatorios: false,
      configuracoes: false,
      backup: false
    }
  },
  gerente: {
    name: 'Gerente',
    icon: Briefcase,
    color: 'orange',
    description: 'Acesso completo exceto configurações',
    permissions: {
      vendas: true,
      produtos: true,
      clientes: true,
      caixa: true,
      ordens_servico: true,
      relatorios: true,
      configuracoes: false,
      backup: false
    }
  }
};

// Card de permissão individual
const PermissionCard = ({ 
  icon: Icon, 
  title, 
  description, 
  enabled, 
  onChange, 
  color 
}: any) => (
  <div 
    className={`relative p-4 border-2 rounded-xl transition-all cursor-pointer group hover:shadow-lg ${
      enabled 
        ? `border-${color}-500 bg-${color}-50` 
        : 'border-gray-200 bg-white hover:border-gray-300'
    }`}
    onClick={onChange}
  >
    <div className="flex items-start justify-between mb-2">
      <div className={`p-2 rounded-lg ${enabled ? `bg-${color}-100` : 'bg-gray-100'}`}>
        <Icon className={`w-5 h-5 ${enabled ? `text-${color}-600` : 'text-gray-400'}`} />
      </div>
      <div className={`w-6 h-6 rounded-full border-2 flex items-center justify-center transition-all ${
        enabled 
          ? `bg-${color}-500 border-${color}-500` 
          : 'border-gray-300 bg-white'
      }`}>
        {enabled && <Check className="w-4 h-4 text-white" />}
      </div>
    </div>
    <h3 className={`font-semibold text-sm mb-1 ${enabled ? `text-${color}-900` : 'text-gray-700'}`}>
      {title}
    </h3>
    <p className={`text-xs ${enabled ? `text-${color}-700` : 'text-gray-500'}`}>
      {description}
    </p>
  </div>
);

export default function GerenciarFuncionariosNovo() {
  const { user, signUpEmployee } = useAuth();
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingEmployee, setEditingEmployee] = useState<Employee | null>(null);
  const [selectedTemplate, setSelectedTemplate] = useState<string | null>(null);
  
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    position: ''
  });
  
  const [permissions, setPermissions] = useState<EmployeePermissions>(defaultPermissions);
  const [creating, setCreating] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const permissionsConfig = [
    { key: 'vendas', icon: ShoppingCart, title: 'Vendas', description: 'Registrar e gerenciar vendas', color: 'blue' },
    { key: 'produtos', icon: Package, title: 'Produtos', description: 'Cadastrar e editar produtos', color: 'green' },
    { key: 'clientes', icon: UsersIcon, title: 'Clientes', description: 'Gerenciar cadastro de clientes', color: 'purple' },
    { key: 'caixa', icon: Wallet, title: 'Caixa', description: 'Abrir/fechar caixa e movimentações', color: 'yellow' },
    { key: 'ordens_servico', icon: Wrench, title: 'Ordens de Serviço', description: 'Criar e acompanhar OS', color: 'orange' },
    { key: 'relatorios', icon: BarChart3, title: 'Relatórios', description: 'Visualizar relatórios e analytics', color: 'indigo' },
    { key: 'configuracoes', icon: Settings, title: 'Configurações', description: 'Alterar configurações do sistema', color: 'red' },
    { key: 'backup', icon: Database, title: 'Backup', description: 'Fazer backup e restaurar dados', color: 'pink' }
  ];

  // Buscar funcionários
  const fetchEmployees = async () => {
    if (!user) return;

    try {
      const { data, error } = await supabase
        .from('user_approvals')
        .select('*')
        .eq('parent_user_id', user.id)
        .eq('user_role', 'employee')
        .eq('status', 'approved')
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Erro ao buscar funcionários:', error);
        return;
      }

      setEmployees(data || []);
    } catch (error) {
      console.error('Erro ao buscar funcionários:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchEmployees();
  }, [user]);

  // Aplicar template
  const applyTemplate = (templateKey: string) => {
    const template = permissionTemplates[templateKey as keyof typeof permissionTemplates];
    if (template) {
      setPermissions(template.permissions);
      setSelectedTemplate(templateKey);
      toast.success(`Template "${template.name}" aplicado!`);
    }
  };

  // Toggle permissão individual
  const togglePermission = (key: keyof EmployeePermissions) => {
    setPermissions(prev => ({
      ...prev,
      [key]: !prev[key]
    }));
    setSelectedTemplate(null); // Remover template selecionado ao personalizar
  };

  // Criar funcionário
  const handleCreateEmployee = async () => {
    if (!formData.name.trim()) {
      toast.error('Nome é obrigatório');
      return;
    }
    if (!formData.email.trim()) {
      toast.error('Email é obrigatório');
      return;
    }
    if (formData.password.length < 6) {
      toast.error('Senha deve ter pelo menos 6 caracteres');
      return;
    }
    if (formData.password !== formData.confirmPassword) {
      toast.error('Senhas não coincidem');
      return;
    }

    setCreating(true);
    try {
      const result = await signUpEmployee(formData.email, formData.password, {
        full_name: formData.name,
        position: formData.position,
        role: 'employee',
        permissions: permissions
      });

      if (result.error) {
        toast.error(result.error.message || 'Erro ao criar funcionário');
        return;
      }

      toast.success('✅ Funcionário criado com sucesso!');
      closeModal();
      await fetchEmployees();
    } catch (error: any) {
      console.error('Erro ao criar funcionário:', error);
      toast.error('Erro inesperado ao criar funcionário');
    } finally {
      setCreating(false);
    }
  };

  // Excluir funcionário
  const handleDeleteEmployee = async (employeeId: string, email: string, employeeName: string) => {
    if (!confirm(`⚠️ Deseja excluir o funcionário "${employeeName}"?\n\nEsta ação não pode ser desfeita.`)) {
      return;
    }

    const loadingToast = toast.loading('Excluindo funcionário...');

    try {
      const { error } = await supabase
        .from('user_approvals')
        .update({ status: 'rejected', approved_at: null, approved_by: null })
        .eq('id', employeeId);

      if (error) {
        toast.error('Erro ao excluir funcionário');
        return;
      }

      toast.success(`✅ ${employeeName} foi excluído com sucesso`);
      await fetchEmployees();
    } catch (error) {
      console.error('Erro ao excluir funcionário:', error);
      toast.error('Erro inesperado ao excluir funcionário');
    } finally {
      toast.dismiss(loadingToast);
    }
  };

  const closeModal = () => {
    setShowModal(false);
    setEditingEmployee(null);
    setFormData({ name: '', email: '', password: '', confirmPassword: '', position: '' });
    setPermissions(defaultPermissions);
    setSelectedTemplate(null);
    setShowPassword(false);
  };

  const activePermissionsCount = Object.values(permissions).filter(Boolean).length;

  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header com gradiente */}
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-2xl shadow-xl p-8 mb-8 text-white">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-3xl font-bold mb-2 flex items-center">
                <Users className="w-8 h-8 mr-3" />
                Gerenciar Funcionários
              </h1>
              <p className="text-blue-100 text-lg">
                {employees.length} funcionário{employees.length !== 1 ? 's' : ''} cadastrado{employees.length !== 1 ? 's' : ''}
              </p>
            </div>
            
            <button
              onClick={() => setShowModal(true)}
              className="flex items-center px-6 py-3 bg-white text-blue-600 rounded-xl hover:bg-blue-50 transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-0.5 font-semibold"
            >
              <UserPlus className="w-5 h-5 mr-2" />
              Novo Funcionário
            </button>
          </div>
        </div>

        {/* Lista de Funcionários em Cards */}
        {employees.length === 0 ? (
          <div className="bg-white rounded-2xl shadow-lg p-12 text-center">
            <div className="max-w-md mx-auto">
              <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-6">
                <Users className="w-10 h-10 text-blue-600" />
              </div>
              <h3 className="text-2xl font-bold text-gray-900 mb-3">
                Nenhum funcionário cadastrado
              </h3>
              <p className="text-gray-600 mb-8 text-lg">
                Adicione funcionários para que possam acessar o sistema com permissões personalizadas
              </p>
              <button
                onClick={() => setShowModal(true)}
                className="inline-flex items-center px-8 py-4 bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-xl hover:from-blue-700 hover:to-blue-800 shadow-lg hover:shadow-xl transition-all transform hover:-translate-y-0.5 font-semibold text-lg"
              >
                <UserPlus className="w-6 h-6 mr-3" />
                Adicionar Primeiro Funcionário
              </button>
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {employees.map((employee) => (
              <div key={employee.id} className="bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all p-6 border border-gray-100">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center">
                    <div className="w-14 h-14 bg-gradient-to-br from-blue-500 to-blue-600 rounded-full flex items-center justify-center text-white text-xl font-bold shadow-md">
                      {employee.full_name.charAt(0).toUpperCase()}
                    </div>
                    <div className="ml-4">
                      <h3 className="font-bold text-lg text-gray-900">{employee.full_name}</h3>
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        <span className="w-2 h-2 bg-green-500 rounded-full mr-1.5 animate-pulse"></span>
                        Ativo
                      </span>
                    </div>
                  </div>
                </div>

                <div className="space-y-2 mb-4">
                  <div className="flex items-center text-sm text-gray-600">
                    <span className="font-medium mr-2">📧</span>
                    {employee.email}
                  </div>
                  <div className="flex items-center text-sm text-gray-600">
                    <span className="font-medium mr-2">📅</span>
                    Desde {new Date(employee.created_at).toLocaleDateString('pt-BR')}
                  </div>
                </div>

                <div className="flex gap-2 pt-4 border-t border-gray-100">
                  <button
                    onClick={() => handleDeleteEmployee(employee.id, employee.email, employee.full_name)}
                    className="flex-1 flex items-center justify-center px-4 py-2.5 text-sm font-medium text-red-600 bg-red-50 border border-red-200 rounded-lg hover:bg-red-100 transition-colors"
                  >
                    <Trash2 className="w-4 h-4 mr-2" />
                    Excluir
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Modal Criar/Editar Funcionário */}
        {showModal && (
          <div className="fixed inset-0 z-50 overflow-y-auto">
            <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20">
              <div className="fixed inset-0 bg-black bg-opacity-50 transition-opacity backdrop-blur-sm" onClick={closeModal}></div>
              
              <div className="relative bg-white rounded-2xl shadow-2xl max-w-5xl w-full max-h-[90vh] overflow-y-auto">
                {/* Header do Modal */}
                <div className="sticky top-0 bg-gradient-to-r from-blue-600 to-blue-700 text-white px-8 py-6 rounded-t-2xl">
                  <div className="flex items-center justify-between">
                    <div>
                      <h2 className="text-2xl font-bold">Novo Funcionário</h2>
                      <p className="text-blue-100 mt-1">Preencha os dados e configure as permissões de acesso</p>
                    </div>
                    <button
                      onClick={closeModal}
                      className="w-10 h-10 flex items-center justify-center rounded-full bg-white/20 hover:bg-white/30 transition-colors"
                    >
                      <X className="w-6 h-6" />
                    </button>
                  </div>
                </div>

                <div className="p-8">
                  {/* Dados Básicos */}
                  <div className="mb-8">
                    <h3 className="text-lg font-bold text-gray-900 mb-4 flex items-center">
                      <Users className="w-5 h-5 mr-2 text-blue-600" />
                      Dados do Funcionário
                    </h3>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-semibold text-gray-700 mb-2">
                          Nome Completo *
                        </label>
                        <input
                          type="text"
                          value={formData.name}
                          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                          className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-blue-500 transition-colors"
                          placeholder="João Silva"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-semibold text-gray-700 mb-2">
                          Email *
                        </label>
                        <input
                          type="email"
                          value={formData.email}
                          onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                          className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-blue-500 transition-colors"
                          placeholder="joao@email.com"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-semibold text-gray-700 mb-2">
                          Cargo
                        </label>
                        <input
                          type="text"
                          value={formData.position}
                          onChange={(e) => setFormData({ ...formData, position: e.target.value })}
                          className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-blue-500 transition-colors"
                          placeholder="Vendedor, Gerente, etc."
                        />
                      </div>
                      <div className="relative">
                        <label className="block text-sm font-semibold text-gray-700 mb-2">
                          Senha *
                        </label>
                        <input
                          type={showPassword ? 'text' : 'password'}
                          value={formData.password}
                          onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                          className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-blue-500 transition-colors pr-12"
                          placeholder="••••••••"
                        />
                        <button
                          type="button"
                          onClick={() => setShowPassword(!showPassword)}
                          className="absolute right-3 top-11 text-gray-400 hover:text-gray-600"
                        >
                          {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                        </button>
                      </div>
                      <div className="col-span-2">
                        <label className="block text-sm font-semibold text-gray-700 mb-2">
                          Confirmar Senha *
                        </label>
                        <input
                          type={showPassword ? 'text' : 'password'}
                          value={formData.confirmPassword}
                          onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
                          className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-blue-500 transition-colors"
                          placeholder="••••••••"
                        />
                      </div>
                    </div>
                  </div>

                  {/* Templates de Permissões */}
                  <div className="mb-8">
                    <h3 className="text-lg font-bold text-gray-900 mb-4 flex items-center">
                      <Sparkles className="w-5 h-5 mr-2 text-blue-600" />
                      Templates Rápidos
                    </h3>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                      {Object.entries(permissionTemplates).map(([key, template]) => {
                        const Icon = template.icon;
                        const isSelected = selectedTemplate === key;
                        return (
                          <button
                            key={key}
                            onClick={() => applyTemplate(key)}
                            className={`p-4 border-2 rounded-xl transition-all text-left ${
                              isSelected
                                ? `border-${template.color}-500 bg-${template.color}-50`
                                : 'border-gray-200 hover:border-gray-300 bg-white'
                            }`}
                          >
                            <Icon className={`w-8 h-8 mb-2 ${isSelected ? `text-${template.color}-600` : 'text-gray-400'}`} />
                            <div className={`font-semibold text-sm mb-1 ${isSelected ? `text-${template.color}-900` : 'text-gray-700'}`}>
                              {template.name}
                            </div>
                            <div className={`text-xs ${isSelected ? `text-${template.color}-700` : 'text-gray-500'}`}>
                              {template.description}
                            </div>
                          </button>
                        );
                      })}
                    </div>
                  </div>

                  {/* Permissões Personalizadas */}
                  <div className="mb-8">
                    <div className="flex items-center justify-between mb-4">
                      <h3 className="text-lg font-bold text-gray-900 flex items-center">
                        <Shield className="w-5 h-5 mr-2 text-blue-600" />
                        Permissões Personalizadas
                      </h3>
                      <span className="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-sm font-semibold">
                        {activePermissionsCount} ativas
                      </span>
                    </div>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                      {permissionsConfig.map((config) => (
                        <PermissionCard
                          key={config.key}
                          icon={config.icon}
                          title={config.title}
                          description={config.description}
                          enabled={permissions[config.key as keyof EmployeePermissions]}
                          onChange={() => togglePermission(config.key as keyof EmployeePermissions)}
                          color={config.color}
                        />
                      ))}
                    </div>
                  </div>

                  {/* Botões de Ação */}
                  <div className="flex gap-4 pt-6 border-t border-gray-200">
                    <button
                      onClick={closeModal}
                      className="flex-1 px-6 py-4 text-sm font-semibold text-gray-700 bg-gray-100 border-2 border-gray-200 rounded-xl hover:bg-gray-200 transition-all"
                    >
                      Cancelar
                    </button>
                    <button
                      onClick={handleCreateEmployee}
                      disabled={creating}
                      className="flex-1 px-6 py-4 text-sm font-semibold text-white bg-gradient-to-r from-blue-600 to-blue-700 rounded-xl hover:from-blue-700 hover:to-blue-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
                    >
                      {creating ? (
                        <span className="flex items-center justify-center">
                          <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                          Criando...
                        </span>
                      ) : (
                        'Criar Funcionário'
                      )}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
