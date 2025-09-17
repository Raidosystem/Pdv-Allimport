// Build a professional PDV reporting section.
// Include global filters (date range, store, channel, seller, category, payment).
// Show skeleton states, empty states and error states.
// Wire navigation to other sections preserving filters via URL params.
// Track events with the given event ids.

import React, { useState, useEffect } from "react";
import { Download, FileText, Mail, Clock, CheckCircle, AlertCircle, Loader } from "lucide-react";

// ===== Helper: Filters (same as overview) =====
type FilterState = {
  period: string;
  start?: string;
  end?: string;
  channel?: string;
  seller?: string;
  category?: string;
  payment?: string;
  compare?: boolean;
};

function readFiltersFromURL(): FilterState {
  const sp = new URLSearchParams(window.location.search);
  return {
    period: sp.get("period") || "30d",
    start: sp.get("start") || undefined,
    end: sp.get("end") || undefined,
    channel: sp.get("channel") || undefined,
    seller: sp.get("seller") || undefined,
    category: sp.get("category") || undefined,
    payment: sp.get("payment") || undefined,
    compare: sp.get("compare") === "1",
  };
}

function useFilters() {
  const [filters, setFilters] = useState<FilterState>(() => readFiltersFromURL());
  return { filters, setFilters } as const;
}

// ===== Types =====
type ExportFormat = 'pdf' | 'excel' | 'csv' | 'json';
type ExportType = 'vendas' | 'produtos' | 'clientes' | 'financeiro' | 'ordens' | 'completo';
type ExportStatus = 'idle' | 'generating' | 'ready' | 'failed';

interface ExportJob {
  id: string;
  type: ExportType;
  format: ExportFormat;
  filters: FilterState;
  status: ExportStatus;
  created: Date;
  completed?: Date;
  size?: string;
  downloadUrl?: string;
}

// ===== Mock Data =====
const mockExportHistory: ExportJob[] = [
  {
    id: "exp-001",
    type: "vendas",
    format: "excel",
    filters: { period: "30d" },
    status: "ready",
    created: new Date("2025-09-22T14:30:00"),
    completed: new Date("2025-09-22T14:32:15"),
    size: "2.4 MB",
    downloadUrl: "#"
  },
  {
    id: "exp-002", 
    type: "produtos",
    format: "pdf",
    filters: { period: "7d", category: "eletronicos" },
    status: "ready",
    created: new Date("2025-09-22T10:15:00"),
    completed: new Date("2025-09-22T10:17:30"),
    size: "1.8 MB",
    downloadUrl: "#"
  },
  {
    id: "exp-003",
    type: "completo", 
    format: "excel",
    filters: { period: "90d" },
    status: "generating",
    created: new Date("2025-09-22T15:45:00"),
    size: "Estimado: 8.5 MB"
  },
];

// ===== Export Templates =====
const exportTemplates = [
  {
    id: "vendas-resumo",
    name: "Vendas - Resumo Executivo",
    description: "Dashboard de vendas com KPIs principais",
    type: "vendas" as ExportType,
    defaultFormat: "pdf" as ExportFormat,
    estimatedSize: "1-3 MB",
    fields: ["Total de vendas", "Ticket médio", "Top produtos", "Performance por vendedor"]
  },
  {
    id: "vendas-detalhado",
    name: "Vendas - Relatório Detalhado", 
    description: "Todas as vendas linha por linha",
    type: "vendas" as ExportType,
    defaultFormat: "excel" as ExportFormat,
    estimatedSize: "2-15 MB",
    fields: ["Dados completos de cada venda", "Itens vendidos", "Formas de pagamento", "Comissões"]
  },
  {
    id: "produtos-estoque",
    name: "Produtos & Estoque",
    description: "Inventário completo com movimentações",
    type: "produtos" as ExportType,
    defaultFormat: "excel" as ExportFormat,
    estimatedSize: "1-5 MB",
    fields: ["Produtos ativos", "Estoque atual", "Movimentações", "Curva ABC"]
  },
  {
    id: "clientes-base",
    name: "Base de Clientes",
    description: "Cadastro e histórico de compras",
    type: "clientes" as ExportType,
    defaultFormat: "excel" as ExportFormat,
    estimatedSize: "500KB - 3MB",
    fields: ["Dados pessoais", "Histórico de compras", "Segmentação", "Últimas interações"]
  },
  {
    id: "financeiro-completo",
    name: "Financeiro Completo",
    description: "DRE, fluxo de caixa e análises",
    type: "financeiro" as ExportType,
    defaultFormat: "pdf" as ExportFormat,
    estimatedSize: "2-8 MB",
    fields: ["Receitas e despesas", "Fluxo de caixa", "Contas a receber/pagar", "Margens"]
  },
  {
    id: "ordens-servico",
    name: "Ordens de Serviço",
    description: "Relatório completo de ordens de serviço",
    type: "ordens" as ExportType,
    defaultFormat: "excel" as ExportFormat,
    estimatedSize: "1-10 MB",
    fields: ["Status das OS", "Equipamentos", "Defeitos", "Valores", "Clientes", "Técnicos"]
  },
];

