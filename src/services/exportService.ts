import jsPDF from 'jspdf';
import 'jspdf-autotable';
import { formatCurrency } from '../utils/format';
import { realReportsService } from './simpleReportsService';

// Tipos para os relatórios
export interface ExportOptions {
  format: 'pdf' | 'csv' | 'excel';
  period: 'week' | 'month' | 'quarter';
  filters?: any;
}

class ExportService {
  
  // Exportar relatório de vendas
  async exportSalesReport(options: ExportOptions) {
    try {
      console.log('📤 [EXPORT] Exportando relatório de vendas...', options);
      
      const salesReport = await realReportsService.getSalesReport(options.period);
      
      if (options.format === 'pdf') {
        return this.generateSalesPDF(salesReport, options);
      } else if (options.format === 'csv') {
        return this.generateSalesCSV(salesReport, options);
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
      
      if (options.format === 'pdf') {
        return this.generateClientsPDF(clientsReport, options);
      } else if (options.format === 'csv') {
        return this.generateClientsCSV(clientsReport, options);
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
      
      if (options.format === 'pdf') {
        return this.generateServiceOrdersPDF(serviceReport, options);
      } else if (options.format === 'csv') {
        return this.generateServiceOrdersCSV(serviceReport, options);
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
      
      if (options.format === 'pdf') {
        return this.generateRankingPDF(data, type, options);
      } else if (options.format === 'csv') {
        return this.generateRankingCSV(data, type, options);
      }
      
    } catch (error) {
      console.error('❌ [EXPORT] Erro ao exportar ranking:', error);
      throw error;
    }
  }

  // Gerar PDF de vendas
  private generateSalesPDF(salesReport: any, options: ExportOptions) {
    const doc = new jsPDF();
    
    // Cabeçalho
    doc.setFontSize(20);
    doc.text('Relatório de Vendas', 20, 20);
    
    doc.setFontSize(12);
    doc.text(`Período: ${this.getPeriodText(options.period)}`, 20, 35);
    doc.text(`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`, 20, 45);
    
    // Resumo
    doc.setFontSize(14);
    doc.text('Resumo Geral', 20, 65);
    
    doc.setFontSize(11);
    doc.text(`Total de Vendas: ${salesReport.totalSales}`, 20, 80);
    doc.text(`Faturamento Total: ${formatCurrency(salesReport.totalAmount)}`, 20, 90);
    
    // Métodos de pagamento
    if (salesReport.paymentMethods?.length > 0) {
      doc.text('Métodos de Pagamento:', 20, 110);
      
      const paymentData = salesReport.paymentMethods.map((method: any) => [
        method.method,
        method.count.toString(),
        formatCurrency(method.amount)
      ]);
      
      doc.autoTable({
        startY: 120,
        head: [['Método', 'Quantidade', 'Valor']],
        body: paymentData,
        margin: { left: 20 }
      });
    }
    
    // Produtos mais vendidos
    if (salesReport.topProducts?.length > 0) {
      const finalY = (doc as any).lastAutoTable?.finalY || 160;
      
      doc.text('Produtos Mais Vendidos:', 20, finalY + 20);
      
      const productsData = salesReport.topProducts.map((product: any) => [
        product.productName,
        product.quantity.toString(),
        formatCurrency(product.revenue)
      ]);
      
      doc.autoTable({
        startY: finalY + 30,
        head: [['Produto', 'Quantidade', 'Receita']],
        body: productsData,
        margin: { left: 20 }
      });
    }
    
    // Download
    const filename = `relatorio-vendas-${options.period}-${new Date().toISOString().split('T')[0]}.pdf`;
    doc.save(filename);
    
    console.log('✅ [EXPORT] PDF de vendas gerado:', filename);
    return filename;
  }

  // Gerar CSV de vendas
  private generateSalesCSV(salesReport: any, options: ExportOptions) {
    const csvContent = [
      // Cabeçalho
      ['Relatório de Vendas'],
      [`Período: ${this.getPeriodText(options.period)}`],
      [`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`],
      [],
      
      // Resumo
      ['RESUMO GERAL'],
      ['Total de Vendas', salesReport.totalSales],
      ['Faturamento Total', formatCurrency(salesReport.totalAmount)],
      [],
      
      // Métodos de pagamento
      ['MÉTODOS DE PAGAMENTO'],
      ['Método', 'Quantidade', 'Valor'],
      ...salesReport.paymentMethods.map((method: any) => [
        method.method,
        method.count,
        formatCurrency(method.amount)
      ]),
      [],
      
      // Produtos mais vendidos
      ['PRODUTOS MAIS VENDIDOS'],
      ['Produto', 'Quantidade', 'Receita'],
      ...salesReport.topProducts.map((product: any) => [
        product.productName,
        product.quantity,
        formatCurrency(product.revenue)
      ]),
      [],
      
      // Vendas diárias
      ['VENDAS DIÁRIAS'],
      ['Data', 'Quantidade', 'Valor'],
      ...salesReport.dailySales.map((sale: any) => [
        sale.date,
        sale.count,
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

  // Gerar PDF de clientes
  private generateClientsPDF(clientsReport: any, options: ExportOptions) {
    const doc = new jsPDF();
    
    // Cabeçalho
    doc.setFontSize(20);
    doc.text('Relatório de Clientes', 20, 20);
    
    doc.setFontSize(12);
    doc.text(`Período: ${this.getPeriodText(options.period)}`, 20, 35);
    doc.text(`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`, 20, 45);
    
    // Resumo
    doc.setFontSize(14);
    doc.text('Resumo Geral', 20, 65);
    
    doc.setFontSize(11);
    doc.text(`Total de Clientes: ${clientsReport.totalClients}`, 20, 80);
    doc.text(`Novos Clientes: ${clientsReport.newClients}`, 20, 90);
    doc.text(`Clientes com Compras: ${clientsReport.clientsWithPurchases}`, 20, 100);
    
    // Top clientes
    if (clientsReport.topClients?.length > 0) {
      doc.text('Top Clientes:', 20, 120);
      
      const clientsData = clientsReport.topClients.map((client: any) => [
        client.clientName,
        client.totalPurchases.toString(),
        formatCurrency(client.totalAmount),
        client.serviceOrders.toString()
      ]);
      
      doc.autoTable({
        startY: 130,
        head: [['Cliente', 'Compras', 'Valor Total', 'Serviços']],
        body: clientsData,
        margin: { left: 20 }
      });
    }
    
    const filename = `relatorio-clientes-${options.period}-${new Date().toISOString().split('T')[0]}.pdf`;
    doc.save(filename);
    
    console.log('✅ [EXPORT] PDF de clientes gerado:', filename);
    return filename;
  }

  // Gerar CSV de clientes
  private generateClientsCSV(clientsReport: any, options: ExportOptions) {
    const csvContent = [
      ['Relatório de Clientes'],
      [`Período: ${this.getPeriodText(options.period)}`],
      [`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`],
      [],
      ['RESUMO GERAL'],
      ['Total de Clientes', clientsReport.totalClients],
      ['Novos Clientes', clientsReport.newClients],
      ['Clientes com Compras', clientsReport.clientsWithPurchases],
      [],
      ['TOP CLIENTES'],
      ['Cliente', 'Compras', 'Valor Total', 'Serviços'],
      ...clientsReport.topClients.map((client: any) => [
        client.clientName,
        client.totalPurchases,
        formatCurrency(client.totalAmount),
        client.serviceOrders
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

  // Gerar PDF de ordens de serviço
  private generateServiceOrdersPDF(serviceReport: any, options: ExportOptions) {
    const doc = new jsPDF();
    
    // Cabeçalho
    doc.setFontSize(20);
    doc.text('Relatório de Ordens de Serviço', 20, 20);
    
    doc.setFontSize(12);
    doc.text(`Período: ${this.getPeriodText(options.period)}`, 20, 35);
    doc.text(`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`, 20, 45);
    
    // Resumo
    doc.setFontSize(14);
    doc.text('Resumo Geral', 20, 65);
    
    doc.setFontSize(11);
    doc.text(`Total de Ordens: ${serviceReport.totalOrders}`, 20, 80);
    doc.text(`Receita Total: ${formatCurrency(serviceReport.totalRevenue)}`, 20, 90);
    doc.text(`Novos Clientes: ${serviceReport.newClients}`, 20, 100);
    doc.text(`Clientes Recorrentes: ${serviceReport.repeatClients}`, 20, 110);
    
    // Equipamentos
    if (serviceReport.equipmentStats?.length > 0) {
      doc.text('Estatísticas por Equipamento:', 20, 130);
      
      const equipmentData = serviceReport.equipmentStats.map((equipment: any) => [
        equipment.equipment,
        equipment.count.toString(),
        formatCurrency(equipment.revenue)
      ]);
      
      doc.autoTable({
        startY: 140,
        head: [['Equipamento', 'Quantidade', 'Receita']],
        body: equipmentData,
        margin: { left: 20 }
      });
    }
    
    const filename = `relatorio-ordens-servico-${options.period}-${new Date().toISOString().split('T')[0]}.pdf`;
    doc.save(filename);
    
    console.log('✅ [EXPORT] PDF de ordens de serviço gerado:', filename);
    return filename;
  }

  // Gerar CSV de ordens de serviço
  private generateServiceOrdersCSV(serviceReport: any, options: ExportOptions) {
    const csvContent = [
      ['Relatório de Ordens de Serviço'],
      [`Período: ${this.getPeriodText(options.period)}`],
      [`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`],
      [],
      ['RESUMO GERAL'],
      ['Total de Ordens', serviceReport.totalOrders],
      ['Receita Total', formatCurrency(serviceReport.totalRevenue)],
      ['Novos Clientes', serviceReport.newClients],
      ['Clientes Recorrentes', serviceReport.repeatClients],
      [],
      ['EQUIPAMENTOS'],
      ['Equipamento', 'Quantidade', 'Receita'],
      ...serviceReport.equipmentStats.map((equipment: any) => [
        equipment.equipment,
        equipment.count,
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

  // Gerar PDF de ranking
  private generateRankingPDF(data: any[], type: string, options: ExportOptions) {
    const doc = new jsPDF();
    
    // Cabeçalho
    doc.setFontSize(20);
    doc.text(`Ranking - ${this.getRankingTitle(type)}`, 20, 20);
    
    doc.setFontSize(12);
    doc.text(`Período: ${this.getPeriodText(options.period)}`, 20, 35);
    doc.text(`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`, 20, 45);
    
    // Dados do ranking
    if (data.length > 0) {
      const headers = this.getRankingHeaders(type);
      const tableData = data.map((item: any, index: number) => [
        (index + 1).toString(),
        ...this.getRankingRowData(item, type)
      ]);
      
      doc.autoTable({
        startY: 60,
        head: [['#', ...headers]],
        body: tableData,
        margin: { left: 20 }
      });
    }
    
    const filename = `ranking-${type}-${options.period}-${new Date().toISOString().split('T')[0]}.pdf`;
    doc.save(filename);
    
    console.log('✅ [EXPORT] PDF de ranking gerado:', filename);
    return filename;
  }

  // Gerar CSV de ranking
  private generateRankingCSV(data: any[], type: string, options: ExportOptions) {
    const headers = this.getRankingHeaders(type);
    
    const csvContent = [
      [`Ranking - ${this.getRankingTitle(type)}`],
      [`Período: ${this.getPeriodText(options.period)}`],
      [`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`],
      [],
      ['Posição', ...headers],
      ...data.map((item: any, index: number) => [
        index + 1,
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
    }
  }

  // Exportar gráficos (versão simplificada)
  async exportChart(chartName: string, format: 'pdf' | 'png' = 'pdf') {
    try {
      console.log('📊 [EXPORT] Exportando gráfico...', { chartName, format });
      
      const doc = new jsPDF();
      
      // Cabeçalho
      doc.setFontSize(18);
      doc.text(`Gráfico: ${chartName}`, 20, 20);
      
      doc.setFontSize(12);
      doc.text(`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`, 20, 35);
      
      // Placeholder para gráfico (em uma implementação real, você capturaria o canvas do gráfico)
      doc.setFontSize(14);
      doc.text('Dados do Gráfico:', 20, 60);
      doc.text('(Visualização não disponível no PDF)', 20, 80);
      doc.text('Para visualizar os gráficos, acesse o sistema web.', 20, 100);
      
      const filename = `grafico-${chartName.toLowerCase().replace(/\s+/g, '-')}-${new Date().toISOString().split('T')[0]}.pdf`;
      doc.save(filename);
      
      console.log('✅ [EXPORT] Gráfico exportado:', filename);
      return filename;
      
    } catch (error) {
      console.error('❌ [EXPORT] Erro ao exportar gráfico:', error);
      throw error;
    }
  }
}

// Instância exportada
export const exportService = new ExportService();