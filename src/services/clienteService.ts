import { supabase } from '../lib/supabase'
import type { Cliente, ClienteInput, ClienteFilters } from '../types/cliente'

export class ClienteService {
  // Buscar todos os clientes com filtros
  static async buscarClientes(filtros: ClienteFilters = {}) {
    try {
      console.log('🚀 [CLIENTE SERVICE] Iniciando busca com filtros:', filtros)
      console.log('🔍 [CLIENTE SERVICE] Contexto de chamada:', (new Error().stack || '').split('\n')[2]?.trim())
      
      // Primeiro tentar buscar no Supabase
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
        
        console.log(`📋 [CLIENTE SERVICE] Condições de busca (${filtros.searchType || 'geral'}):`, searchConditions)
        const finalQuery = searchConditions.join(',')
        console.log(`🔗 [CLIENTE SERVICE] Query final: .or("${finalQuery}")`)
        query = query.or(finalQuery)
      }

      // Aplicar filtro de status
      if (filtros.ativo !== null && filtros.ativo !== undefined) {
        query = query.eq('ativo', filtros.ativo)
      }

      // Aplicar filtro de tipo
      if (filtros.tipo) {
        query = query.eq('tipo', filtros.tipo)
      }

      // Aplicar limite se especificado
      if (filtros.limit && filtros.limit > 0) {
        query = query.limit(filtros.limit)
      }

      const { data, error } = await query

      if (error) {
        console.warn('[CLIENTE SERVICE] Erro ao buscar clientes no Supabase, tentando backup:', error)
      } else {
        console.log(`✅ [CLIENTE SERVICE] Query executada com sucesso`)
      }

      let clientesSupabase = data || []
      console.log(`📊 [CLIENTE SERVICE] Encontrados ${clientesSupabase.length} clientes no Supabase`)
      
      // Log detalhado dos primeiros clientes encontrados para debug
      if (filtros.search && clientesSupabase.length > 0) {
        console.log(`🔍 [CLIENTE SERVICE] Primeiros clientes encontrados:`)
        clientesSupabase.slice(0, 3).forEach((cliente, index) => {
          console.log(`  ${index + 1}. ${cliente.nome} - CPF_CNPJ: "${cliente.cpf_cnpj}" - CPF_DIGITS: "${cliente.cpf_digits}"`)
        })
      } else if (filtros.search) {
        console.log(`❌ [CLIENTE SERVICE] Nenhum cliente encontrado com o termo: "${filtros.search}"`)
        console.log(`🔧 [CLIENTE SERVICE] Termo normalizado era: "${filtros.search.replace(/\D/g, '')}"`)
      }

      // BACKUP DESABILITADO - Usar apenas Supabase para respeitar RLS
      console.log('🔍 [CLIENTE SERVICE] BACKUP DESABILITADO - Usando apenas Supabase')
      
      /*
      try {
        const response = await fetch('/backup-allimport.json')
        const backupData = await response.json()
        
        // Buscar clientes da tabela de clientes
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
          console.log(`🔍 [CLIENTE SERVICE] Aplicando filtro de busca no backup: "${search}"`)
          
          const clientesAntesFiltro = clientesBackup.length
          clientesBackup = clientesBackup.filter(cliente => {
            const nome = cliente.nome.toLowerCase()
            const telefone = cliente.telefone || ''
            const cpf_cnpj = String(cliente.cpf_cnpj || '')
            const cpf_digits = String(cliente.cpf_digits || '')
            const endereco = (cliente.endereco || '').toLowerCase()
            
            // Buscar em diferentes campos
            const matchNome = nome.includes(search)
            const matchTelefone = telefone.includes(search) || telefone.replace(/\D/g, '').includes(search.replace(/\D/g, ''))
            const matchCpfCnpj = cpf_cnpj.includes(search) || cpf_cnpj.replace(/\D/g, '').includes(search.replace(/\D/g, ''))
            const matchCpfDigits = cpf_digits.includes(search.replace(/\D/g, ''))
            const matchEndereco = endereco.includes(search)
            
            const match = matchNome || matchTelefone || matchCpfCnpj || matchCpfDigits || matchEndereco
            
            if (match) {
              console.log(`✅ [BACKUP FILTER] Match encontrado: ${cliente.nome}`)
              console.log(`    - Nome: ${matchNome ? '✓' : '✗'}`)
              console.log(`    - Telefone: ${matchTelefone ? '✓' : '✗'}`)
              console.log(`    - CPF/CNPJ: ${matchCpfCnpj ? '✓' : '✗'} (${cpf_cnpj})`)
              console.log(`    - CPF Digits: ${matchCpfDigits ? '✓' : '✗'} (${cpf_digits})`)
              console.log(`    - Endereço: ${matchEndereco ? '✓' : '✗'}`)
            }
            
            return match
          })
          
          console.log(`📊 [CLIENTE SERVICE] Filtro aplicado: ${clientesAntesFiltro} → ${clientesBackup.length} clientes`)
        }
      } catch (backupError) {
        console.warn('Erro ao buscar clientes no backup:', backupError)
      }
      */

      // Usar apenas clientes do Supabase (respeitando RLS)
      const todosClientes = [...clientesSupabase]
      
      /*
      clientesBackup.forEach(clienteBackup => {
        // Procurar por cliente similar no Supabase
        const clienteSupabaseIndex = todosClientes.findIndex(cliente => 
          cliente.nome.toLowerCase() === clienteBackup.nome.toLowerCase() ||
          (cliente.telefone && clienteBackup.telefone && cliente.telefone === clienteBackup.telefone) ||
          (cliente.cpf_cnpj && clienteBackup.cpf_cnpj && 
           cliente.cpf_cnpj.replace(/\D/g, '') === clienteBackup.cpf_cnpj.replace(/\D/g, ''))
        )
        
        if (clienteSupabaseIndex >= 0) {
          // Cliente existe no Supabase, mesclar dados priorizando os mais completos
          const clienteSupabase = todosClientes[clienteSupabaseIndex]
          const clienteMesclado = {
            ...clienteSupabase,
            // Priorizar dados do backup se estiverem mais completos
            cpf_cnpj: clienteBackup.cpf_cnpj || clienteSupabase.cpf_cnpj,
            endereco: clienteBackup.endereco || clienteSupabase.endereco,
            telefone: clienteBackup.telefone || clienteSupabase.telefone,
            email: clienteBackup.email || clienteSupabase.email,
          }
          
          console.log(`🔄 Mesclando dados para ${clienteSupabase.nome}:`, {
            cpf_antes: clienteSupabase.cpf_cnpj,
            cpf_depois: clienteMesclado.cpf_cnpj,
            endereco_antes: clienteSupabase.endereco,
            endereco_depois: clienteMesclado.endereco
          })
          
          todosClientes[clienteSupabaseIndex] = clienteMesclado
        } else {
          // Cliente não existe no Supabase, adicionar do backup
          todosClientes.push(clienteBackup)
        }
      })
      */

      console.log(`📋 Clientes encontrados: ${clientesSupabase.length} do Supabase (backup desabilitado) = ${todosClientes.length} total`)
      
      // Aplicar limite final se especificado
      let clientesFinais = todosClientes
      if (filtros.limit && filtros.limit > 0) {
        clientesFinais = todosClientes.slice(0, filtros.limit)
        console.log(`📊 [CLIENTE SERVICE] Aplicando limite final: ${todosClientes.length} → ${clientesFinais.length} clientes`)
      }
      
      return clientesFinais

    } catch (error) {
      console.error('Erro geral ao buscar clientes:', error)
      throw new Error(`Erro ao buscar clientes: ${(error as Error).message}`)
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
      .update({ ...cliente, atualizado_em: new Date().toISOString() })
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

  // Buscar clientes por CPF/CNPJ em tempo real
  static async buscarPorCpf(cpf: string): Promise<Cliente[]> {
    const cpfLimpo = cpf.replace(/\D/g, '')
    
    if (cpfLimpo.length < 8) {
      return []
    }

    try {
      console.log('🔍 [CLIENTE SERVICE] Buscando por CPF:', cpfLimpo)
      
      // Primeiro tentar buscar no Supabase
      let query = supabase
        .from('clientes')
        .select('*')
        .order('criado_em', { ascending: false })

      // Busca parcial ou exata dependendo do tamanho
      if (cpfLimpo.length === 11 || cpfLimpo.length === 14) {
        // Busca exata para CPF ou CNPJ completo
        query = query.eq('cpf_cnpj', cpfLimpo)
      } else {
        // Busca parcial para dígitos iniciais
        query = query.like('cpf_cnpj', `${cpfLimpo}%`)
      }

      const { data, error } = await query

      let clientesSupabase = data || []
      
      if (error) {
        console.warn('[CLIENTE SERVICE] Erro no Supabase para busca CPF:', error)
      }

      console.log(`📊 [CLIENTE SERVICE] Encontrados ${clientesSupabase.length} clientes no Supabase por CPF`)

      // BACKUP DESABILITADO - Usar apenas Supabase
      console.log('🔍 [CLIENTE SERVICE] BACKUP DESABILITADO para busca por CPF - Usando apenas Supabase')
      
      /*
      // Se não encontrou no Supabase ou temos poucos resultados, buscar no backup
      if (clientesSupabase.length === 0) {
        try {
          const response = await fetch('/backup-allimport.json')
          const backupData = await response.json()
          
          const clients = backupData.data?.clients || []
          
          // Filtrar por CPF no backup
          const clientesFiltrados = clients.filter((client: any) => {
            const cpfClient = String(client.cpf_cnpj || '').replace(/\D/g, '')
            
            if (cpfLimpo.length === 11 || cpfLimpo.length === 14) {
              // Busca exata
              return cpfClient === cpfLimpo
            } else {
              // Busca parcial
              return cpfClient.startsWith(cpfLimpo)
            }
          })
          
          // Converter para formato do cliente
          const clientesBackup = clientesFiltrados.map((client: any) => ({
            id: client.id || `backup-${Date.now()}-${Math.random()}`,
            user_id: 'backup-user',
            nome: client.name || '',
            cpf_cnpj: client.cpf_cnpj || '',
            telefone: client.phone || '',
            email: client.email || '',
            endereco: client.address || '',
            cidade: client.city || '',
            estado: client.state || '',
            cep: client.zip_code || '',
            tipo: String(client.cpf_cnpj || '').replace(/\D/g, '').length === 11 ? 'fisica' : 'juridica',
            observacoes: '',
            ativo: true,
            criado_em: new Date().toISOString(),
            atualizado_em: new Date().toISOString()
          }))

          console.log(`📦 [CLIENTE SERVICE] Encontrados ${clientesBackup.length} clientes no backup por CPF`)
          
          return clientesBackup
        } catch (backupError) {
          console.warn('[CLIENTE SERVICE] Erro ao buscar no backup:', backupError)
        }
      }
      */

      return clientesSupabase

    } catch (error) {
      console.error('❌ [CLIENTE SERVICE] Erro ao buscar por CPF:', error)
      throw new Error(`Erro ao buscar cliente por CPF: ${error instanceof Error ? error.message : 'Erro desconhecido'}`)
    }
  }
}
