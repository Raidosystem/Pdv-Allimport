import { useState } from 'react'
import { 
  Settings, 
  Mail, 
  MessageCircle, 
  CheckCircle, 
  AlertTriangle, 
  TestTube,
  Save
} from 'lucide-react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'

/**
 * Página de Configuração de Integrações
 * Sistema PDV Allimport - Versão Simplificada
 */
export default function AdminIntegracoesPage() {
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState('smtp')
  
  const [configs, setConfigs] = useState({
    smtp: {
      ativo: false,
      host: '',
      port: '',
      username: '',
      password: '',
      from_email: '',
      from_name: ''
    },
    whatsapp: {
      ativo: false,
      api_url: '',
      api_token: '',
      phone_number: ''
    }
  })

  const integracoes = [
    {
      id: 'smtp',
      nome: 'Email (SMTP)',
      icon: <Mail className="w-5 h-5" />,
      descricao: 'Envie emails automáticos e notificações',
      status: configs.smtp.ativo ? 'ativo' : 'inativo'
    },
    {
      id: 'whatsapp',
      nome: 'WhatsApp',
      icon: <MessageCircle className="w-5 h-5" />,
      descricao: 'Envie mensagens e pedidos via WhatsApp',
      status: configs.whatsapp.ativo ? 'ativo' : 'inativo'
    }
  ]

  const handleSave = async (tipo: string) => {
    setLoading(true)
    try {
      await new Promise(resolve => setTimeout(resolve, 1000))
      console.log(`💾 Configuração ${tipo} salva:`, configs[tipo as keyof typeof configs])
    } catch (error) {
      console.error('❌ Erro ao salvar:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleTest = async (tipo: string) => {
    setLoading(true)
    try {
      await new Promise(resolve => setTimeout(resolve, 2000))
      console.log(`🧪 Teste ${tipo} executado`)
      alert(`Teste ${tipo} executado com sucesso!`)
    } catch (error) {
      console.error('❌ Erro no teste:', error)
      alert(`Erro no teste ${tipo}`)
    } finally {
      setLoading(false)
    }
  }

  const updateConfig = (tipo: string, field: string, value: any) => {
    setConfigs(prev => ({
      ...prev,
      [tipo]: {
        ...prev[tipo as keyof typeof prev],
        [field]: value
      }
    }))
  }

  const getStatusIcon = (status: string) => {
    return status === 'ativo' 
      ? <CheckCircle className="w-4 h-4 text-green-600" />
      : <AlertTriangle className="w-4 h-4 text-gray-400" />
  }

  const getStatusColor = (status: string) => {
    return status === 'ativo'
      ? 'text-green-600 bg-green-100'
      : 'text-gray-600 bg-gray-100'
  }



  const renderSMTPForm = () => (
    <div className="space-y-4">
      <div className="flex items-center gap-3 mb-4">
        <input
          type="checkbox"
          checked={configs.smtp.ativo}
          onChange={(e) => updateConfig('smtp', 'ativo', e.target.checked)}
          className="w-4 h-4 text-blue-600"
        />
        <label className="text-sm font-medium">Ativar integração SMTP</label>
      </div>
      
      <div className="grid md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Servidor SMTP
          </label>
          <input
            type="text"
            value={configs.smtp.host}
            onChange={(e) => updateConfig('smtp', 'host', e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="smtp.gmail.com"
          />
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Porta
          </label>
          <input
            type="number"
            value={configs.smtp.port}
            onChange={(e) => updateConfig('smtp', 'port', e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="587"
          />
        </div>
      </div>
      
      <div className="grid md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Usuário
          </label>
          <input
            type="email"
            value={configs.smtp.username}
            onChange={(e) => updateConfig('smtp', 'username', e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="usuario@gmail.com"
          />
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Senha
          </label>
          <input
            type="password"
            value={configs.smtp.password}
            onChange={(e) => updateConfig('smtp', 'password', e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="••••••••"
          />
        </div>
      </div>
      
      <div className="grid md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Email Remetente
          </label>
          <input
            type="email"
            value={configs.smtp.from_email}
            onChange={(e) => updateConfig('smtp', 'from_email', e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="noreply@empresa.com"
          />
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Nome Remetente
          </label>
          <input
            type="text"
            value={configs.smtp.from_name}
            onChange={(e) => updateConfig('smtp', 'from_name', e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="PDV Allimport"
          />
        </div>
      </div>
    </div>
  )

  const renderWhatsAppForm = () => (
    <div className="space-y-4">
      <div className="flex items-center gap-3 mb-4">
        <input
          type="checkbox"
          checked={configs.whatsapp.ativo}
          onChange={(e) => updateConfig('whatsapp', 'ativo', e.target.checked)}
          className="w-4 h-4 text-blue-600"
        />
        <label className="text-sm font-medium">Ativar integração WhatsApp</label>
      </div>
      
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          URL da API
        </label>
        <input
          type="url"
          value={configs.whatsapp.api_url}
          onChange={(e) => updateConfig('whatsapp', 'api_url', e.target.value)}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          placeholder="https://api.whatsapp.com"
        />
      </div>
      
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Token da API
        </label>
        <input
          type="password"
          value={configs.whatsapp.api_token}
          onChange={(e) => updateConfig('whatsapp', 'api_token', e.target.value)}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          placeholder="••••••••"
        />
      </div>
      
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Número do WhatsApp
        </label>
        <input
          type="tel"
          value={configs.whatsapp.phone_number}
          onChange={(e) => updateConfig('whatsapp', 'phone_number', e.target.value)}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          placeholder="+55 11 99999-9999"
        />
      </div>
    </div>
  )

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-gray-900">
          Configuração de Integrações
        </h1>
        <p className="text-gray-600 mt-1">
          Configure as integrações externas do sistema
        </p>
      </div>

      {/* Lista de Integrações */}
      <div className="grid md:grid-cols-3 gap-4">
        {integracoes.map((integracao) => (
          <div
            key={integracao.id}
            className={`p-4 cursor-pointer transition-colors border rounded-lg ${
              activeTab === integracao.id ? 'ring-2 ring-blue-500 bg-blue-50' : 'hover:bg-gray-50'
            }`}
            onClick={() => setActiveTab(integracao.id)}
          >
            <div className="flex items-center gap-3 mb-2">
              {integracao.icon}
              <h3 className="font-medium">{integracao.nome}</h3>
              {getStatusIcon(integracao.status)}
            </div>
            <p className="text-sm text-gray-600">{integracao.descricao}</p>
            <div className="mt-2">
              <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(integracao.status)}`}>
                {integracao.status === 'ativo' ? 'Ativo' : 'Inativo'}
              </span>
            </div>
          </div>
        ))}
      </div>

      {/* Formulário de Configuração */}
      <Card className="p-6">
        <div className="flex items-center gap-3 mb-6">
          <Settings className="w-6 h-6 text-gray-600" />
          <h2 className="text-lg font-semibold text-gray-900">
            Configuração - {integracoes.find(i => i.id === activeTab)?.nome}
          </h2>
        </div>

        {activeTab === 'smtp' && renderSMTPForm()}
        {activeTab === 'whatsapp' && renderWhatsAppForm()}

        <div className="flex gap-3 pt-6 border-t">
          <Button 
            onClick={() => handleSave(activeTab)}
            disabled={loading}
            className="gap-2"
          >
            <Save className="w-4 h-4" />
            {loading ? 'Salvando...' : 'Salvar Configuração'}
          </Button>
          
          <Button 
            variant="outline"
            onClick={() => handleTest(activeTab)}
            disabled={loading}
            className="gap-2"
          >
            <TestTube className="w-4 h-4" />
            {loading ? 'Testando...' : 'Testar Conexão'}
          </Button>
        </div>
      </Card>
    </div>
  )
}