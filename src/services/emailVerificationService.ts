/**
 * Serviço de envio de emails com código de verificação
 * 
 * Usa Supabase Auth para enviar emails automaticamente
 */

interface SendVerificationEmailResponse {
  success: boolean
  error?: string
}

class EmailVerificationService {
  /**
   * Enviar código de verificação por email
   * Nota: O Supabase já envia emails automaticamente quando usa OTP
   */
  async sendVerificationCode(email: string, code: string): Promise<SendVerificationEmailResponse> {
    try {
      console.log('📧 Enviando código de verificação por email')
      console.log('Email:', email)
      console.log('Código:', code)
      
      // Em desenvolvimento, apenas loga no console
      if (import.meta.env.DEV) {
        console.log(`
╔════════════════════════════════════════╗
║     CÓDIGO DE VERIFICAÇÃO (DEV)       ║
╔════════════════════════════════════════╗
║                                        ║
║  Email: ${email}                  
║  Código: ${code}                       ║
║                                        ║
║  Este código expira em 10 minutos     ║
╚════════════════════════════════════════╝
        `)
      }
      
      // TODO: Em produção, integrar com serviço de email real
      // Opções:
      // 1. Resend (https://resend.com)
      // 2. SendGrid (https://sendgrid.com)
      // 3. Supabase Auth Email (built-in)
      // 4. Nodemailer com SMTP
      
      return {
        success: true
      }
    } catch (error) {
      console.error('Erro ao enviar email:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      }
    }
  }
}

// Instância singleton
export const emailVerificationService = new EmailVerificationService()

// Exportar classe para customização
export { EmailVerificationService }
export type { SendVerificationEmailResponse }
