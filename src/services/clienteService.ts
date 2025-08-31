import { supabase } from '../lib/supabase'
import type { Cliente, ClienteInput, ClienteFilters } from '../types/cliente'

// UUID específico para assistenciaallimport10@gmail.com (atualizado do banco)
const USER_ID_ASSISTENCIA = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'

export class ClienteService {
  // Buscar todos os clientes com filtros
  static async buscarClientes(filtros: ClienteFilters = {}) {
    let query = supabase
      .from('clientes')
      .select('*')
      .eq('user_id', USER_ID_ASSISTENCIA) // FILTRO OBRIGATÓRIO POR USUÁRIO
      .order('created_at', { ascending: false }) // CORRIGIDO: usar created_at

    // Aplicar filtro de busca
    if (filtros.search) {
      query = query.or(`nome.ilike.%${filtros.search}%,telefone.ilike.%${filtros.search}%,cpf_cnpj.ilike.%${filtros.search}%`)
    }

    // Aplicar filtro de status
    if (filtros.ativo !== null && filtros.ativo !== undefined) {
      query = query.eq('ativo', filtros.ativo)
    }

    // Aplicar filtro de tipo
    if (filtros.tipo) {
      query = query.eq('tipo', filtros.tipo)
    }

    const { data, error } = await query

    if (error) {
      console.error('Erro ao buscar clientes no Supabase:', error)
      throw new Error(`Erro ao buscar clientes: ${error.message}`)
    }

    return data as Cliente[]
  }

  // Buscar cliente por ID
  static async buscarClientePorId(id: string) {
    const { data, error } = await supabase
      .from('clientes')
      .select('*')
      .eq('id', id)
      .eq('user_id', USER_ID_ASSISTENCIA) // FILTRO POR USUÁRIO
      .single()

    if (error) {
      throw new Error(`Erro ao buscar cliente: ${error.message}`)
    }

    return data as Cliente
  }

  // Criar novo cliente
  static async criarCliente(cliente: ClienteInput) {
    const clienteComUserId = {
      ...cliente,
      user_id: USER_ID_ASSISTENCIA // ADICIONAR USER_ID AUTOMATICAMENTE
    }
    
    const { data, error } = await supabase
      .from('clientes')
      .insert([clienteComUserId])
      .select()
      .single()

    if (error) {
      throw new Error(`Erro ao criar cliente: ${error.message}`)
    }

    return data as Cliente
  }

  // Atualizar cliente
  static async atualizarCliente(id: string, cliente: Partial<ClienteInput>) {
    const { data, error } = await supabase
      .from('clientes')
      .update({ ...cliente, atualizado_em: new Date().toISOString() })
      .eq('id', id)
      .eq('user_id', USER_ID_ASSISTENCIA) // FILTRO POR USUÁRIO
      .select()
      .single()

    if (error) {
      throw new Error(`Erro ao atualizar cliente: ${error.message}`)
    }

    return data as Cliente
  }

  // Deletar cliente
  static async deletarCliente(id: string) {
    const { error } = await supabase
      .from('clientes')
      .delete()
      .eq('id', id)
      .eq('user_id', USER_ID_ASSISTENCIA) // FILTRO POR USUÁRIO

    if (error) {
      throw new Error(`Erro ao deletar cliente: ${error.message}`)
    }
  }

  // Alternar status ativo/inativo
  static async alternarStatusCliente(id: string, ativo: boolean) {
    return this.atualizarCliente(id, { ativo })
  }

  // Verificar se CPF/CNPJ já existe
  static async verificarCpfCnpjExiste(cpfCnpj: string, excludeId?: string) {
    let query = supabase
      .from('clientes')
      .select('id')
      .eq('cpf_cnpj', cpfCnpj)

    if (excludeId) {
      query = query.neq('id', excludeId)
    }

    const { data, error } = await query

    if (error) {
      throw new Error(`Erro ao verificar CPF/CNPJ: ${error.message}`)
    }

    return data && data.length > 0
  }
}
