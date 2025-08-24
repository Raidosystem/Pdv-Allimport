import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  ArrowLeft, 
  Calendar, 
  Filter, 
  Download, 
  Search,
  RefreshCw,
  Users,
  CreditCard,
  UserCheck
} from 'lucide-react';
import { format } from 'date-fns';

interface FilterData {
  dataInicial: string;
  dataFinal: string;
  funcionario: string;
  formaPagamento: string;
  tipoVenda: string;
}

interface ResultData {
  totalVendas: number;
  numeroPedidos: number;
  ticketMedio: number;
  vendas: Array<{
    id: string;
    data: string;
    cliente: string;
    total: number;
    formaPagamento: string;
    funcionario: string;
    tipo: string;
  }>;
}

const RelatoriosPeriodoPage: React.FC = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [filters, setFilters] = useState<FilterData>({
    dataInicial: format(new Date(), 'yyyy-MM-dd'),
    dataFinal: format(new Date(), 'yyyy-MM-dd'),
    funcionario: '',
    formaPagamento: '',
    tipoVenda: ''
  });

  const [results] = useState<ResultData>({
    totalVendas: 0,
    numeroPedidos: 0,
    ticketMedio: 0,
    vendas: []
  });

  const funcionarios: string[] = []; // Carregados do Supabase
  const formasPagamento = ['PIX', 'Cartão', 'Dinheiro'];
  const tiposVenda = ['Com Cliente', 'Avulsa'];

  const handleFilterChange = (field: keyof FilterData, value: string) => {
    setFilters(prev => ({ ...prev, [field]: value }));
  };

  const applyFilters = async () => {
    setLoading(true);
    // Simular busca com filtros
    setTimeout(() => {
      setLoading(false);
    }, 1500);
  };

  const exportData = (format: 'pdf' | 'excel' | 'csv') => {
    console.log(`Exportando dados em formato ${format}`);
    // Implementar exportação
  };

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center gap-4 mb-4">
            <button
              onClick={() => navigate('/relatorios')}
              className="flex items-center gap-2 text-gray-600 hover:text-gray-800"
            >
              <ArrowLeft className="h-5 w-5" />
              Voltar aos Relatórios
            </button>
          </div>
          
          <div className="flex items-center gap-3">
            <div className="p-3 bg-green-100 rounded-lg">
              <Calendar className="h-8 w-8 text-green-600" />
            </div>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Filtro por Período</h1>
              <p className="text-gray-600">Relatórios customizados com filtros avançados</p>
            </div>
          </div>
        </div>

        {/* Filtros */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200 mb-8">
          <div className="flex items-center gap-2 mb-6">
            <Filter className="h-5 w-5 text-gray-600" />
            <h3 className="text-lg font-semibold text-gray-900">Filtros de Busca</h3>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-6">
            {/* Data Inicial */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Data Inicial
              </label>
              <input
                type="date"
                value={filters.dataInicial}
                onChange={(e) => handleFilterChange('dataInicial', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              />
            </div>

            {/* Data Final */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Data Final
              </label>
              <input
                type="date"
                value={filters.dataFinal}
                onChange={(e) => handleFilterChange('dataFinal', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              />
            </div>

            {/* Funcionário */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Funcionário
              </label>
              <select
                value={filters.funcionario}
                onChange={(e) => handleFilterChange('funcionario', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              >
                <option value="">Todos os funcionários</option>
                {funcionarios.map(func => (
                  <option key={func} value={func}>{func}</option>
                ))}
              </select>
            </div>

            {/* Forma de Pagamento */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Forma de Pagamento
              </label>
              <select
                value={filters.formaPagamento}
                onChange={(e) => handleFilterChange('formaPagamento', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              >
                <option value="">Todas as formas</option>
                {formasPagamento.map(forma => (
                  <option key={forma} value={forma}>{forma}</option>
                ))}
              </select>
            </div>

            {/* Tipo de Venda */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tipo de Venda
              </label>
              <select
                value={filters.tipoVenda}
                onChange={(e) => handleFilterChange('tipoVenda', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              >
                <option value="">Todos os tipos</option>
                {tiposVenda.map(tipo => (
                  <option key={tipo} value={tipo}>{tipo}</option>
                ))}
              </select>
            </div>
          </div>

          <div className="flex flex-wrap gap-4">
            <button
              onClick={applyFilters}
              disabled={loading}
              className="flex items-center gap-2 px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
            >
              {loading ? (
                <RefreshCw className="h-4 w-4 animate-spin" />
              ) : (
                <Search className="h-4 w-4" />
              )}
              {loading ? 'Buscando...' : 'Aplicar Filtros'}
            </button>

            <button
              onClick={() => setFilters({
                dataInicial: format(new Date(), 'yyyy-MM-dd'),
                dataFinal: format(new Date(), 'yyyy-MM-dd'),
                funcionario: '',
                formaPagamento: '',
                tipoVenda: ''
              })}
              className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
            >
              Limpar Filtros
            </button>
          </div>
        </div>

        {/* Resumo dos Resultados */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <div className="flex items-center gap-3 mb-4">
              <div className="p-2 bg-green-100 rounded-lg">
                <CreditCard className="h-6 w-6 text-green-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600">Total de Vendas</p>
                <p className="text-2xl font-bold text-gray-900">{formatCurrency(results.totalVendas)}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <div className="flex items-center gap-3 mb-4">
              <div className="p-2 bg-blue-100 rounded-lg">
                <Users className="h-6 w-6 text-blue-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600">Número de Pedidos</p>
                <p className="text-2xl font-bold text-gray-900">{results.numeroPedidos}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <div className="flex items-center gap-3 mb-4">
              <div className="p-2 bg-purple-100 rounded-lg">
                <UserCheck className="h-6 w-6 text-purple-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600">Ticket Médio</p>
                <p className="text-2xl font-bold text-gray-900">{formatCurrency(results.ticketMedio)}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Tabela de Resultados */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-semibold text-gray-900">Resultados da Pesquisa</h3>
              <div className="flex gap-2">
                <button
                  onClick={() => exportData('pdf')}
                  className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
                >
                  <Download className="h-4 w-4" />
                  PDF
                </button>
                <button
                  onClick={() => exportData('excel')}
                  className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
                >
                  <Download className="h-4 w-4" />
                  Excel
                </button>
                <button
                  onClick={() => exportData('csv')}
                  className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                >
                  <Download className="h-4 w-4" />
                  CSV
                </button>
              </div>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Data/Hora
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Cliente
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Tipo
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Total
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Pagamento
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Funcionário
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {results.vendas.map((venda) => (
                  <tr key={venda.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {venda.data}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {venda.cliente}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                        venda.tipo === 'Com Cliente' 
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-orange-100 text-orange-800'
                      }`}>
                        {venda.tipo}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                      {formatCurrency(venda.total)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                        venda.formaPagamento === 'PIX' 
                          ? 'bg-blue-100 text-blue-800' 
                          : venda.formaPagamento === 'Cartão'
                          ? 'bg-purple-100 text-purple-800'
                          : 'bg-yellow-100 text-yellow-800'
                      }`}>
                        {venda.formaPagamento}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {venda.funcionario}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {results.vendas.length === 0 && (
            <div className="text-center py-12">
              <p className="text-gray-500">Nenhum resultado encontrado para os filtros selecionados.</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default RelatoriosPeriodoPage;
