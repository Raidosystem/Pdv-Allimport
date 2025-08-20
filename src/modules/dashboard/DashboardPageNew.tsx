import { Link } from 'react-router-dom'
import { 
  ShoppingCart, 
  Users, 
  Package, 
  BarChart3, 
  FileText,
  LogOut,
  User,
  Settings,
  Shield,
  DollarSign,
  Crown
} from 'lucide-react'
import { useAuth } from '../auth'
import { useSubscription } from '../../hooks/useSubscription'
import { useUserHierarchy } from '../../hooks/useUserHierarchy'
import { Button } from '../../components/ui/Button'
import { SubscriptionStatus } from '../../components/subscription/SubscriptionStatus'
import { SubscriptionCountdown } from '../../components/subscription/SubscriptionCountdown'
import { SubscriptionBanner } from '../../components/subscription/SubscriptionBanner'

export function DashboardPage() {
  const { user, signOut } = useAuth()
  const { isActive } = useSubscription()
  const { getVisibleModules, isAdmin, isOwner, loading } = useUserHierarchy()

  const handleSignOut = async () => {
    await signOut()
  }

  // Definir todos os módulos possíveis
  const allPossibleModules = [
    {
      name: 'sales',
      title: 'Vendas',
      description: 'Realizar vendas e emitir cupons fiscais',
      icon: ShoppingCart,
      color: 'primary' as const,
      path: '/vendas'
    },
    {
      name: 'clients',
      title: 'Clientes',
      description: 'Gerenciar cadastro de clientes',
      icon: Users,
      color: 'secondary' as const,
      path: '/clientes'
    },
    {
      name: 'products',
      title: 'Produtos',
      description: 'Controle de estoque e produtos',
      icon: Package,
      color: 'success' as const,
      path: '/produtos'
    },
    {
      name: 'cashier',
      title: 'Caixa',
      description: 'Controle de caixa e movimento',
      icon: DollarSign,
      color: 'warning' as const,
      path: '/caixa'
    },
    {
      name: 'orders',
      title: 'OS - Ordem de Serviço',
      description: 'Gestão de ordens de serviço',
      icon: FileText,
      color: 'danger' as const,
      path: '/ordens-servico'
    },
    {
      name: 'reports',
      title: 'Relatórios',
      description: 'Análises e relatórios de vendas',
      icon: BarChart3,
      color: 'info' as const,
      path: '/relatorios'
    }
  ]

  // Obter módulos visíveis baseado nas permissões do useUserHierarchy
  const visibleModules = getVisibleModules()
  
  // Mapear módulos visíveis para os módulos disponíveis
  const availableModules = allPossibleModules.filter(module => 
    visibleModules.some(visible => visible.name === module.name)
  )

  // Adicionar módulos especiais baseado no tipo de usuário
  if (isAdmin()) {
    availableModules.push({
      name: 'admin',
      title: 'Administração',
      description: 'Backup, restore e administração do sistema',
      icon: Shield,
      color: 'danger' as const,
      path: '/configuracoes'
    })
  }
  
  // Owner sempre tem acesso às configurações de empresa
  // Garantir que usuários autenticados sempre vejam configurações da empresa
  if (user?.email) {
    availableModules.push({
      name: 'settings',
      title: 'Configurações da Empresa',
      description: 'Gerenciar funcionários e permissões do sistema',
      icon: Settings,
      color: 'info' as const,
      path: '/configuracoes-empresa'
    })
  }

  // Separar módulos principais dos secundários
  const mainModules = availableModules.filter(module => 
    ['sales', 'clients', 'orders'].includes(module.name)
  )
  
  const secondaryModules = availableModules.filter(module => 
    !['sales', 'clients', 'orders'].includes(module.name)
  )

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando permissões...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 overflow-x-hidden">
      {/* Header - Responsivo e consistente */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            {/* Logo e título */}
            <div className="flex items-center">
              <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-primary-600 rounded-xl flex items-center justify-center mr-3 flex-shrink-0">
                <ShoppingCart className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">PDV Allimport</h1>
                <p className="text-sm text-gray-600 hidden sm:block">Sistema de Ponto de Venda</p>
              </div>
            </div>
            
            {/* Actions */}
            <div className="flex items-center space-x-4">
              {/* User info */}
              <div className="hidden md:flex items-center space-x-3">
                <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center">
                  <User className="w-5 h-5 text-gray-600" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-900">{user?.email}</p>
                  <p className="text-xs text-gray-600">
                    {isAdmin() ? 'Admin' : isOwner() ? 'Proprietário' : 'Funcionário'}
                  </p>
                </div>
              </div>

              {/* User avatar apenas em mobile/tablet */}
              <div className="md:hidden w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center">
                <User className="w-5 h-5 text-gray-600" />
              </div>

              {/* Subscription button */}
              {!isActive && !isAdmin() && (
                <Link to="/assinatura">
                  <Button variant="outline" className="gap-2 border-yellow-300 text-yellow-700 hover:bg-yellow-50">
                    <Crown className="w-4 h-4" />
                    <span className="hidden sm:inline">Assinatura</span>
                  </Button>
                </Link>
              )}

              {/* Logout button */}
              <Button
                variant="outline"
                onClick={handleSignOut}
                className="flex items-center space-x-2 border-red-200 text-red-600 hover:bg-red-50 hover:border-red-300"
              >
                <LogOut className="w-5 h-5" />
                <span className="hidden sm:inline">Sair</span>
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Banner de Assinatura - só mostrar se não estiver ativa */}
      {!isActive && !isAdmin() && <SubscriptionBanner />}

      {/* Main Content - Layout simples baseado no exemplo do usuário */}
      <main className="relative w-full mx-auto py-6 px-4 sm:px-6 lg:px-8 min-h-[calc(100vh-64px)] flex flex-col max-h-screen overflow-y-auto">
        {/* Subscription Status */}
        {!isAdmin() && (
          <div className="mb-6 flex-shrink-0">
            <SubscriptionStatus />
            <SubscriptionCountdown />
          </div>
        )}

        {/* Modules Grid - Layout simples sem títulos */}
        <div className="flex-1 flex flex-col space-y-8 pb-4 min-h-0">
          {/* Módulos Principais - Cards maiores em linha */}
          {mainModules.length > 0 && (
            <div className="w-full">
              <div className="grid grid-cols-[repeat(auto-fit,minmax(280px,1fr))] gap-4 sm:gap-6 lg:grid-cols-3 lg:gap-8">
                {mainModules.map((module) => {
                  const Icon = module.icon
                  const colorClass = module.color ? 
                    ({
                      primary: 'bg-primary-500 hover:bg-primary-600',
                      secondary: 'bg-secondary-500 hover:bg-secondary-600',
                      success: 'bg-green-500 hover:bg-green-600',
                      warning: 'bg-yellow-500 hover:bg-yellow-600',
                      danger: 'bg-red-500 hover:bg-red-600',
                      info: 'bg-blue-500 hover:bg-blue-600'
                    }[module.color] || 'bg-gray-400 hover:bg-gray-500') : 'bg-gray-400 hover:bg-gray-500'

                  return (
                    <Link key={module.name} to={module.path}>
                      <div className="flex flex-col items-center justify-center gap-4 sm:gap-6 p-6 sm:p-8 lg:p-12 rounded-xl bg-white shadow hover:shadow-lg transition w-full h-64 sm:h-72 lg:h-80">
                        <div className={`w-20 h-20 sm:w-24 sm:h-24 lg:w-32 lg:h-32 ${colorClass} rounded-2xl flex items-center justify-center shadow-lg hover:scale-105 transition-transform`}>
                          <Icon className="w-10 h-10 sm:w-12 sm:h-12 lg:w-16 lg:h-16 text-white" />
                        </div>
                        <div className="text-center">
                          <h3 className="text-lg sm:text-xl lg:text-2xl font-bold text-gray-900 mb-2 lg:mb-3 line-clamp-1">
                            {module.title}
                          </h3>
                          <p className="text-sm sm:text-sm lg:text-base text-gray-600 line-clamp-2">
                            {module.description}
                          </p>
                        </div>
                      </div>
                    </Link>
                  )
                })}
              </div>
            </div>
          )}

          {/* Módulos Secundários - Cards menores em linha única */}
          {secondaryModules.length > 0 && (
            <div className="w-full">
              <div className="grid grid-cols-[repeat(auto-fit,minmax(160px,1fr))] gap-3 sm:gap-4 lg:grid-flow-col lg:auto-cols-fr lg:gap-6 overflow-x-auto">
                {secondaryModules.map((module) => {
                  const Icon = module.icon
                  const colorClass = module.color ? 
                    ({
                      primary: 'bg-primary-500 hover:bg-primary-600',
                      secondary: 'bg-secondary-500 hover:bg-secondary-600',
                      success: 'bg-green-500 hover:bg-green-600',
                      warning: 'bg-yellow-500 hover:bg-yellow-600',
                      danger: 'bg-red-500 hover:bg-red-600',
                      info: 'bg-blue-500 hover:bg-blue-600'
                    }[module.color] || 'bg-gray-400 hover:bg-gray-500') : 'bg-gray-400 hover:bg-gray-500'

                  return (
                    <Link key={module.name} to={module.path}>
                      <div className="flex flex-col items-center justify-center gap-3 sm:gap-4 p-4 sm:p-5 lg:p-6 rounded-xl bg-white shadow hover:shadow-md transition w-full lg:min-w-[220px] h-40 sm:h-44 lg:h-52">
                        <div className={`w-14 h-14 sm:w-16 sm:h-16 lg:w-20 lg:h-20 ${colorClass} rounded-xl flex items-center justify-center shadow-lg hover:scale-105 transition-transform`}>
                          <Icon className="w-7 h-7 sm:w-8 sm:h-8 lg:w-10 lg:h-10 text-white" />
                        </div>
                        <div className="text-center">
                          <h3 className="text-xs sm:text-sm lg:text-base font-semibold text-gray-900 line-clamp-2 leading-tight">
                            {module.title}
                          </h3>
                          <p className="text-xs sm:text-xs lg:text-sm text-gray-600 line-clamp-2 mt-1 lg:mt-2 hidden sm:block">
                            {module.description}
                          </p>
                        </div>
                      </div>
                    </Link>
                  )
                })}
              </div>
            </div>
          )}
        </div>

        {/* Empty state: mostrar apenas para funcionário (não admin, não owner) */}
        {availableModules.length === 0 && !isAdmin() && !isOwner() && (
          <div className="text-center py-8">
            <div className="w-16 h-16 bg-gray-200 rounded-full flex items-center justify-center mx-auto mb-4">
              <Settings className="w-8 h-8 text-gray-400" />
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">
              Nenhum módulo disponível
            </h3>
            <p className="text-sm text-gray-600 max-w-md mx-auto">
              Entre em contato com o administrador para liberar acesso aos módulos do sistema.
            </p>
          </div>
        )}
      </main>
    </div>
  )
}
