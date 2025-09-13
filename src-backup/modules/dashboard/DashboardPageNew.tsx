import { Link } from 'react-router-dom'
import { OrdensServicoPage } from '../../pages/OrdensServicoPageNew'
import { CaixaPage } from '../../pages/CaixaPageNew'
import { RelatoriosPage } from '../../pages/RelatoriosPageNew'
import { AdministracaoPage } from '../../pages/AdministracaoPageNew'
import { ConfiguracoesPage } from '../../pages/ConfiguracoesPageNew'
import { useState, useEffect } from 'react'
import { 
  ShoppingCart, 
  Users, 
  BarChart3, 
  FileText,
  LogOut,
  User,
  Settings,
  Shield,
  DollarSign,
  Crown,
  Calendar,
  Eye,
  Plus,
  Clock,
  TrendingUp,
  CreditCard,
  Receipt,
  UserPlus,
  Search,
  History,
  CheckCircle,
  AlertCircle,
  Archive,
  Package
} from 'lucide-react'
import { useAuth } from '../auth'
import { useSubscription } from '../../hooks/useSubscription'
import { useUserHierarchy } from '../../hooks/useUserHierarchy'
import { Button } from '../../components/ui/Button'
import { SubscriptionStatus } from '../../components/subscription/SubscriptionStatus'
import { SubscriptionCountdown } from '../../components/subscription/SubscriptionCountdown'
import { SubscriptionBanner } from '../../components/subscription/SubscriptionBanner'
import { SalesPage } from '../sales/SalesPage'
import { ClientesPage } from '../clientes/ClientesPage'
import { ProductsPage } from '../../pages/ProductsPage'

// Definir interfaces para tipagem correta
interface MenuOption {
  title: string
  path: string
  icon: React.ComponentType<any>
  description: string
}

interface MenuModule {
  name: string
  title: string
  icon: React.ComponentType<any>
  color: 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info'
  priority?: boolean
  directLink?: string // Para menus que vão direto para uma página
  options?: MenuOption[] // Para menus que mostram subopções
}

