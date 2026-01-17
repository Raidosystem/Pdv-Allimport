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

    // 🔥 USAR FUNÇÃO SECURITY DEFINER que bypassa RLS
    console.log('📝 Chamando approve_user_after_email_verification (bypassa RLS)...');
    
    const { data, error } = await supabase
      .rpc('approve_user_after_email_verification', {
        user_email: email
      });

    console.log('📊 Resultado da aprovação:', { data, error });

    if (error) {
      console.error('❌ Erro ao aprovar e ativar usuário:', error);
      console.error('📋 Detalhes do erro:', JSON.stringify(error, null, 2));
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
