import React, { useState } from 'react'
import { Printer, Eraser, Calculator, AlertCircle } from 'lucide-react'

interface OrcamentoData {
  // Dados da Empresa
  empresa: string
  cnpj: string
  telefone_empresa: string
  endereco_empresa: string
  
  // Identificação do Orçamento
  numero_orcamento: string
  data_orcamento: string
  validade_orcamento: string
  
  // Dados do Cliente
  nome_cliente: string
  cpf_cnpj_cliente: string
  telefone_cliente: string
  endereco_cliente: string
  email: string
  
  // Dados do Equipamento
  marca: string
  modelo: string
  tipo: string
  numero_serie: string
  defeito_relatado: string
  
  // Serviços e Valores
  diagnostico: string
  servicos_orcados: string
  pecas_necessarias: string
  mao_de_obra: string
  valor_pecas: string
  valor_mao_obra: string
  desconto: string
  valor_total: string
  
  // Prazo e Garantia
  prazo_execucao: string
  garantia_servico: string
  
  // Observações e Termos
  observacoes: string
  forma_pagamento: string
  
  // Assinatura
  nome_responsavel: string
  funcao_responsavel: string
  data_assinatura: string
}

const OrcamentoPage: React.FC = () => {
  const [formData, setFormData] = useState<OrcamentoData>({
    empresa: '',
    cnpj: '',
    telefone_empresa: '',
    endereco_empresa: '',
    numero_orcamento: '',
    data_orcamento: new Date().toISOString().split('T')[0],
    validade_orcamento: '15',
    nome_cliente: '',
    cpf_cnpj_cliente: '',
    telefone_cliente: '',
    endereco_cliente: '',
    email: '',
    marca: '',
    modelo: '',
    tipo: '',
    numero_serie: '',
    defeito_relatado: '',
    diagnostico: '',
    servicos_orcados: '',
    pecas_necessarias: '',
    mao_de_obra: '',
    valor_pecas: '',
    valor_mao_obra: '',
    desconto: '0',
    valor_total: '',
    prazo_execucao: '',
    garantia_servico: '90 dias',
    observacoes: '',
    forma_pagamento: '',
    nome_responsavel: '',
    funcao_responsavel: 'Responsável Técnico',
    data_assinatura: new Date().toISOString().split('T')[0]
  })

  const handleChange = (field: keyof OrcamentoData, value: string) => {
    setFormData(prev => {
      const updated = { ...prev, [field]: value }
      
      // Calcular valor total automaticamente
      if (field === 'valor_pecas' || field === 'valor_mao_obra' || field === 'desconto') {
        const pecas = parseFloat(updated.valor_pecas || '0')
        const maoObra = parseFloat(updated.valor_mao_obra || '0')
        const desconto = parseFloat(updated.desconto || '0')
        const subtotal = pecas + maoObra
        const total = subtotal - desconto
        updated.valor_total = total.toFixed(2)
      }
      
      return updated
    })
  }

  const handleLimpar = () => {
    if (window.confirm('Deseja realmente limpar todos os campos do orçamento?')) {
      setFormData({
        empresa: '',
        cnpj: '',
        telefone_empresa: '',
        endereco_empresa: '',
        numero_orcamento: '',
        data_orcamento: new Date().toISOString().split('T')[0],
        validade_orcamento: '15',
        nome_cliente: '',
        cpf_cnpj_cliente: '',
        telefone_cliente: '',
        endereco_cliente: '',
        email: '',
        marca: '',
        modelo: '',
        tipo: '',
        numero_serie: '',
        defeito_relatado: '',
        diagnostico: '',
        servicos_orcados: '',
        pecas_necessarias: '',
        mao_de_obra: '',
        valor_pecas: '',
        valor_mao_obra: '',
        desconto: '0',
        valor_total: '',
        prazo_execucao: '',
        garantia_servico: '90 dias',
        observacoes: '',
        forma_pagamento: '',
        nome_responsavel: '',
        funcao_responsavel: 'Responsável Técnico',
        data_assinatura: new Date().toISOString().split('T')[0]
      })
    }
  }

  const handleImprimir = () => {
    const printContent = document.querySelector('.orcamento-impressao')
    if (!printContent) return

    const printWindow = window.open('', '', 'width=800,height=600')
    if (!printWindow) return

    printWindow.document.write(`
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <title>Orçamento</title>
          <style>
            * {
              margin: 0;
              padding: 0;
              box-sizing: border-box;
            }
            
            body {
              font-family: Arial, sans-serif;
              padding: 12mm 15mm;
              font-size: 10pt;
              line-height: 1.4;
              min-height: 297mm;
              width: 210mm;
              margin: 0 auto;
            }
            
            .orcamento-impressao {
              max-width: 100%;
              display: flex;
              flex-direction: column;
              min-height: 273mm;
            }
            
            .header {
              text-align: center;
              margin-bottom: 12px;
              border-bottom: 3px solid #10b981;
              padding-bottom: 8px;
            }
            
            .header h1 {
              font-size: 20pt;
              color: #10b981;
              margin-bottom: 3px;
            }
            
            .header .subtitle {
              font-size: 10pt;
              color: #666;
            }
            
            .empresa-info {
              background: #f9f9f9;
              padding: 10px 12px;
              margin-bottom: 12px;
              border-left: 4px solid #10b981;
              font-size: 10pt;
            }
            
            .empresa-info h2 {
              font-size: 13pt;
              color: #333;
              margin-bottom: 5px;
            }
            
            .empresa-info p {
              font-size: 9pt;
              color: #666;
              margin: 2px 0;
              line-height: 1.5;
            }
            
            .section {
              margin-bottom: 12px;
              page-break-inside: avoid;
            }
            
            .section-title {
              font-size: 12pt;
              font-weight: bold;
              color: #10b981;
              margin-bottom: 6px;
              padding-bottom: 3px;
              border-bottom: 2px solid #e5e5e5;
            }
            
            .info-grid {
              display: grid;
              grid-template-columns: repeat(3, 1fr);
              gap: 8px 10px;
              margin-bottom: 8px;
              font-size: 10pt;
            }
            
            .info-item {
              font-size: 10pt;
              line-height: 1.5;
            }
            
            .info-item strong {
              color: #333;
              display: inline;
              margin-right: 4px;
            }
            
            .info-item span {
              color: #666;
            }
            
            .full-width {
              grid-column: 1 / -1;
            }
            
            .valores-table {
              width: 100%;
              border-collapse: collapse;
              margin: 8px 0;
              font-size: 10pt;
            }
            
            .valores-table th,
            .valores-table td {
              padding: 6px 8px;
              text-align: left;
              border: 1px solid #ddd;
            }
            
            .valores-table th {
              background: #f3f4f6;
              font-weight: bold;
              color: #333;
            }
            
            .valores-table .total-row {
              background: #10b981;
              color: white;
              font-weight: bold;
              font-size: 11pt;
            }
            
            .observacoes {
              background: #fffbeb;
              padding: 8px 10px;
              border-left: 4px solid #f59e0b;
              margin: 8px 0;
              font-size: 9pt;
              line-height: 1.4;
            }
            
            .termos {
              font-size: 8pt;
              color: #666;
              margin: 10px 0;
              padding: 8px 10px;
              background: #f9fafb;
              line-height: 1.5;
            }
            
            .termos ul {
              margin-left: 15px;
            }
            
            .termos li {
              margin: 3px 0;
            }
            
            .assinatura {
              margin-top: auto;
              padding-top: 20px;
              border-top: 2px solid #ddd;
              font-size: 10pt;
            }
            
            .assinatura-grid {
              display: grid;
              grid-template-columns: repeat(2, 1fr);
              gap: 40px;
              margin-top: 40px;
            }
            
            .assinatura-linha {
              border-top: 1px solid #333;
              padding-top: 5px;
              text-align: center;
              font-size: 9pt;
            }
            
            @media print {
              body {
                padding: 10mm 8mm;
              }
              
              .section {
                page-break-inside: avoid;
              }
            }
          </style>
        </head>
        <body>
          ${printContent.innerHTML}
        </body>
      </html>
    `)

    printWindow.document.close()
    printWindow.focus()
    
    setTimeout(() => {
      printWindow.print()
      printWindow.close()
    }, 250)
  }

  return (
    <div className="space-y-6">
      {/* Versão para Impressão (oculta na tela) */}
      <div className="hidden print:block orcamento-impressao">
        <div className="header">
          <h1>ORÇAMENTO DE SERVIÇO</h1>
          <p className="subtitle">Documento de orçamento para serviços técnicos</p>
        </div>

        {/* Informações da Empresa */}
        <div className="empresa-info">
          <h2>{formData.empresa || '[Nome da Empresa]'}</h2>
          <p><strong>CNPJ:</strong> {formData.cnpj || '[CNPJ]'}</p>
          <p><strong>Telefone:</strong> {formData.telefone_empresa || '[Telefone]'}</p>
          <p><strong>Endereço:</strong> {formData.endereco_empresa || '[Endereço]'}</p>
        </div>

        {/* Identificação e Cliente - Combinados */}
        <div className="section">
          <div className="section-title">Identificação e Dados do Cliente</div>
          <div className="info-grid">
            <div className="info-item">
              <strong>Nº:</strong>
              <span>{formData.numero_orcamento || '[Número]'}</span>
            </div>
            <div className="info-item">
              <strong>Data:</strong>
              <span>{formData.data_orcamento ? new Date(formData.data_orcamento + 'T00:00:00').toLocaleDateString('pt-BR') : '[Data]'}</span>
            </div>
            <div className="info-item">
              <strong>Validade:</strong>
              <span>{formData.validade_orcamento} dias</span>
            </div>
            <div className="info-item full-width">
              <strong>Cliente:</strong>
              <span>{formData.nome_cliente || '[Nome do Cliente]'}</span>
            </div>
            <div className="info-item">
              <strong>CPF/CNPJ:</strong>
              <span>{formData.cpf_cnpj_cliente || '[CPF/CNPJ]'}</span>
            </div>
            <div className="info-item">
              <strong>Telefone:</strong>
              <span>{formData.telefone_cliente || '[Telefone]'}</span>
            </div>
            <div className="info-item">
              <strong>E-mail:</strong>
              <span>{formData.email || '[E-mail]'}</span>
            </div>
          </div>
        </div>

        {/* Equipamento e Defeito - Combinados */}
        <div className="section">
          <div className="section-title">Equipamento</div>
          <div className="info-grid">
            <div className="info-item">
              <strong>Tipo:</strong>
              <span>{formData.tipo || '[Tipo]'}</span>
            </div>
            <div className="info-item">
              <strong>Marca:</strong>
              <span>{formData.marca || '[Marca]'}</span>
            </div>
            <div className="info-item">
              <strong>Modelo:</strong>
              <span>{formData.modelo || '[Modelo]'}</span>
            </div>
            <div className="info-item full-width">
              <strong>Defeito:</strong>
              <span>{formData.defeito_relatado || '[Defeito relatado]'} | {formData.diagnostico || '[Diagnóstico]'}</span>
            </div>
          </div>
        </div>

        {/* Serviços Orçados */}
        <div className="section">
          <div className="section-title">Serviços e Peças</div>
          <div className="info-item full-width" style={{ fontSize: '8.5pt' }}>
            <p style={{ whiteSpace: 'pre-line', marginBottom: '4px' }}>{formData.servicos_orcados || '[Descrição dos serviços]'}</p>
            {formData.pecas_necessarias && (
              <p style={{ whiteSpace: 'pre-line' }}><strong>Peças:</strong> {formData.pecas_necessarias}</p>
            )}
          </div>
        </div>

        {/* Tabela de Valores */}
        <div className="section">
          <div className="section-title">Valores do Orçamento</div>
          <table className="valores-table">
            <thead>
              <tr>
                <th>Descrição</th>
                <th style={{ textAlign: 'right', width: '150px' }}>Valor (R$)</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Peças/Componentes</td>
                <td style={{ textAlign: 'right' }}>
                  {formData.valor_pecas ? parseFloat(formData.valor_pecas).toLocaleString('pt-BR', { minimumFractionDigits: 2 }) : '0,00'}
                </td>
              </tr>
              <tr>
                <td>Mão de Obra</td>
                <td style={{ textAlign: 'right' }}>
                  {formData.valor_mao_obra ? parseFloat(formData.valor_mao_obra).toLocaleString('pt-BR', { minimumFractionDigits: 2 }) : '0,00'}
                </td>
              </tr>
              {formData.desconto && parseFloat(formData.desconto) > 0 && (
                <tr>
                  <td>Desconto</td>
                  <td style={{ textAlign: 'right', color: '#dc2626' }}>
                    - {parseFloat(formData.desconto).toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                  </td>
                </tr>
              )}
              <tr className="total-row">
                <td>VALOR TOTAL</td>
                <td style={{ textAlign: 'right' }}>
                  {formData.valor_total ? parseFloat(formData.valor_total).toLocaleString('pt-BR', { minimumFractionDigits: 2 }) : '0,00'}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        {/* Prazo e Garantia */}
        <div className="section">
          <div className="info-grid">
            <div className="info-item">
              <strong>Prazo de Execução:</strong>
              <span>{formData.prazo_execucao || '[Prazo]'}</span>
            </div>
            <div className="info-item">
              <strong>Garantia:</strong>
              <span>{formData.garantia_servico || '[Garantia]'}</span>
            </div>
            <div className="info-item">
              <strong>Forma de Pagamento:</strong>
              <span>{formData.forma_pagamento || '[Forma de pagamento]'}</span>
            </div>
          </div>
        </div>

        {/* Prazo, Garantia e Observações - Combinados */}
        <div className="section">
          <div className="info-grid">
            <div className="info-item">
              <strong>Prazo:</strong>
              <span>{formData.prazo_execucao || '[Prazo]'}</span>
            </div>
            <div className="info-item">
              <strong>Garantia:</strong>
              <span>{formData.garantia_servico || '[Garantia]'}</span>
            </div>
            <div className="info-item">
              <strong>Pagamento:</strong>
              <span>{formData.forma_pagamento || '[Forma]'}</span>
            </div>
            {formData.observacoes && (
              <div className="info-item full-width" style={{ fontSize: '8pt', fontStyle: 'italic' }}>
                <strong>Obs:</strong> <span>{formData.observacoes}</span>
              </div>
            )}
          </div>
        </div>

        {/* Termos e Condições - Resumidos */}
        <div className="termos">
          <strong>Condições:</strong> Validade {formData.validade_orcamento || '15'} dias. Valores sujeitos a alteração. Serviço iniciado após autorização. Garantia para defeitos diagnosticados. Equipamento não retirado em 90 dias será descartado.
        </div>

        {/* Assinatura - Compacta */}
        <div className="assinatura">
          <div className="assinatura-grid">
            <div>
              <div className="assinatura-linha">
                {formData.nome_responsavel || '[Responsável]'} - {formData.funcao_responsavel}
              </div>
            </div>
            <div>
              <div className="assinatura-linha">
                Cliente - Data: {formData.data_assinatura ? new Date(formData.data_assinatura + 'T00:00:00').toLocaleDateString('pt-BR') : '[Data]'}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Formulário de Edição (visível na tela) */}
      <div className="print:hidden bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        {/* Header com Botões */}
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-green-100 rounded-lg">
              <Calculator className="w-6 h-6 text-green-600" />
            </div>
            <div>
              <h2 className="text-xl font-semibold text-gray-800">Orçamento de Serviço</h2>
              <p className="text-sm text-gray-500">Preencha os dados para gerar o orçamento</p>
            </div>
          </div>

          <div className="flex gap-3">
            <button
              type="button"
              onClick={handleLimpar}
              className="flex items-center gap-2 px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg transition-colors"
            >
              <Eraser className="w-4 h-4" />
              Limpar
            </button>
            <button
              type="button"
              onClick={handleImprimir}
              className="flex items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition-colors shadow-sm"
            >
              <Printer className="w-4 h-4" />
              Imprimir
            </button>
          </div>
        </div>

        {/* Alerta Informativo */}
        <div className="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg flex gap-3">
          <AlertCircle className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
          <div className="text-sm text-blue-800">
            <p className="font-medium mb-1">Dica:</p>
            <p>Preencha todos os campos necessários e clique em "Imprimir" para gerar o orçamento em formato A4.</p>
          </div>
        </div>

        {/* Formulário */}
        <form className="space-y-8">
          {/* Dados da Empresa */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800 border-b pb-2">Dados da Empresa</h3>
            <div className="grid grid-cols-2 gap-4">
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nome da Empresa *
                </label>
                <input
                  type="text"
                  value={formData.empresa}
                  onChange={(e) => handleChange('empresa', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Nome da empresa"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  CNPJ
                </label>
                <input
                  type="text"
                  value={formData.cnpj}
                  onChange={(e) => handleChange('cnpj', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="00.000.000/0000-00"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Telefone
                </label>
                <input
                  type="text"
                  value={formData.telefone_empresa}
                  onChange={(e) => handleChange('telefone_empresa', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="(00) 00000-0000"
                />
              </div>
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Endereço
                </label>
                <input
                  type="text"
                  value={formData.endereco_empresa}
                  onChange={(e) => handleChange('endereco_empresa', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Endereço completo"
                />
              </div>
            </div>
          </div>

          {/* Identificação do Orçamento */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800 border-b pb-2">Identificação do Orçamento</h3>
            <div className="grid grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nº Orçamento *
                </label>
                <input
                  type="text"
                  value={formData.numero_orcamento}
                  onChange={(e) => handleChange('numero_orcamento', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="ORÇ-001"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Data do Orçamento
                </label>
                <input
                  type="date"
                  value={formData.data_orcamento}
                  onChange={(e) => handleChange('data_orcamento', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Validade (dias)
                </label>
                <input
                  type="number"
                  value={formData.validade_orcamento}
                  onChange={(e) => handleChange('validade_orcamento', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="15"
                />
              </div>
            </div>
          </div>

          {/* Dados do Cliente */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800 border-b pb-2">Dados do Cliente</h3>
            <div className="grid grid-cols-2 gap-4">
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nome do Cliente *
                </label>
                <input
                  type="text"
                  value={formData.nome_cliente}
                  onChange={(e) => handleChange('nome_cliente', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Nome completo"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  CPF/CNPJ
                </label>
                <input
                  type="text"
                  value={formData.cpf_cnpj_cliente}
                  onChange={(e) => handleChange('cpf_cnpj_cliente', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="000.000.000-00"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Telefone
                </label>
                <input
                  type="text"
                  value={formData.telefone_cliente}
                  onChange={(e) => handleChange('telefone_cliente', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="(00) 00000-0000"
                />
              </div>
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Endereço
                </label>
                <input
                  type="text"
                  value={formData.endereco_cliente}
                  onChange={(e) => handleChange('endereco_cliente', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Endereço completo"
                />
              </div>
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  E-mail
                </label>
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => handleChange('email', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="email@exemplo.com"
                />
              </div>
            </div>
          </div>

          {/* Dados do Equipamento */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800 border-b pb-2">Dados do Equipamento</h3>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Tipo de Equipamento
                </label>
                <input
                  type="text"
                  value={formData.tipo}
                  onChange={(e) => handleChange('tipo', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Ex: Smartphone, Notebook"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Marca
                </label>
                <input
                  type="text"
                  value={formData.marca}
                  onChange={(e) => handleChange('marca', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Marca do equipamento"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Modelo
                </label>
                <input
                  type="text"
                  value={formData.modelo}
                  onChange={(e) => handleChange('modelo', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Modelo do equipamento"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nº de Série
                </label>
                <input
                  type="text"
                  value={formData.numero_serie}
                  onChange={(e) => handleChange('numero_serie', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Número de série"
                />
              </div>
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Defeito Relatado
                </label>
                <textarea
                  value={formData.defeito_relatado}
                  onChange={(e) => handleChange('defeito_relatado', e.target.value)}
                  rows={2}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Descrição do problema relatado pelo cliente"
                />
              </div>
            </div>
          </div>

          {/* Diagnóstico e Serviços */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800 border-b pb-2">Diagnóstico e Serviços</h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Diagnóstico Técnico
                </label>
                <textarea
                  value={formData.diagnostico}
                  onChange={(e) => handleChange('diagnostico', e.target.value)}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Resultado do diagnóstico técnico..."
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Serviços Orçados *
                </label>
                <textarea
                  value={formData.servicos_orcados}
                  onChange={(e) => handleChange('servicos_orcados', e.target.value)}
                  rows={4}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Descrição detalhada dos serviços a serem executados..."
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Peças Necessárias
                </label>
                <textarea
                  value={formData.pecas_necessarias}
                  onChange={(e) => handleChange('pecas_necessarias', e.target.value)}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Lista de peças que serão necessárias..."
                />
              </div>
            </div>
          </div>

          {/* Valores */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800 border-b pb-2">Valores</h3>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Valor das Peças (R$)
                </label>
                <input
                  type="number"
                  step="0.01"
                  value={formData.valor_pecas}
                  onChange={(e) => handleChange('valor_pecas', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="0.00"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Valor Mão de Obra (R$)
                </label>
                <input
                  type="number"
                  step="0.01"
                  value={formData.valor_mao_obra}
                  onChange={(e) => handleChange('valor_mao_obra', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="0.00"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Desconto (R$)
                </label>
                <input
                  type="number"
                  step="0.01"
                  value={formData.desconto}
                  onChange={(e) => handleChange('desconto', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="0.00"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Valor Total (R$)
                </label>
                <input
                  type="text"
                  value={formData.valor_total}
                  readOnly
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg bg-gray-50 font-bold text-green-600"
                  placeholder="0.00"
                />
              </div>
            </div>
          </div>

          {/* Prazo e Garantia */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800 border-b pb-2">Prazo e Garantia</h3>
            <div className="grid grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Prazo de Execução
                </label>
                <input
                  type="text"
                  value={formData.prazo_execucao}
                  onChange={(e) => handleChange('prazo_execucao', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Ex: 5 dias úteis"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Garantia do Serviço
                </label>
                <input
                  type="text"
                  value={formData.garantia_servico}
                  onChange={(e) => handleChange('garantia_servico', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Ex: 90 dias"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Forma de Pagamento
                </label>
                <input
                  type="text"
                  value={formData.forma_pagamento}
                  onChange={(e) => handleChange('forma_pagamento', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Ex: Dinheiro, PIX"
                />
              </div>
            </div>
          </div>

          {/* Observações */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800 border-b pb-2">Observações</h3>
            <div>
              <textarea
                value={formData.observacoes}
                onChange={(e) => handleChange('observacoes', e.target.value)}
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                placeholder="Observações adicionais sobre o orçamento..."
              />
            </div>
          </div>

          {/* Assinatura */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800 border-b pb-2">Responsável</h3>
            <div className="grid grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nome do Responsável
                </label>
                <input
                  type="text"
                  value={formData.nome_responsavel}
                  onChange={(e) => handleChange('nome_responsavel', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Nome completo"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Função
                </label>
                <input
                  type="text"
                  value={formData.funcao_responsavel}
                  onChange={(e) => handleChange('funcao_responsavel', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  placeholder="Cargo/Função"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Data
                </label>
                <input
                  type="date"
                  value={formData.data_assinatura}
                  onChange={(e) => handleChange('data_assinatura', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                />
              </div>
            </div>
          </div>
        </form>
      </div>
    </div>
  )
}

export default OrcamentoPage
