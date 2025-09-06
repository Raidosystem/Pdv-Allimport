import React, { useState, useEffect } from 'react'
import { toast } from 'react-hot-toast'
import { SubscriptionService } from '../../services/subscriptionService'
import { useAuth } from '../../modules/auth'
import { supabase } from '../../lib/supabase'

interface PaymentDebugData {
  subscription: any
  latest_payment: any
  payments_history?: any[]
  subscription_active: boolean
  payment_approved: boolean
  needs_activation: boolean
  access_allowed?: boolean
  error?: string
  debug_info?: {
    has_subscription: boolean
    subscription_status: string
    payment_count: number
    latest_payment_status: string
    errors?: {
      subscription_error?: string
      payment_error?: string
    }
  }
}

export const PaymentDebugger: React.FC = () => {
  const { user } = useAuth()
  const [debugData, setDebugData] = useState<PaymentDebugData | null>(null)
  const [loading, setLoading] = useState(false)
  const [activating, setActivating] = useState(false)

  const checkStatus = async () => {
    if (!user?.email) {
      toast.error('Usuário não encontrado')
      return
    }

    setLoading(true)
    try {
      console.log('🔍 Verificando status para:', user.email)
      
      // Tentar usar a API simples primeiro (não depende de RPC)
      try {
        const response = await fetch(`/api/subscription/simple-status?email=${encodeURIComponent(user.email)}`)
        if (response.ok) {
          const data = await response.json()
          setDebugData(data)
          console.log('✅ Status via API simples:', data)
          return
        } else {
          console.warn('⚠️ API simples falhou:', response.status)
        }
      } catch (apiError) {
        console.warn('⚠️ API simples falhou:', apiError)
      }

      // Tentar usar a API original como segunda opção
      try {
        const data = await SubscriptionService.checkFullStatus(user.email)
        setDebugData(data)
        console.log('✅ Status via API original:', data)
        return
      } catch (apiError) {
        console.warn('⚠️ API original falhou, tentando método direto:', apiError)
      }

      // Fallback: buscar dados diretamente via supabase
      const { data: subscription } = await supabase
        .from('subscriptions')
        .select('*')
        .eq('email', user.email)
        .single()

      const { data: payments } = await supabase
        .from('payments')
        .select('*')
        .eq('payer_email', user.email)
        .order('created_at', { ascending: false })

      const latestPayment = payments?.[0]

      const fallbackData = {
        subscription: subscription || null,
        latest_payment: latestPayment || null,
        subscription_active: subscription?.status === 'active',
        payment_approved: latestPayment?.mp_status === 'approved',
        needs_activation: subscription && latestPayment && 
                         latestPayment.mp_status === 'approved' && 
                         subscription.status !== 'active'
      }

      setDebugData(fallbackData)
      console.log('✅ Status via fallback direto:', fallbackData)
      
    } catch (error) {
      console.error('❌ Erro ao verificar status:', error)
      const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido'
      toast.error(`Erro ao verificar status: ${errorMessage}`)
      
      // Tentar mostrar pelo menos informações básicas do usuário
      setDebugData({
        subscription: null,
        latest_payment: null,
        subscription_active: false,
        payment_approved: false,
        needs_activation: false,
        error: errorMessage
      })
    } finally {
      setLoading(false)
    }
  }

  const forceActivation = async () => {
    if (!user?.email) {
      toast.error('Usuário não encontrado')
      return
    }

    if (!debugData?.latest_payment?.mp_payment_id) {
      toast.error('Nenhum pagamento encontrado')
      return
    }

    setActivating(true)
    try {
      const result = await SubscriptionService.forceActivation(
        user.email,
        debugData.latest_payment.mp_payment_id
      )
      console.log('✅ Ativação forçada:', result)
      toast.success('Assinatura ativada com sucesso!')
      
      // Aguardar um pouco e recarregar
      setTimeout(() => {
        window.location.reload()
      }, 2000)
    } catch (error: any) {
      console.error('Erro ao forçar ativação:', error)
      toast.error(error.message || 'Erro ao ativar assinatura')
    } finally {
      setActivating(false)
    }
  }

  const emergencyBypass = async () => {
    if (!user?.email) {
      toast.error('Usuário não encontrado')
      return
    }

    const adminEmail = prompt('🔐 Digite o email de admin para autorizar o bypass:')
    if (!adminEmail) return

    setActivating(true)
    try {
      const response = await fetch('/api/admin/emergency-bypass', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email: user.email,
          admin_email: adminEmail
        })
      })

      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.error || `HTTP ${response.status}`)
      }

      const result = await response.json()
      console.log('🆘 Bypass de emergência:', result)
      toast.success('Acesso liberado via bypass administrativo!')
      
      // Aguardar um pouco e recarregar
      setTimeout(() => {
        window.location.reload()
      }, 2000)
    } catch (error: any) {
      console.error('Erro no bypass:', error)
      toast.error(error.message || 'Erro no bypass de emergência')
    } finally {
      setActivating(false)
    }
  }

  useEffect(() => {
    if (user?.email) {
      checkStatus()
    }
  }, [user?.email])

  if (!user?.email) {
    return (
      <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
        <p className="text-yellow-800">Usuário não autenticado</p>
      </div>
    )
  }

  return (
    <div className="p-6 bg-white border border-gray-200 rounded-lg shadow-sm">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-medium">Debug do Pagamento PIX</h3>
        <button
          onClick={checkStatus}
          disabled={loading}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
        >
          {loading ? 'Verificando...' : 'Atualizar Status'}
        </button>
      </div>

      {debugData && (
        <div className="space-y-4">
          {/* Mostrar erro se houver */}
          {debugData.error && (
            <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
              <h4 className="font-medium text-red-800 mb-2">❌ Erro Detectado</h4>
              <p className="text-sm text-red-700">{debugData.error}</p>
              <p className="text-xs text-red-600 mt-2">
                Tentando buscar dados com método alternativo...
              </p>
            </div>
          )}

          {/* Status Geral */}
          <div className="grid grid-cols-2 gap-4">
            <div className={`p-3 rounded-lg ${debugData.subscription_active ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'}`}>
              <h4 className="font-medium text-sm">Assinatura Ativa</h4>
              <p className={`text-lg font-bold ${debugData.subscription_active ? 'text-green-800' : 'text-red-800'}`}>
                {debugData.subscription_active ? 'SIM' : 'NÃO'}
              </p>
            </div>
            <div className={`p-3 rounded-lg ${debugData.payment_approved ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'}`}>
              <h4 className="font-medium text-sm">Pagamento Aprovado</h4>
              <p className={`text-lg font-bold ${debugData.payment_approved ? 'text-green-800' : 'text-red-800'}`}>
                {debugData.payment_approved ? 'SIM' : 'NÃO'}
              </p>
            </div>
          </div>

          {/* Assinatura */}
          {debugData.subscription && (
            <div className="p-4 bg-gray-50 border border-gray-200 rounded-lg">
              <h4 className="font-medium mb-2">Dados da Assinatura</h4>
              <div className="text-sm space-y-1">
                <p><strong>Status:</strong> {debugData.subscription.status}</p>
                <p><strong>Email:</strong> {debugData.subscription.email}</p>
                <p><strong>Início:</strong> {debugData.subscription.subscription_start_date || 'N/A'}</p>
                <p><strong>Fim:</strong> {debugData.subscription.subscription_end_date || 'N/A'}</p>
                <p><strong>Pagamento:</strong> {debugData.subscription.payment_status}</p>
              </div>
            </div>
          )}

          {/* Último Pagamento */}
          {debugData.latest_payment && (
            <div className="p-4 bg-gray-50 border border-gray-200 rounded-lg">
              <h4 className="font-medium mb-2">Último Pagamento</h4>
              <div className="text-sm space-y-1">
                <p><strong>ID:</strong> {debugData.latest_payment.mp_payment_id}</p>
                <p><strong>Status MP:</strong> {debugData.latest_payment.mp_status}</p>
                <p><strong>Valor:</strong> R$ {debugData.latest_payment.amount}</p>
                <p><strong>Método:</strong> {debugData.latest_payment.payment_method}</p>
                <p><strong>Data:</strong> {new Date(debugData.latest_payment.created_at).toLocaleString()}</p>
              </div>
            </div>
          )}

          {/* Ação de Ativação */}
          {debugData.needs_activation && (
            <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
              <h4 className="font-medium text-yellow-800 mb-2">⚠️ Ativação Necessária</h4>
              <p className="text-sm text-yellow-700 mb-3">
                Seu pagamento foi aprovado, mas a assinatura ainda não foi ativada automaticamente.
              </p>
              <div className="flex gap-2">
                <button
                  onClick={forceActivation}
                  disabled={activating}
                  className="px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 disabled:opacity-50"
                >
                  {activating ? 'Ativando...' : 'Ativar Assinatura Agora'}
                </button>
                <button
                  onClick={emergencyBypass}
                  disabled={activating}
                  className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 text-sm"
                >
                  🆘 Bypass Emergência
                </button>
              </div>
            </div>
          )}

          {/* Bypass de Emergência - sempre disponível */}
          <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
            <h4 className="font-medium text-red-800 mb-2">🆘 Acesso de Emergência</h4>
            <p className="text-sm text-red-700 mb-3">
              Se o sistema estiver travado, use o bypass administrativo (apenas para admins).
            </p>
            <button
              onClick={emergencyBypass}
              disabled={activating}
              className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50"
            >
              {activating ? 'Processando...' : 'Bypass Administrativo'}
            </button>
          </div>

          {/* Status OK */}
          {debugData.subscription_active && debugData.payment_approved && (
            <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
              <h4 className="font-medium text-green-800 mb-2">✅ Tudo OK!</h4>
              <p className="text-sm text-green-700">
                Sua assinatura está ativa e funcionando corretamente.
              </p>
            </div>
          )}

          {/* Debug Info Adicional */}
          {debugData.debug_info && (
            <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
              <h4 className="font-medium text-blue-800 mb-2">🔧 Informações de Debug</h4>
              <div className="text-sm space-y-1 text-blue-700">
                <p><strong>Tem Assinatura:</strong> {debugData.debug_info.has_subscription ? 'Sim' : 'Não'}</p>
                <p><strong>Status:</strong> {debugData.debug_info.subscription_status || 'N/A'}</p>
                <p><strong>Qtd Pagamentos:</strong> {debugData.debug_info.payment_count}</p>
                <p><strong>Status Último Pagamento:</strong> {debugData.debug_info.latest_payment_status || 'N/A'}</p>
                {debugData.debug_info.errors?.subscription_error && (
                  <p className="text-red-600"><strong>Erro Assinatura:</strong> {debugData.debug_info.errors.subscription_error}</p>
                )}
                {debugData.debug_info.errors?.payment_error && (
                  <p className="text-red-600"><strong>Erro Pagamento:</strong> {debugData.debug_info.errors.payment_error}</p>
                )}
              </div>
            </div>
          )}

          {/* Histórico de Pagamentos */}
          {debugData.payments_history && debugData.payments_history.length > 1 && (
            <div className="p-4 bg-gray-50 border border-gray-200 rounded-lg">
              <h4 className="font-medium mb-2">📋 Histórico de Pagamentos</h4>
              <div className="space-y-2">
                {debugData.payments_history.slice(0, 3).map((payment: any) => (
                  <div key={payment.id} className="text-sm flex justify-between">
                    <span>#{payment.mp_payment_id?.slice(-6) || 'N/A'}</span>
                    <span className={payment.mp_status === 'approved' ? 'text-green-600' : 'text-yellow-600'}>
                      {payment.mp_status}
                    </span>
                    <span>R$ {payment.amount}</span>
                    <span>{new Date(payment.created_at).toLocaleDateString()}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {loading && (
        <div className="text-center py-4">
          <p className="text-gray-600">Carregando dados...</p>
        </div>
      )}
    </div>
  )
}
