// 🔧 Serviço para Ordens de Serviço
import { supabase } from '../lib/supabase'
import type { 
  OrdemServico, 
  NovaOrdemServicoForm, 
  FiltrosOS, 
  StatusOS 
} from '../types/ordemServico'
import type { Cliente } from '../types/cliente'

class OrdemServicoService {
  
  // Buscar todas as ordens de serviço do usuário
  async buscarOrdens(filtros?: FiltrosOS): Promise<OrdemServico[]> {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      throw new Error('Usuário não autenticado')
    }

    let query = supabase
      .from('ordens_servico')
      .select(`
        *,
        cliente:clientes(*)
      `)
      .eq('usuario_id', user.id)
      .order('data_entrada', { ascending: false })

    // Aplicar filtros
    if (filtros?.status && filtros.status.length > 0) {
      query = query.in('status', filtros.status)
    }

    if (filtros?.tipo && filtros.tipo.length > 0) {
      query = query.in('tipo', filtros.tipo)
    }

    if (filtros?.data_inicio) {
      query = query.gte('data_entrada', filtros.data_inicio)
    }

    if (filtros?.data_fim) {
      query = query.lte('data_entrada', filtros.data_fim)
    }

    if (filtros?.busca) {
      query = query.or(
        `marca.ilike.%${filtros.busca}%,modelo.ilike.%${filtros.busca}%,numero_serie.ilike.%${filtros.busca}%`
      )
    }

    const { data, error } = await query

    if (error) {
      console.error('Erro ao buscar ordens:', error)
      throw new Error(`Erro ao buscar ordens de serviço: ${error.message}`)
    }