// ===== Export Card Component =====
interface ExportCardProps {
  template: typeof exportTemplates[0];
  onGenerate: (templateId: string, format: ExportFormat) => void;
  loading?: boolean;
}

const ExportCard: React.FC<ExportCardProps> = ({ template, onGenerate, loading }) => {
  const [selectedFormat, setSelectedFormat] = useState<ExportFormat>(template.defaultFormat);

  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-blue-100 rounded-lg">
            <FileText className="w-5 h-5 text-blue-600" />
          </div>
          <div>
            <h3 className="font-semibold text-gray-900">{template.name}</h3>
            <p className="text-sm text-gray-600">{template.description}</p>
          </div>
        </div>
      </div>

      <div className="space-y-3 mb-4">
        <div className="text-sm text-gray-600">
          <strong>Inclui:</strong>
          <ul className="mt-1 space-y-1">
            {template.fields.map((field, index) => (
              <li key={index} className="flex items-center gap-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                {field}
              </li>
            ))}
          </ul>
        </div>
        
        <div className="text-sm text-gray-500">
          Tamanho estimado: {template.estimatedSize}
        </div>
      </div>

      <div className="flex items-center gap-3">
        <select
          value={selectedFormat}
          onChange={(e) => setSelectedFormat(e.target.value as ExportFormat)}
          className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm"
        >
          <option value="pdf">📄 PDF</option>
          <option value="excel">📊 Excel</option>
          <option value="csv">📋 CSV</option>
          <option value="json">🔗 JSON</option>
        </select>
        
        <button
          onClick={() => onGenerate(template.id, selectedFormat)}
          disabled={loading}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center gap-2 text-sm"
        >
          {loading ? <Loader className="w-4 h-4 animate-spin" /> : <Download className="w-4 h-4" />}
          Gerar
        </button>
      </div>
    </div>
  );
};

