import { Link } from 'react-router-dom'
import { 
  Clock, 
  Settings, 
  CheckCircle, 
  Package, 
  TrendingUp 
} from 'lucide-react'
import { Card } from '../ui/Card'
import { useEstatisticasOS } from '../../hooks/useOrdensServico'

const STATUS_CONFIG = {
  total: {
    label: 'Total de OS',
    icon: Package,
    color: 'bg-blue-50 text-blue-600 border-blue-200',
    textColor: 'text-blue-900'
  },
  emAnalise: {
    label: 'Em Análise',
    icon: Clock,
    color: 'bg-yellow-50 text-yellow-600 border-yellow-200',
    textColor: 'text-yellow-900'
  },
  emConserto: {
    label: 'Em Conserto',
    icon: Settings,
    color: 'bg-blue-50 text-blue-600 border-blue-200',
    textColor: 'text-blue-900'
  },
  prontos: {
    label: 'Prontos',
    icon: CheckCircle,
    color: 'bg-green-50 text-green-600 border-green-200',
    textColor: 'text-green-900'
  },
  encerradas: {
    label: 'Encerradas',
    icon: TrendingUp,
    color: 'bg-gray-50 text-gray-600 border-gray-200',
    textColor: 'text-gray-900'
  }
}

export function StatusCardsOS() {
  const { estatisticas, loading } = useEstatisticasOS()

  if (loading) {
    return (
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
        {Array.from({ length: 5 }).map((_, index) => (
          <Card key={index} className="p-4 animate-pulse">
            <div className="h-8 bg-gray-200 rounded mb-2"></div>
            <div className="h-4 bg-gray-200 rounded"></div>
          </Card>
        ))}
      </div>
    )
  }

  return (
    <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
      {Object.entries(STATUS_CONFIG).map(([key, config]) => {
        const valor = estatisticas[key as keyof typeof estatisticas]
        const Icon = config.icon
        
        return (
          <div key={key}>
            <Card className={`p-4 border transition-all duration-200 hover:shadow-md ${config.color} cursor-default`}>
              <div className="flex items-center justify-between mb-2">
                <Icon className="w-5 h-5" />
                <span className={`text-2xl font-bold ${config.textColor}`}>
                  {valor}
                </span>
              </div>
              <div className={`text-sm font-medium ${config.textColor}`}>
                {config.label}
              </div>
            </Card>
          </div>
        )
      })}
    </div>
  )
}

export function ResumoOSWidget() {
  const { estatisticas, loading } = useEstatisticasOS()

  if (loading) {
    return (
      <Card className="p-6 animate-pulse">
        <div className="h-6 bg-gray-200 rounded mb-4"></div>
        <div className="space-y-2">
          <div className="h-4 bg-gray-200 rounded"></div>
          <div className="h-4 bg-gray-200 rounded"></div>
          <div className="h-4 bg-gray-200 rounded"></div>
        </div>
      </Card>
    )
  }

  const porcentagemProntos = estatisticas.total > 0 
    ? Math.round((estatisticas.prontos / estatisticas.total) * 100)
    : 0

  return (
    <Card className="p-6">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-gray-900">
          Ordens de Serviço
        </h3>
        <Link 
          to="/ordens-servico" 
          className="text-blue-600 hover:text-blue-800 text-sm font-medium"
        >
          Ver todas
        </Link>
      </div>

      <div className="space-y-3">
        <div className="flex justify-between items-center">
          <span className="text-sm text-gray-600">Em andamento</span>
          <span className="font-medium text-gray-900">
            {estatisticas.emAnalise + estatisticas.emConserto}
          </span>
        </div>
        
        <div className="flex justify-between items-center">
          <span className="text-sm text-gray-600">Prontos para entrega</span>
          <span className="font-medium text-green-600">
            {estatisticas.prontos}
          </span>
        </div>
        
        <div className="flex justify-between items-center">
          <span className="text-sm text-gray-600">Taxa de conclusão</span>
          <span className="font-medium text-gray-900">
            {porcentagemProntos}%
          </span>
        </div>
      </div>

      <div className="mt-4 pt-4 border-t">
        <Link to="/ordens-servico">
          <button className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 transition-colors text-sm font-medium">
            Nova Ordem de Serviço
          </button>
        </Link>
      </div>
    </Card>
  )
}
