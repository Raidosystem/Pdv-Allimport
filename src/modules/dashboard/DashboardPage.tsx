import { Link } from 'react-router-dom'
import { 
  ShoppingCart, 
  Users, 
  Package, 
  CreditCard, 
  BarChart3, 
  FileText,
  LogOut,
  User
} from 'lucide-react'
import { useAuth } from '../auth'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'

export function DashboardPage() {
  const { user, signOut } = useAuth()

  const handleSignOut = async () => {
    await signOut()
  }

  const modules = [
    {
      title: 'Vendas',
      description: 'Realizar vendas e emitir cupons fiscais',
      icon: ShoppingCart,
      color: 'primary',
      path: '/vendas',
      comingSoon: true
    },
    {
      title: 'Clientes',
      description: 'Gerenciar cadastro de clientes',
      icon: Users,
      color: 'secondary',
      path: '/clientes',
      comingSoon: true
    },
    {
      title: 'Produtos',
      description: 'Controle de estoque e produtos',
      icon: Package,
      color: 'success',
      path: '/produtos',
      comingSoon: true
    },
    {
      title: 'Caixa',
      description: 'Controle financeiro e fechamento',
      icon: CreditCard,
      color: 'warning',
      path: '/caixa',
      comingSoon: true
    },
    {
      title: 'Relatórios',
      description: 'Análises e relatórios de vendas',
      icon: BarChart3,
      color: 'info',
      path: '/relatorios',
      comingSoon: true
    },
    {
      title: 'OS - Ordem de Serviço',
      description: 'Gestão de ordens de serviço',
      icon: FileText,
      color: 'danger',
      path: '/os',
      comingSoon: true
    }
  ]

  const getColorClasses = (color: string) => {
    const colors = {
      primary: 'bg-primary-500 hover:bg-primary-600',
      secondary: 'bg-secondary-500 hover:bg-secondary-600',
      success: 'bg-green-500 hover:bg-green-600',
      warning: 'bg-yellow-500 hover:bg-yellow-600',
      info: 'bg-blue-500 hover:bg-blue-600',
      danger: 'bg-red-500 hover:bg-red-600'
    }
    return colors[color as keyof typeof colors] || colors.primary
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-white via-primary-50 to-primary-100">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-secondary-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-primary-500 rounded-xl flex items-center justify-center">
                <ShoppingCart className="w-6 h-6 text-white" />
              </div>
              <h1 className="text-2xl font-bold text-secondary-900">
                PDV Import
              </h1>
            </div>
            
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <User className="w-5 h-5 text-secondary-500" />
                <span className="text-sm text-secondary-700">
                  {user?.email}
                </span>
              </div>
              
              <Button 
                variant="outline" 
                size="sm" 
                onClick={handleSignOut}
                className="flex items-center space-x-2"
              >
                <LogOut className="w-4 h-4" />
                <span>Sair</span>
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        {/* Welcome Section */}
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-secondary-900 mb-2">
            Bem-vindo ao PDV Import
          </h2>
          <p className="text-lg text-secondary-600">
            Selecione um módulo para começar a trabalhar
          </p>
        </div>

        {/* Modules Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {modules.map((module) => {
            const Icon = module.icon
            const colorClasses = getColorClasses(module.color)
            
            return (
              <Card 
                key={module.title}
                className="relative overflow-hidden group hover:shadow-xl transition-all duration-300"
              >
                {module.comingSoon && (
                  <div className="absolute top-3 right-3 bg-warning-100 text-warning-800 px-2 py-1 rounded-full text-xs font-medium">
                    Em breve
                  </div>
                )}
                
                <div className="p-6">
                  <div className={`w-12 h-12 ${colorClasses} rounded-xl flex items-center justify-center mb-4 transition-all duration-300 group-hover:scale-110`}>
                    <Icon className="w-6 h-6 text-white" />
                  </div>
                  
                  <h3 className="text-xl font-semibold text-secondary-900 mb-2">
                    {module.title}
                  </h3>
                  
                  <p className="text-secondary-600 mb-4">
                    {module.description}
                  </p>
                  
                  {module.comingSoon ? (
                    <Button 
                      variant="outline" 
                      disabled 
                      className="w-full"
                    >
                      Em desenvolvimento
                    </Button>
                  ) : (
                    <Link to={module.path}>
                      <Button className="w-full">
                        Acessar
                      </Button>
                    </Link>
                  )}
                </div>
              </Card>
            )
          })}
        </div>

        {/* Quick Stats */}
        <div className="mt-12 grid grid-cols-1 md:grid-cols-4 gap-6">
          <Card className="text-center">
            <div className="p-6">
              <div className="text-3xl font-bold text-primary-500 mb-2">0</div>
              <div className="text-secondary-600">Vendas Hoje</div>
            </div>
          </Card>
          
          <Card className="text-center">
            <div className="p-6">
              <div className="text-3xl font-bold text-green-500 mb-2">R$ 0,00</div>
              <div className="text-secondary-600">Faturamento</div>
            </div>
          </Card>
          
          <Card className="text-center">
            <div className="p-6">
              <div className="text-3xl font-bold text-blue-500 mb-2">0</div>
              <div className="text-secondary-600">Produtos</div>
            </div>
          </Card>
          
          <Card className="text-center">
            <div className="p-6">
              <div className="text-3xl font-bold text-yellow-500 mb-2">0</div>
              <div className="text-secondary-600">Clientes</div>
            </div>
          </Card>
        </div>
      </main>
    </div>
  )
}
