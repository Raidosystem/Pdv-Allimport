import { useState, useEffect } from 'react';
import { reportsService } from '../services/reportsService';
import type { 
  SalesMovementReport, 
  ClientReport, 
  CashMovementReport, 
  ServiceOrderReport 
} from '../services/reportsService';

// ✅ HOOK PERSONALIZADO PARA RELATÓRIOS EM TEMPO REAL

export function useReports(autoRefresh = true, intervalMs = 30000) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastUpdate, setLastUpdate] = useState<Date>(new Date());

  // Estados para dados dos relatórios
  const [financialReport, setFinancialReport] = useState<SalesMovementReport | null>(null);
  const [clientReport, setClientReport] = useState<ClientReport | null>(null);
  const [cashReport, setCashReport] = useState<CashMovementReport | null>(null);
  const [serviceOrderReport, setServiceOrderReport] = useState<ServiceOrderReport | null>(null);

  // Função para carregar todos os relatórios
  const loadReports = async () => {
    setLoading(true);
    setError(null);
    
    try {
      console.log('📊 Carregando relatórios...');
      
      const [financial, clients, cash, serviceOrders] = await Promise.all([
        reportsService.getFinancialMovementReport('hoje'),
        reportsService.getClientReport(),
        reportsService.getCashMovementReport(),
        reportsService.getServiceOrderReport()
      ]);

      setFinancialReport(financial);
      setClientReport(clients);
      setCashReport(cash);
      setServiceOrderReport(serviceOrders);
      setLastUpdate(new Date());
      
      console.log('✅ Relatórios carregados com sucesso');
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro desconhecido';
      console.error('❌ Erro ao carregar relatórios:', err);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  // Carregamento inicial
  useEffect(() => {
    loadReports();
  }, []);

  // Auto-refresh dos dados
  useEffect(() => {
    if (!autoRefresh) return;

    const interval = setInterval(() => {
      console.log('🔄 Auto-refresh dos relatórios...');
      loadReports();
    }, intervalMs);

    return () => clearInterval(interval);
  }, [autoRefresh, intervalMs]);

  // Função para refresh manual
  const refresh = () => {
    loadReports();
  };

  return {
    // Estados
    loading,
    error,
    lastUpdate,
    
    // Dados
    financialReport,
    clientReport,
    cashReport,
    serviceOrderReport,
    
    // Ações
    refresh,
    
    // Dados agregados úteis
    summary: {
      totalVendasHoje: financialReport?.valor_hoje || 0,
      vendasCount: financialReport?.vendas_hoje || 0,
      ticketMedio: financialReport?.ticket_medio || 0,
      saldoCaixa: cashReport?.saldo_atual || 0,
      totalClientes: clientReport?.total_cadastrados || 0,
      totalOS: serviceOrderReport?.total_os || 0
    }
  };
}