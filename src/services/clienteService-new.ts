import { supabase } from '../lib/supabase'
import type { Cliente, ClienteInput, ClienteFilters } from '../types/cliente'

export class ClienteService {
  // Buscar todos os clientes com filtros
  static async buscarClientes(filtros: ClienteFilters = {}) {
    let clientesSupabase: Cliente[] = []
    let clientesBackup: Cliente[] = []

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
      console.warn('Erro ao conectar com Supabase, usando apenas backup:', supabaseError)
    }

    // Buscar no backup como fallback
    try {
      const response = await fetch('/backup-allimport.json')
      const backupData = await response.json()
      const clients = backupData.data?.clients || []
      
      // Converter dados do backup para o formato esperado
      const clientesTabela = clients.map((client: any) => {
        // Montar endereço completo se disponível
        let enderecoCompleto = client.address || ''
        if (client.city || client.state || client.zip_code) {
          const partes = []
          if (enderecoCompleto) partes.push(enderecoCompleto)
          if (client.city) partes.push(client.city)
          if (client.state) partes.push(client.state)
          if (client.zip_code) partes.push(`CEP: ${client.zip_code}`)
          enderecoCompleto = partes.join(', ')
        }

        return {
          id: client.id || Date.now().toString(),
          nome: client.name || 'Nome não informado',
          telefone: client.phone || '',
          email: client.email || '',
          cpf_cnpj: String(client.cpf_cnpj || ''),
          endereco: enderecoCompleto,
          tipo: 'Física' as const,
          ativo: true,
          observacoes: '',
          criado_em: client.created_at || new Date().toISOString(),
          atualizado_em: client.updated_at || new Date().toISOString()
        }
      })

      // Buscar também clientes das ordens de serviço (que podem não estar na tabela de clientes)
      const orders = backupData.data?.service_orders || []
      const clientesOrdens = new Map()
      
      orders.forEach((order: any) => {
        if (order.client_name && !clientesOrdens.has(order.client_name)) {
          clientesOrdens.set(order.client_name, {
            id: order.client_id || `backup-${order.client_name.replace(/\s+/g, '-').toLowerCase()}`,
            nome: order.client_name,
            telefone: order.client_phone || '',
            email: '',
            cpf_cnpj: '',
            endereco: '',
            tipo: 'Física' as const,
            ativo: true,
            observacoes: 'Cliente importado das ordens de serviço',
            criado_em: order.created_at || new Date().toISOString(),
            atualizado_em: order.updated_at || new Date().toISOString()
          })
        }
      })

      // Combinar clientes da tabela e das ordens
      clientesBackup = [...clientesTabela, ...Array.from(clientesOrdens.values())]

      // Aplicar filtro de busca nos clientes do backup
      if (filtros.search) {
        const search = filtros.search.toLowerCase()
        clientesBackup = clientesBackup.filter(cliente => 
          cliente.nome.toLowerCase().includes(search) ||
          cliente.telefone.includes(search) ||
          (cliente.cpf_cnpj && String(cliente.cpf_cnpj).includes(search)) ||
          (cliente.endereco && cliente.endereco.toLowerCase().includes(search))
        )
      }
    } catch (backupError) {
      console.warn('Erro ao buscar clientes no backup:', backupError)
    }

    // Combinar clientes do Supabase e backup, removendo duplicatas
    const todosClientes = [...clientesSupabase]
    
    // Adicionar clientes do backup que não existem no Supabase
    clientesBackup.forEach(clienteBackup => {
      const jaExiste = todosClientes.some(cliente => 
        cliente.id === clienteBackup.id || 
        (cliente.nome === clienteBackup.nome && cliente.telefone === clienteBackup.telefone)
      )
      if (!jaExiste) {
        todosClientes.push(clienteBackup)
      }
    })

    return todosClientes
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