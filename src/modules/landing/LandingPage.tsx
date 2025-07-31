import { ShoppingCart, Users, Package, CreditCard, BarChart3, Wrench } from 'lucide-react'
import { Link } from 'react-router-dom'
import { Button } from '../../components/ui/Button'

export function LandingPage() {
  const features = [
    {
      icon: ShoppingCart,
      title: 'Vendas',
      description: 'Sistema completo de vendas com carrinho inteligente'
    },
    {
      icon: Users,
      title: 'Clientes',
      description: 'Gestão completa de clientes e histórico'
    },
    {
      icon: Package,
      title: 'Produtos',
      description: 'Controle de estoque e catálogo de produtos'
    },
    {
      icon: CreditCard,
      title: 'Caixa',
      description: 'Controle financeiro e fluxo de caixa'
    },
    {
      icon: BarChart3,
      title: 'Relatórios',
      description: 'Analytics e relatórios detalhados'
    },
    {
      icon: Wrench,
      title: 'Ordens de Serviço',
      description: 'Gestão completa de OS e manutenções'
    }
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-white via-primary-50 to-primary-100">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary-500 rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-primary-400 rounded-full blur-3xl"></div>
      </div>

      {/* Header */}
      <header className="relative bg-white/90 backdrop-blur-sm shadow-lg border-b border-primary-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6 md:py-8">
            {/* Logo */}
            <div className="flex items-center space-x-4">
              <div className="w-14 h-14 bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl flex items-center justify-center shadow-lg">
                <ShoppingCart className="w-8 h-8 text-white" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-secondary-900">PDV Import</h1>
                <p className="text-primary-600 font-medium">Sistema de Vendas Profissional</p>
              </div>
            </div>

            {/* Navegação */}
            <div className="flex items-center space-x-4">
              <Link to="/login">
                <Button variant="outline" className="border-primary-300 text-primary-700 hover:bg-primary-50 text-lg px-6 py-3">
                  Entrar
                </Button>
              </Link>
              <Link to="/signup">
                <Button className="bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 shadow-lg text-lg px-6 py-3">
                  Teste Grátis
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative py-20 lg:py-32">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <div className="w-32 h-32 bg-gradient-to-br from-primary-500 to-primary-600 rounded-3xl flex items-center justify-center mx-auto mb-8 shadow-2xl transform hover:scale-105 transition-transform">
              <ShoppingCart className="w-16 h-16 text-white" />
            </div>
            
            <h2 className="text-5xl md:text-7xl font-bold text-secondary-900 mb-6">
              Sistema PDV
              <span className="text-primary-500 block">Completo e Moderno</span>
            </h2>
            <p className="text-2xl text-secondary-600 mb-12 max-w-4xl mx-auto leading-relaxed">
              Gerencie suas vendas, clientes, produtos e muito mais com o sistema PDV mais moderno e intuitivo do mercado.
            </p>
            <div className="flex flex-col sm:flex-row gap-6 justify-center">
              <Link to="/signup">
                <Button className="bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 shadow-2xl text-xl px-12 py-4 transform hover:scale-105 transition-all">
                  Começar Teste Grátis
                </Button>
              </Link>
              <Link to="/login">
                <Button variant="outline" className="border-primary-300 text-primary-700 hover:bg-primary-50 text-xl px-12 py-4">
                  Fazer Login
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-gradient-to-br from-secondary-50 to-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h3 className="text-4xl font-bold text-secondary-900 mb-6">
              Funcionalidades Completas
            </h3>
            <p className="text-xl text-secondary-600 max-w-3xl mx-auto">
              Tudo que você precisa para gerenciar seu negócio em um só lugar
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {features.map((feature, index) => {
              const Icon = feature.icon
              const colors = [
                'from-primary-500 to-primary-600',
                'from-blue-500 to-blue-600', 
                'from-green-500 to-green-600',
                'from-yellow-500 to-yellow-600',
                'from-purple-500 to-purple-600',
                'from-red-500 to-red-600'
              ]
              return (
                <div
                  key={index}
                  className="group p-8 bg-white rounded-2xl border border-secondary-100 hover:border-primary-300 hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2"
                >
                  <div className={`w-16 h-16 bg-gradient-to-br ${colors[index]} rounded-2xl flex items-center justify-center mb-6 shadow-lg group-hover:scale-110 transition-transform duration-300`}>
                    <Icon className="w-8 h-8 text-white" />
                  </div>
                  <h4 className="text-xl font-bold text-secondary-900 mb-3">
                    {feature.title}
                  </h4>
                  <p className="text-secondary-600 text-lg">
                    {feature.description}
                  </p>
                </div>
              )
            })}
          </div>
        </div>
      </section>

      {/* CTA Section */}
            {/* CTA Section */}
      <section className="py-20 bg-gradient-to-br from-secondary-900 via-black to-secondary-800">
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          {/* Background Pattern */}
          <div className="absolute inset-0 opacity-10">
            <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-primary-500 rounded-full blur-3xl"></div>
          </div>
          
          <div className="relative">
            <div className="w-24 h-24 bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl flex items-center justify-center mx-auto mb-8 shadow-2xl">
              <ShoppingCart className="w-12 h-12 text-white" />
            </div>
            
            <h3 className="text-4xl md:text-5xl font-bold text-white mb-6">
              Pronto para começar?
            </h3>
            <p className="text-xl text-secondary-200 mb-10 max-w-2xl mx-auto">
              Junte-se a centenas de empresas que já transformaram suas vendas com o PDV Import
            </p>
            
            <div className="flex flex-col sm:flex-row gap-6 justify-center">
              <Link to="/signup">
                <Button className="bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 shadow-2xl text-xl px-12 py-4 transform hover:scale-105 transition-all">
                  Teste Grátis por 30 Dias
                </Button>
              </Link>
              <Link to="/login">
                <Button variant="outline" className="border-white text-white hover:bg-white hover:text-secondary-900 text-xl px-12 py-4">
                  Já tenho conta
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-secondary-900 border-t border-secondary-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-8 h-8 bg-primary-500 rounded-lg flex items-center justify-center">
                <ShoppingCart className="w-5 h-5 text-white" />
              </div>
              <span className="text-white font-semibold">PDV Import</span>
            </div>
            <p className="text-secondary-400 text-sm">
              © 2025 PDV Import. Todos os direitos reservados.
            </p>
          </div>
        </div>
      </footer>
    </div>
  )
}
