import { useState, useEffect } from 'react'
import { 
  Settings, 
  CheckCircle, 
  AlertTriangle, 
  XCircle,
  TestTube,
  Eye,
  EyeOff,
  Save,
  CreditCard,
  Mail,
  MessageSquare
} from 'lucide-react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Input } from '../../components/ui/Input'
import { GuardProfessional } from '../../components/admin/GuardProfessional'
import type { 
  Integracao, 
  ConfigMercadoPago, 
  ConfigSMTP 
} from '../../types/admin-professional'

/**
 * Página de Gerenciamento de Integrações
 * Baseado no Blueprint Profissional do PDV Allimport
 */
export default function AdminIntegracoesPage() {
  const [integracoes, setIntegracoes] = useState<Integracao[]>([])
  const [loading, setLoading] = useState(false)
  const [editando, setEditando] = useState<string | null>(null)
  const [showPasswords, setShowPasswords] = useState<Record<string, boolean>>({})

  // Mock de dados (substituir por API real)
  useEffect(() => {
    loadIntegracoes()
  }, [])

  const loadIntegracoes = async () => {
    setLoading(true)
    try {
      // const data = await integracaoAPI.listar()
      // setIntegracoes(data)
      
      // Mock data
      setIntegracoes([
        {
          id: '1',
          empresa_id: '1',
          tipo: 'mercadopago',
          status: 'nao_configurado',
          config: {},
          updated_at: new Date().toISOString()
        },
        {
          id: '2',
          empresa_id: '1',
          tipo: 'smtp',
          status: 'nao_configurado',
          config: {},
          updated_at: new Date().toISOString()
        },
        {
          id: '3',
          empresa_id: '1',
          tipo: 'whatsapp',
          status: 'nao_configurado',
          config: {},
          updated_at: new Date().toISOString()
        }
      ])
    } catch (error) {
      console.error('Erro ao carregar integrações:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async (integracao: Integracao, config: any) => {
    setLoading(true)
    try {
      // await integracaoAPI.configurar({ tipo: integracao.tipo, config })
      console.log('Salvando configuração:', { tipo: integracao.tipo, config })
      
      setIntegracoes(prev => prev.map(i => 
        i.id === integracao.id 
          ? { ...i, config, status: 'configurado' as const, updated_at: new Date().toISOString() }
          : i
      ))
      setEditando(null)
    } catch (error) {
      console.error('Erro ao salvar configuração:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleTest = async (integracao: Integracao) => {
    setLoading(true)
    try {
      // const result = await integracaoAPI.testar(integracao.tipo)
      // console.log('Resultado do teste:', result)
      
      // Mock: simular teste bem-sucedido
      alert('Teste realizado com sucesso!')
      setIntegracoes(prev => prev.map(i => 
        i.id === integracao.id 
          ? { ...i, status: 'ativo' as const, teste_realizado_at: new Date().toISOString() }
          : i
      ))
    } catch (error) {
      console.error('Erro ao testar integração:', error)
      alert('Erro no teste da integração')
    } finally {
      setLoading(false)
    }
  }

  const getStatusIcon = (status: Integracao['status']) => {
    switch (status) {
      case 'ativo':
        return <CheckCircle className="w-5 h-5 text-green-500" />
      case 'configurado':
        return <AlertTriangle className="w-5 h-5 text-yellow-500" />
      case 'erro':
        return <XCircle className="w-5 h-5 text-red-500" />
      default:
        return <Settings className="w-5 h-5 text-gray-400" />
    }
  }

  const getStatusLabel = (status: Integracao['status']) => {
    switch (status) {
      case 'ativo': return 'Ativo'
      case 'configurado': return 'Configurado'
      case 'erro': return 'Erro'
      default: return 'Não configurado'
    }
  }

  const getIntegracaoIcon = (tipo: Integracao['tipo']) => {
    switch (tipo) {
      case 'mercadopago':
        return <CreditCard className="w-6 h-6 text-blue-600" />
      case 'smtp':
        return <Mail className="w-6 h-6 text-green-600" />
      case 'whatsapp':
        return <MessageSquare className="w-6 h-6 text-green-500" />
      default:
        return <Settings className="w-6 h-6 text-gray-600" />
    }
  }

  const getIntegracaoNome = (tipo: Integracao['tipo']) => {
    switch (tipo) {
      case 'mercadopago': return 'Mercado Pago'
      case 'smtp': return 'E-mail SMTP'
      case 'whatsapp': return 'WhatsApp API'
      default: return tipo
    }
  }

  const togglePasswordVisibility = (field: string) => {
    setShowPasswords(prev => ({ ...prev, [field]: !prev[field] }))
  }

  const renderMercadoPagoConfig = (integracao: Integracao) => {
    const config = integracao.config as ConfigMercadoPago
    const [formData, setFormData] = useState<ConfigMercadoPago>({
      access_token: config.access_token || '',
      public_key: config.public_key || '',
      client_id: config.client_id || '',
      client_secret: config.client_secret || '',
      webhook_secret: config.webhook_secret || '',
      ambiente: config.ambiente || 'sandbox'
    })

    return (
      <div className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Ambiente
          </label>
          <select
            value={formData.ambiente}
            onChange={(e) => setFormData(prev => ({ ...prev, ambiente: e.target.value as 'sandbox' | 'production' }))}
            className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="sandbox">Sandbox (Teste)</option>
            <option value="production">Production (Produção)</option>
          </select>
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Access Token
          </label>
          <div className="relative">
            <Input
              type={showPasswords.mp_access_token ? 'text' : 'password'}
              value={formData.access_token}
              onChange={(e) => setFormData(prev => ({ ...prev, access_token: e.target.value }))}
              placeholder="APP_USR-..."
            />
            <button
              type="button"
              onClick={() => togglePasswordVisibility('mp_access_token')}
              className="absolute right-3 top-1/2 transform -translate-y-1/2"
            >
              {showPasswords.mp_access_token ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
            </button>
          </div>
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Public Key
          </label>
          <Input
            type="text"
            value={formData.public_key}
            onChange={(e) => setFormData(prev => ({ ...prev, public_key: e.target.value }))}
            placeholder="APP_USR-..."
          />
        </div>
        
        <div className="flex gap-3">
          <Button 
            onClick={() => handleSave(integracao, formData)}
            loading={loading}
            className="gap-2"
          >
            <Save className="w-4 h-4" />
            Salvar
          </Button>
          <Button 
            variant="outline" 
            onClick={() => setEditando(null)}
          >
            Cancelar
          </Button>
        </div>
      </div>
    )
  }

  const renderSMTPConfig = (integracao: Integracao) => {
    const config = integracao.config as ConfigSMTP
    const [formData, setFormData] = useState<ConfigSMTP>({
      host: config.host || '',
      port: config.port || 587,
      secure: config.secure || false,
      auth: {
        user: config.auth?.user || '',
        pass: config.auth?.pass || ''
      },
      from_email: config.from_email || '',
      from_name: config.from_name || 'PDV Allimport'
    })

    return (
      <div className="space-y-4">
        <div className="grid md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Servidor SMTP
            </label>
            <Input
              type="text"
              value={formData.host}
              onChange={(e) => setFormData(prev => ({ ...prev, host: e.target.value }))}
              placeholder="smtp.gmail.com"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Porta
            </label>
            <Input
              type="number"
              value={formData.port}
              onChange={(e) => setFormData(prev => ({ ...prev, port: parseInt(e.target.value) }))}
              placeholder="587"
            />
          </div>
        </div>
        
        <div className="grid md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Usuário
            </label>
            <Input
              type="email"
              value={formData.auth?.user}
              onChange={(e) => setFormData(prev => ({ 
                ...prev, 
                auth: { ...prev.auth, user: e.target.value }
              }))}
              placeholder="usuario@gmail.com"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Senha
            </label>
            <div className="relative">
              <Input
                type={showPasswords.smtp_password ? 'text' : 'password'}
                value={formData.auth?.pass}
                onChange={(e) => setFormData(prev => ({ 
                  ...prev, 
                  auth: { ...prev.auth, pass: e.target.value }
                }))}
                placeholder="senha ou app password"
              />
              <button
                type="button"
                onClick={() => togglePasswordVisibility('smtp_password')}
                className="absolute right-3 top-1/2 transform -translate-y-1/2"
              >
                {showPasswords.smtp_password ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
          </div>
        </div>
        
        <div className="flex gap-3">
          <Button 
            onClick={() => handleSave(integracao, formData)}
            loading={loading}
            className="gap-2"
          >
            <Save className="w-4 h-4" />
            Salvar
          </Button>
          <Button 
            variant="outline" 
            onClick={() => setEditando(null)}
          >
            Cancelar
          </Button>
        </div>
      </div>
    )
  }

  return (
    <GuardProfessional perms={[]} need="integracoes.read">
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-semibold text-gray-900">
            Integrações
          </h1>
          <p className="text-gray-600">
            Configure as integrações externas do sistema
          </p>
        </div>

        <div className="grid gap-6">
          {integracoes.map((integracao) => (
            <Card key={integracao.id} className="p-6">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-gray-100 rounded-lg">
                    {getIntegracaoIcon(integracao.tipo)}
                  </div>
                  
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">
                      {getIntegracaoNome(integracao.tipo)}
                    </h3>
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      {getStatusIcon(integracao.status)}
                      <span>{getStatusLabel(integracao.status)}</span>
                      {integracao.teste_realizado_at && (
                        <span>• Testado em {new Date(integracao.teste_realizado_at).toLocaleDateString()}</span>
                      )}
                    </div>
                  </div>
                </div>
                
                <div className="flex gap-2">
                  {integracao.status !== 'nao_configurado' && (
                    <GuardProfessional perms={[]} need="integracoes.test">
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleTest(integracao)}
                        disabled={loading}
                        className="gap-2"
                      >
                        <TestTube className="w-4 h-4" />
                        Testar
                      </Button>
                    </GuardProfessional>
                  )}
                  
                  <GuardProfessional perms={[]} need="integracoes.write">
                    <Button
                      size="sm"
                      onClick={() => setEditando(editando === integracao.id ? null : integracao.id)}
                      className="gap-2"
                    >
                      <Settings className="w-4 h-4" />
                      {editando === integracao.id ? 'Fechar' : 'Configurar'}
                    </Button>
                  </GuardProfessional>
                </div>
              </div>
              
              {editando === integracao.id && (
                <div className="border-t border-gray-200 pt-4">
                  {integracao.tipo === 'mercadopago' && renderMercadoPagoConfig(integracao)}
                  {integracao.tipo === 'smtp' && renderSMTPConfig(integracao)}
                  {integracao.tipo === 'whatsapp' && (
                    <div className="text-center py-8 text-gray-500">
                      <MessageSquare className="w-12 h-12 mx-auto mb-3 text-gray-300" />
                      <div className="font-medium">Configuração em desenvolvimento</div>
                      <div className="text-sm">WhatsApp API será disponibilizada em breve</div>
                    </div>
                  )}
                </div>
              )}
              
              {integracao.ultimo_erro && (
                <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg">
                  <div className="flex items-start gap-2">
                    <XCircle className="w-5 h-5 text-red-500 mt-0.5" />
                    <div>
                      <div className="font-medium text-red-800">Último erro:</div>
                      <div className="text-sm text-red-700">{integracao.ultimo_erro}</div>
                    </div>
                  </div>
                </div>
              )}
            </Card>
          ))}
        </div>
      </div>
    </GuardProfessional>
  )
}