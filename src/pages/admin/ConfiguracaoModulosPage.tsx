import { useState, useEffect } from 'react'
import { useModulosHabilitados } from '../../hooks/useModulosHabilitados'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { ShoppingCart, Package, Wrench, BarChart3, Save, RefreshCw } from 'lucide-react'
import { toast } from 'react-hot-toast'

interface ModuloConfig {
  key: 'ordens_servico' | 'vendas' | 'estoque' | 'relatorios'
  label: string
  description: string
  icon: any
  color: string
}

const MODULOS: ModuloConfig[] = [
  {
    key: 'vendas',
    label: 'Vendas (PDV)',
    description: 'Sistema de ponto de venda e gestão de vendas',
    icon: ShoppingCart,
    color: 'text-blue-600'
  },
  {
    key: 'estoque',
    label: 'Estoque',
    description: 'Gestão de produtos, fornecedores e estoque',
    icon: Package,
    color: 'text-green-600'
  },
  {
    key: 'ordens_servico',
    label: 'Ordens de Serviço',
    description: 'Gestão de ordens de serviço e assistência técnica',
    icon: Wrench,
    color: 'text-orange-600'
  },
  {
    key: 'relatorios',
    label: 'Relatórios',
    description: 'Relatórios gerenciais e análises de dados',
    icon: BarChart3,
    color: 'text-purple-600'
  }
]

export function ConfiguracaoModulosPage() {
  const { modulos, loading, atualizarModulo, recarregar } = useModulosHabilitados()
  const [salvando, setSalvando] = useState(false)
  const [modulosEditados, setModulosEditados] = useState(modulos)

  // Sincronizar modulosEditados com modulos quando mudar (ex: após recarregar)
  useEffect(() => {
    setModulosEditados(modulos)
  }, [modulos])

  const handleToggle = async (modulo: keyof typeof modulos) => {
    const novoValor = !modulosEditados[modulo]
    
    // Atualizar estado local imediatamente para feedback visual
    setModulosEditados(prev => ({
      ...prev,
      [modulo]: novoValor
    }))

    // Salvar no banco de dados
    setSalvando(true)
    try {
      const resultado = await atualizarModulo(modulo, novoValor)
      
      if (resultado) {
        toast.success(`✅ ${novoValor ? 'Módulo ativado' : 'Módulo desativado'} com sucesso!`)
        // Recarregar para garantir sincronização
        await recarregar()
        
        // Aguardar 500ms e recarregar a página para aplicar mudanças
        setTimeout(() => {
          window.location.reload()
        }, 500)
      } else {
        // Reverter em caso de erro
        setModulosEditados(prev => ({
          ...prev,
          [modulo]: !novoValor
        }))
        toast.error('❌ Erro ao atualizar módulo')
      }
    } catch (error) {
      console.error('Erro ao atualizar módulo:', error)
      // Reverter em caso de erro
      setModulosEditados(prev => ({
        ...prev,
        [modulo]: !novoValor
      }))
      toast.error('❌ Erro ao atualizar módulo')
    } finally {
      setSalvando(false)
    }
  }

  const handleSalvar = async () => {
    setSalvando(true)
    try {
      let sucesso = true
      
      for (const [key, value] of Object.entries(modulosEditados)) {
        if (modulos[key as keyof typeof modulos] !== value) {
          const resultado = await atualizarModulo(key as keyof typeof modulos, value)
          if (!resultado) sucesso = false
        }
      }

      if (sucesso) {
        toast.success('✅ Configuração de módulos salva com sucesso!')
        await recarregar()
      } else {
        toast.error('❌ Erro ao salvar algumas configurações')
      }
    } catch (error) {
      console.error('Erro ao salvar módulos:', error)
      toast.error('❌ Erro ao salvar configurações')
    } finally {
      setSalvando(false)
    }
  }

  const handleRecarregar = async () => {
    await recarregar()
    setModulosEditados(modulos)
    toast.success('✅ Configurações recarregadas')
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  const temAlteracoes = JSON.stringify(modulos) !== JSON.stringify(modulosEditados)

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Módulos do Sistema</h1>
          <p className="text-sm text-gray-600 mt-1">
            Configure quais módulos estarão visíveis no menu e dashboard
            <span className="ml-2 text-green-600 font-medium">✓ Salvamento automático</span>
          </p>
        </div>
        <Button
          variant="outline"
          onClick={handleRecarregar}
          disabled={salvando}
        >
          <RefreshCw className="w-4 h-4 mr-2" />
          Recarregar
        </Button>
      </div>

      {/* Avisos */}
      <Card className="bg-blue-50 border-blue-200">
        <div className="p-4">
          <h3 className="font-semibold text-blue-900 mb-2">ℹ️ Informações Importantes</h3>
          <ul className="text-sm text-blue-800 space-y-1">
            <li>• <strong>Mudanças são salvas instantaneamente</strong> ao clicar no toggle</li>
            <li>• Desabilitar um módulo apenas <strong>oculta</strong> do menu - os dados permanecem salvos</li>
            <li>• Você pode reabilitar a qualquer momento sem perder informações</li>
            <li>• As rotas ficarão inacessíveis enquanto o módulo estiver desabilitado</li>
            <li>• Ideal para empresas que não usam certos recursos (ex: apenas vendas, sem OS)</li>
          </ul>
        </div>
      </Card>

      {/* Grid de Módulos */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {MODULOS.map((config) => {
          const Icon = config.icon
          const habilitado = modulosEditados[config.key]

          return (
            <Card key={config.key} className={habilitado ? '' : 'opacity-60'}>
              <div className="p-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className={`p-3 rounded-lg ${habilitado ? 'bg-gray-100' : 'bg-gray-50'}`}>
                      <Icon className={`w-6 h-6 ${habilitado ? config.color : 'text-gray-400'}`} />
                    </div>
                    <div>
                      <h3 className="font-semibold text-gray-900">{config.label}</h3>
                      <p className="text-sm text-gray-600">{config.description}</p>
                    </div>
                  </div>
                </div>

                <div className="flex items-center justify-between pt-4 border-t">
                  <span className={`text-sm font-medium ${habilitado ? 'text-green-700' : 'text-red-700'}`}>
                    {habilitado ? '✅ Habilitado' : '❌ Desabilitado'}
                  </span>
                  <button
                    onClick={() => handleToggle(config.key)}
                    disabled={salvando}
                    className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 ${
                      habilitado 
                        ? 'bg-green-600 focus:ring-green-500' 
                        : 'bg-red-500 focus:ring-red-500'
                    } ${salvando ? 'opacity-50 cursor-not-allowed' : ''}`}
                  >
                    <span
                      className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                        habilitado ? 'translate-x-6' : 'translate-x-1'
                      }`}
                    />
                  </button>
                </div>
              </div>
            </Card>
          )
        })}
      </div>

      {/* Rodapé com dicas */}
      <Card className="bg-gray-50">
        <div className="p-4">
          <h3 className="font-semibold text-gray-900 mb-2">💡 Casos de Uso</h3>
          <div className="text-sm text-gray-700 space-y-2">
            <p><strong>Loja de Varejo:</strong> Desabilite "Ordens de Serviço" se você só vende produtos</p>
            <p><strong>Assistência Técnica:</strong> Mantenha "Ordens de Serviço" e desabilite "Vendas" se não revende</p>
            <p><strong>Sistema Completo:</strong> Mantenha todos habilitados para uso total do sistema</p>
          </div>
        </div>
      </Card>
    </div>
  )
}
