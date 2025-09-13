import { useState, useEffect } from 'react';
import { 
  Download, 
  Calendar, 
  TrendingUp, 
  TrendingDown, 
  Eye,
  Filter,
  X,
  FileText,
  ArrowLeft
} from 'lucide-react';
import { Link } from 'react-router-dom';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { formatCurrency, formatDate, formatDateTime } from '../utils/format';
import { toast } from 'react-hot-toast';
import jsPDF from 'jspdf';
import 'jspdf-autotable';
import { caixaService } from '../services/caixaService';
import type { CaixaCompleto } from '../types/caixa';

interface FiltrosHistorico {
  dataInicio: string;
  dataFim: string;
  status: 'todos' | 'aberto' | 'fechado';
}

export function HistoricoCaixaPage() {
  const [historico, setHistorico] = useState<CaixaCompleto[]>([]);
  const [loading, setLoading] = useState(true);
  const [filtros, setFiltros] = useState<FiltrosHistorico>({
    dataInicio: '',
    dataFim: '',
    status: 'todos'
  });
  const [mostrarFiltros, setMostrarFiltros] = useState(false);
  const [detalheSelecionado, setDetalheSelecionado] = useState<CaixaCompleto | null>(null);

  useEffect(() => {
    carregarHistorico();
  }, []);

  const carregarHistorico = async () => {
    try {
      setLoading(true);
      
      const filtrosCaixa = {
        data_inicio: filtros.dataInicio || undefined,
        data_fim: filtros.dataFim || undefined,
        status: filtros.status === 'todos' ? undefined : filtros.status
      };

      const dados = await caixaService.buscarHistorico(filtrosCaixa);
      setHistorico(dados);
    } catch (error) {
      console.error('Erro ao carregar histórico:', error);
      toast.error('Erro ao carregar histórico do caixa');
    } finally {
      setLoading(false);
    }
  };

  const aplicarFiltros = () => {
    carregarHistorico();
    setMostrarFiltros(false);
    toast.success('Filtros aplicados');
  };

  const limparFiltros = () => {
    setFiltros({
      dataInicio: '',
      dataFim: '',
      status: 'todos'
    });
    carregarHistorico();
  };

  const gerarPDF = () => {
    try {
      const doc = new jsPDF();
      
      // Configuração do cabeçalho
      doc.setFontSize(20);
      doc.text('PDV Import - Histórico do Caixa', 20, 20);
      
      doc.setFontSize(12);
      doc.text(`Relatório gerado em: ${formatDateTime(new Date().toISOString())}`, 20, 30);
      
      // Preparar dados para a tabela
      const dadosTabela = historico.map(item => [
        formatDate(item.data_abertura),
        item.status === 'fechado' && item.data_fechamento ? formatDate(item.data_fechamento) : 'Em andamento',
        formatCurrency(item.valor_inicial),
        item.status === 'fechado' && item.valor_final ? formatCurrency(item.valor_final) : '-',
        item.status === 'fechado' && item.diferenca !== undefined ? formatCurrency(item.diferenca) : '-',
        item.status === 'fechado' ? 'Fechado' : 'Aberto'
      ]);

      // Criar tabela
      (doc as any).autoTable({
        head: [['Data Abertura', 'Data Fechamento', 'Valor Inicial', 'Valor Final', 'Diferença', 'Status']],
        body: dadosTabela,
        startY: 40,
        styles: { fontSize: 8 },
        headStyles: { fillColor: [255, 165, 0] },
        columnStyles: {
          2: { halign: 'right' },
          3: { halign: 'right' },
          4: { halign: 'right' }
        }
      });

      // Adicionar resumo
      const totalCaixasFechados = historico.filter(h => h.status === 'fechado').length;
      const somaValorInicial = historico.reduce((sum, h) => sum + h.valor_inicial, 0);
      const somaValorFinal = historico
        .filter(h => h.status === 'fechado' && h.valor_final)
        .reduce((sum, h) => sum + (h.valor_final || 0), 0);
      
      const finalY = (doc as any).lastAutoTable.finalY || 100;
      doc.text('Resumo:', 20, finalY + 20);
      doc.text(`Total de caixas: ${historico.length}`, 20, finalY + 30);
      doc.text(`Caixas fechados: ${totalCaixasFechados}`, 20, finalY + 40);
      doc.text(`Soma valor inicial: ${formatCurrency(somaValorInicial)}`, 20, finalY + 50);
      doc.text(`Soma valor final: ${formatCurrency(somaValorFinal)}`, 20, finalY + 60);

      doc.save(`historico-caixa-${new Date().toISOString().split('T')[0]}.pdf`);
      toast.success('PDF gerado com sucesso!');
    } catch (error) {
      console.error('Erro ao gerar PDF:', error);
      toast.error('Erro ao gerar PDF');
    }
  };

  const calcularResumo = () => {
    const totalCaixas = historico.length;
    const caixasFechados = historico.filter(h => h.status === 'fechado').length;
    const somaInicial = historico.reduce((sum, h) => sum + h.valor_inicial, 0);
    const somaFinal = historico
      .filter(h => h.status === 'fechado' && h.valor_final)
      .reduce((sum, h) => sum + (h.valor_final || 0), 0);
    const totalMovimentacao = somaFinal - somaInicial;

    return {
      totalCaixas,
      caixasFechados,
      somaInicial,
      somaFinal,
      totalMovimentacao
    };
  };

  const resumo = calcularResumo();

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500 mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando histórico...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-4">
              <Link 
                to="/caixa" 
                className="flex items-center space-x-2 text-gray-600 hover:text-orange-600 transition-colors"
              >
                <ArrowLeft className="w-4 h-4" />
                <span>Caixa</span>
              </Link>
              <div className="h-8 border-l border-gray-300"></div>
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-orange-600 rounded-lg flex items-center justify-center">
                  <FileText className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h1 className="text-xl font-bold text-gray-900">Histórico do Caixa</h1>
                  <p className="text-sm text-gray-600">Movimentações e fechamentos</p>
                </div>
              </div>
            </div>
            
            <div className="flex items-center space-x-3">
              <Button
                onClick={() => setMostrarFiltros(!mostrarFiltros)}
                variant="outline"
                className="gap-2"
              >
                <Filter className="w-4 h-4" />
                Filtros
              </Button>
              
              <Button
                onClick={gerarPDF}
                className="gap-2 bg-orange-500 hover:bg-orange-600"
              >
                <Download className="w-4 h-4" />
                Baixar PDF
              </Button>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Filtros */}
        {mostrarFiltros && (
          <Card className="mb-6 p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Filtros</h3>
              <Button
                onClick={() => setMostrarFiltros(false)}
                variant="outline"
                size="sm"
              >
                <X className="w-4 h-4" />
              </Button>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Data Início
                </label>
                <input
                  type="date"
                  value={filtros.dataInicio}
                  onChange={(e) => setFiltros({ ...filtros, dataInicio: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-500 focus:border-orange-500"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Data Fim
                </label>
                <input
                  type="date"
                  value={filtros.dataFim}
                  onChange={(e) => setFiltros({ ...filtros, dataFim: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-500 focus:border-orange-500"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Status
                </label>
                <select
                  value={filtros.status}
                  onChange={(e) => setFiltros({ ...filtros, status: e.target.value as any })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-500 focus:border-orange-500"
                >
                  <option value="todos">Todos</option>
                  <option value="aberto">Aberto</option>
                  <option value="fechado">Fechado</option>
                </select>
              </div>
              
              <div className="flex items-end space-x-2">
                <Button onClick={aplicarFiltros} className="flex-1">
                  Aplicar
                </Button>
                <Button onClick={limparFiltros} variant="outline">
                  Limpar
                </Button>
              </div>
            </div>
          </Card>
        )}

        {/* Resumo */}
        <div className="grid grid-cols-1 md:grid-cols-5 gap-6 mb-8">
          <Card className="p-6 bg-gradient-to-br from-blue-500 to-blue-600 text-white">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-blue-100 text-sm">Total de Caixas</p>
                <p className="text-2xl font-bold">{resumo.totalCaixas}</p>
              </div>
              <FileText className="w-8 h-8 text-blue-200" />
            </div>
          </Card>

          <Card className="p-6 bg-gradient-to-br from-green-500 to-green-600 text-white">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-green-100 text-sm">Caixas Fechados</p>
                <p className="text-2xl font-bold">{resumo.caixasFechados}</p>
              </div>
              <Calendar className="w-8 h-8 text-green-200" />
            </div>
          </Card>

          <Card className="p-6 bg-gradient-to-br from-yellow-500 to-yellow-600 text-white">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-yellow-100 text-sm">Valor Inicial Total</p>
                <p className="text-2xl font-bold">{formatCurrency(resumo.somaInicial)}</p>
              </div>
              <TrendingUp className="w-8 h-8 text-yellow-200" />
            </div>
          </Card>

          <Card className="p-6 bg-gradient-to-br from-purple-500 to-purple-600 text-white">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-purple-100 text-sm">Valor Final Total</p>
                <p className="text-2xl font-bold">{formatCurrency(resumo.somaFinal)}</p>
              </div>
              <TrendingDown className="w-8 h-8 text-purple-200" />
            </div>
          </Card>

          <Card className={`p-6 ${resumo.totalMovimentacao >= 0 ? 'bg-gradient-to-br from-green-500 to-green-600' : 'bg-gradient-to-br from-red-500 to-red-600'} text-white`}>
            <div className="flex items-center justify-between">
              <div>
                <p className={`${resumo.totalMovimentacao >= 0 ? 'text-green-100' : 'text-red-100'} text-sm`}>
                  Movimentação Total
                </p>
                <p className="text-2xl font-bold">{formatCurrency(resumo.totalMovimentacao)}</p>
              </div>
              {resumo.totalMovimentacao >= 0 ? (
                <TrendingUp className="w-8 h-8 text-green-200" />
              ) : (
                <TrendingDown className="w-8 h-8 text-red-200" />
              )}
            </div>
          </Card>
        </div>

        {/* Lista do Histórico */}
        <Card className="overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-semibold text-gray-900">
              Histórico de Movimentações ({historico.length} registros)
            </h3>
          </div>
          
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Data Abertura
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Data Fechamento
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Valor Inicial
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Valor Final
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Diferença
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ações
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {historico.map((item) => (
                  <tr key={item.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {formatDateTime(item.data_abertura)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {item.status === 'fechado' && item.data_fechamento ? formatDateTime(item.data_fechamento) : '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {formatCurrency(item.valor_inicial)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {item.status === 'fechado' && item.valor_final ? formatCurrency(item.valor_final) : '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm">
                      {item.status === 'fechado' && item.diferenca !== undefined ? (
                        <span className={`${item.diferenca >= 0 ? 'text-green-600' : 'text-red-600'} font-medium`}>
                          {formatCurrency(item.diferenca)}
                        </span>
                      ) : '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        item.status === 'fechado' 
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-yellow-100 text-yellow-800'
                      }`}>
                        {item.status === 'fechado' ? 'Fechado' : 'Aberto'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <Button
                        onClick={() => setDetalheSelecionado(item)}
                        size="sm"
                        variant="outline"
                        className="gap-2"
                      >
                        <Eye className="w-4 h-4" />
                        Detalhes
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          
          {historico.length === 0 && (
            <div className="p-8 text-center">
              <FileText className="w-12 h-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-500">Nenhum registro encontrado</p>
            </div>
          )}
        </Card>
      </main>

      {/* Modal de Detalhes */}
      {detalheSelecionado && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <Card className="w-full max-w-2xl max-h-[80vh] overflow-y-auto">
            <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
              <h3 className="text-lg font-semibold text-gray-900">
                Detalhes do Caixa - {formatDate(detalheSelecionado.data_abertura)}
              </h3>
              <Button
                onClick={() => setDetalheSelecionado(null)}
                variant="outline"
                size="sm"
              >
                <X className="w-4 h-4" />
              </Button>
            </div>
            
            <div className="p-6">
              <div className="grid grid-cols-2 gap-4 mb-6">
                <div>
                  <p className="text-sm text-gray-500">Valor Inicial</p>
                  <p className="text-lg font-semibold">{formatCurrency(detalheSelecionado.valor_inicial)}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Valor Final</p>
                  <p className="text-lg font-semibold">
                    {detalheSelecionado.status === 'fechado' && detalheSelecionado.valor_final 
                      ? formatCurrency(detalheSelecionado.valor_final) 
                      : '-'}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Data Abertura</p>
                  <p className="text-lg font-semibold">{formatDateTime(detalheSelecionado.data_abertura)}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Data Fechamento</p>
                  <p className="text-lg font-semibold">
                    {detalheSelecionado.status === 'fechado' && detalheSelecionado.data_fechamento 
                      ? formatDateTime(detalheSelecionado.data_fechamento) 
                      : 'Em andamento'}
                  </p>
                </div>
              </div>

              {detalheSelecionado.observacoes && (
                <div className="mb-6">
                  <p className="text-sm text-gray-500 mb-1">Observações</p>
                  <p className="text-gray-900">{detalheSelecionado.observacoes}</p>
                </div>
              )}

              <div>
                <h4 className="text-md font-semibold text-gray-900 mb-3">
                  Movimentações ({detalheSelecionado.movimentacoes_caixa?.length || 0})
                </h4>
                
                {detalheSelecionado.movimentacoes_caixa && detalheSelecionado.movimentacoes_caixa.length > 0 ? (
                  <div className="space-y-2">
                    {detalheSelecionado.movimentacoes_caixa.map((mov) => (
                      <div key={mov.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                        <div className="flex items-center space-x-3">
                          <div className={`w-3 h-3 rounded-full ${
                            mov.tipo === 'entrada' ? 'bg-green-500' : 'bg-red-500'
                          }`}></div>
                          <div>
                            <p className="font-medium text-gray-900">{mov.descricao}</p>
                            <p className="text-sm text-gray-500">{formatDateTime(mov.data)}</p>
                          </div>
                        </div>
                        <span className={`font-semibold ${
                          mov.tipo === 'entrada' ? 'text-green-600' : 'text-red-600'
                        }`}>
                          {mov.tipo === 'entrada' ? '+' : '-'}{formatCurrency(mov.valor)}
                        </span>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-gray-500 text-center py-4">Nenhuma movimentação registrada</p>
                )}
              </div>
            </div>
          </Card>
        </div>
      )}
    </div>
  );
}
