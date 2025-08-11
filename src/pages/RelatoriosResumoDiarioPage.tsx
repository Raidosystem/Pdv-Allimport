import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  ArrowLeft, 
  DollarSign, 
  ShoppingCart, 
  CreditCard, 
  Users, 
  UserCheck,
  FileText,
  TrendingUp,
  TrendingDown,
  Calendar,
  RefreshCw
} from 'lucide-react';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';

interface DailySummaryData {
  totalVendas: number;
  numeroPedidos: number;
  formasPagamento: {
    pix: number;
    cartao: number;
    dinheiro: number;
  };
  vendasComCliente: number;
  vendasAvulsas: number;
  vendasPorFuncionario: Array<{
    funcionario: string;
    vendas: number;
    total: number;
  }>;
  osFechadas: number;
  movimentoCaixa: {
    entradas: number;
    saidas: number;
    saldo: number;
  };
}

const ResumoDiarioPage: React.FC = () => {
  const navigate = useNavigate();
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [loading, setLoading] = useState(false);
  const [data] = useState<DailySummaryData>({
    totalVendas: 2340.50,
    numeroPedidos: 28,
    formasPagamento: {
      pix: 1250.30,
      cartao: 890.20,
      dinheiro: 200.00
    },
    vendasComCliente: 1890.50,
    vendasAvulsas: 450.00,
    vendasPorFuncionario: [
      { funcionario: 'Maria Silva', vendas: 15, total: 1200.50 },
      { funcionario: 'João Santos', vendas: 13, total: 1140.00 }
    ],
    osFechadas: 8,
    movimentoCaixa: {
      entradas: 2340.50,
      saidas: 150.00,
      saldo: 2190.50
    }
  });

  const loadDailyData = async () => {
    setLoading(true);
    // Simular carregamento de dados
    setTimeout(() => {
      setLoading(false);
    }, 1000);
  };

  useEffect(() => {
    loadDailyData();
  }, [selectedDate]);

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  const StatCard = ({ 
    title, 
    value, 
    icon: Icon, 
    color, 
    subtitle, 
    trend 
  }: {
    title: string;
    value: string;
    icon: React.ElementType;
    color: string;
    subtitle?: string;
    trend?: { value: string; isPositive: boolean };
  }) => (
    <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
      <div className="flex items-center justify-between mb-4">
        <div className={`p-2 ${color} rounded-lg`}>
          <Icon className="h-6 w-6 text-white" />
        </div>
        {trend && (
          <div className={`flex items-center gap-1 ${trend.isPositive ? 'text-green-600' : 'text-red-600'}`}>
            {trend.isPositive ? <TrendingUp className="h-4 w-4" /> : <TrendingDown className="h-4 w-4" />}
            <span className="text-sm font-medium">{trend.value}</span>
          </div>
        )}
      </div>
      <h3 className="text-sm font-medium text-gray-600 mb-1">{title}</h3>
      <p className="text-2xl font-bold text-gray-900">{value}</p>
      {subtitle && <p className="text-sm text-gray-500 mt-1">{subtitle}</p>}
    </div>
  );

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
          
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-3 bg-blue-100 rounded-lg">
                <Calendar className="h-8 w-8 text-blue-600" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Resumo Diário</h1>
                <p className="text-gray-600">
                  {format(selectedDate, "EEEE, dd 'de' MMMM 'de' yyyy", { locale: ptBR })}
                </p>
              </div>
            </div>

            <div className="flex items-center gap-4">
              <input
                type="date"
                value={format(selectedDate, 'yyyy-MM-dd')}
                onChange={(e) => setSelectedDate(new Date(e.target.value))}
                className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
              <button
                onClick={loadDailyData}
                disabled={loading}
                className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
              >
                <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
                Atualizar
              </button>
            </div>
          </div>
        </div>

        {loading ? (
          <div className="flex items-center justify-center h-64">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
          </div>
        ) : (
          <div className="space-y-8">
            {/* Cards Principais */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <StatCard
                title="Total de Vendas"
                value={formatCurrency(data.totalVendas)}
                icon={DollarSign}
                color="bg-green-500"
                trend={{ value: "+12%", isPositive: true }}
              />
              <StatCard
                title="Número de Pedidos"
                value={data.numeroPedidos.toString()}
                icon={ShoppingCart}
                color="bg-blue-500"
                subtitle="pedidos realizados"
                trend={{ value: "+5", isPositive: true }}
              />
              <StatCard
                title="OS Fechadas"
                value={data.osFechadas.toString()}
                icon={FileText}
                color="bg-purple-500"
                subtitle="ordens finalizadas"
              />
              <StatCard
                title="Saldo em Caixa"
                value={formatCurrency(data.movimentoCaixa.saldo)}
                icon={TrendingUp}
                color="bg-indigo-500"
                trend={{ value: "+8.5%", isPositive: true }}
              />
            </div>

            {/* Formas de Pagamento */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Formas de Pagamento</h3>
                <div className="space-y-4">
                  <div className="flex items-center justify-between p-4 bg-blue-50 rounded-lg">
                    <div className="flex items-center gap-3">
                      <CreditCard className="h-5 w-5 text-blue-600" />
                      <span className="font-medium text-gray-900">PIX</span>
                    </div>
                    <span className="text-lg font-bold text-blue-600">
                      {formatCurrency(data.formasPagamento.pix)}
                    </span>
                  </div>
                  <div className="flex items-center justify-between p-4 bg-green-50 rounded-lg">
                    <div className="flex items-center gap-3">
                      <CreditCard className="h-5 w-5 text-green-600" />
                      <span className="font-medium text-gray-900">Cartão</span>
                    </div>
                    <span className="text-lg font-bold text-green-600">
                      {formatCurrency(data.formasPagamento.cartao)}
                    </span>
                  </div>
                  <div className="flex items-center justify-between p-4 bg-yellow-50 rounded-lg">
                    <div className="flex items-center gap-3">
                      <DollarSign className="h-5 w-5 text-yellow-600" />
                      <span className="font-medium text-gray-900">Dinheiro</span>
                    </div>
                    <span className="text-lg font-bold text-yellow-600">
                      {formatCurrency(data.formasPagamento.dinheiro)}
                    </span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Tipo de Vendas</h3>
                <div className="space-y-4">
                  <div className="flex items-center justify-between p-4 bg-purple-50 rounded-lg">
                    <div className="flex items-center gap-3">
                      <UserCheck className="h-5 w-5 text-purple-600" />
                      <span className="font-medium text-gray-900">Com Cliente</span>
                    </div>
                    <span className="text-lg font-bold text-purple-600">
                      {formatCurrency(data.vendasComCliente)}
                    </span>
                  </div>
                  <div className="flex items-center justify-between p-4 bg-orange-50 rounded-lg">
                    <div className="flex items-center gap-3">
                      <Users className="h-5 w-5 text-orange-600" />
                      <span className="font-medium text-gray-900">Avulsas</span>
                    </div>
                    <span className="text-lg font-bold text-orange-600">
                      {formatCurrency(data.vendasAvulsas)}
                    </span>
                  </div>
                  
                  {/* Percentuais */}
                  <div className="mt-4 pt-4 border-t border-gray-200">
                    <div className="flex justify-between text-sm text-gray-600 mb-2">
                      <span>Com Cliente: {((data.vendasComCliente / data.totalVendas) * 100).toFixed(1)}%</span>
                      <span>Avulsas: {((data.vendasAvulsas / data.totalVendas) * 100).toFixed(1)}%</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div 
                        className="bg-purple-600 h-2 rounded-full" 
                        style={{ width: `${(data.vendasComCliente / data.totalVendas) * 100}%` }}
                      ></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Vendas por Funcionário */}
            <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Vendas por Funcionário</h3>
              <div className="space-y-4">
                {data.vendasPorFuncionario.map((funcionario, index) => (
                  <div key={index} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                        <Users className="h-5 w-5 text-blue-600" />
                      </div>
                      <div>
                        <p className="font-medium text-gray-900">{funcionario.funcionario}</p>
                        <p className="text-sm text-gray-600">{funcionario.vendas} vendas realizadas</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-lg font-bold text-gray-900">{formatCurrency(funcionario.total)}</p>
                      <p className="text-sm text-gray-600">
                        {((funcionario.total / data.totalVendas) * 100).toFixed(1)}% do total
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Movimento de Caixa */}
            <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Movimento de Caixa</h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="text-center p-4 bg-green-50 rounded-lg">
                  <TrendingUp className="h-8 w-8 text-green-600 mx-auto mb-2" />
                  <p className="text-sm text-gray-600 mb-1">Entradas</p>
                  <p className="text-2xl font-bold text-green-600">
                    {formatCurrency(data.movimentoCaixa.entradas)}
                  </p>
                </div>
                <div className="text-center p-4 bg-red-50 rounded-lg">
                  <TrendingDown className="h-8 w-8 text-red-600 mx-auto mb-2" />
                  <p className="text-sm text-gray-600 mb-1">Saídas</p>
                  <p className="text-2xl font-bold text-red-600">
                    {formatCurrency(data.movimentoCaixa.saidas)}
                  </p>
                </div>
                <div className="text-center p-4 bg-blue-50 rounded-lg">
                  <DollarSign className="h-8 w-8 text-blue-600 mx-auto mb-2" />
                  <p className="text-sm text-gray-600 mb-1">Saldo Final</p>
                  <p className="text-2xl font-bold text-blue-600">
                    {formatCurrency(data.movimentoCaixa.saldo)}
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ResumoDiarioPage;