// ===== Main Component =====
const ReportsExportsPage: React.FC = () => {
  const { filters, setFilters } = useFilters();
  const [loading, setLoading] = useState(false);
  const [exportHistory, setExportHistory] = useState<ExportJob[]>(mockExportHistory);
  const [generatingId, setGeneratingId] = useState<string | null>(null);
  const [autoEmail, setAutoEmail] = useState(false);
  const [emailRecipient, setEmailRecipient] = useState("");

  // Simulate loading
  useEffect(() => {
    setLoading(true);
    const timer = setTimeout(() => setLoading(false), 800);
    return () => clearTimeout(timer);
  }, [filters]);

  const handleGenerate = (templateId: string, format: ExportFormat) => {
    console.log('exports_generate_report', { templateId, format, filters });
    
    setGeneratingId(templateId);
    
    // Simulate export generation
    setTimeout(() => {
      const newJob: ExportJob = {
        id: `exp-${Date.now()}`,
        type: exportTemplates.find(t => t.id === templateId)?.type || 'vendas',
        format,
        filters: { ...filters },
        status: 'ready',
        created: new Date(),
        completed: new Date(),
        size: `${(Math.random() * 5 + 1).toFixed(1)} MB`,
        downloadUrl: "#"
      };
      
      setExportHistory(prev => [newJob, ...prev]);
      setGeneratingId(null);
      
      if (autoEmail && emailRecipient) {
        console.log('exports_auto_email', { email: emailRecipient, jobId: newJob.id });
      }
    }, 2000);
  };

  const handleDownload = (job: ExportJob) => {
    console.log('exports_download', { jobId: job.id, type: job.type, format: job.format });
    // Simulate download
    const link = document.createElement('a');
    link.href = job.downloadUrl || '#';
    link.download = `relatorio-${job.type}-${job.format}-${job.id}.${job.format}`;
    link.click();
  };

  const handleBulkExport = () => {
    console.log('exports_bulk_generate', { filters });
    alert('Gerando pacote completo de relatórios...');
  };

  const getStatusIcon = (status: ExportStatus) => {
    switch (status) {
      case 'generating': return <Loader className="w-4 h-4 animate-spin text-blue-500" />;
      case 'ready': return <CheckCircle className="w-4 h-4 text-green-500" />;
      case 'failed': return <AlertCircle className="w-4 h-4 text-red-500" />;
      default: return <Clock className="w-4 h-4 text-gray-400" />;
    }
  };

  const getStatusText = (status: ExportStatus) => {
    switch (status) {
      case 'generating': return 'Gerando...';
      case 'ready': return 'Pronto';
      case 'failed': return 'Erro';
      default: return 'Aguardando';
    }
  };

  // Loading skeleton
  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="h-64 bg-gray-200 rounded-xl"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">📤 Exportações</h1>
          <p className="text-gray-600">Gere e baixe relatórios personalizados</p>
        </div>
        
        <button
          onClick={handleBulkExport}
          className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
        >
          <Download className="w-4 h-4" />
          Pacote Completo
        </button>
      </div>

      {/* Global Settings */}
      <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-200">
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-semibold text-gray-900">Configurações Globais</h3>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-4">
          <select
            value={filters.period}
            onChange={(e) => setFilters({ ...filters, period: e.target.value })}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
          >
            <option value="7d">Últimos 7 dias</option>
            <option value="30d">Últimos 30 dias</option>
            <option value="90d">Últimos 90 dias</option>
            <option value="1y">Último ano</option>
          </select>

          <select
            value={filters.seller || ''}
            onChange={(e) => setFilters({ ...filters, seller: e.target.value || undefined })}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
          >
            <option value="">Todos Vendedores</option>
            <option value="maria">Maria Santos</option>
            <option value="pedro">Pedro Lima</option>
          </select>

          <select
            value={filters.category || ''}
            onChange={(e) => setFilters({ ...filters, category: e.target.value || undefined })}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
          >
            <option value="">Todas Categorias</option>
            <option value="eletronicos">Eletrônicos</option>
            <option value="informatica">Informática</option>
          </select>
        </div>

        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2">
            <input
              type="checkbox"
              id="auto-email"
              checked={autoEmail}
              onChange={(e) => setAutoEmail(e.target.checked)}
              className="rounded border-gray-300"
            />
            <label htmlFor="auto-email" className="text-sm text-gray-700">
              Enviar por email automaticamente
            </label>
          </div>
          
          {autoEmail && (
            <input
              type="email"
              placeholder="email@exemplo.com"
              value={emailRecipient}
              onChange={(e) => setEmailRecipient(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm"
            />
          )}
        </div>
      </div>

      {/* Export Templates */}
      <div>
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Modelos de Relatório</h2>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {exportTemplates.map((template) => (
            <ExportCard
              key={template.id}
              template={template}
              onGenerate={handleGenerate}
              loading={generatingId === template.id}
            />
          ))}
        </div>
      </div>

      {/* Export History */}
      <div>
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Histórico de Exportações</h2>
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-6 py-3 text-left font-semibold text-gray-900">Status</th>
                  <th className="px-6 py-3 text-left font-semibold text-gray-900">Tipo</th>
                  <th className="px-6 py-3 text-left font-semibold text-gray-900">Formato</th>
                  <th className="px-6 py-3 text-left font-semibold text-gray-900">Criado</th>
                  <th className="px-6 py-3 text-left font-semibold text-gray-900">Tamanho</th>
                  <th className="px-6 py-3 text-center font-semibold text-gray-900">Ações</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {exportHistory.map((job) => (
                  <tr key={job.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        {getStatusIcon(job.status)}
                        <span className="text-sm font-medium text-gray-900">
                          {getStatusText(job.status)}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="capitalize text-sm text-gray-900">{job.type}</span>
                    </td>
                    <td className="px-6 py-4">
                      <span className="uppercase text-sm font-mono text-gray-600">{job.format}</span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">
                      {job.created.toLocaleString('pt-BR')}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">
                      {job.size}
                    </td>
                    <td className="px-6 py-4 text-center">
                      {job.status === 'ready' ? (
                        <div className="flex items-center justify-center gap-2">
                          <button
                            onClick={() => handleDownload(job)}
                            className="text-blue-600 hover:text-blue-800 transition-colors"
                          >
                            <Download className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => console.log('exports_share', { jobId: job.id })}
                            className="text-gray-600 hover:text-gray-800 transition-colors"
                          >
                            <Mail className="w-4 h-4" />
                          </button>
                        </div>
                      ) : job.status === 'generating' ? (
                        <span className="text-sm text-gray-500">Processando...</span>
                      ) : (
                        <span className="text-sm text-red-500">Erro</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Empty State */}
      {exportHistory.length === 0 && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-12 text-center">
          <div className="text-gray-400 text-6xl mb-4">📤</div>
          <div className="text-gray-600 text-lg font-semibold mb-2">Nenhuma exportação realizada</div>
          <p className="text-gray-500 mb-4">Gere seu primeiro relatório usando os modelos acima.</p>
        </div>
      )}
    </div>
  );
};

export default ReportsExportsPage;