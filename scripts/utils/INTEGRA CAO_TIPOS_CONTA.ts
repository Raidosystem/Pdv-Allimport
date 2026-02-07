// 🔄 INTEGRAÇÃO: Sistema de Tipos de Conta
// Arquivo: src/services/subscriptionService.ts

import { supabase } from '@/lib/supabase'

/**
 * Tipos de conta no sistema
 */
export type TipoConta = 
  | 'super_admin'        // Desenvolvedor (você)
  | 'assinatura_ativa'   // Cliente pagante
  | 'teste_ativo'        // Teste de 15 dias
  | 'teste_expirado'     // Teste vencido
  | 'funcionarios'       // Funcionários

/**
 * Ativar assinatura após pagamento confirmado
 */
export async function ativarAssinatura(empresaId: string) {
  try {
    const { error } = await supabase.rpc('ativar_assinatura', {
      p_empresa_id: empresaId
    })

    if (error) throw error

    console.log('✅ Assinatura ativada com sucesso:', empresaId)
    return { success: true }
  } catch (error: any) {
    console.error('❌ Erro ao ativar assinatura:', error)
    return { success: false, error: error.message }
  }
}

/**
 * Verificar se empresa está em período de teste
 */
export async function verificarStatusTeste(empresaId: string) {
  try {
    const { data, error } = await supabase
      .from('empresas')
      .select('tipo_conta, data_fim_teste, data_cadastro')
      .eq('id', empresaId)
      .single()

    if (error) throw error

    const hoje = new Date()
    const fimTeste = data.data_fim_teste ? new Date(data.data_fim_teste) : null
    const diasRestantes = fimTeste 
      ? Math.ceil((fimTeste.getTime() - hoje.getTime()) / (1000 * 60 * 60 * 24))
      : 0

    return {
      tipo_conta: data.tipo_conta as TipoConta,
      em_teste: data.tipo_conta === 'teste_ativo',
      dias_restantes: diasRestantes,
      teste_expirado: diasRestantes <= 0 && data.tipo_conta === 'teste_ativo',
      data_fim_teste: fimTeste
    }
  } catch (error: any) {
    console.error('❌ Erro ao verificar status:', error)
    return null
  }
}

/**
 * Verificar se pode acessar o sistema
 */
export async function podeAcessarSistema(empresaId: string): Promise<boolean> {
  try {
    const { data, error } = await supabase
      .from('empresas')
      .select('tipo_conta, is_super_admin')
      .eq('id', empresaId)
      .single()

    if (error) throw error

    // Super admin sempre pode acessar
    if (data.is_super_admin) return true

    // Tipos permitidos
    const tiposPermitidos: TipoConta[] = [
      'super_admin',
      'assinatura_ativa',
      'teste_ativo'
    ]

    return tiposPermitidos.includes(data.tipo_conta)
  } catch (error: any) {
    console.error('❌ Erro ao verificar acesso:', error)
    return false
  }
}

/**
 * Obter mensagem de status para o usuário
 */
export function getMensagemStatus(status: ReturnType<typeof verificarStatusTeste> extends Promise<infer T> ? T : never) {
  if (!status) return null

  if (status.tipo_conta === 'super_admin') {
    return {
      tipo: 'success' as const,
      titulo: '🔐 Super Admin',
      mensagem: 'Acesso total ao sistema'
    }
  }

  if (status.tipo_conta === 'assinatura_ativa') {
    return {
      tipo: 'success' as const,
      titulo: '✅ Assinatura Ativa',
      mensagem: 'Seu plano está ativo e funcionando'
    }
  }

  if (status.tipo_conta === 'teste_ativo') {
    if (status.dias_restantes <= 0) {
      return {
        tipo: 'error' as const,
        titulo: '⏰ Período de Teste Expirado',
        mensagem: 'Seu teste de 15 dias terminou. Assine agora para continuar!'
      }
    }

    if (status.dias_restantes <= 3) {
      return {
        tipo: 'warning' as const,
        titulo: `⚠️ ${status.dias_restantes} dias restantes`,
        mensagem: 'Seu período de teste está acabando. Garanta seu acesso!'
      }
    }

    return {
      tipo: 'info' as const,
      titulo: `🆓 Teste - ${status.dias_restantes} dias restantes`,
      mensagem: 'Aproveite o período de avaliação gratuita'
    }
  }

  if (status.tipo_conta === 'teste_expirado') {
    return {
      tipo: 'error' as const,
      titulo: '❌ Acesso Bloqueado',
      mensagem: 'Período de teste expirado. Assine para reativar!'
    }
  }

  return null
}

// ====================================
// EXEMPLO DE USO NO CÓDIGO
// ====================================

/*
// 1. No AuthContext ou após login, verificar status:
const status = await verificarStatusTeste(empresaId)
if (status?.teste_expirado) {
  // Redirecionar para página de pagamento
  navigate('/assinar')
}

// 2. Mostrar badge de status no Dashboard:
const mensagem = getMensagemStatus(status)
if (mensagem) {
  <Alert type={mensagem.tipo}>
    <AlertTitle>{mensagem.titulo}</AlertTitle>
    <AlertDescription>{mensagem.mensagem}</AlertDescription>
  </Alert>
}

// 3. Após confirmação de pagamento (webhook):
const result = await ativarAssinatura(empresaId)
if (result.success) {
  toast.success('Assinatura ativada com sucesso!')
}

// 4. Bloquear acesso se não pode usar:
const podeAcessar = await podeAcessarSistema(empresaId)
if (!podeAcessar) {
  navigate('/bloqueado')
}
*/
