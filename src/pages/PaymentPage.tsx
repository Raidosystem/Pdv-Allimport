import React, { useState } from 'react'
import { QrCode, CreditCard, CheckCircle, AlertCircle } from 'lucide-react'
import PaymentStatusMonitor from '../components/PaymentStatusMonitor'

interface PaymentPageProps {
  userEmail: string // Email do usuário
}

export const PaymentPage: React.FC<PaymentPageProps> = ({ userEmail }) => {
  const [selectedMethod, setSelectedMethod] = useState<'pix' | 'card' | null>(null)
  const [loading, setLoading] = useState(false)
  const [paymentData, setPaymentData] = useState<any>(null)
  const [error, setError] = useState<string | null>(null)

  const createPixPayment = async () => {
    setLoading(true)
    setError(null)

    try {
      const response = await fetch('/api/payments/create-pix', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user_email: userEmail,
          payer_email: userEmail,
          amount: 59.90,
          plan_days: 31
        })
      })

      if (!response.ok) {
        throw new Error(`Erro HTTP: ${response.status}`)
      }

      const data = await response.json()
      setPaymentData(data)
      
      // Redirecionar para o checkout do MercadoPago
      if (data.init_point) {
        window.open(data.init_point, '_blank')
      }

    } catch (err) {
      console.error('Erro ao criar PIX:', err)
      setError(err instanceof Error ? err.message : 'Erro desconhecido')
    } finally {
      setLoading(false)
    }
  }

  const createCardPayment = async (cardToken: string) => {
    setLoading(true)
    setError(null)

    try {
      const response = await fetch('/api/payments/create-card', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user_email: userEmail,
          payer_email: userEmail,
          card_token: cardToken,
          amount: 59.90,
          plan_days: 31
        })
      })

      if (!response.ok) {
        throw new Error(`Erro HTTP: ${response.status}`)
      }

      const data = await response.json()
      setPaymentData(data)

    } catch (err) {
      console.error('Erro ao criar pagamento cartão:', err)
      setError(err instanceof Error ? err.message : 'Erro desconhecido')
    } finally {
      setLoading(false)
    }
  }

  const onPaymentApproved = (approvedPayment: any) => {
    console.log('🎉 Pagamento aprovado em tempo real!', approvedPayment)
    // Aqui você pode redirecionar para o sistema ou atualizar UI
    alert('🎉 Pagamento aprovado! Sua assinatura foi ativada!')
  }

  if (paymentData) {
    return (
      <div className="max-w-2xl mx-auto p-6 space-y-6">
        <div className="text-center">
          <CheckCircle className="w-16 h-16 text-green-500 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-900">
            Pagamento Iniciado
          </h1>
          <p className="text-gray-600 mt-2">
            {selectedMethod === 'pix' 
              ? 'Complete o pagamento PIX na aba que foi aberta'
              : 'Processando seu pagamento...'
            }
          </p>
        </div>

        {/* Monitor de Status em Tempo Real */}
        <PaymentStatusMonitor
          userEmail={userEmail}
          paymentId={paymentData.payment_id}
          onPaymentApproved={onPaymentApproved}
        />

        {selectedMethod === 'pix' && (
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <h3 className="font-semibold text-blue-900 mb-2">
              🔥 Sistema Automático Ativo!
            </h3>
            <ul className="text-sm text-blue-800 space-y-1">
              <li>✅ Webhook configurado para {paymentData.webhook_url}</li>
              <li>✅ PIX = accredited → Credita 31 dias instantaneamente</li>
              <li>✅ Status atualiza em tempo real nesta página</li>
              <li>✅ Sistema libera acesso automaticamente</li>
            </ul>
          </div>
        )}

        <button
          onClick={() => window.location.reload()}
          className="w-full bg-gray-500 text-white py-3 px-4 rounded-lg hover:bg-gray-600 transition-colors"
        >
          Tentar Outro Pagamento
        </button>
      </div>
    )
  }

  return (
    <div className="max-w-md mx-auto p-6 space-y-6">
      <div className="text-center">
        <h1 className="text-2xl font-bold text-gray-900 mb-2">
          Ativar Assinatura
        </h1>
        <p className="text-gray-600">
          RaVal pdv - 31 dias por R$ 59,90
        </p>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <div className="flex items-center space-x-2">
            <AlertCircle className="w-5 h-5 text-red-500" />
            <span className="text-red-700">{error}</span>
          </div>
        </div>
      )}

      <div className="space-y-4">
        <button
          onClick={() => setSelectedMethod('pix')}
          disabled={loading}
          className="w-full bg-green-600 text-white py-4 px-4 rounded-lg hover:bg-green-700 transition-colors flex items-center justify-center space-x-2 disabled:opacity-50"
        >
          <QrCode className="w-5 h-5" />
          <span>Pagar com PIX</span>
        </button>

        <button
          onClick={() => setSelectedMethod('card')}
          disabled={loading}
          className="w-full bg-blue-600 text-white py-4 px-4 rounded-lg hover:bg-blue-700 transition-colors flex items-center justify-center space-x-2 disabled:opacity-50"
        >
          <CreditCard className="w-5 h-5" />
          <span>Pagar com Cartão</span>
        </button>
      </div>

      {selectedMethod === 'pix' && (
        <div className="bg-green-50 border border-green-200 rounded-lg p-4">
          <button
            onClick={createPixPayment}
            disabled={loading}
            className="w-full bg-green-600 text-white py-3 px-4 rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50"
          >
            {loading ? 'Gerando PIX...' : 'Gerar PIX'}
          </button>
        </div>
      )}

      {selectedMethod === 'card' && (
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <p className="text-sm text-blue-800 mb-3">
            Para pagamento com cartão, você precisaria integrar o Card Brick do MercadoPago aqui.
          </p>
          <button
            onClick={() => createCardPayment('fake-token-for-demo')}
            disabled={loading}
            className="w-full bg-blue-600 text-white py-3 px-4 rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50"
          >
            {loading ? 'Processando...' : 'Pagar com Cartão (Demo)'}
          </button>
        </div>
      )}

      <div className="text-xs text-gray-500 space-y-2">
        <div className="bg-gray-50 rounded p-3">
          <h4 className="font-semibold mb-1">🚀 Sistema Automático:</h4>
          <ul className="space-y-1">
            <li>• PIX aprovado = Libera na hora</li>
            <li>• Cartão aprovado = Libera na hora</li>
            <li>• Status atualiza em tempo real</li>
            <li>• Webhook processa automaticamente</li>
          </ul>
        </div>
      </div>
    </div>
  )
}

export default PaymentPage