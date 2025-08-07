import { useState, useEffect, useCallback } from 'react';
import { caixaService } from '../services/caixaService';
import type { 
  CaixaCompleto, 
  AberturaCaixaForm,
  FechamentoCaixaForm,
  MovimentacaoForm,
  CaixaFiltros 
} from '../types/caixa';
import toast from 'react-hot-toast';

export function useCaixa() {
  const [caixaAtual, setCaixaAtual] = useState<CaixaCompleto | null>(null);
  const [loading, setLoading] = useState(true); // Iniciar como true
  const [error, setError] = useState<string | null>(null);

  // ===== CARREGAR CAIXA ATUAL =====
  const carregarCaixaAtual = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const caixa = await caixaService.buscarCaixaAtual();
      setCaixaAtual(caixa);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao carregar caixa';
      setError(errorMessage);
      console.error('Erro ao carregar caixa atual:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  // ===== ABRIR CAIXA =====
  const abrirCaixa = async (dados: AberturaCaixaForm): Promise<boolean> => {
    try {
      setLoading(true);
      setError(null);
      
      await caixaService.abrirCaixa(dados);
      
      // Recarregar caixa atual
      await carregarCaixaAtual();
      
      toast.success('Caixa aberto com sucesso!');
      return true;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao abrir caixa';
      setError(errorMessage);
      toast.error(errorMessage);
      return false;
    } finally {
      setLoading(false);
    }
  };

  // ===== FECHAR CAIXA =====
  const fecharCaixa = async (
    caixaId: string, 
    dados: FechamentoCaixaForm
  ): Promise<boolean> => {
    try {
      setLoading(true);
      setError(null);
      
      await caixaService.fecharCaixa(caixaId, dados);
      
      // Recarregar caixa atual (será null após fechamento)
      await carregarCaixaAtual();
      
      toast.success('Caixa fechado com sucesso!');
      return true;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao fechar caixa';
      setError(errorMessage);
      toast.error(errorMessage);
      return false;
    } finally {
      setLoading(false);
    }
  };

  // ===== ADICIONAR MOVIMENTAÇÃO =====
  const adicionarMovimentacao = async (
    caixaId: string,
    dados: MovimentacaoForm
  ): Promise<boolean> => {
    try {
      setLoading(true);
      setError(null);
      
      await caixaService.adicionarMovimentacao(caixaId, dados);
      
      // Recarregar caixa atual para atualizar saldo
      await carregarCaixaAtual();
      
      const tipoMsg = dados.tipo === 'entrada' ? 'Entrada' : 'Saída';
      toast.success(`${tipoMsg} registrada com sucesso!`);
      return true;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao registrar movimentação';
      setError(errorMessage);
      toast.error(errorMessage);
      return false;
    } finally {
      setLoading(false);
    }
  };

  // ===== VERIFICAR SE CAIXA ESTÁ ABERTO =====
  const verificarCaixaAberto = (): boolean => {
    return caixaAtual !== null && caixaAtual.status === 'aberto';
  };

  // ===== OBTER RESUMO DO CAIXA =====
  const obterResumo = () => {
    if (!caixaAtual) return null;
    
    return {
      valor_inicial: caixaAtual.valor_inicial,
      total_entradas: caixaAtual.total_entradas || 0,
      total_saidas: caixaAtual.total_saidas || 0,
      saldo_atual: caixaAtual.saldo_atual || 0,
      total_movimentacoes: caixaAtual.movimentacoes_caixa?.length || 0
    };
  };

  // ===== CARREGAR CAIXA AO MONTAR COMPONENTE =====
  useEffect(() => {
    carregarCaixaAtual();
  }, [carregarCaixaAtual]);

  return {
    // Estados
    caixaAtual,
    loading,
    error,
    
    // Funções
    abrirCaixa,
    fecharCaixa,
    adicionarMovimentacao,
    carregarCaixaAtual,
    verificarCaixaAberto,
    obterResumo
  };
}

// ===== HOOK PARA HISTÓRICO DE CAIXAS =====
export function useCaixaHistorico() {
  const [caixas, setCaixas] = useState<CaixaCompleto[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const carregarHistorico = async (filtros: CaixaFiltros = {}) => {
    try {
      setLoading(true);
      setError(null);
      const dados = await caixaService.listarCaixas(filtros);
      setCaixas(dados);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao carregar histórico';
      setError(errorMessage);
      console.error('Erro ao carregar histórico:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    carregarHistorico();
  }, [carregarHistorico]);

  return {
    caixas,
    loading,
    error,
    carregarHistorico
  };
}

// ===== HOOK PARA DETALHES DE UM CAIXA =====
export function useCaixaDetalhes(caixaId: string | null) {
  const [caixa, setCaixa] = useState<CaixaCompleto | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const carregarDetalhes = async () => {
    if (!caixaId) return;
    
    try {
      setLoading(true);
      setError(null);
      const dados = await caixaService.buscarCaixaPorId(caixaId);
      setCaixa(dados);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao carregar detalhes';
      setError(errorMessage);
      console.error('Erro ao carregar detalhes:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (caixaId) {
      carregarDetalhes();
    } else {
      setCaixa(null);
    }
  }, [caixaId, carregarDetalhes]);

  return {
    caixa,
    loading,
    error,
    carregarDetalhes
  };
}
