import type { MercadoPagoPreference, MercadoPagoPayment } from '../types/subscription'

// Configuração do Mercado Pago
const MP_ACCESS_TOKEN = import.meta.env.VITE_MP_ACCESS_TOKEN || ''
const MP_PUBLIC_KEY = import.meta.env.VITE_MP_PUBLIC_KEY || ''
const MP_BASE_URL = import.meta.env.VITE_MP_BASE_URL || 'https://api.mercadopago.com'

export class MercadoPagoService {
  
  // Criar preferência de pagamento
  static async createPaymentPreference(
    userEmail: string,
    userName: string,
    planPrice: number,
    planName: string
  ): Promise<MercadoPagoPreference> {
    try {
      const preferenceData = {
        items: [
          {
            id: 'pdv-subscription',
            title: planName,
            description: 'Assinatura do Sistema PDV Allimport',
            quantity: 1,
            currency_id: 'BRL',
            unit_price: planPrice
          }
        ],
        payer: {
          email: userEmail,
          name: userName
        },
        payment_methods: {
          excluded_payment_types: [],
          excluded_payment_methods: [],
          installments: 12 // Máximo de parcelas
        },
        back_urls: {
          success: `${window.location.origin}/payment/success`,
          failure: `${window.location.origin}/payment/failure`,
          pending: `${window.location.origin}/payment/pending`
        },
        auto_return: 'approved',
        external_reference: `subscription_${userEmail}_${Date.now()}`,
        notification_url: `${import.meta.env.VITE_API_URL}/webhook/mercadopago`,
        expires: true,
        expiration_date_from: new Date().toISOString(),
        expiration_date_to: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() // 24 horas
      }

      const response = await fetch(`${MP_BASE_URL}/checkout/preferences`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(preferenceData)
      })

      if (!response.ok) {
        throw new Error(`Erro ao criar preferência: ${response.statusText}`)
      }

      const data = await response.json()
      return data as MercadoPagoPreference
    } catch (error) {
      console.error('Erro ao criar preferência do Mercado Pago:', error)
      throw error
    }
  }

  // Buscar informações de um pagamento
  static async getPaymentInfo(paymentId: string): Promise<MercadoPagoPayment> {
    try {
      const response = await fetch(`${MP_BASE_URL}/v1/payments/${paymentId}`, {
        headers: {
          'Authorization': `Bearer ${MP_ACCESS_TOKEN}`
        }
      })

      if (!response.ok) {
        throw new Error(`Erro ao buscar pagamento: ${response.statusText}`)
      }

      const data = await response.json()
      return data as MercadoPagoPayment
    } catch (error) {
      console.error('Erro ao buscar informações do pagamento:', error)
      throw error
    }
  }

  // Gerar QR Code para PIX
  static async generatePixQRCode(
    userEmail: string,
    userName: string,
    amount: number,
    description: string
  ): Promise<{ qr_code: string; qr_code_base64: string; payment_id: string }> {
    try {
      const pixData = {
        transaction_amount: amount,
        description: description,
        payment_method_id: 'pix',
        payer: {
          email: userEmail,
          first_name: userName.split(' ')[0],
          last_name: userName.split(' ').slice(1).join(' ') || 'Cliente'
        },
        external_reference: `pix_${userEmail}_${Date.now()}`,
        notification_url: `${import.meta.env.VITE_API_URL}/webhook/mercadopago`
      }

      const response = await fetch(`${MP_BASE_URL}/v1/payments`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(pixData)
      })

      if (!response.ok) {
        throw new Error(`Erro ao gerar PIX: ${response.statusText}`)
      }

      const data = await response.json()
      
      return {
        qr_code: data.point_of_interaction?.transaction_data?.qr_code || '',
        qr_code_base64: data.point_of_interaction?.transaction_data?.qr_code_base64 || '',
        payment_id: data.id.toString()
      }
    } catch (error) {
      console.error('Erro ao gerar QR Code PIX:', error)
      throw error
    }
  }

  // Verificar status do pagamento
  static async checkPaymentStatus(paymentId: string): Promise<{
    status: string
    status_detail: string
    approved: boolean
  }> {
    try {
      const payment = await this.getPaymentInfo(paymentId)
      
      return {
        status: payment.status,
        status_detail: payment.status_detail,
        approved: payment.status === 'approved'
      }
    } catch (error) {
      console.error('Erro ao verificar status do pagamento:', error)
      return {
        status: 'error',
        status_detail: 'Erro ao verificar pagamento',
        approved: false
      }
    }
  }

  // Traduzir status do Mercado Pago para português
  static translatePaymentStatus(status: string, statusDetail: string): string {
    const statusMap: { [key: string]: string } = {
      'pending': 'Pendente',
      'approved': 'Aprovado',
      'authorized': 'Autorizado',
      'in_process': 'Em processamento',
      'in_mediation': 'Em mediação',
      'rejected': 'Rejeitado',
      'cancelled': 'Cancelado',
      'refunded': 'Reembolsado',
      'charged_back': 'Estornado'
    }

    const detailMap: { [key: string]: string } = {
      'accredited': 'Pagamento creditado',
      'pending_contingency': 'Aguardando confirmação',
      'pending_review_manual': 'Em análise manual',
      'cc_rejected_insufficient_amount': 'Saldo insuficiente',
      'cc_rejected_bad_filled_card_number': 'Número do cartão inválido',
      'cc_rejected_bad_filled_date': 'Data de validade inválida',
      'cc_rejected_bad_filled_security_code': 'Código de segurança inválido',
      'cc_rejected_bad_filled_other': 'Dados incorretos',
      'cc_rejected_blacklist': 'Cartão bloqueado',
      'cc_rejected_call_for_authorize': 'Contate o banco para autorizar',
      'cc_rejected_card_disabled': 'Cartão desabilitado',
      'cc_rejected_duplicated_payment': 'Pagamento duplicado',
      'cc_rejected_high_risk': 'Transação de alto risco',
      'cc_rejected_max_attempts': 'Muitas tentativas inválidas',
      'cc_rejected_other_reason': 'Pagamento rejeitado'
    }

    const statusText = statusMap[status] || status
    const detailText = detailMap[statusDetail] || statusDetail

    return statusDetail ? `${statusText} - ${detailText}` : statusText
  }

  // Validar configuração do Mercado Pago
  static validateConfiguration(): { valid: boolean; errors: string[] } {
    const errors: string[] = []

    if (!MP_ACCESS_TOKEN) {
      errors.push('VITE_MP_ACCESS_TOKEN não configurado')
    }

    if (!MP_PUBLIC_KEY) {
      errors.push('VITE_MP_PUBLIC_KEY não configurado')
    }

    return {
      valid: errors.length === 0,
      errors
    }
  }
}
