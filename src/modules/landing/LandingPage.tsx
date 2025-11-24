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
    <div className="min-h-screen bg-gradient-to-br from-white via-primary-50 to-primary-100 overflow-x-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5 overflow-hidden">
        <div className="absolute top-1/4 left-1/4 w-64 h-64 sm:w-96 sm:h-96 bg-primary-500 rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/4 right-1/4 w-64 h-64 sm:w-96 sm:h-96 bg-primary-400 rounded-full blur-3xl"></div>
      </div>

      {/* Header */}
      <header className="relative bg-white/90 backdrop-blur-sm shadow-lg border-b border-primary-100 w-full">
        <div className="max-w-7xl mx-auto px-2 xs:px-3 sm:px-4 md:px-6 lg:px-8">
          <div className="flex justify-between items-center py-2 xs:py-3 sm:py-4 md:py-6 lg:py-8 min-h-[60px]">
            {/* Logo */}
            <div className="flex items-center space-x-1 xs:space-x-2 sm:space-x-3 md:space-x-4 flex-shrink-0 max-w-[60%]">
              <div className="w-7 h-7 xs:w-8 xs:h-8 sm:w-10 sm:h-10 md:w-12 md:h-12 lg:w-14 lg:h-14 bg-gradient-to-br from-primary-500 to-primary-600 rounded-lg xs:rounded-xl sm:rounded-2xl flex items-center justify-center shadow-lg flex-shrink-0">
                <ShoppingCart className="w-3.5 h-3.5 xs:w-4 xs:h-4 sm:w-5 sm:h-5 md:w-6 md:h-6 lg:w-8 lg:h-8 text-white" />
              </div>
              <div className="min-w-0 flex-1">
                <h1 className="text-sm xs:text-base sm:text-lg md:text-xl lg:text-2xl xl:text-3xl font-bold text-secondary-900 truncate">RaVal pdv</h1>
                <p className="text-xs sm:text-sm md:text-base text-primary-600 font-medium hidden sm:block truncate">Sistema de Ponto de Venda</p>
              </div>
            </div>

            {/* Navegação */}
            <div className="flex items-center space-x-1 xs:space-x-1.5 sm:space-x-2 md:space-x-4 flex-shrink-0">
              <Link to="/login">
                <Button variant="outline" className="border-primary-300 text-primary-700 hover:bg-primary-50 text-xs xs:text-xs sm:text-sm md:text-base lg:text-lg px-1.5 py-1 xs:px-2 xs:py-1.5 sm:px-3 sm:py-2 md:px-4 md:py-2 lg:px-6 lg:py-3 whitespace-nowrap">
                  <span className="hidden xs:inline">Entrar</span>
                  <span className="xs:hidden">🔐</span>
                </Button>
              </Link>
              <Link to="/signup">
                <Button className="bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 shadow-lg text-xs xs:text-xs sm:text-sm md:text-base lg:text-lg px-1.5 py-1 xs:px-2 xs:py-1.5 sm:px-3 sm:py-2 md:px-4 md:py-2 lg:px-6 lg:py-3 whitespace-nowrap">
                  <span className="hidden xs:inline">Teste</span>
                  <span className="xs:hidden">🚀</span>
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative py-6 xs:py-8 sm:py-10 md:py-12 lg:py-16 xl:py-20 2xl:py-32 w-full">
        <div className="max-w-7xl mx-auto px-2 xs:px-3 sm:px-4 md:px-6 lg:px-8">
          <div className="text-center">
            <div className="w-12 h-12 xs:w-14 xs:h-14 sm:w-16 sm:h-16 md:w-20 md:h-20 lg:w-24 lg:h-24 xl:w-28 xl:h-28 2xl:w-32 2xl:h-32 bg-gradient-to-br from-primary-500 to-primary-600 rounded-xl xs:rounded-xl sm:rounded-2xl md:rounded-3xl flex items-center justify-center mx-auto mb-3 xs:mb-4 sm:mb-6 md:mb-8 shadow-2xl transform hover:scale-105 transition-transform">
              <ShoppingCart className="w-6 h-6 xs:w-7 xs:h-7 sm:w-8 sm:h-8 md:w-10 md:h-10 lg:w-12 lg:h-12 xl:w-14 xl:h-14 2xl:w-16 2xl:h-16 text-white" />
            </div>
            
            <h2 className="text-xl xs:text-2xl sm:text-3xl md:text-4xl lg:text-5xl xl:text-6xl 2xl:text-7xl font-bold text-secondary-900 mb-2 xs:mb-3 sm:mb-4 md:mb-6 leading-tight px-1 xs:px-2">
              <span className="block">RaVal pdv</span>
              <span className="text-primary-500 block">Completo e Moderno</span>
            </h2>
            <p className="text-sm xs:text-base sm:text-lg md:text-xl lg:text-2xl text-secondary-600 mb-4 xs:mb-6 sm:mb-8 md:mb-10 lg:mb-12 max-w-4xl mx-auto leading-relaxed px-2 xs:px-3 sm:px-4">
              Gerencie suas vendas, clientes, produtos e muito mais com o sistema mais moderno e intuitivo do mercado.
            </p>
            <div className="flex flex-col gap-2 xs:gap-3 sm:gap-4 md:gap-6 justify-center items-stretch px-2 xs:px-3 sm:px-4 max-w-sm sm:max-w-md mx-auto">
              <Link to="/signup" className="w-full">
                <Button className="w-full bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 shadow-lg text-xs xs:text-sm sm:text-base px-3 xs:px-4 sm:px-5 py-1.5 xs:py-2 sm:py-2.5 transform hover:scale-105 transition-all font-medium rounded-md">
                  🚀 Começar Teste Grátis
                </Button>
              </Link>
              <Link to="/login" className="w-full">
                <Button variant="outline" className="w-full border-primary-300 text-primary-700 hover:bg-primary-50 text-xs xs:text-sm sm:text-base px-3 xs:px-4 sm:px-5 py-1.5 xs:py-2 sm:py-2.5 font-medium rounded-md">
                  🔐 Fazer Login
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-8 xs:py-10 sm:py-12 md:py-16 lg:py-20 bg-gradient-to-br from-secondary-50 to-white w-full">
        <div className="max-w-7xl mx-auto px-2 xs:px-3 sm:px-4 md:px-6 lg:px-8">
          <div className="text-center mb-8 xs:mb-10 sm:mb-12 md:mb-16">
            <h3 className="text-xl xs:text-2xl sm:text-3xl md:text-4xl font-bold text-secondary-900 mb-3 xs:mb-4 sm:mb-6 px-2">
              Funcionalidades Completas
            </h3>
            <p className="text-sm xs:text-base sm:text-lg md:text-xl text-secondary-600 max-w-3xl mx-auto px-3 xs:px-4">
              Tudo que você precisa para gerenciar seu negócio em um só lugar
            </p>
          </div>

          <div className="grid grid-cols-1 xs:grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 xs:gap-5 sm:gap-6 md:gap-8">
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
                  className="group p-4 xs:p-5 sm:p-6 md:p-8 bg-white rounded-lg xs:rounded-xl sm:rounded-2xl border border-secondary-100 hover:border-primary-300 hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2"
                >
                  <div className={`w-10 h-10 xs:w-12 xs:h-12 sm:w-14 sm:h-14 md:w-16 md:h-16 bg-gradient-to-br ${colors[index]} rounded-lg xs:rounded-xl sm:rounded-2xl flex items-center justify-center mb-3 xs:mb-4 sm:mb-6 shadow-lg group-hover:scale-110 transition-transform duration-300 mx-auto sm:mx-0`}>
                    <Icon className="w-5 h-5 xs:w-6 xs:h-6 sm:w-7 sm:h-7 md:w-8 md:h-8 text-white" />
                  </div>
                  <h4 className="text-base xs:text-lg sm:text-xl font-bold text-secondary-900 mb-2 sm:mb-3 text-center sm:text-left">
                    {feature.title}
                  </h4>
                  <p className="text-secondary-600 text-sm xs:text-base sm:text-lg text-center sm:text-left leading-relaxed">
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
      <section className="py-8 xs:py-10 sm:py-12 md:py-16 lg:py-20 bg-gradient-to-br from-secondary-900 via-black to-secondary-800 w-full">
        <div className="relative max-w-7xl mx-auto px-2 xs:px-3 sm:px-4 md:px-6 lg:px-8 text-center">
          {/* Background Pattern */}
          <div className="absolute inset-0 opacity-10 overflow-hidden">
            <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-48 h-48 xs:w-64 xs:h-64 sm:w-80 sm:h-80 md:w-96 md:h-96 bg-primary-500 rounded-full blur-3xl"></div>
          </div>
          
          <div className="relative">
            <div className="w-12 h-12 xs:w-14 xs:h-14 sm:w-16 sm:h-16 md:w-20 md:h-20 lg:w-24 lg:h-24 bg-gradient-to-br from-primary-500 to-primary-600 rounded-lg xs:rounded-xl sm:rounded-2xl flex items-center justify-center mx-auto mb-4 xs:mb-6 sm:mb-8 shadow-2xl">
              <ShoppingCart className="w-6 h-6 xs:w-7 xs:h-7 sm:w-8 sm:h-8 md:w-10 md:h-10 lg:w-12 lg:h-12 text-white" />
            </div>
            
            <h3 className="text-xl xs:text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold text-white mb-3 xs:mb-4 sm:mb-6 px-2">
              Pronto para começar?
            </h3>
            <p className="text-sm xs:text-base sm:text-lg md:text-xl text-secondary-200 mb-6 xs:mb-8 sm:mb-10 max-w-2xl mx-auto px-3 xs:px-4 leading-relaxed">
              Junte-se a centenas de empresas que já transformaram suas vendas com o RaVal pdv
            </p>
            
            <div className="flex flex-col gap-2 xs:gap-3 sm:gap-4 md:gap-6 justify-center items-stretch px-2 xs:px-3 sm:px-4 max-w-sm sm:max-w-md mx-auto">
              <Link to="/signup" className="w-full">
                <Button className="w-full bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 shadow-lg text-xs xs:text-sm sm:text-base px-3 xs:px-4 sm:px-5 py-1.5 xs:py-2 sm:py-2.5 transform hover:scale-105 transition-all font-medium rounded-md">
                  🚀 Teste Grátis por 15 Dias
                </Button>
              </Link>
              <Link to="/login" className="w-full">
                <button className="w-full border-2 border-white bg-transparent text-white hover:bg-white hover:text-secondary-900 text-xs xs:text-sm sm:text-base px-3 xs:px-4 sm:px-5 py-1.5 xs:py-2 sm:py-2.5 font-medium transition-all duration-200 rounded-md inline-flex items-center justify-center">
                  🔐 Já tenho conta
                </button>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-secondary-900 border-t border-secondary-800 w-full">
        <div className="max-w-7xl mx-auto px-2 xs:px-3 sm:px-4 md:px-6 lg:px-8 py-4 xs:py-6 sm:py-8">
          <div className="flex flex-col xs:flex-col sm:flex-row items-center justify-between space-y-2 xs:space-y-3 sm:space-y-0 text-center sm:text-left">
            <div className="flex items-center space-x-2 xs:space-x-3">
              <div className="w-6 h-6 xs:w-7 xs:h-7 sm:w-8 sm:h-8 bg-primary-500 rounded-md xs:rounded-lg flex items-center justify-center flex-shrink-0">
                <ShoppingCart className="w-3 h-3 xs:w-4 xs:h-4 sm:w-5 sm:h-5 text-white" />
              </div>
              <span className="text-white font-semibold text-sm xs:text-base sm:text-lg">RaVal pdv</span>
            </div>
            <p className="text-secondary-400 text-xs xs:text-sm text-center px-2">
              © 2025 RaVal pdv. Todos os direitos reservados. v2.1
            </p>
          </div>
        </div>
      </footer>
    </div>
  )
}
