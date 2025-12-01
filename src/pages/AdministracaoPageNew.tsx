import { useState, useEffect } from 'react'
import { Users, Shield, Database, BarChart3, Crown, UserCheck } from 'lucide-react'
import { PermissionsProvider, usePermissions } from '../hooks/usePermissions'
import AdminDashboard from './admin/AdminDashboard'
import AdminUsersPage from './admin/AdminUsersPage'
// import AdminConvitesPage from './admin/AdminConvitesPage' // REMOVIDO - Sistema automático
import AdminRolesPermissionsPageNew from './admin/AdminRolesPermissionsPageNew' // NOVA VERSÃO MODERNA
import AdminBackupsPage from './admin/AdminBackupsPage'
import SuperAdminPage from './admin/SuperAdminPage'
import DebugPermissions from '../components/DebugPermissions'
import PermissionsDebugger from '../components/PermissionsDebugger'
import { ActivateUsersPage } from '../modules/admin/pages/ActivateUsersPage'

type ViewMode = 'dashboard' | 'usuarios' | 'permissoes' | 'backup' | 'super-admin' | 'debug' | 'permissions-debug' | 'ativar-usuarios'

function AdministracaoContent() {
  const [viewMode, setViewMode] = useState<ViewMode>('dashboard')
  const { isSuperAdmin } = usePermissions()

  // Escutar eventos de navegação do AdminDashboard
  useEffect(() => {
    const handleNavigate = (event: CustomEvent<{ view: string }>) => {
      setViewMode(event.detail.view as ViewMode);
    };

    window.addEventListener('admin-navigate', handleNavigate as EventListener);
    return () => {
      window.removeEventListener('admin-navigate', handleNavigate as EventListener);
    };
  }, []);

  const baseMenuItems = [
    {
      id: 'dashboard' as ViewMode,
      label: 'Dashboard',
      icon: BarChart3,
      description: 'Visão geral do sistema'
    },
    {
      id: 'usuarios' as ViewMode,
      label: 'Usuários',
      icon: Users,
      description: 'Gerenciar usuários do sistema'
    },
    {
      id: 'ativar-usuarios' as ViewMode,
      label: 'Ativar Usuários',
      icon: UserCheck,
      description: 'Criar e ativar novos funcionários com senha local'
    },
    {
      id: 'permissoes' as ViewMode,
      label: 'Funções & Permissões',
      icon: Shield,
      description: 'Configurar roles e permissões'
    },
    {
      id: 'backup' as ViewMode,
      label: 'Backups',
      icon: Database,
      description: 'Sistema de backup e restore'
    }
    // Debug buttons hidden - removed from baseMenuItems
    // {
    //   id: 'permissions-debug' as ViewMode,
    //   label: 'Debug Permissões',
    //   icon: Bug,
    //   description: 'Diagnóstico de permissões e acesso'
    // }
  ]

  // Adicionar aba Super Admin se o usuário for super admin
  const menuItems = isSuperAdmin ? [
    {
      id: 'super-admin' as ViewMode,
      label: 'Super Admin',
      icon: Crown,
      description: 'Gerenciar todas as empresas'
    },
    ...baseMenuItems
    // Debug button hidden - removed from super admin menuItems  
    // {
    //   id: 'debug' as ViewMode,
    //   label: '🔍 Debug',
    //   icon: Settings,
    //   description: 'Debug de permissões'
    // }
  ] : [
    ...baseMenuItems
    // Debug button hidden - removed from menuItems
    // {
    //   id: 'debug' as ViewMode,
    //   label: '🔍 Debug',
    //   icon: Settings,
    //   description: 'Debug de permissões'
    // }
  ]

  const renderContent = () => {
    switch (viewMode) {
      case 'super-admin':
        return <SuperAdminPage />
      case 'dashboard':
        return <AdminDashboard />
      case 'usuarios':
        return <AdminUsersPage />
      case 'ativar-usuarios':
        return <ActivateUsersPage />
      case 'permissoes':
        return <AdminRolesPermissionsPageNew />
      case 'backup':
        return <AdminBackupsPage />
      case 'debug':
        return <DebugPermissions />
      case 'permissions-debug':
        return <PermissionsDebugger />
      default:
        return <AdminDashboard />
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Administração do Sistema</h1>
            <p className="text-gray-600 mt-1">
              Como administrador da empresa, gerencie funcionários, permissões e configurações
            </p>
          </div>
        </div>

        {/* Navegação por abas */}
        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex flex-wrap gap-2">
            {menuItems.map((item) => {
              const Icon = item.icon
              return (
                <button
                  key={item.id}
                  onClick={() => setViewMode(item.id)}
                  className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all duration-200 shadow-sm hover:shadow-md transform hover:scale-105 ${
                    item.id === 'dashboard' 
                      ? viewMode === item.id 
                        ? 'bg-gradient-to-r from-blue-600 to-blue-700 text-white shadow-lg' 
                        : 'bg-gradient-to-r from-blue-100 to-blue-200 text-blue-800 hover:from-blue-200 hover:to-blue-300'
                    : item.id === 'usuarios'
                      ? viewMode === item.id
                        ? 'bg-gradient-to-r from-green-600 to-green-700 text-white shadow-lg'
                        : 'bg-gradient-to-r from-green-100 to-green-200 text-green-800 hover:from-green-200 hover:to-green-300'
                    : item.id === 'ativar-usuarios'
                      ? viewMode === item.id
                        ? 'bg-gradient-to-r from-emerald-600 to-emerald-700 text-white shadow-lg'
                        : 'bg-gradient-to-r from-emerald-100 to-emerald-200 text-emerald-800 hover:from-emerald-200 hover:to-emerald-300'
                    : item.id === 'permissoes'
                      ? viewMode === item.id
                        ? 'bg-gradient-to-r from-purple-600 to-purple-700 text-white shadow-lg'
                        : 'bg-gradient-to-r from-purple-100 to-purple-200 text-purple-800 hover:from-purple-200 hover:to-purple-300'
                    : item.id === 'backup'
                      ? viewMode === item.id
                        ? 'bg-gradient-to-r from-orange-600 to-orange-700 text-white shadow-lg'
                        : 'bg-gradient-to-r from-orange-100 to-orange-200 text-orange-800 hover:from-orange-200 hover:to-orange-300'
                    : item.id === 'super-admin'
                      ? viewMode === item.id
                        ? 'bg-gradient-to-r from-red-600 to-red-700 text-white shadow-lg'
                        : 'bg-gradient-to-r from-red-100 to-red-200 text-red-800 hover:from-red-200 hover:to-red-300'
                    : viewMode === item.id
                      ? 'bg-gradient-to-r from-gray-600 to-gray-700 text-white shadow-lg'
                      : 'bg-gradient-to-r from-gray-100 to-gray-200 text-gray-800 hover:from-gray-200 hover:to-gray-300'
                  }`}
                >
                  <Icon className="w-4 h-4" />
                  {item.label}
                </button>
              )
            })}
          </div>
        </div>

        {/* Conteúdo baseado na view selecionada */}
        <div className="animate-in fade-in duration-300">
          {renderContent()}
        </div>
      </div>
    </div>
  )
}

export function AdministracaoPage() {
  return (
    <PermissionsProvider>
      <AdministracaoContent />
    </PermissionsProvider>
  )
}