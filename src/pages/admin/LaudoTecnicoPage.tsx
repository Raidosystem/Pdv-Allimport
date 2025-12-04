import React, { useState } from 'react';
import { Printer, Eraser, FileText, AlertCircle } from 'lucide-react';

interface LaudoTecnicoData {
  // Dados da Empresa
  empresa: string;
  cnpj: string;
  telefone_empresa: string;
  endereco_empresa: string;
  
  // Identificação do Laudo
  numero_os: string;
  numero_laudo: string;
  data_laudo: string;
  data_entrada: string;
  
  // Dados do Cliente
  nome_cliente: string;
  cpf_cnpj_cliente: string;
  telefone_cliente: string;
  endereco_cliente: string;
  cidade_uf: string;
  cep: string;
  email: string;
  
  // Dados do Equipamento
  marca: string;
  modelo: string;
  tipo: string;
  numero_serie: string;
  acessorios: string;
  
  // Diagnóstico e Serviços
  relato_cliente: string;
  testes_realizados: string;
  diagnostico: string;
  servicos_executados: string;
  pecas_trocadas: string;
  
  // Garantia
  garantia_tipo: 'sem_garantia' | 'com_garantia';
  garantia_dias: string;
  
  // Assinaturas
  nome_responsavel: string;
  funcao_responsavel: string;
  data_assinatura_tecnico: string;
  assinatura_tecnico: string;
  
  nome_cliente_assinatura: string;
  documento_cliente: string;
  data_assinatura_cliente: string;
  assinatura_cliente: string;
}