export function DashboardPage() {
  const { user, signOut } = useAuth()
  const { isActive } = useSubscription()
  const { getVisibleModules, isAdmin, isOwner, loading } = useUserHierarchy()
  const [activeMenu, setActiveMenu] = useState<string | null>(null)

  // Debug do activeMenu (simplificado)
  useEffect(() => {
    console.log('� Menu ativo:', activeMenu)
  }, [activeMenu])

  const handleSignOut = async () => {
    await signOut()
  }

  // Definir todos os módulos com suas opções/submenus
  const allMenuModules: MenuModule[] = [
    {
      name: 'sales',
      title: 'Vendas',
      icon: ShoppingCart,
      color: 'primary' as const,
      priority: true, // Menu destacado
      options: [
        { title: 'Nova Venda', path: '/vendas', icon: Plus, description: 'Realizar nova venda' },
        { title: 'Histórico de Vendas', path: '/vendas/historico', icon: History, description: 'Ver vendas realizadas' },
        { title: 'Cupons Fiscais', path: '/vendas/cupons', icon: Receipt, description: 'Reimprimir cupons' },
        { title: 'Vendas do Dia', path: '/relatorios/vendas', icon: Calendar, description: 'Relatório diário' }
      ]
    },
    {
      name: 'clients',
      title: 'Clientes',
      icon: Users,
      color: 'secondary' as const,
      priority: true, // Menu destacado
      options: [
        { title: 'Novo Cliente', path: '/clientes/novo', icon: UserPlus, description: 'Cadastrar novo cliente' },
        { title: 'Lista de Clientes', path: '/clientes', icon: Search, description: 'Ver todos os clientes' },
        { title: 'Histórico de Compras', path: '/clientes/historico', icon: History, description: 'Consultar vendas por cliente' },
        { title: 'Relatório Clientes', path: '/relatorios/clientes', icon: BarChart3, description: 'Análises de clientes' }
      ]
    },
    {
      name: 'products',
      title: 'Produtos',
      icon: Package,
      color: 'info' as const,
      priority: true, // Menu destacado
      options: [
        { title: 'Novo Produto', path: '/produtos/novo', icon: Plus, description: 'Cadastrar novo produto' },
        { title: 'Lista de Produtos', path: '/produtos', icon: Search, description: 'Ver todos os produtos' },
        { title: 'Controle de Estoque', path: '/produtos/estoque', icon: Archive, description: 'Gerenciar estoque' },
        { title: 'Relatório Produtos', path: '/relatorios/produtos', icon: BarChart3, description: 'Análises de produtos' }
      ]
    },
    {
      name: 'orders',
      title: 'OS - Ordens de Serviço',
      icon: FileText,
      color: 'danger' as const,
      priority: true, // Menu destacado
      options: [
        { title: 'Nova OS', path: '/ordens-servico/nova', icon: Plus, description: 'Criar nova ordem de serviço' },
        { title: 'Lista de OS', path: '/ordens-servico', icon: Eye, description: 'Ver todas as ordens' },
        { title: 'OS em Andamento', path: '/ordens-servico?status=andamento', icon: Clock, description: 'Acompanhar serviços em execução' },
        { title: 'OS Finalizadas', path: '/ordens-servico?status=finalizada', icon: CheckCircle, description: 'Ver serviços concluídos' }
      ]
    },
    {
      name: 'cashier',
      title: 'Caixa',
      icon: DollarSign,
      color: 'warning' as const,
      priority: true, // Menu destacado
      options: [
        { title: 'Abrir Caixa', path: '/caixa', icon: CreditCard, description: 'Iniciar movimento do caixa' },
        { title: 'Fechar Caixa', path: '/caixa/fechar', icon: CheckCircle, description: 'Finalizar movimento diário' },
        { title: 'Histórico', path: '/historico-caixa', icon: History, description: 'Consultar movimentos anteriores' },
        { title: 'Relatórios', path: '/relatorios', icon: BarChart3, description: 'Análises financeiras' }
      ]
    },
    {
      name: 'reports',
      title: 'Relatórios',
      icon: BarChart3,
      color: 'info' as const,
      priority: true,
      options: [
        { title: 'Vendas do Dia', path: '/relatorios', icon: Calendar, description: 'Resumo diário' },
        { title: 'Período', path: '/relatorios/periodo', icon: TrendingUp, description: 'Análise por período' },
        { title: 'Ranking', path: '/relatorios/ranking', icon: Crown, description: 'Produtos mais vendidos' }
      ]
    }
  ]

  // Obter módulos visíveis baseado nas permissões
  const visibleModules = getVisibleModules()
  const availableMenus = allMenuModules.filter(menu => 
    visibleModules.some(visible => visible.name === menu.name)
  )

  // Adicionar módulos especiais
  const specialModules: MenuModule[] = []
  if (isAdmin()) {
    specialModules.push({
      name: 'admin',
      title: 'Administração',
      icon: Shield,
      color: 'danger' as const,
      priority: true,
      options: [
        { title: 'Backup', path: '/configuracoes', icon: Archive, description: 'Backup do sistema' },
        { title: 'Usuários', path: '/admin/usuarios', icon: Users, description: 'Gerenciar usuários' }
      ]
    })
  }
  
  if (user?.email) {
    specialModules.push({
      name: 'settings',
      title: 'Configurações',
      icon: Settings,
      color: 'info' as const,
      priority: true,
      options: [
        { title: 'Empresa', path: '/configuracoes-empresa', icon: Settings, description: 'Configurar empresa' },
        { title: 'Funcionários', path: '/funcionarios', icon: Users, description: 'Gerenciar equipe' }
      ]
    })
  }

  const allMenus = [...availableMenus, ...specialModules]

  // Abrir automaticamente o primeiro menu prioritário quando carrega
  useEffect(() => {
    const firstPriorityMenu = allMenus.find(menu => menu.priority)
    if (firstPriorityMenu && !activeMenu) {
      setActiveMenu(firstPriorityMenu.name)
    }
  }, [allMenus, activeMenu])

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
      {/* CSS customizado para excelente responsividade mobile */}
      <style>
        {`
          /* Ocultar scrollbar mas manter funcionalidade */
          .scrollbar-hide {
            -ms-overflow-style: none;
            scrollbar-width: none;
          }
          .scrollbar-hide::-webkit-scrollbar {
            display: none;
          }
          
          /* Mobile First - Extra pequeno (até 480px) */
          @media (max-width: 480px) {
            .dashboard-menu-container {
              padding-left: 4px !important;
              padding-right: 4px !important;
            }
            .dashboard-content {
              padding-left: 8px !important;
              padding-right: 8px !important;
              padding-top: 12px !important;
            }
            .mobile-menu-button {
              min-width: 65px !important;
              height: 48px !important;
              padding: 6px !important;
            }
            .mobile-menu-icon {
              width: 16px !important;
              height: 16px !important;
              margin-bottom: 2px !important;
            }
            .mobile-menu-text {
              font-size: 10px !important;
              line-height: 1.2 !important;
              font-weight: 600 !important;
            }
          }
          
          /* Mobile padrão (481px - 640px) */
          @media (min-width: 481px) and (max-width: 640px) {
            .dashboard-menu-container {
              padding-left: 8px !important;
              padding-right: 8px !important;
            }
            .dashboard-content {
              padding-left: 12px !important;
              padding-right: 12px !important;
              padding-top: 16px !important;
            }
            .mobile-menu-button {
              min-width: 75px !important;
              height: 52px !important;
              padding: 8px !important;
            }
            .mobile-menu-icon {
              width: 18px !important;
              height: 18px !important;
              margin-bottom: 3px !important;
            }
            .mobile-menu-text {
              font-size: 11px !important;
              line-height: 1.2 !important;
              font-weight: 600 !important;
            }
          }
          
          /* Tablet (641px - 1024px) */
          @media (min-width: 641px) and (max-width: 1024px) {
            .dashboard-menu-container {
              padding-left: 16px;
              padding-right: 16px;
            }
            .dashboard-content {
              padding-left: 24px;
              padding-right: 24px;
            }
          }
          
          /* Desktop (1025px+) */
          @media (min-width: 1025px) {
            .dashboard-menu-container {
              padding-left: 32px;
              padding-right: 32px;
            }
            .dashboard-content {
              padding-left: 32px;
              padding-right: 32px;
            }
          }
          
          /* Utilitários */
          .line-clamp-2 {
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
          }
          
          .animate-in {
            animation: fadeInUp 0.3s ease-out forwards;
          }
          
          @keyframes fadeInUp {
            from {
              opacity: 0;
              transform: translateY(10px);
            }
            to {
              opacity: 1;
              transform: translateY(0);
            }
          }
          
          /* Melhorar touch targets para mobile */
          @media (max-width: 640px) {
            .mobile-touch-target {
              min-height: 44px;
              min-width: 44px;
            }
          }
          
          /* Scroll suave em mobile */
          .smooth-scroll {
            scroll-behavior: smooth;
            -webkit-overflow-scrolling: touch;
          }
        `}
      </style>
      {/* Header */}
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

      {/* Banner de Assinatura */}
      {!isActive && !isAdmin() && <SubscriptionBanner />}

      {/* Menu Principal Horizontal - Otimizado para Mobile */}
      <div className="bg-white border-b shadow-sm relative z-20">
        <div className="max-w-7xl mx-auto dashboard-menu-container">
          {/* Scroll horizontal otimizado para mobile */}
          <div className="flex gap-1 sm:gap-2 overflow-x-auto py-2 sm:py-3 lg:py-4 scrollbar-hide smooth-scroll" 
               style={{ pointerEvents: 'auto' }}>
            
            {/* Menus Prioritários - Otimizados para mobile */}
            {allMenus.filter(menu => menu.priority).map((menu) => {
              const Icon = menu.icon
              const isActive = activeMenu === menu.name
              const colorClasses = {
                primary: isActive ? 'bg-blue-100 border-blue-300 text-blue-700' : 'bg-blue-50 hover:bg-blue-100 border-blue-200 text-blue-600',
                secondary: isActive ? 'bg-purple-100 border-purple-300 text-purple-700' : 'bg-purple-50 hover:bg-purple-100 border-purple-200 text-purple-600',
                success: isActive ? 'bg-green-100 border-green-300 text-green-700' : 'bg-green-50 hover:bg-green-100 border-green-200 text-green-600',
                warning: isActive ? 'bg-yellow-100 border-yellow-300 text-yellow-700' : 'bg-yellow-50 hover:bg-yellow-100 border-yellow-200 text-yellow-600',
                danger: isActive ? 'bg-red-100 border-red-300 text-red-700' : 'bg-red-50 hover:bg-red-100 border-red-200 text-red-600',
                info: isActive ? 'bg-cyan-100 border-cyan-300 text-cyan-700' : 'bg-cyan-50 hover:bg-cyan-100 border-cyan-200 text-cyan-600'
              }[menu.color] || 'bg-gray-50 hover:bg-gray-100 border-gray-200 text-gray-600'

              return (
                <button
                  key={menu.name}
                  onClick={(e) => {
                    e.preventDefault()
                    e.stopPropagation()
                    console.log('🎯 Menu clicado:', menu.name)
                    
                    // Todos os menus agora funcionam da mesma forma
                    setActiveMenu(menu.name)
                  }}
                  style={{ 
                    pointerEvents: 'auto',
                    position: 'relative',
                    zIndex: 10,
                    cursor: 'pointer'
                  }}
                  className={`
                    mobile-menu-button mobile-touch-target
                    flex flex-col items-center justify-center
                    p-2 sm:p-3 lg:p-4 
                    rounded-lg border-2 
                    transition-all duration-200 
                    min-w-[80px] sm:min-w-[100px] lg:min-w-[140px]
                    h-14 sm:h-16 lg:h-20
                    cursor-pointer 
                    hover:scale-105 active:scale-95
                    flex-shrink-0
                    ${colorClasses}
                  `}
                >
                  <Icon className="mobile-menu-icon w-5 h-5 sm:w-6 sm:h-6 lg:w-8 lg:h-8 mb-1 sm:mb-2" />
                  <span className="mobile-menu-text text-xs sm:text-sm lg:text-sm font-semibold text-center leading-tight">
                    {menu.title}
                  </span>
                </button>
              )
            })}
            
            {/* Separador visual - Responsivo */}
            {allMenus.filter(menu => menu.priority).length > 0 && allMenus.filter(menu => !menu.priority).length > 0 && (
              <div className="flex items-center px-1 sm:px-2">
                <div className="w-px h-10 sm:h-12 lg:h-16 bg-gray-300"></div>
              </div>
            )}
            
            {/* Menus Normais - Otimizados para mobile */}
            {allMenus.filter(menu => !menu.priority).map((menu) => {
              const Icon = menu.icon
              const isActive = activeMenu === menu.name
              const colorClasses = {
                primary: isActive ? 'bg-blue-100 border-blue-300 text-blue-700' : 'bg-blue-50 hover:bg-blue-100 border-blue-200 text-blue-600',
                secondary: isActive ? 'bg-purple-100 border-purple-300 text-purple-700' : 'bg-purple-50 hover:bg-purple-100 border-purple-200 text-purple-600',
                success: isActive ? 'bg-green-100 border-green-300 text-green-700' : 'bg-green-50 hover:bg-green-100 border-green-200 text-green-600',
                warning: isActive ? 'bg-yellow-100 border-yellow-300 text-yellow-700' : 'bg-yellow-50 hover:bg-yellow-100 border-yellow-200 text-yellow-600',
                danger: isActive ? 'bg-red-100 border-red-300 text-red-700' : 'bg-red-50 hover:bg-red-100 border-red-200 text-red-600',
                info: isActive ? 'bg-cyan-100 border-cyan-300 text-cyan-700' : 'bg-cyan-50 hover:bg-cyan-100 border-cyan-200 text-cyan-600'
              }[menu.color] || 'bg-gray-50 hover:bg-gray-100 border-gray-200 text-gray-600'

              return (
                <button
                  key={menu.name}
                  onClick={(e) => {
                    e.preventDefault()
                    e.stopPropagation()
                    console.log('🎯 Menu secundário clicado:', menu.name)
                    setActiveMenu(menu.name)
                  }}
                  style={{ 
                    pointerEvents: 'auto',
                    position: 'relative',
                    zIndex: 10,
                    cursor: 'pointer'
                  }}
                  className={`
                    mobile-menu-button mobile-touch-target
                    flex flex-col items-center justify-center
                    p-2 sm:p-3 lg:p-3 
                    rounded-lg border-2 
                    transition-all duration-200 
                    min-w-[70px] sm:min-w-[90px] lg:min-w-[100px]
                    h-12 sm:h-14 lg:h-16
                    cursor-pointer 
                    hover:scale-105 active:scale-95
                    flex-shrink-0
                    ${colorClasses}
                  `}
                >
                  <Icon className="mobile-menu-icon w-4 h-4 sm:w-5 sm:h-5 lg:w-6 lg:h-6 mb-1" />
                  <span className="mobile-menu-text text-xs sm:text-sm lg:text-sm font-medium text-center leading-tight">
                    {menu.title}
                  </span>
                </button>
              )
            })}
          </div>
        </div>
      </div>

      {/* Conteúdo Principal - Responsivo */}
      <main className="max-w-7xl mx-auto dashboard-content py-4 sm:py-6 lg:py-8">
        {/* Subscription Status */}
        {!isAdmin() && (
          <div className="mb-4 sm:mb-6">
            <SubscriptionStatus />
            <SubscriptionCountdown />
          </div>
        )}

        {/* Conteúdo Principal - Página embarcada ou Submenu */}
        {activeMenu && (
          <div className="mb-8 animate-in fade-in duration-300">
            {allMenus
              .filter(menu => menu.name === activeMenu)
              .map(menu => {
                // Para menus prioritários, mostrar a página diretamente
                if (menu.priority) {
                  const pageContent = {
                    sales: <SalesPage key="sales-page" />,
                    clients: <ClientesPage key="clients-page" />,
                    products: <ProductsPage key="products-page" />,
                    orders: <OrdensServicoPage key="orders-page" />,
                    cashier: <CaixaPage key="cashier-page" />,
                    reports: <RelatoriosPage key="reports-page" />,
                    admin: <AdministracaoPage key="admin-page" />,
                    settings: <ConfiguracoesPage key="settings-page" />
                  }[menu.name]
                  
                  return <div key={`page-${menu.name}`}>{pageContent}</div>
                }
                
                // Para menus secundários, mostrar as opções
                return (
                  <div key={menu.name} className="bg-white rounded-lg shadow-sm border p-6">
                    <div className="flex items-center justify-between mb-6">
                      <h2 className="text-xl font-bold text-gray-900 flex items-center">
                        <menu.icon className="w-6 h-6 mr-2" />
                        {menu.title}
                        <span className="ml-2 text-xs bg-blue-100 text-blue-700 px-2 py-1 rounded-full">
                          ATIVO
                        </span>
                      </h2>
                      <div className="text-right">
                        <span className="text-sm text-gray-500">
                          {menu.options?.length || 0} opções disponíveis
                        </span>
                        <p className="text-xs text-gray-400 mt-1">
                          Clique em uma opção para acessar
                        </p>
                      </div>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                      {menu.options?.map((option, index) => (
                        <Link
                          key={option.path}
                          to={option.path}
                          className="flex items-start p-5 rounded-lg border border-gray-200 hover:border-blue-300 hover:shadow-lg bg-white hover:bg-blue-50 transition-all duration-300 group animate-in slide-in-from-bottom transform hover:scale-102"
                          style={{ animationDelay: `${index * 50}ms` }}
                        >
                          <div className="flex-shrink-0 mr-4">
                            <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center group-hover:bg-blue-200 transition-colors">
                              <option.icon className="w-6 h-6 text-blue-600 group-hover:text-blue-700 transition-colors" />
                            </div>
                          </div>
                          <div className="flex-1">
                            <h3 className="font-semibold text-gray-900 group-hover:text-blue-900 mb-1 transition-colors">
                              {option.title}
                            </h3>
                            <p className="text-sm text-gray-600 group-hover:text-blue-700 transition-colors leading-relaxed">
                              {option.description}
                            </p>
                            <div className="mt-2 text-xs text-blue-600 opacity-0 group-hover:opacity-100 transition-opacity">
                              Clique para acessar →
                            </div>
                          </div>
                        </Link>
                      ))}
                    </div>
                  </div>
                )
              })
            }
          </div>
        )}

        {/* Mensagem quando nenhum menu está ativo */}
        {!activeMenu && (
          <div className="text-center py-12">
            <div className="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <ShoppingCart className="w-10 h-10 text-gray-400" />
            </div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              Bem-vindo ao PDV Allimport
            </h3>
            <p className="text-gray-600 max-w-md mx-auto mb-8">
              Clique em um dos menus acima para ver as opções disponíveis e começar a usar o sistema.
            </p>
            
            {/* Atalhos rápidos para os menus principais */}
            <div className="flex justify-center space-x-4 flex-wrap gap-2">
              {allMenus.filter(menu => menu.priority).map((menu) => {
                const Icon = menu.icon
                return (
                  <button
                    key={menu.name}
                    onClick={() => setActiveMenu(menu.name)}
                    className="flex items-center px-4 py-2 bg-white border border-gray-200 rounded-lg hover:border-gray-300 hover:shadow-sm transition-all duration-200"
                  >
                    <Icon className="w-5 h-5 mr-2 text-gray-600" />
                    <span className="text-sm font-medium text-gray-700">{menu.title}</span>
                  </button>
                )
              })}
            </div>
          </div>
        )}

        {/* Empty state para usuários sem permissões */}
        {allMenus.length === 0 && !isAdmin() && !isOwner() && (
          <div className="text-center py-12">
            <div className="w-16 h-16 bg-gray-200 rounded-full flex items-center justify-center mx-auto mb-4">
              <AlertCircle className="w-8 h-8 text-gray-400" />
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
