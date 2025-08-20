import React, { useState } from 'react';
import { 
  ArrowLeft, 
  Trophy, 
  Package, 
  Users, 
  FileText,
  TrendingUp,
  Medal,
  Crown,
  Star
} from 'lucide-react';

interface ProdutoRanking {
  id: string;
  nome: string;
  categoria: string;
  quantidadeVendida: number;
  totalVendas: number;
  lucro: number;
  posicao: number;
}

interface ClienteRanking {
  id: string;
  nome: string;
  email: string;
  totalCompras: number;
  numeroCompras: number;
  ticketMedio: number;
  posicao: number;
}

interface ServicoRanking {
  id: string;
  nome: string;
  categoria: string;
  numeroOs: number;
  valorMedio: number;
  totalFaturado: number;
  posicao: number;
}

const RelatoriosRankingPage: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'produtos' | 'clientes' | 'servicos'>('produtos');

  const produtosMaisVendidos: ProdutoRanking[] = [
    {
      id: '1',
      nome: 'Smartphone Samsung Galaxy A54',
      categoria: 'Celulares',
      quantidadeVendida: 45,
      totalVendas: 22500.00,
      lucro: 4500.00,
      posicao: 1
    },
    {
      id: '2',
      nome: 'Fone Bluetooth JBL',
      categoria: 'Acessórios',
      quantidadeVendida: 38,
      totalVendas: 3800.00,
      lucro: 1140.00,
      posicao: 2
    },
    {
      id: '3',
      nome: 'Carregador Turbo USB-C',
      categoria: 'Acessórios',
      quantidadeVendida: 67,
      totalVendas: 2010.00,
      lucro: 804.00,
      posicao: 3
    }
  ];

  const clientesTopCompras: ClienteRanking[] = [
    {
      id: '1',
      nome: 'Maria Silva Santos',
      email: 'maria.silva@email.com',
      totalCompras: 5420.00,
      numeroCompras: 12,
      ticketMedio: 451.67,
      posicao: 1
    },
    {
      id: '2',
      nome: 'João Carlos Oliveira',
      email: 'joao.carlos@email.com',
      totalCompras: 3890.50,
      numeroCompras: 8,
      ticketMedio: 486.31,
      posicao: 2
    },
    {
      id: '3',
      nome: 'Ana Paula Costa',
      email: 'ana.paula@email.com',
      totalCompras: 2750.00,
      numeroCompras: 15,
      ticketMedio: 183.33,
      posicao: 3
    }
  ];

  const servicosMaisSolicitados: ServicoRanking[] = [
    {
      id: '1',
      nome: 'Troca de Tela de Celular',
      categoria: 'Reparo de Tela',
      numeroOs: 34,
      valorMedio: 120.00,
      totalFaturado: 4080.00,
      posicao: 1
    },
    {
      id: '2',
      nome: 'Troca de Bateria',
      categoria: 'Reparo de Bateria',
      numeroOs: 28,
      valorMedio: 80.00,
      totalFaturado: 2240.00,
      posicao: 2
    },
    {
      id: '3',
      nome: 'Formatação de Sistema',
      categoria: 'Software',
      numeroOs: 22,
      valorMedio: 50.00,
      totalFaturado: 1100.00,
      posicao: 3
    }
  ];

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  const getRankingIcon = (posicao: number) => {
    switch (posicao) {
      case 1:
        return <Crown className="h-6 w-6 text-yellow-500" />;
      case 2:
        return <Medal className="h-6 w-6 text-gray-400" />;
      case 3:
        return <Star className="h-6 w-6 text-orange-500" />;
      default:
        return <Trophy className="h-6 w-6 text-gray-300" />;
    }
  };

  const getRankingBg = (posicao: number) => {
    switch (posicao) {
      case 1:
        return 'bg-gradient-to-r from-yellow-50 to-yellow-100 border-yellow-200';
      case 2:
        return 'bg-gradient-to-r from-gray-50 to-gray-100 border-gray-200';
      case 3:
        return 'bg-gradient-to-r from-orange-50 to-orange-100 border-orange-200';
      default:
        return 'bg-white border-gray-200';
    }
  };

  const TabButton = ({ 
    id, 
    label, 
    icon: Icon 
  }: { 
    id: 'produtos' | 'clientes' | 'servicos'; 
    label: string; 
    icon: React.ElementType 
  }) => (
    <button
      onClick={() => setActiveTab(id)}
      className={`flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-colors ${
        activeTab === id
          ? 'bg-blue-600 text-white'
          : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
      }`}
    >
      <Icon className="h-5 w-5" />
      {label}
    </button>
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
          
          <div className="flex items-center gap-3 mb-6">
            <div className="p-3 bg-yellow-100 rounded-lg">
              <Trophy className="h-8 w-8 text-yellow-600" />
            </div>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Ranking de Produtos e Clientes</h1>
              <p className="text-gray-600">Top performers e principais resultados</p>
            </div>
          </div>

          {/* Tabs */}
          <div className="flex flex-wrap gap-4">
            <TabButton id="produtos" label="Produtos Mais Vendidos" icon={Package} />
            <TabButton id="clientes" label="Melhores Clientes" icon={Users} />
            <TabButton id="servicos" label="Serviços Mais Solicitados" icon={FileText} />
          </div>
        </div>

        {/* Produtos Mais Vendidos */}
        {activeTab === 'produtos' && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
              <div className="flex items-center gap-2 mb-6">
                <Package className="h-6 w-6 text-blue-600" />
                <h3 className="text-xl font-semibold text-gray-900">Produtos Mais Vendidos</h3>
              </div>

              <div className="space-y-4">
                {produtosMaisVendidos.map((produto) => (
                  <div
                    key={produto.id}
                    className={`p-6 rounded-lg border-2 ${getRankingBg(produto.posicao)}`}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-4">
                        <div className="flex items-center gap-2">
                          {getRankingIcon(produto.posicao)}
                          <span className="text-2xl font-bold text-gray-600">#{produto.posicao}</span>
                        </div>
                        <div>
                          <h4 className="text-lg font-semibold text-gray-900">{produto.nome}</h4>
                          <p className="text-sm text-gray-600">Categoria: {produto.categoria}</p>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="text-2xl font-bold text-gray-900">
                          {formatCurrency(produto.totalVendas)}
                        </p>
                        <p className="text-sm text-gray-600">Total faturado</p>
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4 pt-4 border-t border-gray-200">
                      <div className="text-center">
                        <p className="text-2xl font-bold text-blue-600">{produto.quantidadeVendida}</p>
                        <p className="text-sm text-gray-600">Unidades vendidas</p>
                      </div>
                      <div className="text-center">
                        <p className="text-2xl font-bold text-green-600">
                          {formatCurrency(produto.lucro)}
                        </p>
                        <p className="text-sm text-gray-600">Lucro gerado</p>
                      </div>
                      <div className="text-center">
                        <p className="text-2xl font-bold text-purple-600">
                          {formatCurrency(produto.totalVendas / produto.quantidadeVendida)}
                        </p>
                        <p className="text-sm text-gray-600">Preço médio</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Melhores Clientes */}
        {activeTab === 'clientes' && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
              <div className="flex items-center gap-2 mb-6">
                <Users className="h-6 w-6 text-blue-600" />
                <h3 className="text-xl font-semibold text-gray-900">Clientes que Mais Compram</h3>
              </div>

              <div className="space-y-4">
                {clientesTopCompras.map((cliente) => (
                  <div
                    key={cliente.id}
                    className={`p-6 rounded-lg border-2 ${getRankingBg(cliente.posicao)}`}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-4">
                        <div className="flex items-center gap-2">
                          {getRankingIcon(cliente.posicao)}
                          <span className="text-2xl font-bold text-gray-600">#{cliente.posicao}</span>
                        </div>
                        <div>
                          <h4 className="text-lg font-semibold text-gray-900">{cliente.nome}</h4>
                          <p className="text-sm text-gray-600">{cliente.email}</p>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="text-2xl font-bold text-gray-900">
                          {formatCurrency(cliente.totalCompras)}
                        </p>
                        <p className="text-sm text-gray-600">Total gasto</p>
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4 pt-4 border-t border-gray-200">
                      <div className="text-center">
                        <p className="text-2xl font-bold text-blue-600">{cliente.numeroCompras}</p>
                        <p className="text-sm text-gray-600">Compras realizadas</p>
                      </div>
                      <div className="text-center">
                        <p className="text-2xl font-bold text-green-600">
                          {formatCurrency(cliente.ticketMedio)}
                        </p>
                        <p className="text-sm text-gray-600">Ticket médio</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Serviços Mais Solicitados */}
        {activeTab === 'servicos' && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
              <div className="flex items-center gap-2 mb-6">
                <FileText className="h-6 w-6 text-blue-600" />
                <h3 className="text-xl font-semibold text-gray-900">Serviços Mais Solicitados</h3>
              </div>

              <div className="space-y-4">
                {servicosMaisSolicitados.map((servico) => (
                  <div
                    key={servico.id}
                    className={`p-6 rounded-lg border-2 ${getRankingBg(servico.posicao)}`}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-4">
                        <div className="flex items-center gap-2">
                          {getRankingIcon(servico.posicao)}
                          <span className="text-2xl font-bold text-gray-600">#{servico.posicao}</span>
                        </div>
                        <div>
                          <h4 className="text-lg font-semibold text-gray-900">{servico.nome}</h4>
                          <p className="text-sm text-gray-600">Categoria: {servico.categoria}</p>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="text-2xl font-bold text-gray-900">
                          {formatCurrency(servico.totalFaturado)}
                        </p>
                        <p className="text-sm text-gray-600">Total faturado</p>
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4 pt-4 border-t border-gray-200">
                      <div className="text-center">
                        <p className="text-2xl font-bold text-blue-600">{servico.numeroOs}</p>
                        <p className="text-sm text-gray-600">OS realizadas</p>
                      </div>
                      <div className="text-center">
                        <p className="text-2xl font-bold text-green-600">
                          {formatCurrency(servico.valorMedio)}
                        </p>
                        <p className="text-sm text-gray-600">Valor médio</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Insights e Recomendações */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200 mt-8">
          <div className="flex items-center gap-2 mb-4">
            <TrendingUp className="h-6 w-6 text-green-600" />
            <h3 className="text-lg font-semibold text-gray-900">Insights e Recomendações</h3>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <div className="p-4 bg-blue-50 rounded-lg">
              <h4 className="font-semibold text-blue-900 mb-2">📱 Produtos</h4>
              <p className="text-sm text-blue-800">
                Smartphones lideram as vendas. Considere expandir a linha de acessórios para aumentar o ticket médio.
              </p>
            </div>
            
            <div className="p-4 bg-green-50 rounded-lg">
              <h4 className="font-semibold text-green-900 mb-2">👥 Clientes</h4>
              <p className="text-sm text-green-800">
                Clientes fidelizados têm ticket médio 40% maior. Implemente programa de fidelidade.
              </p>
            </div>
            
            <div className="p-4 bg-purple-50 rounded-lg">
              <h4 className="font-semibold text-purple-900 mb-2">🔧 Serviços</h4>
              <p className="text-sm text-purple-800">
                Reparos de tela são o serviço mais procurado. Mantenha sempre peças em estoque.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RelatoriosRankingPage;
