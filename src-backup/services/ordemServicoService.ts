// 🔧 Serviço para Ordens de Serviço
import { supabase } from '../lib/supabase'
import { requireAuth } from '../utils/auth'
import type { 
  OrdemServico, 
  NovaOrdemServicoForm, 
  FiltrosOS, 
  StatusOS 
} from '../types/ordemServico'
import type { Cliente } from '../types/cliente'

class OrdemServicoService {
  
  // Gerar número único para a OS
  private async gerarNumeroOS(): Promise<string> {
    const agora = new Date()
    const ano = agora.getFullYear()
    const mes = String(agora.getMonth() + 1).padStart(2, '0')
    const dia = String(agora.getDate()).padStart(2, '0')
    
    // Buscar a última OS do dia para incrementar
    const inicioDia = new Date(ano, agora.getMonth(), agora.getDate())
    const fimDia = new Date(ano, agora.getMonth(), agora.getDate() + 1)
    
    const { data: ultimasOS } = await supabase
      .from('ordens_servico')
      .select('numero_os')
      .gte('criado_em', inicioDia.toISOString())
      .lt('criado_em', fimDia.toISOString())
      .order('numero_os', { ascending: false })
      .limit(1)
    
    let sequencial = 1
    if (ultimasOS && ultimasOS.length > 0) {
      const ultimoNumero = ultimasOS[0].numero_os
      // Extrair o número sequencial do formato OS-YYYYMMDD-XXX
      const match = ultimoNumero.match(/OS-\d{8}-(\d+)/)
      if (match) {
        sequencial = parseInt(match[1]) + 1
      }
    }
    
    const numeroSequencial = String(sequencial).padStart(3, '0')
    return `OS-${ano}${mes}${dia}-${numeroSequencial}`
  }

  // Buscar todas as ordens de serviço do usuário
  async buscarOrdens(filtros?: FiltrosOS): Promise<OrdemServico[]> {
    const user = await requireAuth()

    console.log('🔍 Buscando ordens no banco - timestamp:', Date.now())

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

    console.log('✅ Ordens retornadas do banco:', data?.length || 0)
    console.log('📊 Status detalhados encontrados:', data?.map(o => ({ 
      id: o.id.slice(-6), 
      status: o.status,
      data_entrega: o.data_entrega 
    })) || [])

    return data || []
  }

  // Buscar ordem por ID
  async buscarPorId(id: string): Promise<OrdemServico | null> {
    const user = await requireAuth()

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
    const user = await requireAuth()

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

    // Gerar número único para a OS
    const numero_os = await this.gerarNumeroOS()

    const novaOrdem = {
      numero_os,
      cliente_id,
      tipo: dadosForm.tipo,
      marca: dadosForm.marca,
      modelo: dadosForm.modelo,
      cor: dadosForm.cor,
      numero_serie: dadosForm.numero_serie,
      checklist: dadosForm.checklist,
      observacoes: dadosForm.observacoes,
      defeito_relatado: dadosForm.defeito_relatado,
      // Mapeamento adicional para compatibilidade com schema existente
      descricao_problema: dadosForm.defeito_relatado || 'Não informado',
      equipamento: `${dadosForm.tipo || ''} ${dadosForm.marca || ''} ${dadosForm.modelo || ''}`.trim(),
      status: 'Aberta',
      data_previsao: dadosForm.data_previsao || null,
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
    const user = await requireAuth()

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
    console.log('🔧 OrdemServicoService.atualizarStatus chamado:', { id, novoStatus });
    const user = await requireAuth()
    console.log('👤 Usuário autenticado:', user.id);

    const dadosAtualizacao: any = { status: novoStatus }
    
    // Se for "Entregue", marcar data de entrega
    if (novoStatus === 'Entregue') {
      dadosAtualizacao.data_entrega = new Date().toISOString()
      console.log('📅 Status "Entregue" - adicionando data_entrega');
    }

    console.log('💾 Executando update no Supabase:', dadosAtualizacao);
    const { error } = await supabase
      .from('ordens_servico')
      .update(dadosAtualizacao)
      .eq('id', id)
      .eq('usuario_id', user.id)

    if (error) {
      console.error('❌ Erro no Supabase ao atualizar status:', error)
      throw new Error(`Erro ao atualizar status: ${error.message}`)
    }
    
    console.log('✅ Status atualizado com sucesso no banco!');
  }

  // Processar entrega com garantia
  async processarEntrega(id: string, dados: {
    garantia_meses?: number
    valor_final?: number
    data_entrega: string
    data_fim_garantia?: string
  }): Promise<OrdemServico> {
    const user = await requireAuth()

    console.log('🚀 Iniciando processamento de entrega para OS:', id)
    console.log('📝 Dados para atualização:', dados)

    const dadosAtualizacao = {
      status: 'Entregue' as StatusOS,
      data_entrega: dados.data_entrega,
      valor_final: dados.valor_final,
      garantia_meses: dados.garantia_meses || null,
      data_fim_garantia: dados.data_fim_garantia || null
    }

    console.log('💾 Executando UPDATE no Supabase com:', dadosAtualizacao)

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
      console.error('❌ Erro ao processar entrega no Supabase:', error)
      throw new Error(`Erro ao processar entrega: ${error.message}`)
    }

    console.log('✅ Entrega processada com sucesso no banco!')
    console.log('📊 Status atual no banco:', data.status)
    console.log('📅 Data de entrega:', data.data_entrega)

    return data
  }

  // Buscar clientes por termo
  async buscarClientes(termo: string): Promise<Cliente[]> {
    await requireAuth()

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
    await requireAuth()

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
    const user = await requireAuth()

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
