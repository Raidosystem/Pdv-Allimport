/**
 * ================================================
 * SERVIÇO DE EMAIL - ENVIO DE CÓDIGOS DE VERIFICAÇÃO
 * ================================================
 * 
 * USANDO: Resend para envio de emails
 * - 3.000 emails grátis/mês
 * - API Key configurada no Vercel
 */

import { supabase } from '../lib/supabase';

interface EmailVerificationResponse {
  success: boolean;
  code?: string;
  expiresAt?: string;
  error?: string;
}

// Função auxiliar para enviar email via Resend
async function sendEmailWithResend(to: string, code: string): Promise<boolean> {
  try {
    const apiKey = import.meta.env.VITE_RESEND_API_KEY;
    
    if (!apiKey || apiKey === 'undefined' || apiKey === '') {
      console.warn('⚠️ VITE_RESEND_API_KEY não configurada');
      return false;
    }

    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'RaVal pdv <onboarding@resend.dev>',
        to: [to],
        subject: '🔐 Código de Verificação - RaVal pdv',
        html: `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
    <h1 style="color: white; margin: 0;">RaVal pdv</h1>
  </div>
  
  <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
    <h2 style="color: #667eea; margin-top: 0;">Código de Verificação</h2>
    
    <p>Olá!</p>
    
    <p>Use o código abaixo para verificar sua conta:</p>
    
    <div style="background: white; border: 2px dashed #667eea; border-radius: 8px; padding: 20px; text-align: center; margin: 30px 0;">
      <h1 style="color: #667eea; font-size: 36px; letter-spacing: 8px; margin: 0;">${code}</h1>
    </div>
    
    <p><strong>⏰ Este código expira em 10 minutos.</strong></p>
    
    <p>Se você não solicitou este código, ignore este email.</p>
    
    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
    
    <p style="color: #666; font-size: 12px; text-align: center;">
      © ${new Date().getFullYear()} RaVal pdv. Todos os direitos reservados.
    </p>
  </div>
</body>
</html>
        `,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error('❌ Erro Resend:', error);
      return false;
    }

    const data = await response.json();
    console.log('✅ Email enviado via Resend! ID:', data.id);
    return true;
  } catch (error) {
    console.error('❌ Erro ao chamar Resend API:', error);
    return false;
  }
}

/**
 * Gera e envia código de verificação por email
 */
export async function sendEmailVerificationCode(
  userId: string,
  email: string
): Promise<EmailVerificationResponse> {
  try {
    console.log('📧 Gerando código de verificação para:', email);

    // Gerar código via função do banco
    const { data, error } = await supabase
      .rpc('generate_email_verification_code', {
        p_user_id: userId,
        p_email: email
      });

    if (error) {
      console.error('❌ Erro ao gerar código:', error);
      throw error;
    }

    if (!data || data.length === 0) {
      throw new Error('Nenhum código foi gerado');
    }

    const { code, expires_at } = data[0];

    console.log('✅ Código gerado:', code);
    console.log('⏰ Expira em:', expires_at);

    // TENTAR ENVIAR EMAIL VIA RESEND
    const emailSent = await sendEmailWithResend(email, code);

    if (emailSent) {
      console.log('✅ Email enviado com sucesso para:', email);
    } else {
      console.warn('⚠️ Não foi possível enviar email. Mostrando código no console.');
      console.log(`
╔════════════════════════════════════════════╗
║       CÓDIGO DE VERIFICAÇÃO GERADO         ║
╠════════════════════════════════════════════╣
║                                            ║
║  Email: ${email.padEnd(32, ' ')}          ║
║  Código: ${code}                           ║
║                                            ║
║  ⏰ Expira em: 10 minutos                  ║
║                                            ║
╚════════════════════════════════════════════╝
      `);
    }

    return {
      success: true,
      code: emailSent ? undefined : code, // Só retorna código se email falhou
      expiresAt: expires_at
    };

  } catch (error: any) {
    console.error('❌ Erro ao enviar código:', error);
    return {
      success: false,
      error: error.message || 'Erro ao enviar código de verificação'
    };
  }
}

/**
 * Verifica código de email
 */
export async function verifyEmailCode(
  userId: string,
  code: string
): Promise<EmailVerificationResponse> {
  try {
    console.log('🔍 Verificando código para usuário:', userId);

    const { data, error } = await supabase
      .rpc('verify_email_code', {
        p_user_id: userId,
        p_code: code
      });

    if (error) {
      console.error('❌ Erro ao verificar código:', error);
      throw error;
    }

    if (!data) {
      return {
        success: false,
        error: 'Código inválido'
      };
    }

    console.log('✅ Código verificado com sucesso!');

    return {
      success: true
    };

  } catch (error: any) {
    console.error('❌ Erro na verificação:', error);
    
    // Mensagens de erro amigáveis
    let errorMessage = 'Erro ao verificar código';
    
    if (error.message.includes('não encontrado')) {
      errorMessage = 'Código não encontrado';
    } else if (error.message.includes('expirado')) {
      errorMessage = 'Código expirado. Solicite um novo código.';
    } else if (error.message.includes('tentativas')) {
      errorMessage = 'Número máximo de tentativas excedido. Solicite um novo código.';
    } else if (error.message.includes('inválido')) {
      errorMessage = 'Código inválido';
    }
    
    return {
      success: false,
      error: errorMessage
    };
  }
}

/**
 * Reenviar código de verificação
 */
export async function resendEmailVerificationCode(
  userId: string,
  email: string
): Promise<EmailVerificationResponse> {
  console.log('🔄 Reenviando código de verificação...');
  return sendEmailVerificationCode(userId, email);
}


