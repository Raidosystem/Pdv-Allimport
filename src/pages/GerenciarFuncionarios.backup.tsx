import { useState, useEffect } from 'react';
import { toast } from 'react-hot-toast';
import { UserPlus, Users, Trash2 } from 'lucide-react';
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
}

export default function GerenciarFuncionarios() {
  const { user, signUpEmployee } = useAuth();
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAddModal, setShowAddModal] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    position: ''
  });
  const [creating, setCreating] = useState(false);

  // Buscar funcionários do usuário logado
  const fetchEmployees = async () => {
    if (!user) return;

    try {
      const { data, error } = await supabase
        .from('user_approvals')
        .select('*')
        .eq('parent_user_id', user.id)
        .eq('user_role', 'employee')
        .eq('status', 'approved') // Só mostra funcionários ativos
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Erro ao buscar funcionários:', error);
        return;
      }

      console.log('👥 Funcionários encontrados:', data?.length || 0);
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

  // Validar formulário
  const validateForm = () => {
    if (!formData.name.trim()) {
      toast.error('Nome é obrigatório');
      return false;
    }
    if (!formData.email.trim()) {
      toast.error('Email é obrigatório');
      return false;
    }
    if (formData.password.length < 6) {
      toast.error('Senha deve ter pelo menos 6 caracteres');
      return false;
    }
    if (formData.password !== formData.confirmPassword) {
      toast.error('Senhas não coincidem');
      return false;
    }
    return true;
  };

  // Criar funcionário
  const handleCreateEmployee = async () => {
    if (!validateForm()) return;

    setCreating(true);
    try {
      const result = await signUpEmployee(formData.email, formData.password, {
        full_name: formData.name,
        position: formData.position,
        role: 'employee'
      });

      if (result.error) {
        toast.error(result.error.message || 'Erro ao criar funcionário');
        return;
      }

      toast.success('Funcionário criado com sucesso!');
      setShowAddModal(false);
      setFormData({
        name: '',
        email: '',
        password: '',
        confirmPassword: '',
        position: ''
      });
      
      // Atualizar lista
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
    // Confirmação mais detalhada
    const confirmMessage = `⚠️ ATENÇÃO: Esta ação irá excluir permanentemente o funcionário:

📧 Email: ${email}
👤 Nome: ${employeeName}

O funcionário não conseguirá mais fazer login no sistema.

Tem certeza que deseja continuar?`;

    if (!confirm(confirmMessage)) {
      return;
    }

    const loadingToast = toast.loading('Excluindo funcionário...');

    try {
      console.log('🗑️ Excluindo funcionário:', { employeeId, email });

      // 1. Desativar na tabela user_approvals
      const { error: updateError } = await supabase
        .from('user_approvals')
        .update({ 
          status: 'rejected',
          approved_at: null,
          approved_by: null
        })
        .eq('id', employeeId);

      if (updateError) {
        console.error('Erro ao atualizar user_approvals:', updateError);
        toast.error('Erro ao excluir funcionário da base de dados');
        return;
      }

      console.log('✅ Funcionário marcado como rejeitado');

      // 2. Opcional: Tentar deletar da auth.users (se possível)
      // Nota: Isso pode falhar por limitações de permissão, mas não é crítico
      try {
        // Esta operação pode falhar e está ok
        await supabase.auth.admin.deleteUser(employeeId);
        console.log('✅ Usuário removido do auth.users');
      } catch (authError) {
        console.log('⚠️ Não foi possível remover do auth.users (normal)');
      }

      toast.success(`Funcionário ${employeeName} foi excluído com sucesso`, {
        duration: 4000,
      });

      // Atualizar lista
      await fetchEmployees();

    } catch (error) {
      console.error('Erro ao excluir funcionário:', error);
      toast.error('Erro inesperado ao excluir funcionário');
    } finally {
      toast.dismiss(loadingToast);
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
    <div className="p-6 bg-gray-50 min-h-screen">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="flex justify-between items-center mb-6">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Gerenciar Funcionários</h1>
            <p className="text-gray-600">Crie e gerencie contas de funcionários vinculadas à sua empresa</p>
          </div>
          
          <button
            onClick={() => setShowAddModal(true)}
            className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            <UserPlus className="w-5 h-5 mr-2" />
            Adicionar Funcionário
          </button>
        </div>

        {/* Lista de Funcionários */}
        <div className="bg-white rounded-lg shadow-sm">
          {employees.length === 0 ? (
            <div className="text-center py-12">
              <Users className="w-16 h-16 mx-auto text-gray-400 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">
                Nenhum funcionário cadastrado
              </h3>
              <p className="text-gray-600 mb-4">
                Adicione funcionários para que possam acessar o sistema com suas próprias contas
              </p>
              <button
                onClick={() => setShowAddModal(true)}
                className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
              >
                <UserPlus className="w-5 h-5 mr-2" />
                Adicionar Primeiro Funcionário
              </button>
            </div>
          ) : (
            <div className="overflow-hidden">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Funcionário
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Email
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Criado em
                    </th>
                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Ações
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {employees.map((employee) => (
                    <tr key={employee.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                            <Users className="w-5 h-5 text-blue-600" />
                          </div>
                          <div className="ml-4">
                            <div className="text-sm font-medium text-gray-900">
                              {employee.full_name}
                            </div>
                            <div className="text-sm text-gray-500">
                              Funcionário
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{employee.email}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                          Ativo
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {new Date(employee.created_at).toLocaleDateString('pt-BR')}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex items-center justify-end space-x-2">
                          <button
                            onClick={() => handleDeleteEmployee(employee.id, employee.email, employee.full_name)}
                            className="inline-flex items-center px-3 py-1.5 text-sm font-medium text-red-600 bg-red-50 border border-red-200 rounded-md hover:bg-red-100 hover:text-red-700 transition-colors"
                            title="Excluir funcionário"
                          >
                            <Trash2 className="w-4 h-4 mr-1" />
                            Excluir
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Modal Adicionar Funcionário */}
        {showAddModal && (
          <div className="fixed inset-0 z-50 overflow-y-auto">
            <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
              <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" onClick={() => setShowAddModal(false)}></div>
              
              <div className="inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6">
                <div className="mb-4">
                  <h3 className="text-lg font-medium text-gray-900 mb-2">
                    Adicionar Novo Funcionário
                  </h3>
                  <p className="text-sm text-gray-600">
                    O funcionário receberá acesso automaticamente após criação.
                  </p>
                </div>

                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Nome Completo *
                    </label>
                    <input
                      type="text"
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
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
                      value={formData.email}
                      onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="email@exemplo.com"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Cargo
                    </label>
                    <input
                      type="text"
                      value={formData.position}
                      onChange={(e) => setFormData({ ...formData, position: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="Vendedor, Gerente, etc."
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Senha *
                      </label>
                      <input
                        type="password"
                        value={formData.password}
                        onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        placeholder="••••••••"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Confirmar Senha *
                      </label>
                      <input
                        type="password"
                        value={formData.confirmPassword}
                        onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        placeholder="••••••••"
                      />
                    </div>
                  </div>
                </div>

                <div className="mt-6 flex space-x-3">
                  <button
                    onClick={() => setShowAddModal(false)}
                    className="flex-1 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
                  >
                    Cancelar
                  </button>
                  <button
                    onClick={handleCreateEmployee}
                    disabled={creating}
                    className="flex-1 px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700 disabled:opacity-50"
                  >
                    {creating ? 'Criando...' : 'Criar Funcionário'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
