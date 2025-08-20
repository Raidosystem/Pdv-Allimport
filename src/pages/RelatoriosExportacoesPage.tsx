import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  ArrowLeft, 
  Download, 
  FileText, 
  FileSpreadsheet,
  File,
  Mail,
  Printer,
  Calendar,
  Settings,
  CheckCircle,
  AlertCircle
} from 'lucide-react';
import { format } from 'date-fns';

interface ExportOptions {
  tipo: 'vendas' | 'clientes' | 'produtos' | 'os' | 'caixa' | 'completo';
  formato: 'pdf' | 'excel' | 'csv';
  periodo: {
    inicio: string;
    fim: string;
  };
  incluirDetalhes: boolean;
  incluirGraficos: boolean;
  enviarEmail: boolean;
  email?: string;
}

const RelatoriosExportacoesPage: React.FC = () => {
  const navigate = useNavigate();
  const [exportOptions, setExportOptions] = useState<ExportOptions>({
    tipo: 'vendas',
    formato: 'pdf',
    periodo: {
      inicio: format(new Date(), 'yyyy-MM-dd'),
      fim: format(new Date(), 'yyyy-MM-dd')
    },
    incluirDetalhes: true,
    incluirGraficos: true,
    enviarEmail: false,
    email: ''
  });

  const [exporting, setExporting] = useState(false);
  const [exportStatus, setExportStatus] = useState<{
    success: boolean;
    message: string;
  } | null>(null);

  const tiposRelatorio = [
    { id: 'vendas', label: 'Relatório de Vendas', icon: FileText },
    { id: 'clientes', label: 'Relatório de Clientes', icon: FileText },
    { id: 'produtos', label: 'Relatório de Produtos', icon: FileText },
    { id: 'os', label: 'Relatório de OS', icon: FileText },
    { id: 'caixa', label: 'Relatório de Caixa', icon: FileText },
    { id: 'completo', label: 'Relatório Completo', icon: FileText }
  ];

  const formatosExportacao = [
    { 
      id: 'pdf', 
      label: 'PDF', 
      icon: FileText, 
      color: 'bg-red-500',
      description: 'Formato ideal para impressão e visualização'
    },
    { 
      id: 'excel', 
      label: 'Excel (XLSX)', 
      icon: FileSpreadsheet, 
      color: 'bg-green-500',
      description: 'Planilha editável para análises avançadas'
    },
    { 
      id: 'csv', 
      label: 'CSV', 
      icon: File, 
      color: 'bg-blue-500',
      description: 'Formato universal para importação'
    }
  ];

  const handleExport = async () => {
    setExporting(true);
    setExportStatus(null);

    // Simular processo de exportação
    try {
      await new Promise(resolve => setTimeout(resolve, 3000));
      
      setExportStatus({
        success: true,
        message: `Relatório exportado com sucesso! ${exportOptions.enviarEmail ? 'E-mail enviado.' : 'Download iniciado.'}`
      });
    } catch (error) {
      setExportStatus({
        success: false,
        message: 'Erro ao exportar relatório. Tente novamente.'
      });
    } finally {
      setExporting(false);
    }
  };

  const updateExportOption = (key: keyof ExportOptions, value: any) => {
    setExportOptions(prev => ({ ...prev, [key]: value }));
  };

  const updatePeriodo = (key: 'inicio' | 'fim', value: string) => {
    setExportOptions(prev => ({
      ...prev,
      periodo: { ...prev.periodo, [key]: value }
    }));
  };

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center gap-4 mb-4">
            <button
              onClick={() => window.history.back()}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
            >
              <ArrowLeft className="h-5 w-5" />
              Voltar
            </button>
          </div>
          
          <div className="flex items-center gap-3">
            <div className="p-3 bg-indigo-100 rounded-lg">
              <Download className="h-8 w-8 text-indigo-600" />
            </div>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Exportações</h1>
              <p className="text-gray-600">Exporte relatórios em diferentes formatos</p>
            </div>
          </div>
        </div>

        <div className="space-y-8">
          {/* Tipo de Relatório */}
          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <div className="flex items-center gap-2 mb-4">
              <FileText className="h-5 w-5 text-gray-600" />
              <h3 className="text-lg font-semibold text-gray-900">Tipo de Relatório</h3>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {tiposRelatorio.map((tipo) => (
                <button
                  key={tipo.id}
                  onClick={() => updateExportOption('tipo', tipo.id)}
                  className={`p-4 rounded-lg border-2 transition-colors ${
                    exportOptions.tipo === tipo.id
                      ? 'border-indigo-500 bg-indigo-50'
                      : 'border-gray-200 hover:border-gray-300'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <tipo.icon className={`h-5 w-5 ${
                      exportOptions.tipo === tipo.id ? 'text-indigo-600' : 'text-gray-400'
                    }`} />
                    <span className={`font-medium ${
                      exportOptions.tipo === tipo.id ? 'text-indigo-900' : 'text-gray-700'
                    }`}>
                      {tipo.label}
                    </span>
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Formato de Exportação */}
          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <div className="flex items-center gap-2 mb-4">
              <Download className="h-5 w-5 text-gray-600" />
              <h3 className="text-lg font-semibold text-gray-900">Formato de Exportação</h3>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {formatosExportacao.map((formato) => (
                <button
                  key={formato.id}
                  onClick={() => updateExportOption('formato', formato.id)}
                  className={`p-6 rounded-lg border-2 transition-colors ${
                    exportOptions.formato === formato.id
                      ? 'border-indigo-500 bg-indigo-50'
                      : 'border-gray-200 hover:border-gray-300'
                  }`}
                >
                  <div className="text-center">
                    <div className={`w-12 h-12 ${formato.color} rounded-lg flex items-center justify-center mx-auto mb-3`}>
                      <formato.icon className="h-6 w-6 text-white" />
                    </div>
                    <h4 className={`font-semibold mb-2 ${
                      exportOptions.formato === formato.id ? 'text-indigo-900' : 'text-gray-900'
                    }`}>
                      {formato.label}
                    </h4>
                    <p className="text-sm text-gray-600">{formato.description}</p>
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Período */}
          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <div className="flex items-center gap-2 mb-4">
              <Calendar className="h-5 w-5 text-gray-600" />
              <h3 className="text-lg font-semibold text-gray-900">Período</h3>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Data Inicial
                </label>
                <input
                  type="date"
                  value={exportOptions.periodo.inicio}
                  onChange={(e) => updatePeriodo('inicio', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Data Final
                </label>
                <input
                  type="date"
                  value={exportOptions.periodo.fim}
                  onChange={(e) => updatePeriodo('fim', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                />
              </div>
            </div>
          </div>

          {/* Opções Avançadas */}
          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <div className="flex items-center gap-2 mb-4">
              <Settings className="h-5 w-5 text-gray-600" />
              <h3 className="text-lg font-semibold text-gray-900">Opções Avançadas</h3>
            </div>

            <div className="space-y-4">
              <label className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={exportOptions.incluirDetalhes}
                  onChange={(e) => updateExportOption('incluirDetalhes', e.target.checked)}
                  className="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                />
                <span className="text-gray-700">Incluir detalhes completos</span>
              </label>

              <label className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={exportOptions.incluirGraficos}
                  onChange={(e) => updateExportOption('incluirGraficos', e.target.checked)}
                  className="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                  disabled={exportOptions.formato === 'csv'}
                />
                <span className={`${exportOptions.formato === 'csv' ? 'text-gray-400' : 'text-gray-700'}`}>
                  Incluir gráficos e visualizações
                  {exportOptions.formato === 'csv' && (
                    <span className="text-xs text-gray-400 ml-2">(não disponível para CSV)</span>
                  )}
                </span>
              </label>

              <label className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={exportOptions.enviarEmail}
                  onChange={(e) => updateExportOption('enviarEmail', e.target.checked)}
                  className="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                />
                <span className="text-gray-700">Enviar por e-mail</span>
              </label>

              {exportOptions.enviarEmail && (
                <div className="ml-7">
                  <input
                    type="email"
                    placeholder="Digite o e-mail de destino"
                    value={exportOptions.email}
                    onChange={(e) => updateExportOption('email', e.target.value)}
                    className="w-full max-w-md px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  />
                </div>
              )}
            </div>
          </div>

          {/* Status da Exportação */}
          {exportStatus && (
            <div className={`p-4 rounded-lg border ${
              exportStatus.success 
                ? 'bg-green-50 border-green-200' 
                : 'bg-red-50 border-red-200'
            }`}>
              <div className="flex items-center gap-2">
                {exportStatus.success ? (
                  <CheckCircle className="h-5 w-5 text-green-600" />
                ) : (
                  <AlertCircle className="h-5 w-5 text-red-600" />
                )}
                <p className={`font-medium ${
                  exportStatus.success ? 'text-green-800' : 'text-red-800'
                }`}>
                  {exportStatus.message}
                </p>
              </div>
            </div>
          )}

          {/* Ações */}
          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <div className="flex flex-wrap gap-4">
              <button
                onClick={handleExport}
                disabled={exporting || (exportOptions.enviarEmail && !exportOptions.email)}
                className="flex items-center gap-2 px-6 py-3 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {exporting ? (
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                ) : (
                  <Download className="h-4 w-4" />
                )}
                {exporting ? 'Exportando...' : `Exportar ${formatosExportacao.find(f => f.id === exportOptions.formato)?.label}`}
              </button>

              <button
                onClick={() => window.print()}
                className="flex items-center gap-2 px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
              >
                <Printer className="h-4 w-4" />
                Imprimir Relatório
              </button>

              <button
                onClick={() => navigate('/relatorios/periodo')}
                className="flex items-center gap-2 px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
              >
                <Mail className="h-4 w-4" />
                Configurar Envio Automático
              </button>
            </div>

            <div className="mt-4 p-4 bg-gray-50 rounded-lg">
              <h4 className="font-medium text-gray-900 mb-2">Resumo da Exportação:</h4>
              <ul className="text-sm text-gray-600 space-y-1">
                <li>• Tipo: {tiposRelatorio.find(t => t.id === exportOptions.tipo)?.label}</li>
                <li>• Formato: {formatosExportacao.find(f => f.id === exportOptions.formato)?.label}</li>
                <li>• Período: {exportOptions.periodo.inicio} a {exportOptions.periodo.fim}</li>
                <li>• Detalhes: {exportOptions.incluirDetalhes ? 'Sim' : 'Não'}</li>
                <li>• Gráficos: {exportOptions.incluirGraficos ? 'Sim' : 'Não'}</li>
                <li>• Envio: {exportOptions.enviarEmail ? `E-mail (${exportOptions.email})` : 'Download direto'}</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RelatoriosExportacoesPage;
