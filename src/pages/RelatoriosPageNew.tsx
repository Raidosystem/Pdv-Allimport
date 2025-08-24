import React, { useState } from 'react'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell } from 'recharts'
import { Calendar, Download, TrendingUp, DollarSign, ShoppingCart, Users, Package, Printer, BarChart3 } from 'lucide-react'

type ViewMode = 'dashboard' | 'vendas' | 'financeiro' | 'estoque' | 'clientes'

interface RelatorioVenda {
  id: string
  data: string
  vendedor: string
  cliente: string
  produtos: number
  valor: number
  desconto: number
  valor_final: number
}

interface RelatorioFinanceiro {
  periodo: string
  receita: number
  despesas: number
  lucro: number
  vendas_quantidade: number
}

interface RelatorioEstoque {
  produto: string
  categoria: string
  estoque_atual: number
  vendidos: number
  valor_estoque: number
  status: 'normal' | 'baixo' | 'zerado'
}

interface RelatorioCliente {
  id: string
  nome: string
  total_compras: number
  valor_total: number
  ultima_compra: string
  status: 'ativo' | 'inativo'
}

export function RelatoriosPage() {
  const [viewMode, setViewMode] = useState<ViewMode>('dashboard')
  const [dataInicio, setDataInicio] = useState('')
  const [dataFim, setDataFim] = useState('')
  const [loading, setLoading] = useState(false)

  // Mock data para relatórios
  const vendasMock: RelatorioVenda[] = [
    {
      id: '1',
      data: '2024-01-20',
      vendedor: 'João Silva',
      cliente: 'Maria Santos',
      produtos: 3,
      valor: 450.00,
      desconto: 45.00,
      valor_final: 405.00
    },
    {
      id: '2',
      data: '2024-01-20',
      vendedor: 'Ana Costa',
      cliente: 'Pedro Lima',
      produtos: 1,
      valor: 299.90,
      desconto: 0,
      valor_final: 299.90
    },
    {
      id: '3',
      data: '2024-01-19',
      vendedor: 'João Silva',
      cliente: 'Cliente Balcão',
      produtos: 2,
      valor: 89.80,
      desconto: 8.98,
      valor_final: 80.82
    },
    {
      id: '4',
      data: '2024-01-19',
      vendedor: 'Ana Costa',
      cliente: 'Carlos Oliveira',
      produtos: 4,
      valor: 780.00,
      desconto: 78.00,
      valor_final: 702.00
    },
    {
      id: '5',
      data: '2024-01-18',
      vendedor: 'João Silva',
      cliente: 'Lucia Ferreira',
      produtos: 1,
      valor: 199.90,
      desconto: 0,
      valor_final: 199.90
    }
  ]

  const financeiroMock: RelatorioFinanceiro[] = [
    { periodo: 'Jan/2024', receita: 15420.50, despesas: 8500.00, lucro: 6920.50, vendas_quantidade: 87 },
    { periodo: 'Dez/2023', receita: 18750.30, despesas: 9200.00, lucro: 9550.30, vendas_quantidade: 104 },
    { periodo: 'Nov/2023', receita: 12890.80, despesas: 7800.00, lucro: 5090.80, vendas_quantidade: 72 },
    { periodo: 'Out/2023', receita: 16340.20, despesas: 8900.00, lucro: 7440.20, vendas_quantidade: 93 },
    { periodo: 'Set/2023', receita: 14520.60, despesas: 8100.00, lucro: 6420.60, vendas_quantidade: 81 }
  ]

  const estoqueMock: RelatorioEstoque[] = [
    {
      produto: 'Smartphone Samsung A54',
      categoria: 'Smartphones',
      estoque_atual: 15,
      vendidos: 8,
      valor_estoque: 19498.50,
      status: 'normal'
    },
    {
      produto: 'Fone JBL Tune 510BT',
      categoria: 'Áudio',
      estoque_atual: 3,
      vendidos: 22,
      valor_estoque: 599.70,
      status: 'baixo'
    },
    {
      produto: 'Carregador USB-C 20W',
      categoria: 'Acessórios',
      estoque_atual: 50,
      vendidos: 35,
      valor_estoque: 1495.00,
      status: 'normal'
    },
    {
      produto: 'Película Vidro Temperado',
      categoria: 'Acessórios',
      estoque_atual: 0,
      vendidos: 45,
      valor_estoque: 0,
      status: 'zerado'
    },
    {
      produto: 'Capinha iPhone 14',
      categoria: 'Capinhas',
      estoque_atual: 8,
      vendidos: 12,
      valor_estoque: 319.20,
      status: 'baixo'
    }
  ]

  const clientesMock: RelatorioCliente[] = [
    {
      id: '1',
      nome: 'Maria Santos',
      total_compras: 15,
      valor_total: 4850.30,
      ultima_compra: '2024-01-20',
      status: 'ativo'
    },
    {
      id: '2',
      nome: 'Pedro Lima',
      total_compras: 8,
      valor_total: 2340.80,
      ultima_compra: '2024-01-18',
      status: 'ativo'
    },
    {
      id: '3',
      nome: 'Carlos Oliveira',
      total_compras: 22,
      valor_total: 7920.50,
      ultima_compra: '2024-01-15',
      status: 'ativo'
    },
    {
      id: '4',
      nome: 'Ana Rodrigues',
      total_compras: 3,
      valor_total: 450.20,
      ultima_compra: '2023-12-10',
      status: 'inativo'
    },
    {
      id: '5',
      nome: 'José Costa',
      total_compras: 12,
      valor_total: 3680.90,
      ultima_compra: '2024-01-12',
      status: 'ativo'
    }
  ]

  // Dados para gráficos
  const vendasDiarias = [
    { dia: '15/01', vendas: 8, valor: 1250.80 },
    { dia: '16/01', vendas: 12, valor: 2340.50 },
    { dia: '17/01', vendas: 6, valor: 890.30 },
    { dia: '18/01', vendas: 15, valor: 3420.90 },
    { dia: '19/01', vendas: 10, valor: 1980.70 },
    { dia: '20/01', vendas: 18, valor: 4230.20 }
  ]

  const categoriaVendas = [
    { name: 'Smartphones', value: 45, color: '#0088FE' },
    { name: 'Acessórios', value: 30, color: '#00C49F' },
    { name: 'Áudio', value: 15, color: '#FFBB28' },
    { name: 'Capinhas', value: 10, color: '#FF8042' }
  ]

  // Estatísticas gerais
  const stats = {
    vendas_hoje: 12,
    valor_hoje: 2450.80,
    vendas_mes: 87,
    valor_mes: 15420.50,
    produtos_baixo_estoque: estoqueMock.filter(p => p.status === 'baixo').length,
    produtos_sem_estoque: estoqueMock.filter(p => p.status === 'zerado').length,
    clientes_ativos: clientesMock.filter(c => c.status === 'ativo').length,
    ticket_medio: 177.48
  }

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value)
  }

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString('pt-BR')
  }

  const handleExportPDF = () => {
    setLoading(true)
    // Simular export
    setTimeout(() => {
      setLoading(false)
      alert('Relatório exportado com sucesso!')
    }, 2000)
  }

  const handlePrint = () => {
    window.print()
  }

  // Card de Estatística
  const StatCard = ({ title, value, icon: Icon, color, subtitle, change }: {
    title: string
    value: string | number
    icon: React.ComponentType<any>
    color: string
    subtitle?: string
    change?: string
  }) => (
    <div className={`bg-white p-6 rounded-lg shadow-sm border-l-4 ${color}`}>
      <div className="flex items-center">
        <div className="flex-shrink-0">
          <Icon className="h-6 w-6 text-gray-600" />
        </div>
        <div className="ml-5 w-0 flex-1">
          <dl>
            <dt className="text-sm font-medium text-gray-500 truncate">
              {title}
            </dt>
            <dd className="text-lg font-medium text-gray-900">
              {typeof value === 'number' && title.includes('R$') ? formatCurrency(value) : value}
            </dd>
            {subtitle && (
              <dd className="text-xs text-gray-500">{subtitle}</dd>
            )}
            {change && (
              <dd className="text-xs text-green-600 font-medium">{change}</dd>
            )}
          </dl>
        </div>
      </div>
    </div>
  )

  // Dashboard principal
  const DashboardView = () => (
    <div className="space-y-6">
      {/* Estatísticas principais */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard 
          title="Vendas Hoje" 
          value={stats.vendas_hoje} 
          icon={ShoppingCart} 
          color="border-blue-500"
          subtitle="vendas realizadas"
          change="+15% vs ontem"
        />
        <StatCard 
          title="R$ Hoje" 
          value={stats.valor_hoje} 
          icon={DollarSign} 
          color="border-green-500"
          change="+8% vs ontem"
        />
        <StatCard 
          title="Vendas do Mês" 
          value={stats.vendas_mes} 
          icon={TrendingUp} 
          color="border-purple-500"
          subtitle="total mensal"
        />
        <StatCard 
          title="R$ do Mês" 
          value={stats.valor_mes} 
          icon={DollarSign} 
          color="border-indigo-500" 
        />
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard 
          title="Ticket Médio" 
          value={formatCurrency(stats.ticket_medio)} 
          icon={DollarSign} 
          color="border-orange-500" 
        />
        <StatCard 
          title="Clientes Ativos" 
          value={stats.clientes_ativos} 
          icon={Users} 
          color="border-cyan-500" 
        />
        <StatCard 
          title="Baixo Estoque" 
          value={stats.produtos_baixo_estoque} 
          icon={Package} 
          color="border-yellow-500"
          subtitle="produtos"
        />
        <StatCard 
          title="Sem Estoque" 
          value={stats.produtos_sem_estoque} 
          icon={Package} 
          color="border-red-500"
          subtitle="produtos"
        />
      </div>

      {/* Gráficos */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Vendas por dia */}
        <div className="bg-white p-6 rounded-lg shadow-sm">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Vendas dos Últimos 6 Dias</h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={vendasDiarias}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="dia" />
              <YAxis />
              <Tooltip 
                formatter={(value, name) => [
                  name === 'valor' ? formatCurrency(Number(value)) : value,
                  name === 'valor' ? 'Valor' : 'Vendas'
                ]}
              />
              <Line type="monotone" dataKey="vendas" stroke="#8884d8" strokeWidth={2} />
              <Line type="monotone" dataKey="valor" stroke="#82ca9d" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Vendas por categoria */}
        <div className="bg-white p-6 rounded-lg shadow-sm">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Vendas por Categoria (%)</h3>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={categoriaVendas}
                cx="50%"
                cy="50%"
                outerRadius={80}
                fill="#8884d8"
                dataKey="value"
                label={({name, percent}) => `${name} ${((percent || 0) * 100).toFixed(0)}%`}
              >
                {categoriaVendas.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Receita mensal */}
      <div className="bg-white p-6 rounded-lg shadow-sm">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Receita dos Últimos 5 Meses</h3>
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={financeiroMock}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="periodo" />
            <YAxis />
            <Tooltip 
              formatter={(value, name) => [
                formatCurrency(Number(value)),
                name === 'receita' ? 'Receita' : name === 'despesas' ? 'Despesas' : 'Lucro'
              ]}
            />
            <Bar dataKey="receita" fill="#8884d8" />
            <Bar dataKey="lucro" fill="#82ca9d" />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  )

  // Relatório de vendas
  const VendasView = () => (
    <div className="bg-white rounded-lg shadow-sm overflow-hidden">
      <div className="p-6 border-b">
        <h3 className="text-lg font-semibold text-gray-900">Relatório de Vendas</h3>
        <p className="text-gray-600 mt-1">Lista detalhada de todas as vendas realizadas</p>
      </div>
      
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-gray-50 border-b">
            <tr>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Data</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Vendedor</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Cliente</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Produtos</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Valor</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Desconto</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Total</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {vendasMock.map((venda) => (
              <tr key={venda.id} className="hover:bg-gray-50">
                <td className="py-3 px-4 text-sm text-gray-900">
                  {formatDate(venda.data)}
                </td>
                <td className="py-3 px-4 text-sm text-gray-900">
                  {venda.vendedor}
                </td>
                <td className="py-3 px-4 text-sm text-gray-900">
                  {venda.cliente}
                </td>
                <td className="py-3 px-4 text-sm text-gray-900">
                  {venda.produtos} itens
                </td>
                <td className="py-3 px-4 text-sm text-gray-900">
                  {formatCurrency(venda.valor)}
                </td>
                <td className="py-3 px-4 text-sm text-gray-900">
                  {formatCurrency(venda.desconto)}
                </td>
                <td className="py-3 px-4 text-sm font-medium text-gray-900">
                  {formatCurrency(venda.valor_final)}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )

  // Relatório financeiro
  const FinanceiroView = () => (
    <div className="bg-white rounded-lg shadow-sm overflow-hidden">
      <div className="p-6 border-b">
        <h3 className="text-lg font-semibold text-gray-900">Relatório Financeiro</h3>
        <p className="text-gray-600 mt-1">Análise de receitas, despesas e lucro por período</p>
      </div>
      
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-gray-50 border-b">
            <tr>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Período</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Receita</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Despesas</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Lucro</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Vendas</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Margem</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {financeiroMock.map((periodo) => {
              const margem = ((periodo.lucro / periodo.receita) * 100).toFixed(1)
              return (
                <tr key={periodo.periodo} className="hover:bg-gray-50">
                  <td className="py-3 px-4 text-sm font-medium text-gray-900">
                    {periodo.periodo}
                  </td>
                  <td className="py-3 px-4 text-sm text-green-600 font-medium">
                    {formatCurrency(periodo.receita)}
                  </td>
                  <td className="py-3 px-4 text-sm text-red-600 font-medium">
                    {formatCurrency(periodo.despesas)}
                  </td>
                  <td className="py-3 px-4 text-sm text-blue-600 font-medium">
                    {formatCurrency(periodo.lucro)}
                  </td>
                  <td className="py-3 px-4 text-sm text-gray-900">
                    {periodo.vendas_quantidade}
                  </td>
                  <td className="py-3 px-4 text-sm text-gray-900">
                    {margem}%
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </div>
  )

  // Relatório de estoque
  const EstoqueView = () => (
    <div className="bg-white rounded-lg shadow-sm overflow-hidden">
      <div className="p-6 border-b">
        <h3 className="text-lg font-semibold text-gray-900">Relatório de Estoque</h3>
        <p className="text-gray-600 mt-1">Situação atual do estoque e produtos vendidos</p>
      </div>
      
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-gray-50 border-b">
            <tr>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Produto</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Categoria</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Estoque</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Vendidos</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Valor Estoque</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {estoqueMock.map((item, index) => (
              <tr key={index} className="hover:bg-gray-50">
                <td className="py-3 px-4 text-sm font-medium text-gray-900">
                  {item.produto}
                </td>
                <td className="py-3 px-4 text-sm text-gray-600">
                  {item.categoria}
                </td>
                <td className="py-3 px-4 text-sm text-gray-900">
                  {item.estoque_atual}
                </td>
                <td className="py-3 px-4 text-sm text-gray-900">
                  {item.vendidos}
                </td>
                <td className="py-3 px-4 text-sm text-gray-900">
                  {formatCurrency(item.valor_estoque)}
                </td>
                <td className="py-3 px-4">
                  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                    item.status === 'normal' ? 'bg-green-100 text-green-800' :
                    item.status === 'baixo' ? 'bg-yellow-100 text-yellow-800' :
                    'bg-red-100 text-red-800'
                  }`}>
                    {item.status === 'normal' ? 'Normal' :
                     item.status === 'baixo' ? 'Baixo' : 'Zerado'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )

  // Relatório de clientes
  const ClientesView = () => (
    <div className="bg-white rounded-lg shadow-sm overflow-hidden">
      <div className="p-6 border-b">
        <h3 className="text-lg font-semibold text-gray-900">Relatório de Clientes</h3>
        <p className="text-gray-600 mt-1">Análise do comportamento e histórico dos clientes</p>
      </div>
      
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-gray-50 border-b">
            <tr>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Cliente</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Total Compras</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Valor Total</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Ticket Médio</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Última Compra</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {clientesMock.map((cliente) => {
              const ticketMedio = cliente.valor_total / cliente.total_compras
              return (
                <tr key={cliente.id} className="hover:bg-gray-50">
                  <td className="py-3 px-4 text-sm font-medium text-gray-900">
                    {cliente.nome}
                  </td>
                  <td className="py-3 px-4 text-sm text-gray-900">
                    {cliente.total_compras}
                  </td>
                  <td className="py-3 px-4 text-sm text-gray-900">
                    {formatCurrency(cliente.valor_total)}
                  </td>
                  <td className="py-3 px-4 text-sm text-gray-900">
                    {formatCurrency(ticketMedio)}
                  </td>
                  <td className="py-3 px-4 text-sm text-gray-900">
                    {formatDate(cliente.ultima_compra)}
                  </td>
                  <td className="py-3 px-4">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      cliente.status === 'ativo' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                    }`}>
                      {cliente.status === 'ativo' ? 'Ativo' : 'Inativo'}
                    </span>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </div>
  )

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Relatórios e Analytics</h1>
            <p className="text-gray-600 mt-1">
              Análise completa do desempenho da sua loja
            </p>
          </div>
          
          <div className="flex gap-2">
            <button
              onClick={handleExportPDF}
              disabled={loading}
              className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 disabled:opacity-50 flex items-center gap-2"
            >
              {loading ? (
                <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent" />
              ) : (
                <Download className="h-4 w-4" />
              )}
              Exportar PDF
            </button>
            <button
              onClick={handlePrint}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2"
            >
              <Printer className="h-4 w-4" />
              Imprimir
            </button>
          </div>
        </div>

        {/* Filtros e navegação */}
        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex flex-col lg:flex-row gap-4 items-center justify-between">
            {/* Navegação por abas */}
            <div className="flex flex-wrap gap-2">
              <button
                onClick={() => setViewMode('dashboard')}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  viewMode === 'dashboard'
                    ? 'bg-blue-100 text-blue-700 border border-blue-200'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                <BarChart3 className="h-4 w-4 inline mr-2" />
                Dashboard
              </button>
              <button
                onClick={() => setViewMode('vendas')}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  viewMode === 'vendas'
                    ? 'bg-blue-100 text-blue-700 border border-blue-200'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                <ShoppingCart className="h-4 w-4 inline mr-2" />
                Vendas
              </button>
              <button
                onClick={() => setViewMode('financeiro')}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  viewMode === 'financeiro'
                    ? 'bg-blue-100 text-blue-700 border border-blue-200'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                <DollarSign className="h-4 w-4 inline mr-2" />
                Financeiro
              </button>
              <button
                onClick={() => setViewMode('estoque')}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  viewMode === 'estoque'
                    ? 'bg-blue-100 text-blue-700 border border-blue-200'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                <Package className="h-4 w-4 inline mr-2" />
                Estoque
              </button>
              <button
                onClick={() => setViewMode('clientes')}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  viewMode === 'clientes'
                    ? 'bg-blue-100 text-blue-700 border border-blue-200'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                <Users className="h-4 w-4 inline mr-2" />
                Clientes
              </button>
            </div>

            {/* Filtros de data */}
            <div className="flex gap-2 items-center">
              <div className="relative">
                <Calendar className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                <input
                  type="date"
                  value={dataInicio}
                  onChange={(e) => setDataInicio(e.target.value)}
                  className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
                  placeholder="Data início"
                />
              </div>
              <span className="text-gray-500">até</span>
              <div className="relative">
                <Calendar className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                <input
                  type="date"
                  value={dataFim}
                  onChange={(e) => setDataFim(e.target.value)}
                  className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
                  placeholder="Data fim"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Conteúdo baseado na view selecionada */}
        <div className="animate-in fade-in duration-300">
          {viewMode === 'dashboard' && <DashboardView />}
          {viewMode === 'vendas' && <VendasView />}
          {viewMode === 'financeiro' && <FinanceiroView />}
          {viewMode === 'estoque' && <EstoqueView />}
          {viewMode === 'clientes' && <ClientesView />}
        </div>
      </div>
    </div>
  )
}
