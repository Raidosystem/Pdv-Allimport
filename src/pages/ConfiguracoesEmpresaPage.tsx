import { useState, useEffect } from 'react'
import { useUserHierarchy } from '../hooks/useUserHierarchy'
import { useAuth } from '../modules/auth'
import { Button } from '../components/ui/Button'
import { Card } from '../components/ui/Card'
import { Input } from '../components/ui/Input'
import { toast } from 'react-hot-toast'
import { 
  Settings, 
  Users, 
  UserPlus, 
  Edit2, 
  Trash2, 
  Eye, 
  EyeOff,
  Shield,
  Save,
  ArrowLeft,
  CheckCircle,
  XCircle,
  X
} from 'lucide-react'
import { Link } from 'react-router-dom'

// Componente Modal simples
function Modal({ 
  isOpen, 
  onClose, 
  title, 
  children, 
  size = 'md' 
}: {
  isOpen: boolean
  onClose: () => void
  title: string
  children: React.ReactNode
  size?: 'sm' | 'md' | 'lg' | 'xl'
}) {
  if (!isOpen) return null

  const sizeClasses = {
    sm: 'max-w-sm',
    md: 'max-w-md',
    lg: 'max-w-lg',
    xl: 'max-w-2xl'
  }

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex min-h-screen items-center justify-center p-4">
        <div className="fixed inset-0 bg-black bg-opacity-25" onClick={onClose} />
        <div className={`relative bg-white rounded-lg shadow-xl w-full ${sizeClasses[size]}`}>
          <div className="flex items-center justify-between p-6 border-b">
            <h3 className="text-lg font-medium text-gray-900">{title}</h3>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-500"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
          <div className="p-6">
            {children}
          </div>
        </div>
      </div>
    </div>
  )
}

interface Employee {
  id: string
  email: string
  name: string | null
  is_active: boolean
  created_at: string
  permissions: Permission[]
}

interface Permission {
  id: string
  module_name: string
  can_read: boolean
  can_write: boolean
  can_delete: boolean
}

interface SystemModule {
  id: string
  name: string
  display_name: string
  description: string
  is_active: boolean
}

