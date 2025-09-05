import React, { useState, useEffect } from 'react'
import { toast } from 'react-hot-toast'
import { SubscriptionService } from '../../services/subscriptionService'
import { useAuth } from '../../modules/auth'

interface PaymentDebugData {
  subscription: any
  latest_payment: any
  subscription_active: boolean
  payment_approved: boolean
  needs_activation: boolean
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
      const data = await SubscriptionService.checkFullStatus(user.email)
      setDebugData(data)
      console.log('🔍 Status completo:', data)
    } catch (error) {
      console.error('Erro ao verificar status:', error)
      toast.error('Erro ao verificar status')
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
              <button
                onClick={forceActivation}
                disabled={activating}
                className="px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 disabled:opacity-50"
              >
                {activating ? 'Ativando...' : 'Ativar Assinatura Agora'}
              </button>
            </div>
          )}

          {/* Status OK */}
          {debugData.subscription_active && debugData.payment_approved && (
            <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
              <h4 className="font-medium text-green-800 mb-2">✅ Tudo OK!</h4>
              <p className="text-sm text-green-700">
                Sua assinatura está ativa e funcionando corretamente.
              </p>
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
