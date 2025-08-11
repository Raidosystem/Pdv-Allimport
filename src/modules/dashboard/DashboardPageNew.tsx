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

  // Verificar se é a conta principal (que comprou o sistema)
  const isMainAccount = user?.email && (
    user.email.endsWith('@pdvallimport.com') ||
    user.email === 'novaradiosystem@outlook.com' ||
    user.email === 'teste@teste.com'
  )

  // Obter módulos visíveis baseado nas permissões
  const visibleModules = getVisibleModules()
  
  // Se for a conta principal, tem acesso a todos os módulos
  let availableModules
  if (isMainAccount) {
    // Conta principal tem acesso total a todos os módulos
    availableModules = [...allPossibleModules]
  } else {
    // Filtrar módulos que o usuário pode ver baseado nas permissões
    availableModules = allPossibleModules.filter(module => 
      visibleModules.some(visible => visible.name === module.name)
    )
  }

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
  
  // Owner OU conta principal sempre têm acesso às configurações de empresa
  if (isOwner() || isMainAccount) {
    availableModules.push({
      name: 'settings',
      title: 'Configurações da Empresa',
      description: 'Gerenciar funcionários e permissões do sistema',
      icon: Settings,
      color: 'info',
      path: '/configuracoes-empresa'
    })
  }

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
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-primary-600 rounded-xl flex items-center justify-center mr-3">
                <ShoppingCart className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">PDV Allimport</h1>
                <p className="text-sm text-gray-600">Sistema de Ponto de Venda</p>
              </div>
            </div>
            
            <div className="flex items-center space-x-4">
              {/* User info */}
              <div className="flex items-center space-x-3">
                <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center">
                  <User className="w-5 h-5 text-gray-600" />
                </div>
                <div className="hidden sm:block">
                  <p className="text-sm font-medium text-gray-900">{user?.email}</p>
                  <p className="text-xs text-gray-600">
                    {isAdmin() ? 'Administrador' : isOwner() ? 'Proprietário' : 'Funcionário'}
                  </p>
                </div>
              </div>

              {/* Subscription button for non-active users */}
              {!isActive && !isAdmin() && (
                <Link to="/assinatura">
                  <Button variant="outline" className="gap-2 border-yellow-300 text-yellow-700 hover:bg-yellow-50">
                    <Crown className="w-4 h-4" />
                    <span className="hidden sm:inline">Assinatura</span>
                  </Button>
                </Link>
              )}

              {/* Logout */}
              <Button
                variant="outline"
                onClick={handleSignOut}
                className="flex items-center space-x-2 border-red-200 text-red-600 hover:bg-red-50 hover:border-red-300"
              >
                <LogOut className="w-5 h-5" />
                <span>Sair</span>
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Banner de Assinatura - só mostrar se não estiver ativa */}
      {!isActive && !isAdmin() && <SubscriptionBanner />}

      {/* Main Content */}
      <main className="relative max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        {/* Welcome Section */}
        <div className="text-center mb-12">
          <div className="w-20 h-20 bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-xl">
            <ShoppingCart className="w-10 h-10 text-white" />
          </div>
          <h2 className="text-3xl font-bold text-gray-900 mb-2">
            Bem-vindo ao seu PDV
          </h2>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            Sistema completo de ponto de venda com controle de estoque, vendas e muito mais.
          </p>
          
          {/* Subscription Status */}
          {!isAdmin() && (
            <div className="mt-6">
              <SubscriptionStatus />
              <SubscriptionCountdown />
            </div>
          )}
        </div>

        {/* Modules Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {availableModules.map((module) => {
            const Icon = module.icon
            return (
              <Card 
                key={module.name}
                className="group hover:shadow-lg transition-all duration-200 hover:-translate-y-1 cursor-pointer border-0 shadow-md"
              >
                <Link to={module.path} className="block p-6">
                  <div className="flex flex-col items-center text-center space-y-4">
                    <div className={`w-16 h-16 ${getColorClasses(module.color)} rounded-2xl flex items-center justify-center transition-transform group-hover:scale-110 shadow-lg`}>
                      <Icon className="w-8 h-8 text-white" />
                    </div>
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900 group-hover:text-gray-700 transition-colors">
                        {module.title}
                      </h3>
                      <p className="text-sm text-gray-600 mt-1">
                        {module.description}
                      </p>
                    </div>
                  </div>
                </Link>
              </Card>
            )
          })}
        </div>

        {/* Empty state: mostrar apenas para funcionário (não admin, não owner, não conta principal) */}
        {availableModules.length === 0 && !isAdmin() && !isOwner() && !isMainAccount && (
          <div className="text-center py-16">
            <div className="w-24 h-24 bg-gray-200 rounded-full flex items-center justify-center mx-auto mb-6">
              <Settings className="w-12 h-12 text-gray-400" />
            </div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              Nenhum módulo disponível
            </h3>
            <p className="text-gray-600 max-w-md mx-auto">
              Entre em contato com o administrador para liberar acesso aos módulos do sistema.
            </p>
          </div>
        )}

        {/* Help Section */}
        <div className="mt-16 bg-gradient-to-r from-primary-500 to-primary-600 rounded-2xl p-8 text-white">
          <div className="text-center">
            <h3 className="text-2xl font-bold mb-4">Precisa de ajuda?</h3>
            <p className="text-primary-100 mb-6 max-w-2xl mx-auto">
              Nossa equipe está pronta para ajudar você a aproveitar ao máximo seu sistema PDV.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Button 
                variant="outline" 
                className="bg-white text-primary-600 hover:bg-primary-50 border-white"
              >
                Central de Ajuda
              </Button>
              <Button 
                variant="outline" 
                className="bg-transparent text-white border-white hover:bg-white/10"
              >
                Falar com Suporte
              </Button>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}
