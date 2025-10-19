import { useState, useEffect } from 'react'
import { Users, Calendar, Clock, Crown, AlertTriangle, Play, Pause, Plus, RefreshCw, TrendingUp } from 'lucide-react'
import { Button } from '../ui/Button'
import { supabase } from '../../lib/supabase'
import { useAuth } from '../../modules/auth'
import toast from 'react-hot-toast'

interface Subscriber {
  user_id: string
  email: string
  full_name?: string
  company_name?: string
  subscription: {
    id: string
    status: 'trial' | 'active' | 'expired' | 'cancelled' | 'pending'
    trial_start_date?: string
    trial_end_date?: string
    subscription_start_date?: string
    subscription_end_date?: string
    payment_status?: string
    days_remaining: number
    is_paused: boolean
    plan_type: string
  }
  created_at: string
}

interface DashboardStats {
  total_subscribers: number
  active_trials: number
  active_premium: number
  expired: number
  total_revenue_potential: number
}

export function AdminDashboard() {
  const { user } = useAuth()
  const [subscribers, setSubscribers] = useState<Subscriber[]>([])
  const [stats, setStats] = useState<DashboardStats>({
    total_subscribers: 0,
    active_trials: 0,
    active_premium: 0,
    expired: 0,
    total_revenue_potential: 0
  })
  const [loading, setLoading] = useState(true)
  const [selectedSubscriber, setSelectedSubscriber] = useState<Subscriber | null>(null)
  const [showAddDaysModal, setShowAddDaysModal] = useState(false)
  const [daysToAdd, setDaysToAdd] = useState(30)
  const [filterStatus, setFilterStatus] = useState<'all' | 'trial' | 'active' | 'expired'>('all')

  // Verificar se é admin
  const isAdmin = user?.email === 'admin@pdvallimport.com' || 
                  user?.email === 'novaradiosystem@outlook.com' || 
                  user?.app_metadata?.role === 'admin'

  useEffect(() => {
    if (isAdmin) {
      loadSubscribers()
      // Recarregar a cada 30 segundos para dados em tempo real
      const interval = setInterval(loadSubscribers, 30000)
      return () => clearInterval(interval)
    }
  }, [isAdmin])

  const loadSubscribers = async () => {
    try {
      setLoading(true)

      // Buscar todos os usuários com suas assinaturas (agora com email!)
      const { data: subscriptions, error } = await supabase
        .from('subscriptions')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) throw error

      // Buscar dados complementares dos usuários do user_approvals
      const userIds = subscriptions?.map(s => s.user_id) || []
      const { data: userApprovals } = await supabase
        .from('user_approvals')
        .select('user_id, email, full_name, company_name, created_at')
        .in('user_id', userIds)

      // Criar mapa de usuários
      const userMap = new Map()
      
      // Adiciona dados do user_approvals
      userApprovals?.forEach(u => {
        userMap.set(u.user_id, u)
      })

      // Combinar dados e calcular dias restantes em TEMPO REAL
      const now = new Date()
      const subscribersList: Subscriber[] = subscriptions?.map(sub => {
        // Pega dados do user_approvals OU usa email da subscription
        const userApprovalData = userMap.get(sub.user_id)
        const userData = {
          email: userApprovalData?.email || sub.email || `user_${sub.user_id.substring(0, 8)}`,
          full_name: userApprovalData?.full_name || null,
          company_name: userApprovalData?.company_name || null
        }
        
        // Calcular dias restantes em TEMPO REAL
        let daysRemaining = 0
        let endDate: Date | null = null

        if (sub.status === 'trial' && sub.trial_end_date) {
          endDate = new Date(sub.trial_end_date)
        } else if (sub.status === 'active' && sub.subscription_end_date) {
          endDate = new Date(sub.subscription_end_date)
        }

        if (endDate) {
          const diffTime = endDate.getTime() - now.getTime()
          daysRemaining = Math.max(0, Math.ceil(diffTime / (1000 * 60 * 60 * 24)))
        }

        // Verificar se está pausado
        const isPaused = sub.payment_status === 'paused' || false

        return {
          user_id: sub.user_id,
          email: userData.email,
          full_name: userData.full_name,
          company_name: userData.company_name,
          subscription: {
            id: sub.id,
            status: sub.status,
            trial_start_date: sub.trial_start_date,
            trial_end_date: sub.trial_end_date,
            subscription_start_date: sub.subscription_start_date,
            subscription_end_date: sub.subscription_end_date,
            payment_status: sub.payment_status,
            days_remaining: daysRemaining,
            is_paused: isPaused,
            plan_type: sub.status
          },
          created_at: userApprovalData?.created_at || sub.created_at
        }
      }) || []

      // Calcular estatísticas
      const statsData: DashboardStats = {
        total_subscribers: subscribersList.length,
        active_trials: subscribersList.filter(s => s.subscription.status === 'trial' && s.subscription.days_remaining > 0).length,
        active_premium: subscribersList.filter(s => s.subscription.status === 'active' && s.subscription.days_remaining > 0).length,
        expired: subscribersList.filter(s => s.subscription.days_remaining === 0).length,
        total_revenue_potential: subscribersList.filter(s => s.subscription.status === 'active').length * 59.90
      }

      setSubscribers(subscribersList)
      setStats(statsData)
      console.log('✅ Carregados', subscribersList.length, 'assinantes em tempo real')

    } catch (error) {
      console.error('Erro ao carregar assinantes:', error)
      toast.error('Erro ao carregar assinantes')
    } finally {
      setLoading(false)
    }
  }

  const togglePauseSubscription = async (subscriber: Subscriber) => {
    const action = subscriber.subscription.is_paused ? 'reativar' : 'pausar'
    const loadingToast = toast.loading(`${action === 'pausar' ? 'Pausando' : 'Reativando'} assinatura...`)

    try {
      const newStatus = subscriber.subscription.is_paused ? 'pending' : 'paused'

      const { error } = await supabase
        .from('subscriptions')
        .update({ 
          payment_status: newStatus,
          updated_at: new Date().toISOString()
        })
        .eq('user_id', subscriber.user_id)

      if (error) throw error

      toast.dismiss(loadingToast)
      toast.success(`✅ Assinatura ${action === 'pausar' ? 'pausada' : 'reativada'} com sucesso!`)
      await loadSubscribers() // Recarregar dados
    } catch (error) {
      console.error('Erro ao alterar status:', error)
      toast.dismiss(loadingToast)
      toast.error(`Erro ao ${action} assinatura`)
    }
  }

  const openAddDaysModal = (subscriber: Subscriber) => {
    setSelectedSubscriber(subscriber)
    setShowAddDaysModal(true)
    setDaysToAdd(30)
  }

  const closeAddDaysModal = () => {
    setShowAddDaysModal(false)
    setSelectedSubscriber(null)
    setDaysToAdd(30)
  }

  const addDays = async () => {
    if (!selectedSubscriber || daysToAdd <= 0) {
      toast.error('Selecione um número válido de dias')
      return
    }

    const loadingToast = toast.loading('Adicionando dias...')

    try {
      // Calcular nova data de expiração
      const currentEndDate = selectedSubscriber.subscription.status === 'trial'
        ? new Date(selectedSubscriber.subscription.trial_end_date || Date.now())
        : new Date(selectedSubscriber.subscription.subscription_end_date || Date.now())

      const newEndDate = new Date(currentEndDate.getTime() + (daysToAdd * 24 * 60 * 60 * 1000))

      // Atualizar no banco
      const updateData: any = { updated_at: new Date().toISOString() }

      if (selectedSubscriber.subscription.status === 'trial') {
        updateData.trial_end_date = newEndDate.toISOString()
      } else {
        updateData.subscription_end_date = newEndDate.toISOString()
      }

      const { error } = await supabase
        .from('subscriptions')
        .update(updateData)
        .eq('user_id', selectedSubscriber.user_id)

      if (error) throw error

      toast.dismiss(loadingToast)
      toast.success(`✅ ${daysToAdd} dias adicionados para ${selectedSubscriber.full_name || selectedSubscriber.email}!`)
      
      closeAddDaysModal()
      await loadSubscribers() // Recarregar dados
    } catch (error) {
      console.error('Erro ao adicionar dias:', error)
      toast.dismiss(loadingToast)
      toast.error('Erro ao adicionar dias')
    }
  }

  const getStatusColor = (subscriber: Subscriber) => {
    if (subscriber.subscription.is_paused) return 'bg-gray-100 border-gray-300'
    if (subscriber.subscription.days_remaining === 0) return 'bg-red-50 border-red-300'
    if (subscriber.subscription.days_remaining <= 5) return 'bg-orange-50 border-orange-300'
    if (subscriber.subscription.status === 'trial') return 'bg-blue-50 border-blue-300'
    return 'bg-green-50 border-green-300'
  }

  const getStatusBadge = (subscriber: Subscriber) => {
    if (subscriber.subscription.is_paused) {
      return <span className="px-3 py-1 bg-gray-600 text-white text-xs font-bold rounded-full">⏸️ PAUSADO</span>
    }
    if (subscriber.subscription.days_remaining === 0) {
      return <span className="px-3 py-1 bg-red-600 text-white text-xs font-bold rounded-full">❌ EXPIRADO</span>
    }
    if (subscriber.subscription.status === 'trial') {
      return <span className="px-3 py-1 bg-blue-600 text-white text-xs font-bold rounded-full">🎁 TESTE</span>
    }
    return <span className="px-3 py-1 bg-green-600 text-white text-xs font-bold rounded-full">⭐ PREMIUM</span>
  }

  const filteredSubscribers = subscribers.filter(s => {
    if (filterStatus === 'all') return true
    if (filterStatus === 'trial') return s.subscription.status === 'trial' && s.subscription.days_remaining > 0
    if (filterStatus === 'active') return s.subscription.status === 'active' && s.subscription.days_remaining > 0
    if (filterStatus === 'expired') return s.subscription.days_remaining === 0
    return true
  })

  if (!isAdmin) {
    return (
      <div className="p-8 text-center">
        <AlertTriangle className="w-16 h-16 mx-auto mb-4 text-red-600" />
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Acesso Negado</h2>
        <p className="text-gray-600">Você não tem permissão para acessar o painel admin.</p>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2 flex items-center gap-3">
            <Crown className="w-10 h-10 text-yellow-600" />
            Painel de Controle de Assinantes
          </h1>
          <p className="text-gray-600 text-lg">Gerencie todos os assinantes do sistema em tempo real</p>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-5 gap-6 mb-8">
          <div className="bg-white rounded-2xl shadow-lg p-6 border-2 border-blue-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-semibold text-gray-600">Total</p>
                <p className="text-3xl font-bold text-blue-600">{stats.total_subscribers}</p>
              </div>
              <Users className="w-12 h-12 text-blue-600 opacity-50" />
            </div>
          </div>

          <div className="bg-white rounded-2xl shadow-lg p-6 border-2 border-purple-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-semibold text-gray-600">Em Teste</p>
                <p className="text-3xl font-bold text-purple-600">{stats.active_trials}</p>
              </div>
              <Clock className="w-12 h-12 text-purple-600 opacity-50" />
            </div>
          </div>

          <div className="bg-white rounded-2xl shadow-lg p-6 border-2 border-green-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-semibold text-gray-600">Premium</p>
                <p className="text-3xl font-bold text-green-600">{stats.active_premium}</p>
              </div>
              <Crown className="w-12 h-12 text-green-600 opacity-50" />
            </div>
          </div>

          <div className="bg-white rounded-2xl shadow-lg p-6 border-2 border-red-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-semibold text-gray-600">Expirados</p>
                <p className="text-3xl font-bold text-red-600">{stats.expired}</p>
              </div>
              <AlertTriangle className="w-12 h-12 text-red-600 opacity-50" />
            </div>
          </div>

          <div className="bg-white rounded-2xl shadow-lg p-6 border-2 border-yellow-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-semibold text-gray-600">Receita Mensal</p>
                <p className="text-2xl font-bold text-yellow-600">R$ {stats.total_revenue_potential.toFixed(2)}</p>
              </div>
              <TrendingUp className="w-12 h-12 text-yellow-600 opacity-50" />
            </div>
          </div>
        </div>

        {/* Filters and Refresh */}
        <div className="bg-white rounded-2xl shadow-lg p-6 mb-6">
          <div className="flex flex-wrap items-center justify-between gap-4">
            <div className="flex gap-2">
              <button
                onClick={() => setFilterStatus('all')}
                className={`px-4 py-2 rounded-lg font-semibold transition-all ${
                  filterStatus === 'all' 
                    ? 'bg-blue-600 text-white' 
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                Todos ({subscribers.length})
              </button>
              <button
                onClick={() => setFilterStatus('trial')}
                className={`px-4 py-2 rounded-lg font-semibold transition-all ${
                  filterStatus === 'trial' 
                    ? 'bg-purple-600 text-white' 
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                🎁 Testes ({stats.active_trials})
              </button>
              <button
                onClick={() => setFilterStatus('active')}
                className={`px-4 py-2 rounded-lg font-semibold transition-all ${
                  filterStatus === 'active' 
                    ? 'bg-green-600 text-white' 
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                ⭐ Premium ({stats.active_premium})
              </button>
              <button
                onClick={() => setFilterStatus('expired')}
                className={`px-4 py-2 rounded-lg font-semibold transition-all ${
                  filterStatus === 'expired' 
                    ? 'bg-red-600 text-white' 
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                ❌ Expirados ({stats.expired})
              </button>
            </div>

            <Button
              onClick={loadSubscribers}
              disabled={loading}
              variant="secondary"
              className="shadow-md"
            >
              <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
              Atualizar Dados
            </Button>
          </div>
        </div>

        {/* Subscribers List - TABELA COMPACTA */}
        {loading ? (
          <div className="flex items-center justify-center py-20">
            <div className="text-center">
              <div className="animate-spin rounded-full h-16 w-16 border-b-4 border-blue-600 mx-auto mb-4"></div>
              <p className="text-gray-600 font-medium">Carregando assinantes em tempo real...</p>
            </div>
          </div>
        ) : filteredSubscribers.length === 0 ? (
          <div className="bg-white rounded-2xl shadow-lg p-12 text-center">
            <Users className="w-16 h-16 mx-auto mb-4 text-gray-400" />
            <h3 className="text-xl font-bold text-gray-900 mb-2">Nenhum assinante encontrado</h3>
            <p className="text-gray-600">Não há assinantes neste filtro</p>
          </div>
        ) : (
          <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gradient-to-r from-blue-600 to-indigo-700">
                  <tr>
                    <th className="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">
                      Assinante
                    </th>
                    <th className="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-4 text-center text-xs font-bold text-white uppercase tracking-wider">
                      Dias Restantes
                    </th>
                    <th className="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">
                      Tipo
                    </th>
                    <th className="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">
                      Vencimento
                    </th>
                    <th className="px-6 py-4 text-center text-xs font-bold text-white uppercase tracking-wider">
                      Ações
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredSubscribers.map((subscriber, index) => (
                    <tr 
                      key={subscriber.user_id}
                      className={`hover:bg-gray-50 transition-colors ${
                        index % 2 === 0 ? 'bg-white' : 'bg-gray-50'
                      }`}
                    >
                      {/* Assinante */}
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="flex-shrink-0 h-10 w-10 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-full flex items-center justify-center text-white font-bold">
                            {((subscriber.full_name || subscriber.email || 'U').charAt(0)).toUpperCase()}
                          </div>
                          <div className="ml-4">
                            <div className="text-sm font-bold text-gray-900">
                              {subscriber.full_name || (subscriber.email ? subscriber.email.split('@')[0] : 'Sem nome')}
                            </div>
                            <div className="text-xs text-gray-500">{subscriber.email || 'Sem email'}</div>
                            {subscriber.company_name && (
                              <div className="text-xs text-gray-400">🏢 {subscriber.company_name}</div>
                            )}
                          </div>
                        </div>
                      </td>

                      {/* Status */}
                      <td className="px-6 py-4 whitespace-nowrap">
                        {getStatusBadge(subscriber)}
                      </td>

                      {/* Dias Restantes */}
                      <td className="px-6 py-4 whitespace-nowrap text-center">
                        <span className={`text-2xl font-bold ${
                          subscriber.subscription.days_remaining === 0 ? 'text-red-600' :
                          subscriber.subscription.days_remaining <= 5 ? 'text-orange-600' :
                          subscriber.subscription.days_remaining <= 10 ? 'text-yellow-600' :
                          'text-green-600'
                        }`}>
                          {subscriber.subscription.days_remaining}
                        </span>
                        <div className="text-xs text-gray-500">dias</div>
                      </td>

                      {/* Tipo */}
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="text-sm font-semibold text-gray-900">
                          {subscriber.subscription.status === 'trial' ? '🎁 Teste' : '⭐ Premium'}
                        </span>
                      </td>

                      {/* Vencimento */}
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="text-sm font-medium text-gray-900">
                          {subscriber.subscription.status === 'trial' && subscriber.subscription.trial_end_date
                            ? new Date(subscriber.subscription.trial_end_date).toLocaleDateString('pt-BR')
                            : subscriber.subscription.subscription_end_date
                            ? new Date(subscriber.subscription.subscription_end_date).toLocaleDateString('pt-BR')
                            : 'Não definido'}
                        </span>
                      </td>

                      {/* Ações */}
                      <td className="px-6 py-4 whitespace-nowrap text-center">
                        <div className="flex gap-2 justify-center">
                          <button
                            onClick={() => openAddDaysModal(subscriber)}
                            className="inline-flex items-center px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold rounded-lg transition-colors"
                            title="Adicionar dias"
                          >
                            <Plus className="w-3 h-3 mr-1" />
                            Dias
                          </button>
                          <button
                            onClick={() => togglePauseSubscription(subscriber)}
                            className={`inline-flex items-center px-3 py-1.5 text-xs font-semibold rounded-lg transition-colors ${
                              subscriber.subscription.is_paused
                                ? 'bg-green-600 hover:bg-green-700 text-white'
                                : 'bg-orange-600 hover:bg-orange-700 text-white'
                            }`}
                            title={subscriber.subscription.is_paused ? 'Reativar' : 'Pausar'}
                          >
                            {subscriber.subscription.is_paused ? (
                              <>
                                <Play className="w-3 h-3 mr-1" />
                                Reativar
                              </>
                            ) : (
                              <>
                                <Pause className="w-3 h-3 mr-1" />
                                Pausar
                              </>
                            )}
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Modal Add Days */}
        {showAddDaysModal && selectedSubscriber && (
          <div className="fixed inset-0 z-50 overflow-y-auto">
            <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20">
              <div className="fixed inset-0 bg-black bg-opacity-50 transition-opacity backdrop-blur-sm" onClick={closeAddDaysModal}></div>
              
              <div className="relative bg-white rounded-2xl shadow-2xl max-w-2xl w-full">
                {/* Header */}
                <div className="bg-gradient-to-r from-blue-600 to-indigo-700 text-white px-8 py-6 rounded-t-2xl">
                  <h2 className="text-2xl font-bold">➕ Adicionar Dias de Assinatura</h2>
                  <p className="text-blue-100 mt-1">{selectedSubscriber.full_name || selectedSubscriber.email}</p>
                </div>

                <div className="p-8">
                  {/* Status Atual */}
                  <div className="mb-6 p-4 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl border-2 border-blue-200">
                    <h3 className="font-bold text-blue-900 mb-3">📊 Status Atual</h3>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="bg-white p-3 rounded-lg">
                        <p className="text-xs text-gray-600 mb-1">Plano</p>
                        <p className="font-bold text-blue-900">
                          {selectedSubscriber.subscription.status === 'trial' ? '🎁 TESTE' : '⭐ PREMIUM'}
                        </p>
                      </div>
                      <div className="bg-white p-3 rounded-lg">
                        <p className="text-xs text-gray-600 mb-1">Dias Restantes</p>
                        <p className={`font-bold ${
                          selectedSubscriber.subscription.days_remaining <= 5 ? 'text-red-600' : 'text-green-600'
                        }`}>
                          {selectedSubscriber.subscription.days_remaining} dias
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Input de Dias */}
                  <div className="mb-6">
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                      Quantidade de Dias
                    </label>
                    <input
                      type="number"
                      value={daysToAdd}
                      onChange={(e) => setDaysToAdd(parseInt(e.target.value) || 0)}
                      min="1"
                      max="3650"
                      className="w-full px-4 py-3 text-lg font-bold border-2 border-gray-300 rounded-xl focus:outline-none focus:border-blue-500 transition-colors text-center"
                    />
                  </div>

                  {/* Botões Rápidos */}
                  <div className="mb-6">
                    <label className="block text-sm font-semibold text-gray-700 mb-2">Atalhos Rápidos</label>
                    <div className="grid grid-cols-4 gap-3">
                      <button
                        onClick={() => setDaysToAdd(7)}
                        className="px-4 py-3 bg-gray-100 hover:bg-blue-500 hover:text-white border-2 border-gray-300 rounded-xl font-bold transition-all"
                      >
                        7 dias
                      </button>
                      <button
                        onClick={() => setDaysToAdd(30)}
                        className="px-4 py-3 bg-gray-100 hover:bg-blue-500 hover:text-white border-2 border-gray-300 rounded-xl font-bold transition-all"
                      >
                        30 dias
                      </button>
                      <button
                        onClick={() => setDaysToAdd(90)}
                        className="px-4 py-3 bg-gray-100 hover:bg-blue-500 hover:text-white border-2 border-gray-300 rounded-xl font-bold transition-all"
                      >
                        90 dias
                      </button>
                      <button
                        onClick={() => setDaysToAdd(365)}
                        className="px-4 py-3 bg-gray-100 hover:bg-blue-500 hover:text-white border-2 border-gray-300 rounded-xl font-bold transition-all"
                      >
                        1 ano
                      </button>
                    </div>
                  </div>

                  {/* Preview */}
                  {daysToAdd > 0 && (
                    <div className="p-4 bg-green-50 border-2 border-green-300 rounded-xl mb-6">
                      <p className="text-sm text-green-800 mb-1 font-semibold">✨ Nova Expiração:</p>
                      <p className="text-2xl font-bold text-green-900">
                        {(() => {
                          const currentEnd = selectedSubscriber.subscription.status === 'trial'
                            ? new Date(selectedSubscriber.subscription.trial_end_date || Date.now())
                            : new Date(selectedSubscriber.subscription.subscription_end_date || Date.now())
                          const newEnd = new Date(currentEnd.getTime() + (daysToAdd * 24 * 60 * 60 * 1000))
                          return newEnd.toLocaleDateString('pt-BR')
                        })()}
                      </p>
                      <p className="text-xs text-green-700 mt-1">
                        Total: {selectedSubscriber.subscription.days_remaining + daysToAdd} dias
                      </p>
                    </div>
                  )}

                  {/* Botões */}
                  <div className="flex gap-4">
                    <button
                      onClick={closeAddDaysModal}
                      className="flex-1 px-6 py-4 text-sm font-semibold text-gray-700 bg-gray-100 border-2 border-gray-300 rounded-xl hover:bg-gray-200 transition-all"
                    >
                      Cancelar
                    </button>
                    <button
                      onClick={addDays}
                      disabled={daysToAdd <= 0}
                      className="flex-1 px-6 py-4 text-sm font-semibold text-white bg-gradient-to-r from-green-600 to-green-700 rounded-xl hover:from-green-700 hover:to-green-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-lg hover:shadow-xl"
                    >
                      ✅ Adicionar {daysToAdd} Dias
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
