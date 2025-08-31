import jsPDF from 'jspdf'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'
import html2canvas from 'html2canvas'
import type { SalesReport, FinancialReport, StockReport, ClientsReport } from '../types/reports'

export class ExportService {
  
  // Exportar relatório de vendas para PDF
  static async exportSalesToPDF(data: SalesReport, filters: any) {
    const doc = new jsPDF()
    
    // Título
    doc.setFontSize(18)
    doc.text('Relatório de Vendas', 20, 20)
    
    // Período
    doc.setFontSize(12)
    doc.text(`Período: ${filters.data_inicio} a ${filters.data_fim}`, 20, 35)
    
    // Resumo
    doc.text('RESUMO:', 20, 50)
    doc.text(`Total de Vendas: ${data.resumo.total_vendas}`, 20, 60)
    doc.text(`Valor Total: R$ ${data.resumo.total_valor.toFixed(2)}`, 20, 70)
    doc.text(`Ticket Médio: R$ ${data.resumo.ticket_medio.toFixed(2)}`, 20, 80)
    doc.text(`Total Descontos: R$ ${data.resumo.total_desconto.toFixed(2)}`, 20, 90)
    
    // Lista de vendas (simplificada)
    let yPosition = 110
    doc.text('VENDAS:', 20, yPosition)
    yPosition += 10
    
    data.vendas.slice(0, 10).forEach((venda) => {
      if (yPosition > 270) {
        doc.addPage()
        yPosition = 20
      }
      
      const clienteNome = venda.cliente?.nome || 'Sem cliente'
      const texto = `#${venda.id} - ${clienteNome} - R$ ${venda.total.toFixed(2)}`
      doc.text(texto, 20, yPosition)
      yPosition += 8
    })
    
    if (data.vendas.length > 10) {
      doc.text(`... e mais ${data.vendas.length - 10} vendas`, 20, yPosition)
    }
    
    doc.save(`relatorio-vendas-${new Date().toISOString().split('T')[0]}.pdf`)
  }

  // Exportar relatório de vendas para Excel
  static async exportSalesToExcel(data: SalesReport, filters: any) {
    const workbook = XLSX.utils.book_new()
    
    // Aba Resumo
    const resumoData = [
      ['Relatório de Vendas'],
      [`Período: ${filters.data_inicio} a ${filters.data_fim}`],
      [],
      ['RESUMO'],
      ['Total de Vendas', data.resumo.total_vendas],
      ['Valor Total', data.resumo.total_valor],
      ['Ticket Médio', data.resumo.ticket_medio],
      ['Total Descontos', data.resumo.total_desconto],
      [],
      ['TOP PRODUTOS'],
      ['Produto', 'Quantidade', 'Valor'],
      ...data.resumo.top_produtos.map(p => [p.produto, p.quantidade, p.valor]),
      [],
      ['TOP CLIENTES'],
      ['Cliente', 'Quantidade', 'Valor'],
      ...data.resumo.top_clientes.map(c => [c.cliente, c.quantidade, c.valor])
    ]
    
    const resumoSheet = XLSX.utils.aoa_to_sheet(resumoData)
    XLSX.utils.book_append_sheet(workbook, resumoSheet, 'Resumo')
    
    // Aba Vendas Detalhadas
    const vendasData = [
      ['ID', 'Data', 'Cliente', 'Vendedor', 'Forma Pagamento', 'Subtotal', 'Desconto', 'Total'],
      ...data.vendas.map(v => [
        v.id,
        v.data_venda,
        v.cliente?.nome || 'Sem cliente',
        v.vendedor || '-',
        v.forma_pagamento,
        v.subtotal,
        v.desconto || 0,
        v.total
      ])
    ]
    
    const vendasSheet = XLSX.utils.aoa_to_sheet(vendasData)
    XLSX.utils.book_append_sheet(workbook, vendasSheet, 'Vendas')
    
    // Salvar arquivo
    const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' })
    const data_blob = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    saveAs(data_blob, `relatorio-vendas-${new Date().toISOString().split('T')[0]}.xlsx`)
  }