    return data || []
  }

  // Buscar ordem por ID
  async buscarPorId(id: string): Promise<OrdemServico | null> {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      throw new Error('Usuário não autenticado')
    }

    const { data, error } = await supabase
      .from('ordens_servico')
      .select(`
        *,
        cliente:clientes(*)
      `)
      .eq('id', id)
      .eq('usuario_id', user.id)
      .single()

    if (error) {
      console.error('Erro ao buscar ordem:', error)
      throw new Error(`Erro ao buscar ordem de serviço: ${error.message}`)
    }

    return data
  }

  // Criar nova ordem de serviço
  async criarOrdem(dadosForm: NovaOrdemServicoForm): Promise<OrdemServico> {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      throw new Error('Usuário não autenticado')
    }

    // Se não tem cliente_id, criar novo cliente
    let cliente_id = dadosForm.cliente_id

    if (!cliente_id && dadosForm.cliente_nome && dadosForm.cliente_telefone) {
      const novoCliente = await this.criarOuBuscarCliente(
        dadosForm.cliente_nome,
        dadosForm.cliente_telefone,
        dadosForm.cliente_email
      )
      cliente_id = novoCliente.id
    }

    if (!cliente_id) {
      throw new Error('Cliente é obrigatório')
    }

    const novaOrdem = {
      cliente_id,
      tipo: dadosForm.tipo,
      marca: dadosForm.marca,
      modelo: dadosForm.modelo,
      cor: dadosForm.cor,
      numero_serie: dadosForm.numero_serie,
      checklist: dadosForm.checklist,
      observacoes: dadosForm.observacoes,
      defeito_relatado: dadosForm.defeito_relatado,
      data_previsao: dadosForm.data_previsao || null, // Converter string vazia para null
      valor_orcamento: dadosForm.valor_orcamento,
      usuario_id: user.id
    }

    const { data, error } = await supabase
      .from('ordens_servico')
      .insert(novaOrdem)
      .select(`
        *,
        cliente:clientes(*)
      `)
      .single()

    if (error) {
      console.error('Erro ao criar ordem:', error)
      throw new Error(`Erro ao criar ordem de serviço: ${error.message}`)
    }

    return data
  }

  // Atualizar ordem de serviço
  async atualizarOrdem(id: string, dados: Partial<OrdemServico>): Promise<OrdemServico> {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      throw new Error('Usuário não autenticado')
    }

    const { data, error } = await supabase
      .from('ordens_servico')
      .update(dados)
      .eq('id', id)
      .eq('usuario_id', user.id)
      .select(`
        *,
        cliente:clientes(*)
      `)
      .single()

    if (error) {
      console.error('Erro ao atualizar ordem:', error)
      throw new Error(`Erro ao atualizar ordem de serviço: ${error.message}`)
    }

    return data
  }

  // Atualizar apenas o status
  async atualizarStatus(id: string, novoStatus: StatusOS): Promise<void> {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      throw new Error('Usuário não autenticado')
    }

    const dadosAtualizacao: any = { status: novoStatus }
    
    // Se for "Entregue", marcar data de entrega
    if (novoStatus === 'Entregue') {
      dadosAtualizacao.data_entrega = new Date().toISOString()
    }

    const { error } = await supabase
      .from('ordens_servico')
      .update(dadosAtualizacao)
      .eq('id', id)
      .eq('usuario_id', user.id)

    if (error) {
      console.error('Erro ao atualizar status:', error)
      throw new Error(`Erro ao atualizar status: ${error.message}`)
    }
  }

  // Processar entrega com garantia
  async processarEntrega(id: string, dados: {
    garantia_meses?: number
    valor_final?: number
    data_entrega: string
    data_fim_garantia?: string
  }): Promise<OrdemServico> {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      throw new Error('Usuário não autenticado')
    }

    const dadosAtualizacao = {
      status: 'Entregue' as StatusOS,
      data_entrega: dados.data_entrega,
      valor_final: dados.valor_final,
      garantia_meses: dados.garantia_meses || null,
      data_fim_garantia: dados.data_fim_garantia || null
    }

    const { data, error } = await supabase
      .from('ordens_servico')
      .update(dadosAtualizacao)
      .eq('id', id)
      .eq('usuario_id', user.id)
      .select(`
        *,
        cliente:clientes(*)
      `)
      .single()

    if (error) {
      console.error('Erro ao processar entrega:', error)
      throw new Error(`Erro ao processar entrega: ${error.message}`)
    }

    return data
  }

  // Buscar clientes por termo
  async buscarClientes(termo: string): Promise<Cliente[]> {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      throw new Error('Usuário não autenticado')
    }

    const { data, error } = await supabase
      .from('clientes')
      .select('*')
      .or(`nome.ilike.%${termo}%,telefone.ilike.%${termo}%`)
      .order('nome')
      .limit(10)

    if (error) {
      console.error('Erro ao buscar clientes:', error)
      return []
    }

    return data || []
  }

  // Criar ou buscar cliente existente
  private async criarOuBuscarCliente(nome: string, telefone: string, email?: string): Promise<Cliente> {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      throw new Error('Usuário não autenticado')
    }

    // Primeiro, tentar encontrar cliente existente pelo telefone
    const { data: clienteExistente } = await supabase
      .from('clientes')
      .select('*')
      .eq('telefone', telefone)
      .single()

    if (clienteExistente) {
      return clienteExistente
    }

    // Criar novo cliente
    const novoCliente = {
      nome,
      telefone,
      email: email || null
    }

    const { data, error } = await supabase
      .from('clientes')
      .insert(novoCliente)
      .select('*')
      .single()

    if (error) {
      console.error('Erro ao criar cliente:', error)
      throw new Error(`Erro ao criar cliente: ${error.message}`)
    }

    return data
  }

  // Estatísticas do dashboard
  async obterEstatisticas(): Promise<{
    total: number
    emAnalise: number
    emConserto: number
    prontos: number
    encerradas: number
  }> {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      throw new Error('Usuário não autenticado')
    }

    const { data, error } = await supabase
      .from('ordens_servico')
      .select('status')
      .eq('usuario_id', user.id)

    if (error) {
      console.error('Erro ao buscar estatísticas:', error)
      return { total: 0, emAnalise: 0, emConserto: 0, prontos: 0, encerradas: 0 }
    }

    const stats = {
      total: data.length,
      emAnalise: data.filter(os => os.status === 'Em análise').length,
      emConserto: data.filter(os => ['Em conserto', 'Aguardando peças'].includes(os.status)).length,
      prontos: data.filter(os => os.status === 'Pronto').length,
      encerradas: data.filter(os => os.status === 'Entregue').length
    }

    return stats
  }
}

export const ordemServicoService = new OrdemServicoService()
