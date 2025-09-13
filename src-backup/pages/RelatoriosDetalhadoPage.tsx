import React, { useState } from 'react';
import { 
  ArrowLeft, 
  FileText, 
  Eye, 
  Download, 
  Filter,
  Search,
  ChevronDown,
  ChevronUp
} from 'lucide-react';
import { format } from 'date-fns';

interface VendaDetalhada {
  id: string;
  data: string;
  cliente: string;
  tipo: 'Venda' | 'OS';
  total: number;
  formaPagamento: string;
  funcionario: string;
  status: string;
  itens: Array<{
    produto: string;
    quantidade: number;
    preco: number;
    total: number;
  }>;
}

const RelatoriosDetalhadoPage: React.FC = () => {
  const [expandedRow, setExpandedRow] = useState<string | null>(null);
  const [filters, setFilters] = useState({
    dataInicial: format(new Date(), 'yyyy-MM-dd'),
    dataFinal: format(new Date(), 'yyyy-MM-dd'),
    tipo: '',
    status: '',
    funcionario: ''
  });

  const vendasDetalhadas: VendaDetalhada[] = [];

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  const toggleRowExpansion = (id: string) => {
    setExpandedRow(expandedRow === id ? null : id);
  };

  const exportarPDF = () => {
    console.log('Exportando relatório detalhado em PDF');
    // Implementar exportação PDF
  };

  const exportarExcel = () => {
    console.log('Exportando relatório detalhado em Excel');
    // Implementar exportação Excel
  };

  const StatusBadge = ({ status, tipo }: { status: string; tipo: string }) => {
    const getStatusColor = () => {
      if (tipo === 'OS') {
        return status === 'Concluída' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800';
      }
      return status === 'Finalizada' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800';
    };

    return (
      <span className={`px-2 py-1 text-xs font-medium rounded-full ${getStatusColor()}`}>
        {status}
      </span>
    );
  };

  const TipoBadge = ({ tipo }: { tipo: string }) => (
    <span className={`px-2 py-1 text-xs font-medium rounded-full ${
      tipo === 'Venda' ? 'bg-blue-100 text-blue-800' : 'bg-purple-100 text-purple-800'
    }`}>
      {tipo}
    </span>
  );

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-7xl mx-auto">
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
          
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-3 bg-purple-100 rounded-lg">
                <FileText className="h-8 w-8 text-purple-600" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Relatório Detalhado</h1>
                <p className="text-gray-600">Listagem completa de vendas e ordens de serviço</p>
              </div>
            </div>

            <div className="flex gap-2">
              <button
                onClick={exportarPDF}
                className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
              >
                <Download className="h-4 w-4" />
                PDF
              </button>
              <button
                onClick={exportarExcel}
                className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
              >
                <Download className="h-4 w-4" />
                Excel
              </button>
            </div>
          </div>
        </div>

        {/* Filtros */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200 mb-8">
          <div className="flex items-center gap-2 mb-4">
            <Filter className="h-5 w-5 text-gray-600" />
            <h3 className="text-lg font-semibold text-gray-900">Filtros</h3>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Data Inicial</label>
              <input
                type="date"
                value={filters.dataInicial}
                onChange={(e) => setFilters({...filters, dataInicial: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Data Final</label>
              <input
                type="date"
                value={filters.dataFinal}
                onChange={(e) => setFilters({...filters, dataFinal: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Tipo</label>
              <select
                value={filters.tipo}
                onChange={(e) => setFilters({...filters, tipo: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500"
              >
                <option value="">Todos</option>
                <option value="Venda">Venda</option>
                <option value="OS">OS</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <select
                value={filters.status}
                onChange={(e) => setFilters({...filters, status: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500"
              >
                <option value="">Todos</option>
                <option value="Finalizada">Finalizada</option>
                <option value="Concluída">Concluída</option>
                <option value="Pendente">Pendente</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Funcionário</label>
              <select
                value={filters.funcionario}
                onChange={(e) => setFilters({...filters, funcionario: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500"
              >
                <option value="">Todos</option>
                {/* Funcionários carregados do Supabase */}
              </select>
            </div>
          </div>

          <div className="mt-4">
            <button className="flex items-center gap-2 px-6 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700">
              <Search className="h-4 w-4" />
              Aplicar Filtros
            </button>
          </div>
        </div>

        {/* Resumo */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <div className="text-center">
              <p className="text-2xl font-bold text-gray-900">{vendasDetalhadas.length}</p>
              <p className="text-sm text-gray-600">Total de registros</p>
            </div>
          </div>
          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <div className="text-center">
              <p className="text-2xl font-bold text-green-600">
                {formatCurrency(vendasDetalhadas.reduce((acc, venda) => acc + venda.total, 0))}
              </p>
              <p className="text-sm text-gray-600">Total geral</p>
            </div>
          </div>
          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <div className="text-center">
              <p className="text-2xl font-bold text-blue-600">
                {vendasDetalhadas.filter(v => v.tipo === 'Venda').length}
              </p>
              <p className="text-sm text-gray-600">Vendas</p>
            </div>
          </div>
          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <div className="text-center">
              <p className="text-2xl font-bold text-purple-600">
                {vendasDetalhadas.filter(v => v.tipo === 'OS').length}
              </p>
              <p className="text-sm text-gray-600">Ordens de Serviço</p>
            </div>
          </div>
        </div>

        {/* Tabela */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <h3 className="text-lg font-semibold text-gray-900">Detalhes das Operações</h3>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                    Data/Hora
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                    Cliente
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                    Tipo
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                    Total
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                    Pagamento
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                    Funcionário
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                    Ações
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {vendasDetalhadas.map((venda) => (
                  <React.Fragment key={venda.id}>
                    <tr className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {format(new Date(venda.data), 'dd/MM/yyyy HH:mm')}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {venda.cliente}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <TipoBadge tipo={venda.tipo} />
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                        {formatCurrency(venda.total)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {venda.formaPagamento}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {venda.funcionario}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <StatusBadge status={venda.status} tipo={venda.tipo} />
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm">
                        <div className="flex gap-2">
                          <button
                            onClick={() => toggleRowExpansion(venda.id)}
                            className="text-purple-600 hover:text-purple-900"
                          >
                            {expandedRow === venda.id ? (
                              <ChevronUp className="h-4 w-4" />
                            ) : (
                              <ChevronDown className="h-4 w-4" />
                            )}
                          </button>
                          <button className="text-blue-600 hover:text-blue-900">
                            <Eye className="h-4 w-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                    
                    {expandedRow === venda.id && (
                      <tr>
                        <td colSpan={8} className="px-6 py-4 bg-gray-50">
                          <div className="space-y-2">
                            <h4 className="font-semibold text-gray-900 mb-3">Itens:</h4>
                            <div className="space-y-2">
                              {venda.itens.map((item, index) => (
                                <div key={index} className="flex justify-between items-center p-3 bg-white rounded border">
                                  <div>
                                    <p className="font-medium text-gray-900">{item.produto}</p>
                                    <p className="text-sm text-gray-600">
                                      Qtd: {item.quantidade} x {formatCurrency(item.preco)}
                                    </p>
                                  </div>
                                  <div className="text-right">
                                    <p className="font-semibold text-gray-900">
                                      {formatCurrency(item.total)}
                                    </p>
                                  </div>
                                </div>
                              ))}
                            </div>
                          </div>
                        </td>
                      </tr>
                    )}
                  </React.Fragment>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RelatoriosDetalhadoPage;
