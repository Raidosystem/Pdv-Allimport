import { useState } from 'react'
import { Users, Shield, Database, BarChart3, Crown, UserPlus, UserCheck } from 'lucide-react'
import { PermissionsProvider, usePermissions } from '../hooks/usePermissions'
import AdminDashboard from './admin/AdminDashboard'
import AdminUsersPage from './admin/AdminUsersPage'
import AdminConvitesPage from './admin/AdminConvitesPage'
import AdminRolesPermissionsPage from './admin/AdminRolesPermissionsPage'
import AdminBackupsPage from './admin/AdminBackupsPage'
import SuperAdminPage from './admin/SuperAdminPage'
import DebugPermissions from '../components/DebugPermissions'
import PermissionsDebugger from '../components/PermissionsDebugger'
import { ActivateUsersPage } from '../modules/admin/pages/ActivateUsersPage'

type ViewMode = 'dashboard' | 'usuarios' | 'convites' | 'permissoes' | 'backup' | 'super-admin' | 'debug' | 'permissions-debug' | 'ativar-usuarios'

function AdministracaoContent() {
  const [viewMode, setViewMode] = useState<ViewMode>('dashboard')
  const { isSuperAdmin } = usePermissions()

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
      id: 'convites' as ViewMode,
      label: 'Convites',
      icon: UserPlus,
      description: 'Convidar novos usuários'
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
      case 'convites':
        return <AdminConvitesPage />
      case 'permissoes':
        return <AdminRolesPermissionsPage />
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
                  className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                    viewMode === item.id
                      ? 'bg-blue-600 text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
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