const LaudoTecnicoPage: React.FC = () => {
  const [formData, setFormData] = useState<LaudoTecnicoData>({
    empresa: '',
    cnpj: '',
    telefone_empresa: '',
    endereco_empresa: '',
    numero_os: '',
    numero_laudo: '',
    data_laudo: new Date().toISOString().split('T')[0],
    data_entrada: new Date().toISOString().split('T')[0],
    nome_cliente: '',
    cpf_cnpj_cliente: '',
    telefone_cliente: '',
    endereco_cliente: '',
    cidade_uf: '',
    cep: '',
    email: '',
    marca: '',
    modelo: '',
    tipo: '',
    numero_serie: '',
    acessorios: '',
    relato_cliente: '',
    testes_realizados: '',
    diagnostico: '',
    servicos_executados: '',
    pecas_trocadas: '',
    garantia_tipo: 'sem_garantia',
    garantia_dias: '90',
    nome_responsavel: '',
    funcao_responsavel: 'Técnico Responsável',
    data_assinatura_tecnico: new Date().toISOString().split('T')[0],
    assinatura_tecnico: '',
    nome_cliente_assinatura: '',
    documento_cliente: '',
    data_assinatura_cliente: new Date().toISOString().split('T')[0],
    assinatura_cliente: ''
  });

  const handleChange = (field: keyof LaudoTecnicoData, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleLimpar = () => {
    if (window.confirm('Deseja realmente limpar todos os campos do laudo?')) {
      setFormData({
        empresa: '',
        cnpj: '',
        telefone_empresa: '',
        endereco_empresa: '',
        numero_os: '',
        numero_laudo: '',
        data_laudo: new Date().toISOString().split('T')[0],
        data_entrada: new Date().toISOString().split('T')[0],
        nome_cliente: '',
        cpf_cnpj_cliente: '',
        telefone_cliente: '',
        endereco_cliente: '',
        cidade_uf: '',
        cep: '',
        email: '',
        marca: '',
        modelo: '',
        tipo: '',
        numero_serie: '',
        acessorios: '',
        relato_cliente: '',
        testes_realizados: '',
        diagnostico: '',
        servicos_executados: '',
        pecas_trocadas: '',
        garantia_tipo: 'sem_garantia',
        garantia_dias: '90',
        nome_responsavel: '',
        funcao_responsavel: 'Técnico Responsável',
        data_assinatura_tecnico: new Date().toISOString().split('T')[0],
        assinatura_tecnico: '',
        nome_cliente_assinatura: '',
        documento_cliente: '',
        data_assinatura_cliente: new Date().toISOString().split('T')[0],
        assinatura_cliente: ''
      });
    }
  };

  const handleImprimir = () => {
    // Criar conteúdo HTML para impressão
    const printContent = document.querySelector('.laudo-impressao');
    if (!printContent) return;

    // Abrir nova janela
    const printWindow = window.open('', '_blank', 'width=800,height=600');
    if (!printWindow) return;

    // Escrever conteúdo
    printWindow.document.write(`
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <title>Laudo Técnico</title>
          <style>
            @page {
              size: A4 portrait;
              margin: 1cm;
            }

            @media print {
              /* Remover cabeçalhos e rodapés do navegador */
              @page {
                margin: 1cm;
              }
            }

            * {
              margin: 0;
              padding: 0;
              box-sizing: border-box;
            }

            body {
              font-family: Arial, sans-serif;
              font-size: 11px;
              line-height: 1.5;
              color: black;
              background: white;
              width: 100%;
              height: 100%;
            }

            .laudo-impressao {
              width: 100%;
              max-width: 100%;
              padding: 0;
            }

            h1 {
              font-size: 24px;
              font-weight: bold;
              text-align: center;
              margin-bottom: 8px;
              padding-bottom: 6px;
              border-bottom: 2px solid #000;
            }

            h2 {
              font-size: 12px;
              font-weight: bold;
              background-color: #e5e7eb;
              padding: 4px 8px;
              margin-top: 8px;
              margin-bottom: 6px;
            }

            p, div {
              font-size: 11px;
              line-height: 1.5;
            }

            section {
              margin-bottom: 8px;
            }

            .grid {
              display: grid;
              margin-bottom: 6px;
            }

            .grid-cols-2 {
              grid-template-columns: repeat(2, 1fr);
              gap: 10px;
            }

            .grid-cols-3 {
              grid-template-columns: repeat(3, 1fr);
              gap: 10px;
            }

            .grid-cols-4 {
              grid-template-columns: repeat(4, 1fr);
              gap: 10px;
            }

            .border {
              border: 1px solid #666;
              padding: 6px;
            }

            .text-center {
              text-align: center;
            }

            .font-bold {
              font-weight: bold;
            }

            .bg-gray-200 {
              background-color: #e5e7eb;
            }

            .space-y-1\.5 > * + * {
              margin-top: 8px;
            }

            .space-y-2 > * + * {
              margin-top: 10px;
            }

            .mb-3 {
              margin-bottom: 8px;
            }

            .mb-1\.5 {
              margin-bottom: 6px;
            }

            .mb-1 {
              margin-bottom: 4px;
            }

            .pb-4 {
              padding-bottom: 16px;
            }

            .pb-2 {
              padding-bottom: 6px;
            }

            .p-1\.5 {
              padding: 6px;
            }

            .mt-1\.5 {
              margin-top: 6px;
            }

            .mt-0\.5 {
              margin-top: 3px;
            }

            .gap-3 {
              gap: 10px;
            }
          </style>
        </head>
        <body>
          ${printContent.innerHTML}
        </body>
      </html>
    `);

    printWindow.document.close();
    
    // Aguardar carregamento e imprimir
    printWindow.onload = () => {
      printWindow.focus();
      printWindow.print();
      printWindow.close();
    };
  };

  const condicoesGerais = `
CONDIÇÕES GERAIS:

1. A garantia dos serviços executados é válida mediante apresentação deste laudo técnico.
2. A garantia não cobre danos causados por uso inadequado, quedas, umidade, oxidação ou ação de terceiros.
3. O equipamento deverá ser retirado em até 30 dias após a conclusão do serviço, sob pena de cobrança de armazenagem.
4. A empresa não se responsabiliza por dados/arquivos contidos no equipamento.
5. Equipamentos não retirados em até 90 dias serão considerados abandonados e destinados conforme legislação vigente.
6. O cliente declara ser proprietário ou possuidor legítimo do equipamento.
  `.trim();

  return (
    <>
      {/* Interface de Edição - Esconder na impressão */}
      <div className="min-h-screen bg-gray-50 p-4 print:hidden">
        {/* Botões de Ação */}
        <div className="max-w-4xl mx-auto mb-4">
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
            <div className="flex items-center justify-between gap-4">
              <div className="flex items-center gap-2 text-gray-600">
                <FileText className="w-5 h-5" />
                <span className="font-medium">Laudo Técnico de Equipamento Eletrônico</span>
              </div>
              <div className="flex gap-2">
                <button
                  onClick={handleLimpar}
                  className="flex items-center gap-2 px-4 py-2 bg-red-50 text-red-600 rounded-lg hover:bg-red-100 transition-colors border border-red-200"
                >
                  <Eraser className="w-4 h-4" />
                  Limpar
                </button>
                <button
                  onClick={handleImprimir}
                  className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors shadow-sm"
                >
                  <Printer className="w-4 h-4" />
                  Imprimir
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Formulário do Laudo - Versão de Edição */}
        <div className="max-w-4xl mx-auto bg-white rounded-lg shadow-lg border border-gray-300">
          <div className="p-8">
          {/* Cabeçalho */}
          <div className="text-center mb-6 border-b-2 border-gray-800 pb-4">
            <h1 className="text-2xl font-bold text-gray-900 mb-1">LAUDO TÉCNICO</h1>
            <p className="text-sm text-gray-600">EQUIPAMENTO ELETRÔNICO</p>
          </div>

          {/* Dados da Empresa */}
          <section className="mb-6">
            <h2 className="text-sm font-bold text-gray-800 mb-3 bg-gray-100 px-3 py-2 rounded">DADOS DA EMPRESA</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Empresa *</label>
                <input
                  type="text"
                  value={formData.empresa}
                  onChange={(e) => handleChange('empresa', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Nome da empresa"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">CNPJ *</label>
                <input
                  type="text"
                  value={formData.cnpj}
                  onChange={(e) => handleChange('cnpj', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="00.000.000/0000-00"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Telefone/WhatsApp *</label>
                <input
                  type="text"
                  value={formData.telefone_empresa}
                  onChange={(e) => handleChange('telefone_empresa', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="(00) 00000-0000"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Endereço *</label>
                <input
                  type="text"
                  value={formData.endereco_empresa}
                  onChange={(e) => handleChange('endereco_empresa', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Rua, número, bairro"
                />
              </div>
            </div>
          </section>

          {/* Identificação do Laudo */}
          <section className="mb-6">
            <h2 className="text-sm font-bold text-gray-800 mb-3 bg-gray-100 px-3 py-2 rounded">IDENTIFICAÇÃO</h2>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Nº OS *</label>
                <input
                  type="text"
                  value={formData.numero_os}
                  onChange={(e) => handleChange('numero_os', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="000001"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Nº Laudo *</label>
                <input
                  type="text"
                  value={formData.numero_laudo}
                  onChange={(e) => handleChange('numero_laudo', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="LAU-0001"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Data do Laudo *</label>
                <input
                  type="date"
                  value={formData.data_laudo}
                  onChange={(e) => handleChange('data_laudo', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Data Entrada *</label>
                <input
                  type="date"
                  value={formData.data_entrada}
                  onChange={(e) => handleChange('data_entrada', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>
          </section>

          {/* Dados do Cliente */}
          <section className="mb-6">
            <h2 className="text-sm font-bold text-gray-800 mb-3 bg-gray-100 px-3 py-2 rounded">DADOS DO CLIENTE</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div className="md:col-span-2">
                <label className="block text-xs font-medium text-gray-700 mb-1">Nome/Razão Social *</label>
                <input
                  type="text"
                  value={formData.nome_cliente}
                  onChange={(e) => handleChange('nome_cliente', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Nome completo do cliente"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">CPF/CNPJ *</label>
                <input
                  type="text"
                  value={formData.cpf_cnpj_cliente}
                  onChange={(e) => handleChange('cpf_cnpj_cliente', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="000.000.000-00"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Telefone/WhatsApp *</label>
                <input
                  type="text"
                  value={formData.telefone_cliente}
                  onChange={(e) => handleChange('telefone_cliente', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="(00) 00000-0000"
                />
              </div>
              <div className="md:col-span-2">
                <label className="block text-xs font-medium text-gray-700 mb-1">Endereço</label>
                <input
                  type="text"
                  value={formData.endereco_cliente}
                  onChange={(e) => handleChange('endereco_cliente', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Rua, número, bairro"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Cidade/UF</label>
                <input
                  type="text"
                  value={formData.cidade_uf}
                  onChange={(e) => handleChange('cidade_uf', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Cidade - UF"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">CEP</label>
                <input
                  type="text"
                  value={formData.cep}
                  onChange={(e) => handleChange('cep', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="00000-000"
                />
              </div>
              <div className="md:col-span-2">
                <label className="block text-xs font-medium text-gray-700 mb-1">E-mail</label>
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => handleChange('email', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="email@exemplo.com"
                />
              </div>
            </div>
          </section>

          {/* Dados do Equipamento */}
          <section className="mb-6">
            <h2 className="text-sm font-bold text-gray-800 mb-3 bg-gray-100 px-3 py-2 rounded">DADOS DO EQUIPAMENTO</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Marca *</label>
                <input
                  type="text"
                  value={formData.marca}
                  onChange={(e) => handleChange('marca', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Ex: Samsung, Apple, Dell"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Modelo *</label>
                <input
                  type="text"
                  value={formData.modelo}
                  onChange={(e) => handleChange('modelo', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Ex: Galaxy S20, iPhone 12"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Tipo *</label>
                <input
                  type="text"
                  value={formData.tipo}
                  onChange={(e) => handleChange('tipo', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Ex: Smartphone, Notebook, TV"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Nº Série / IMEI</label>
                <input
                  type="text"
                  value={formData.numero_serie}
                  onChange={(e) => handleChange('numero_serie', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Número de série ou IMEI"
                />
              </div>
              <div className="md:col-span-2">
                <label className="block text-xs font-medium text-gray-700 mb-1">Acessórios Entregues</label>
                <input
                  type="text"
                  value={formData.acessorios}
                  onChange={(e) => handleChange('acessorios', e.target.value)}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Ex: Carregador, fone de ouvido, capa"
                />
              </div>
            </div>
          </section>

          {/* Avaliação Técnica */}
          <section className="mb-6">
            <h2 className="text-sm font-bold text-gray-800 mb-3 bg-gray-100 px-3 py-2 rounded">AVALIAÇÃO TÉCNICA</h2>
            <div className="space-y-3">
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Relato do Cliente</label>
                <textarea
                  value={formData.relato_cliente}
                  onChange={(e) => handleChange('relato_cliente', e.target.value)}
                  rows={3}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none"
                  placeholder="Descrição do problema relatado pelo cliente..."
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Testes Realizados / Avaliação Técnica</label>
                <textarea
                  value={formData.testes_realizados}
                  onChange={(e) => handleChange('testes_realizados', e.target.value)}
                  rows={3}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none"
                  placeholder="Testes realizados e observações técnicas..."
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Diagnóstico Técnico *</label>
                <textarea
                  value={formData.diagnostico}
                  onChange={(e) => handleChange('diagnostico', e.target.value)}
                  rows={3}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none"
                  placeholder="Diagnóstico detalhado do problema identificado..."
                />
              </div>
            </div>
          </section>

          {/* Serviços Executados */}
          <section className="mb-6">
            <h2 className="text-sm font-bold text-gray-800 mb-3 bg-gray-100 px-3 py-2 rounded">SERVIÇOS EXECUTADOS</h2>
            <div className="space-y-3">
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Serviços Executados *</label>
                <textarea
                  value={formData.servicos_executados}
                  onChange={(e) => handleChange('servicos_executados', e.target.value)}
                  rows={3}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none"
                  placeholder="Descrição detalhada dos serviços realizados..."
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-700 mb-1">Peças Trocadas / Reparadas</label>
                <textarea
                  value={formData.pecas_trocadas}
                  onChange={(e) => handleChange('pecas_trocadas', e.target.value)}
                  rows={3}
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none"
                  placeholder="Lista de peças substituídas ou reparadas..."
                />
              </div>
            </div>
          </section>

          {/* Garantia */}
          <section className="mb-6">
            <h2 className="text-sm font-bold text-gray-800 mb-3 bg-gray-100 px-3 py-2 rounded">GARANTIA</h2>
            <div className="space-y-3">
              <div className="flex items-center gap-6">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="radio"
                    name="garantia"
                    value="sem_garantia"
                    checked={formData.garantia_tipo === 'sem_garantia'}
                    onChange={(e) => handleChange('garantia_tipo', e.target.value as any)}
                    className="w-4 h-4 text-blue-600"
                  />
                  <span className="text-sm text-gray-700">Sem Garantia</span>
                </label>
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="radio"
                    name="garantia"
                    value="com_garantia"
                    checked={formData.garantia_tipo === 'com_garantia'}
                    onChange={(e) => handleChange('garantia_tipo', e.target.value as any)}
                    className="w-4 h-4 text-blue-600"
                  />
                  <span className="text-sm text-gray-700">Com Garantia de</span>
                </label>
                {formData.garantia_tipo === 'com_garantia' && (
                  <input
                    type="number"
                    value={formData.garantia_dias}
                    onChange={(e) => handleChange('garantia_dias', e.target.value)}
                    className="w-20 px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="90"
                  />
                )}
                {formData.garantia_tipo === 'com_garantia' && (
                  <span className="text-sm text-gray-700">dias</span>
                )}
              </div>
            </div>
          </section>

          {/* Condições Gerais */}
          <section className="mb-6">
            <h2 className="text-sm font-bold text-gray-800 mb-3 bg-gray-100 px-3 py-2 rounded">CONDIÇÕES GERAIS</h2>
            <div className="bg-gray-50 border border-gray-300 rounded p-3">
              <pre className="text-xs text-gray-700 whitespace-pre-wrap font-sans">{condicoesGerais}</pre>
            </div>
          </section>

          {/* Assinaturas */}
          <section className="mb-6">
            <h2 className="text-sm font-bold text-gray-800 mb-3 bg-gray-100 px-3 py-2 rounded">ASSINATURAS</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Técnico */}
              <div className="border border-gray-300 rounded p-4">
                <h3 className="text-xs font-semibold text-gray-700 mb-3">RESPONSÁVEL TÉCNICO</h3>
                <div className="space-y-2">
                  <div>
                    <label className="block text-xs font-medium text-gray-600 mb-1">Nome</label>
                    <input
                      type="text"
                      value={formData.nome_responsavel}
                      onChange={(e) => handleChange('nome_responsavel', e.target.value)}
                      className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      placeholder="Nome do técnico"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-600 mb-1">Função</label>
                    <input
                      type="text"
                      value={formData.funcao_responsavel}
                      onChange={(e) => handleChange('funcao_responsavel', e.target.value)}
                      className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      placeholder="Função"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-600 mb-1">Data</label>
                    <input
                      type="date"
                      value={formData.data_assinatura_tecnico}
                      onChange={(e) => handleChange('data_assinatura_tecnico', e.target.value)}
                      className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-600 mb-1">Assinatura</label>
                    <div className="border-b-2 border-gray-400 pb-8 mt-2">
                      <input
                        type="text"
                        value={formData.assinatura_tecnico}
                        onChange={(e) => handleChange('assinatura_tecnico', e.target.value)}
                        className="w-full text-sm italic text-gray-700 border-0 focus:ring-0 bg-transparent"
                        placeholder="____________________________"
                      />
                    </div>
                  </div>
                </div>
              </div>

              {/* Cliente */}
              <div className="border border-gray-300 rounded p-4">
                <h3 className="text-xs font-semibold text-gray-700 mb-3">CLIENTE</h3>
                <div className="space-y-2">
                  <div>
                    <label className="block text-xs font-medium text-gray-600 mb-1">Nome</label>
                    <input
                      type="text"
                      value={formData.nome_cliente_assinatura}
                      onChange={(e) => handleChange('nome_cliente_assinatura', e.target.value)}
                      className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      placeholder="Nome do cliente"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-600 mb-1">CPF/CNPJ</label>
                    <input
                      type="text"
                      value={formData.documento_cliente}
                      onChange={(e) => handleChange('documento_cliente', e.target.value)}
                      className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      placeholder="Documento"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-600 mb-1">Data</label>
                    <input
                      type="date"
                      value={formData.data_assinatura_cliente}
                      onChange={(e) => handleChange('data_assinatura_cliente', e.target.value)}
                      className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-600 mb-1">Assinatura</label>
                    <div className="border-b-2 border-gray-400 pb-8 mt-2">
                      <input
                        type="text"
                        value={formData.assinatura_cliente}
                        onChange={(e) => handleChange('assinatura_cliente', e.target.value)}
                        className="w-full text-sm italic text-gray-700 border-0 focus:ring-0 bg-transparent"
                        placeholder="____________________________"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Aviso de impressão */}
          <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <div className="flex items-start gap-3">
              <AlertCircle className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
              <div className="text-sm text-blue-800">
                <p className="font-medium mb-1">Dica de Impressão:</p>
                <ul className="list-disc list-inside space-y-1 text-xs">
                  <li>Configure a impressão para papel A4</li>
                  <li>Margens recomendadas: 1cm em todos os lados</li>
                  <li>Os campos vazios aparecerão como linhas para preenchimento manual</li>
                  <li>O formulário foi otimizado para caber em uma página</li>
                </ul>
              </div>
            </div>
          </div>
          </div>
        </div>
      </div>

      {/* Versão para Impressão - Apenas o Laudo */}
      <div className="hidden print:block print:m-0 print:p-0">
        <div className="laudo-impressao">
          {/* Cabeçalho */}
          <div className="text-center mb-3 border-b-2 border-gray-900 pb-2">
            <h1 className="text-2xl font-bold text-gray-900">LAUDO TÉCNICO</h1>
          </div>

          {/* Dados da Empresa */}
          <section className="mb-3">
            <h2 className="text-xs font-bold text-gray-900 mb-1.5 bg-gray-200 px-2 py-1">DADOS DA EMPRESA</h2>
            <div className="grid grid-cols-2 gap-3 text-[11px]">
              <div><strong>Empresa:</strong> {formData.empresa || '_______________________________________'}</div>
              <div><strong>CNPJ:</strong> {formData.cnpj || '________________________'}</div>
              <div><strong>Telefone:</strong> {formData.telefone_empresa || '________________________'}</div>
              <div><strong>Endereço:</strong> {formData.endereco_empresa || '_______________________________________'}</div>
            </div>
          </section>

          {/* Identificação */}
          <section className="mb-3">
            <h2 className="text-xs font-bold text-gray-900 mb-1.5 bg-gray-200 px-2 py-1">IDENTIFICAÇÃO</h2>
            <div className="grid grid-cols-4 gap-3 text-[11px]">
              <div><strong>Nº OS:</strong> {formData.numero_os || '________'}</div>
              <div><strong>Nº Laudo:</strong> {formData.numero_laudo || '________'}</div>
              <div><strong>Data Laudo:</strong> {formData.data_laudo || '__________'}</div>
              <div><strong>Data Entrada:</strong> {formData.data_entrada || '__________'}</div>
            </div>
          </section>

          {/* Dados do Cliente */}
          <section className="mb-3">
            <h2 className="text-xs font-bold text-gray-900 mb-1.5 bg-gray-200 px-2 py-1">DADOS DO CLIENTE</h2>
            <div className="space-y-1.5 text-[11px]">
              <div><strong>Nome/Razão Social:</strong> {formData.nome_cliente || '___________________________________________________'}</div>
              <div className="grid grid-cols-2 gap-3">
                <div><strong>CPF/CNPJ:</strong> {formData.cpf_cnpj_cliente || '__________________'}</div>
                <div><strong>Telefone:</strong> {formData.telefone_cliente || '__________________'}</div>
              </div>
              <div><strong>Endereço:</strong> {formData.endereco_cliente || '___________________________________________________'}</div>
              <div className="grid grid-cols-3 gap-3">
                <div><strong>Cidade/UF:</strong> {formData.cidade_uf || '______________'}</div>
                <div><strong>CEP:</strong> {formData.cep || '______________'}</div>
                <div><strong>E-mail:</strong> {formData.email || '______________'}</div>
              </div>
            </div>
          </section>

          {/* Dados do Equipamento */}
          <section className="mb-3">
            <h2 className="text-xs font-bold text-gray-900 mb-1.5 bg-gray-200 px-2 py-1">DADOS DO EQUIPAMENTO</h2>
            <div className="grid grid-cols-2 gap-3 text-[11px]">
              <div><strong>Marca:</strong> {formData.marca || '________________________'}</div>
              <div><strong>Modelo:</strong> {formData.modelo || '________________________'}</div>
              <div><strong>Tipo:</strong> {formData.tipo || '________________________'}</div>
              <div><strong>Nº Série/IMEI:</strong> {formData.numero_serie || '________________________'}</div>
              <div className="col-span-2"><strong>Acessórios:</strong> {formData.acessorios || '_________________________________________________'}</div>
            </div>
          </section>

          {/* Avaliação Técnica e Serviços Executados - Lado a Lado */}
          <div className="grid grid-cols-2 gap-3 mb-3">
            {/* Avaliação Técnica */}
            <section>
              <h2 className="text-xs font-bold text-gray-900 mb-1.5 bg-gray-200 px-2 py-1">AVALIAÇÃO TÉCNICA</h2>
              <div className="space-y-2 text-[11px]">
                <div>
                  <strong>Relato do Cliente:</strong>
                  <p className="mt-0.5 whitespace-pre-wrap leading-tight">{formData.relato_cliente || '________________________________\n________________________________'}</p>
                </div>
                <div>
                  <strong>Testes Realizados:</strong>
                  <p className="mt-0.5 whitespace-pre-wrap leading-tight">{formData.testes_realizados || '________________________________\n________________________________'}</p>
                </div>
                <div>
                  <strong>Diagnóstico Técnico:</strong>
                  <p className="mt-0.5 whitespace-pre-wrap leading-tight">{formData.diagnostico || '________________________________\n________________________________'}</p>
                </div>
              </div>
            </section>

            {/* Serviços Executados */}
            <section>
              <h2 className="text-xs font-bold text-gray-900 mb-1.5 bg-gray-200 px-2 py-1">SERVIÇOS EXECUTADOS</h2>
              <div className="space-y-2 text-[11px]">
                <div>
                  <strong>Serviços:</strong>
                  <p className="mt-0.5 whitespace-pre-wrap leading-tight">{formData.servicos_executados || '________________________________\n________________________________\n________________________________'}</p>
                </div>
                <div>
                  <strong>Peças Trocadas:</strong>
                  <p className="mt-0.5 whitespace-pre-wrap leading-tight">{formData.pecas_trocadas || '________________________________\n________________________________'}</p>
                </div>
              </div>
            </section>
          </div>

          {/* Garantia */}
          <section className="mb-3">
            <h2 className="text-xs font-bold text-gray-900 mb-1.5 bg-gray-200 px-2 py-1">GARANTIA</h2>
            <p className="text-[11px]">
              {formData.garantia_tipo === 'sem_garantia' 
                ? '☑ Sem Garantia  ☐ Com Garantia de ____ dias' 
                : `☐ Sem Garantia  ☑ Com Garantia de ${formData.garantia_dias} dias`}
            </p>
          </section>

          {/* Condições Gerais */}
          <section className="mb-3">
            <h2 className="text-xs font-bold text-gray-900 mb-1.5 bg-gray-200 px-2 py-1">CONDIÇÕES GERAIS</h2>
            <pre className="text-[10px] leading-relaxed text-gray-800 whitespace-pre-wrap font-sans">{condicoesGerais}</pre>
          </section>

          {/* Assinaturas */}
          <section>
            <h2 className="text-xs font-bold text-gray-900 mb-1.5 bg-gray-200 px-2 py-1">ASSINATURAS</h2>
            <div className="grid grid-cols-2 gap-3">
              {/* Técnico */}
              <div className="border border-gray-400 p-1.5">
                <p className="text-[10px] font-bold mb-1">RESPONSÁVEL TÉCNICO</p>
                <div className="space-y-1 text-[9px]">
                  <p><strong>Nome:</strong> {formData.nome_responsavel || '______________________'}</p>
                  <p><strong>Função:</strong> {formData.funcao_responsavel || '______________________'}</p>
                  <p><strong>Data:</strong> {formData.data_assinatura_tecnico || '__________'}</p>
                  <p className="mt-1.5"><strong>Assinatura:</strong></p>
                  <p className="border-b border-gray-500 mt-0.5 pb-4 italic text-[9px]">{formData.assinatura_tecnico}</p>
                </div>
              </div>
              
              {/* Cliente */}
              <div className="border border-gray-400 p-1.5">
                <p className="text-[10px] font-bold mb-1">CLIENTE</p>
                <div className="space-y-1 text-[9px]">
                  <p><strong>Nome:</strong> {formData.nome_cliente_assinatura || '______________________'}</p>
                  <p><strong>CPF/CNPJ:</strong> {formData.documento_cliente || '______________________'}</p>
                  <p><strong>Data:</strong> {formData.data_assinatura_cliente || '__________'}</p>
                  <p className="mt-1.5"><strong>Assinatura:</strong></p>
                  <p className="border-b border-gray-500 mt-0.5 pb-4 italic text-[9px]">{formData.assinatura_cliente}</p>
                </div>
              </div>
            </div>
          </section>
        </div>
      </div>

      {/* Estilos para impressão */}
      <style>{`
        @media print {
          /* ESCONDER TUDO PRIMEIRO */
          body > * {
            display: none !important;
          }

          /* Esconder interface de edição */
          .print\\:hidden {
            display: none !important;
          }

          /* Configuração da página */
          body {
            margin: 0 !important;
            padding: 0 !important;
            background: white !important;
          }

          @page {
            size: A4 portrait;
            margin: 0.7cm;
          }

          /* MOSTRAR APENAS O CONTAINER DO LAUDO */
          body > div {
            display: block !important;
          }

          body > div > * {
            display: none !important;
          }

          /* Container do laudo */
          .laudo-impressao {
            display: block !important;
            visibility: visible !important;
            width: 100% !important;
            max-width: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
            font-size: 9px !important;
            line-height: 1.1 !important;
            color: black !important;
            background: white !important;
          }

          /* Garantir que elementos internos apareçam */
          .laudo-impressao * {
            display: revert !important;
            visibility: visible !important;
            color: black !important;
          }

          /* Manter grids funcionando */
          .laudo-impressao .grid {
            display: grid !important;
          }

          .laudo-impressao .grid-cols-2 {
            grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
          }

          .laudo-impressao .grid-cols-3 {
            grid-template-columns: repeat(3, minmax(0, 1fr)) !important;
          }

          .laudo-impressao .grid-cols-4 {
            grid-template-columns: repeat(4, minmax(0, 1fr)) !important;
          }

          /* Evitar quebra de página */
          .laudo-impressao section {
            page-break-inside: avoid !important;
            break-inside: avoid !important;
          }

          /* Cores para impressão */
          * {
            -webkit-print-color-adjust: exact !important;
            print-color-adjust: exact !important;
            color-adjust: exact !important;
          }

          /* Ajustar tamanhos */
          .laudo-impressao h1 {
            font-size: 14px !important;
            margin-bottom: 2px !important;
          }

          .laudo-impressao h2 {
            font-size: 9px !important;
            margin-bottom: 2px !important;
            padding: 2px 4px !important;
          }

          .laudo-impressao p,
          .laudo-impressao div {
            font-size: 8px !important;
            line-height: 1.1 !important;
          }

          .laudo-impressao section {
            margin-bottom: 4px !important;
          }

          /* Bordas */
          .laudo-impressao .border-b-2 {
            border-bottom: 2px solid #000 !important;
          }

          .laudo-impressao .border {
            border: 1px solid #666 !important;
          }

          .laudo-impressao .bg-gray-200 {
            background-color: #e5e7eb !important;
          }

          /* Esconder menu, header, sidebar, etc */
          header, nav, aside, [role="navigation"], [class*="sidebar"], [class*="menu"], [class*="header"] {
            display: none !important;
          }
        }

        /* Esconder laudo na tela normal */
        .laudo-impressao {
          display: none;
        }

        @media print {
          .laudo-impressao {
            display: block !important;
          }
        }
      `}</style>
    </>
  );
};

export default LaudoTecnicoPage;
