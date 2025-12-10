/**
 * Utilitário para obter empresa_id correto
 * 
 * Resolve o problema de funcionários locais tentando usar user_id
 * para buscar empresas quando deveriam usar empresa_id do metadata
 */

import { supabase } from '../lib/supabase'
import type { User } from '@supabase/supabase-js'

export interface EmpresaIdResult {
  empresaId: string | null
  isFuncionario: boolean
  userId: string
}

/**
 * Obtém o empresa_id correto para o usuário atual
 * 
 * - Se for funcionário (tem is_login_local ou funcionario_id): usa empresa_id do metadata
 * - Se for admin/owner: busca empresa onde user_id = auth.uid()
 * 
 * @param user - Usuário do Supabase Auth
 * @returns empresa_id, flag se é funcionário, e userId
 */
export async function getEmpresaId(user: User | null): Promise<EmpresaIdResult> {
  if (!user) {
    return { empresaId: null, isFuncionario: false, userId: '' }
  }

  // Verificar se é login local (funcionário)
  const isLoginLocal = user.user_metadata?.is_login_local === true
  const funcionarioId = user.user_metadata?.funcionario_id
  const empresaIdMetadata = user.user_metadata?.empresa_id

  console.log('🔍 [getEmpresaId] Detectando tipo de usuário:', {
    userId: user.id,
    email: user.email,
    isLoginLocal,
    funcionarioId,
    empresaIdMetadata,
  })

  // Se for funcionário, usar empresa_id do metadata
  if (isLoginLocal || funcionarioId) {
    console.log('✅ [getEmpresaId] Funcionário detectado - usando empresa_id do metadata')
    return {
      empresaId: empresaIdMetadata || null,
      isFuncionario: true,
      userId: user.id,
    }
  }

  // Se não for funcionário, buscar empresa onde user_id = auth.uid()
  console.log('👤 [getEmpresaId] Admin/Owner detectado - buscando empresa por user_id')
  
  const { data, error } = await supabase
    .from('empresas')
    .select('id')
    .eq('user_id', user.id)
    .single()

  if (error || !data) {
    console.error('❌ [getEmpresaId] Erro ao buscar empresa:', error)
    return { empresaId: null, isFuncionario: false, userId: user.id }
  }

  console.log('✅ [getEmpresaId] Empresa encontrada:', data.id)
  return {
    empresaId: data.id,
    isFuncionario: false,
    userId: user.id,
  }
}

/**
 * Obtém empresa_id do usuário atual (versão síncrona)
 * 
 * ATENÇÃO: Esta versão só funciona para funcionários (usa apenas metadata).
 * Para admins, você DEVE usar a versão assíncrona getEmpresaId().
 * 
 * @param user - Usuário do Supabase Auth
 * @returns empresa_id ou null
 */
export function getEmpresaIdSync(user: User | null): string | null {
  if (!user) return null

  const empresaIdMetadata = user.user_metadata?.empresa_id
  const isLoginLocal = user.user_metadata?.is_login_local === true
  const funcionarioId = user.user_metadata?.funcionario_id

  // Se for funcionário, retornar empresa_id do metadata
  if (isLoginLocal || funcionarioId) {
    return empresaIdMetadata || null
  }

  // Para admins, essa função não funciona - deve usar getEmpresaId() assíncrona
  console.warn('⚠️ [getEmpresaIdSync] Usuário admin detectado - use getEmpresaId() assíncrona')
  return null
}

/**
 * Verifica se o usuário é um funcionário (login local)
 * 
 * @param user - Usuário do Supabase Auth
 * @returns true se for funcionário
 */
export function isFuncionario(user: User | null): boolean {
  if (!user) return false

  return (
    user.user_metadata?.is_login_local === true ||
    !!user.user_metadata?.funcionario_id
  )
}

/**
 * Cria query Supabase filtrando por empresa do usuário
 * 
 * Exemplo de uso:
 * ```ts
 * const query = await createEmpresaQuery(user, supabase.from('clientes'))
 * const { data, error } = await query.select('*')
 * ```
 * 
 * @param user - Usuário do Supabase Auth
 * @param baseQuery - Query inicial do Supabase
 * @returns Query com filtro de empresa aplicado
 */
export async function createEmpresaQuery(
  user: User | null,
  baseQuery: any
): Promise<any> {
  const { empresaId, isFuncionario: isFuncionarioUser } = await getEmpresaId(user)

  if (!empresaId) {
    throw new Error('Empresa não encontrada para o usuário')
  }

  // Para funcionários, filtrar por empresa_id
  if (isFuncionarioUser) {
    return baseQuery.eq('empresa_id', empresaId)
  }

  // Para admins, filtrar por user_id (comportamento antigo)
  return baseQuery.eq('user_id', user!.id)
}
