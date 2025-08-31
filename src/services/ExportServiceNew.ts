import jsPDF from 'jspdf'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'
import type { SalesReport, ClientsReport } from '../types/reports'

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
    
    doc.save(`relatorio-vendas-${new Date().toISOString().split('T')[0]}.pdf`)
  }

  // Exportar relatório de vendas para Excel
  static async exportSalesToExcel(data: SalesReport) {
    const workbook = XLSX.utils.book_new()
    
    const vendasData = [
      ['ID', 'Data', 'Cliente', 'Valor Total', 'Forma Pagamento'],
      ...data.vendas.map(venda => [
        venda.id,
        new Date(venda.data_venda).toLocaleDateString('pt-BR'),
        venda.cliente?.nome || 'Sem cliente',
        venda.total,
        venda.forma_pagamento
      ])
    ]
    
    const vendasSheet = XLSX.utils.aoa_to_sheet(vendasData)
    XLSX.utils.book_append_sheet(workbook, vendasSheet, 'Vendas')
    
    const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' })
    const data_blob = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    saveAs(data_blob, `relatorio-vendas-${new Date().toISOString().split('T')[0]}.xlsx`)
  }

  // Exportar relatório de clientes para PDF
  static async exportClientsToPDF(data: ClientsReport) {
    const doc = new jsPDF()
    
    // Título
    doc.setFontSize(18)
    doc.text('Relatório de Clientes', 20, 20)
    
    // Data do relatório
    doc.setFontSize(12)
    doc.text(`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`, 20, 35)
    
    // Resumo
    doc.setFontSize(14)
    doc.text('RESUMO:', 20, 50)
    doc.setFontSize(12)
    doc.text(`Total de Clientes: ${data.resumo.total_clientes}`, 20, 60)
    doc.text(`Clientes Ativos: ${data.resumo.clientes_ativos}`, 20, 70)
    doc.text(`Clientes Inativos: ${data.resumo.clientes_inativos}`, 20, 80)
    doc.text(`Ticket Médio Geral: R$ ${data.resumo.ticket_medio_geral.toFixed(2)}`, 20, 90)
    
    // Lista de clientes
    let yPosition = 110
    doc.setFontSize(14)
    doc.text('CLIENTES:', 20, yPosition)
    yPosition += 15
    
    data.clientes.forEach((cliente) => {
      if (yPosition > 270) {
        doc.addPage()
        yPosition = 20
      }
      
      const nome = cliente.nome || 'Sem nome'
      const email = cliente.email || 'Sem email'
      
      doc.text(`${nome} - ${email}`, 20, yPosition)
      doc.text(`Compras: ${cliente.total_compras} - Total: R$ ${cliente.valor_total.toFixed(2)}`, 20, yPosition + 8)
      yPosition += 20
    })
    
    doc.save(`relatorio-clientes-${new Date().toISOString().split('T')[0]}.pdf`)
  }

  // Exportar relatório de clientes para Excel
  static async exportClientsToExcel(data: ClientsReport) {
    const workbook = XLSX.utils.book_new()
    
    // Planilha de clientes
    const clientesData = [
      ['Nome', 'Email', 'Telefone', 'Total Compras', 'Valor Total', 'Última Compra', 'Ticket Médio'],
      ...data.clientes.map(cliente => [
        cliente.nome || '',
        cliente.email || '',
        cliente.telefone || '',
        cliente.total_compras,
        cliente.valor_total,
        cliente.ultima_compra ? new Date(cliente.ultima_compra).toLocaleDateString('pt-BR') : 'Nunca',
        cliente.ticket_medio
      ])
    ]
    
    const clientesSheet = XLSX.utils.aoa_to_sheet(clientesData)
    XLSX.utils.book_append_sheet(workbook, clientesSheet, 'Clientes')
    
    const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' })
    const data_blob = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    saveAs(data_blob, `relatorio-clientes-${new Date().toISOString().split('T')[0]}.xlsx`)
  }

  // Imprimir apenas um elemento específico da página
  static printElement(elementId: string) {
    const element = document.getElementById(elementId)
    if (!element) {
      console.error('Elemento não encontrado:', elementId)
      return
    }

    // Criar uma nova janela para impressão
    const printWindow = window.open('', '_blank')
    if (!printWindow) {
      console.error('Não foi possível abrir janela de impressão')
      return
    }

    // Copiar estilos da página principal
    const styles = Array.from(document.styleSheets)
      .map(styleSheet => {
        try {
          return Array.from(styleSheet.cssRules)
            .map(rule => rule.cssText)
            .join('')
        } catch {
          return ''
        }
      })
      .join('')

    // HTML para a janela de impressão
    printWindow.document.write(`
      <html>
        <head>
          <title>Relatório - PDV Allimport</title>
          <style>
            ${styles}
            @media print {
              body { margin: 0; padding: 20px; }
              .no-print { display: none !important; }
            }
          </style>
        </head>
        <body>
          ${element.innerHTML}
        </body>
      </html>
    `)
    
    printWindow.document.close()
    
    // Aguardar carregamento e imprimir
    printWindow.onload = () => {
      setTimeout(() => {
        printWindow.print()
        printWindow.close()
      }, 500)
    }
  }
}
