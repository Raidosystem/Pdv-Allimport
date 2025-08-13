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

      {/* Main Content - Layout totalmente responsivo para qualquer tela */}
      <main className="relative max-w-full mx-auto py-4 sm:py-6 lg:py-8 px-2 sm:px-4 lg:px-6 xl:px-8 2xl:px-12 3xl:px-16 min-h-[calc(100vh-64px)] flex flex-col">
        {/* Subscription Status */}
        {!isAdmin() && (
          <div className="mb-4 sm:mb-6 flex-shrink-0">
            <SubscriptionStatus />
            <SubscriptionCountdown />
          </div>
        )}

        {/* Modules Grid - Sistema responsivo completo para todas as telas */}
        <div className="flex-1 flex flex-col space-y-4 sm:space-y-6 lg:space-y-8">
          {/* Módulos Principais - Sistema responsivo inteligente */}
          {mainModules.length > 0 && (
            <div className="w-full">
              <h2 className="responsive-title-main text-gray-800 mb-3 sm:mb-4 lg:mb-6 px-1">📋 Módulos Principais</h2>
              <div className="responsive-grid-main">
                {mainModules.map((module) => {
                  const Icon = module.icon
                  return (
                    <Card 
                      key={module.name}
                      className="group hover:shadow-xl transition-all duration-300 hover:-translate-y-2 cursor-pointer border-0 shadow-lg h-full"
                    >
                      <Link to={module.path} className="block h-full">
                        <div className="responsive-card-main flex flex-col items-center text-center space-y-3 sm:space-y-4 lg:space-y-6 h-full justify-center">
                          <div className={`responsive-icon-main ${getColorClasses(module.color)} rounded-2xl lg:rounded-3xl flex items-center justify-center transition-transform group-hover:scale-110 shadow-xl flex-shrink-0`}>
                            <Icon className="w-1/2 h-1/2 text-white" />
                          </div>
                          <div className="flex-1 flex flex-col justify-center">
                            <h3 className="responsive-title-main text-gray-900 group-hover:text-gray-700 transition-colors leading-tight mb-2">
                              {module.title}
                            </h3>
                            <p className="responsive-text leading-relaxed">
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

          {/* Módulos Secundários - Grid responsivo que aproveita toda a tela */}
          {secondaryModules.length > 0 && (
            <div className="w-full flex-1">
              <h2 className="responsive-title-main text-gray-800 mb-3 sm:mb-4 lg:mb-6 px-1">⚙️ Outros Módulos</h2>
              <div className="responsive-grid-secondary">
                {secondaryModules.map((module) => {
                  const Icon = module.icon
                  return (
                    <Card 
                      key={module.name}
                      className="group hover:shadow-xl transition-all duration-300 hover:-translate-y-2 cursor-pointer border-0 shadow-lg h-full"
                    >
                      <Link to={module.path} className="block h-full">
                        <div className="responsive-card-secondary flex flex-col items-center text-center space-y-2 sm:space-y-3 lg:space-y-4 h-full justify-center">
                          <div className={`responsive-icon-secondary ${getColorClasses(module.color)} rounded-xl lg:rounded-2xl flex items-center justify-center transition-transform group-hover:scale-110 shadow-lg flex-shrink-0`}>
                            <Icon className="w-1/2 h-1/2 text-white" />
                          </div>
                          <div className="min-h-0 flex-1 flex flex-col justify-center">
                            <h3 className="responsive-title-secondary text-gray-900 group-hover:text-gray-700 transition-colors leading-tight mb-1 line-clamp-2">
                              {module.title}
                            </h3>
                            <p className="text-xs sm:text-sm lg:text-base text-gray-600 leading-tight line-clamp-2 hidden sm:block lg:hidden xl:block">
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