  // Exportar relatório financeiro para PDF
  static async exportFinancialToPDF(data: FinancialReport, filters: any) {
    const doc = new jsPDF()
    
    doc.setFontSize(18)
    doc.text('Relatório Financeiro', 20, 20)
    
    doc.setFontSize(12)
    doc.text(`Período: ${filters.data_inicio} a ${filters.data_fim}`, 20, 35)
    
    doc.text('RESUMO:', 20, 50)
    doc.text(`Total Entradas: R$ ${data.resumo.total_entradas.toFixed(2)}`, 20, 60)
    doc.text(`Total Saídas: R$ ${data.resumo.total_saidas.toFixed(2)}`, 20, 70)
    doc.text(`Saldo: R$ ${data.resumo.saldo.toFixed(2)}`, 20, 80)
    
    let yPosition = 100
    doc.text('MOVIMENTAÇÕES:', 20, yPosition)
    yPosition += 10
    
    data.movimentacoes.slice(0, 15).forEach((mov) => {
      if (yPosition > 270) {
        doc.addPage()
        yPosition = 20
      }
      
      const sinal = mov.tipo === 'entrada' ? '+' : '-'
      const texto = `${mov.data_movimento} - ${mov.categoria} - ${sinal}R$ ${mov.valor.toFixed(2)}`
      doc.text(texto, 20, yPosition)
      yPosition += 8
    })
    
    doc.save(`relatorio-financeiro-${new Date().toISOString().split('T')[0]}.pdf`)
  }

  // Exportar relatório financeiro para Excel
  static async exportFinancialToExcel(data: FinancialReport, filters: any) {
    const workbook = XLSX.utils.book_new()
    
    const resumoData = [
      ['Relatório Financeiro'],
      [`Período: ${filters.data_inicio} a ${filters.data_fim}`],
      [],
      ['RESUMO'],
      ['Total Entradas', data.resumo.total_entradas],
      ['Total Saídas', data.resumo.total_saidas],
      ['Saldo', data.resumo.saldo],
      [],
      ['ENTRADAS POR CATEGORIA'],
      ['Categoria', 'Valor'],
      ...data.resumo.entradas_por_categoria.map(c => [c.categoria, c.valor]),
      [],
      ['SAÍDAS POR CATEGORIA'],
      ['Categoria', 'Valor'],
      ...data.resumo.saidas_por_categoria.map(c => [c.categoria, c.valor])
    ]
    
    const resumoSheet = XLSX.utils.aoa_to_sheet(resumoData)
    XLSX.utils.book_append_sheet(workbook, resumoSheet, 'Resumo')
    
    const movimentacoesData = [
      ['Data', 'Tipo', 'Categoria', 'Descrição', 'Valor'],
      ...data.movimentacoes.map(m => [
        m.data_movimento,
        m.tipo,
        m.categoria,
        m.descricao,
        m.valor
      ])
    ]
    
    const movSheet = XLSX.utils.aoa_to_sheet(movimentacoesData)
    XLSX.utils.book_append_sheet(workbook, movSheet, 'Movimentações')
    
    const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' })
    const data_blob = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    saveAs(data_blob, `relatorio-financeiro-${new Date().toISOString().split('T')[0]}.xlsx`)
  }

  // Exportar relatório de estoque para PDF
  static async exportStockToPDF(data: StockReport) {
    const doc = new jsPDF()
    
    doc.setFontSize(18)
    doc.text('Relatório de Estoque', 20, 20)
    
    doc.setFontSize(12)
    doc.text(`Valor Total do Estoque: R$ ${data.valor_total_estoque.toFixed(2)}`, 20, 35)
    doc.text(`Produtos com Estoque Baixo: ${data.produtos_estoque_baixo.length}`, 20, 45)
    
    let yPosition = 65
    doc.text('PRODUTOS COM ESTOQUE BAIXO:', 20, yPosition)
    yPosition += 10
    
    data.produtos_estoque_baixo.forEach((produto) => {
      if (yPosition > 270) {
        doc.addPage()
        yPosition = 20
      }
      
      const texto = `${produto.nome} - Atual: ${produto.estoque_atual} | Mínimo: ${produto.estoque_minimo}`
      doc.text(texto, 20, yPosition)
      yPosition += 8
    })
    
    doc.save(`relatorio-estoque-${new Date().toISOString().split('T')[0]}.pdf`)
  }

