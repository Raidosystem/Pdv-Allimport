/**
 * ================================================
 * SERVIÇO DE ATIVAÇÃO DE USUÁRIO
 * ================================================
 * 
 * Gerencia a ativação do usuário após verificação de email
 */

import { supabase } from '../lib/supabase';

interface ActivationResponse {
  success: boolean;
  message?: string;
  trialEndDate?: string;
  daysRemaining?: number;
  error?: string;
}

/**
 * Ativa o usuário após verificação bem-sucedida do email
 * Concede 15 dias de teste gratuito
 */
export async function activateUserAfterEmailVerification(
  email: string
): Promise<ActivationResponse> {
  try {
    console.log('🎯 Ativando usuário após verificação de email:', email);

    // Chamar função do Supabase para ativar usuário
    const { data, error } = await supabase
      .rpc('activate_user_after_email_verification', {
        user_email: email
      });

    if (error) {
      console.error('❌ Erro ao ativar usuário:', error);
      throw error;
    }

    console.log('✅ Resposta da ativação:', data);

    if (data && data.success) {
      const subscription = data.subscription || {};
      
      return {
        success: true,
        message: data.message || 'Usuário ativado com sucesso!',
        trialEndDate: subscription.trial_end_date,
        daysRemaining: subscription.days_remaining
      };
    } else {
      return {
        success: false,
        error: data?.error || 'Erro ao ativar usuário'
      };
    }
  } catch (error: any) {
    console.error('❌ Erro na ativação:', error);
    return {
      success: false,
      error: error.message || 'Erro ao ativar usuário'
    };
  }
}
