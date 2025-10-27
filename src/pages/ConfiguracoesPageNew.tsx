import React, { useState, useEffect, useCallback } from 'react'
import { Settings, Building, Palette, Printer, Bell, Shield, Database, Wifi, Cloud, Save, RefreshCw, Check, X, Crown, AlertTriangle, Sun, Moon, FileText, Edit, Eye, EyeOff } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useSubscription } from '../hooks/useSubscription'
import { useAppearanceSettings } from '../hooks/useAppearanceSettings'
import { useEmpresaSettings } from '../hooks/useEmpresaSettings'
import { usePermissions } from '../hooks/usePermissions'
import { EmpresaView } from '../components/EmpresaView'
import toast from 'react-hot-toast'

type ViewMode = 'dashboard' | 'empresa' | 'aparencia' | 'impressao' | 'notificacoes' | 'seguranca' | 'integracao' | 'assinatura'

interface ConfiguracaoEmpresa {
  nome: string
  razao_social: string
  cnpj: string
  cep: string
  logradouro: string
  numero: string
  complemento: string
  bairro: string
  cidade: string
  estado: string
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
  // Configurações de fonte
  fonte_tamanho: 'pequena' | 'media' | 'grande'
  fonte_intensidade: 'normal' | 'medio' | 'forte'
  fonte_negrito: boolean
  // Cabeçalho e Rodapé personalizados
  cabecalho_personalizado: string
  rodape_linha1: string
  rodape_linha2: string
  rodape_linha3: string
  rodape_linha4: string
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

// Componente de Modal de Rodapé isolado
const ModalRodape = React.memo(({ 
  isOpen, 
  onClose, 
  linha1, 
  linha2, 
  linha3, 
  linha4,
  onSave 
}: { 
  isOpen: boolean
  onClose: () => void
  linha1: string
  linha2: string
  linha3: string
  linha4: string
  onSave: (l1: string, l2: string, l3: string, l4: string) => void
}) => {
  const [temp1, setTemp1] = useState(linha1)
  const [temp2, setTemp2] = useState(linha2)
  const [temp3, setTemp3] = useState(linha3)
  const [temp4, setTemp4] = useState(linha4)

  useEffect(() => {
    if (isOpen) {
      setTemp1(linha1)
      setTemp2(linha2)
      setTemp3(linha3)
      setTemp4(linha4)
    }
  }, [isOpen, linha1, linha2, linha3, linha4])

  if (!isOpen) return null

  return (
    <div 
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      onClick={onClose}
    >
      <div 
        className="bg-white rounded-lg max-w-2xl w-full shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="p-6 border-b">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <FileText className="w-6 h-6 text-green-600" />
              <div>
                <h3 className="text-lg font-semibold text-gray-900">Editar Rodapé do Recibo</h3>
                <p className="text-sm text-gray-600">Personalize até 4 linhas no rodapé dos recibos</p>
              </div>
            </div>
            <button
              type="button"
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>
        
        <div className="p-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Linha 1
            </label>
            <input
              type="text"
              value={temp1}
              onChange={(e) => setTemp1(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
              placeholder="Ex: Obrigado pela preferência!"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Linha 2
            </label>
            <input
              type="text"
              value={temp2}
              onChange={(e) => setTemp2(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
              placeholder="Ex: Volte sempre!"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Linha 3
            </label>
            <input
              type="text"
              value={temp3}
              onChange={(e) => setTemp3(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
              placeholder="Ex: www.allimport.com.br"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Linha 4
            </label>
            <input
              type="text"
              value={temp4}
              onChange={(e) => setTemp4(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
              placeholder="Ex: WhatsApp: (11) 99999-9999"
            />
          </div>

          <div className="bg-green-50 border border-green-200 rounded-lg p-3">
            <p className="text-xs text-green-700">
              💡 <strong>Dica:</strong> Use essas linhas para informações de contato, redes sociais, horário de funcionamento ou mensagens especiais.
            </p>
          </div>
        </div>

        <div className="p-6 border-t bg-gray-50 flex justify-end gap-3">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-100"
          >
            Cancelar
          </button>
          <button
            type="button"
            onClick={() => {
              onSave(temp1, temp2, temp3, temp4)
              onClose()
            }}
            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
          >
            Salvar Rodapé
          </button>
        </div>
      </div>
    </div>
  )
})

ModalRodape.displayName = 'ModalRodape'

export function ConfiguracoesPage() {
  const [viewMode, setViewMode] = useState<ViewMode>('dashboard')
  const [loading, setLoading] = useState(false)
  const [unsavedChanges, setUnsavedChanges] = useState(false)
  const { isActive, isInTrial, daysRemaining } = useSubscription()
  const { can } = usePermissions()
  
  // Hook de configurações de aparência
  const { settings: appearanceSettings, saveSettings, loading: loadingAppearance } = useAppearanceSettings()
  
  // Hook de configurações da empresa
  const { 
    settings: empresaSettings, 
    saveSettings: saveEmpresa, 
    uploadLogo,
    loading: loadingEmpresa,
    uploading: uploadingLogo
  } = useEmpresaSettings()
  
  // Estado local para edição de aparência
  const [configAparencia, setConfigAparencia] = useState<ConfiguracaoAparencia>({
    ...appearanceSettings,
    fonte: 'Inter' // Adicionado campo que falta
  })

  // Estado local para edição de empresa
  const [configEmpresa, setConfigEmpresa] = useState<ConfiguracaoEmpresa>({
    nome: '',
    razao_social: '',
    cnpj: '',
    telefone: '',
    email: '',
    site: '',
    cep: '',
    logradouro: '',
    numero: '',
    complemento: '',
    bairro: '',
    cidade: '',
    estado: '',
    logo: undefined
  })

  // Sincronizar estado local quando as configurações carregarem
  useEffect(() => {
    if (!loadingAppearance) {
      setConfigAparencia({
        ...appearanceSettings,
        fonte: 'Inter'
      })
    }
  }, [appearanceSettings, loadingAppearance])

  // Sincronizar dados da empresa e carregar configurações salvas
  useEffect(() => {
    if (!loadingEmpresa && empresaSettings.nome) {
      setConfigEmpresa(empresaSettings)
      
      // PRIMEIRO: Carregar do localStorage (tem prioridade)
      try {
        const savedConfig = localStorage.getItem('print_config');
        if (savedConfig) {
          const config = JSON.parse(savedConfig);
          console.log('📋 Carregando configurações salvas do localStorage:', config);
          
          setConfigImpressao(prev => ({
            ...prev,
            ...config
          }));
          return; // Se tem config salva, não usa os dados da empresa
        }
      } catch (error) {
        console.error('Erro ao carregar configurações de impressão:', error);
      }
      
      // SEGUNDO: Se NÃO tem config salva, usar dados da empresa como padrão
      setConfigImpressao(prev => ({
        ...prev,
        cabecalho_personalizado: gerarCabecalhoEmpresa(empresaSettings)
      }))
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [loadingEmpresa])

  // Função para gerar cabeçalho com dados da empresa
  const gerarCabecalhoEmpresa = (empresa: ConfiguracaoEmpresa) => {
    const partes = []
    
    if (empresa.nome) partes.push(empresa.nome.toUpperCase())
    if (empresa.razao_social && empresa.razao_social !== empresa.nome) {
      partes.push(empresa.razao_social)
    }
    if (empresa.cnpj) partes.push(`CNPJ: ${empresa.cnpj}`)
    
    const endereco = []
    if (empresa.logradouro) endereco.push(empresa.logradouro)
    if (empresa.numero) endereco.push(`Nº ${empresa.numero}`)
    if (empresa.bairro) endereco.push(empresa.bairro)
    if (endereco.length > 0) partes.push(endereco.join(', '))
    
    if (empresa.cidade && empresa.estado) {
      partes.push(`${empresa.cidade} - ${empresa.estado}`)
    }
    
    const contatos = []
    if (empresa.telefone) contatos.push(`Tel: ${empresa.telefone}`)
    if (empresa.email) contatos.push(empresa.email)
    if (contatos.length > 0) partes.push(contatos.join(' | '))
    
    return partes.join('\n')
  }

  const [configImpressao, setConfigImpressao] = useState<ConfiguracaoImpressao>({
    impressora_padrao: 'Impressora Térmica',
    papel_tamanho: '80mm',
    margens: 5,
    impressao_automatica: true,
    copias_recibo: 2,
    logo_recibo: true,
    rodape_personalizado: 'Obrigado pela preferência!',
    // Configurações de fonte
    fonte_tamanho: 'media',
    fonte_intensidade: 'normal',
    fonte_negrito: false,
    // Cabeçalho e Rodapé
    cabecalho_personalizado: 'PDV ALLIMPORT - Eletrônicos e Acessórios',
    rodape_linha1: 'Obrigado pela preferência!',
    rodape_linha2: 'Volte sempre!',
    rodape_linha3: 'www.allimport.com.br',
    rodape_linha4: 'WhatsApp: (11) 99999-9999'
  })

  // Estados para os modais
  const [modalCabecalhoOpen, setModalCabecalhoOpen] = useState(false)
  const [modalRodapeOpen, setModalRodapeOpen] = useState(false)
  
  // Estados locais temporários para edição no modal de cabeçalho
  const [tempCabecalho, setTempCabecalho] = useState('')

  // Handler memorizado para cabeçalho
  const handleTempCabecalhoChange = useCallback((e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setTempCabecalho(e.target.value)
  }, [])

  // Salvar configurações de impressão no localStorage automaticamente
  useEffect(() => {
    try {
      const printConfig = {
        // Textos personalizados
        cabecalho_personalizado: configImpressao.cabecalho_personalizado,
        rodape_linha1: configImpressao.rodape_linha1,
        rodape_linha2: configImpressao.rodape_linha2,
        rodape_linha3: configImpressao.rodape_linha3,
        rodape_linha4: configImpressao.rodape_linha4,
        // Configurações de fonte
        fonte_tamanho: configImpressao.fonte_tamanho,
        fonte_intensidade: configImpressao.fonte_intensidade,
        fonte_negrito: configImpressao.fonte_negrito,
        // Outras configurações
        papel_tamanho: configImpressao.papel_tamanho,
        logo_recibo: configImpressao.logo_recibo
      };
      localStorage.setItem('print_config', JSON.stringify(printConfig));
      console.log('✅ Configurações de impressão salvas:', printConfig);
    } catch (error) {
      console.error('Erro ao salvar configurações de impressão:', error);
    }
  }, [
    configImpressao.cabecalho_personalizado,
    configImpressao.rodape_linha1,
    configImpressao.rodape_linha2,
    configImpressao.rodape_linha3,
    configImpressao.rodape_linha4,
    configImpressao.fonte_tamanho,
    configImpressao.fonte_intensidade,
    configImpressao.fonte_negrito,
    configImpressao.papel_tamanho,
    configImpressao.logo_recibo
  ])

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

  // Estatísticas do dashboard - calculadas dinamicamente
  const stats = {
    configuracoes_ativas: [
      empresaSettings.nome,
      appearanceSettings.tema,
      configImpressao.impressora_padrao
    ].filter(Boolean).length,
    integracao_status: isActive ? 'Conectado' : 'Ativo',
    ultimo_backup: new Date().toISOString(),
    espaco_utilizado: empresaSettings.logo ? 0.5 : 0.1, // GB (estimativa)
    tempo_funcionamento: isActive 
      ? `${Math.floor(daysRemaining)} dias ativos`
      : isInTrial 
        ? `${daysRemaining} dias restantes (Trial)`
        : '0 dias',
    usuarios_conectados: 1, // Usuário atual sempre conectado
    notificacoes_pendentes: !empresaSettings.nome ? 1 : 0, // Aviso se não configurou empresa
    status_sistema: isActive || isInTrial ? 'Ativo' : 'Normal'
  }

  // Auto-save para tema (aplica imediatamente)
  const handleTemaChange = async (tema: 'claro' | 'escuro' | 'automatico') => {
    const novasConfig = { ...configAparencia, tema }
    setConfigAparencia(novasConfig)
    
    // Salvar automaticamente
    const result = await saveSettings(novasConfig)
    
    if (result.success) {
      toast.success(`Tema ${tema} ativado!`, { duration: 2000 })
    }
  }

  // Auto-save para tamanho de fonte (aplica imediatamente)
  const handleFonteChange = async (tamanho_fonte: 'pequeno' | 'medio' | 'grande') => {
    const novasConfig = { ...configAparencia, tamanho_fonte }
    setConfigAparencia(novasConfig)
    
    // Salvar automaticamente
    const result = await saveSettings(novasConfig)
    
    if (result.success) {
      const labels = { pequeno: 'Pequena', medio: 'Média', grande: 'Grande' }
      toast.success(`Fonte ${labels[tamanho_fonte]} ativada!`, { duration: 2000 })
    }
  }

  // Auto-save para animações (aplica imediatamente)
  const handleAnimacoesChange = async (animacoes: boolean) => {
    const novasConfig = { ...configAparencia, animacoes }
    setConfigAparencia(novasConfig)
    
    // Salvar automaticamente
    const result = await saveSettings(novasConfig)
    
    if (result.success) {
      toast.success(animacoes ? 'Animações ativadas!' : 'Animações desativadas!', { duration: 2000 })
    }
  }

  // Auto-save para sidebar compacta (aplica imediatamente)
  const handleSidebarChange = async (sidebar_compacta: boolean) => {
    const novasConfig = { ...configAparencia, sidebar_compacta }
    setConfigAparencia(novasConfig)
    
    // Salvar automaticamente
    const result = await saveSettings(novasConfig)
    
    if (result.success) {
      toast.success(sidebar_compacta ? 'Sidebar compacta ativada!' : 'Sidebar expandida!', { duration: 2000 })
    }
  }

  const handleSave = async (categoria: string) => {
    setLoading(true)
    
    try {
      if (categoria === 'Aparência') {
        // Salvar configurações de aparência
        const result = await saveSettings(configAparencia)
        
        if (result.success) {
          toast.success('Configurações de aparência salvas com sucesso!')
          setUnsavedChanges(false)
        } else {
          toast.error('Erro ao salvar configurações')
        }
      } else if (categoria === 'Empresa') {
        // Validar campos obrigatórios
        if (!configEmpresa.nome.trim()) {
          toast.error('Nome da empresa é obrigatório')
          setLoading(false)
          return
        }

        // Salvar configurações da empresa
        const result = await saveEmpresa(configEmpresa)
        
        if (result.success) {
          toast.success('Dados da empresa salvos com sucesso!')
          setUnsavedChanges(false)
        } else {
          toast.error('Erro ao salvar dados da empresa')
        }
      } else {
        // Simular salvamento de outras categorias
        setTimeout(() => {
          toast.success(`Configurações de ${categoria} salvas com sucesso!`)
          setUnsavedChanges(false)
        }, 500)
      }
    } catch (error) {
      console.error('Erro ao salvar:', error)
      toast.error('Erro ao salvar configurações')
    } finally {
      setLoading(false)
    }
  }

  // Função para upload de logo
  const handleLogoUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    const result = await uploadLogo(file)
    
    if (result.success && result.url) {
      setConfigEmpresa(prev => ({ ...prev, logo: result.url }))
      setUnsavedChanges(true)
      toast.success('Logo enviada com sucesso!')
    } else {
      toast.error(result.error || 'Erro ao enviar logo')
    }
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

    </div>
  )

  // Handlers para mudanças nos campos da empresa
  const handleEmpresaChange = (field: keyof ConfiguracaoEmpresa, value: string) => {
    setConfigEmpresa(prev => ({ ...prev, [field]: value }))
    setUnsavedChanges(true)
  }

  // Configurações de aparência
  const AparenciaView = () => (
    <div className="bg-white rounded-lg shadow-sm">
      <div className="p-6 border-b">
        <div>
          <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Aparência e Interface</h3>
          <p className="text-gray-600 dark:text-gray-400 mt-1">Personalize a aparência do sistema (mudanças são salvas automaticamente)</p>
        </div>
      </div>
      
      <div className="p-6 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Tema com ícones visuais */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
              Tema
            </label>
            <div className="flex gap-3">
              <button
                type="button"
                onClick={() => handleTemaChange('claro')}
                className={`flex-1 flex flex-col items-center justify-center gap-2 p-4 rounded-lg border-2 transition-all ${
                  configAparencia.tema === 'claro'
                    ? 'border-blue-500 bg-blue-50 text-blue-700 dark:bg-blue-900 dark:text-blue-200'
                    : 'border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500 text-gray-600 dark:text-gray-300'
                }`}
              >
                <Sun className="w-6 h-6" />
                <span className="text-sm font-medium">Claro</span>
              </button>
              
              <button
                type="button"
                onClick={() => handleTemaChange('escuro')}
                className={`flex-1 flex flex-col items-center justify-center gap-2 p-4 rounded-lg border-2 transition-all ${
                  configAparencia.tema === 'escuro'
                    ? 'border-blue-500 bg-blue-50 text-blue-700 dark:bg-blue-900 dark:text-blue-200'
                    : 'border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500 text-gray-600 dark:text-gray-300'
                }`}
              >
                <Moon className="w-6 h-6" />
                <span className="text-sm font-medium">Escuro</span>
              </button>
            </div>
          </div>

          {/* Tamanho da Fonte com letras P, M, G */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
              Tamanho da Fonte
            </label>
            <div className="flex gap-3">
              <button
                type="button"
                onClick={() => handleFonteChange('pequeno')}
                className={`flex-1 flex flex-col items-center justify-center gap-2 p-4 rounded-lg border-2 transition-all ${
                  configAparencia.tamanho_fonte === 'pequeno'
                    ? 'border-blue-500 bg-blue-50 text-blue-700 dark:bg-blue-900 dark:text-blue-200'
                    : 'border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500 text-gray-600 dark:text-gray-300'
                }`}
              >
                <span className="text-2xl font-bold">P</span>
                <span className="text-xs font-medium">Pequeno</span>
              </button>
              
              <button
                type="button"
                onClick={() => handleFonteChange('medio')}
                className={`flex-1 flex flex-col items-center justify-center gap-2 p-4 rounded-lg border-2 transition-all ${
                  configAparencia.tamanho_fonte === 'medio'
                    ? 'border-blue-500 bg-blue-50 text-blue-700 dark:bg-blue-900 dark:text-blue-200'
                    : 'border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500 text-gray-600 dark:text-gray-300'
                }`}
              >
                <span className="text-3xl font-bold">M</span>
                <span className="text-xs font-medium">Médio</span>
              </button>
              
              <button
                type="button"
                onClick={() => handleFonteChange('grande')}
                className={`flex-1 flex flex-col items-center justify-center gap-2 p-4 rounded-lg border-2 transition-all ${
                  configAparencia.tamanho_fonte === 'grande'
                    ? 'border-blue-500 bg-blue-50 text-blue-700 dark:bg-blue-900 dark:text-blue-200'
                    : 'border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500 text-gray-600 dark:text-gray-300'
                }`}
              >
                <span className="text-4xl font-bold">G</span>
                <span className="text-xs font-medium">Grande</span>
              </button>
            </div>
          </div>
        </div>

        <div className="space-y-4">
          <div className="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
            <div>
              <label className="text-sm font-medium text-gray-700 dark:text-gray-300">Animações</label>
              <p className="text-xs text-gray-500 dark:text-gray-400">Ativar efeitos de transição e animações</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={configAparencia.animacoes}
                onChange={(e) => handleAnimacoesChange(e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 dark:bg-gray-700 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
            </label>
          </div>

          <div className="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
            <div>
              <label className="text-sm font-medium text-gray-700 dark:text-gray-300">Sidebar Compacta</label>
              <p className="text-xs text-gray-500 dark:text-gray-400">Reduzir largura da barra lateral</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={configAparencia.sidebar_compacta}
                onChange={(e) => handleSidebarChange(e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 dark:bg-gray-700 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
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

        {/* Cards de Cabeçalho e Rodapé */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* Card Cabeçalho */}
          <button
            type="button"
            onClick={() => {
              setTempCabecalho(configImpressao.cabecalho_personalizado)
              setModalCabecalhoOpen(true)
            }}
            className="p-6 border-2 border-gray-300 hover:border-blue-500 rounded-lg transition-all text-left group hover:shadow-md"
          >
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <FileText className="w-5 h-5 text-blue-600" />
                <h4 className="font-semibold text-gray-900">Cabeçalho do Recibo</h4>
              </div>
              <Edit className="w-4 h-4 text-gray-400 group-hover:text-blue-600" />
            </div>
            
            {/* Preview do Cabeçalho */}
            <div className="bg-gray-50 rounded-lg p-3 mb-3 min-h-[100px] border border-gray-200">
              {configImpressao.cabecalho_personalizado ? (
                <pre className="text-xs text-gray-700 font-mono whitespace-pre-wrap break-words line-clamp-4">
                  {configImpressao.cabecalho_personalizado}
                </pre>
              ) : (
                <p className="text-xs text-gray-400 italic">Nenhum cabeçalho configurado</p>
              )}
            </div>
            
            <span className="text-xs text-blue-600 mt-2 flex items-center gap-1">
              <Edit className="w-3 h-3" />
              Clique para editar
            </span>
          </button>

          {/* Card Rodapé */}
          <button
            type="button"
            onClick={() => setModalRodapeOpen(true)}
            className="p-6 border-2 border-gray-300 hover:border-green-500 rounded-lg transition-all text-left group hover:shadow-md"
          >
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <FileText className="w-5 h-5 text-green-600" />
                <h4 className="font-semibold text-gray-900">Rodapé do Recibo</h4>
              </div>
              <Edit className="w-4 h-4 text-gray-400 group-hover:text-green-600" />
            </div>
            
            {/* Preview do Rodapé */}
            <div className="bg-gray-50 rounded-lg p-3 mb-3 min-h-[100px] border border-gray-200">
              {configImpressao.rodape_linha1 || configImpressao.rodape_linha2 || configImpressao.rodape_linha3 || configImpressao.rodape_linha4 ? (
                <div className="text-xs text-gray-700 space-y-1">
                  {configImpressao.rodape_linha1 && (
                    <div className="flex items-start gap-2">
                      <span className="text-gray-400 font-mono">1.</span>
                      <span className="flex-1">{configImpressao.rodape_linha1}</span>
                    </div>
                  )}
                  {configImpressao.rodape_linha2 && (
                    <div className="flex items-start gap-2">
                      <span className="text-gray-400 font-mono">2.</span>
                      <span className="flex-1">{configImpressao.rodape_linha2}</span>
                    </div>
                  )}
                  {configImpressao.rodape_linha3 && (
                    <div className="flex items-start gap-2">
                      <span className="text-gray-400 font-mono">3.</span>
                      <span className="flex-1">{configImpressao.rodape_linha3}</span>
                    </div>
                  )}
                  {configImpressao.rodape_linha4 && (
                    <div className="flex items-start gap-2">
                      <span className="text-gray-400 font-mono">4.</span>
                      <span className="flex-1">{configImpressao.rodape_linha4}</span>
                    </div>
                  )}
                </div>
              ) : (
                <p className="text-xs text-gray-400 italic">Nenhum rodapé configurado</p>
              )}
            </div>
            
            <span className="text-xs text-green-600 mt-2 flex items-center gap-1">
              <Edit className="w-3 h-3" />
              Clique para editar (4 linhas)
            </span>
          </button>
        </div>

        {/* Seção de Configuração de Fonte */}
        <div className="border-t pt-6">
          <h4 className="text-md font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <span>🖨️</span> Qualidade de Impressão
          </h4>
          <p className="text-sm text-gray-600 mb-4">
            Ajuste a fonte para melhorar a legibilidade na sua impressora
          </p>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Tamanho da Fonte */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tamanho da Fonte
              </label>
              <select
                value={configImpressao.fonte_tamanho}
                onChange={(e) => setConfigImpressao(prev => ({ 
                  ...prev, 
                  fonte_tamanho: e.target.value as 'pequena' | 'media' | 'grande'
                }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="pequena">Pequena (9pt)</option>
                <option value="media">Média (11pt)</option>
                <option value="grande">Grande (13pt)</option>
              </select>
            </div>

            {/* Intensidade da Cor */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Intensidade da Cor
              </label>
              <select
                value={configImpressao.fonte_intensidade}
                onChange={(e) => setConfigImpressao(prev => ({ 
                  ...prev, 
                  fonte_intensidade: e.target.value as 'normal' | 'medio' | 'forte'
                }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="normal">Normal (Economia)</option>
                <option value="medio">Médio (Balanceado)</option>
                <option value="forte">Forte (Máxima Qualidade)</option>
              </select>
            </div>

            {/* Negrito */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Texto em Negrito
              </label>
              <div className="flex items-center h-10 px-4 border border-gray-300 rounded-lg bg-gray-50">
                <label className="flex items-center cursor-pointer w-full justify-between">
                  <span className="text-sm text-gray-700">
                    {configImpressao.fonte_negrito ? 'Ativado' : 'Desativado'}
                  </span>
                  <input
                    type="checkbox"
                    checked={configImpressao.fonte_negrito}
                    onChange={(e) => setConfigImpressao(prev => ({ ...prev, fonte_negrito: e.target.checked }))}
                    className="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500"
                  />
                </label>
              </div>
            </div>
          </div>

          {/* Preview da Configuração */}
          <div className="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <div className="flex items-start gap-3">
              <div className="text-blue-600 mt-0.5">💡</div>
              <div className="flex-1">
                <p className="text-sm font-medium text-blue-900">Dica de Configuração</p>
                <p className="text-xs text-blue-700 mt-1">
                  Para impressoras com tinta fraca: use <strong>Intensidade Forte</strong> e ative o <strong>Negrito</strong>. 
                  Para melhor legibilidade, escolha <strong>Fonte Grande</strong>.
                </p>
              </div>
            </div>
          </div>
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

      {/* Modal de Cabeçalho */}
      {modalCabecalhoOpen && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
          onClick={() => {
            setModalCabecalhoOpen(false)
            setTempCabecalho('')
          }}
        >
          <div 
            className="bg-white rounded-lg max-w-2xl w-full shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="p-6 border-b">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <FileText className="w-6 h-6 text-blue-600" />
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">Editar Cabeçalho do Recibo</h3>
                    <p className="text-sm text-gray-600">Personalize o texto que aparece no topo dos recibos</p>
                  </div>
                </div>
                <button
                  onClick={() => {
                    setModalCabecalhoOpen(false)
                    setTempCabecalho('')
                  }}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
            </div>
            
            <div className="p-6 space-y-4">
              {/* Informação sobre dados da empresa */}
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <div className="flex items-start gap-3">
                  <div className="text-blue-600 mt-0.5">ℹ️</div>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-blue-900 mb-1">Dados carregados da sua empresa</p>
                    <p className="text-xs text-blue-700">
                      As informações abaixo foram carregadas automaticamente dos dados cadastrados na seção 
                      <strong> Dados da Empresa</strong>. Você pode editar livremente o cabeçalho do recibo como preferir.
                    </p>
                  </div>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Texto do Cabeçalho
                </label>
                <textarea
                  rows={8}
                  value={tempCabecalho}
                  onChange={handleTempCabecalhoChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 font-mono text-sm"
                  placeholder="Ex: PDV ALLIMPORT - Eletrônicos e Acessórios"
                />
                <p className="text-xs text-gray-500 mt-2">
                  💡 Este texto aparecerá no topo de todos os recibos impressos. Use quebras de linha para organizar as informações.
                </p>
              </div>

              {/* Botão para recarregar dados da empresa */}
              <button
                type="button"
                onClick={() => {
                  setTempCabecalho(gerarCabecalhoEmpresa(configEmpresa))
                  toast.success('Dados da empresa recarregados!')
                }}
                className="text-sm text-blue-600 hover:text-blue-700 flex items-center gap-2"
              >
                <RefreshCw className="w-4 h-4" />
                Recarregar dados da empresa
              </button>
            </div>

            <div className="p-6 border-t bg-gray-50 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => {
                  setModalCabecalhoOpen(false)
                  setTempCabecalho('')
                }}
                className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-100"
              >
                Cancelar
              </button>
              <button
                type="button"
                onClick={() => {
                  setConfigImpressao(prev => ({ ...prev, cabecalho_personalizado: tempCabecalho }))
                  setModalCabecalhoOpen(false)
                  setTempCabecalho('')
                  toast.success('Cabeçalho atualizado!')
                }}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
              >
                Salvar Cabeçalho
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal de Rodapé */}
      <ModalRodape
        isOpen={modalRodapeOpen}
        onClose={() => setModalRodapeOpen(false)}
        linha1={configImpressao.rodape_linha1}
        linha2={configImpressao.rodape_linha2}
        linha3={configImpressao.rodape_linha3}
        linha4={configImpressao.rodape_linha4}
        onSave={(l1, l2, l3, l4) => {
          setConfigImpressao(prev => ({
            ...prev,
            rodape_linha1: l1,
            rodape_linha2: l2,
            rodape_linha3: l3,
            rodape_linha4: l4
          }))
          toast.success('Rodapé atualizado!')
        }}
      />
    </div>
  )

  // Configurações de assinatura
  const AssinaturaView = () => (
    <div className="bg-white p-6 rounded-lg shadow-sm">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">Gerenciar Assinatura</h3>
          <p className="text-gray-600 mt-1">Controle sua assinatura e pagamentos</p>
        </div>
      </div>

      <div className="space-y-6">
        {/* Status da assinatura */}
        <div className="p-4 bg-gradient-to-r from-yellow-50 to-orange-50 border border-yellow-200 rounded-lg">
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
              <Link to="/assinatura">
                <button className="px-4 py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-lg flex items-center gap-2 transition-colors">
                  <Crown className="w-4 h-4" />
                  {isActive ? 'Renovar Antecipado' : 'Assinar Agora'}
                </button>
              </Link>
            </div>
          </div>
        </div>

        {/* Informações da assinatura */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="p-4 bg-gray-50 rounded-lg">
            <h4 className="font-medium text-gray-900 mb-2">Plano Atual</h4>
            <p className="text-sm text-gray-600">
              {isActive ? 'Plano Premium' : 'Sem plano ativo'}
            </p>
            <p className="text-xs text-gray-500 mt-1">
              R$ 59,90/mês
            </p>
          </div>

          <div className="p-4 bg-gray-50 rounded-lg">
            <h4 className="font-medium text-gray-900 mb-2">Próximo Vencimento</h4>
            <p className="text-sm text-gray-600">
              {isActive 
                ? `${daysRemaining} dias restantes`
                : 'Nenhum plano ativo'
              }
            </p>
            <p className="text-xs text-gray-500 mt-1">
              Renovação automática disponível
            </p>
          </div>
        </div>

        {/* Benefícios */}
        <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <h4 className="font-medium text-gray-900 mb-3">Benefícios da Assinatura</h4>
          <ul className="space-y-2 text-sm text-gray-600">
            <li className="flex items-center gap-2">
              <Check className="w-4 h-4 text-green-500" />
              Acesso completo ao sistema PDV
            </li>
            <li className="flex items-center gap-2">
              <Check className="w-4 h-4 text-green-500" />
              Backup automático dos dados
            </li>
            <li className="flex items-center gap-2">
              <Check className="w-4 h-4 text-green-500" />
              Suporte técnico prioritário
            </li>
            <li className="flex items-center gap-2">
              <Check className="w-4 h-4 text-green-500" />
              Atualizações automáticas
            </li>
          </ul>
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
            {/* Dashboard - Azul (Controle/Gestão) */}
            {can('configuracoes.dashboard', 'read') && (
              <button
                onClick={() => setViewMode('dashboard')}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  viewMode === 'dashboard'
                    ? 'bg-blue-100 text-blue-700 border-2 border-blue-400'
                    : 'bg-blue-50 text-blue-600 hover:bg-blue-100 border border-blue-200'
                }`}
              >
                <Settings className="h-4 w-4 inline mr-2" />
                Dashboard
              </button>
            )}
            
            {/* Empresa - Verde (Negócio/Crescimento) */}
            {can('configuracoes.empresa', 'read') && (
              <button
                onClick={() => setViewMode('empresa')}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  viewMode === 'empresa'
                    ? 'bg-green-100 text-green-700 border-2 border-green-400'
                    : 'bg-green-50 text-green-600 hover:bg-green-100 border border-green-200'
                }`}
              >
                <Building className="h-4 w-4 inline mr-2" />
                Empresa
              </button>
            )}
            
            {/* Aparência - Roxo (Criatividade/Design) */}
            {can('configuracoes.aparencia', 'read') && (
              <button
                onClick={() => setViewMode('aparencia')}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  viewMode === 'aparencia'
                    ? 'bg-purple-100 text-purple-700 border-2 border-purple-400'
                    : 'bg-purple-50 text-purple-600 hover:bg-purple-100 border border-purple-200'
                }`}
              >
                <Palette className="h-4 w-4 inline mr-2" />
                Aparência
              </button>
            )}
            
            {/* Impressão - Laranja (Ação/Produção) */}
            {can('configuracoes.impressao', 'read') && (
              <button
                onClick={() => setViewMode('impressao')}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  viewMode === 'impressao'
                    ? 'bg-orange-100 text-orange-700 border-2 border-orange-400'
                    : 'bg-orange-50 text-orange-600 hover:bg-orange-100 border border-orange-200'
                }`}
              >
                <Printer className="h-4 w-4 inline mr-2" />
                Impressão
              </button>
            )}
            
            {/* Assinatura - Amarelo/Dourado (Premium/Valor) */}
            {can('configuracoes.assinatura', 'read') && (
              <button
                onClick={() => setViewMode('assinatura')}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  viewMode === 'assinatura'
                    ? 'bg-yellow-100 text-yellow-700 border-2 border-yellow-400'
                    : 'bg-yellow-50 text-yellow-600 hover:bg-yellow-100 border border-yellow-200'
                }`}
              >
                <Crown className="h-4 w-4 inline mr-2" />
                Assinatura
              </button>
            )}
          </div>
        </div>

        {/* Conteúdo baseado na view selecionada */}
        <div className="animate-in fade-in duration-300">
          {viewMode === 'dashboard' && <DashboardView />}
          {viewMode === 'empresa' && (
            <EmpresaView
              configEmpresa={configEmpresa}
              loading={loading}
              uploadingLogo={uploadingLogo}
              unsavedChanges={unsavedChanges}
              onEmpresaChange={handleEmpresaChange}
              onLogoUpload={handleLogoUpload}
              onSave={() => handleSave('Empresa')}
            />
          )}
          {viewMode === 'aparencia' && <AparenciaView />}
          {viewMode === 'impressao' && <ImpressaoView />}
          {viewMode === 'assinatura' && <AssinaturaView />}
        </div>
      </div>
    </div>
  )
}
