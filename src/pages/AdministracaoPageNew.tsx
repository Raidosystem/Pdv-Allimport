import { useState, useEffect } from 'react'
import { Users, Shield, BarChart3, Crown, UserCheck, Building, Check, Settings } from 'lucide-react'
import { Link } from 'react-router-dom'
import { PermissionsProvider, usePermissions } from '../hooks/usePermissions'
import { useEmpresaSettings } from '../hooks/useEmpresaSettings'
import { useSubscription } from '../hooks/useSubscription'
import { EmpresaView } from '../components/EmpresaView'
import toast from 'react-hot-toast'
import AdminDashboard from './admin/AdminDashboard'
import { ConfiguracaoModulosPage } from './admin/ConfiguracaoModulosPage'
import AdminUsersPage from './admin/AdminUsersPage'
// import AdminConvitesPage from './admin/AdminConvitesPage' // REMOVIDO - Sistema automático
import AdminRolesPermissionsPageNew from './admin/AdminRolesPermissionsPageNew' // NOVA VERSÃO MODERNA
import SuperAdminPage from './admin/SuperAdminPage'
import DebugPermissions from '../components/DebugPermissions'
import PermissionsDebugger from '../components/PermissionsDebugger'
import { ActivateUsersPage } from '../modules/admin/pages/ActivateUsersPage'

type ViewMode = 'dashboard' | 'usuarios' | 'permissoes' | 'super-admin' | 'debug' | 'permissions-debug' | 'ativar-usuarios' | 'empresa' | 'modulos' | 'assinatura'

