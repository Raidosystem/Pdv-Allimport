import React, { useState } from 'react';
import { 
  BarChart3, 
  Calendar, 
  Trophy, 
  FileText, 
  PieChart, 
  Download,
  TrendingUp,
  Users,
  DollarSign,
  Clock,
  ArrowLeft,
  Package,
  FileX,
  Mail,
  Printer
} from 'lucide-react';

const RelatoriosPage: React.FC = () => {
  const [activeSection, setActiveSection] = useState<string | null>(null);

  const renderResumoDiario = () => (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-2xl font-bold mb-6 flex items-center gap-2">
        <Calendar className="w-6 h-6 text-blue-500" />
        Resumo Diário - {new Date().toLocaleDateString('pt-BR')}
      </h2>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <div className="bg-blue-50 p-4 rounded-lg">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total de Vendas</p>
              <p className="text-2xl font-bold text-blue-600">R$ 0,00</p>
            </div>
            <DollarSign className="w-8 h-8 text-blue-500" />
          </div>
        </div>
        
        <div className="bg-green-50 p-4 rounded-lg">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Número de Pedidos</p>
              <p className="text-2xl font-bold text-green-600">0</p>
            </div>
            <FileText className="w-8 h-8 text-green-500" />
          </div>
        </div>
        
        <div className="bg-purple-50 p-4 rounded-lg">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">OS Fechadas</p>
              <p className="text-2xl font-bold text-purple-600">0</p>
            </div>
            <FileX className="w-8 h-8 text-purple-500" />
          </div>
        </div>
        
        <div className="bg-yellow-50 p-4 rounded-lg">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total em Caixa</p>
              <p className="text-2xl font-bold text-yellow-600">R$ 0,00</p>
            </div>
            <DollarSign className="w-8 h-8 text-yellow-500" />
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold mb-3">Formas de Pagamento</h3>
          <div className="space-y-2">
            <div className="text-center text-gray-500 py-4">
              Nenhum dado disponível
            </div>
          </div>
        </div>
        
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold mb-3">Vendas por Funcionário</h3>
          <div className="space-y-2">
            <div className="text-center text-gray-500 py-4">
              Nenhum dado disponível
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  const renderFiltroPeriodo = () => (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-2xl font-bold mb-6 flex items-center gap-2">
        <BarChart3 className="w-6 h-6 text-green-500" />
        Filtro por Período
      </h2>
      
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        <div>
          <label className="block text-sm font-medium mb-2">Data Inicial</label>
          <input 
            type="date" 
            className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-2">Data Final</label>
          <input 
            type="date" 
            className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-2">Funcionário</label>
          <select className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent">
            <option value="">Todos</option>
          </select>
        </div>
      </div>
      
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <div>
          <label className="block text-sm font-medium mb-2">Forma de Pagamento</label>
          <select className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent">
            <option value="">Todas</option>
            <option value="pix">PIX</option>
            <option value="cartao">Cartão</option>
            <option value="dinheiro">Dinheiro</option>
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium mb-2">Tipo de Venda</label>
          <select className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent">
            <option value="">Todas</option>
            <option value="cliente">Com Cliente</option>
            <option value="avulsa">Avulsa</option>
          </select>
        </div>
      </div>
      
      <button className="bg-blue-500 text-white px-6 py-2 rounded-md hover:bg-blue-600 transition-colors">
        Gerar Relatório
      </button>
    </div>
  );

  const renderRanking = () => (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-2xl font-bold mb-6 flex items-center gap-2">
        <Trophy className="w-6 h-6 text-yellow-500" />
        Ranking de Produtos e Clientes
      </h2>
      
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold mb-4 flex items-center gap-2">
            <Package className="w-5 h-5" />
            Produtos Mais Vendidos
          </h3>
          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span>Smartphone XYZ</span>
              <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-sm">45 vendas</span>
            </div>
            <div className="flex justify-between items-center">
              <span>Fone Bluetooth</span>
              <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-sm">32 vendas</span>
            </div>
            <div className="flex justify-between items-center">
              <span>Cabo USB-C</span>
              <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-sm">28 vendas</span>
            </div>
          </div>
        </div>
        
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold mb-4 flex items-center gap-2">
            <Users className="w-5 h-5" />
            Clientes que Mais Compram
          </h3>
          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span>Carlos Silva</span>
              <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-sm">R$ 2.450</span>
            </div>
            <div className="flex justify-between items-center">
              <span>Ana Santos</span>
              <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-sm">R$ 1.890</span>
            </div>
            <div className="flex justify-between items-center">
              <span>Pedro Costa</span>
              <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-sm">R$ 1.650</span>
            </div>
          </div>
        </div>
        
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold mb-4 flex items-center gap-2">
            <FileX className="w-5 h-5" />
            Serviços Mais Solicitados
          </h3>
          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span>Troca de Tela</span>
              <span className="bg-purple-100 text-purple-800 px-2 py-1 rounded text-sm">23 OS</span>
            </div>
            <div className="flex justify-between items-center">
              <span>Reparo de Placa</span>
              <span className="bg-purple-100 text-purple-800 px-2 py-1 rounded text-sm">18 OS</span>
            </div>
            <div className="flex justify-between items-center">
              <span>Limpeza</span>
              <span className="bg-purple-100 text-purple-800 px-2 py-1 rounded text-sm">15 OS</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  const renderDetalhado = () => (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-2xl font-bold mb-6 flex items-center gap-2">
        <FileText className="w-6 h-6 text-purple-500" />
        Relatório Detalhado
      </h2>
      
      <div className="flex justify-between items-center mb-4">
        <div className="flex gap-2">
          <button className="bg-green-500 text-white px-4 py-2 rounded-md hover:bg-green-600 transition-colors flex items-center gap-2">
            <Download className="w-4 h-4" />
            PDF
          </button>
          <button className="bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600 transition-colors flex items-center gap-2">
            <Download className="w-4 h-4" />
            Excel
          </button>
        </div>
      </div>
      
      <div className="overflow-x-auto">
        <table className="w-full border-collapse border border-gray-300">
          <thead>
            <tr className="bg-gray-50">
              <th className="border border-gray-300 p-2 text-left">Data</th>
              <th className="border border-gray-300 p-2 text-left">Cliente</th>
              <th className="border border-gray-300 p-2 text-left">Tipo</th>
              <th className="border border-gray-300 p-2 text-left">Total</th>
              <th className="border border-gray-300 p-2 text-left">Pagamento</th>
              <th className="border border-gray-300 p-2 text-left">Funcionário</th>
              <th className="border border-gray-300 p-2 text-left">Ações</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td colSpan={7} className="border border-gray-300 p-4 text-center text-gray-500">
                Nenhum dado disponível
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderGraficos = () => (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-2xl font-bold mb-6 flex items-center gap-2">
        <PieChart className="w-6 h-6 text-red-500" />
        Gráficos e Dashboards
      </h2>
      
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold mb-4">Vendas por Dia (Últimos 7 dias)</h3>
          <div className="h-64 bg-white rounded border flex items-center justify-center">
            <span className="text-gray-500">Gráfico de Barras aqui</span>
          </div>
        </div>
        
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold mb-4">Formas de Pagamento</h3>
          <div className="h-64 bg-white rounded border flex items-center justify-center">
            <span className="text-gray-500">Gráfico de Pizza aqui</span>
          </div>
        </div>
        
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold mb-4">Evolução das Vendas (Mensal)</h3>
          <div className="h-64 bg-white rounded border flex items-center justify-center">
            <span className="text-gray-500">Gráfico de Linha aqui</span>
          </div>
        </div>
        
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold mb-4">Produtos Mais Vendidos</h3>
          <div className="h-64 bg-white rounded border flex items-center justify-center">
            <span className="text-gray-500">Gráfico de Barras Horizontais aqui</span>
          </div>
        </div>
      </div>
    </div>
  );

  const renderExportacoes = () => (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-2xl font-bold mb-6 flex items-center gap-2">
        <Download className="w-6 h-6 text-indigo-500" />
        Exportações
      </h2>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div className="bg-red-50 p-6 rounded-lg text-center">
          <FileText className="w-12 h-12 text-red-500 mx-auto mb-4" />
          <h3 className="font-semibold mb-2">Exportar PDF</h3>
          <p className="text-sm text-gray-600 mb-4">Relatórios formatados para impressão</p>
          <button className="bg-red-500 text-white px-4 py-2 rounded-md hover:bg-red-600 transition-colors">
            Gerar PDF
          </button>
        </div>
        
        <div className="bg-green-50 p-6 rounded-lg text-center">
          <BarChart3 className="w-12 h-12 text-green-500 mx-auto mb-4" />
          <h3 className="font-semibold mb-2">Exportar Excel</h3>
          <p className="text-sm text-gray-600 mb-4">Planilhas para análise avançada</p>
          <button className="bg-green-500 text-white px-4 py-2 rounded-md hover:bg-green-600 transition-colors">
            Gerar XLSX
          </button>
        </div>
        
        <div className="bg-blue-50 p-6 rounded-lg text-center">
          <FileText className="w-12 h-12 text-blue-500 mx-auto mb-4" />
          <h3 className="font-semibold mb-2">Exportar CSV</h3>
          <p className="text-sm text-gray-600 mb-4">Dados simples para integração</p>
          <button className="bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600 transition-colors">
            Gerar CSV
          </button>
        </div>
        
        <div className="bg-purple-50 p-6 rounded-lg text-center">
          <Mail className="w-12 h-12 text-purple-500 mx-auto mb-4" />
          <h3 className="font-semibold mb-2">Enviar por E-mail</h3>
          <p className="text-sm text-gray-600 mb-4">Relatórios automáticos por e-mail</p>
          <button className="bg-purple-500 text-white px-4 py-2 rounded-md hover:bg-purple-600 transition-colors">
            Configurar
          </button>
        </div>
        
        <div className="bg-yellow-50 p-6 rounded-lg text-center">
          <Printer className="w-12 h-12 text-yellow-500 mx-auto mb-4" />
          <h3 className="font-semibold mb-2">Impressão Direta</h3>
          <p className="text-sm text-gray-600 mb-4">Imprimir relatórios instantaneamente</p>
          <button className="bg-yellow-500 text-white px-4 py-2 rounded-md hover:bg-yellow-600 transition-colors">
            Imprimir
          </button>
        </div>
        
        <div className="bg-indigo-50 p-6 rounded-lg text-center">
          <DollarSign className="w-12 h-12 text-indigo-500 mx-auto mb-4" />
          <h3 className="font-semibold mb-2">Fechamento de Caixa</h3>
          <p className="text-sm text-gray-600 mb-4">Relatório completo do caixa</p>
          <button className="bg-indigo-500 text-white px-4 py-2 rounded-md hover:bg-indigo-600 transition-colors">
            Ver Fechamento
          </button>
        </div>
      </div>
    </div>
  );

  const renderContent = () => {
    switch (activeSection) {
      case 'resumo-diario':
        return renderResumoDiario();
      case 'filtro-periodo':
        return renderFiltroPeriodo();
      case 'ranking':
        return renderRanking();
      case 'detalhado':
        return renderDetalhado();
      case 'graficos':
        return renderGraficos();
      case 'exportacoes':
        return renderExportacoes();
      default:
        return null;
    }
  };

  // Se há seção ativa, mostrar o conteúdo específico
  if (activeSection) {
    return (
      <div className="p-6 max-w-7xl mx-auto">
        <button
          onClick={() => setActiveSection(null)}
          className="mb-4 text-blue-500 hover:text-blue-700 flex items-center gap-2"
        >
          <ArrowLeft className="w-4 h-4" />
          Voltar aos Relatórios
        </button>
        
        {renderContent()}
      </div>
    );
  }

  const relatoriosModules = [
    {
      id: 'resumo',
      title: 'Resumo Diário',
      description: 'Visão geral das vendas e movimentações do dia',
      icon: BarChart3,
      color: 'bg-blue-500',
      onClick: () => setActiveSection('resumo-diario')
    },
    {
      id: 'periodo',
      title: 'Filtro por Período',
      description: 'Relatórios customizados por data e filtros',
      icon: Calendar,
      color: 'bg-green-500',
      onClick: () => setActiveSection('filtro-periodo')
    },
    {
      id: 'ranking',
      title: 'Ranking de Produtos e Clientes',
      description: 'Produtos mais vendidos e melhores clientes',
      icon: Trophy,
      color: 'bg-yellow-500',
      onClick: () => setActiveSection('ranking')
    },
    {
      id: 'detalhado',
      title: 'Relatório Detalhado',
      description: 'Listagem completa de vendas e OS',
      icon: FileText,
      color: 'bg-purple-500',
      onClick: () => setActiveSection('detalhado')
    },
    {
      id: 'graficos',
      title: 'Gráficos e Dashboards',
      description: 'Visualizações interativas e análises',
      icon: PieChart,
      color: 'bg-pink-500',
      onClick: () => setActiveSection('graficos')
    },
    {
      id: 'exportacoes',
      title: 'Exportações',
      description: 'Exportar relatórios em PDF, Excel e CSV',
      icon: Download,
      color: 'bg-indigo-500',
      onClick: () => setActiveSection('exportacoes')
    }
  ];

  const quickStats = [
    { 
      title: 'Vendas Hoje', 
      value: 'R$ 2.340,50', 
      icon: DollarSign, 
      change: '+12%',
      color: 'text-green-600'
    },
    { 
      title: 'Pedidos Hoje', 
      value: '28', 
      icon: TrendingUp, 
      change: '+5',
      color: 'text-blue-600'
    },
    { 
      title: 'Clientes Ativos', 
      value: '156', 
      icon: Users, 
      change: '+8',
      color: 'text-purple-600'
    },
    { 
      title: 'OS Abertas', 
      value: '12', 
      icon: Clock, 
      change: '+3',
      color: 'text-orange-600'
    }
  ];

  const handleModuleClick = (onClick: () => void) => {
    onClick();
  };

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
            <div className="p-3 bg-blue-100 rounded-lg">
              <BarChart3 className="h-8 w-8 text-blue-600" />
            </div>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Relatórios</h1>
              <p className="text-gray-600">Análises detalhadas e insights do seu negócio</p>
            </div>
          </div>

          {/* Quick Stats */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            {quickStats.map((stat, index) => (
              <div key={index} className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600">{stat.title}</p>
                    <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
                    <p className={`text-sm ${stat.color}`}>{stat.change} hoje</p>
                  </div>
                  <div className={`p-3 rounded-full bg-gray-100`}>
                    <stat.icon className={`h-6 w-6 ${stat.color}`} />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Módulos de Relatórios */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {relatoriosModules.map((module) => (
            <div
              key={module.id}
              onClick={() => handleModuleClick(module.onClick)}
              className="bg-white rounded-lg p-6 shadow-sm border border-gray-200 hover:shadow-md transition-shadow cursor-pointer group"
            >
              <div className="flex items-center gap-4 mb-4">
                <div className={`p-3 ${module.color} rounded-lg group-hover:scale-110 transition-transform`}>
                  <module.icon className="h-6 w-6 text-white" />
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 group-hover:text-blue-600 transition-colors">
                    {module.title}
                  </h3>
                </div>
              </div>
              
              <p className="text-gray-600 text-sm leading-relaxed">
                {module.description}
              </p>

              <div className="mt-4 flex items-center text-sm text-blue-600 group-hover:text-blue-700">
                <span>Acessar relatório</span>
                <span className="ml-1 group-hover:translate-x-1 transition-transform">→</span>
              </div>
            </div>
          ))}
        </div>

        {/* Ações Rápidas */}
        <div className="mt-8 bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Ações Rápidas</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <button 
              onClick={() => setActiveSection('resumo-diario')}
              className="flex items-center gap-3 p-4 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors"
            >
              <BarChart3 className="h-5 w-5 text-blue-600" />
              <span className="text-blue-700 font-medium">Ver Resumo de Hoje</span>
            </button>
            
            <button 
              onClick={() => setActiveSection('exportacoes')}
              className="flex items-center gap-3 p-4 bg-green-50 rounded-lg hover:bg-green-100 transition-colors"
            >
              <Download className="h-5 w-5 text-green-600" />
              <span className="text-green-700 font-medium">Exportar Relatórios</span>
            </button>
            
            <button 
              onClick={() => setActiveSection('graficos')}
              className="flex items-center gap-3 p-4 bg-purple-50 rounded-lg hover:bg-purple-100 transition-colors"
            >
              <PieChart className="h-5 w-5 text-purple-600" />
              <span className="text-purple-700 font-medium">Ver Gráficos</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RelatoriosPage;
