import { Link } from 'react-router-dom'
import { useState, useEffect } from 'react'
import { supabase } from '../../lib/supabase'
import { 
  ShoppingCart, 
  Users, 
  Package, 
  CreditCard, 
  BarChart3, 
  FileText,
  LogOut,
  User,
  Settings,
  Crown
} from 'lucide-react'
import { useAuth } from '../auth'
import { useSubscription } from '../../hooks/useSubscription'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'
import { SubscriptionStatus } from '../../components/subscription/SubscriptionStatus'
import { SubscriptionCountdown } from '../../components/subscription/SubscriptionCountdown'
import { SubscriptionBanner } from '../../components/subscription/SubscriptionBanner'

export function DashboardPage() {
  const { user, signOut } = useAuth()
  const { isActive } = useSubscription()
  const [empresaNome, setEmpresaNome] = useState<string>('RaVal pdv')

  // Carregar nome da empresa
  useEffect(() => {
    const loadEmpresaNome = async () => {
      if (!user?.id) return
      
      try {
        const { data, error } = await supabase
          .from('empresas')
          .select('nome')
          .eq('user_id', user.id)
          .single()
        
        if (data && data.nome) {
          setEmpresaNome(data.nome)
        }
      } catch (error) {
        console.error('Erro ao carregar nome da empresa:', error)
      }
    }
    
    loadEmpresaNome()
  }, [user])

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
      comingSoon: false
    },
    {
      title: 'Clientes',
      description: 'Gerenciar cadastro de clientes',
      icon: Users,
      color: 'secondary',
      path: '/clientes',
      comingSoon: false
    },
    {
      title: 'Produtos',
      description: 'Controle de estoque e produtos',
      icon: Package,
      color: 'success',
      path: '/produtos'
    },
    {
      title: 'Caixa',
      description: 'Controle financeiro e fechamento',
      icon: CreditCard,
      color: 'warning',
      path: '/caixa',
      comingSoon: false
    },
    {
      title: 'Relatórios',
      description: 'Análises e relatórios de vendas',
      icon: BarChart3,
      color: 'info',
      path: '/relatorios',
      comingSoon: false
    },
    {
      title: 'OS - Ordem de Serviço',
      description: 'Gestão de ordens de serviço',
      icon: FileText,
      color: 'danger',
      path: '/ordens-servico',
      comingSoon: false
    },
    {
      title: 'Administração',
      description: 'Gerenciar usuários e configurações',
      icon: Settings,
      color: 'info',
      path: '/configuracoes',
      comingSoon: false
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
    <div className="min-h-screen bg-gradient-to-br from-secondary-50 via-white to-primary-50">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary-500 rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-primary-400 rounded-full blur-3xl"></div>
      </div>

      {/* Header */}
      <header className="relative bg-white/90 backdrop-blur-sm shadow-lg border-b border-secondary-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-20">
            <div className="flex items-center space-x-4">
              <div className="w-14 h-14 bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl flex items-center justify-center shadow-lg">
                <ShoppingCart className="w-8 h-8 text-white" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-secondary-900">
                  {empresaNome}
                </h1>
                <p className="text-primary-600 font-medium">Painel de Controle</p>
              </div>
            </div>
            
            <div className="flex items-center space-x-6">
              {/* Status da Assinatura - só mostrar se não estiver ativa */}
              {!isActive && <SubscriptionStatus />}
              
              {/* Contador de dias da assinatura ativa */}
              {isActive && <SubscriptionCountdown />}
              
              <div className="flex items-center space-x-3 bg-secondary-50 rounded-xl px-4 py-2">
                <User className="w-6 h-6 text-primary-500" />
                <div>
                  <p className="text-sm text-secondary-500">Bem-vindo,</p>
                  <p className="font-medium text-secondary-900">
                    {user?.email}
                  </p>
                </div>
              </div>
              
              {/* Botão Assinatura - só mostrar se não estiver ativa */}
              {!isActive && (
                <Link to="/assinatura">
                  <Button 
                    variant="outline" 
                    className="flex items-center space-x-2 border-primary-200 text-primary-600 hover:bg-primary-50 hover:border-primary-300"
                  >
                    <Crown className="w-5 h-5" />
                    <span>Assinatura</span>
                  </Button>
                </Link>
              )}
              
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
      {!isActive && <SubscriptionBanner />}

      {/* Main Content */}
      <main className="relative max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        {/* Welcome Section */}
        <div className="text-center mb-12">
          <div className="w-20 h-20 bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-xl">
            <ShoppingCart className="w-10 h-10 text-white" />
          </div>
          <h2 className="text-4xl font-bold text-secondary-900 mb-4">
            Bem-vindo ao {empresaNome}
          </h2>
          <p className="text-xl text-secondary-600 max-w-2xl mx-auto">
            Selecione um módulo para começar a gerenciar seu negócio
          </p>
        </div>

        {/* Modules Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
          {modules.map((module) => {
            const Icon = module.icon
            const colorClasses = getColorClasses(module.color)
            
            return (
              <Card 
                key={module.title}
                className="relative overflow-hidden group hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2 bg-white/80 backdrop-blur-sm border-0"
              >
                {module.comingSoon && (
                  <div className="absolute top-3 right-3 bg-gradient-to-r from-yellow-400 to-yellow-500 text-yellow-900 px-2 py-1 rounded-full text-xs font-medium shadow-lg">
                    Em breve
                  </div>
                )}
                
                <div className="p-6">
                  <div className={`w-12 h-12 ${colorClasses} rounded-xl flex items-center justify-center mb-4 shadow-xl transition-all duration-300 group-hover:scale-110 group-hover:rotate-3`}>
                    <Icon className="w-6 h-6 text-white" />
                  </div>
                  
                  <h3 className="text-xl font-bold text-secondary-900 mb-2">
                    {module.title}
                  </h3>
                  
                  <p className="text-secondary-600 mb-4 text-base leading-relaxed">
                    {module.description}
                  </p>
                  
                  {module.comingSoon ? (
                    <Button 
                      variant="outline" 
                      disabled 
                      className="w-full py-2 text-base border-secondary-200 text-secondary-400"
                    >
                      Em desenvolvimento
                    </Button>
                  ) : (
                    <Link to={module.path}>
                      <Button className="w-full py-2 text-base bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 shadow-lg transform hover:scale-105 transition-all">
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
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <Card className="bg-gradient-to-br from-primary-500 to-primary-600 text-white border-0 shadow-xl hover:shadow-2xl transition-all duration-300 transform hover:scale-105">
            <div className="p-6 text-center">
              <ShoppingCart className="w-8 h-8 mx-auto mb-3 opacity-90" />
              <div className="text-2xl font-bold mb-1">0</div>
              <div className="text-primary-100 text-sm">Vendas Hoje</div>
            </div>
          </Card>
          
          <Card className="bg-gradient-to-br from-green-500 to-green-600 text-white border-0 shadow-xl hover:shadow-2xl transition-all duration-300 transform hover:scale-105">
            <div className="p-6 text-center">
              <CreditCard className="w-8 h-8 mx-auto mb-3 opacity-90" />
              <div className="text-2xl font-bold mb-1">R$ 0,00</div>
              <div className="text-green-100 text-sm">Faturamento</div>
            </div>
          </Card>
          
          <Card className="bg-gradient-to-br from-blue-500 to-blue-600 text-white border-0 shadow-xl hover:shadow-2xl transition-all duration-300 transform hover:scale-105">
            <div className="p-6 text-center">
              <Package className="w-8 h-8 mx-auto mb-3 opacity-90" />
              <div className="text-2xl font-bold mb-1">0</div>
              <div className="text-blue-100 text-sm">Produtos</div>
            </div>
          </Card>
          
          <Card className="bg-gradient-to-br from-yellow-500 to-yellow-600 text-white border-0 shadow-xl hover:shadow-2xl transition-all duration-300 transform hover:scale-105">
            <div className="p-6 text-center">
              <Users className="w-8 h-8 mx-auto mb-3 opacity-90" />
              <div className="text-2xl font-bold mb-1">0</div>
              <div className="text-yellow-100 text-sm">Clientes</div>
            </div>
          </Card>
        </div>
      </main>
    </div>
  )
}
