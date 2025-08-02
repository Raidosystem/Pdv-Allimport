import { supabase } from '../lib/supabase';
import type { 
  Caixa, 
  MovimentacaoCaixa, 
  CaixaCompleto, 
  AberturaCaixaForm, 
  FechamentoCaixaForm, 
  MovimentacaoForm,
  CaixaFiltros 
} from '../types/caixa';

class CaixaService {
  // ===== ABERTURA DE CAIXA =====
  
  async abrirCaixa(dados: AberturaCaixaForm): Promise<Caixa> {
    // 1. Verificar se já existe caixa aberto para o usuário hoje
    const { data: usuario } = await supabase.auth.getUser();
    if (!usuario.user) {
      throw new Error('Usuário não autenticado');
    }

    const hoje = new Date().toISOString().split('T')[0];
    
    const { data: caixaAberto } = await supabase
      .from('caixa')
      .select('*')
      .eq('usuario_id', usuario.user.id)
      .eq('status', 'aberto')
      .gte('data_abertura', `${hoje}T00:00:00`)
      .lt('data_abertura', `${hoje}T23:59:59`)
      .single();

    if (caixaAberto) {
      throw new Error('Já existe um caixa aberto para hoje. Feche o caixa atual antes de abrir um novo.');
    }

    // 2. Criar novo caixa
    const { data, error } = await supabase
      .from('caixa')
      .insert({
        usuario_id: usuario.user.id,
        valor_inicial: dados.valor_inicial,
        observacoes: dados.observacoes,
        status: 'aberto'
      })
      .select()
      .single();

    if (error) {
      console.error('Erro ao abrir caixa:', error);
      throw new Error('Erro ao abrir caixa. Tente novamente.');
    }

    return data;
  }

  // ===== BUSCAR CAIXA ATUAL =====
  
  async buscarCaixaAtual(): Promise<CaixaCompleto | null> {
    const { data: usuario } = await supabase.auth.getUser();
    if (!usuario.user) return null;

    const { data, error } = await supabase
      .from('caixa')
      .select(`
        *,
        movimentacoes_caixa (*)
      `)
      .eq('usuario_id', usuario.user.id)
      .eq('status', 'aberto')
      .order('data_abertura', { ascending: false })
      .limit(1)
      .single();

    if (error && error.code !== 'PGRST116') {
      console.error('Erro ao buscar caixa atual:', error);
      throw new Error('Erro ao buscar caixa atual');
    }

    if (!data) return null;

    return this.calcularResumoCaixa(data);
  }

  // ===== LISTAR CAIXAS COM FILTROS =====
  
  async listarCaixas(filtros: CaixaFiltros = {}): Promise<CaixaCompleto[]> {
    let query = supabase
      .from('caixa')
      .select(`
        *,
        movimentacoes_caixa (*)
      `);

    // Aplicar filtros
    if (filtros.status && filtros.status !== 'todos') {
      query = query.eq('status', filtros.status);
    }

    if (filtros.data_inicio) {
      query = query.gte('data_abertura', filtros.data_inicio);
    }

    if (filtros.data_fim) {
      query = query.lte('data_abertura', filtros.data_fim);
    }

    if (filtros.usuario_id) {
      query = query.eq('usuario_id', filtros.usuario_id);
    }

    const { data, error } = await query
      .order('data_abertura', { ascending: false })
      .limit(50);

    if (error) {
      console.error('Erro ao listar caixas:', error);
      throw new Error('Erro ao carregar histórico de caixas');
    }

    return data.map((caixa: any) => this.calcularResumoCaixa(caixa));
  }

  // ===== MOVIMENTAÇÕES =====
  
  async adicionarMovimentacao(
    caixaId: string, 
    dados: MovimentacaoForm
  ): Promise<MovimentacaoCaixa> {
    const { data: usuario } = await supabase.auth.getUser();
    if (!usuario.user) {
      throw new Error('Usuário não autenticado');
    }

    const { data, error } = await supabase
      .from('movimentacoes_caixa')
      .insert({
        caixa_id: caixaId,
        tipo: dados.tipo,
        descricao: dados.descricao,
        valor: dados.valor,
        usuario_id: usuario.user.id
      })
      .select()
      .single();

    if (error) {
      console.error('Erro ao adicionar movimentação:', error);
      throw new Error('Erro ao registrar movimentação');
    }

    return data;
  }

