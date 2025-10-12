import { supabase } from '../lib/supabase'
import type { Cliente, ClienteInput, ClienteFilters } from '../types/cliente'

export class ClienteService {
  // Buscar todos os clientes com filtros (RLS ativo filtra automaticamente por usuário)
  static async buscarClientes(filtros: ClienteFilters = {}) {
    try {
      console.log('🚀 [CLIENTE SERVICE] Iniciando busca com filtros:', filtros)
      console.log('🔒 [CLIENTE SERVICE] RLS ativo - filtro automático por usuário')
      console.log('🔍 [CLIENTE SERVICE] Contexto de chamada:', (new Error().stack || '').split('\n')[2]?.trim())
      
      // Buscar no Supabase - RLS automaticamente filtra por user_id
      let query = supabase
        .from('clientes')
        .select('*')
        .order('criado_em', { ascending: false })

      // Aplicar filtro de busca
      if (filtros.search) {
        console.log(`🔍 [CLIENTE SERVICE] Busca iniciada com termo: "${filtros.search}"`)
        console.log(`🎯 [CLIENTE SERVICE] Tipo de busca: "${filtros.searchType || 'geral'}"`)
        
        // Normalizar o termo de busca para números (CPF/telefone)
        const searchNormalized = filtros.search.replace(/\D/g, '')
        console.log(`🔢 [CLIENTE SERVICE] Termo normalizado (só dígitos): "${searchNormalized}"`)
        
        // Definir condições de busca baseadas no tipo
        let searchConditions: string[] = []
        
        switch (filtros.searchType) {
          case 'telefone':
            searchConditions = [`telefone.ilike.%${searchNormalized}%`]
            break
            
          default: // 'geral' - busca por nome e CPF/CNPJ
            // Buscar em nome, telefone, endereço, cpf_cnpj e cpf_digits
            searchConditions = [
              `nome.ilike.%${filtros.search}%`,
              `telefone.ilike.%${filtros.search}%`,
              `cpf_cnpj.ilike.%${filtros.search}%`,
              `endereco.ilike.%${filtros.search}%`
            ]
            
            // Se o termo de busca contém dígitos, também buscar em campos numéricos
            if (searchNormalized.length > 0) {
              searchConditions.push(`cpf_digits.ilike.%${searchNormalized}%`)
              // Buscar telefone apenas pelos dígitos (para encontrar independente da formatação)
              searchConditions.push(`telefone.ilike.%${searchNormalized}%`)
            }
            break
        }
        
        // Aplicar filtro OR para buscar em qualquer campo
        const searchFilter = searchConditions.join(',')
        console.log(`📋 [CLIENTE SERVICE] Filtro de busca aplicado: ${searchFilter}`)
        query = query.or(searchFilter)
      }

      // Aplicar filtro de status ativo/inativo
      if (filtros.ativo !== undefined) {
        console.log(`✅ [CLIENTE SERVICE] Filtro de status aplicado: ${filtros.ativo ? 'ativo' : 'inativo'}`)
        query = query.eq('ativo', filtros.ativo)
      }

      console.log('📡 [CLIENTE SERVICE] Executando query no Supabase...')
      const { data: clientesSupabase, error } = await query

      if (error) {
        console.error('❌ [CLIENTE SERVICE] Erro na query Supabase:', error)
        throw new Error(`Erro ao buscar clientes: ${error.message}`)
      }

      console.log(`✅ [CLIENTE SERVICE] Query executada com sucesso! ${clientesSupabase?.length || 0} clientes encontrados`)
      return clientesSupabase as Cliente[] || []

    } catch (error) {
      console.error('💥 [CLIENTE SERVICE] Erro inesperado:', error)
      throw error
    }
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

  // Criar cliente (RLS automaticamente define user_id)
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

  // Atualizar cliente (RLS garante que só edita clientes do próprio usuário)
  static async atualizarCliente(id: string, cliente: Partial<ClienteInput>) {
    const { data, error } = await supabase
      .from('clientes')
      .update({ ...cliente, atualizado_em: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single()

    if (error) {
      throw new Error(`Erro ao atualizar cliente: ${error.message}`)
    }

    return data as Cliente
  }

  // Deletar cliente (RLS garante que só deleta clientes do próprio usuário)
  static async deletarCliente(id: string) {
    const { error } = await supabase
      .from('clientes')
      .delete()
      .eq('id', id)

    if (error) {
      throw new Error(`Erro ao deletar cliente: ${error.message}`)
    }
  }

  // Contar total de clientes
  static async contarClientes(filtros: ClienteFilters = {}) {
    let query = supabase
      .from('clientes')
      .select('id', { count: 'exact', head: true })

    // Aplicar mesmo filtro de busca se existir
    if (filtros.search) {
      const searchNormalized = filtros.search.replace(/\D/g, '')
      let searchConditions: string[] = []
      
      switch (filtros.searchType) {
        case 'telefone':
          searchConditions = [`telefone.ilike.%${searchNormalized}%`]
          break
          
        default:
          searchConditions = [
            `nome.ilike.%${filtros.search}%`,
            `telefone.ilike.%${filtros.search}%`,
            `cpf_cnpj.ilike.%${filtros.search}%`,
            `endereco.ilike.%${filtros.search}%`
          ]
          
          if (searchNormalized.length > 0) {
            searchConditions.push(`cpf_digits.ilike.%${searchNormalized}%`)
            searchConditions.push(`telefone.ilike.%${searchNormalized}%`)
          }
          break
      }
      
      const searchFilter = searchConditions.join(',')
      query = query.or(searchFilter)
    }

    if (filtros.ativo !== undefined) {
      query = query.eq('ativo', filtros.ativo)
    }

    const { count, error } = await query

    if (error) {
      throw new Error(`Erro ao contar clientes: ${error.message}`)
    }

    return count || 0
  }
}