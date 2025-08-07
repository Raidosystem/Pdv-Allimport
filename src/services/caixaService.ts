import { supabase } from '../lib/supabase';
import type { 
  Caixa, 
  MovimentacaoCaixa, 
  CaixaCompleto, 
  AberturaCaixaForm, 
  FechamentoCaixaForm, 
  MovimentacaoForm,
  CaixaFiltros,
  CaixaResumo 
} from '../types/caixa';

class CaixaService {
  // ===== HELPER PARA VERIFICAR AUTENTICAÇÃO =====
  
  private async getAuthenticatedUser() {
    const { data: { user }, error } = await supabase.auth.getUser();
    
    if (error) {
      console.error('Erro de autenticação:', error);
      throw new Error('Erro ao verificar autenticação. Faça login novamente.');
    }
    
    if (!user) {
      throw new Error('Usuário não autenticado. Faça login para continuar.');
    }
    
    return user;
  }

  // ===== ABERTURA DE CAIXA =====
  
  async abrirCaixa(dados: AberturaCaixaForm): Promise<Caixa> {
    try {
      // 1. Verificar autenticação
      const usuario = await this.getAuthenticatedUser();

      const hoje = new Date().toISOString().split('T')[0];
      
      const { data: caixaAberto } = await supabase
        .from('caixa')
        .select('*')
        .eq('usuario_id', usuario.id)
        .eq('status', 'aberto')
        .gte('data_abertura', `${hoje}T00:00:00`)
        .lt('data_abertura', `${hoje}T23:59:59`)
        .single();

      if (caixaAberto) {
        // Ao invés de erro, retornar o caixa existente
        console.log('✅ Caixa já aberto encontrado:', caixaAberto);
        return caixaAberto;
      }

      // 2. Criar novo caixa
      const { data, error } = await supabase
        .from('caixa')
        .insert({
          usuario_id: usuario.id,
          valor_inicial: dados.valor_inicial,
          observacoes: dados.observacoes,
          status: 'aberto'
        })
        .select()
        .single();

      if (error) {
        console.error('Erro ao abrir caixa:', error);
        throw new Error('Erro ao abrir caixa. Verifique se as tabelas estão criadas no Supabase.');
      }

      return data;
    } catch (error) {
      if (error instanceof Error) {
        throw error;
      }
      throw new Error('Erro inesperado ao abrir caixa');
    }
  }

  // ===== BUSCAR CAIXA ATUAL =====
  
  async buscarCaixaAtual(): Promise<CaixaCompleto | null> {
    try {
      const usuario = await this.getAuthenticatedUser();

      const { data, error } = await supabase
        .from('caixa')
        .select(`
          *,
          movimentacoes_caixa (*)
        `)
        .eq('usuario_id', usuario.id)
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
    } catch (error) {
      if (error instanceof Error && error.message.includes('autenticado')) {
        throw error;
      }
      return null;
    }
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

    return data.map((caixa: CaixaCompleto) => this.calcularResumoCaixa(caixa));
  }

  // ===== MOVIMENTAÇÕES =====
  
  async adicionarMovimentacao(
    caixaId: string, 
    dados: MovimentacaoForm
  ): Promise<MovimentacaoCaixa> {
    const usuario = await this.getAuthenticatedUser();

    const { data, error } = await supabase
      .from('movimentacoes_caixa')
      .insert({
        caixa_id: caixaId,
        tipo: dados.tipo,
        descricao: dados.descricao,
        valor: dados.valor,
        usuario_id: usuario.id
      })
      .select()
      .single();

    if (error) {
      console.error('Erro ao adicionar movimentação:', error);
      throw new Error('Erro ao registrar movimentação. Verifique se as tabelas estão criadas no Supabase.');
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
        updated_at: new Date().toISOString()
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
  
  private calcularResumoCaixa(caixa: CaixaCompleto): CaixaCompleto {
    const movimentacoes = caixa.movimentacoes_caixa || [];

    const total_entradas = movimentacoes
      .filter((m: MovimentacaoCaixa) => m.tipo === 'entrada')
      .reduce((sum: number, m: MovimentacaoCaixa) => sum + m.valor, 0) || 0;

    const total_saidas = movimentacoes
      .filter((m: MovimentacaoCaixa) => m.tipo === 'saida')
      .reduce((sum: number, m: MovimentacaoCaixa) => sum + m.valor, 0) || 0;

    const saldo_atual = (caixa.valor_inicial || 0) + total_entradas - total_saidas;
    const total_movimentacoes = movimentacoes.length;

    return {
      ...caixa,
      movimentacoes_caixa: movimentacoes,
      total_entradas,
      total_saidas,
      saldo_atual,
      total_movimentacoes
    };
  }

  // ===== VERIFICAÇÕES =====
  
  async verificarCaixaAberto(): Promise<boolean> {
    const caixaAtual = await this.buscarCaixaAtual();
    return caixaAtual !== null;
  }

  async obterResumoDoDia(): Promise<CaixaResumo | null> {
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

  // ===== HISTÓRICO DE CAIXAS =====
  
  async buscarHistorico(filtros: CaixaFiltros = {}): Promise<CaixaCompleto[]> {
    try {
      const usuario = await this.getAuthenticatedUser();

      let query = supabase
        .from('caixa')
        .select(`
          *,
          movimentacoes_caixa (*)
        `)
        .eq('usuario_id', usuario.id)
        .order('data_abertura', { ascending: false });

      // Aplicar filtros
      if (filtros.data_inicio) {
        query = query.gte('data_abertura', `${filtros.data_inicio}T00:00:00`);
      }

      if (filtros.data_fim) {
        query = query.lte('data_abertura', `${filtros.data_fim}T23:59:59`);
      }

      if (filtros.status && filtros.status !== 'todos') {
        query = query.eq('status', filtros.status);
      }

      const { data, error } = await query;

      if (error) {
        console.error('Erro ao buscar histórico:', error);
        throw new Error('Erro ao buscar histórico do caixa');
      }

      return (data || []).map(caixa => this.calcularResumoCaixa(caixa));
    } catch (error) {
      console.error('Erro no serviço de histórico:', error);
      throw error;
    }
  }
}

export const caixaService = new CaixaService();
