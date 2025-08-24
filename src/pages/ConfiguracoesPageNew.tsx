import React, { useState } from 'react'
import { Settings, Building, Palette, Printer, Bell, Shield, Database, Wifi, Cloud, Save, Upload, Download, RefreshCw, Check, X, AlertTriangle } from 'lucide-react'

type ViewMode = 'dashboard' | 'empresa' | 'aparencia' | 'impressao' | 'notificacoes' | 'seguranca' | 'integracao'

interface ConfiguracaoEmpresa {
  nome: string
  razao_social: string
  cnpj: string
  endereco: string
  cidade: string
  cep: string
  telefone: string
  email: string
  site: string
  logo?: string
}

interface ConfiguracaoAparencia {
  tema: 'claro' | 'escuro' | 'automatico'
  cor_primaria: string
  cor_secundaria: string
  fonte: string
  tamanho_fonte: 'pequeno' | 'medio' | 'grande'
  animacoes: boolean
  sidebar_compacta: boolean
}

interface ConfiguracaoImpressao {
  impressora_padrao: string
  papel_tamanho: 'A4' | '80mm' | '58mm'
  margens: number
  impressao_automatica: boolean
  copias_recibo: number
  logo_recibo: boolean
  rodape_personalizado: string
}

// Interfaces para futuras implementações
// interface ConfiguracaoNotificacao {
//   email_vendas: boolean
//   email_estoque_baixo: boolean
//   email_backup: boolean
//   som_notificacao: boolean
//   popup_notificacao: boolean
//   webhook_url?: string
// }

// interface ConfiguracaoSeguranca {
//   senha_obrigatoria: boolean
//   tempo_sessao: number
//   login_duplo_fator: boolean
//   log_atividades: boolean
//   backup_automatico: boolean
//   frequencia_backup: 'diario' | 'semanal' | 'mensal'
// }

// interface ConfiguracaoIntegracao {
//   whatsapp_token?: string
//   email_smtp_host: string
//   email_smtp_porta: number
//   email_smtp_usuario: string
//   email_smtp_senha: string
//   api_cep_ativa: boolean
//   sincronizacao_nuvem: boolean
// }

