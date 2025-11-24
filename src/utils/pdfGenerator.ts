import jsPDF from 'jspdf'
import 'jspdf-autotable'
import type { Product } from '../types/product'
import { formatCurrency } from './format'

// Tipo para as opções do autoTable
interface AutoTableOptions {
  startY?: number
  head?: string[][]
  body?: string[][]
  theme?: 'striped' | 'grid' | 'plain'
  styles?: {
    fontSize?: number
    cellPadding?: number
  }
  headStyles?: {
    fillColor?: number[]
    textColor?: number | string
    fontStyle?: string
  }
  alternateRowStyles?: {
    fillColor?: number[]
  }
  columnStyles?: Record<number, { cellWidth?: number }>
  margin?: { left?: number; right?: number }
}

// Extender o tipo jsPDF para incluir autoTable
declare module 'jspdf' {
  interface jsPDF {
    autoTable: (options: AutoTableOptions) => jsPDF
  }
}

interface ExportOptions {
  filters?: {
    searchTerm?: string
    category?: string
    status?: string
    stockLevel?: string
  }
  generatedBy?: string
  generatedAt?: Date
}

export async function generateProductsPDF(products: Product[], options: ExportOptions = {}) {
  const doc = new jsPDF()
  
  // Configurações
  const pageWidth = doc.internal.pageSize.width
  const margin = 20
  
  // Título
  doc.setFontSize(20)
  doc.setFont('helvetica', 'bold')
  doc.text('Relatório de Produtos', margin, 30)
  
  // Informações do relatório
  doc.setFontSize(10)
  doc.setFont('helvetica', 'normal')
  const currentDate = options.generatedAt || new Date()
  doc.text(`Gerado em: ${currentDate.toLocaleDateString('pt-BR')} às ${currentDate.toLocaleTimeString('pt-BR')}`, margin, 45)
  
  if (options.generatedBy) {
    doc.text(`Gerado por: ${options.generatedBy}`, margin, 52)
  }
  
  doc.text(`Total de produtos: ${products.length}`, margin, 59)
  
  // Filtros aplicados
  let yPosition = 66
  if (options.filters) {
    const { filters } = options
    const activeFilters = []
    
    if (filters.searchTerm) activeFilters.push(`Busca: "${filters.searchTerm}"`)
    if (filters.category && filters.category !== 'all') activeFilters.push(`Categoria: ${filters.category}`)
    if (filters.status && filters.status !== 'all') activeFilters.push(`Status: ${filters.status === 'active' ? 'Ativo' : 'Inativo'}`)
    if (filters.stockLevel && filters.stockLevel !== 'all') {
      const stockLabels = {
        'normal': 'Estoque normal',
        'low': 'Estoque baixo',
        'out': 'Sem estoque'
      }
      activeFilters.push(`Estoque: ${stockLabels[filters.stockLevel as keyof typeof stockLabels]}`)
    }
    
    if (activeFilters.length > 0) {
      doc.text('Filtros aplicados:', margin, yPosition)
      yPosition += 7
      activeFilters.forEach(filter => {
        doc.text(`• ${filter}`, margin + 5, yPosition)
        yPosition += 7
      })
    }
  }
  
  // Linha separadora
  yPosition += 5
  doc.line(margin, yPosition, pageWidth - margin, yPosition)
  yPosition += 10
  
  // Estatísticas resumidas
  const stats = {
    total: products.length,
    ativos: products.filter(p => p.ativo).length,
    inativos: products.filter(p => !p.ativo).length,
    semEstoque: products.filter(p => p.estoque === 0).length,
    estoqueTotal: products.reduce((sum, p) => sum + p.estoque, 0),
    valorTotal: products.reduce((sum, p) => sum + (p.preco_venda * p.estoque), 0)
  }
  
  doc.setFontSize(12)
  doc.setFont('helvetica', 'bold')
  doc.text('Resumo Executivo', margin, yPosition)
  yPosition += 10
  
  doc.setFontSize(10)
  doc.setFont('helvetica', 'normal')
  
  const statsData = [
    ['Total de produtos:', stats.total.toString()],
    ['Produtos ativos:', stats.ativos.toString()],
    ['Produtos inativos:', stats.inativos.toString()],
    ['Produtos sem estoque:', stats.semEstoque.toString()],
    ['Estoque total (unidades):', stats.estoqueTotal.toString()],
    ['Valor total do estoque:', formatCurrency(stats.valorTotal)]
  ]
  
  statsData.forEach(([label, value]) => {
    doc.text(label, margin, yPosition)
    doc.text(value, margin + 120, yPosition)
    yPosition += 7
  })
  
  yPosition += 10
  
  // Tabela de produtos
  const tableColumns = [
    { header: 'Código', dataKey: 'codigo' },
    { header: 'Nome', dataKey: 'nome' },
    { header: 'Categoria', dataKey: 'categoria' },
    { header: 'Preço', dataKey: 'preco' },
    { header: 'Estoque', dataKey: 'estoque' },
    { header: 'Status', dataKey: 'status' }
  ]
  
  const tableData = products.map(product => ({
    codigo: product.codigo,
    nome: product.nome.length > 25 ? product.nome.substring(0, 22) + '...' : product.nome,
    categoria: product.categoria || '-',
    preco: formatCurrency(product.preco_venda),
    estoque: `${product.estoque} ${product.unidade}`,
    status: product.ativo ? 'Ativo' : 'Inativo'
  }))
  
  doc.autoTable({
    startY: yPosition,
    head: [tableColumns.map(col => col.header)],
    body: tableData.map(row => tableColumns.map(col => row[col.dataKey as keyof typeof row])),
    theme: 'grid',
    styles: {
      fontSize: 8,
      cellPadding: 2
    },
    headStyles: {
      fillColor: [51, 122, 183],
      textColor: 255,
      fontStyle: 'bold'
    },
    alternateRowStyles: {
      fillColor: [245, 245, 245]
    },
    columnStyles: {
      0: { cellWidth: 25 }, // Código
      1: { cellWidth: 45 }, // Nome
      2: { cellWidth: 30 }, // Categoria
      3: { cellWidth: 25 }, // Preço
      4: { cellWidth: 25 }, // Estoque
      5: { cellWidth: 20 }  // Status
    },
    margin: { left: margin, right: margin }
  })
  
  // Rodapé
  const pageCount = doc.internal.pages.length - 1
  for (let i = 1; i <= pageCount; i++) {
    doc.setPage(i)
    doc.setFontSize(8)
    doc.setFont('helvetica', 'normal')
    doc.text(
      `RaVal pdv - Relatório de Produtos | Página ${i} de ${pageCount}`,
      pageWidth / 2,
      doc.internal.pageSize.height - 10,
      { align: 'center' }
    )
  }
  
  // Salvar o PDF
  const fileName = `produtos_${currentDate.toISOString().split('T')[0]}.pdf`
  doc.save(fileName)
}
