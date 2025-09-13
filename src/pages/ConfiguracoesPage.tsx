import { useState } from 'react'
import { Link } from 'react-router-dom'
import { 
  Settings, 
  Database, 
  Shield, 
  User, 
  Bell, 
  Palette,
  ArrowLeft,
  ChevronRight,
  Crown
} from 'lucide-react'
import { Button } from '../components/ui/Button'
import { Card } from '../components/ui/Card'
import BackupManager from '../components/BackupManager'
import { useSubscription } from '../hooks/useSubscription'
import { SubscriptionStatus } from '../components/subscription/SubscriptionStatus'
import { SubscriptionCountdown } from '../components/subscription/SubscriptionCountdown'

type ConfigSection = 'dashboard' | 'backup' | 'import' | 'security' | 'profile' | 'notifications' | 'appearance' | 'subscription'

export function ConfiguracoesPage() {
  const [activeSection, setActiveSection] = useState<ConfigSection>('dashboard')
  const { isActive, isInTrial, daysRemaining } = useSubscription()

  const configSections = [
    {
      id: 'backup' as ConfigSection,
      title: 'Backup e Restauração',
      description: 'Gerencie backups dos seus dados',
      icon: Database,
      color: 'bg-blue-500'
    },
    {
      id: 'import' as ConfigSection,
      title: 'Importar Backup',
      description: 'Importar dados de backup anterior',
      icon: Database,
      color: 'bg-green-600'
    },
    {
      id: 'security' as ConfigSection,
      title: 'Segurança',
      description: 'Configurações de segurança',
      icon: Shield,
      color: 'bg-green-500'
    },
    {
      id: 'profile' as ConfigSection,
      title: 'Perfil do Usuário',
      description: 'Dados pessoais e preferências',
      icon: User,
      color: 'bg-purple-500'
    },
    {
      id: 'notifications' as ConfigSection,
      title: 'Notificações',
      description: 'Configurar alertas e avisos',
      icon: Bell,
      color: 'bg-yellow-500'
    },
    {
      id: 'appearance' as ConfigSection,
      title: 'Aparência',
      description: 'Tema e personalização visual',
      icon: Palette,
      color: 'bg-pink-500'
    },
    {
      id: 'subscription' as ConfigSection,
      title: 'Assinatura',
      description: 'Gerenciar plano e pagamentos',
      icon: Crown,
      color: 'bg-yellow-500'
    }
  ]

  const renderSectionContent = () => {
    switch (activeSection) {
      case 'subscription':
        return (
          <Card className="p-6">
            <div className="space-y-6">
              <div className="text-center space-y-4">
                <div className="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mx-auto">
                  <Crown className="w-8 h-8 text-yellow-600" />
                </div>
                <h3 className="text-xl font-semibold">Gerenciar Assinatura</h3>
                <p className="text-gray-600 max-w-md mx-auto">
                  Controle sua assinatura, visualize status e renove quando quiser.
                </p>
              </div>

              {/* Status da Assinatura */}
              <div className="flex justify-center space-x-4">
                <SubscriptionStatus />
                <SubscriptionCountdown />
              </div>

              {/* Informações detalhadas */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="p-4 bg-blue-50 rounded-lg">
                  <h4 className="font-medium text-blue-800 mb-2">📊 Status Atual</h4>
                  <p className="text-sm text-blue-700">
                    {isActive ? 'Assinatura ativa e funcionando' : 
                     isInTrial ? `Período de teste - ${daysRemaining} dias restantes` : 
                     'Assinatura inativa'}
                  </p>
                </div>
                
                <div className="p-4 bg-green-50 rounded-lg">
                  <h4 className="font-medium text-green-800 mb-2">✅ Benefícios Ativos</h4>
                  <ul className="text-sm text-green-700 space-y-1">
                    <li>• Sistema PDV completo</li>
                    <li>• Backup automático</li>
                    <li>• Suporte técnico</li>
                  </ul>
                </div>
              </div>

              {/* Botões de Ação */}
              <div className="space-y-4">
                {/* Botão principal - Gerenciar/Assinar */}
                <div className="text-center">
                  <Link to="/assinatura">
                    <Button className="bg-yellow-500 hover:bg-yellow-600 text-white px-8 py-3 gap-2">
                      <Crown className="w-5 h-5" />
                      {isActive ? 'Gerenciar Assinatura' : 'Assinar Agora'}
                    </Button>
                  </Link>
                </div>

                {/* Botão especial - Pagar Quando Quiser */}
                {(isActive || isInTrial) && (
                  <div className="p-4 bg-gradient-to-r from-purple-50 to-pink-50 rounded-lg border-2 border-purple-200">
                    <div className="text-center space-y-3">
                      <h4 className="font-semibold text-purple-800">💳 Pagar Quando Quiser</h4>
                      <p className="text-sm text-purple-700">
                        Quer renovar sua assinatura antes do vencimento? 
                        {isInTrial && ` Ainda restam ${daysRemaining} dias do seu teste.`}
                        {isActive && ` Sua assinatura está ativa, mas você pode renovar antecipadamente.`}
                      </p>
                      <Link to="/assinatura?action=renew">
                        <Button 
                          variant="outline" 
                          className="border-purple-300 text-purple-700 hover:bg-purple-50 gap-2"
                        >
                          <Crown className="w-4 h-4" />
                          Renovar Agora
                        </Button>
                      </Link>
                      <p className="text-xs text-purple-600">
                        💡 Ao renovar antecipadamente, o tempo restante será preservado
                      </p>
                    </div>
                  </div>
                )}
              </div>

              {/* Informações adicionais */}
              <div className="p-4 bg-gray-50 rounded-lg">
                <h4 className="font-medium text-gray-800 mb-2">ℹ️ Informações Importantes</h4>
                <ul className="text-sm text-gray-600 space-y-1">
                  <li>• Sua assinatura garante acesso completo ao sistema</li>
                  <li>• Backup automático de todos os seus dados</li>
                  <li>• Suporte técnico prioritário</li>
                  <li>• Atualizações automáticas e novas funcionalidades</li>
                  {isInTrial && <li>• <strong>Período de teste:</strong> Experimente sem compromisso</li>}
                </ul>
              </div>
            </div>
          </Card>
        )
      
      case 'backup':
        return <BackupManager />
      
      case 'import':
        return (
          <Card className="p-6">
            <div className="text-center space-y-4">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto">
                <Database className="w-8 h-8 text-green-600" />
              </div>
              <h3 className="text-xl font-semibold">Importar Backup Allimport</h3>
              <p className="text-gray-600 max-w-md mx-auto">
                Importe dados de backup do sistema anterior incluindo clientes, produtos, vendas e ordens de serviço.
              </p>
              <Link to="/import-backup">
                <Button className="bg-green-600 hover:bg-green-700 text-white px-8 py-3">
                  Ir para Importação
                </Button>
              </Link>
            </div>
          </Card>
        )
      
      case 'security':
        return (
          <Card className="p-6">
            <h3 className="text-lg font-semibold mb-4">Configurações de Segurança</h3>
            <div className="space-y-4">
              <div className="p-4 bg-green-50 rounded-lg border border-green-200">
                <h4 className="font-medium text-green-800 mb-2">✅ Privacidade Total Ativada</h4>
                <p className="text-green-700 text-sm">
                  Seus dados estão completamente isolados de outros usuários através do sistema RLS (Row Level Security).
                  Apenas você pode acessar seus próprios dados.
                </p>
              </div>
              <div className="p-4 bg-blue-50 rounded-lg border border-blue-200">
                <h4 className="font-medium text-blue-800 mb-2">🔐 Autenticação Segura</h4>
                <p className="text-blue-700 text-sm">
                  Sistema de autenticação gerenciado pelo Supabase com criptografia de ponta.
                </p>
              </div>
            </div>
          </Card>
        )
      
      case 'profile':
        return (
          <Card className="p-6">
            <h3 className="text-lg font-semibold mb-4">Perfil do Usuário</h3>
            <p className="text-gray-600">Configurações de perfil em desenvolvimento...</p>
          </Card>
        )
      
      case 'notifications':
        return (
          <Card className="p-6">
            <h3 className="text-lg font-semibold mb-4">Notificações</h3>
            <p className="text-gray-600">Configurações de notificações em desenvolvimento...</p>
          </Card>
        )
      
      case 'appearance':
        return (
          <Card className="p-6">
            <h3 className="text-lg font-semibold mb-4">Aparência</h3>
            <p className="text-gray-600">Configurações de aparência em desenvolvimento...</p>
          </Card>
        )
      
      default:
        return (
          <div className="space-y-6">
            <Card className="p-6">
              <h3 className="text-lg font-semibold mb-4">Configurações do Sistema</h3>
              <p className="text-gray-600 mb-6">
                Gerencie todas as configurações do seu sistema PDV Allimport.
              </p>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {configSections.map((section) => {
                  const Icon = section.icon
                  return (
                    <button
                      key={section.id}
                      onClick={() => setActiveSection(section.id)}
                      className="p-4 bg-white border border-gray-200 rounded-lg hover:border-gray-300 hover:shadow-sm transition-all text-left group"
                    >
                      <div className="flex items-center gap-3">
                        <div className={`w-10 h-10 ${section.color} rounded-lg flex items-center justify-center`}>
                          <Icon className="w-5 h-5 text-white" />
                        </div>
                        <div className="flex-1">
                          <h4 className="font-medium text-gray-900 group-hover:text-gray-700">
                            {section.title}
                          </h4>
                          <p className="text-sm text-gray-600">
                            {section.description}
                          </p>
                        </div>
                        <ChevronRight className="w-5 h-5 text-gray-400 group-hover:text-gray-600" />
                      </div>
                    </button>
                  )
                })}
              </div>
            </Card>

            {/* Botão destacado de Assinatura */}
            <Card className="p-6 bg-gradient-to-r from-yellow-50 to-orange-50 border-yellow-200">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 bg-yellow-500 rounded-lg flex items-center justify-center">
                    <Crown className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <h4 className="font-semibold text-gray-900">Status da Assinatura</h4>
                    <p className="text-sm text-gray-600">
                      {isActive 
                        ? `Assinatura ativa${isInTrial ? ` (Trial: ${daysRemaining} dias restantes)` : ''}`
                        : 'Assinatura inativa - Assine agora'
                      }
                    </p>
                  </div>
                </div>
                <div className="flex gap-3">
                  <Button
                    variant="outline"
                    onClick={() => setActiveSection('subscription')}
                    className="gap-2 border-yellow-500 text-yellow-700 hover:bg-yellow-50"
                  >
                    <Crown className="w-4 h-4" />
                    Ver Detalhes
                  </Button>
                  <Link to="/assinatura">
                    <Button className="gap-2 bg-yellow-500 hover:bg-yellow-600 text-white">
                      <Crown className="w-4 h-4" />
                      {isActive ? 'Renovar Antecipado' : 'Assinar Agora'}
                    </Button>
                  </Link>
                </div>
              </div>
            </Card>
          </div>
        )
    }
  }

  return (
    <div className="max-w-7xl mx-auto p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link
            to="/dashboard"
            className="flex items-center gap-2 text-gray-600 hover:text-gray-800 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
            <span>Dashboard</span>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-3">
              <Settings className="w-8 h-8 text-gray-700" />
              Configurações
            </h1>
            <p className="text-gray-600">
              {activeSection === 'dashboard' 
                ? 'Gerencie as configurações do seu sistema PDV'
                : configSections.find(s => s.id === activeSection)?.description
              }
            </p>
          </div>
        </div>
        
        {activeSection !== 'dashboard' && (
          <Button
            variant="outline"
            onClick={() => setActiveSection('dashboard')}
            className="gap-2"
          >
            <Settings className="w-4 h-4" />
            Voltar às Configurações
          </Button>
        )}
      </div>

      {/* Breadcrumb */}
      {activeSection !== 'dashboard' && (
        <div className="flex items-center gap-2 text-sm text-gray-600">
          <button 
            onClick={() => setActiveSection('dashboard')}
            className="hover:text-gray-800"
          >
            Configurações
          </button>
          <ChevronRight className="w-4 h-4" />
          <span className="text-gray-800">
            {configSections.find(s => s.id === activeSection)?.title}
          </span>
        </div>
      )}

      {/* Content */}
      {renderSectionContent()}
    </div>
  )
}
