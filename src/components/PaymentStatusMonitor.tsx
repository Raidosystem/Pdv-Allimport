import React, { useState, useEffect } from 'react'
import { createClient } from '@supabase/supabase-js'
import { CheckCircle, Clock, XCircle, CreditCard, Smartphone } from 'lucide-react'

interface PaymentStatusProps {
  empresaId: string
  paymentId?: number
  onPaymentApproved?: (paymentData: any) => void
}

interface Payment {
  id: string
  mp_payment_id: number
  empresa_id: string
  mp_status: string
  mp_status_detail: string
  payment_method: string
  amount: number
  subscription_days_added: number
  webhook_processed_at: string | null
  created_at: string
  updated_at: string
}

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://kmcaaqetxtwkdcczdomw.supabase.co',
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'
)

export const PaymentStatusMonitor: React.FC<PaymentStatusProps> = ({
  empresaId,
  paymentId,
  onPaymentApproved
}) => {
  const [payment, setPayment] = useState<Payment | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Buscar pagamento inicial
  useEffect(() => {
    const fetchPayment = async () => {
      try {
        let query = supabase
          .from('payments')
          .select('*')
          .eq('empresa_id', empresaId)
          .order('created_at', { ascending: false })

        if (paymentId) {
          query = query.eq('mp_payment_id', paymentId)
        }

        const { data, error } = await query.limit(1).single()

        if (error) {
          console.warn('Pagamento não encontrado ainda:', error.message)
          setPayment(null)
        } else {
          setPayment(data)
          
          // Se já foi aprovado, notificar
          if (data.mp_status === 'approved' && onPaymentApproved) {
            onPaymentApproved(data)
          }
        }
      } catch (err) {
        console.error('Erro ao buscar pagamento:', err)
        setError('Erro ao buscar status do pagamento')
      } finally {
        setLoading(false)
      }
    }

    fetchPayment()
  }, [empresaId, paymentId, onPaymentApproved])

  // Configurar Realtime para atualizações ao vivo
  useEffect(() => {
    const channel = supabase
      .channel('payment-updates')
      .on(
        'postgres_changes',
        {
          event: '*', // INSERT, UPDATE, DELETE
          schema: 'public',
          table: 'payments',
          filter: `empresa_id=eq.${empresaId}`
        },
        (payload) => {
          console.log('🔄 Atualização em tempo real:', payload)
          
          const newPayment = payload.new as Payment
          
          if (newPayment) {
            setPayment(newPayment)
            
            // Se foi aprovado agora, notificar
            if (newPayment.mp_status === 'approved' && onPaymentApproved) {
              onPaymentApproved(newPayment)
            }
          }
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [empresaId, onPaymentApproved])

  const getStatusIcon = () => {
    if (!payment) return <Clock className="w-6 h-6 text-yellow-500" />

    switch (payment.mp_status) {
      case 'approved':
        return <CheckCircle className="w-6 h-6 text-green-500" />
      case 'pending':
        return <Clock className="w-6 h-6 text-yellow-500" />
      case 'rejected':
      case 'cancelled':
        return <XCircle className="w-6 h-6 text-red-500" />
      default:
        return <Clock className="w-6 h-6 text-gray-500" />
    }
  }

  const getStatusMessage = () => {
    if (loading) return 'Carregando status do pagamento...'
    if (!payment) return 'Aguardando pagamento...'

    switch (payment.mp_status) {
      case 'approved':
        return `✅ Pagamento aprovado! ${payment.subscription_days_added} dias creditados.`
      case 'pending':
        return payment.payment_method === 'pix' 
          ? '⏳ Aguardando confirmação do PIX...' 
          : '⏳ Processando pagamento...'
      case 'rejected':
        return '❌ Pagamento rejeitado'
      case 'cancelled':
        return '❌ Pagamento cancelado'
      default:
        return `Status: ${payment.mp_status}`
    }
  }

  const getPaymentMethodIcon = () => {
    if (!payment) return null
    
    return payment.payment_method === 'pix' 
      ? <Smartphone className="w-4 h-4" />
      : <CreditCard className="w-4 h-4" />
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-4">
        <div className="flex items-center space-x-2">
          <XCircle className="w-5 h-5 text-red-500" />
          <span className="text-red-700">{error}</span>
        </div>
      </div>
    )
  }

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-gray-900">
          Status do Pagamento
        </h3>
        {getStatusIcon()}
      </div>

      <div className="space-y-3">
        <div className="flex items-center space-x-2 text-sm text-gray-600">
          {getPaymentMethodIcon()}
          <span>
            {payment?.payment_method === 'pix' ? 'PIX' : 'Cartão de Crédito'}
          </span>
          {payment && (
            <span className="font-medium">
              R$ {payment.amount.toFixed(2)}
            </span>
          )}
        </div>

        <div className="text-base">
          {getStatusMessage()}
        </div>

        {payment?.mp_status === 'approved' && payment.webhook_processed_at && (
          <div className="text-sm text-green-600 bg-green-50 rounded p-2">
            🎉 Assinatura ativada em {new Date(payment.webhook_processed_at).toLocaleString('pt-BR')}
          </div>
        )}

        {payment?.mp_status === 'pending' && payment.payment_method === 'pix' && (
          <div className="text-sm text-blue-600 bg-blue-50 rounded p-2">
            💡 O status será atualizado automaticamente quando o PIX for confirmado
          </div>
        )}

        {payment && (
          <div className="text-xs text-gray-500 pt-2 border-t">
            Última atualização: {new Date(payment.updated_at).toLocaleString('pt-BR')}
          </div>
        )}
      </div>
    </div>
  )
}

export default PaymentStatusMonitor