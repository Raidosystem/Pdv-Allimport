import { formatCurrency } from '../utils/format';
import { realReportsService } from './simpleReportsService';

// Tipos para os relatórios
export interface ExportOptions {
  format: 'pdf' | 'csv';
  period: 'week' | 'month' | 'quarter';
  filters?: any;
}

class SimpleExportService {
  
  // Exportar relatório de vendas como CSV
  async exportSalesReport(options: ExportOptions) {
    try {
      console.log('📤 [EXPORT] Exportando relatório de vendas...', options);
      
      const salesReport = await realReportsService.getSalesReport(options.period);
      
      if (options.format === 'csv') {
        return this.generateSalesCSV(salesReport, options);
      } else {
        // Para PDF, vamos usar uma versão simplificada
        return this.generateSimplePDF('Relatório de Vendas', salesReport, options);
      }
      
    } catch (error) {
      console.error('❌ [EXPORT] Erro ao exportar vendas:', error);
      throw error;
    }
  }

  // Exportar relatório de clientes
  async exportClientsReport(options: ExportOptions) {
    try {
      console.log('📤 [EXPORT] Exportando relatório de clientes...', options);
      
      const clientsReport = await realReportsService.getClientsReport(options.period);
      
      if (options.format === 'csv') {
        return this.generateClientsCSV(clientsReport, options);
      } else {
        return this.generateSimplePDF('Relatório de Clientes', clientsReport, options);
      }
      
    } catch (error) {
      console.error('❌ [EXPORT] Erro ao exportar clientes:', error);
      throw error;
    }
  }

  // Exportar relatório de ordens de serviço
  async exportServiceOrdersReport(options: ExportOptions) {
    try {
      console.log('📤 [EXPORT] Exportando relatório de ordens de serviço...', options);
      
      const serviceReport = await realReportsService.getServiceOrdersReport(options.period);
      
      if (options.format === 'csv') {
        return this.generateServiceOrdersCSV(serviceReport, options);
      } else {
        return this.generateSimplePDF('Relatório de Ordens de Serviço', serviceReport, options);
      }
      
    } catch (error) {
      console.error('❌ [EXPORT] Erro ao exportar ordens de serviço:', error);
      throw error;
    }
  }

  // Exportar rankings
  async exportRankings(type: 'products' | 'categories' | 'clients', options: ExportOptions) {
    try {
      console.log('📤 [EXPORT] Exportando ranking...', { type, options });
      
      let data: any[];
      
      switch (type) {
        case 'products':
          data = await realReportsService.getProductRanking(options.period);
          break;
        case 'categories':
          data = await realReportsService.getCategoryRanking(options.period);
          break;
        case 'clients':
          data = await realReportsService.getClientSpendingRanking(options.period);
          break;
        default:
          throw new Error('Tipo de ranking inválido');
      }
      
      if (options.format === 'csv') {
        return this.generateRankingCSV(data, type, options);
      } else {
        return this.generateSimplePDF(`Ranking - ${this.getRankingTitle(type)}`, { rankingData: data }, options);
      }
      
    } catch (error) {
      console.error('❌ [EXPORT] Erro ao exportar ranking:', error);
      throw error;
    }
  }

  // Gerar CSV de vendas
  private generateSalesCSV(salesReport: any, options: ExportOptions) {
    const csvContent = [
      // Cabeçalho
      ['Relatório de Vendas'],
      [`Período: ${this.getPeriodText(options.period)}`],
      [`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`],
      [''],
      
      // Resumo
      ['RESUMO GERAL'],
      ['Total de Vendas', salesReport.totalSales.toString()],
      ['Faturamento Total', formatCurrency(salesReport.totalAmount)],
      [''],
      
      // Métodos de pagamento
      ['MÉTODOS DE PAGAMENTO'],
      ['Método', 'Quantidade', 'Valor'],
      ...salesReport.paymentMethods.map((method: any) => [
        method.method,
        method.count.toString(),
        formatCurrency(method.amount)
      ]),
      [''],
      
      // Produtos mais vendidos
      ['PRODUTOS MAIS VENDIDOS'],
      ['Produto', 'Quantidade', 'Receita'],
      ...salesReport.topProducts.map((product: any) => [
        product.productName,
        product.quantity.toString(),
        formatCurrency(product.revenue)
      ]),
      [''],
      
      // Vendas diárias
      ['VENDAS DIÁRIAS'],
      ['Data', 'Quantidade', 'Valor'],
      ...salesReport.dailySales.map((sale: any) => [
        sale.date,
        sale.count.toString(),
        formatCurrency(sale.amount)
      ])
    ];
    
    const csvString = csvContent.map((row: any[]) => 
      row.map((cell: any) => `"${cell}"`).join(',')
    ).join('\n');
    
    const filename = `relatorio-vendas-${options.period}-${new Date().toISOString().split('T')[0]}.csv`;
    this.downloadCSV(csvString, filename);
    
    console.log('✅ [EXPORT] CSV de vendas gerado:', filename);
    return filename;
  }