  async listarMovimentacoes(caixaId: string): Promise<MovimentacaoCaixa[]> {
    const { data, error } = await supabase
      .from('movimentacoes_caixa')
      .select('*')
      .eq('caixa_id', caixaId)
      .order('data', { ascending: false });

    if (error) {
      console.error('Erro ao listar movimentações:', error);
      throw new Error('Erro ao carregar movimentações');
    }

    return data;
  }

  // ===== FECHAMENTO DE CAIXA =====
  
  async fecharCaixa(
    caixaId: string, 
    dados: FechamentoCaixaForm
  ): Promise<Caixa> {
    // 1. Buscar caixa atual para calcular diferença
    const caixaAtual = await this.buscarCaixaPorId(caixaId);
    if (!caixaAtual) {
      throw new Error('Caixa não encontrado');
    }

    if (caixaAtual.status === 'fechado') {
      throw new Error('Este caixa já está fechado');
    }

    // 2. Calcular saldo esperado
    const resumo = this.calcularResumoCaixa(caixaAtual);
    const saldoEsperado = resumo.saldo_atual || 0;
    const diferenca = dados.valor_contado - saldoEsperado;

    // 3. Atualizar caixa
    const { data, error } = await supabase
      .from('caixa')
      .update({
        status: 'fechado',
        valor_final: dados.valor_contado,
        diferenca: diferenca,
        data_fechamento: new Date().toISOString(),
        observacoes: dados.observacoes || caixaAtual.observacoes,
        atualizado_em: new Date().toISOString()
      })
      .eq('id', caixaId)
      .select()
      .single();

    if (error) {
      console.error('Erro ao fechar caixa:', error);
      throw new Error('Erro ao fechar caixa');
    }

    return data;
  }

  // ===== BUSCAR CAIXA POR ID =====
  
  async buscarCaixaPorId(id: string): Promise<CaixaCompleto | null> {
    const { data, error } = await supabase
      .from('caixa')
      .select(`
        *,
        movimentacoes_caixa (*)
      `)
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') return null;
      console.error('Erro ao buscar caixa:', error);
      throw new Error('Erro ao buscar caixa');
    }

    return this.calcularResumoCaixa(data);
  }

  // ===== FUNÇÕES AUXILIARES =====
  
  private calcularResumoCaixa(caixa: any): CaixaCompleto {
    const movimentacoes = caixa.movimentacoes_caixa || [];
    
    const total_entradas = movimentacoes
      .filter((m: MovimentacaoCaixa) => m.tipo === 'entrada')
      .reduce((sum: number, m: MovimentacaoCaixa) => sum + m.valor, 0);
    
    const total_saidas = movimentacoes
      .filter((m: MovimentacaoCaixa) => m.tipo === 'saida')
      .reduce((sum: number, m: MovimentacaoCaixa) => sum + m.valor, 0);
    
    const saldo_atual = caixa.valor_inicial + total_entradas - total_saidas;

    return {
      ...caixa,
      movimentacoes,
      total_entradas,
      total_saidas,
      saldo_atual
    };
  }

  // ===== VERIFICAÇÕES =====
  
  async verificarCaixaAberto(): Promise<boolean> {
    const caixaAtual = await this.buscarCaixaAtual();
    return caixaAtual !== null;
  }

  async obterResumoDoDia(): Promise<any> {
    const { data: usuario } = await supabase.auth.getUser();
    if (!usuario.user) return null;

    const hoje = new Date().toISOString().split('T')[0];
    
    const { data } = await supabase
      .from('caixa')
      .select(`
        *,
        movimentacoes_caixa (*)
      `)
      .eq('usuario_id', usuario.user.id)
      .gte('data_abertura', `${hoje}T00:00:00`)
      .lt('data_abertura', `${hoje}T23:59:59`)
      .order('data_abertura', { ascending: false })
      .limit(1)
      .single();

    if (!data) return null;

    return this.calcularResumoCaixa(data);
  }
}

export const caixaService = new CaixaService();
