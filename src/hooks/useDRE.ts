// ============================================
// HOOK: useDRE
// Hook personalizado para gerenciar DRE
// ============================================

import { useState, useEffect, useCallback } from 'react';
import { dreService } from '../services/dreService';
import type {
  DRE,
  KPIsDRE,
  FiltrosDRE,
  Compra,
  Despesa,
  OutraMovimentacaoFinanceira,
  CompraForm,
  DespesaForm,
  OutraMovimentacaoForm,
  FiltrosCompras,
  FiltrosDespesas,
} from '../types/dre';
import toast from 'react-hot-toast';

export function useDRE() {
  const [dre, setDRE] = useState<DRE | null>(null);
  const [kpis, setKPIs] = useState<KPIsDRE | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const calcularDRE = useCallback(async (filtros: FiltrosDRE) => {
    try {
      setLoading(true);
      setError(null);

      const resultado = await dreService.calcularDRE(filtros);
      setDRE(resultado.dre);
      setKPIs(resultado.kpis);
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : 'Erro ao calcular DRE';
      setError(errorMessage);
      toast.error(errorMessage);
      console.error('Erro ao calcular DRE:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  const exportarCSV = useCallback(() => {
    if (!dre || !kpis) {
      toast.error('Não há dados para exportar');
      return;
    }

    try {
      const csv = dreService.exportarDREParaCSV(dre, kpis);
      const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
      const link = document.createElement('a');
      const url = URL.createObjectURL(blob);

      link.setAttribute('href', url);
      link.setAttribute('download', `DRE_${new Date().toISOString()}.csv`);
      link.style.visibility = 'hidden';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      toast.success('DRE exportado com sucesso!');
    } catch (err) {
      toast.error('Erro ao exportar DRE');
      console.error('Erro ao exportar:', err);
    }
  }, [dre, kpis]);

  return {
    dre,
    kpis,
    loading,
    error,
    calcularDRE,
    exportarCSV,
  };
}

// ===== HOOK: useCompras =====

export function useCompras() {
  const [compras, setCompras] = useState<Compra[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const carregarCompras = useCallback(async (filtros: FiltrosCompras = {}) => {
    try {
      setLoading(true);
      setError(null);

      const data = await dreService.listarCompras(filtros);
      setCompras(data);
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : 'Erro ao carregar compras';
      setError(errorMessage);
      console.error('Erro ao carregar compras:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  const criarCompra = async (dados: CompraForm): Promise<boolean> => {
    try {
      setLoading(true);
      setError(null);

      await dreService.criarCompra(dados);
      toast.success('Compra registrada com sucesso!');
      
      // Recarregar lista
      await carregarCompras();
      
      return true;
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : 'Erro ao criar compra';
      setError(errorMessage);
      toast.error(errorMessage);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const cancelarCompra = async (id: string): Promise<boolean> => {
    try {
      setLoading(true);
      await dreService.cancelarCompra(id);
      toast.success('Compra cancelada');
      await carregarCompras();
      return true;
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : 'Erro ao cancelar compra';
      toast.error(errorMessage);
      return false;
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    carregarCompras();
  }, [carregarCompras]);

  return {
    compras,
    loading,
    error,
    carregarCompras,
    criarCompra,
    cancelarCompra,
  };
}

// ===== HOOK: useDespesas =====

export function useDespesas() {
  const [despesas, setDespesas] = useState<Despesa[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const carregarDespesas = useCallback(async (filtros: FiltrosDespesas = {}) => {
    try {
      setLoading(true);
      setError(null);

      const data = await dreService.listarDespesas(filtros);
      setDespesas(data);
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : 'Erro ao carregar despesas';
      setError(errorMessage);
      console.error('Erro ao carregar despesas:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  const criarDespesa = async (dados: DespesaForm): Promise<boolean> => {
    try {
      setLoading(true);
      setError(null);

      await dreService.criarDespesa(dados);
      toast.success('Despesa registrada com sucesso!');
      
      await carregarDespesas();
      
      return true;
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : 'Erro ao criar despesa';
      setError(errorMessage);
      toast.error(errorMessage);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const pagarDespesa = async (id: string, dataPagamento: Date): Promise<boolean> => {
    try {
      await dreService.pagarDespesa(id, dataPagamento);
      toast.success('Despesa paga');
      await carregarDespesas();
      return true;
    } catch (err) {
      toast.error('Erro ao pagar despesa');
      return false;
    }
  };

  const excluirDespesa = async (id: string): Promise<boolean> => {
    try {
      await dreService.excluirDespesa(id);
      toast.success('Despesa excluída');
      await carregarDespesas();
      return true;
    } catch (err) {
      toast.error('Erro ao excluir despesa');
      return false;
    }
  };

  useEffect(() => {
    carregarDespesas();
  }, [carregarDespesas]);

  return {
    despesas,
    loading,
    error,
    carregarDespesas,
    criarDespesa,
    pagarDespesa,
    excluirDespesa,
  };
}

// ===== HOOK: useOutrasMovimentacoes =====

export function useOutrasMovimentacoes() {
  const [movimentacoes, setMovimentacoes] = useState<OutraMovimentacaoFinanceira[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const carregarMovimentacoes = useCallback(
    async (dataInicio: Date, dataFim: Date) => {
      try {
        setLoading(true);
        setError(null);

        const data = await dreService.listarOutrasMovimentacoes(
          dataInicio,
          dataFim
        );
        setMovimentacoes(data);
      } catch (err) {
        const errorMessage =
          err instanceof Error ? err.message : 'Erro ao carregar movimentações';
        setError(errorMessage);
        console.error('Erro ao carregar movimentações:', err);
      } finally {
        setLoading(false);
      }
    },
    []
  );

  const criarMovimentacao = async (
    dados: OutraMovimentacaoForm
  ): Promise<boolean> => {
    try {
      setLoading(true);
      setError(null);

      await dreService.criarOutraMovimentacao(dados);
      toast.success('Movimentação registrada com sucesso!');
      
      return true;
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : 'Erro ao criar movimentação';
      setError(errorMessage);
      toast.error(errorMessage);
      return false;
    } finally {
      setLoading(false);
    }
  };

  return {
    movimentacoes,
    loading,
    error,
    carregarMovimentacoes,
    criarMovimentacao,
  };
}