function AdministracaoContent() {
  const [viewMode, setViewMode] = useState<ViewMode>('dashboard')
  const { isSuperAdmin } = usePermissions()
  const { settings: empresaSettings, loading, uploading: uploadingLogo, saveSettings, uploadLogo } = useEmpresaSettings()
  const { isActive, isInTrial, daysRemaining } = useSubscription()
  
  // Estado local para edição
  const [configEmpresa, setConfigEmpresa] = useState(empresaSettings)
  const [unsavedChanges, setUnsavedChanges] = useState(false)

  // Atualizar configEmpresa quando empresaSettings mudar
  useEffect(() => {
    setConfigEmpresa(empresaSettings)
  }, [empresaSettings])

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

  // Handler para mudanças na empresa
  const handleEmpresaChange = (field: keyof typeof configEmpresa, value: string) => {
    setConfigEmpresa(prev => ({ ...prev, [field]: value }))
    setUnsavedChanges(true)
  }

  // Handler para upload de logo
  const handleLogoUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      const result = await uploadLogo(file)
      if (result.success && result.url) {
        setConfigEmpresa(prev => ({ ...prev, logo: result.url }))
        toast.success('Logo enviado com sucesso!')
        setUnsavedChanges(true)
      } else {
        toast.error(result.error || 'Erro ao enviar logo')
      }
    }
  }

  // Handler para salvar
  const handleSave = async () => {
    const result = await saveSettings(configEmpresa)
    if (result.success) {
      toast.success('Configurações salvas!')
      setUnsavedChanges(false)
    } else {
      toast.error('Erro ao salvar configurações')
    }
  }

  // Componente de visualização de Empresa
  const EmpresaViewAdmin = () => (
    <EmpresaView
      configEmpresa={configEmpresa}
      loading={loading}
      uploadingLogo={uploadingLogo}
      unsavedChanges={unsavedChanges}
      onEmpresaChange={handleEmpresaChange}
      onLogoUpload={handleLogoUpload}
      onSave={handleSave}
    />
  );

  // Componente de visualização de Assinatura
  const AssinaturaViewAdmin = () => {
    return (
      <div className="bg-white p-6 rounded-lg shadow-sm">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-lg font-semibold text-gray-900">Gerenciar Assinatura</h3>
            <p className="text-gray-600 mt-1">Controle sua assinatura e pagamentos</p>
          </div>
        </div>

        <div className="space-y-6">
          {/* Status da assinatura */}
          <div className="p-4 bg-gradient-to-r from-yellow-50 to-orange-50 border border-yellow-200 rounded-lg">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-yellow-500 rounded-lg flex items-center justify-center">
                  <Crown className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h4 className="font-semibold text-gray-900">Status da Assinatura</h4>
                  <p className="text-sm text-gray-600">
                    {isActive 
                      ? `Assinatura ativa${isInTrial ? ` (Trial: ${daysRemaining} dias restantes)` : ''}`
                      : 'Assinatura inativa - Assine agora'
                    }
                  </p>
                </div>
              </div>
              <div className="flex gap-3">
                <Link to="/assinatura">
                  <button className="px-4 py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-lg flex items-center gap-2 transition-colors">
                    <Crown className="w-4 h-4" />
                    {isActive ? 'Renovar Antecipado' : 'Assinar Agora'}
                  </button>
                </Link>
              </div>
            </div>
          </div>

          {/* Informações da assinatura */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="p-4 bg-gray-50 rounded-lg">
              <h4 className="font-medium text-gray-900 mb-2">Plano Atual</h4>
              <p className="text-sm text-gray-600">
                {isActive ? 'Plano Premium' : 'Sem plano ativo'}
              </p>
              <p className="text-xs text-gray-500 mt-1">
                R$ 59,90/mês
              </p>
            </div>

            <div className="p-4 bg-gray-50 rounded-lg">
              <h4 className="font-medium text-gray-900 mb-2">Próximo Vencimento</h4>
              <p className="text-sm text-gray-600">
                {isActive 
                  ? `${daysRemaining} dias restantes`
                  : 'Nenhum plano ativo'
                }
              </p>
              <p className="text-xs text-gray-500 mt-1">
                Renovação automática disponível
              </p>
            </div>
          </div>

          {/* Benefícios */}
          <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <h4 className="font-medium text-gray-900 mb-3">Benefícios da Assinatura</h4>
            <ul className="space-y-2 text-sm text-gray-600">
              <li className="flex items-center gap-2">
                <Check className="w-4 h-4 text-green-500" />
                Acesso ilimitado a todas as funcionalidades
              </li>
              <li className="flex items-center gap-2">
                <Check className="w-4 h-4 text-green-500" />
                Backup automático diário
              </li>
              <li className="flex items-center gap-2">
                <Check className="w-4 h-4 text-green-500" />
                Suporte técnico prioritário
              </li>
              <li className="flex items-center gap-2">
                <Check className="w-4 h-4 text-green-500" />
                Atualizações automáticas
              </li>
            </ul>
          </div>
        </div>
      </div>
    );
  };

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
      id: 'empresa' as ViewMode,
      label: 'Empresa',
      icon: Building,
      description: 'Configurar dados da empresa'
    },
    {
      id: 'modulos' as ViewMode,
      label: 'Módulos do Sistema',
      icon: Settings,
      description: 'Ativar/desativar módulos (OS, Vendas, etc)'
    },
    {
      id: 'assinatura' as ViewMode,
      label: 'Assinatura',
      icon: Crown,
      description: 'Gerenciar plano e assinatura'
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
      case 'empresa':
        return <EmpresaViewAdmin />
      case 'modulos':
        return <ConfiguracaoModulosPage />
      case 'assinatura':
        return <AssinaturaViewAdmin />
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
                    : item.id === 'empresa'
                      ? viewMode === item.id
                        ? 'bg-gradient-to-r from-teal-600 to-teal-700 text-white shadow-lg'
                        : 'bg-gradient-to-r from-teal-100 to-teal-200 text-teal-800 hover:from-teal-200 hover:to-teal-300'
                    : item.id === 'modulos'
                      ? viewMode === item.id
                        ? 'bg-gradient-to-r from-indigo-600 to-indigo-700 text-white shadow-lg'
                        : 'bg-gradient-to-r from-indigo-100 to-indigo-200 text-indigo-800 hover:from-indigo-200 hover:to-indigo-300'
                    : item.id === 'assinatura'
                      ? viewMode === item.id
                        ? 'bg-gradient-to-r from-yellow-600 to-yellow-700 text-white shadow-lg'
                        : 'bg-gradient-to-r from-yellow-100 to-yellow-200 text-yellow-800 hover:from-yellow-200 hover:to-yellow-300'
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