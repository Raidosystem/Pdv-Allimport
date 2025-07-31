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
      {/* Header */}
      <header className="relative">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6 md:py-8">
            {/* Logo */}
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-primary-500 rounded-xl flex items-center justify-center shadow-lg">
                <ShoppingCart className="w-6 h-6 text-white" />
              </div>
              <h1 className="text-2xl font-bold text-secondary-900">PDV Import</h1>
            </div>

            {/* Navegação */}
            <div className="flex items-center space-x-4">
              <Link to="/login">
                <Button variant="outline">
                  Entrar
                </Button>
              </Link>
              <Link to="/signup">
                <Button>
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
            <h2 className="text-4xl md:text-6xl font-bold text-secondary-900 mb-6">
              Sistema PDV
              <span className="text-primary-500 block">Completo e Moderno</span>
            </h2>
            <p className="text-xl text-secondary-600 mb-8 max-w-3xl mx-auto">
              Gerencie suas vendas, clientes, produtos e muito mais com o sistema PDV mais moderno e intuitivo do mercado.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link to="/signup">
                <Button size="lg" className="shadow-glow">
                  Começar Teste Grátis
                </Button>
              </Link>
              <Link to="/login">
                <Button variant="outline" size="lg">
                  Fazer Login
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h3 className="text-3xl font-bold text-secondary-900 mb-4">
              Funcionalidades Completas
            </h3>
            <p className="text-lg text-secondary-600 max-w-2xl mx-auto">
              Tudo que você precisa para gerenciar seu negócio em um só lugar
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {features.map((feature, index) => {
              const Icon = feature.icon
              return (
                <div
                  key={index}
                  className="group p-6 bg-white rounded-xl border border-secondary-200 hover:border-primary-300 hover:shadow-lg transition-all duration-300"
                >
                  <div className="w-12 h-12 bg-primary-100 rounded-lg flex items-center justify-center mb-4 group-hover:bg-primary-500 transition-colors duration-300">
                    <Icon className="w-6 h-6 text-primary-500 group-hover:text-white transition-colors duration-300" />
                  </div>
                  <h4 className="text-lg font-semibold text-secondary-900 mb-2">
                    {feature.title}
                  </h4>
                  <p className="text-secondary-600">
                    {feature.description}
                  </p>
                </div>
              )
            })}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-secondary-900">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h3 className="text-3xl font-bold text-white mb-4">
            Pronto para começar?
          </h3>
          <p className="text-xl text-secondary-300 mb-8 max-w-2xl mx-auto">
            Experimente gratuitamente por 30 dias. Sem compromisso, sem cartão de crédito.
          </p>
          <Link to="/signup">
            <Button size="lg" className="shadow-glow">
              Iniciar Teste Grátis
            </Button>
          </Link>
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