  // Gerar CSV de clientes
  private generateClientsCSV(clientsReport: any, options: ExportOptions) {
    const csvContent = [
      ['Relatório de Clientes'],
      [`Período: ${this.getPeriodText(options.period)}`],
      [`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`],
      [''],
      ['RESUMO GERAL'],
      ['Total de Clientes', clientsReport.totalClients.toString()],
      ['Novos Clientes', clientsReport.newClients.toString()],
      ['Clientes com Compras', clientsReport.clientsWithPurchases.toString()],
      [''],
      ['TOP CLIENTES'],
      ['Cliente', 'Compras', 'Valor Total', 'Serviços'],
      ...clientsReport.topClients.map((client: any) => [
        client.clientName,
        client.totalPurchases.toString(),
        formatCurrency(client.totalAmount),
        client.serviceOrders.toString()
      ])
    ];
    
    const csvString = csvContent.map((row: any[]) => 
      row.map((cell: any) => `"${cell}"`).join(',')
    ).join('\n');
    
    const filename = `relatorio-clientes-${options.period}-${new Date().toISOString().split('T')[0]}.csv`;
    this.downloadCSV(csvString, filename);
    
    console.log('✅ [EXPORT] CSV de clientes gerado:', filename);
    return filename;
  }

  // Gerar CSV de ordens de serviço
  private generateServiceOrdersCSV(serviceReport: any, options: ExportOptions) {
    const csvContent = [
      ['Relatório de Ordens de Serviço'],
      [`Período: ${this.getPeriodText(options.period)}`],
      [`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`],
      [''],
      ['RESUMO GERAL'],
      ['Total de Ordens', serviceReport.totalOrders.toString()],
      ['Receita Total', formatCurrency(serviceReport.totalRevenue)],
      ['Novos Clientes', serviceReport.newClients.toString()],
      ['Clientes Recorrentes', serviceReport.repeatClients.toString()],
      [''],
      ['EQUIPAMENTOS'],
      ['Equipamento', 'Quantidade', 'Receita'],
      ...serviceReport.equipmentStats.map((equipment: any) => [
        equipment.equipment,
        equipment.count.toString(),
        formatCurrency(equipment.revenue)
      ])
    ];
    
    const csvString = csvContent.map((row: any[]) => 
      row.map((cell: any) => `"${cell}"`).join(',')
    ).join('\n');
    
    const filename = `relatorio-ordens-servico-${options.period}-${new Date().toISOString().split('T')[0]}.csv`;
    this.downloadCSV(csvString, filename);
    
    console.log('✅ [EXPORT] CSV de ordens de serviço gerado:', filename);
    return filename;
  }

  // Gerar CSV de ranking
  private generateRankingCSV(data: any[], type: string, options: ExportOptions) {
    const headers = this.getRankingHeaders(type);
    
    const csvContent = [
      [`Ranking - ${this.getRankingTitle(type)}`],
      [`Período: ${this.getPeriodText(options.period)}`],
      [`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`],
      [''],
      ['Posição', ...headers],
      ...data.map((item: any, index: number) => [
        (index + 1).toString(),
        ...this.getRankingRowData(item, type)
      ])
    ];
    
    const csvString = csvContent.map((row: any[]) => 
      row.map((cell: any) => `"${cell}"`).join(',')
    ).join('\n');
    
    const filename = `ranking-${type}-${options.period}-${new Date().toISOString().split('T')[0]}.csv`;
    this.downloadCSV(csvString, filename);
    
    console.log('✅ [EXPORT] CSV de ranking gerado:', filename);
    return filename;
  }

  // Gerar PDF simples (texto)
  private generateSimplePDF(title: string, data: any, options: ExportOptions) {
    const content = [
      title,
      `Período: ${this.getPeriodText(options.period)}`,
      `Gerado em: ${new Date().toLocaleDateString('pt-BR')}`,
      '',
      'DADOS DO RELATÓRIO:',
      JSON.stringify(data, null, 2)
    ].join('\n');
    
    // Criar um arquivo de texto simples
    const filename = `${title.toLowerCase().replace(/\s+/g, '-')}-${options.period}-${new Date().toISOString().split('T')[0]}.txt`;
    this.downloadText(content, filename);
    
    console.log('✅ [EXPORT] Arquivo de texto gerado:', filename);
    return filename;
  }

  // Funções auxiliares
  private getPeriodText(period: string): string {
    switch (period) {
      case 'week': return 'Última Semana';
      case 'month': return 'Último Mês';
      case 'quarter': return 'Últimos 3 Meses';
      default: return 'Período Personalizado';
    }
  }

  private getRankingTitle(type: string): string {
    switch (type) {
      case 'products': return 'Produtos';
      case 'categories': return 'Categorias';
      case 'clients': return 'Clientes';
      default: return 'Geral';
    }
  }

