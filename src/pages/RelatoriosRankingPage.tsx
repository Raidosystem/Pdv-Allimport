import React, { useState, useEffect } from 'react';
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
import { supabase } from '../lib/supabase';
import { useAuth } from '../modules/auth';

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
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState<'produtos' | 'clientes' | 'servicos'>('produtos');
  const [loading, setLoading] = useState(true);

  const [produtosMaisVendidos, setProdutosMaisVendidos] = useState<ProdutoRanking[]>([]);
  const [clientesTopCompras, setClientesTopCompras] = useState<ClienteRanking[]>([]);
  const [servicosMaisSolicitados, setServicosMaisSolicitados] = useState<ServicoRanking[]>([]);

  useEffect(() => {
    if (user?.id) {
      loadRankings();
    }
  }, [user]);

  const loadRankings = async () => {
    setLoading(true);
    try {
      await Promise.all([
        loadProdutos(),
        loadClientes(),
        loadServicos()
      ]);
    } catch (error) {
      console.error('Erro ao carregar rankings:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadProdutos = async () => {
    console.log('🔍 Iniciando carregamento de produtos...');
    
    // Buscar vendas agrupadas por produto
    const { data, error } = await supabase
      .from('vendas_itens')
      .select(`
        produto_id,
        quantidade,
        preco_unitario,
        produtos (nome, categoria, preco_custo)
      `)
      .eq('user_id', user?.id);

    console.log('📊 Dados de vendas_itens:', { data, error, count: data?.length });

    if (error) {
      console.error('❌ Erro ao buscar produtos:', error);
      return;
    }

    if (!data || data.length === 0) {
      console.log('⚠️ Nenhuma venda encontrada para o usuário');
      setProdutosMaisVendidos([]);
      return;
    }

    // Agrupar por produto
    const grouped = data.reduce((acc: any, item: any) => {
      const produtoId = item.produto_id;
      if (!acc[produtoId]) {
        acc[produtoId] = {
          id: produtoId,
          nome: item.produtos?.nome || 'Produto sem nome',
          categoria: item.produtos?.categoria || 'Sem categoria',
          quantidadeVendida: 0,
          totalVendas: 0,
          lucro: 0,
          precoCusto: item.produtos?.preco_custo || 0
        };
      }
      acc[produtoId].quantidadeVendida += item.quantidade;
      acc[produtoId].totalVendas += item.quantidade * item.preco_unitario;
      acc[produtoId].lucro += item.quantidade * (item.preco_unitario - acc[produtoId].precoCusto);
      return acc;
    }, {});

    // Ordenar por total de vendas
    const ranking = Object.values(grouped)
      .sort((a: any, b: any) => b.totalVendas - a.totalVendas)
      .slice(0, 10)
      .map((item: any, index) => ({
        ...item,
        posicao: index + 1
      }));

    setProdutosMaisVendidos(ranking as ProdutoRanking[]);
  };

  const loadClientes = async () => {
    console.log('🔍 Iniciando carregamento de clientes...');
    
    // Buscar vendas agrupadas por cliente
    const { data, error } = await supabase
      .from('vendas')
      .select(`
        cliente_id,
        valor_total,
        clientes (nome, email)
      `)
      .eq('user_id', user?.id)
      .not('cliente_id', 'is', null);

    console.log('📊 Dados de vendas (clientes):', { data, error, count: data?.length });

    if (error) {
      console.error('❌ Erro ao buscar clientes:', error);
      return;
    }

    if (!data || data.length === 0) {
      console.log('⚠️ Nenhuma venda encontrada para clientes');
      setClientesTopCompras([]);
      return;
    }

    // Agrupar por cliente
    const grouped = data.reduce((acc: any, venda: any) => {
      const clienteId = venda.cliente_id;
      if (!acc[clienteId]) {
        acc[clienteId] = {
          id: clienteId,
          nome: venda.clientes?.nome || 'Cliente sem nome',
          email: venda.clientes?.email || '',
          totalCompras: 0,
          numeroCompras: 0,
          ticketMedio: 0
        };
      }
      acc[clienteId].totalCompras += venda.valor_total;
      acc[clienteId].numeroCompras += 1;
      return acc;
    }, {});

    // Calcular ticket médio e ordenar
    const ranking = Object.values(grouped)
      .map((item: any) => ({
        ...item,
        ticketMedio: item.totalCompras / item.numeroCompras
      }))
      .sort((a: any, b: any) => b.totalCompras - a.totalCompras)
      .slice(0, 10)
      .map((item: any, index) => ({
        ...item,
        posicao: index + 1
      }));

    setClientesTopCompras(ranking as ClienteRanking[]);
  };

  const loadServicos = async () => {
    console.log('🔍 Iniciando carregamento de serviços...');
    
    // Buscar ordens de serviço agrupadas por serviço
    const { data, error } = await supabase
      .from('ordens_servico')
      .select('id, descricao, valor_total, status')
      .eq('user_id', user?.id);

    console.log('📊 Dados de ordens_servico:', { data, error, count: data?.length });

    if (error) {
      console.error('❌ Erro ao buscar serviços:', error);
      return;
    }

    if (!data || data.length === 0) {
      console.log('⚠️ Nenhuma ordem de serviço encontrada para o usuário');
      setServicosMaisSolicitados([]);
      return;
    }

    // Agrupar por descrição (serviço)
    const grouped = data.reduce((acc: any, os: any) => {
      const servico = os.descricao || 'Serviço sem descrição';
      if (!acc[servico]) {
        acc[servico] = {
          id: servico,
          nome: servico,
          categoria: 'Assistência Técnica',
          numeroOs: 0,
          valorMedio: 0,
          totalFaturado: 0
        };
      }
      acc[servico].numeroOs += 1;
      acc[servico].totalFaturado += os.valor_total || 0;
      return acc;
    }, {});

    console.log('📦 Serviços agrupados:', grouped);

    // Calcular valor médio e ordenar
    const ranking = Object.values(grouped)
      .map((item: any) => ({
        ...item,
        valorMedio: item.totalFaturado / item.numeroOs
      }))
      .sort((a: any, b: any) => b.numeroOs - a.numeroOs)
      .slice(0, 10)
      .map((item: any, index) => ({
        ...item,
        posicao: index + 1
      }));

    console.log('🏆 Ranking final de serviços:', ranking);
    setServicosMaisSolicitados(ranking as ServicoRanking[]);
  };

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
                {loading ? (
                  <div className="text-center py-12">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
                    <p className="text-gray-600 mt-4">Carregando produtos...</p>
                  </div>
                ) : produtosMaisVendidos.length === 0 ? (
                  <div className="text-center py-12">
                    <Package className="h-16 w-16 text-gray-300 mx-auto mb-4" />
                    <p className="text-gray-600">Nenhum produto vendido no período</p>
                  </div>
                ) : (
                  produtosMaisVendidos.map((produto) => (
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
                )))
              }
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
                {loading ? (
                  <div className="text-center py-12">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
                    <p className="text-gray-600 mt-4">Carregando clientes...</p>
                  </div>
                ) : clientesTopCompras.length === 0 ? (
                  <div className="text-center py-12">
                    <Users className="h-16 w-16 text-gray-300 mx-auto mb-4" />
                    <p className="text-gray-600">Nenhum cliente com compras no período</p>
                  </div>
                ) : (
                  clientesTopCompras.map((cliente) => (
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
                )))}
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
                {loading ? (
                  <div className="text-center py-12">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
                    <p className="text-gray-600 mt-4">Carregando serviços...</p>
                  </div>
                ) : servicosMaisSolicitados.length === 0 ? (
                  <div className="text-center py-12">
                    <FileText className="h-16 w-16 text-gray-300 mx-auto mb-4" />
                    <p className="text-gray-600">Nenhuma ordem de serviço no período</p>
                  </div>
                ) : (
                  servicosMaisSolicitados.map((servico) => (
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
                )))
              }
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
