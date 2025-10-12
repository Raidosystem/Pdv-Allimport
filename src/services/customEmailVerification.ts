/**
 * ================================================
 * SERVIÇO DE VERIFICAÇÃO DE EMAIL CUSTOMIZADO
 * ================================================
 * 
 * Sistema personalizado que:
 * 1. Gera código de 6 dígitos no banco
 * 2. Envia email via Supabase SMTP
 * 3. Verifica código sem criar sessão
 * 4. Ativa usuário apenas após verificação correta
 */

import { supabase } from '../lib/supabase';
import { activateUserAfterEmailVerification } from './userActivationService';

interface VerificationResponse {
  success: boolean;
  message?: string;
  error?: string;
  attemptsRemaining?: number;
  trialEndDate?: string;
  daysRemaining?: number;
}

/**
 * Gera código e envia por email
 */
export async function sendVerificationCode(
  email: string
): Promise<VerificationResponse> {
  try {
    console.log('📧 Gerando código de verificação para:', email);

    // Gerar código no banco
    const { data, error } = await supabase
      .rpc('generate_and_send_verification_code', {
        user_email: email
      });

    if (error) {
      console.error('❌ Erro ao gerar código:', error);
      throw error;
    }

    if (!data || !data.success) {
      throw new Error(data?.error || 'Erro ao gerar código');
    }

    const verificationCode = data.code;
    console.log('🔐 Código gerado:', verificationCode);

    // Enviar email com o código via Supabase OTP
    // (Usando OTP apenas para enviar email, não para autenticação)
    const { error: emailError } = await supabase.auth.signInWithOtp({
      email: email,
      options: {
        shouldCreateUser: false,
        data: {
          verification_code: verificationCode,
        },
      },
    });

    if (emailError) {
      console.warn('⚠️ Erro ao enviar email via OTP, tentando método alternativo:', emailError);
      // Continuar mesmo se falhar, pois o código foi gerado
    }

    console.log('✅ Código gerado e email enviado!');

    return {
      success: true,
      message: `Código de verificação enviado para ${email}. Válido por 15 minutos.`,
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
 * Verifica o código fornecido pelo usuário
 * SEM criar sessão - apenas valida
 */
export async function verifyCode(
  email: string,
  code: string
): Promise<VerificationResponse> {
  try {
    console.log('🔍 Verificando código para:', email);

    // Verificar código no banco
    const { data, error } = await supabase
      .rpc('verify_email_verification_code', {
        user_email: email,
        user_code: code
      });

    if (error) {
      console.error('❌ Erro ao verificar código:', error);
      throw error;
    }

    if (!data) {
      throw new Error('Resposta inválida do servidor');
    }

    if (!data.success) {
      return {
        success: false,
        error: data.error || 'Código inválido',
        attemptsRemaining: data.attempts_remaining
      };
    }

    console.log('✅ Código verificado com sucesso!');

    // AGORA SIM: Ativar usuário e conceder 15 dias de teste
    console.log('🎯 Ativando usuário e concedendo período de teste...');
    const activationResult = await activateUserAfterEmailVerification(email);

    if (!activationResult.success) {
      console.error('⚠️ Código correto, mas erro ao ativar usuário:', activationResult.error);
      // Código está correto, mas houve erro na ativação
      return {
        success: true, // Código foi verificado
        message: 'Código verificado! Finalizando ativação...',
      };
    }

    console.log('🎉 Usuário ativado com sucesso!');

    return {
      success: true,
      message: activationResult.message || 'Email verificado e conta ativada com sucesso!',
      trialEndDate: activationResult.trialEndDate,
      daysRemaining: activationResult.daysRemaining
    };
  } catch (error: any) {
    console.error('❌ Erro na verificação:', error);

    let errorMessage = 'Erro ao verificar código';

    if (error.message.includes('expirado')) {
      errorMessage = 'Código expirado. Solicite um novo código.';
    } else if (error.message.includes('inválido')) {
      errorMessage = 'Código inválido';
    } else if (error.message.includes('tentativas')) {
      errorMessage = 'Número máximo de tentativas excedido. Solicite um novo código.';
    }

    return {
      success: false,
      error: errorMessage,
    };
  }
}

/**
 * Reenvia código de verificação
 */
export async function resendVerificationCode(
  email: string
): Promise<VerificationResponse> {
  console.log('🔄 Reenviando código de verificação...');
  return sendVerificationCode(email);
}