  private getRankingHeaders(type: string): string[] {
    switch (type) {
      case 'products':
        return ['Produto', 'Quantidade', 'Receita'];
      case 'categories':
        return ['Categoria', 'Quantidade', 'Receita'];
      case 'clients':
        return ['Cliente', 'Total Gasto', 'Compras'];
      default:
        return ['Item', 'Valor'];
    }
  }

  private getRankingRowData(item: any, type: string): string[] {
    switch (type) {
      case 'products':
        return [
          item.productName || 'N/A',
          item.totalQuantity?.toString() || '0',
          formatCurrency(item.totalRevenue || 0)
        ];
      case 'categories':
        return [
          item.categoryName || 'N/A',
          item.totalQuantity?.toString() || '0',
          formatCurrency(item.totalRevenue || 0)
        ];
      case 'clients':
        return [
          item.clientName || 'N/A',
          formatCurrency(item.totalSpending || 0),
          item.purchaseCount?.toString() || '0'
        ];
      default:
        return [item.name || 'N/A', item.value?.toString() || '0'];
    }
  }

  private downloadCSV(csvContent: string, filename: string) {
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    
    if (link.download !== undefined) {
      const url = URL.createObjectURL(blob);
      link.setAttribute('href', url);
      link.setAttribute('download', filename);
      link.style.visibility = 'hidden';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    }
  }

  private downloadText(content: string, filename: string) {
    const blob = new Blob([content], { type: 'text/plain;charset=utf-8;' });
    const link = document.createElement('a');
    
    if (link.download !== undefined) {
      const url = URL.createObjectURL(blob);
      link.setAttribute('href', url);
      link.setAttribute('download', filename);
      link.style.visibility = 'hidden';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    }
  }

  // Exportar gráficos (versão simplificada)
  async exportChart(chartName: string, chartData: any) {
    try {
      console.log('📊 [EXPORT] Exportando gráfico...', { chartName });
      
      const content = [
        `Gráfico: ${chartName}`,
        `Gerado em: ${new Date().toLocaleDateString('pt-BR')}`,
        '',
        'DADOS DO GRÁFICO:',
        JSON.stringify(chartData, null, 2)
      ].join('\n');
      
      const filename = `grafico-${chartName.toLowerCase().replace(/\s+/g, '-')}-${new Date().toISOString().split('T')[0]}.txt`;
      this.downloadText(content, filename);
      
      console.log('✅ [EXPORT] Gráfico exportado:', filename);
      return filename;
      
    } catch (error) {
      console.error('❌ [EXPORT] Erro ao exportar gráfico:', error);
      throw error;
    }
  }

  // Exportar todas as páginas de relatórios
  async exportAllReports(options: ExportOptions) {
    try {
      console.log('📤 [EXPORT] Exportando todos os relatórios...', options);
      
      // Buscar todos os dados
      const [salesReport, clientsReport, serviceReport] = await Promise.all([
        realReportsService.getSalesReport(options.period),
        realReportsService.getClientsReport(options.period),
        realReportsService.getServiceOrdersReport(options.period)
      ]);
      
      const allData = {
        vendas: salesReport,
        clientes: clientsReport,
        ordensServico: serviceReport,
        periodo: this.getPeriodText(options.period),
        geradoEm: new Date().toLocaleDateString('pt-BR')
      };
      
      if (options.format === 'csv') {
        const csvContent = [
          ['RELATÓRIO COMPLETO PDV'],
          [`Período: ${this.getPeriodText(options.period)}`],
          [`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`],
          [''],
          ['RESUMO GERAL'],
          ['Total de Vendas', salesReport.totalSales.toString()],
          ['Faturamento', formatCurrency(salesReport.totalAmount)],
          ['Total de Clientes', clientsReport.totalClients.toString()],
          ['Ordens de Serviço', serviceReport.totalOrders.toString()],
          [''],
          ['Para dados detalhados, exporte cada relatório individual']
        ];
        
        const csvString = csvContent.map((row: any[]) => 
          row.map((cell: any) => `"${cell}"`).join(',')
        ).join('\n');
        
        const filename = `relatorio-completo-${options.period}-${new Date().toISOString().split('T')[0]}.csv`;
        this.downloadCSV(csvString, filename);
        
        console.log('✅ [EXPORT] Relatório completo exportado:', filename);
        return filename;
      } else {
        const content = [
          'RELATÓRIO COMPLETO PDV',
          `Período: ${this.getPeriodText(options.period)}`,
          `Gerado em: ${new Date().toLocaleDateString('pt-BR')}`,
          '',
          'DADOS COMPLETOS:',
          JSON.stringify(allData, null, 2)
        ].join('\n');
        
        const filename = `relatorio-completo-${options.period}-${new Date().toISOString().split('T')[0]}.txt`;
        this.downloadText(content, filename);
        
        console.log('✅ [EXPORT] Relatório completo exportado:', filename);
        return filename;
      }
      
    } catch (error) {
      console.error('❌ [EXPORT] Erro ao exportar relatório completo:', error);
      throw error;
    }
  }
}

// Instância exportada
export const exportService = new SimpleExportService();