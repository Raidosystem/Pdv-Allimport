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
    console.log('🎯 Ativando teste de 15 dias para novo usuário:', email);

    // Chamar NOVA função que ativa teste de 15 dias
    const { data, error } = await supabase
      .rpc('activate_trial_for_new_user', {
        user_email: email
      });

    if (error) {
      console.error('❌ Erro ao ativar período de teste:', error);
      throw error;
    }

    console.log('✅ Resposta da ativação:', data);

    if (data && data.success) {
      return {
        success: true,
        message: data.message || '15 dias de teste ativados!',
        trialEndDate: data.trial_end_date,
        daysRemaining: data.days_remaining || 15
      };
    } else {
      return {
        success: false,
        error: data?.error || 'Erro ao ativar período de teste'
      };
    }
  } catch (error: any) {
    console.error('❌ Erro na ativação:', error);
    return {
      success: false,
      error: error.message || 'Erro ao ativar período de teste'
    };
  }
}