  // Exportar relatório de estoque para Excel
  static async exportStockToExcel(data: StockReport) {
    const workbook = XLSX.utils.book_new()
    
    const resumoData = [
      ['Relatório de Estoque'],
      [],
      ['RESUMO'],
      ['Valor Total do Estoque', data.valor_total_estoque],
      ['Produtos com Estoque Baixo', data.produtos_estoque_baixo.length],
      ['Produtos Mais Vendidos', data.produtos_mais_vendidos.length],
      [],
      ['PRODUTOS COM ESTOQUE BAIXO'],
      ['Produto', 'Estoque Atual', 'Estoque Mínimo', 'Valor Investido'],
      ...data.produtos_estoque_baixo.map(p => [p.nome, p.estoque_atual, p.estoque_minimo, p.valor_investido]),
      [],
      ['PRODUTOS MAIS VENDIDOS'],
      ['Produto', 'Quantidade Vendida', 'Valor Total'],
      ...data.produtos_mais_vendidos.map(p => [p.produto, p.quantidade_vendida, p.valor_total])
    ]
    
    const sheet = XLSX.utils.aoa_to_sheet(resumoData)
    XLSX.utils.book_append_sheet(workbook, sheet, 'Estoque')
    
    const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' })
    const data_blob = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    saveAs(data_blob, `relatorio-estoque-${new Date().toISOString().split('T')[0]}.xlsx`)
  }

  // Exportar relatório de clientes para PDF
  static async exportClientsToPDF(data: ClientsReport) {
    const doc = new jsPDF()
    
    doc.setFontSize(18)
    doc.text('Relatório de Clientes', 20, 20)
    
    doc.setFontSize(12)
    doc.text(`Total de Clientes: ${data.resumo.total_clientes}`, 20, 35)
    doc.text(`Clientes Ativos: ${data.resumo.clientes_ativos}`, 20, 45)
    doc.text(`Clientes Inativos: ${data.resumo.clientes_inativos}`, 20, 55)
    doc.text(`Ticket Médio Geral: R$ ${data.resumo.ticket_medio_geral.toFixed(2)}`, 20, 65)
    
    let yPosition = 85
    doc.text('TOP 10 CLIENTES:', 20, yPosition)
    yPosition += 10
    
    data.clientes
      .sort((a, b) => b.valor_total - a.valor_total)
      .slice(0, 10)
      .forEach((cliente) => {
        if (yPosition > 270) {
          doc.addPage()
          yPosition = 20
        }
        
        const texto = `${cliente.nome} - ${cliente.total_compras} compras - R$ ${cliente.valor_total.toFixed(2)}`
        doc.text(texto, 20, yPosition)
        yPosition += 8
      })
    
    doc.save(`relatorio-clientes-${new Date().toISOString().split('T')[0]}.pdf`)
  }

  // Exportar relatório de clientes para Excel
  static async exportClientsToExcel(data: ClientsReport) {
    const workbook = XLSX.utils.book_new()
    
    const resumoData = [
      ['Relatório de Clientes'],
      [],
      ['RESUMO'],
      ['Total de Clientes', data.resumo.total_clientes],
      ['Clientes Ativos', data.resumo.clientes_ativos],
      ['Clientes Inativos', data.resumo.clientes_inativos],
      ['Ticket Médio Geral', data.resumo.ticket_medio_geral],
    ]
    
    const resumoSheet = XLSX.utils.aoa_to_sheet(resumoData)
    XLSX.utils.book_append_sheet(workbook, resumoSheet, 'Resumo')
    
    const clientesData = [
      ['Nome', 'Email', 'Telefone', 'Total Compras', 'Valor Total', 'Ticket Médio', 'Última Compra'],
      ...data.clientes.map(c => [
        c.nome,
        c.email || '',
        c.telefone || '',
        c.total_compras,
        c.valor_total,
        c.ticket_medio,
        c.ultima_compra || ''
      ])
    ]
    
    const clientesSheet = XLSX.utils.aoa_to_sheet(clientesData)
    XLSX.utils.book_append_sheet(workbook, clientesSheet, 'Clientes')
    
    const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' })
    const data_blob = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    saveAs(data_blob, `relatorio-clientes-${new Date().toISOString().split('T')[0]}.xlsx`)
  }

  // Capturar elemento HTML e exportar como imagem no PDF
  static async exportElementToPDF(elementId: string, filename: string) {
    try {
      const element = document.getElementById(elementId)
      if (!element) {
        throw new Error('Elemento não encontrado')
      }

      const canvas = await html2canvas(element, {
        useCORS: true,
        allowTaint: true
      })

      const imgData = canvas.toDataURL('image/png')
      const doc = new jsPDF('landscape')
      
      const imgWidth = 280
      const imgHeight = (canvas.height * imgWidth) / canvas.width
      
      doc.addImage(imgData, 'PNG', 10, 10, imgWidth, imgHeight)
      doc.save(filename)
    } catch (error) {
      console.error('Erro ao exportar PDF:', error)
      throw error
    }
  }
}