export function ConfiguracoesEmpresaPage() {
  const { user } = useAuth()
  const { 
    getEmployees, 
    createEmployee, 
    updateEmployee, 
    deleteEmployee,
    getSystemModules,
    updateEmployeePermissions,
    isOwner,
    isAdmin,
    loading: authLoading 
  } = useUserHierarchy()

  const [employees, setEmployees] = useState<Employee[]>([])
  const [systemModules, setSystemModules] = useState<SystemModule[]>([])
  const [loading, setLoading] = useState(true)
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [showPermissionsModal, setShowPermissionsModal] = useState(false)
  const [selectedEmployee, setSelectedEmployee] = useState<Employee | null>(null)
  const [newEmployeeEmail, setNewEmployeeEmail] = useState('')
  const [newEmployeeName, setNewEmployeeName] = useState('')

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      setLoading(true)
      const [employeesData, modulesData] = await Promise.all([
        getEmployees(),
        getSystemModules()
      ])
      setEmployees(employeesData)
      setSystemModules(modulesData)
    } catch (error) {
      console.error('Erro ao carregar dados:', error)
      toast.error('Erro ao carregar dados')
    } finally {
      setLoading(false)
    }
  }

  const handleCreateEmployee = async () => {
    if (!newEmployeeEmail.trim()) {
      toast.error('Email é obrigatório')
      return
    }

    try {
      await createEmployee(newEmployeeEmail, newEmployeeName || undefined)
      toast.success('Funcionário criado com sucesso!')
      setShowCreateModal(false)
      setNewEmployeeEmail('')
      setNewEmployeeName('')
      loadData()
    } catch (error: any) {
      console.error('Erro ao criar funcionário:', error)
      toast.error(error.message || 'Erro ao criar funcionário')
    }
  }

  const handleToggleEmployeeStatus = async (employee: Employee) => {
    try {
      await updateEmployee(employee.id, { is_active: !employee.is_active })
      toast.success(`Funcionário ${employee.is_active ? 'desativado' : 'ativado'} com sucesso!`)
      loadData()
    } catch (error: any) {
      console.error('Erro ao atualizar status:', error)
      toast.error('Erro ao atualizar status do funcionário')
    }
  }

  const handleDeleteEmployee = async (employee: Employee) => {
    if (!confirm(`Tem certeza que deseja excluir o funcionário ${employee.email}?`)) {
      return
    }

    try {
      await deleteEmployee(employee.id)
      toast.success('Funcionário excluído com sucesso!')
      loadData()
    } catch (error: any) {
      console.error('Erro ao excluir funcionário:', error)
      toast.error('Erro ao excluir funcionário')
    }
  }

  const handleEditPermissions = (employee: Employee) => {
    setSelectedEmployee(employee)
    setShowPermissionsModal(true)
  }

  const handleUpdatePermissions = async (permissions: any[]) => {
    if (!selectedEmployee) return

    try {
      // Converter array para o formato esperado pelo hook
      const permissionsObj = permissions.reduce((acc, perm) => {
        acc[perm.module_name] = {
          can_view: perm.can_read,
          can_create: perm.can_write,
          can_edit: perm.can_write,
          can_delete: perm.can_delete
        }
        return acc
      }, {} as Record<string, { can_view: boolean; can_create: boolean; can_edit: boolean; can_delete: boolean }>)

      await updateEmployeePermissions(selectedEmployee.id, permissionsObj)
      toast.success('Permissões atualizadas com sucesso!')
      setShowPermissionsModal(false)
      setSelectedEmployee(null)
      loadData()
    } catch (error: any) {
      console.error('Erro ao atualizar permissões:', error)
      toast.error('Erro ao atualizar permissões')
    }
  }

  if (authLoading || loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando...</p>
        </div>
      </div>
    )
  }

  // Permitir acesso para owner OU admin OU email principal (quem fez a compra)
  const isMainAccount = user?.email && (
    user.email.endsWith('@pdvallimport.com') ||
    user.email === 'novaradiosystem@outlook.com' ||
    user.email === 'teste@teste.com'
  )

  // Adicionar logs para debug
  console.log('Debug acesso - User:', user?.email)
  console.log('Debug acesso - isOwner:', isOwner())
  console.log('Debug acesso - isAdmin:', isAdmin())
  console.log('Debug acesso - isMainAccount:', isMainAccount)

  if (!isOwner() && !isAdmin() && !isMainAccount) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <Shield className="w-16 h-16 text-red-500 mx-auto mb-4" />
          <h2 className="text-xl font-semibold text-gray-900 mb-2">Acesso Negado</h2>
          <p className="text-gray-600 mb-4">Você não tem permissão para acessar esta página.</p>
          <p className="text-xs text-gray-500 mb-4">
            Email: {user?.email} | Owner: {isOwner().toString()} | Admin: {isAdmin().toString()} | Main: {isMainAccount?.toString()}
          </p>
          <Link to="/dashboard">
            <Button>Voltar ao Dashboard</Button>
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-4">
              <Link to="/dashboard">
                <Button variant="outline" size="sm" className="gap-2">
                  <ArrowLeft className="w-4 h-4" />
                  Voltar
                </Button>
              </Link>
              <div className="flex items-center">
                <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl flex items-center justify-center mr-3">
                  <Settings className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h1 className="text-xl font-bold text-gray-900">Configurações da Empresa</h1>
                  <p className="text-sm text-gray-600">Gerenciar funcionários e permissões</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        {/* Stats Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 mb-8">
          <Card className="p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mr-4">
                <Users className="w-6 h-6 text-blue-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600">Total de Funcionários</p>
                <p className="text-2xl font-bold text-gray-900">{employees.length}</p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center mr-4">
                <CheckCircle className="w-6 h-6 text-green-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600">Funcionários Ativos</p>
                <p className="text-2xl font-bold text-gray-900">
                  {employees.filter(emp => emp.is_active).length}
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center mr-4">
                <XCircle className="w-6 h-6 text-red-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600">Funcionários Inativos</p>
                <p className="text-2xl font-bold text-gray-900">
                  {employees.filter(emp => !emp.is_active).length}
                </p>
              </div>
            </div>
          </Card>
        </div>

        {/* Employees Section */}
        <Card className="p-6">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center">
              <Users className="w-6 h-6 text-gray-600 mr-2" />
              <h2 className="text-xl font-semibold text-gray-900">Funcionários</h2>
            </div>
            <Button 
              onClick={() => setShowCreateModal(true)}
              className="gap-2"
            >
              <UserPlus className="w-4 h-4" />
              Adicionar Funcionário
            </Button>
          </div>

          {employees.length === 0 ? (
            <div className="text-center py-12">
              <Users className="w-16 h-16 text-gray-300 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-gray-900 mb-2">
                Nenhum funcionário cadastrado
              </h3>
              <p className="text-gray-600 mb-4">
                Adicione funcionários para controlar o acesso ao sistema.
              </p>
              <Button 
                onClick={() => setShowCreateModal(true)}
                className="gap-2"
              >
                <UserPlus className="w-4 h-4" />
                Adicionar Primeiro Funcionário
              </Button>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Funcionário
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Data de Criação
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Ações
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {employees.map((employee) => (
                    <tr key={employee.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div>
                          <p className="text-sm font-medium text-gray-900">
                            {employee.name || employee.email}
                          </p>
                          {employee.name && (
                            <p className="text-sm text-gray-500">{employee.email}</p>
                          )}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                          employee.is_active 
                            ? 'bg-green-100 text-green-800' 
                            : 'bg-red-100 text-red-800'
                        }`}>
                          {employee.is_active ? 'Ativo' : 'Inativo'}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {new Date(employee.created_at).toLocaleDateString('pt-BR')}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => handleEditPermissions(employee)}
                          className="gap-1"
                        >
                          <Edit2 className="w-3 h-3" />
                          Permissões
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => handleToggleEmployeeStatus(employee)}
                          className={`gap-1 ${employee.is_active ? 'text-red-600 hover:bg-red-50' : 'text-green-600 hover:bg-green-50'}`}
                        >
                          {employee.is_active ? (
                            <>
                              <EyeOff className="w-3 h-3" />
                              Desativar
                            </>
                          ) : (
                            <>
                              <Eye className="w-3 h-3" />
                              Ativar
                            </>
                          )}
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => handleDeleteEmployee(employee)}
                          className="gap-1 text-red-600 hover:bg-red-50"
                        >
                          <Trash2 className="w-3 h-3" />
                          Excluir
                        </Button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </Card>
      </main>

      {/* Modal para criar funcionário */}
      <Modal
        isOpen={showCreateModal}
        onClose={() => setShowCreateModal(false)}
        title="Adicionar Funcionário"
      >
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Email *
            </label>
            <Input
              type="email"
              value={newEmployeeEmail}
              onChange={(e: React.ChangeEvent<HTMLInputElement>) => setNewEmployeeEmail(e.target.value)}
              placeholder="funcionario@empresa.com"
              className="w-full"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Nome (opcional)
            </label>
            <Input
              type="text"
              value={newEmployeeName}
              onChange={(e: React.ChangeEvent<HTMLInputElement>) => setNewEmployeeName(e.target.value)}
              placeholder="Nome do funcionário"
              className="w-full"
            />
          </div>
          <div className="flex justify-end space-x-3 pt-4">
            <Button
              variant="outline"
              onClick={() => setShowCreateModal(false)}
            >
              Cancelar
            </Button>
            <Button
              onClick={handleCreateEmployee}
              className="gap-2"
            >
              <Save className="w-4 h-4" />
              Criar Funcionário
            </Button>
          </div>
        </div>
      </Modal>

      {/* Modal para editar permissões */}
      {selectedEmployee && (
        <PermissionsModal
          employee={selectedEmployee}
          systemModules={systemModules}
          isOpen={showPermissionsModal}
          onClose={() => {
            setShowPermissionsModal(false)
            setSelectedEmployee(null)
          }}
          onSave={handleUpdatePermissions}
        />
      )}
    </div>
  )
}

// Componente separado para o modal de permissões
function PermissionsModal({ 
  employee, 
  systemModules, 
  isOpen, 
  onClose, 
  onSave 
}: {
  employee: Employee
  systemModules: SystemModule[]
  isOpen: boolean
  onClose: () => void
  onSave: (permissions: any[]) => void
}) {
  const [permissions, setPermissions] = useState<Record<string, {can_read: boolean, can_write: boolean, can_delete: boolean}>>({})

  useEffect(() => {
    if (employee) {
      const permissionsMap: Record<string, {can_read: boolean, can_write: boolean, can_delete: boolean}> = {}
      
      systemModules.forEach(module => {
        const existingPermission = employee.permissions.find(p => p.module_name === module.name)
        permissionsMap[module.name] = {
          can_read: existingPermission?.can_read || false,
          can_write: existingPermission?.can_write || false,
          can_delete: existingPermission?.can_delete || false
        }
      })
      
      setPermissions(permissionsMap)
    }
  }, [employee, systemModules])

  const handlePermissionChange = (moduleName: string, permission: string, value: boolean) => {
    setPermissions(prev => ({
      ...prev,
      [moduleName]: {
        ...prev[moduleName],
        [permission]: value
      }
    }))
  }

  const handleSave = () => {
    const permissionsArray = Object.entries(permissions).map(([moduleName, perms]) => ({
      module_name: moduleName,
      ...perms
    }))
    onSave(permissionsArray)
  }

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title={`Permissões - ${employee.name || employee.email}`}
      size="lg"
    >
      <div className="space-y-6">
        <div className="text-sm text-gray-600">
          Configure quais módulos este funcionário pode acessar e suas permissões.
        </div>
        
        <div className="space-y-4">
          {systemModules.filter(module => module.is_active).map((module) => (
            <div key={module.name} className="border rounded-lg p-4">
              <div className="flex items-center justify-between mb-3">
                <div>
                  <h4 className="font-medium text-gray-900">{module.display_name}</h4>
                  <p className="text-sm text-gray-600">{module.description}</p>
                </div>
              </div>
              
              <div className="grid grid-cols-3 gap-4">
                <label className="flex items-center space-x-2">
                  <input
                    type="checkbox"
                    checked={permissions[module.name]?.can_read || false}
                    onChange={(e) => handlePermissionChange(module.name, 'can_read', e.target.checked)}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                  <span className="text-sm text-gray-700">Visualizar</span>
                </label>
                
                <label className="flex items-center space-x-2">
                  <input
                    type="checkbox"
                    checked={permissions[module.name]?.can_write || false}
                    onChange={(e) => handlePermissionChange(module.name, 'can_write', e.target.checked)}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                  <span className="text-sm text-gray-700">Editar</span>
                </label>
                
                <label className="flex items-center space-x-2">
                  <input
                    type="checkbox"
                    checked={permissions[module.name]?.can_delete || false}
                    onChange={(e) => handlePermissionChange(module.name, 'can_delete', e.target.checked)}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                  <span className="text-sm text-gray-700">Excluir</span>
                </label>
              </div>
            </div>
          ))}
        </div>

        <div className="flex justify-end space-x-3 pt-4 border-t">
          <Button variant="outline" onClick={onClose}>
            Cancelar
          </Button>
          <Button onClick={handleSave} className="gap-2">
            <Save className="w-4 h-4" />
            Salvar Permissões
          </Button>
        </div>
      </div>
    </Modal>
  )
}
