import { 
  DollarSign, 
  TrendingUp, 
  TrendingDown, 
  Calculator,
  Clock,
  User 
} from 'lucide-react';
import type { CaixaCompleto } from '../../types/caixa';

interface StatusCaixaProps {
  caixa: CaixaCompleto | null;
  loading?: boolean;
}

export function StatusCaixa({ caixa, loading = false }: StatusCaixaProps) {
  if (loading) {
    return (
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div className="animate-pulse">
          <div className="h-6 bg-gray-200 rounded w-1/3 mb-4"></div>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="space-y-2">
                <div className="h-4 bg-gray-200 rounded w-2/3"></div>
                <div className="h-8 bg-gray-200 rounded"></div>
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  if (!caixa) {
    return (
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div className="text-center py-8">
          <div className="bg-gray-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
            <DollarSign className="w-8 h-8 text-gray-400" />
          </div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">
            Nenhum caixa aberto
          </h3>
          <p className="text-gray-500 text-sm">
            Abra um caixa para começar as operações do dia
          </p>
        </div>
      </div>
    );
  }

  const formatarMoeda = (valor: number) => {
    return valor.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    });
  };

  const formatarDataHora = (data: string) => {
    return new Date(data).toLocaleString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const stats = [
    {
      label: 'Valor Inicial',
      valor: formatarMoeda(caixa.valor_inicial),
      icon: DollarSign,
      cor: 'text-blue-600',
      bgCor: 'bg-blue-50'
    },
    {
      label: 'Total Entradas',
      valor: formatarMoeda(caixa.total_entradas || 0),
      icon: TrendingUp,
      cor: 'text-green-600',
      bgCor: 'bg-green-50'
    },
    {
      label: 'Total Saídas',
      valor: formatarMoeda(caixa.total_saidas || 0),
      icon: TrendingDown,
      cor: 'text-red-600',
      bgCor: 'bg-red-50'
    },
    {
      label: 'Saldo Atual',
      valor: formatarMoeda(caixa.saldo_atual || 0),
      icon: Calculator,
      cor: 'text-orange-600',
      bgCor: 'bg-orange-50'
    }
  ];

  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-200">
      {/* Header */}
      <div className="p-6 border-b border-gray-200">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-xl font-bold text-gray-900 flex items-center gap-2">
              <div className={`p-2 rounded-lg ${
                caixa.status === 'aberto' ? 'bg-green-100' : 'bg-gray-100'
              }`}>
                <DollarSign className={`w-5 h-5 ${
                  caixa.status === 'aberto' ? 'text-green-600' : 'text-gray-400'
                }`} />
              </div>
              Status do Caixa
            </h2>
            <p className="text-gray-600 text-sm mt-1">
              Controle financeiro em tempo real
            </p>
          </div>
          
          <div className={`px-3 py-1 rounded-full text-sm font-medium ${
            caixa.status === 'aberto' 
              ? 'bg-green-100 text-green-700' 
              : 'bg-gray-100 text-gray-700'
          }`}>
            {caixa.status === 'aberto' ? '🟢 Aberto' : '🔴 Fechado'}
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="p-6">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
          {stats.map((stat) => (
            <div key={stat.label} className="text-center">
              <div className={`inline-flex p-3 rounded-lg ${stat.bgCor} mb-3`}>
                <stat.icon className={`w-6 h-6 ${stat.cor}`} />
              </div>
              <p className="text-sm text-gray-600 mb-1">{stat.label}</p>
              <p className="text-lg font-bold text-gray-900">{stat.valor}</p>
            </div>
          ))}
        </div>

        {/* Informações adicionais */}
        <div className="flex flex-col sm:flex-row gap-4 text-sm text-gray-600 pt-4 border-t border-gray-100">
          <div className="flex items-center gap-2">
            <Clock className="w-4 h-4" />
            <span>Aberto em: {formatarDataHora(caixa.data_abertura)}</span>
          </div>
          
          {caixa.data_fechamento && (
            <div className="flex items-center gap-2">
              <Clock className="w-4 h-4" />
              <span>Fechado em: {formatarDataHora(caixa.data_fechamento)}</span>
            </div>
          )}

          <div className="flex items-center gap-2">
            <User className="w-4 h-4" />
            <span>{caixa.movimentacoes?.length || 0} movimentações</span>
          </div>
        </div>

        {/* Diferença (se caixa fechado) */}
        {caixa.status === 'fechado' && caixa.diferenca !== null && caixa.diferenca !== undefined && (
          <div className="mt-4 p-4 rounded-lg bg-yellow-50 border border-yellow-200">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-yellow-800">
                Diferença no fechamento:
              </span>
              <span className={`font-bold ${
                caixa.diferenca === 0 
                  ? 'text-green-600' 
                  : (caixa.diferenca || 0) > 0 
                    ? 'text-blue-600' 
                    : 'text-red-600'
              }`}>
                {formatarMoeda(caixa.diferenca || 0)}
              </span>
            </div>
            {caixa.diferenca !== 0 && (
              <p className="text-xs text-yellow-700 mt-1">
                {(caixa.diferenca || 0) > 0 ? 'Sobra de caixa' : 'Falta no caixa'}
              </p>
            )}
          </div>
        )}

        {/* Observações */}
        {caixa.observacoes && (
          <div className="mt-4 p-3 bg-gray-50 rounded-lg">
            <p className="text-sm text-gray-600">
              <strong>Observações:</strong> {caixa.observacoes}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
