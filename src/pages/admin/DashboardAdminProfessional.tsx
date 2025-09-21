import { useState, useEffect } from 'react'
import { 
  Users, 
  Shield, 
  Database, 
  Settings, 
  TrendingUp,
  CheckCircle,
  AlertTriangle,
  Download,
  RefreshCw
} from 'lucide-react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { GuardProfessional } from '../../components/admin/GuardProfessional'
import type { DashboardStats } from '../../types/admin-professional'

/**
 * Dashboard Administrativo Profissional
 * Baseado no Blueprint Profissional do PDV Allimport
 */
export default function DashboardAdminProfessional() {
  const [stats] = useState<DashboardStats>({
    empresa: {
      nome: 'PDV Allimport',
      plano: 'Basic',
      ativo: true,
      usuarios_total: 1,
      usuarios_limite: 5
    },
    usuarios: {
      total: 1,
      ativos: 1,
      bloqueados: 0,
      pendentes: 0,
      convites: 0,
      online: 1
    },
    atividade_hoje: {
      logins: 1,
      acoes: 15,
      ultimo_backup: '2025-09-20'
    },
    sistema: {
      versao: 'v2.2.5',
      uptime: '8d 14h',
      atualizado: true,
      ultima_atualizacao: '2025-09-21'
    },
    integracoes: [
      { tipo: 'Mercado Pago', status: 'Não configurado' },
      { tipo: 'E-mail SMTP', status: 'Não configurado' },
      { tipo: 'WhatsApp API', status: 'Não configurado' }
    ],
    backups_recentes: []
  })

  const [loading, setLoading] = useState(false)

  // Mock de carregamento de dados (substituir por API real)
  useEffect(() => {
    // loadDashboardStats()
  }, [])

  const loadDashboardStats = async () => {
    setLoading(true)
    try {
      // const data = await dashboardAPI.obterStats()
      // setStats(data)
    } catch (error) {
      console.error('Erro ao carregar estatísticas:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <GuardProfessional perms={[]} need="dashboard.admin.read">
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-semibold text-gray-900">
            Dashboard Administrativo
          </h1>
          <Button
            variant="outline"
            onClick={loadDashboardStats}
            disabled={loading}
            className="gap-2"
          >
            <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
            Atualizar
          </Button>
        </div>

        {/* Cards de Status Principal */}
        <div className="grid md:grid-cols-4 gap-4">
          <Card className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm font-medium text-gray-500">Empresa</div>
                <div className="text-2xl font-bold text-gray-900">{stats.empresa.nome}</div>
                <div className="text-sm text-gray-600">
                  Plano {stats.empresa.plano} • {stats.empresa.ativo ? 'Ativo' : 'Suspenso'}
                </div>
              </div>
              <div className="p-3 bg-blue-100 rounded-lg">
                <Settings className="w-6 h-6 text-blue-600" />
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm font-medium text-gray-500">Usuários</div>
                <div className="text-2xl font-bold text-gray-900">
                  {stats.usuarios.ativos}/{stats.usuarios.total}
                </div>
                <div className="text-sm text-gray-600">
                  {stats.usuarios.convites} convites • {stats.usuarios.online} online
                </div>
              </div>
              <div className="p-3 bg-green-100 rounded-lg">
                <Users className="w-6 h-6 text-green-600" />
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm font-medium text-gray-500">Atividade Hoje</div>
                <div className="text-2xl font-bold text-gray-900">{stats.atividade_hoje.logins}</div>
                <div className="text-sm text-gray-600">
                  {stats.atividade_hoje.acoes} ações realizadas
                </div>
              </div>
              <div className="p-3 bg-purple-100 rounded-lg">
                <TrendingUp className="w-6 h-6 text-purple-600" />
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm font-medium text-gray-500">Sistema</div>
                <div className="text-2xl font-bold text-gray-900">{stats.sistema.versao}</div>
                <div className="text-sm text-gray-600">
                  Uptime: {stats.sistema.uptime}
                </div>
              </div>
              <div className="p-3 bg-orange-100 rounded-lg">
                <Database className="w-6 h-6 text-orange-600" />
              </div>
            </div>
          </Card>
        </div>

        {/* Status das Integrações */}
        <GuardProfessional perms={[]} need="integracoes.read">
          <Card className="p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Status das Integrações
            </h2>
            <div className="grid md:grid-cols-3 gap-4">
              {stats.integracoes.map((integracao) => (
                <div 
                  key={integracao.tipo}
                  className="rounded-xl border border-gray-200 p-4 hover:border-gray-300 transition-colors"
                >
                  <div className="flex items-center justify-between mb-2">
                    <div className="font-medium text-gray-900">{integracao.tipo}</div>
                    {integracao.status === 'Ativo' ? (
                      <CheckCircle className="w-5 h-5 text-green-500" />
                    ) : (
                      <AlertTriangle className="w-5 h-5 text-yellow-500" />
                    )}
                  </div>
                  <div className="text-sm text-gray-600 mb-3">{integracao.status}</div>
                  <div className="flex gap-2">
                    <Button size="sm" variant="outline" disabled>
                      Configurar
                    </Button>
                    <Button size="sm" variant="outline" disabled>
                      Testar
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          </Card>
        </GuardProfessional>

        {/* Backups Recentes */}
        <GuardProfessional perms={[]} need="backups.read">
          <Card className="p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-gray-900">
                Backups Recentes
              </h2>
              <Button size="sm" className="gap-2" disabled>
                <Database className="w-4 h-4" />
                Executar Backup
              </Button>
            </div>
            
            {stats.backups_recentes.length === 0 ? (
              <div className="text-center py-8 text-gray-500">
                <Database className="w-12 h-12 mx-auto mb-3 text-gray-300" />
                <div className="font-medium">Nenhum backup encontrado</div>
                <div className="text-sm">Execute seu primeiro backup para começar</div>
              </div>
            ) : (
              <div className="space-y-2">
                {stats.backups_recentes.map((backup) => (
                  <div 
                    key={backup.id}
                    className="flex items-center justify-between p-3 border border-gray-200 rounded-lg"
                  >
                    <div className="flex items-center gap-3">
                      <div className={`p-2 rounded-lg ${
                        backup.status === 'ok' ? 'bg-green-100 text-green-600' :
                        backup.status === 'erro' ? 'bg-red-100 text-red-600' :
                        'bg-yellow-100 text-yellow-600'
                      }`}>
                        <Database className="w-4 h-4" />
                      </div>
                      <div>
                        <div className="font-medium text-gray-900">
                          Backup {new Date(backup.created_at).toLocaleDateString()}
                        </div>
                        <div className="text-sm text-gray-600">
                          {backup.tamanho_mb ? `${backup.tamanho_mb} MB` : 'Processando...'}
                        </div>
                      </div>
                    </div>
                    <Button size="sm" variant="outline" disabled>
                      <Download className="w-4 h-4" />
                    </Button>
                  </div>
                ))}
              </div>
            )}
          </Card>
        </GuardProfessional>

        {/* Ações Rápidas */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Ações Rápidas
          </h2>
          <div className="flex flex-wrap gap-3">
            <Button variant="outline" className="gap-2" disabled>
              <Users className="w-4 h-4" />
              Gerenciar Usuários
            </Button>
            <Button variant="outline" className="gap-2" disabled>
              <Shield className="w-4 h-4" />
              Configurar Permissões
            </Button>
            <Button variant="outline" className="gap-2" disabled>
              <Database className="w-4 h-4" />
              Executar Backup
            </Button>
            <Button variant="outline" className="gap-2" disabled>
              <Settings className="w-4 h-4" />
              Configurações do Sistema
            </Button>
          </div>
        </Card>

        {/* Informações do Sistema */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Informações do Sistema
          </h2>
          <div className="grid md:grid-cols-2 gap-6">
            <div>
              <div className="text-sm font-medium text-gray-500 mb-2">Versão</div>
              <div className="text-lg font-medium text-gray-900 mb-1">{stats.sistema.versao}</div>
              <div className="text-sm text-gray-600">
                Última atualização: {stats.sistema.ultima_atualizacao}
              </div>
            </div>
            <div>
              <div className="text-sm font-medium text-gray-500 mb-2">Uptime</div>
              <div className="text-lg font-medium text-gray-900 mb-1">{stats.sistema.uptime}</div>
              <div className="text-sm text-gray-600">
                Sistema funcionando normalmente
              </div>
            </div>
          </div>
        </Card>
      </div>
    </GuardProfessional>
  )
}