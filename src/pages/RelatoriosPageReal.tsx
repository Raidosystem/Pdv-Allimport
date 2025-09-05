import React, { useState, useEffect } from 'react'
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, LineChart, Line
} from 'recharts'
import { 
  Download, Users, ShoppingCart, DollarSign, 
  TrendingUp, Package, BarChart3, RefreshCw, Wrench
} from 'lucide-react'
import { toast } from 'react-hot-toast'
import { formatCurrency } from '../utils/format'
import { relatoriosService } from '../services/relatoriosService'
import type { 
  RelatorioVendas, 
  RelatorioClientes, 
  RelatorioOS, 
  RelatorioFinanceiro 
} from '../services/relatoriosService'

type ViewMode = 'dashboard' | 'vendas' | 'financeiro' | 'clientes' | 'ordens'

export default function RelatoriosPageReal() {
  const [currentView, setCurrentView] = useState<ViewMode>('dashboard')
  const [loading, setLoading] = useState(false)
  const [relatorioVendas, setRelatorioVendas] = useState<RelatorioVendas | null>(null)
  const [relatorioClientes, setRelatorioClientes] = useState<RelatorioClientes | null>(null)
  const [relatorioOS, setRelatorioOS] = useState<RelatorioOS | null>(null)
  const [relatorioFinanceiro, setRelatorioFinanceiro] = useState<RelatorioFinanceiro | null>(null)

  // Cores para gráficos
  const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8', '#82ca9d']

  // Carregar dados dos relatórios
  const carregarDados = async () => {
    setLoading(true)
    try {
      console.log('📊 Carregando dados dos relatórios...')
      
      const [vendas, clientes, os, financeiro] = await Promise.all([
        relatoriosService.gerarRelatorioVendas(),
        relatoriosService.gerarRelatorioClientes(),
        relatoriosService.gerarRelatorioOS(),
        relatoriosService.gerarRelatorioFinanceiro()
      ])
      
      setRelatorioVendas(vendas)
      setRelatorioClientes(clientes)
      setRelatorioOS(os)
      setRelatorioFinanceiro(financeiro)
      
      console.log('✅ Dados dos relatórios carregados com sucesso')
      toast.success('Relatórios atualizados!')
    } catch (error) {
      console.error('❌ Erro ao carregar relatórios:', error)
      toast.error('Erro ao carregar relatórios')
    } finally {
      setLoading(false)
    }
  }

  // Carregar dados na inicialização
  useEffect(() => {
    carregarDados()
  }, [])

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
  const DashboardView = () => {
    if (!relatorioVendas || !relatorioClientes || !relatorioOS || !relatorioFinanceiro) {
      return (
        <div className="flex items-center justify-center h-64">
          <div className="text-center">
            <RefreshCw className="h-8 w-8 animate-spin mx-auto text-blue-500 mb-2" />
            <p className="text-gray-500">Carregando relatórios...</p>
          </div>
        </div>
      )
    }

    return (
      <div className="space-y-6">
        {/* Estatísticas principais */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard 
            title="Total Vendas" 
            value={relatorioVendas.total_vendas} 
            icon={ShoppingCart} 
            color="border-blue-500"
            subtitle="vendas realizadas"
          />
          <StatCard 
            title="Faturamento" 
            value={formatCurrency(relatorioVendas.valor_total)} 
            icon={DollarSign} 
            color="border-green-500"
          />
          <StatCard 
            title="Ticket Médio" 
            value={formatCurrency(relatorioVendas.ticket_medio)} 
            icon={TrendingUp} 
            color="border-purple-500"
          />
          <StatCard 
            title="Total Clientes" 
            value={relatorioClientes.total_clientes} 
            icon={Users} 
            color="border-indigo-500" 
          />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard 
            title="Clientes Ativos" 
            value={relatorioClientes.clientes_ativos} 
            icon={Users} 
            color="border-cyan-500" 
          />
          <StatCard 
            title="Ordens de Serviço" 
            value={relatorioOS.total_os} 
            icon={Wrench} 
            color="border-orange-500"
          />
          <StatCard 
            title="OS Finalizadas" 
            value={relatorioOS.os_concluidas} 
            icon={Package} 
            color="border-yellow-500"
          />
          <StatCard 
            title="Receita Total" 
            value={formatCurrency(relatorioFinanceiro.receita_total)} 
            icon={DollarSign} 
            color="border-red-500"
          />
        </div>

        {/* Gráficos */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Vendas por dia */}
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h3 className="text-lg font-medium mb-4">Vendas por Dia</h3>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={relatorioVendas.vendas_por_data}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="data" />
                <YAxis />
                <Tooltip formatter={(value, name) => [
                  name === 'valor' ? formatCurrency(Number(value)) : value,
                  name === 'valor' ? 'Faturamento' : 'Vendas'
                ]} />
                <Bar dataKey="vendas" fill="#8884d8" />
                <Bar dataKey="valor" fill="#82ca9d" />
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Formas de pagamento */}
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h3 className="text-lg font-medium mb-4">Formas de Pagamento</h3>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={relatorioVendas.formas_pagamento}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ forma, percentual }) => `${forma}: ${percentual?.toFixed(1)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="valor"
                >
                  {relatorioVendas.formas_pagamento.map((_entry: any, index: number) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip formatter={(value) => [formatCurrency(Number(value)), 'Valor']} />
              </PieChart>
            </ResponsiveContainer>
          </div>

          {/* Status das OS */}
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h3 className="text-lg font-medium mb-4">Status das Ordens de Serviço</h3>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={relatorioOS.os_por_status}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ status, percentual }) => `${status}: ${percentual.toFixed(1)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="quantidade"
                >
                  {relatorioOS.os_por_status.map((_entry: any, index: number) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>

          {/* Novos clientes por mês */}
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h3 className="text-lg font-medium mb-4">Novos Clientes por Mês</h3>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={relatorioClientes.clientes_por_cidade.slice(0, 10)}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="mes" />
                <YAxis />
                <Tooltip />
                <Line type="monotone" dataKey="novos" stroke="#8884d8" />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    )
  }

  // Relatório de Vendas
  const VendasView = () => {
    if (!relatorioVendas) return <div>Carregando...</div>

    return (
      <div className="space-y-6">
        <div className="bg-white p-6 rounded-lg shadow-sm">
          <h3 className="text-lg font-medium mb-4">Resumo de Vendas</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-blue-50 p-4 rounded-lg">
              <p className="text-sm text-blue-600">Total de Vendas</p>
              <p className="text-2xl font-bold text-blue-800">{relatorioVendas.total_vendas}</p>
            </div>
            <div className="bg-green-50 p-4 rounded-lg">
              <p className="text-sm text-green-600">Faturamento Total</p>
              <p className="text-2xl font-bold text-green-800">{formatCurrency(relatorioVendas.valor_total)}</p>
            </div>
            <div className="bg-purple-50 p-4 rounded-lg">
              <p className="text-sm text-purple-600">Ticket Médio</p>
              <p className="text-2xl font-bold text-purple-800">{formatCurrency(relatorioVendas.ticket_medio)}</p>
            </div>
          </div>
        </div>

        {/* Lista de vendas */}
        <div className="bg-white rounded-lg shadow-sm overflow-hidden">
          <div className="px-6 py-4 border-b">
            <h3 className="text-lg font-medium">Vendas Recentes</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Data</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Cliente</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Valor</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Pagamento</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {relatorioVendas.vendas_detalhadas.slice(0, 10).map((venda: any, index: number) => (
                  <tr key={venda.id || index}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {new Date(venda.created_at).toLocaleDateString('pt-BR')}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {venda.customer?.name || 'Cliente não informado'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {formatCurrency(venda.total || venda.total_amount || 0)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {venda.payment_method || 'Não informado'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    )
  }

  // Relatório de Clientes
  const ClientesView = () => {
    if (!relatorioClientes) return <div>Carregando...</div>

    return (
      <div className="space-y-6">
        <div className="bg-white p-6 rounded-lg shadow-sm">
          <h3 className="text-lg font-medium mb-4">Resumo de Clientes</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-blue-50 p-4 rounded-lg">
              <p className="text-sm text-blue-600">Total de Clientes</p>
              <p className="text-2xl font-bold text-blue-800">{relatorioClientes.total_clientes}</p>
            </div>
            <div className="bg-green-50 p-4 rounded-lg">
              <p className="text-sm text-green-600">Clientes Ativos</p>
              <p className="text-2xl font-bold text-green-800">{relatorioClientes.clientes_ativos}</p>
            </div>
            <div className="bg-red-50 p-4 rounded-lg">
              <p className="text-sm text-red-600">Clientes Inativos</p>
              <p className="text-2xl font-bold text-red-800">{relatorioClientes.clientes_inativos}</p>
            </div>
          </div>
        </div>

        {/* Lista de clientes */}
        <div className="bg-white rounded-lg shadow-sm overflow-hidden">
          <div className="px-6 py-4 border-b">
            <h3 className="text-lg font-medium">Clientes Cadastrados</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nome</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Telefone</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tipo</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {relatorioClientes.clientes_detalhados.slice(0, 10).map((cliente: any) => (
                  <tr key={cliente.id}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {cliente.nome}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {cliente.telefone}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {cliente.tipo}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        cliente.ativo 
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {cliente.ativo ? 'Ativo' : 'Inativo'}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    )
  }

  // Relatório de Ordens de Serviço
  const OrdensView = () => {
    if (!relatorioOS) return <div>Carregando...</div>

    return (
      <div className="space-y-6">
        <div className="bg-white p-6 rounded-lg shadow-sm">
          <h3 className="text-lg font-medium mb-4">Resumo de Ordens de Serviço</h3>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="bg-blue-50 p-4 rounded-lg">
              <p className="text-sm text-blue-600">Total de OS</p>
              <p className="text-2xl font-bold text-blue-800">{relatorioOS.total_os}</p>
            </div>
            <div className="bg-green-50 p-4 rounded-lg">
              <p className="text-sm text-green-600">OS Finalizadas</p>
              <p className="text-2xl font-bold text-green-800">{relatorioOS.os_concluidas}</p>
            </div>
            <div className="bg-yellow-50 p-4 rounded-lg">
              <p className="text-sm text-yellow-600">OS Abertas</p>
              <p className="text-2xl font-bold text-yellow-800">{relatorioOS.os_abertas}</p>
            </div>
            <div className="bg-purple-50 p-4 rounded-lg">
              <p className="text-sm text-purple-600">Faturamento</p>
              <p className="text-2xl font-bold text-purple-800">{formatCurrency(relatorioOS.valor_total)}</p>
            </div>
          </div>
        </div>

        {/* Lista de ordens */}
        <div className="bg-white rounded-lg shadow-sm overflow-hidden">
          <div className="px-6 py-4 border-b">
            <h3 className="text-lg font-medium">Ordens de Serviço Recentes</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">OS</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Equipamento</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Valor</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {relatorioOS.os_detalhadas.slice(0, 10).map((os: any) => (
                  <tr key={os.id}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {os.numero_os || os.id.slice(0, 8)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {os.equipamento || `${os.marca} ${os.modelo}`}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        os.status === 'Entregue' ? 'bg-green-100 text-green-800' :
                        os.status === 'Pronto' ? 'bg-blue-100 text-blue-800' :
                        os.status === 'Em conserto' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {os.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {formatCurrency(parseFloat(os.valor_total || os.valor_final || '0'))}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    )
  }

  // Relatório Financeiro
  const FinanceiroView = () => {
    if (!relatorioFinanceiro) return <div>Carregando...</div>

    return (
      <div className="space-y-6">
        <div className="bg-white p-6 rounded-lg shadow-sm">
          <h3 className="text-lg font-medium mb-4">Resumo Financeiro</h3>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="bg-green-50 p-4 rounded-lg">
              <p className="text-sm text-green-600">Receita Total</p>
              <p className="text-2xl font-bold text-green-800">{formatCurrency(relatorioFinanceiro.receita_total)}</p>
            </div>
            <div className="bg-blue-50 p-4 rounded-lg">
              <p className="text-sm text-blue-600">Receita Vendas</p>
              <p className="text-2xl font-bold text-blue-800">{formatCurrency(relatorioFinanceiro.receita_total * 0.7)}</p>
            </div>
            <div className="bg-purple-50 p-4 rounded-lg">
              <p className="text-sm text-purple-600">Receita Serviços</p>
              <p className="text-2xl font-bold text-purple-800">{formatCurrency(relatorioFinanceiro.receita_total * 0.3)}</p>
            </div>
            <div className="bg-gray-50 p-4 rounded-lg">
              <p className="text-sm text-gray-600">Margem de Lucro</p>
              <p className="text-2xl font-bold text-gray-800">{relatorioFinanceiro.margem_lucro.toFixed(1)}%</p>
            </div>
          </div>
        </div>

        {/* Formas de pagamento */}
        <div className="bg-white p-6 rounded-lg shadow-sm">
          <h3 className="text-lg font-medium mb-4">Distribuição por Forma de Pagamento</h3>
          <ResponsiveContainer width="100%" height={400}>
            <PieChart>
              <Pie
                data={relatorioFinanceiro.formas_pagamento}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ forma, percentual }) => `${forma}: ${percentual.toFixed(1)}%`}
                outerRadius={120}
                fill="#8884d8"
                dataKey="valor"
              >
                {relatorioFinanceiro.formas_pagamento.map((_entry: any, index: number) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip formatter={(value) => [formatCurrency(Number(value)), 'Valor']} />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>
    )
  }

  return (
    <div className="max-w-7xl mx-auto p-6 space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Relatórios</h1>
          <p className="mt-2 text-sm text-gray-600">
            Acompanhe o desempenho do seu negócio
          </p>
        </div>
        <div className="flex items-center space-x-3 mt-4 sm:mt-0">
          <button
            onClick={carregarDados}
            disabled={loading}
            className="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
          >
            <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Atualizar
          </button>
          <button className="inline-flex items-center px-3 py-2 border border-transparent rounded-md text-sm font-medium text-white bg-blue-600 hover:bg-blue-700">
            <Download className="w-4 h-4 mr-2" />
            Exportar
          </button>
        </div>
      </div>

      {/* Navegação */}
      <div className="bg-white rounded-lg shadow-sm">
        <div className="border-b border-gray-200">
          <nav className="flex overflow-x-auto">
            {[
              { key: 'dashboard', label: 'Dashboard', icon: BarChart3 },
              { key: 'vendas', label: 'Vendas', icon: ShoppingCart },
              { key: 'clientes', label: 'Clientes', icon: Users },
              { key: 'ordens', label: 'Ordens de Serviço', icon: Wrench },
              { key: 'financeiro', label: 'Financeiro', icon: DollarSign }
            ].map(({ key, label, icon: Icon }) => (
              <button
                key={key}
                onClick={() => setCurrentView(key as ViewMode)}
                className={`flex items-center px-6 py-3 text-sm font-medium whitespace-nowrap border-b-2 ${
                  currentView === key
                    ? 'border-blue-500 text-blue-600 bg-blue-50'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <Icon className="w-4 h-4 mr-2" />
                {label}
              </button>
            ))}
          </nav>
        </div>
      </div>

      {/* Conteúdo do relatório */}
      <div className="min-h-[500px]">
        {currentView === 'dashboard' && <DashboardView />}
        {currentView === 'vendas' && <VendasView />}
        {currentView === 'clientes' && <ClientesView />}
        {currentView === 'ordens' && <OrdensView />}
        {currentView === 'financeiro' && <FinanceiroView />}
      </div>
    </div>
  )
}
