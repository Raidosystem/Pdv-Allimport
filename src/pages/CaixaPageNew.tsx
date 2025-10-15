import React, { useState } from 'react'
import { Plus, Search, Filter, Trash2, DollarSign, TrendingUp, TrendingDown, Clock, AlertCircle, CheckCircle, Receipt } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useCaixa } from '../hooks/useCaixa'
import type { AberturaCaixaForm } from '../types/caixa'

type ViewMode = 'dashboard' | 'movimentacoes' | 'historico'

export function CaixaPage() {
  const navigate = useNavigate()
  const [viewMode, setViewMode] = useState<ViewMode>('dashboard')
  const [searchTerm, setSearchTerm] = useState('')
  const [tipoFilter, setTipoFilter] = useState<'entrada' | 'saida' | ''>('')
  const [showAbrirCaixaModal, setShowAbrirCaixaModal] = useState(false)
  const [showFecharCaixaModal, setShowFecharCaixaModal] = useState(false)
  const [showMovimentacaoModal, setShowMovimentacaoModal] = useState(false)

  const {
    caixaAtual: caixaAtivo,
    loading,
    error,
    abrirCaixa,
    fecharCaixa,
    adicionarMovimentacao
  } = useCaixa()

  // Mock data para demonstração - interface rápida
  const movimentacoes = caixaAtivo?.movimentacoes_caixa || []
  const caixas = caixaAtivo ? [caixaAtivo] : []

  // Filtrar movimentações
  const movimentacoesFiltradas = movimentacoes.filter((mov: any) => {
    const matchesSearch = mov.descricao.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesTipo = !tipoFilter || mov.tipo === tipoFilter
    return matchesSearch && matchesTipo
  })

  // Estatísticas - mostrar valores mesmo durante carregamento
  const stats = {
    caixaAberto: caixaAtivo ? true : false,
    valorInicial: caixaAtivo?.valor_inicial || 0,
    totalEntradas: caixaAtivo?.total_entradas || 0,
    totalSaidas: caixaAtivo?.total_saidas || 0,
    saldoAtual: caixaAtivo?.saldo_atual || 0,
    totalMovimentacoes: movimentacoes.length || 0
  }

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value)
  }

  const formatDate = (date: string) => {
    return new Date(date).toLocaleString('pt-BR')
  }

  const formatTime = (date: string) => {
    return new Date(date).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
  }

  // Modal Abrir Caixa
  const AbrirCaixaModal = () => {
    const [valorInicial, setValorInicial] = useState(0)
    const [observacoes, setObservacoes] = useState('')

    const handleSubmit = async (e: React.FormEvent) => {
      e.preventDefault()
      try {
        const dados: AberturaCaixaForm = { valor_inicial: valorInicial, observacoes }
        await abrirCaixa(dados)
        setShowAbrirCaixaModal(false)
        setValorInicial(0)
        setObservacoes('')
      } catch (error) {
        console.error('Erro ao abrir caixa:', error)
      }
    }

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg shadow-lg p-6 w-full max-w-md">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Abrir Caixa</h3>
            <button
              onClick={() => setShowAbrirCaixaModal(false)}
              className="text-gray-400 hover:text-gray-600"
            >
              ✕
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Valor Inicial *
              </label>
              <input
                type="number"
                step="0.01"
                min="0"
                required
                value={valorInicial}
                onChange={(e) => setValorInicial(parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="0,00"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Observações
              </label>
              <textarea
                rows={3}
                value={observacoes}
                onChange={(e) => setObservacoes(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Observações sobre a abertura do caixa..."
              />
            </div>

            <div className="flex gap-3">
              <button
                type="submit"
                disabled={loading}
                className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700 disabled:opacity-50"
              >
                {loading ? 'Abrindo...' : 'Abrir Caixa'}
              </button>
              <button
                type="button"
                onClick={() => setShowAbrirCaixaModal(false)}
                className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
              >
                Cancelar
              </button>
            </div>
          </form>
        </div>
      </div>
    )
  }

  // Modal Fechar Caixa
  const FecharCaixaModal = () => {
    const [valorContado, setValorContado] = useState(stats.saldoAtual)
    const [observacoes, setObservacoes] = useState('')

    const diferenca = valorContado - stats.saldoAtual

    const handleSubmit = async (e: React.FormEvent) => {
      e.preventDefault()
      try {
        if (caixaAtivo) {
          const dados = { valor_contado: valorContado, observacoes }
          await fecharCaixa(caixaAtivo.id, dados)
          setShowFecharCaixaModal(false)
          setObservacoes('')
        }
      } catch (error) {
        console.error('Erro ao fechar caixa:', error)
      }
    }

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg shadow-lg p-6 w-full max-w-md">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Fechar Caixa</h3>
            <button
              onClick={() => setShowFecharCaixaModal(false)}
              className="text-gray-400 hover:text-gray-600"
            >
              ✕
            </button>
          </div>

          <div className="space-y-3 mb-6">
            <div className="flex justify-between">
              <span className="text-gray-600">Saldo do Sistema:</span>
              <span className="font-medium">{formatCurrency(stats.saldoAtual)}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Valor Contado:</span>
              <span className="font-medium">{formatCurrency(valorContado)}</span>
            </div>
            <div className="flex justify-between pt-2 border-t">
              <span className="text-gray-600">Diferença:</span>
              <span className={`font-medium ${diferenca >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                {formatCurrency(diferenca)}
              </span>
            </div>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Valor Contado *
              </label>
              <input
                type="number"
                step="0.01"
                min="0"
                required
                value={valorContado}
                onChange={(e) => setValorContado(parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Observações
              </label>
              <textarea
                rows={3}
                value={observacoes}
                onChange={(e) => setObservacoes(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Observações sobre o fechamento..."
              />
            </div>

            <div className="flex gap-3">
              <button
                type="submit"
                disabled={loading}
                className="flex-1 bg-red-600 text-white py-2 px-4 rounded-lg hover:bg-red-700 disabled:opacity-50"
              >
                {loading ? 'Fechando...' : 'Fechar Caixa'}
              </button>
              <button
                type="button"
                onClick={() => setShowFecharCaixaModal(false)}
                className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
              >
                Cancelar
              </button>
            </div>
          </form>
        </div>
      </div>
    )
  }

  // Modal Nova Movimentação
  const MovimentacaoModal = () => {
    const [tipo, setTipo] = useState<'entrada' | 'saida'>('entrada')
    const [descricao, setDescricao] = useState('')
    const [valor, setValor] = useState(0)

    const handleSubmit = async (e: React.FormEvent) => {
      e.preventDefault()
      try {
        if (caixaAtivo) {
          await adicionarMovimentacao(caixaAtivo.id, { tipo, descricao, valor })
          setShowMovimentacaoModal(false)
          setDescricao('')
          setValor(0)
        }
      } catch (error) {
        console.error('Erro ao adicionar movimentação:', error)
      }
    }

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg shadow-lg p-6 w-full max-w-md">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Nova Movimentação</h3>
            <button
              onClick={() => setShowMovimentacaoModal(false)}
              className="text-gray-400 hover:text-gray-600"
            >
              ✕
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tipo *
              </label>
              <div className="flex gap-4">
                <label className="flex items-center">
                  <input
                    type="radio"
                    name="tipo"
                    value="entrada"
                    checked={tipo === 'entrada'}
                    onChange={(e) => setTipo(e.target.value as 'entrada')}
                    className="mr-2"
                  />
                  <TrendingUp className="h-4 w-4 text-green-600 mr-1" />
                  Entrada
                </label>
                <label className="flex items-center">
                  <input
                    type="radio"
                    name="tipo"
                    value="saida"
                    checked={tipo === 'saida'}
                    onChange={(e) => setTipo(e.target.value as 'saida')}
                    className="mr-2"
                  />
                  <TrendingDown className="h-4 w-4 text-red-600 mr-1" />
                  Saída
                </label>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Descrição *
              </label>
              <input
                type="text"
                required
                value={descricao}
                onChange={(e) => setDescricao(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Descrição da movimentação"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Valor *
              </label>
              <input
                type="number"
                step="0.01"
                min="0.01"
                required
                value={valor}
                onChange={(e) => setValor(parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="0,00"
              />
            </div>

            <div className="flex gap-3">
              <button
                type="submit"
                disabled={loading || !caixaAtivo}
                className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700 disabled:opacity-50"
              >
                {loading ? 'Salvando...' : 'Adicionar'}
              </button>
              <button
                type="button"
                onClick={() => setShowMovimentacaoModal(false)}
                className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
              >
                Cancelar
              </button>
            </div>
          </form>
        </div>
      </div>
    )
  }

  // Card de Estatística
  const StatCard = ({ title, value, icon: Icon, color, subtitle }: {
    title: string
    value: string | number
    icon: React.ComponentType<any>
    color: string
    subtitle?: string
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
              {typeof value === 'number' ? formatCurrency(value) : value}
            </dd>
            {subtitle && (
              <dd className="text-xs text-gray-500">{subtitle}</dd>
            )}
          </dl>
        </div>
      </div>
    </div>
  )

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 p-4">
        <div className="max-w-7xl mx-auto">
          <div className="bg-red-50 border border-red-200 rounded-lg p-4">
            <p className="text-red-600">Erro: {error}</p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Controle de Caixa</h1>
            <p className="text-gray-600 mt-1">
              Gerencie a abertura, fechamento e movimentações do caixa
            </p>
          </div>
          
          <div className="flex flex-col sm:flex-row gap-2">
            {/* Botão Financeiro - sempre visível */}
            <button
              onClick={() => navigate('/financeiro/contas-pagar')}
              className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 flex items-center gap-2"
            >
              <Receipt className="h-5 w-5" />
              Financeiro
            </button>
            
            {!caixaAtivo ? (
              <button
                onClick={() => setShowAbrirCaixaModal(true)}
                className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 flex items-center gap-2"
              >
                <Plus className="h-5 w-5" />
                Abrir Caixa
              </button>
            ) : (
              <>
                <button
                  onClick={() => setShowMovimentacaoModal(true)}
                  className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2"
                >
                  <Plus className="h-5 w-5" />
                  Nova Movimentação
                </button>
                <button
                  onClick={() => setShowFecharCaixaModal(true)}
                  className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 flex items-center gap-2"
                >
                  <CheckCircle className="h-5 w-5" />
                  Fechar Caixa
                </button>
              </>
            )}
          </div>
        </div>

        {/* Status do Caixa */}
        <div className="bg-white p-4 rounded-lg shadow-sm border-l-4 border-blue-500">
          <div className="flex items-center gap-3">
            {caixaAtivo ? (
              <>
                <CheckCircle className="h-6 w-6 text-green-600" />
                <div>
                  <h3 className="font-semibold text-gray-900">Caixa Aberto</h3>
                  <p className="text-sm text-gray-600">
                    Aberto em {formatDate(caixaAtivo.data_abertura)}
                  </p>
                </div>
              </>
            ) : (
              <>
                <AlertCircle className="h-6 w-6 text-red-600" />
                <div>
                  <h3 className="font-semibold text-gray-900">Caixa Fechado</h3>
                  <p className="text-sm text-gray-600">
                    Abra um caixa para começar a registrar movimentações
                  </p>
                </div>
              </>
            )}
          </div>
        </div>

        {/* Estatísticas */}
        {caixaAtivo && (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <StatCard
              title="Valor Inicial"
              value={stats.valorInicial}
              icon={DollarSign}
              color="border-blue-500"
            />
            <StatCard
              title="Total Entradas"
              value={stats.totalEntradas}
              icon={TrendingUp}
              color="border-green-500"
              subtitle={`${movimentacoes.filter((m: any) => m.tipo === 'entrada').length} movimentações`}
            />
            <StatCard
              title="Total Saídas"
              value={stats.totalSaidas}
              icon={TrendingDown}
              color="border-red-500"
              subtitle={`${movimentacoes.filter((m: any) => m.tipo === 'saida').length} movimentações`}
            />
            <StatCard
              title="Saldo Atual"
              value={stats.saldoAtual}
              icon={DollarSign}
              color="border-purple-500"
              subtitle={`${stats.totalMovimentacoes} movimentações`}
            />
          </div>
        )}

        {/* Navegação */}
        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex flex-wrap gap-2">
            <button
              onClick={() => setViewMode('dashboard')}
              className={`px-4 py-2 rounded-lg transition-colors ${
                viewMode === 'dashboard'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Dashboard
            </button>
            <button
              onClick={() => setViewMode('movimentacoes')}
              className={`px-4 py-2 rounded-lg transition-colors ${
                viewMode === 'movimentacoes'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Movimentações
            </button>
            <button
              onClick={() => setViewMode('historico')}
              className={`px-4 py-2 rounded-lg transition-colors ${
                viewMode === 'historico'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Histórico
            </button>
          </div>
        </div>

        {/* Conteúdo baseado na view */}
        {viewMode === 'movimentacoes' && caixaAtivo && (
          <>
            {/* Filtros */}
            <div className="bg-white p-4 rounded-lg shadow-sm">
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="flex-1 relative">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                  <input
                    type="text"
                    placeholder="Buscar por descrição..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                
                <div className="relative">
                  <Filter className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                  <select
                    value={tipoFilter}
                    onChange={(e) => setTipoFilter(e.target.value as 'entrada' | 'saida' | '')}
                    className="pl-10 pr-8 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white"
                  >
                    <option value="">Todos os tipos</option>
                    <option value="entrada">Entradas</option>
                    <option value="saida">Saídas</option>
                  </select>
                </div>
              </div>
            </div>

            {/* Tabela de Movimentações */}
            <div className="bg-white rounded-lg shadow-sm overflow-hidden">
              {loading && movimentacoes.length === 0 ? (
                <div className="p-8 text-center">
                  <div className="animate-spin rounded-full h-8 w-8 border-2 border-blue-600 border-t-transparent mx-auto mb-4" />
                  <p className="text-gray-600">Carregando movimentações...</p>
                </div>
              ) : movimentacoesFiltradas.length === 0 ? (
                <div className="p-8 text-center">
                  <Clock className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-gray-600 text-lg">
                    {searchTerm || tipoFilter
                      ? 'Nenhuma movimentação encontrada com os filtros aplicados'
                      : 'Nenhuma movimentação registrada'
                    }
                  </p>
                </div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead className="bg-gray-50 border-b">
                      <tr>
                        <th className="text-left py-3 px-4 font-medium text-gray-700">Data/Hora</th>
                        <th className="text-left py-3 px-4 font-medium text-gray-700">Tipo</th>
                        <th className="text-left py-3 px-4 font-medium text-gray-700">Descrição</th>
                        <th className="text-left py-3 px-4 font-medium text-gray-700">Valor</th>
                        <th className="text-right py-3 px-4 font-medium text-gray-700">Ações</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200">
                      {movimentacoesFiltradas.map((mov: any) => (
                        <tr key={mov.id} className="hover:bg-gray-50">
                          <td className="py-3 px-4 text-sm text-gray-500">
                            {formatTime(mov.data)}
                          </td>
                          <td className="py-3 px-4">
                            <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                              mov.tipo === 'entrada'
                                ? 'bg-green-100 text-green-800'
                                : 'bg-red-100 text-red-800'
                            }`}>
                              {mov.tipo === 'entrada' ? (
                                <TrendingUp className="h-3 w-3 mr-1" />
                              ) : (
                                <TrendingDown className="h-3 w-3 mr-1" />
                              )}
                              {mov.tipo === 'entrada' ? 'Entrada' : 'Saída'}
                            </span>
                          </td>
                          <td className="py-3 px-4 text-sm text-gray-900">
                            {mov.descricao}
                          </td>
                          <td className="py-3 px-4">
                            <span className={`font-medium ${
                              mov.tipo === 'entrada' ? 'text-green-600' : 'text-red-600'
                            }`}>
                              {mov.tipo === 'entrada' ? '+' : '-'}{formatCurrency(mov.valor)}
                            </span>
                          </td>
                          <td className="py-3 px-4 text-right">
                            <button
                              onClick={() => console.log('Excluir movimentação:', mov.id)}
                              className="p-1 text-red-600 hover:text-red-800"
                              title="Excluir"
                            >
                              <Trash2 className="h-4 w-4" />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </>
        )}

        {/* Histórico de Caixas */}
        {viewMode === 'historico' && (
          <div className="bg-white rounded-lg shadow-sm overflow-hidden">
            <div className="p-6 border-b">
              <h3 className="text-lg font-semibold text-gray-900">Histórico de Caixas</h3>
            </div>
            
            {loading && caixas.length === 0 ? (
              <div className="p-8 text-center">
                <div className="animate-spin rounded-full h-8 w-8 border-2 border-blue-600 border-t-transparent mx-auto mb-4" />
                <p className="text-gray-600">Carregando histórico...</p>
              </div>
            ) : caixas.length === 0 ? (
              <div className="p-8 text-center">
                <Clock className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <p className="text-gray-600 text-lg">Nenhum histórico de caixa encontrado</p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead className="bg-gray-50 border-b">
                    <tr>
                      <th className="text-left py-3 px-4 font-medium text-gray-700">Data Abertura</th>
                      <th className="text-left py-3 px-4 font-medium text-gray-700">Data Fechamento</th>
                      <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                      <th className="text-left py-3 px-4 font-medium text-gray-700">Valor Inicial</th>
                      <th className="text-left py-3 px-4 font-medium text-gray-700">Valor Final</th>
                      <th className="text-left py-3 px-4 font-medium text-gray-700">Diferença</th>
                      <th className="text-left py-3 px-4 font-medium text-gray-700">Movimentações</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200">
                    {caixas.map((caixa: any) => (
                      <tr key={caixa.id} className="hover:bg-gray-50">
                        <td className="py-3 px-4 text-sm text-gray-900">
                          {formatDate(caixa.data_abertura)}
                        </td>
                        <td className="py-3 px-4 text-sm text-gray-500">
                          {caixa.data_fechamento ? formatDate(caixa.data_fechamento) : '-'}
                        </td>
                        <td className="py-3 px-4">
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                            caixa.status === 'aberto'
                              ? 'bg-green-100 text-green-800'
                              : 'bg-gray-100 text-gray-800'
                          }`}>
                            {caixa.status === 'aberto' ? 'Aberto' : 'Fechado'}
                          </span>
                        </td>
                        <td className="py-3 px-4 text-sm text-gray-900">
                          {formatCurrency(caixa.valor_inicial)}
                        </td>
                        <td className="py-3 px-4 text-sm text-gray-900">
                          {caixa.valor_final ? formatCurrency(caixa.valor_final) : '-'}
                        </td>
                        <td className="py-3 px-4 text-sm">
                          {caixa.diferenca !== undefined ? (
                            <span className={caixa.diferenca >= 0 ? 'text-green-600' : 'text-red-600'}>
                              {formatCurrency(caixa.diferenca)}
                            </span>
                          ) : '-'}
                        </td>
                        <td className="py-3 px-4 text-sm text-gray-500">
                          {caixa.total_movimentacoes}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Modais */}
      {showAbrirCaixaModal && <AbrirCaixaModal />}
      {showFecharCaixaModal && <FecharCaixaModal />}
      {showMovimentacaoModal && <MovimentacaoModal />}
    </div>
  )
}
