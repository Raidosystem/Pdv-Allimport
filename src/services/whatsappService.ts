/**
 * Serviço de envio de mensagens via WhatsApp
 * 
 * Implementação com Twilio WhatsApp API
 * Alternativas: Evolution API, Z-API, Baileys
 */

interface WhatsAppConfig {
  provider: 'twilio' | 'evolution' | 'z-api' | 'baileys'
  twilioAccountSid?: string
  twilioAuthToken?: string
  twilioWhatsAppNumber?: string
  evolutionApiUrl?: string
  evolutionApiKey?: string
  zApiInstance?: string
  zApiToken?: string
}

interface SendMessageResponse {
  success: boolean
  messageId?: string
  error?: string
}

class WhatsAppService {
  private config: WhatsAppConfig

  constructor(config?: Partial<WhatsAppConfig>) {
    // Configuração padrão
    this.config = {
      provider: 'twilio', // Pode mudar para 'evolution' se preferir API brasileira
      twilioAccountSid: import.meta.env.VITE_TWILIO_ACCOUNT_SID,
      twilioAuthToken: import.meta.env.VITE_TWILIO_AUTH_TOKEN,
      twilioWhatsAppNumber: import.meta.env.VITE_TWILIO_WHATSAPP_NUMBER || 'whatsapp:+14155238886',
      ...config
    }
  }

  /**
   * Enviar código de verificação via WhatsApp
   */
  async sendVerificationCode(phone: string, code: string): Promise<SendMessageResponse> {
    const message = `🔐 Seu código de verificação é: *${code}*\n\nEste código expira em 10 minutos.\n\nSe você não solicitou este código, ignore esta mensagem.`

    switch (this.config.provider) {
      case 'twilio':
        return this.sendViaTwilio(phone, message)
      
      case 'evolution':
        return this.sendViaEvolution(phone, message)
      
      case 'z-api':
        return this.sendViaZApi(phone, message)
      
      default:
        return this.simulateSend(phone, code)
    }
  }

  /**
   * Enviar via Twilio (Recomendado - confiável e global)
   */
  private async sendViaTwilio(phone: string, message: string): Promise<SendMessageResponse> {
    try {
      const { twilioAccountSid, twilioAuthToken, twilioWhatsAppNumber } = this.config

      if (!twilioAccountSid || !twilioAuthToken) {
        throw new Error('Twilio credentials not configured')
      }

      const formattedPhone = this.formatPhoneForTwilio(phone)
      
      const response = await fetch(
        `https://api.twilio.com/2010-04-01/Accounts/${twilioAccountSid}/Messages.json`,
        {
          method: 'POST',
          headers: {
            'Authorization': 'Basic ' + btoa(`${twilioAccountSid}:${twilioAuthToken}`),
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: new URLSearchParams({
            From: twilioWhatsAppNumber!,
            To: formattedPhone,
            Body: message,
          }),
        }
      )

      if (!response.ok) {
        const error = await response.json()
        throw new Error(error.message || 'Failed to send message')
      }

      const data = await response.json()
      
      return {
        success: true,
        messageId: data.sid,
      }
    } catch (error) {
      console.error('Twilio error:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      }
    }
  }

  /**
   * Enviar via Evolution API (API brasileira open-source)
   */
  private async sendViaEvolution(phone: string, message: string): Promise<SendMessageResponse> {
    try {
      const { evolutionApiUrl, evolutionApiKey } = this.config

      if (!evolutionApiUrl || !evolutionApiKey) {
        throw new Error('Evolution API credentials not configured')
      }

      const formattedPhone = this.formatPhoneForBrazil(phone)
      
      const response = await fetch(`${evolutionApiUrl}/message/sendText`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': evolutionApiKey,
        },
        body: JSON.stringify({
          number: formattedPhone,
          text: message,
        }),
      })

      if (!response.ok) {
        throw new Error('Failed to send message via Evolution API')
      }

      const data = await response.json()
      
      return {
        success: true,
        messageId: data.key?.id || data.messageId,
      }
    } catch (error) {
      console.error('Evolution API error:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      }
    }
  }

  /**
   * Enviar via Z-API (API brasileira comercial)
   */
  private async sendViaZApi(phone: string, message: string): Promise<SendMessageResponse> {
    try {
      const { zApiInstance, zApiToken } = this.config

      if (!zApiInstance || !zApiToken) {
        throw new Error('Z-API credentials not configured')
      }

      const formattedPhone = this.formatPhoneForBrazil(phone)
      
      const response = await fetch(
        `https://api.z-api.io/instances/${zApiInstance}/token/${zApiToken}/send-text`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            phone: formattedPhone,
            message: message,
          }),
        }
      )

      if (!response.ok) {
        throw new Error('Failed to send message via Z-API')
      }

      const data = await response.json()
      
      return {
        success: true,
        messageId: data.messageId,
      }
    } catch (error) {
      console.error('Z-API error:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      }
    }
  }

  /**
   * Simular envio (desenvolvimento)
   */
  private async simulateSend(phone: string, code: string): Promise<SendMessageResponse> {
    console.log('📱 SIMULAÇÃO DE ENVIO WhatsApp')
    console.log('Telefone:', phone)
    console.log('Código:', code)
    console.log('Mensagem seria enviada via WhatsApp')
    
    // Em desenvolvimento, apenas loga no console
    return {
      success: true,
      messageId: `sim_${Date.now()}`,
    }
  }

  /**
   * Formatar telefone para Twilio (formato internacional com whatsapp:)
   */
  private formatPhoneForTwilio(phone: string): string {
    const cleaned = phone.replace(/\D/g, '')
    
    // Se não tem código do país, assume Brasil (+55)
    if (cleaned.length === 11 || cleaned.length === 10) {
      return `whatsapp:+55${cleaned}`
    }
    
    return `whatsapp:+${cleaned}`
  }

  /**
   * Formatar telefone para APIs brasileiras
   */
  private formatPhoneForBrazil(phone: string): string {
    const cleaned = phone.replace(/\D/g, '')
    
    // Se não tem código do país, assume Brasil (+55)
    if (cleaned.length === 11 || cleaned.length === 10) {
      return `55${cleaned}`
    }
    
    return cleaned
  }

  /**
   * Validar número de telefone brasileiro
   */
  validateBrazilianPhone(phone: string): boolean {
    const cleaned = phone.replace(/\D/g, '')
    
    // Formato: (DD) 9XXXX-XXXX ou (DD) XXXX-XXXX
    // Com código: 55 DD 9XXXX-XXXX
    
    if (cleaned.length === 11) {
      // 11 dígitos: DDD + 9 + 8 dígitos
      const ddd = parseInt(cleaned.substring(0, 2))
      const firstDigit = cleaned.charAt(2)
      
      return ddd >= 11 && ddd <= 99 && (firstDigit === '9' || firstDigit === '8' || firstDigit === '7')
    }
    
    if (cleaned.length === 13 && cleaned.startsWith('55')) {
      // 13 dígitos: 55 + DDD + 9 + 8 dígitos
      return this.validateBrazilianPhone(cleaned.substring(2))
    }
    
    return false
  }
}

// Instância singleton
export const whatsappService = new WhatsAppService()

// Exportar classe para customização
export { WhatsAppService }
export type { WhatsAppConfig, SendMessageResponse }