export function ConfiguracoesPage() {
  const [viewMode, setViewMode] = useState<ViewMode>('dashboard')
  const [loading, setLoading] = useState(false)
  const [unsavedChanges, setUnsavedChanges] = useState(false)

  // Mock data para configurações
  const [configEmpresa, setConfigEmpresa] = useState<ConfiguracaoEmpresa>({
    nome: 'Allimport Technology',
    razao_social: 'Allimport Technology Ltda',
    cnpj: '12.345.678/0001-90',
    endereco: 'Rua das Tecnologias, 123',
    cidade: 'São Paulo, SP',
    cep: '01234-567',
    telefone: '(11) 99999-9999',
    email: 'contato@allimport.com.br',
    site: 'www.allimport.com.br',
    logo: undefined
  })

  const [configAparencia, setConfigAparencia] = useState<ConfiguracaoAparencia>({
    tema: 'claro',
    cor_primaria: '#3B82F6',
    cor_secundaria: '#10B981',
    fonte: 'Inter',
    tamanho_fonte: 'medio',
    animacoes: true,
    sidebar_compacta: false
  })

  const [configImpressao, setConfigImpressao] = useState<ConfiguracaoImpressao>({
    impressora_padrao: 'Impressora Térmica',
    papel_tamanho: '80mm',
    margens: 5,
    impressao_automatica: true,
    copias_recibo: 2,
    logo_recibo: true,
    rodape_personalizado: 'Obrigado pela preferência!'
  })

  // Mock data para configurações não implementadas nesta versão
  // const [configNotificacao, setConfigNotificacao] = useState<ConfiguracaoNotificacao>({
  //   email_vendas: true,
  //   email_estoque_baixo: true,
  //   email_backup: false,
  //   som_notificacao: true,
  //   popup_notificacao: true,
  //   webhook_url: ''
  // })

  // const [configSeguranca, setConfigSeguranca] = useState<ConfiguracaoSeguranca>({
  //   senha_obrigatoria: true,
  //   tempo_sessao: 480, // 8 horas
  //   login_duplo_fator: false,
  //   log_atividades: true,
  //   backup_automatico: true,
  //   frequencia_backup: 'diario'
  // })

  // const [configIntegracao, setConfigIntegracao] = useState<ConfiguracaoIntegracao>({
  //   whatsapp_token: '',
  //   email_smtp_host: 'smtp.gmail.com',
  //   email_smtp_porta: 587,
  //   email_smtp_usuario: 'sistema@allimport.com.br',
  //   email_smtp_senha: '',
  //   api_cep_ativa: true,
  //   sincronizacao_nuvem: false
  // })

  // Estatísticas do dashboard
  const stats = {
    configuracoes_ativas: 15,
    integracao_status: 'Conectado',
    ultimo_backup: '2024-01-20T02:00:00',
    espaco_utilizado: 2.4, // GB
    tempo_funcionamento: '15 dias, 8 horas',
    usuarios_conectados: 3,
    notificacoes_pendentes: 2,
    status_sistema: 'Normal'
  }

  const handleSave = async (categoria: string) => {
    setLoading(true)
    // Simular salvamento
    setTimeout(() => {
      setLoading(false)
      setUnsavedChanges(false)
      alert(`Configurações de ${categoria} salvas com sucesso!`)
    }, 1500)
  }

  const handleTestConnection = async (tipo: string) => {
    setLoading(true)
    setTimeout(() => {
      setLoading(false)
      alert(`Teste de conexão ${tipo} realizado com sucesso!`)
    }, 2000)
  }

  const handleExportConfig = () => {
    setLoading(true)
    setTimeout(() => {
      setLoading(false)
      alert('Configurações exportadas com sucesso!')
    }, 1000)
  }

  const handleImportConfig = () => {
    setLoading(true)
    setTimeout(() => {
      setLoading(false)
      alert('Configurações importadas com sucesso!')
    }, 1000)
  }

  const formatFileSize = (size: number) => {
    return `${size.toFixed(1)} GB`
  }

  const formatDateTime = (dateTime: string) => {
    return new Date(dateTime).toLocaleString('pt-BR')
  }

  // Card de Estatística
  const StatCard = ({ title, value, icon: Icon, color, subtitle, status }: {
    title: string
    value: string | number
    icon: React.ComponentType<any>
    color: string
    subtitle?: string
    status?: 'good' | 'warning' | 'danger'
  }) => (
    <div className={`bg-white p-6 rounded-lg shadow-sm border-l-4 ${color}`}>
      <div className="flex items-center">
        <div className="flex-shrink-0">
          <Icon className="h-6 w-6 text-gray-600" />
        </div>
        <div className="ml-5 w-0 flex-1">
          <dl>
            <dt className="text-sm font-medium text-gray-500 truncate">
              {title}
            </dt>
            <dd className="text-lg font-medium text-gray-900">
              {value}
            </dd>
            {subtitle && (
              <dd className="text-xs text-gray-500">{subtitle}</dd>
            )}
            {status && (
              <dd className={`text-xs font-medium mt-1 flex items-center gap-1 ${
                status === 'good' ? 'text-green-600' :
                status === 'warning' ? 'text-yellow-600' : 'text-red-600'
              }`}>
                {status === 'good' ? <Check className="h-3 w-3" /> :
                 status === 'warning' ? <AlertTriangle className="h-3 w-3" /> : 
                 <X className="h-3 w-3" />}
                {status === 'good' ? 'Normal' :
                 status === 'warning' ? 'Atenção' : 'Crítico'}
              </dd>
            )}
          </dl>
        </div>
      </div>
    </div>
  )

  // Dashboard principal
  const DashboardView = () => (
    <div className="space-y-6">
      {/* Estatísticas principais */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard 
          title="Configurações Ativas" 
          value={stats.configuracoes_ativas} 
          icon={Settings} 
          color="border-blue-500"
          subtitle="módulos configurados"
          status="good"
        />
        <StatCard 
          title="Status de Integração" 
          value={stats.integracao_status} 
          icon={Wifi} 
          color="border-green-500"
          status="good"
        />
        <StatCard 
          title="Último Backup" 
          value={formatDateTime(stats.ultimo_backup)} 
          icon={Database} 
          color="border-purple-500"
          status="good"
        />
        <StatCard 
          title="Espaço Utilizado" 
          value={formatFileSize(stats.espaco_utilizado)} 
          icon={Cloud} 
          color="border-orange-500"
          subtitle="de dados"
          status="good"
        />
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard 
          title="Tempo Funcionamento" 
          value={stats.tempo_funcionamento} 
          icon={RefreshCw} 
          color="border-cyan-500"
          status="good"
        />
        <StatCard 
          title="Usuários Conectados" 
          value={stats.usuarios_conectados} 
          icon={Building} 
          color="border-indigo-500"
          subtitle="ativos agora"
        />
        <StatCard 
          title="Notificações Pendentes" 
          value={stats.notificacoes_pendentes} 
          icon={Bell} 
          color="border-yellow-500"
          status={stats.notificacoes_pendentes > 0 ? "warning" : "good"}
        />
        <StatCard 
          title="Status do Sistema" 
          value={stats.status_sistema} 
          icon={Shield} 
          color="border-green-500"
          status="good"
        />
      </div>

      {/* Ações rápidas */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Ações Rápidas</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <button
            onClick={() => handleExportConfig()}
            disabled={loading}
            className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <Download className="h-8 w-8 text-blue-600 mb-2" />
            <span className="text-sm font-medium text-gray-900">Exportar Configurações</span>
            <span className="text-xs text-gray-500 mt-1">Backup das configurações</span>
          </button>

          <button
            onClick={() => handleImportConfig()}
            disabled={loading}
            className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <Upload className="h-8 w-8 text-green-600 mb-2" />
            <span className="text-sm font-medium text-gray-900">Importar Configurações</span>
            <span className="text-xs text-gray-500 mt-1">Restaurar backup</span>
          </button>

          <button
            onClick={() => handleTestConnection('Sistema')}
            disabled={loading}
            className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <Wifi className="h-8 w-8 text-purple-600 mb-2" />
            <span className="text-sm font-medium text-gray-900">Testar Conexões</span>
            <span className="text-xs text-gray-500 mt-1">Verificar integrações</span>
          </button>

          <button
            onClick={() => window.location.reload()}
            className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <RefreshCw className="h-8 w-8 text-orange-600 mb-2" />
            <span className="text-sm font-medium text-gray-900">Recarregar Sistema</span>
            <span className="text-xs text-gray-500 mt-1">Aplicar alterações</span>
          </button>
        </div>
      </div>
    </div>
  )

  // Configurações da empresa
  const EmpresaView = () => (
    <div className="bg-white rounded-lg shadow-sm">
      <div className="p-6 border-b">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold text-gray-900">Dados da Empresa</h3>
            <p className="text-gray-600 mt-1">Informações básicas da sua empresa</p>
          </div>
          <button
            onClick={() => handleSave('Empresa')}
            disabled={loading}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50 flex items-center gap-2"
          >
            {loading ? (
              <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent" />
            ) : (
              <Save className="h-4 w-4" />
            )}
            Salvar
          </button>
        </div>
      </div>
      
      <div className="p-6 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Nome da Empresa *
            </label>
            <input
              type="text"
              value={configEmpresa.nome}
              onChange={(e) => {
                setConfigEmpresa(prev => ({ ...prev, nome: e.target.value }))
                setUnsavedChanges(true)
              }}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Razão Social
            </label>
            <input
              type="text"
              value={configEmpresa.razao_social}
              onChange={(e) => {
                setConfigEmpresa(prev => ({ ...prev, razao_social: e.target.value }))
                setUnsavedChanges(true)
              }}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              CNPJ
            </label>
            <input
              type="text"
              value={configEmpresa.cnpj}
              onChange={(e) => {
                setConfigEmpresa(prev => ({ ...prev, cnpj: e.target.value }))
                setUnsavedChanges(true)
              }}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="00.000.000/0000-00"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Telefone
            </label>
            <input
              type="text"
              value={configEmpresa.telefone}
              onChange={(e) => {
                setConfigEmpresa(prev => ({ ...prev, telefone: e.target.value }))
                setUnsavedChanges(true)
              }}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="(00) 00000-0000"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Email
            </label>
            <input
              type="email"
              value={configEmpresa.email}
              onChange={(e) => {
                setConfigEmpresa(prev => ({ ...prev, email: e.target.value }))
                setUnsavedChanges(true)
              }}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Website
            </label>
            <input
              type="url"
              value={configEmpresa.site}
              onChange={(e) => {
                setConfigEmpresa(prev => ({ ...prev, site: e.target.value }))
                setUnsavedChanges(true)
              }}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="www.empresa.com.br"
            />
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Endereço Completo
          </label>
          <textarea
            rows={3}
            value={`${configEmpresa.endereco}\n${configEmpresa.cidade}\nCEP: ${configEmpresa.cep}`}
            onChange={(e) => {
              const lines = e.target.value.split('\n')
              setConfigEmpresa(prev => ({
                ...prev,
                endereco: lines[0] || '',
                cidade: lines[1] || '',
                cep: lines[2] ? lines[2].replace('CEP: ', '') : ''
              }))
              setUnsavedChanges(true)
            }}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="Rua, número, bairro&#10;Cidade, Estado&#10;CEP: 00000-000"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Logo da Empresa
          </label>
          <div className="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md">
            <div className="space-y-1 text-center">
              <Upload className="mx-auto h-12 w-12 text-gray-400" />
              <div className="flex text-sm text-gray-600">
                <label className="relative cursor-pointer bg-white rounded-md font-medium text-blue-600 hover:text-blue-500">
                  <span>Enviar arquivo</span>
                  <input type="file" className="sr-only" accept="image/*" />
                </label>
                <p className="pl-1">ou arraste e solte</p>
              </div>
              <p className="text-xs text-gray-500">PNG, JPG até 2MB</p>
            </div>
          </div>
        </div>

        {unsavedChanges && (
          <div className="bg-yellow-50 border border-yellow-200 rounded-md p-4">
            <div className="flex">
              <AlertTriangle className="h-5 w-5 text-yellow-400" />
              <div className="ml-3">
                <p className="text-sm text-yellow-800">
                  Você tem alterações não salvas. Clique em "Salvar" para aplicar as mudanças.
                </p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )

  // Configurações de aparência
  const AparenciaView = () => (
    <div className="bg-white rounded-lg shadow-sm">
      <div className="p-6 border-b">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold text-gray-900">Aparência e Interface</h3>
            <p className="text-gray-600 mt-1">Personalize a aparência do sistema</p>
          </div>
          <button
            onClick={() => handleSave('Aparência')}
            disabled={loading}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50 flex items-center gap-2"
          >
            {loading ? (
              <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent" />
            ) : (
              <Save className="h-4 w-4" />
            )}
            Salvar
          </button>
        </div>
      </div>
      
      <div className="p-6 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Tema
            </label>
            <select
              value={configAparencia.tema}
              onChange={(e) => setConfigAparencia(prev => ({ 
                ...prev, 
                tema: e.target.value as 'claro' | 'escuro' | 'automatico' 
              }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="claro">Claro</option>
              <option value="escuro">Escuro</option>
              <option value="automatico">Automático</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Tamanho da Fonte
            </label>
            <select
              value={configAparencia.tamanho_fonte}
              onChange={(e) => setConfigAparencia(prev => ({ 
                ...prev, 
                tamanho_fonte: e.target.value as 'pequeno' | 'medio' | 'grande' 
              }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="pequeno">Pequeno</option>
              <option value="medio">Médio</option>
              <option value="grande">Grande</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Cor Primária
            </label>
            <div className="flex items-center gap-3">
              <input
                type="color"
                value={configAparencia.cor_primaria}
                onChange={(e) => setConfigAparencia(prev => ({ ...prev, cor_primaria: e.target.value }))}
                className="w-12 h-10 border border-gray-300 rounded-lg cursor-pointer"
              />
              <input
                type="text"
                value={configAparencia.cor_primaria}
                onChange={(e) => setConfigAparencia(prev => ({ ...prev, cor_primaria: e.target.value }))}
                className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="#3B82F6"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Cor Secundária
            </label>
            <div className="flex items-center gap-3">
              <input
                type="color"
                value={configAparencia.cor_secundaria}
                onChange={(e) => setConfigAparencia(prev => ({ ...prev, cor_secundaria: e.target.value }))}
                className="w-12 h-10 border border-gray-300 rounded-lg cursor-pointer"
              />
              <input
                type="text"
                value={configAparencia.cor_secundaria}
                onChange={(e) => setConfigAparencia(prev => ({ ...prev, cor_secundaria: e.target.value }))}
                className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="#10B981"
              />
            </div>
          </div>
        </div>

        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <label className="text-sm font-medium text-gray-700">Animações</label>
              <p className="text-xs text-gray-500">Ativar efeitos de transição e animações</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={configAparencia.animacoes}
                onChange={(e) => setConfigAparencia(prev => ({ ...prev, animacoes: e.target.checked }))}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
            </label>
          </div>

          <div className="flex items-center justify-between">
            <div>
              <label className="text-sm font-medium text-gray-700">Sidebar Compacta</label>
              <p className="text-xs text-gray-500">Reduzir largura da barra lateral</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={configAparencia.sidebar_compacta}
                onChange={(e) => setConfigAparencia(prev => ({ ...prev, sidebar_compacta: e.target.checked }))}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
            </label>
          </div>
        </div>
      </div>
    </div>
  )

  // Configurações de impressão
  const ImpressaoView = () => (
    <div className="bg-white rounded-lg shadow-sm">
      <div className="p-6 border-b">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold text-gray-900">Configurações de Impressão</h3>
            <p className="text-gray-600 mt-1">Configure impressoras e layout de impressão</p>
          </div>
          <button
            onClick={() => handleSave('Impressão')}
            disabled={loading}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50 flex items-center gap-2"
          >
            {loading ? (
              <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent" />
            ) : (
              <Save className="h-4 w-4" />
            )}
            Salvar
          </button>
        </div>
      </div>
      
      <div className="p-6 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Impressora Padrão
            </label>
            <select
              value={configImpressao.impressora_padrao}
              onChange={(e) => setConfigImpressao(prev => ({ ...prev, impressora_padrao: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="Impressora Térmica">Impressora Térmica</option>
              <option value="HP LaserJet">HP LaserJet</option>
              <option value="Canon Pixma">Canon Pixma</option>
              <option value="Epson EcoTank">Epson EcoTank</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Tamanho do Papel
            </label>
            <select
              value={configImpressao.papel_tamanho}
              onChange={(e) => setConfigImpressao(prev => ({ 
                ...prev, 
                papel_tamanho: e.target.value as 'A4' | '80mm' | '58mm' 
              }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="A4">A4 (210 x 297 mm)</option>
              <option value="80mm">Térmica 80mm</option>
              <option value="58mm">Térmica 58mm</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Margens (mm)
            </label>
            <input
              type="number"
              min="0"
              max="20"
              value={configImpressao.margens}
              onChange={(e) => setConfigImpressao(prev => ({ ...prev, margens: parseInt(e.target.value) || 0 }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Cópias do Recibo
            </label>
            <input
              type="number"
              min="1"
              max="5"
              value={configImpressao.copias_recibo}
              onChange={(e) => setConfigImpressao(prev => ({ ...prev, copias_recibo: parseInt(e.target.value) || 1 }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Rodapé Personalizado
          </label>
          <textarea
            rows={2}
            value={configImpressao.rodape_personalizado}
            onChange={(e) => setConfigImpressao(prev => ({ ...prev, rodape_personalizado: e.target.value }))}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="Mensagem personalizada no rodapé dos recibos"
          />
        </div>

        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <label className="text-sm font-medium text-gray-700">Impressão Automática</label>
              <p className="text-xs text-gray-500">Imprimir recibos automaticamente após vendas</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={configImpressao.impressao_automatica}
                onChange={(e) => setConfigImpressao(prev => ({ ...prev, impressao_automatica: e.target.checked }))}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
            </label>
          </div>

          <div className="flex items-center justify-between">
            <div>
              <label className="text-sm font-medium text-gray-700">Logo no Recibo</label>
              <p className="text-xs text-gray-500">Incluir logo da empresa nos recibos</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={configImpressao.logo_recibo}
                onChange={(e) => setConfigImpressao(prev => ({ ...prev, logo_recibo: e.target.checked }))}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
            </label>
          </div>
        </div>
      </div>
    </div>
  )

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Configurações do Sistema</h1>
            <p className="text-gray-600 mt-1">
              Configure e personalize o sistema conforme suas necessidades
            </p>
          </div>
        </div>

        {/* Navegação por abas */}
        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex flex-wrap gap-2">
            <button
              onClick={() => setViewMode('dashboard')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                viewMode === 'dashboard'
                  ? 'bg-blue-100 text-blue-700 border border-blue-200'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <Settings className="h-4 w-4 inline mr-2" />
              Dashboard
            </button>
            <button
              onClick={() => setViewMode('empresa')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                viewMode === 'empresa'
                  ? 'bg-blue-100 text-blue-700 border border-blue-200'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <Building className="h-4 w-4 inline mr-2" />
              Empresa
            </button>
            <button
              onClick={() => setViewMode('aparencia')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                viewMode === 'aparencia'
                  ? 'bg-blue-100 text-blue-700 border border-blue-200'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <Palette className="h-4 w-4 inline mr-2" />
              Aparência
            </button>
            <button
              onClick={() => setViewMode('impressao')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                viewMode === 'impressao'
                  ? 'bg-blue-100 text-blue-700 border border-blue-200'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <Printer className="h-4 w-4 inline mr-2" />
              Impressão
            </button>
          </div>
        </div>

        {/* Conteúdo baseado na view selecionada */}
        <div className="animate-in fade-in duration-300">
          {viewMode === 'dashboard' && <DashboardView />}
          {viewMode === 'empresa' && <EmpresaView />}
          {viewMode === 'aparencia' && <AparenciaView />}
          {viewMode === 'impressao' && <ImpressaoView />}
        </div>
      </div>
    </div>
  )
}
