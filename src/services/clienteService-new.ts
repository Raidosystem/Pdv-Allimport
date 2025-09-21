import { supabase } from '../lib/supabase'
import type { Cliente, ClienteInput, ClienteFilters } from '../types/cliente'

export class ClienteService {
  // Buscar todos os clientes com filtros
  static async buscarClientes(filtros: ClienteFilters = {}) {
    let clientesSupabase: Cliente[] = []

    // Buscar no Supabase
    try {
      let query = supabase
        .from('clientes')
        .select('*')
        .order('criado_em', { ascending: false })

      // Aplicar filtro de busca
      if (filtros.search) {
        query = query.or(`nome.ilike.%${filtros.search}%,telefone.ilike.%${filtros.search}%,cpf_cnpj.ilike.%${filtros.search}%,endereco.ilike.%${filtros.search}%`)
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
      } else {
        clientesSupabase = data as Cliente[]
      }
    } catch (supabaseError) {
      console.warn('Erro ao conectar com Supabase:', supabaseError)
    }
    
    // BACKUP DESABILITADO - Usar apenas Supabase para respeitar RLS
    console.log('🔍 [CLIENTE SERVICE NEW] BACKUP DESABILITADO - Usando apenas Supabase com RLS')
    console.log(`📊 Total de clientes do Supabase: ${clientesSupabase.length}`)
    
    return clientesSupabase
  }

  // Buscar cliente por ID
  static async buscarClientePorId(id: string) {
    const { data, error } = await supabase
      .from('clientes')
      .select('*')
      .eq('id', id)
      .single()

    if (error) {
      throw new Error(`Erro ao buscar cliente: ${error.message}`)
    }

    return data as Cliente
  }

  // Criar novo cliente
  static async criarCliente(cliente: ClienteInput) {
    const { data, error } = await supabase
      .from('clientes')
      .insert([cliente])
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
      .update(cliente)
      .eq('id', id)
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