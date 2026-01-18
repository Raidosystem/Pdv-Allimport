/**
 * 🚀 SERVIÇO DE CRIAÇÃO DE FUNCIONÁRIOS COM AUTH
 * 
 * Cria funcionários com conta no Supabase Auth automaticamente
 * - Sessão persiste em cookies httpOnly (não usa localStorage)
 * - Permite edição de permissões em tempo real
 * - Cada funcionário tem login próprio
 */

import { supabase } from '@/lib/supabase'

export interface NovoFuncionario {
  nome: string
  email: string
  senha: string
  empresa_id: string
  funcao_id: string
  cpf?: string
  telefone?: string
}

export interface ResultadoCriacaoFuncionario {
  success: boolean
  funcionario_id?: string
  user_id?: string
  email?: string
  error?: string
}

/**
 * Cria funcionário com conta Auth automaticamente
 * 
 * FLUXO:
 * 1. Verifica se email já existe
 * 2. Cria conta no auth.users via signUp
 * 3. Cria registro em funcionarios com user_id
 * 4. Auto-aprova na user_approvals
 * 5. Funcionário pode fazer login imediatamente
 */
export async function criarFuncionarioComAuth(
  dados: NovoFuncionario
): Promise<ResultadoCriacaoFuncionario> {
  try {
    console.log('🔧 Criando funcionário com Auth:', dados.nome)

    // 1. Verificar se email já existe em funcionarios
    const { data: funcionarioExistente } = await supabase
      .from('funcionarios')
      .select('id, email')
      .eq('email', dados.email)
      .maybeSingle()

    if (funcionarioExistente) {
      throw new Error(`Email ${dados.email} já cadastrado`)
    }

    // 2. Criar conta no Supabase Auth
    console.log('📧 Criando conta Auth...')
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: dados.email,
      password: dados.senha,
      options: {
        data: {
          full_name: dados.nome,
          role: 'employee',
          tipo_admin: null // Funcionário normal
        },
        emailRedirectTo: `${window.location.origin}/auth/callback`
      }
    })

    if (authError) {
      console.error('❌ Erro ao criar conta Auth:', authError)
      throw authError
    }

    if (!authData.user) {
      throw new Error('Falha ao criar usuário no Auth')
    }

    console.log('✅ Conta Auth criada:', authData.user.id)

    // 3. Criar registro em funcionarios com user_id
    console.log('👤 Criando registro de funcionário...')
    const { data: funcionario, error: funcionarioError } = await supabase
      .from('funcionarios')
      .insert({
        user_id: authData.user.id,
        nome: dados.nome,
        email: dados.email,
        empresa_id: dados.empresa_id,
        funcao_id: dados.funcao_id,
        cpf: dados.cpf || null,
        telefone: dados.telefone || null,
        status: 'ativo',
        tipo_admin: null
      })
      .select('id')
      .single()

    if (funcionarioError) {
      console.error('❌ Erro ao criar funcionário:', funcionarioError)
      
      // Tentar limpar conta Auth criada (rollback)
      try {
        const { error: deleteError } = await supabase.rpc('delete_user', { user_id: authData.user.id })
        if (deleteError) {
          // Se a função RPC não existir, apenas avisar
          if (deleteError.message.includes('function') || deleteError.message.includes('does not exist')) {
            console.warn('⚠️  Função delete_user não disponível. Conta Auth pode ficar órfã:', authData.user.id)
          } else {
            console.error('⚠️  Erro ao deletar conta Auth:', deleteError)
          }
        } else {
          console.log('✅ Conta Auth removida no rollback')
        }
      } catch (e) {
        console.warn('⚠️  Exceção ao limpar conta Auth:', e)
      }
      
      throw funcionarioError
    }

    console.log('✅ Funcionário criado:', funcionario.id)

    // 4. Auto-aprovar em user_approvals
    console.log('🔐 Auto-aprovando acesso...')
    const { error: approvalError } = await supabase
      .from('user_approvals')
      .upsert({
        user_id: authData.user.id,
        email: dados.email,
        full_name: dados.nome,
        company_name: 'Assistencia All-import',
        status: 'approved',
        user_role: 'employee',
        approved_at: new Date().toISOString()
      })

    if (approvalError) {
      console.warn('⚠️  Erro ao aprovar acesso:', approvalError)
      // Não bloqueamos o fluxo por causa disso
    }

    console.log('🎉 Funcionário criado com sucesso!')
    console.log('   - ID:', funcionario.id)
    console.log('   - User ID:', authData.user.id)
    console.log('   - Email:', dados.email)
    console.log('   - Pode fazer login com senha:', dados.senha)

    return {
      success: true,
      funcionario_id: funcionario.id,
      user_id: authData.user.id,
      email: dados.email
    }
  } catch (error: any) {
    console.error('❌ Erro ao criar funcionário:', error)
    return {
      success: false,
      error: error.message || 'Erro desconhecido'
    }
  }
}

/**
 * Lista funcionários sem conta Auth (precisam migração)
 */
export async function listarFuncionariosSemAuth() {
  const { data, error } = await supabase
    .from('funcionarios')
    .select(`
      id,
      nome,
      email,
      user_id,
      status,
      funcoes (
        nome
      )
    `)
    .is('user_id', null)
    .eq('status', 'ativo')

  if (error) {
    console.error('Erro ao listar funcionários sem Auth:', error)
    return []
  }

  return data || []
}

/**
 * Vincula conta Auth existente a funcionário
 */
export async function vincularAuthUsuario(
  funcionario_id: string,
  user_id: string
) {
  const { error } = await supabase
    .from('funcionarios')
    .update({ user_id })
    .eq('id', funcionario_id)

  if (error) {
    throw error
  }

  console.log('✅ Conta Auth vinculada ao funcionário')
}
