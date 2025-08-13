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
  Crown,
  Shield,
  DollarSign
} from 'lucide-react'
import { useAuth } from '../auth'
import { useSubscription } from '../../hooks/useSubscription'
import { useUserHierarchy } from '../../hooks/useUserHierarchy'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'
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
      color: 'primary',
      path: '/vendas'
    },
    {
      name: 'clients',
      title: 'Clientes',
      description: 'Gerenciar cadastro de clientes',
      icon: Users,
      color: 'secondary',
      path: '/clientes'
    },
    {
      name: 'products',
      title: 'Produtos',
      description: 'Controle de estoque e produtos',
      icon: Package,
      color: 'success',
      path: '/produtos'
    },
    {
      name: 'cashier',
      title: 'Caixa',
      description: 'Controle de caixa e movimento',
      icon: DollarSign,
      color: 'warning',
      path: '/caixa'
    },
    {
      name: 'orders',
      title: 'OS - Ordem de Serviço',
      description: 'Gestão de ordens de serviço',
      icon: FileText,
      color: 'danger',
      path: '/ordens-servico'
    },
    {
      name: 'reports',
      title: 'Relatórios',
      description: 'Análises e relatórios de vendas',
      icon: BarChart3,
      color: 'info',
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
      color: 'danger',
      path: '/configuracoes'
    })
  }
  
  // Owner sempre tem acesso às configurações de empresa
  if (isOwner()) {
    availableModules.push({
      name: 'settings',
      title: 'Configurações da Empresa',
      description: 'Gerenciar funcionários e permissões do sistema',
      icon: Settings,
      color: 'info',
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

  const getColorClasses = (color: string) => {
    const colors = {
      primary: 'bg-primary-500 hover:bg-primary-600',
      secondary: 'bg-secondary-500 hover:bg-secondary-600',
      success: 'bg-green-500 hover:bg-green-600',
      warning: 'bg-yellow-500 hover:bg-yellow-600',
      danger: 'bg-red-500 hover:bg-red-600',
      info: 'bg-blue-500 hover:bg-blue-600'
    }
    return colors[color as keyof typeof colors] || 'bg-gray-500 hover:bg-gray-600'
  }

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
    <div className="min-h-screen bg-gray-50">
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

      {/* Main Content - Layout responsivo limpo */}
      <main className="relative max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8 min-h-[calc(100vh-64px)] flex flex-col">
        {/* Subscription Status */}
        {!isAdmin() && (
          <div className="mb-6 flex-shrink-0">
            <SubscriptionStatus />
            <SubscriptionCountdown />
          </div>
        )}

        {/* Modules Grid - Layout responsivo e limpo */}
        <div className="flex-1 flex flex-col space-y-8">
          {/* Módulos Principais - Cards responsivos que crescem com a tela */}
          {mainModules.length > 0 && (
            <div className="w-full">
              <h2 className="text-lg sm:text-xl lg:text-2xl xl:text-3xl 2xl:text-4xl 3xl:text-5xl font-semibold text-gray-800 mb-4 sm:mb-6 lg:mb-8 xl:mb-10 2xl:mb-12 3xl:mb-16 px-1">📋 Módulos Principais</h2>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-3 2xl:grid-cols-3 3xl:grid-cols-3 gap-4 sm:gap-6 lg:gap-8 xl:gap-10 2xl:gap-12 3xl:gap-16">
                {mainModules.map((module) => {
                  const Icon = module.icon
                  return (
                    <Card 
                      key={module.name}
                      className="group hover:shadow-2xl transition-all duration-300 hover:-translate-y-3 cursor-pointer border-0 shadow-lg"
                    >
                      <Link to={module.path} className="block p-6 sm:p-8 lg:p-10 xl:p-12 2xl:p-16 3xl:p-20 h-full">
                        <div className="flex flex-col items-center text-center space-y-4 sm:space-y-6 lg:space-y-8 xl:space-y-10 2xl:space-y-12 3xl:space-y-16 h-full justify-center min-h-[180px] sm:min-h-[220px] lg:min-h-[280px] xl:min-h-[320px] 2xl:min-h-[400px] 3xl:min-h-[500px]">
                          <div className={`w-20 h-20 sm:w-24 sm:h-24 lg:w-32 lg:h-32 xl:w-40 xl:h-40 2xl:w-46 2xl:h-46 3xl:w-56 3xl:h-56 ${getColorClasses(module.color)} rounded-2xl lg:rounded-3xl xl:rounded-3xl 2xl:rounded-[2rem] 3xl:rounded-[3rem] flex items-center justify-center transition-transform group-hover:scale-110 shadow-xl flex-shrink-0`}>
                            <Icon className="w-10 h-10 sm:w-12 sm:h-12 lg:w-16 lg:h-16 xl:w-20 xl:h-20 2xl:w-22 2xl:h-22 3xl:w-28 3xl:h-28 text-white" />
                          </div>
                          <div className="flex-1 flex flex-col justify-center">
                            <h3 className="text-xl sm:text-2xl lg:text-3xl xl:text-4xl 2xl:text-5xl 3xl:text-6xl font-bold text-gray-900 group-hover:text-gray-700 transition-colors leading-tight mb-2 lg:mb-4 xl:mb-6 2xl:mb-8">
                              {module.title}
                            </h3>
                            <p className="text-sm sm:text-base lg:text-lg xl:text-xl 2xl:text-2xl 3xl:text-3xl text-gray-600 leading-relaxed">
                              {module.description}
                            </p>
                          </div>
                        </div>
                      </Link>
                    </Card>
                  )
                })}
              </div>
            </div>
          )}

          {/* Módulos Secundários - Grid responsivo que ocupa mais espaço em telas maiores */}
          {secondaryModules.length > 0 && (
            <div className="w-full flex-1">
              <h2 className="text-lg sm:text-xl lg:text-2xl xl:text-3xl 2xl:text-4xl 3xl:text-5xl font-semibold text-gray-800 mb-4 sm:mb-6 lg:mb-8 xl:mb-10 2xl:mb-12 px-1">⚙️ Outros Módulos</h2>
              <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 2xl:grid-cols-8 3xl:grid-cols-10 gap-4 sm:gap-6 lg:gap-8 xl:gap-10">
                {secondaryModules.map((module) => {
                  const Icon = module.icon
                  return (
                    <Card 
                      key={module.name}
                      className="group hover:shadow-xl transition-all duration-300 hover:-translate-y-2 cursor-pointer border-0 shadow-lg"
                    >
                      <Link to={module.path} className="block p-4 sm:p-6 lg:p-8 xl:p-10 2xl:p-12 h-full">
                        <div className="flex flex-col items-center text-center space-y-3 sm:space-y-4 lg:space-y-6 xl:space-y-8 h-full justify-center min-h-[140px] sm:min-h-[160px] lg:min-h-[200px] xl:min-h-[240px] 2xl:min-h-[300px] 3xl:min-h-[360px]">
                          <div className={`w-14 h-14 sm:w-16 sm:h-16 lg:w-20 lg:h-20 xl:w-24 xl:h-24 2xl:w-30 2xl:h-30 3xl:w-38 3xl:h-38 ${getColorClasses(module.color)} rounded-xl lg:rounded-2xl xl:rounded-2xl 2xl:rounded-3xl flex items-center justify-center transition-transform group-hover:scale-110 shadow-lg flex-shrink-0`}>
                            <Icon className="w-7 h-7 sm:w-8 sm:h-8 lg:w-10 lg:h-10 xl:w-12 xl:h-12 2xl:w-16 2xl:h-16 3xl:w-20 3xl:h-20 text-white" />
                          </div>
                          <div className="min-h-0 flex-1 flex flex-col justify-center">
                            <h3 className="text-sm sm:text-base lg:text-lg xl:text-xl 2xl:text-2xl 3xl:text-3xl font-semibold text-gray-900 group-hover:text-gray-700 transition-colors leading-tight mb-1 lg:mb-2 xl:mb-3 line-clamp-2">
                              {module.title}
                            </h3>
                            <p className="text-xs sm:text-sm lg:text-base xl:text-lg 2xl:text-xl text-gray-600 leading-tight line-clamp-2 hidden sm:block lg:hidden xl:block">
                              {module.description}
                            </p>
                          </div>
                        </div>
                      </Link>
                    </Card>
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
