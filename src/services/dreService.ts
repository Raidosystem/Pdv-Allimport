// ============================================
// SERVIÇO DRE - Business Logic
// ============================================

import { supabase } from '../lib/supabase';
import type {
  DRE,
  FiltrosDRE,
  KPIsDRE,
  Compra,
  CompraForm,
  Despesa,
  DespesaForm,
  OutraMovimentacaoFinanceira,
  OutraMovimentacaoForm,
  MovimentacaoEstoque,
  FiltrosCompras,
  FiltrosDespesas,
  FiltrosMovimentacoes,
  RelatorioEstoque,
  DREComparativo,
} from '../types/dre';

class DREService {
  // ===== COMPRAS =====

  async criarCompra(dados: CompraForm): Promise<Compra> {
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error('Usuário não autenticado');

      // Buscar empresa_id
      const { data: empresas } = await supabase
        .from('empresas')
        .select('id')
        .eq('user_id', user.id)
        .single();

      if (!empresas) throw new Error('Empresa não encontrada');

      const empresa_id = empresas.id;

      // Calcular valor total
      const valor_total = dados.itens.reduce(
        (sum, item) => sum + item.quantidade * item.custo_unitario,
        0
      );

      // Criar compra
      const { data: compra, error: compraError } = await supabase
        .from('compras')
        .insert({
          empresa_id,
          user_id: user.id,
          fornecedor_nome: dados.fornecedor_nome,
          fornecedor_cnpj: dados.fornecedor_cnpj,
          numero_nota: dados.numero_nota,
          data_compra: dados.data_compra.toISOString(),
          valor_total,
          observacoes: dados.observacoes,
          status: 'pendente',
        })
        .select()
        .single();

      if (compraError) throw compraError;

      // Criar itens da compra
      const itens = dados.itens.map((item) => ({
        compra_id: compra.id,
        produto_id: item.produto_id,
        empresa_id,
        user_id: user.id,
        quantidade: item.quantidade,
        custo_unitario: item.custo_unitario,
      }));

      const { error: itensError } = await supabase
        .from('itens_compra')
        .insert(itens);

      if (itensError) throw itensError;

      // Aplicar compra (atualizar estoque e custo médio)
      const { error: aplicarError } = await supabase.rpc('fn_aplicar_compra', {
        p_compra_id: compra.id,
      });

      if (aplicarError) throw aplicarError;

      return compra;
    } catch (error) {
      console.error('Erro ao criar compra:', error);
      throw error;
    }
  }

  async listarCompras(filtros: FiltrosCompras = {}): Promise<Compra[]> {
    try {
      let query = supabase.from('compras').select(`
          *,
          itens:itens_compra(
            *,
            produto:produtos(nome)
          )
        `);

      if (filtros.data_inicio) {
        query = query.gte('data_compra', filtros.data_inicio.toISOString());
      }

      if (filtros.data_fim) {
        query = query.lte('data_compra', filtros.data_fim.toISOString());
      }

      if (filtros.fornecedor_nome) {
        query = query.ilike('fornecedor_nome', `%${filtros.fornecedor_nome}%`);
      }

      if (filtros.status) {
        query = query.eq('status', filtros.status);
      }

      const orderBy = filtros.order_by || 'data_compra';
      const orderDirection = filtros.order_direction || 'desc';
      query = query.order(orderBy, { ascending: orderDirection === 'asc' });

      const { data, error } = await query;

      if (error) throw error;

      return data || [];
    } catch (error) {
      console.error('Erro ao listar compras:', error);
      throw error;
    }
  }

  async buscarCompraPorId(id: string): Promise<Compra | null> {
    try {
      const { data, error } = await supabase
        .from('compras')
        .select(`
          *,
          itens:itens_compra(
            *,
            produto:produtos(nome, codigo_barras)
          )
        `)
        .eq('id', id)
        .single();

      if (error) throw error;

      return data;
    } catch (error) {
      console.error('Erro ao buscar compra:', error);
      throw error;
    }
  }

  async cancelarCompra(id: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('compras')
        .update({ status: 'cancelada' })
        .eq('id', id);

      if (error) throw error;
    } catch (error) {
      console.error('Erro ao cancelar compra:', error);
      throw error;
    }
  }

  // ===== DESPESAS =====

  async criarDespesa(dados: DespesaForm): Promise<Despesa> {
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error('Usuário não autenticado');

      const { data: empresas } = await supabase
        .from('empresas')
        .select('id')
        .eq('user_id', user.id)
        .single();

      if (!empresas) throw new Error('Empresa não encontrada');

      const { data, error } = await supabase
        .from('despesas')
        .insert({
          empresa_id: empresas.id,
          user_id: user.id,
          descricao: dados.descricao,
          categoria: dados.categoria,
          valor: dados.valor,
          data_despesa: dados.data_despesa.toISOString().split('T')[0],
          data_vencimento: dados.data_vencimento
            ? dados.data_vencimento.toISOString().split('T')[0]
            : null,
          status: dados.status,
          forma_pagamento: dados.forma_pagamento,
          observacoes: dados.observacoes,
        })
        .select()
        .single();

      if (error) throw error;

      return data;
    } catch (error) {
      console.error('Erro ao criar despesa:', error);
      throw error;
    }
  }

  async listarDespesas(filtros: FiltrosDespesas = {}): Promise<Despesa[]> {
    try {
      let query = supabase.from('despesas').select('*');

      if (filtros.data_inicio) {
        query = query.gte(
          'data_despesa',
          filtros.data_inicio.toISOString().split('T')[0]
        );
      }

      if (filtros.data_fim) {
        query = query.lte(
          'data_despesa',
          filtros.data_fim.toISOString().split('T')[0]
        );
      }

      if (filtros.categoria) {
        query = query.eq('categoria', filtros.categoria);
      }

      if (filtros.status) {
        query = query.eq('status', filtros.status);
      }

      const orderBy = filtros.order_by || 'data_despesa';
      const orderDirection = filtros.order_direction || 'desc';
      query = query.order(orderBy, { ascending: orderDirection === 'asc' });

      const { data, error } = await query;

      if (error) throw error;

      return data || [];
    } catch (error) {
      console.error('Erro ao listar despesas:', error);
      throw error;
    }
  }

  async atualizarDespesa(id: string, dados: Partial<DespesaForm>): Promise<void> {
    try {
      const updates: any = { ...dados };

      if (dados.data_despesa) {
        updates.data_despesa = dados.data_despesa.toISOString().split('T')[0];
      }

      if (dados.data_vencimento) {
        updates.data_vencimento = dados.data_vencimento.toISOString().split('T')[0];
      }

      const { error } = await supabase
        .from('despesas')
        .update(updates)
        .eq('id', id);

      if (error) throw error;
    } catch (error) {
      console.error('Erro ao atualizar despesa:', error);
      throw error;
    }
  }

  async pagarDespesa(id: string, data_pagamento: Date): Promise<void> {
    try {
      const { error } = await supabase
        .from('despesas')
        .update({
          status: 'pago',
          data_pagamento: data_pagamento.toISOString().split('T')[0],
        })
        .eq('id', id);

      if (error) throw error;
    } catch (error) {
      console.error('Erro ao pagar despesa:', error);
      throw error;
    }
  }

  async excluirDespesa(id: string): Promise<void> {
    try {
      const { error } = await supabase.from('despesas').delete().eq('id', id);

      if (error) throw error;
    } catch (error) {
      console.error('Erro ao excluir despesa:', error);
      throw error;
    }
  }

  // ===== OUTRAS MOVIMENTAÇÕES FINANCEIRAS =====

  async criarOutraMovimentacao(
    dados: OutraMovimentacaoForm
  ): Promise<OutraMovimentacaoFinanceira> {
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error('Usuário não autenticado');

      const { data: empresas } = await supabase
        .from('empresas')
        .select('id')
        .eq('user_id', user.id)
        .single();

      if (!empresas) throw new Error('Empresa não encontrada');

      const { data, error } = await supabase
        .from('outras_movimentacoes_financeiras')
        .insert({
          empresa_id: empresas.id,
          user_id: user.id,
          tipo: dados.tipo,
          descricao: dados.descricao,
          categoria: dados.categoria,
          valor: dados.valor,
          data_movimentacao: dados.data_movimentacao
            .toISOString()
            .split('T')[0],
          observacoes: dados.observacoes,
        })
        .select()
        .single();

      if (error) throw error;

      return data;
    } catch (error) {
      console.error('Erro ao criar outra movimentação:', error);
      throw error;
    }
  }

  async listarOutrasMovimentacoes(
    data_inicio: Date,
    data_fim: Date
  ): Promise<OutraMovimentacaoFinanceira[]> {
    try {
      const { data, error } = await supabase
        .from('outras_movimentacoes_financeiras')
        .select('*')
        .gte('data_movimentacao', data_inicio.toISOString().split('T')[0])
        .lte('data_movimentacao', data_fim.toISOString().split('T')[0])
        .order('data_movimentacao', { ascending: false });

      if (error) throw error;

      return data || [];
    } catch (error) {
      console.error('Erro ao listar outras movimentações:', error);
      throw error;
    }
  }

  // ===== MOVIMENTAÇÕES DE ESTOQUE =====

  async listarMovimentacoesEstoque(
    filtros: FiltrosMovimentacoes = {}
  ): Promise<MovimentacaoEstoque[]> {
    try {
      let query = supabase.from('movimentacoes_estoque').select(`
          *,
          produto:produtos(nome, codigo_barras)
        `);

      if (filtros.data_inicio) {
        query = query.gte(
          'data_movimentacao',
          filtros.data_inicio.toISOString()
        );
      }

      if (filtros.data_fim) {
        query = query.lte('data_movimentacao', filtros.data_fim.toISOString());
      }

      if (filtros.produto_id) {
        query = query.eq('produto_id', filtros.produto_id);
      }

      if (filtros.tipo_movimentacao) {
        query = query.eq('tipo_movimentacao', filtros.tipo_movimentacao);
      }

      const orderBy = filtros.order_by || 'data_movimentacao';
      const orderDirection = filtros.order_direction || 'desc';
      query = query.order(orderBy, { ascending: orderDirection === 'asc' });

      const { data, error } = await query;

      if (error) throw error;

      return data || [];
    } catch (error) {
      console.error('Erro ao listar movimentações de estoque:', error);
      throw error;
    }
  }

  // ===== DRE (DEMONSTRAÇÃO DO RESULTADO DO EXERCÍCIO) =====

  async calcularDRE(filtros: FiltrosDRE): Promise<{ dre: DRE; kpis: KPIsDRE }> {
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error('Usuário não autenticado');

      const { data: empresas } = await supabase
        .from('empresas')
        .select('id')
        .eq('user_id', user.id)
        .single();

      if (!empresas) throw new Error('Empresa não encontrada');

      const empresa_id = filtros.empresa_id || empresas.id;

      // Chamar função RPC do banco
      console.log('🔍 [DRE Service] Parâmetros da chamada RPC:', {
        p_data_inicio: filtros.data_inicio.toISOString(),
        p_data_fim: filtros.data_fim.toISOString(),
        p_user_id: empresa_id,
      });
      
      const { data, error } = await supabase.rpc('fn_calcular_dre', {
        p_data_inicio: filtros.data_inicio.toISOString(),
        p_data_fim: filtros.data_fim.toISOString(),
        p_user_id: empresa_id,
      });

      if (error) throw error;

      console.log('🔍 [DRE] Dados retornados:', data);
      console.log('🔍 [DRE] Receita bruta:', data?.receita_bruta);
      console.log('🔍 [DRE] Receita líquida:', data?.receita_liquida);

      // A função SQL retorna JSONB direto, não array
      const dre: DRE = data as DRE;

      // Calcular KPIs
      const kpis = this.calcularKPIs(dre);

      return { dre, kpis };
    } catch (error) {
      console.error('Erro ao calcular DRE:', error);
      throw error;
    }
  }

  private calcularKPIs(dre: DRE): KPIsDRE {
    const margem_bruta_percentual =
      dre.receita_liquida > 0
        ? (dre.lucro_bruto / dre.receita_liquida) * 100
        : 0;

    const margem_operacional_percentual =
      dre.receita_liquida > 0
        ? (dre.resultado_operacional / dre.receita_liquida) * 100
        : 0;

    const margem_liquida_percentual =
      dre.receita_liquida > 0
        ? (dre.resultado_liquido / dre.receita_liquida) * 100
        : 0;

    const markup_medio = dre.cmv > 0 ? dre.receita_bruta / dre.cmv - 1 : 0;

    return {
      margem_bruta_percentual,
      margem_operacional_percentual,
      margem_liquida_percentual,
      markup_medio,
      ticket_medio: 0, // Será calculado separadamente
      total_vendas: 0, // Será calculado separadamente
    };
  }

  async calcularDREComparativo(
    periodo_atual_inicio: Date,
    periodo_atual_fim: Date,
    periodo_anterior_inicio: Date,
    periodo_anterior_fim: Date
  ): Promise<DREComparativo> {
    try {
      const { dre: periodo_atual } = await this.calcularDRE({
        data_inicio: periodo_atual_inicio,
        data_fim: periodo_atual_fim,
      });

      const { dre: periodo_anterior } = await this.calcularDRE({
        data_inicio: periodo_anterior_inicio,
        data_fim: periodo_anterior_fim,
      });

      const variacao_percentual = {
        receita_bruta: this.calcularVariacao(
          periodo_anterior.receita_bruta,
          periodo_atual.receita_bruta
        ),
        receita_liquida: this.calcularVariacao(
          periodo_anterior.receita_liquida,
          periodo_atual.receita_liquida
        ),
        lucro_bruto: this.calcularVariacao(
          periodo_anterior.lucro_bruto,
          periodo_atual.lucro_bruto
        ),
        resultado_liquido: this.calcularVariacao(
          periodo_anterior.resultado_liquido,
          periodo_atual.resultado_liquido
        ),
      };

      return {
        periodo_atual,
        periodo_anterior,
        variacao_percentual,
      };
    } catch (error) {
      console.error('Erro ao calcular DRE comparativo:', error);
      throw error;
    }
  }

  private calcularVariacao(valorAnterior: number, valorAtual: number): number {
    if (valorAnterior === 0) return 0;
    return ((valorAtual - valorAnterior) / valorAnterior) * 100;
  }

  // ===== RELATÓRIOS =====

  async relatorioEstoque(): Promise<RelatorioEstoque[]> {
    try {
      const { data, error } = await supabase.from('produtos').select(`
          id,
          nome,
          quantidade_estoque,
          custo_medio
        `);

      if (error) throw error;

      return (data || []).map((produto) => ({
        produto_id: produto.id,
        produto_nome: produto.nome,
        quantidade_estoque: produto.quantidade_estoque || 0,
        custo_medio: produto.custo_medio || 0,
        valor_total_estoque:
          (produto.quantidade_estoque || 0) * (produto.custo_medio || 0),
      }));
    } catch (error) {
      console.error('Erro ao gerar relatório de estoque:', error);
      throw error;
    }
  }

  // ===== EXPORT CSV =====

  exportarDREParaCSV(dre: DRE, kpis: KPIsDRE): string {
    const linhas = [
      'DEMONSTRAÇÃO DO RESULTADO DO EXERCÍCIO (DRE)',
      '',
      `Receita Bruta,${dre.receita_bruta.toFixed(2)}`,
      `(-) Deduções,${dre.deducoes.toFixed(2)}`,
      `(=) Receita Líquida,${dre.receita_liquida.toFixed(2)}`,
      '',
      `(-) CMV - Custo da Mercadoria Vendida,${dre.cmv.toFixed(2)}`,
      `(=) Lucro Bruto,${dre.lucro_bruto.toFixed(2)}`,
      `Margem Bruta %,${kpis.margem_bruta_percentual.toFixed(2)}%`,
      '',
      `(-) Despesas Operacionais,${dre.despesas_operacionais.toFixed(2)}`,
      `(=) Resultado Operacional,${dre.resultado_operacional.toFixed(2)}`,
      `Margem Operacional %,${kpis.margem_operacional_percentual.toFixed(2)}%`,
      '',
      `(+) Outras Receitas,${dre.outras_receitas.toFixed(2)}`,
      `(-) Outras Despesas,${dre.outras_despesas.toFixed(2)}`,
      `(=) RESULTADO LÍQUIDO,${dre.resultado_liquido.toFixed(2)}`,
      `Margem Líquida %,${kpis.margem_liquida_percentual.toFixed(2)}%`,
    ];

    return linhas.join('\n');
  }
}

export const dreService = new DREService();
