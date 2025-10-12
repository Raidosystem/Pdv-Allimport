/**
 * ================================================
 * SERVIÇO DE VERIFICAÇÃO - SUPABASE OTP
 * ================================================
 * 
 * Sistema de verificação usando Supabase Auth OTP:
 * - Código enviado automaticamente por email via SMTP configurado
 * - Verificação nativa do Supabase
 * - Sem código exposto na interface
 */

import { supabase } from '../lib/supabase';

interface EmailVerificationResponse {
  success: boolean;
  error?: string;
}

/**
 * Envia código de verificação via Supabase OTP
 * O código será enviado automaticamente por email
 */
export async function sendEmailVerificationCode(
  email: string
): Promise<EmailVerificationResponse> {
  try {
    console.log('📧 Enviando código via Supabase OTP para:', email);

    // Usar Supabase OTP - envia email automaticamente
    const { error } = await supabase.auth.signInWithOtp({
      email: email,
      options: {
        shouldCreateUser: false, // Não criar usuário, apenas enviar código
      },
    });

    if (error) {
      console.error('❌ Erro ao enviar código:', error);
      throw error;
    }

    console.log('✅ Código enviado com sucesso! Verifique seu email.');
    
    return {
      success: true,
    };
  } catch (error: any) {
    console.error('❌ Erro ao enviar código:', error);
    return {
      success: false,
      error: error.message || 'Erro ao enviar código de verificação',
    };
  }
}

/**
 * Verifica o código OTP enviado por email
 */
export async function verifyEmailCode(
  email: string,
  code: string
): Promise<EmailVerificationResponse> {
  try {
    console.log('🔍 Verificando código para:', email);

    // Verificar OTP com Supabase
    const { data, error } = await supabase.auth.verifyOtp({
      email: email,
      token: code,
      type: 'email',
    });

    if (error) {
      console.error('❌ Erro ao verificar código:', error);
      throw error;
    }

    if (!data.session) {
      return {
        success: false,
        error: 'Código inválido',
      };
    }

    console.log('✅ Código verificado com sucesso!');

    return {
      success: true,
    };
  } catch (error: any) {
    console.error('❌ Erro na verificação:', error);

    // Mensagens de erro amigáveis
    let errorMessage = 'Erro ao verificar código';

    if (error.message.includes('expired')) {
      errorMessage = 'Código expirado. Solicite um novo código.';
    } else if (error.message.includes('invalid')) {
      errorMessage = 'Código inválido';
    }

    return {
      success: false,
      error: errorMessage,
    };
  }
}

/**
 * Reenviar código de verificação
 * IMPORTANTE: Não retorna o código, apenas confirma o envio
 */
export async function resendEmailVerificationCode(
  email: string
): Promise<EmailVerificationResponse> {
  console.log('🔄 Reenviando código de verificação...');
  return sendEmailVerificationCode(email);
}
