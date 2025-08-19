import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { toast } from 'react-hot-toast'
import { 
  Plus, 
  Search, 
  Eye, 
  Edit, 
  Printer,
  RefreshCw
} from 'lucide-react'
import { Button } from '../components/ui/Button'
import { BackButton } from '../components/ui/BackButton'
import { Card } from '../components/ui/Card'
import { ordemServicoService } from '../services/ordemServicoService'
import { OrdemServicoForm } from '../components/ordem-servico/OrdemServicoForm'
import { StatusCardsOS } from '../components/ordem-servico/StatusCardsOS'
import { useOrdensServico } from '../hooks/useOrdensServico'
import type { 
  FiltrosOS, 
  StatusOS, 
  TipoEquipamento,
  OrdemServico
} from '../types/ordemServico'

const STATUS_OPTIONS: StatusOS[] = [
  'Em análise',
  'Aguardando aprovação', 
  'Aguardando peças',
  'Em conserto',
  'Pronto',
  'Cancelado'
]

const TIPO_OPTIONS: TipoEquipamento[] = [
  'Celular',
  'Notebook', 
  'Console',
  'Tablet',
  'Outro'
]

export function OrdensServicoPage() {
  const [filtros, setFiltros] = useState<FiltrosOS>({})
  const [mostrarFormulario, setMostrarFormulario] = useState(false)
  const [atualizandoStatus, setAtualizandoStatus] = useState<string | null>(null)

  const { ordens, loading, recarregar } = useOrdensServico(filtros)

  // Sistema simples de refresh após encerramento
  useEffect(() => {
    const checkRefresh = () => {
      const needsRefresh = localStorage.getItem('os_refresh_needed')
      if (needsRefresh === 'true') {
        console.log('� Atualizando lista após encerramento...')
        localStorage.removeItem('os_refresh_needed')
        recarregar()
      }
    }
    
    // Verificar imediatamente e quando a página ganhar foco
    checkRefresh()
    window.addEventListener('focus', checkRefresh)
    return () => window.removeEventListener('focus', checkRefresh)
  }, [recarregar])

  // Atualizar status da ordem
  const atualizarStatus = async (id: string, novoStatus: StatusOS) => {
    setAtualizandoStatus(id)
    try {
      await ordemServicoService.atualizarStatus(id, novoStatus)
      toast.success('Status atualizado com sucesso!')
      recarregar()
    } catch (error: any) {
      console.error('Erro ao atualizar status:', error)
      toast.error('Erro ao atualizar status')
    } finally {
      setAtualizandoStatus(null)
    }
  }

  // Aplicar filtros
  const aplicarFiltros = (novosFiltros: Partial<FiltrosOS>) => {
    setFiltros(prev => ({ ...prev, ...novosFiltros }))
  }

  // Imprimir ordem de serviço com detecção automática de impressora
  const imprimirOrdem = (ordem: OrdemServico & { cliente?: { nome?: string; telefone?: string; email?: string } }) => {
    const statusEntregue = ordem.status === 'Entregue' ? 'ENTREGUE' : ordem.status.toUpperCase()
    const valorFinal = ordem.valor_final || ordem.valor_orcamento || 0
    
    // Layout para impressora A4 (padrão)
    const layoutA4 = `
      <div style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; font-size: 12px;">
        <div style="text-align: center; margin-bottom: 30px; border-bottom: 2px solid #333; padding-bottom: 20px;">
          <h1 style="margin: 0; font-size: 24px;">ORDEM DE SERVIÇO</h1>
          <h2 style="margin: 5px 0; font-size: 18px; color: #666;">#{ordem.id.slice(-6).toUpperCase()}</h2>
        </div>
        
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
          <div>
            <h3 style="margin: 0 0 10px 0; color: #333; font-size: 14px;">Cliente</h3>
            <p style="margin: 5px 0;"><strong>Nome:</strong> ${ordem.cliente?.nome || 'N/A'}</p>
            <p style="margin: 5px 0;"><strong>Telefone:</strong> ${ordem.cliente?.telefone || 'N/A'}</p>
            <p style="margin: 5px 0;"><strong>Email:</strong> ${ordem.cliente?.email || 'N/A'}</p>
          </div>
          
          <div>
            <h3 style="margin: 0 0 10px 0; color: #333; font-size: 14px;">Equipamento</h3>
            <p style="margin: 5px 0;"><strong>Tipo:</strong> ${ordem.tipo}</p>
            <p style="margin: 5px 0;"><strong>Marca:</strong> ${ordem.marca}</p>
            <p style="margin: 5px 0;"><strong>Modelo:</strong> ${ordem.modelo}</p>
            ${ordem.cor ? `<p style="margin: 5px 0;"><strong>Cor:</strong> ${ordem.cor}</p>` : ''}
            ${ordem.numero_serie ? `<p style="margin: 5px 0;"><strong>Nº Série:</strong> ${ordem.numero_serie}</p>` : ''}
          </div>
        </div>
        
        <div style="margin-bottom: 20px;">
          <h3 style="margin: 0 0 10px 0; color: #333; font-size: 14px;">Defeito Relatado</h3>
          <p style="margin: 0; padding: 10px; background: #f5f5f5; border-radius: 5px; font-size: 12px;">
            ${ordem.defeito_relatado || 'Não informado'}
          </p>
        </div>
        
        <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; margin-bottom: 20px;">
          <div>
            <h3 style="margin: 0 0 10px 0; color: #333; font-size: 14px;">Data Entrada</h3>
            <p style="margin: 0; font-size: 12px;">${new Date(ordem.data_entrada).toLocaleDateString('pt-BR')}</p>
          </div>
          
          <div>
            <h3 style="margin: 0 0 10px 0; color: #333; font-size: 14px;">Status</h3>
            <p style="margin: 0; font-weight: bold; color: ${ordem.status === 'Entregue' ? '#16a34a' : '#666'}; font-size: 12px;">
              ${statusEntregue}
            </p>
          </div>
          
          <div>
            <h3 style="margin: 0 0 10px 0; color: #333; font-size: 14px;">Valor</h3>
            <p style="margin: 0; font-weight: bold; font-size: 12px;">
              ${valorFinal.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })}
            </p>
          </div>
        </div>
        
        ${ordem.status === 'Entregue' && ordem.data_entrega ? `
          <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #ccc;">
            <h3 style="margin: 0 0 10px 0; color: #333; font-size: 14px;">Comprovante de Entrega</h3>
            <p style="margin: 5px 0; font-size: 12px;"><strong>Data de Entrega:</strong> ${new Date(ordem.data_entrega).toLocaleDateString('pt-BR')}</p>
            <div style="margin-top: 30px;">
              <p style="border-top: 1px solid #333; width: 300px; padding-top: 5px; margin-top: 50px; font-size: 10px;">
                Assinatura do Cliente
              </p>
            </div>
          </div>
        ` : ''}
        
        <div style="margin-top: 40px; text-align: center; font-size: 10px; color: #666;">
          <p>Impresso em ${new Date().toLocaleDateString('pt-BR')} às ${new Date().toLocaleTimeString('pt-BR')}</p>
        </div>
      </div>
    `
    
    // Layout para impressora térmica 80mm
    const layout80mm = `
      <div style="font-family: 'Courier New', monospace; width: 80mm; margin: 0 auto; padding: 5mm; font-size: 10px; line-height: 1.2;">
        <div style="text-align: center; margin-bottom: 10px; border-bottom: 1px dashed #333; padding-bottom: 8px;">
          <div style="font-size: 16px; font-weight: bold;">ORDEM DE SERVICO</div>
          <div style="font-size: 14px; margin-top: 2px;">#{ordem.id.slice(-6).toUpperCase()}</div>
        </div>
        
        <div style="margin-bottom: 8px;">
          <div style="font-weight: bold; font-size: 11px;">CLIENTE:</div>
          <div>${ordem.cliente?.nome || 'N/A'}</div>
          <div>Tel: ${ordem.cliente?.telefone || 'N/A'}</div>
        </div>
        
        <div style="border-top: 1px dashed #333; padding-top: 8px; margin-bottom: 8px;">
          <div style="font-weight: bold; font-size: 11px;">EQUIPAMENTO:</div>
          <div>${ordem.tipo} - ${ordem.marca} ${ordem.modelo}</div>
          ${ordem.cor ? `<div>Cor: ${ordem.cor}</div>` : ''}
          ${ordem.numero_serie ? `<div>Serie: ${ordem.numero_serie}</div>` : ''}
        </div>
        
        <div style="border-top: 1px dashed #333; padding-top: 8px; margin-bottom: 8px;">
          <div style="font-weight: bold; font-size: 11px;">DEFEITO:</div>
          <div style="word-wrap: break-word;">${ordem.defeito_relatado || 'Nao informado'}</div>
        </div>
        
        <div style="border-top: 1px dashed #333; padding-top: 8px; margin-bottom: 8px;">
          <div style="display: flex; justify-content: space-between;">
            <div>
              <div style="font-weight: bold; font-size: 9px;">ENTRADA:</div>
              <div style="font-size: 9px;">${new Date(ordem.data_entrada).toLocaleDateString('pt-BR')}</div>
            </div>
            <div style="text-align: right;">
              <div style="font-weight: bold; font-size: 9px;">STATUS:</div>
              <div style="font-size: 9px; font-weight: bold;">${statusEntregue}</div>
            </div>
          </div>
        </div>
        
        <div style="border-top: 1px dashed #333; padding-top: 8px; margin-bottom: 8px; text-align: center;">
          <div style="font-weight: bold; font-size: 12px;">VALOR: ${valorFinal.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })}</div>
        </div>
        
        ${ordem.status === 'Entregue' && ordem.data_entrega ? `
          <div style="border-top: 1px dashed #333; padding-top: 8px; margin-bottom: 8px;">
            <div style="font-weight: bold; font-size: 11px;">ENTREGUE EM:</div>
            <div>${new Date(ordem.data_entrega).toLocaleDateString('pt-BR')}</div>
            <div style="margin-top: 15px; border-top: 1px solid #333; padding-top: 3px; font-size: 8px; text-align: center;">
              ASSINATURA CLIENTE
            </div>
          </div>
        ` : ''}
        
        <div style="text-align: center; font-size: 8px; margin-top: 10px; border-top: 1px dashed #333; padding-top: 5px;">
          ${new Date().toLocaleDateString('pt-BR')} - ${new Date().toLocaleTimeString('pt-BR')}
        </div>
      </div>
    `
    
    // Layout para mini impressora 58mm
    const layout58mm = `
      <div style="font-family: 'Courier New', monospace; width: 58mm; margin: 0 auto; padding: 3mm; font-size: 9px; line-height: 1.1;">
        <div style="text-align: center; margin-bottom: 8px;">
          <div style="font-size: 14px; font-weight: bold;">O.S.</div>
          <div style="font-size: 12px;">#{ordem.id.slice(-6).toUpperCase()}</div>
        </div>
        
        <div style="border-top: 1px dashed #333; padding-top: 5px; margin-bottom: 6px;">
          <div style="font-weight: bold;">CLIENTE:</div>
          <div style="word-wrap: break-word;">${ordem.cliente?.nome || 'N/A'}</div>
          <div>Tel: ${ordem.cliente?.telefone || 'N/A'}</div>
        </div>
        
        <div style="border-top: 1px dashed #333; padding-top: 5px; margin-bottom: 6px;">
          <div style="font-weight: bold;">EQUIPAMENTO:</div>
          <div style="word-wrap: break-word;">${ordem.tipo}</div>
          <div style="word-wrap: break-word;">${ordem.marca} ${ordem.modelo}</div>
        </div>
        
        <div style="border-top: 1px dashed #333; padding-top: 5px; margin-bottom: 6px;">
          <div style="font-weight: bold;">DEFEITO:</div>
          <div style="word-wrap: break-word; font-size: 8px;">${ordem.defeito_relatado || 'Nao informado'}</div>
        </div>
        
        <div style="border-top: 1px dashed #333; padding-top: 5px; margin-bottom: 6px;">
          <div>ENTRADA: ${new Date(ordem.data_entrada).toLocaleDateString('pt-BR')}</div>
          <div>STATUS: <strong>${statusEntregue}</strong></div>
          <div style="text-align: center; font-weight: bold; margin-top: 3px;">
            ${valorFinal.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })}
          </div>
        </div>
        
        ${ordem.status === 'Entregue' && ordem.data_entrega ? `
          <div style="border-top: 1px dashed #333; padding-top: 5px; margin-bottom: 6px;">
            <div>ENTREGUE: ${new Date(ordem.data_entrega).toLocaleDateString('pt-BR')}</div>
            <div style="margin-top: 8px; border-top: 1px solid #333; padding-top: 2px; font-size: 7px; text-align: center;">
              ASSINATURA
            </div>
          </div>
        ` : ''}
        
        <div style="text-align: center; font-size: 7px; margin-top: 8px; border-top: 1px dashed #333; padding-top: 3px;">
          ${new Date().toLocaleDateString('pt-BR')}
        </div>
      </div>
    `
    
    // CSS para detecção automática do tipo de impressora
    const autoDetectionCSS = `
      <style>
        /* Layout padrão A4 */
        .layout-a4 { display: block; }
        .layout-80mm { display: none; }
        .layout-58mm { display: none; }
        
        /* Detecção para impressoras térmicas 80mm */
        @media print and (max-width: 85mm) {
          .layout-a4 { display: none; }
          .layout-80mm { display: block; }
          .layout-58mm { display: none; }
        }
        
        /* Detecção para mini impressoras 58mm */
        @media print and (max-width: 62mm) {
          .layout-a4 { display: none; }
          .layout-80mm { display: none; }
          .layout-58mm { display: block; }
        }
        
        /* Configurações gerais de impressão */
        @media print {
          body { margin: 0; padding: 0; }
          @page { margin: 0; size: auto; }
        }
        
        /* Configurações específicas por tamanho */
        @media print and (max-width: 85mm) {
          @page { 
            size: 80mm auto; 
            margin: 2mm; 
          }
        }
        
        @media print and (max-width: 62mm) {
          @page { 
            size: 58mm auto; 
            margin: 1mm; 
          }
        }
      </style>
    `
    
    const janela = window.open('', '_blank')
    if (janela) {
      janela.document.write(`
        <html>
          <head>
            <title>OS #${ordem.id.slice(-6).toUpperCase()}</title>
            <meta charset="utf-8">
            ${autoDetectionCSS}
          </head>
          <body>
            <div class="layout-a4">${layoutA4}</div>
            <div class="layout-80mm">${layout80mm}</div>
            <div class="layout-58mm">${layout58mm}</div>
            <script>
              window.onload = function() {
                setTimeout(function() {
                  window.print();
                }, 500);
              }
            </script>
          </body>
        </html>
      `)
      janela.document.close()
    } else {
      toast.error('Não foi possível abrir a janela de impressão')
    }
  }

  // Limpar filtros
  const limparFiltros = () => {
    setFiltros({})
  }

  if (mostrarFormulario) {
    return (
      <OrdemServicoForm
        onSuccess={() => {
          setMostrarFormulario(false)
          recarregar()
        }}
        onCancel={() => setMostrarFormulario(false)}
      />
    )
  }

  return (
    <div className="h-screen flex flex-col p-3 max-w-7xl mx-auto">
      
      {/* Header Compacto */}
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-3">
          <BackButton customAction={() => window.location.href = '/dashboard'}>
            Dashboard
          </BackButton>
          <h1 className="text-xl font-bold text-gray-900">Ordens de Serviço</h1>
        </div>
        
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => {
              console.log('🔄 Refresh manual...')
              recarregar()
              toast.success('Lista atualizada!')
            }}
            className="gap-1"
          >
            <RefreshCw className="w-3 h-3" />
            Atualizar
          </Button>
          
          <Button
            size="sm"
            onClick={() => setMostrarFormulario(true)}
            className="gap-1"
          >
            <Plus className="w-3 h-3" />
            Nova OS
          </Button>
        </div>
      </div>

      {/* Filtros - Sempre Visíveis */}
      <Card className="p-2">
          <div className="grid grid-cols-1 md:grid-cols-5 gap-2">
            <div>
              <label className="block text-xs font-medium text-gray-700 mb-1">
                Buscar
              </label>
              <div className="relative">
                <Search className="w-3 h-3 text-gray-400 absolute left-2 top-2.5" />
                <input
                  type="text"
                  placeholder="Cliente, marca..."
                  value={filtros.busca || ''}
                  onChange={(e) => aplicarFiltros({ busca: e.target.value })}
                  className="w-full pl-7 pr-2 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-700 mb-1">
                Status
              </label>
              <select
                value={filtros.status?.[0] || ''}
                onChange={(e) => aplicarFiltros({ 
                  status: e.target.value ? [e.target.value as StatusOS] : undefined 
                })}
                className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500"
              >
                <option value="">Todos</option>
                {STATUS_OPTIONS.map(status => (
                  <option key={status} value={status}>{status}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-700 mb-1">
                Tipo
              </label>
              <select
                value={filtros.tipo?.[0] || ''}
                onChange={(e) => aplicarFiltros({ 
                  tipo: e.target.value ? [e.target.value as TipoEquipamento] : undefined 
                })}
                className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500"
              >
                <option value="">Todos</option>
                {TIPO_OPTIONS.map(tipo => (
                  <option key={tipo} value={tipo}>{tipo}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-700 mb-1">
                Data
              </label>
              <input
                type="date"
                value={filtros.data_inicio || ''}
                onChange={(e) => aplicarFiltros({ data_inicio: e.target.value })}
                className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>

            <div className="flex items-end">
              <Button
                variant="outline"
                size="sm"
                onClick={limparFiltros}
                className="w-full text-xs"
              >
                Limpar
              </Button>
            </div>
          </div>
        </Card>

      {/* Estatísticas rápidas */}
      <StatusCardsOS />

      {/* Lista de Ordens - Otimizada */}
      <div className="flex-1 overflow-hidden">
        <Card className="h-full overflow-hidden">
          {loading ? (
            <div className="p-4 text-center">
              <RefreshCw className="w-5 h-5 text-blue-600 animate-spin mx-auto mb-1" />
              <p className="text-sm text-gray-600">Carregando...</p>
            </div>
          ) : ordens.length === 0 ? (
            <div className="p-4 text-center">
              <p className="text-sm text-gray-600 mb-2">Nenhuma ordem encontrada</p>
              <Button size="sm" onClick={() => setMostrarFormulario(true)} className="gap-1">
                <Plus className="w-3 h-3" />
                Criar OS
              </Button>
            </div>
          ) : (
            <div className="h-full overflow-auto">
              <table className="w-full text-sm">
                <thead className="bg-gray-50 sticky top-0">
                  <tr className="border-b">
                    <th className="text-left p-2 font-medium text-gray-700">ID</th>
                    <th className="text-left p-2 font-medium text-gray-700">Cliente</th>
                    <th className="text-left p-2 font-medium text-gray-700">Equipamento</th>
                    <th className="text-left p-2 font-medium text-gray-700">Status</th>
                    <th className="text-left p-2 font-medium text-gray-700">Entrada</th>
                    <th className="text-left p-2 font-medium text-gray-700">Valor</th>
                    <th className="text-center p-2 font-medium text-gray-700">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  {ordens.map((ordem) => (
                    <tr key={ordem.id} className="hover:bg-gray-50 border-b">
                      <td className="p-2">
                        <div className="text-xs font-medium text-gray-900">
                          #{ordem.id.slice(-6).toUpperCase()}
                        </div>
                      </td>
                      
                      <td className="p-2">
                        <div className="text-xs font-medium text-gray-900">
                          {ordem.cliente?.nome}
                        </div>
                        <div className="text-xs text-gray-500">
                          {ordem.cliente?.telefone}
                        </div>
                      </td>
                      
                      <td className="p-2">
                        <div className="text-xs font-medium text-gray-900">
                          {ordem.marca} {ordem.modelo}
                        </div>
                        <div className="text-xs text-gray-500">
                          {ordem.tipo}
                        </div>
                      </td>
                      
                      <td className="p-2">
                        {ordem.status === 'Entregue' ? (
                          <div className="inline-flex items-center px-2 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800 border border-green-500">
                            <span className="text-green-600 mr-1">✓</span>
                            Entregue
                          </div>
                        ) : (
                          <select
                            value={ordem.status}
                            onChange={(e) => atualizarStatus(ordem.id, e.target.value as StatusOS)}
                            disabled={atualizandoStatus === ordem.id}
                            className="text-xs px-1 py-1 border border-gray-300 rounded bg-white focus:outline-none focus:ring-1 focus:ring-blue-500"
                          >
                            {STATUS_OPTIONS.filter(status => status !== 'Entregue').map(status => (
                              <option key={status} value={status}>{status}</option>
                            ))}
                          </select>
                        )}
                      </td>
                      
                      <td className="p-2">
                        <div className="text-xs text-gray-900">
                          {new Date(ordem.data_entrada).toLocaleDateString('pt-BR')}
                        </div>
                      </td>
                      
                      <td className="p-2">
                        <div className="text-xs font-medium text-gray-900">
                          {(ordem.valor_final || ordem.valor_orcamento || 0).toLocaleString('pt-BR', { 
                            style: 'currency', 
                            currency: 'BRL' 
                          })}
                        </div>
                      </td>
                      
                      <td className="p-2">
                        <div className="flex gap-1 justify-center">
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={() => imprimirOrdem(ordem)}
                            className="h-6 w-6 p-0"
                          >
                            <Printer className="w-3 h-3" />
                          </Button>
                          
                          <Link to={`/ordem-servico/${ordem.id}`}>
                            <Button size="sm" variant="outline" className="h-6 w-6 p-0">
                              <Eye className="w-3 h-3" />
                            </Button>
                          </Link>
                          
                          {ordem.status !== 'Entregue' && (
                            <Link to={`/ordem-servico/${ordem.id}/editar`}>
                              <Button size="sm" variant="outline" className="h-6 w-6 p-0">
                                <Edit className="w-3 h-3" />
                              </Button>
                            </Link>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </Card>
      </div>
      
      {/* Formulário Modal */}
      {mostrarFormulario && (
        <OrdemServicoForm 
          onSuccess={() => {
            setMostrarFormulario(false)
            recarregar()
          }}
        />
      )}
    </div>
  )
}
