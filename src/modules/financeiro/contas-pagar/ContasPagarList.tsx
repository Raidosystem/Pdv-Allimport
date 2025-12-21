import React, { useState, useEffect } from 'react';
import {
  Plus,
  Search,
  Filter,
  Download,
  CheckCircle,
  XCircle,
  Clock,
  AlertCircle,
  Edit,
  Trash2,
  FileText,
  DollarSign,
  ArrowLeft
} from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import type { ContaPagar, ContaPagarFilters } from './api';
import {
  getContasPagar,
  pagarConta,
  deleteContaPagar,
  getEstatisticasContas
} from './api';
import ContaPagarForm from './ContaPagarForm';

interface ContasPagarListProps {
  isModal?: boolean;
  onClose?: () => void;
}

const ContasPagarList: React.FC<ContasPagarListProps> = ({ isModal = false, onClose }) => {
  const navigate = useNavigate();

  // Função para voltar
  const handleVoltar = () => {
    if (onClose) {
      onClose();
    } else {
      navigate('/caixa');
    }
  };
  const [contas, setContas] = useState<ContaPagar[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingConta, setEditingConta] = useState<ContaPagar | undefined>();
  const [showFilters, setShowFilters] = useState(false);
  
  // Filtros
  const [filters, setFilters] = useState<ContaPagarFilters>({});
  const [searchTerm, setSearchTerm] = useState('');
  
  // Estatísticas
  const [stats, setStats] = useState({
    total_pendentes: 0,
    total_pagas: 0,
    total_vencidas: 0,
    valor_pendente: 0,
    valor_pago: 0,
    valor_vencido: 0,
  });

  useEffect(() => {
    loadContas();
    loadStats();
  }, [filters]);

  const loadContas = async () => {
    setLoading(true);
    try {
      const data = await getContasPagar(filters);
      setContas(data);
    } catch (error) {
      console.error('Erro ao carregar contas:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadStats = async () => {
    try {
      const data = await getEstatisticasContas();
      setStats(data);
    } catch (error) {
      console.error('Erro ao carregar estatísticas:', error);
    }
  };

  const handlePagarConta = async (id: string) => {
    if (confirm('Confirma o pagamento desta conta?')) {
      try {
        await pagarConta(id);
        await loadContas();
        await loadStats();
      } catch (error) {
        console.error('Erro ao pagar conta:', error);
        alert('Erro ao registrar pagamento');
      }
    }
  };

  const handleDeleteConta = async (id: string) => {
    if (confirm('Tem certeza que deseja excluir esta conta?')) {
      try {
        await deleteContaPagar(id);
        await loadContas();
        await loadStats();
      } catch (error) {
        console.error('Erro ao excluir conta:', error);
        alert('Erro ao excluir conta');
      }
    }
  };

  const handleEditConta = (conta: ContaPagar) => {
    setEditingConta(conta);
    setShowForm(true);
  };

  const handleCloseForm = () => {
    setShowForm(false);
    setEditingConta(undefined);
  };

  const handleSaveForm = async () => {
    await loadContas();
    await loadStats();
  };

  const filteredContas = contas.filter(conta =>
    conta.fornecedor.toLowerCase().includes(searchTerm.toLowerCase()) ||
    conta.descricao.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'pago':
        return <CheckCircle className="w-5 h-5 text-green-600" />;
      case 'vencido':
        return <AlertCircle className="w-5 h-5 text-red-600" />;
      case 'pendente':
        return <Clock className="w-5 h-5 text-yellow-600" />;
      case 'cancelado':
        return <XCircle className="w-5 h-5 text-gray-600" />;
      default:
        return <Clock className="w-5 h-5 text-gray-600" />;
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case 'pago': return 'Pago';
      case 'vencido': return 'Vencido';
      case 'pendente': return 'Pendente';
      case 'cancelado': return 'Cancelado';
      default: return status;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pago': return 'bg-green-100 text-green-800';
      case 'vencido': return 'bg-red-100 text-red-800';
      case 'pendente': return 'bg-yellow-100 text-yellow-800';
      case 'cancelado': return 'bg-gray-100 text-gray-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  const formatDate = (date: string) => {
    return new Date(date + 'T00:00:00').toLocaleDateString('pt-BR');
  };

  return (
    <div className="p-6 space-y-6">
      {/* Header - Oculto quando em modal */}
      {!isModal && (
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <button
              onClick={handleVoltar}
              className="flex items-center gap-2 px-3 py-2 text-white bg-orange-500 hover:bg-orange-600 rounded-lg transition-colors border border-orange-600"
              title="Voltar para Controle de Caixa"
            >
              <ArrowLeft className="w-5 h-5" />
              <span className="font-medium">Voltar</span>
            </button>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Contas a Pagar</h1>
              <p className="text-gray-600">Gerencie boletos e pagamentos aos fornecedores</p>
            </div>
          </div>
          
          <button
            onClick={() => setShowForm(true)}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            <Plus className="w-4 h-4" />
            Nova Conta
          </button>
        </div>
      )}

      {/* Header alternativo para modal */}
      {isModal && (
        <div className="flex items-center justify-end">
          <button
            onClick={() => setShowForm(true)}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            <Plus className="w-4 h-4" />
            Nova Conta
          </button>
        </div>
      )}

      {/* Cards de Estatísticas */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Pendentes */}
        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Pendentes</p>
              <p className="text-2xl font-bold text-yellow-600 mt-1">
                {stats.total_pendentes}
              </p>
              <p className="text-sm text-gray-500 mt-1">
                {formatCurrency(stats.valor_pendente)}
              </p>
            </div>
            <Clock className="w-10 h-10 text-yellow-500" />
          </div>
        </div>

        {/* Vencidas */}
        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Vencidas</p>
              <p className="text-2xl font-bold text-red-600 mt-1">
                {stats.total_vencidas}
              </p>
              <p className="text-sm text-gray-500 mt-1">
                {formatCurrency(stats.valor_vencido)}
              </p>
            </div>
            <AlertCircle className="w-10 h-10 text-red-500" />
          </div>
        </div>

        {/* Pagas */}
        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Pagas</p>
              <p className="text-2xl font-bold text-green-600 mt-1">
                {stats.total_pagas}
              </p>
              <p className="text-sm text-gray-500 mt-1">
                {formatCurrency(stats.valor_pago)}
              </p>
            </div>
            <CheckCircle className="w-10 h-10 text-green-500" />
          </div>
        </div>
      </div>

      {/* Filtros e Busca */}
      <div className="bg-white rounded-lg border border-gray-200 p-4">
        <div className="flex items-center gap-4">
          {/* Busca */}
          <div className="flex-1">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Buscar por fornecedor ou descrição..."
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          </div>

          {/* Botão Filtros */}
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="flex items-center gap-2 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <Filter className="w-4 h-4" />
            Filtros
          </button>
        </div>

        {/* Painel de Filtros */}
        {showFilters && (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4 pt-4 border-t border-gray-200">
            {/* Status */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Status
              </label>
              <select
                value={filters.status || ''}
                onChange={(e) => setFilters({ ...filters, status: e.target.value || undefined })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">Todos</option>
                <option value="pendente">Pendente</option>
                <option value="vencido">Vencido</option>
                <option value="pago">Pago</option>
                <option value="cancelado">Cancelado</option>
              </select>
            </div>

            {/* Data Início */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Vencimento (De)
              </label>
              <input
                type="date"
                value={filters.data_inicio || ''}
                onChange={(e) => setFilters({ ...filters, data_inicio: e.target.value || undefined })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            {/* Data Fim */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Vencimento (Até)
              </label>
              <input
                type="date"
                value={filters.data_fim || ''}
                onChange={(e) => setFilters({ ...filters, data_fim: e.target.value || undefined })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          </div>
        )}
      </div>

      {/* Lista de Contas */}
      <div className="bg-white rounded-lg border border-gray-200">
        {loading ? (
          <div className="p-8">
            <div className="animate-pulse space-y-4">
              {[...Array(5)].map((_, i) => (
                <div key={i} className="h-20 bg-gray-200 rounded"></div>
              ))}
            </div>
          </div>
        ) : filteredContas.length === 0 ? (
          <div className="text-center py-12">
            <DollarSign className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              Nenhuma conta encontrada
            </h3>
            <p className="text-gray-500 mb-4">
              {searchTerm || filters.status 
                ? 'Tente ajustar os filtros de busca'
                : 'Comece adicionando uma nova conta a pagar'
              }
            </p>
            <button
              onClick={() => setShowForm(true)}
              className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              <Plus className="w-4 h-4" />
              Nova Conta
            </button>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Fornecedor/Descrição
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Categoria
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Vencimento
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Valor
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ações
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredContas.map((conta) => (
                  <tr key={conta.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div>
                        <div className="text-sm font-medium text-gray-900 flex items-center gap-2">
                          {conta.fornecedor}
                          {conta.boleto_url && (
                            <span title="Tem boleto anexado">
                              <FileText className="w-4 h-4 text-blue-600" />
                            </span>
                          )}
                        </div>
                        <div className="text-sm text-gray-500">{conta.descricao}</div>
                      </div>
                    </td>
                    
                    <td className="px-6 py-4">
                      <span className="text-sm text-gray-900">{conta.categoria}</span>
                    </td>
                    
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900">{formatDate(conta.data_vencimento)}</div>
                      {conta.data_pagamento && (
                        <div className="text-xs text-green-600">
                          Pago em {formatDate(conta.data_pagamento)}
                        </div>
                      )}
                    </td>
                    
                    <td className="px-6 py-4">
                      <span className="text-sm font-medium text-gray-900">
                        {formatCurrency(conta.valor)}
                      </span>
                    </td>
                    
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        {getStatusIcon(conta.status)}
                        <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(conta.status)}`}>
                          {getStatusText(conta.status)}
                        </span>
                      </div>
                    </td>
                    
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        {conta.status !== 'pago' && conta.status !== 'cancelado' && (
                          <button
                            onClick={() => handlePagarConta(conta.id)}
                            className="p-1 text-green-600 hover:text-green-800 transition-colors"
                            title="Registrar pagamento"
                          >
                            <CheckCircle className="w-5 h-5" />
                          </button>
                        )}
                        
                        <button
                          onClick={() => handleEditConta(conta)}
                          className="p-1 text-blue-600 hover:text-blue-800 transition-colors"
                          title="Editar"
                        >
                          <Edit className="w-5 h-5" />
                        </button>
                        
                        {conta.boleto_url && (
                          <a
                            href={conta.boleto_url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="p-1 text-purple-600 hover:text-purple-800 transition-colors"
                            title="Ver boleto"
                          >
                            <Download className="w-5 h-5" />
                          </a>
                        )}
                        
                        <button
                          onClick={() => handleDeleteConta(conta.id)}
                          className="p-1 text-red-600 hover:text-red-800 transition-colors"
                          title="Excluir"
                        >
                          <Trash2 className="w-5 h-5" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Modal de Formulário */}
      {showForm && (
        <ContaPagarForm
          conta={editingConta}
          onSave={handleSaveForm}
          onClose={handleCloseForm}
        />
      )}
    </div>
  );
};

export default ContasPagarList;
