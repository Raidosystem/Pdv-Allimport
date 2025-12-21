import React, { useState, useEffect } from 'react';
import { 
  Globe,
  Shield,
  RefreshCw,
  Save,
  Monitor,
  Bell
} from 'lucide-react';
import { usePermissions } from '../../hooks/usePermissions';
import { supabase } from '../../lib/supabase';

interface SystemSettings {
  empresa: {
    nome: string;
    logo_url?: string;
    cores: {
      primaria: string;
      secundaria: string;
      texto: string;
    };
    timezone: string;
    moeda: string;
    idioma: string;
  };
  pdv: {
    permitir_venda_sem_cliente: boolean;
    permitir_desconto_maximo: number;
    imprimir_automatico: boolean;
    fechar_caixa_automatico: boolean;
    validar_cpf_cnpj: boolean;
  };
  integracoes: {
    email: {
      smtp_host: string;
      smtp_port: number;
      smtp_user: string;
      smtp_password: string;
      ssl_enabled: boolean;
    };
    whatsapp: {
      api_url: string;
      api_token: string;
      numero_padrao: string;
      envio_automatico: boolean;
    };
    mercado_pago: {
      access_token: string;
      public_key: string;
      webhook_url: string;
      sandbox_mode: boolean;
    };
  };
  notificacoes: {
    email_vendas: boolean;
    email_estoque_baixo: boolean;
    whatsapp_os_status: boolean;
    whatsapp_vendas: boolean;
  };
  seguranca: {
    sessao_timeout_minutos: number;
    login_max_tentativas: number;
    senha_minima_chars: number;
    senha_requer_maiuscula: boolean;
    senha_requer_numero: boolean;
    senha_requer_simbolo: boolean;
    duplo_fator_obrigatorio: boolean;
  };
}

const AdminSystemSettingsPage: React.FC = () => {
  const { can, isAdmin } = usePermissions();
  const [settings, setSettings] = useState<SystemSettings | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [activeTab, setActiveTab] = useState('empresa');
  const [showPasswords, setShowPasswords] = useState<Record<string, boolean>>({});
  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [testingConnection, setTestingConnection] = useState<Record<string, boolean>>({});

  useEffect(() => {
    if (can('administracao.sistema', 'read')) {
      loadSettings();
    }
  }, []);

  const loadSettings = async () => {
    setLoading(true);
    try {
      // Carregar configurações da empresa
      const { data: empresa } = await supabase
        .from('empresas')
        .select('*')
        .single();

      // Configurações padrão se não existirem
      const defaultSettings: SystemSettings = {
        empresa: {
          nome: empresa?.nome || 'Minha Empresa',
          logo_url: empresa?.logo_url,
          cores: empresa?.cores || {
            primaria: '#3B82F6',
            secundaria: '#1E40AF',
            texto: '#1F2937'
          },
          timezone: empresa?.timezone || 'America/Sao_Paulo',
          moeda: empresa?.moeda || 'BRL',
          idioma: empresa?.idioma || 'pt-BR'
        },
        pdv: empresa?.configuracoes?.pdv || {
          permitir_venda_sem_cliente: true,
          permitir_desconto_maximo: 10,
          imprimir_automatico: true,
          fechar_caixa_automatico: false,
          validar_cpf_cnpj: false
        },
        integracoes: empresa?.configuracoes?.integracoes || {
          email: {
            smtp_host: '',
            smtp_port: 587,
            smtp_user: '',
            smtp_password: '',
            ssl_enabled: true
          },
          whatsapp: {
            api_url: '',
            api_token: '',
            numero_padrao: '',
            envio_automatico: false
          },
          mercado_pago: {
            access_token: '',
            public_key: '',
            webhook_url: '',
            sandbox_mode: true
          }
        },
        notificacoes: empresa?.configuracoes?.notificacoes || {
          email_vendas: false,
          email_estoque_baixo: true,
          whatsapp_os_status: false,
          whatsapp_vendas: false
        },
        seguranca: empresa?.configuracoes?.seguranca || {
          sessao_timeout_minutos: 480,
          login_max_tentativas: 5,
          senha_minima_chars: 8,
          senha_requer_maiuscula: true,
          senha_requer_numero: true,
          senha_requer_simbolo: false,
          duplo_fator_obrigatorio: false
        }
      };

      setSettings(defaultSettings);

    } catch (error) {
      console.error('Erro ao carregar configurações:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSaveSettings = async () => {
    if (!can('administracao.sistema', 'update') || !settings) return;

    setSaving(true);
    try {
      let logoUrl = settings.empresa.logo_url;

      // Upload da logo se foi selecionada
      if (logoFile) {
        const fileExt = logoFile.name.split('.').pop();
        const fileName = `${Date.now()}.${fileExt}`;
        
        const { data: uploadData, error: uploadError } = await supabase.storage
          .from('empresas')
          .upload(`logos/${fileName}`, logoFile);

        if (uploadError) throw uploadError;

        const { data: urlData } = supabase.storage
          .from('empresas')
          .getPublicUrl(uploadData.path);

        logoUrl = urlData.publicUrl;
      }

      // Atualizar dados da empresa
      const { error } = await supabase
        .from('empresas')
        .update({
          nome: settings.empresa.nome,
          logo_url: logoUrl,
          cores: settings.empresa.cores,
          timezone: settings.empresa.timezone,
          moeda: settings.empresa.moeda,
          idioma: settings.empresa.idioma,
          configuracoes: {
            pdv: settings.pdv,
            integracoes: settings.integracoes,
            notificacoes: settings.notificacoes,
            seguranca: settings.seguranca
          }
        })
        .eq('id', (await supabase.auth.getUser()).data.user?.user_metadata?.empresa_id);

      if (error) throw error;

      // Atualizar estado local
      setSettings({
        ...settings,
        empresa: {
          ...settings.empresa,
          logo_url: logoUrl
        }
      });

      setLogoFile(null);
      
      // Log de auditoria
      await supabase.from('audit_logs').insert({
        recurso: 'administracao.sistema',
        acao: 'update',
        entidade_tipo: 'configuracao',
        detalhes: { secao: activeTab }
      });

      alert('Configurações salvas com sucesso!');

    } catch (error) {
      console.error('Erro ao salvar configurações:', error);
      alert('Erro ao salvar configurações. Tente novamente.');
    } finally {
      setSaving(false);
    }
  };

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const handleTestConnection = async (type: 'email' | 'whatsapp' | 'mercado_pago') => {
    if (!settings) return;

    setTestingConnection({ ...testingConnection, [type]: true });

    try {
      let result = false;

      switch (type) {
        case 'email':
          // Simular teste de conexão SMTP
          result = await testEmailConnection(settings.integracoes.email);
          break;
        case 'whatsapp':
          // Simular teste de API WhatsApp
          result = await testWhatsAppConnection(settings.integracoes.whatsapp);
          break;
        case 'mercado_pago':
          // Simular teste de API Mercado Pago
          result = await testMercadoPagoConnection(settings.integracoes.mercado_pago);
          break;
      }

      alert(result ? 'Conexão testada com sucesso!' : 'Falha na conexão. Verifique as configurações.');

    } catch (error) {
      console.error(`Erro ao testar ${type}:`, error);
      alert('Erro ao testar conexão.');
    } finally {
      setTestingConnection({ ...testingConnection, [type]: false });
    }
  };

  const testEmailConnection = async (emailConfig: any): Promise<boolean> => {
    // Simular teste de SMTP
    await new Promise(resolve => setTimeout(resolve, 2000));
    return emailConfig.smtp_host && emailConfig.smtp_user;
  };

  const testWhatsAppConnection = async (whatsappConfig: any): Promise<boolean> => {
    // Simular teste de API
    await new Promise(resolve => setTimeout(resolve, 2000));
    return whatsappConfig.api_url && whatsappConfig.api_token;
  };

  const testMercadoPagoConnection = async (mpConfig: any): Promise<boolean> => {
    // Simular teste de API
    await new Promise(resolve => setTimeout(resolve, 2000));
    return mpConfig.access_token && mpConfig.public_key;
  };

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const togglePasswordVisibility = (field: string) => {
    setShowPasswords({
      ...showPasswords,
      [field]: !showPasswords[field]
    });
  };

  const updateSettings = (section: keyof SystemSettings, field: string, value: any) => {
    if (!settings) return;

    setSettings({
      ...settings,
      [section]: {
        ...settings[section],
        [field]: value
      }
    });
  };

  const updateNestedSettings = (section: keyof SystemSettings, subsection: string, field: string, value: any) => {
    if (!settings) return;

    setSettings({
      ...settings,
      [section]: {
        ...settings[section],
        [subsection]: {
          ...(settings[section] as any)[subsection],
          [field]: value
        }
      }
    });
  };

  const tabs = [
    { id: 'empresa', label: 'Empresa', icon: Globe },
    { id: 'pdv', label: 'PDV', icon: Monitor },
    { id: 'notificacoes', label: 'Notificações', icon: Bell },
    { id: 'seguranca', label: 'Segurança', icon: Shield }
  ];

  // Apenas admin (super_admin OU admin_empresa) pode acessar configurações
  if (!isAdmin) {
    return (
      <div className="p-6">
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
          <Shield className="w-12 h-12 text-red-600 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-red-900 mb-2">Acesso Restrito</h3>
          <p className="text-red-700">
            Apenas administradores da empresa podem acessar as configurações do sistema.
          </p>
        </div>
      </div>
    );
  }

  if (loading || !settings) {
    return (
      <div className="p-6">
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="h-96 bg-gray-200 rounded"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Configurações do Sistema</h1>
          <p className="text-gray-600">
            Gerencie as configurações globais do sistema
          </p>
        </div>
        
        {can('administracao.sistema', 'update') && (
          <button
            onClick={handleSaveSettings}
            disabled={saving}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {saving ? (
              <RefreshCw className="w-4 h-4 animate-spin" />
            ) : (
              <Save className="w-4 h-4" />
            )}
            {saving ? 'Salvando...' : 'Salvar Alterações'}
          </button>
        )}
      </div>

      {/* Tabs */}
      <div className="bg-white rounded-lg border border-gray-200">
        <div className="border-b border-gray-200">
          <nav className="flex space-x-8 px-6">
            {tabs.map((tab) => {
              const Icon = tab.icon;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                    activeTab === tab.id
                      ? 'border-blue-500 text-blue-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  <div className="flex items-center gap-2">
                    <Icon className="w-4 h-4" />
                    {tab.label}
                  </div>
                </button>
              );
            })}
          </nav>
        </div>

        <div className="p-6">
          {/* Aba Empresa */}
          {activeTab === 'empresa' && (
            <div className="space-y-6">
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Informações da Empresa</h3>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Nome da Empresa
                    </label>
                    <input
                      type="text"
                      value={settings.empresa.nome}
                      onChange={(e) => updateSettings('empresa', 'nome', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Timezone
                    </label>
                    <select
                      value={settings.empresa.timezone}
                      onChange={(e) => updateSettings('empresa', 'timezone', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                      <option value="America/Sao_Paulo">São Paulo (UTC-3)</option>
                      <option value="America/Manaus">Manaus (UTC-4)</option>
                      <option value="America/Rio_Branco">Rio Branco (UTC-5)</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Moeda
                    </label>
                    <select
                      value={settings.empresa.moeda}
                      onChange={(e) => updateSettings('empresa', 'moeda', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                      <option value="BRL">Real Brasileiro (R$)</option>
                      <option value="USD">Dólar Americano ($)</option>
                      <option value="EUR">Euro (€)</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Idioma
                    </label>
                    <select
                      value={settings.empresa.idioma}
                      onChange={(e) => updateSettings('empresa', 'idioma', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                      <option value="pt-BR">Português (Brasil)</option>
                      <option value="en-US">English (US)</option>
                      <option value="es-ES">Español</option>
                    </select>
                  </div>
                </div>
              </div>

              <div>
                <h4 className="text-md font-semibold text-gray-900 mb-4">Logo da Empresa</h4>
                <div className="flex items-center gap-4">
                  {settings.empresa.logo_url && (
                    <img
                      src={settings.empresa.logo_url}
                      alt="Logo da empresa"
                      className="w-16 h-16 object-contain border border-gray-200 rounded-lg"
                    />
                  )}
                  <div>
                    <input
                      type="file"
                      accept="image/*"
                      onChange={(e) => setLogoFile(e.target.files?.[0] || null)}
                      className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
                    />
                    <p className="text-xs text-gray-500 mt-1">
                      PNG, JPG ou SVG. Tamanho recomendado: 200x200px
                    </p>
                  </div>
                </div>
              </div>

              <div>
                <h4 className="text-md font-semibold text-gray-900 mb-4">Cores do Sistema</h4>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Cor Primária
                    </label>
                    <div className="flex items-center gap-2">
                      <input
                        type="color"
                        value={settings.empresa.cores.primaria}
                        onChange={(e) => updateNestedSettings('empresa', 'cores', 'primaria', e.target.value)}
                        className="w-12 h-10 border border-gray-300 rounded cursor-pointer"
                      />
                      <input
                        type="text"
                        value={settings.empresa.cores.primaria}
                        onChange={(e) => updateNestedSettings('empresa', 'cores', 'primaria', e.target.value)}
                        className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Cor Secundária
                    </label>
                    <div className="flex items-center gap-2">
                      <input
                        type="color"
                        value={settings.empresa.cores.secundaria}
                        onChange={(e) => updateNestedSettings('empresa', 'cores', 'secundaria', e.target.value)}
                        className="w-12 h-10 border border-gray-300 rounded cursor-pointer"
                      />
                      <input
                        type="text"
                        value={settings.empresa.cores.secundaria}
                        onChange={(e) => updateNestedSettings('empresa', 'cores', 'secundaria', e.target.value)}
                        className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Cor do Texto
                    </label>
                    <div className="flex items-center gap-2">
                      <input
                        type="color"
                        value={settings.empresa.cores.texto}
                        onChange={(e) => updateNestedSettings('empresa', 'cores', 'texto', e.target.value)}
                        className="w-12 h-10 border border-gray-300 rounded cursor-pointer"
                      />
                      <input
                        type="text"
                        value={settings.empresa.cores.texto}
                        onChange={(e) => updateNestedSettings('empresa', 'cores', 'texto', e.target.value)}
                        className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Aba PDV */}
          {activeTab === 'pdv' && (
            <div className="space-y-6">
              <h3 className="text-lg font-semibold text-gray-900">Configurações do PDV</h3>
              
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700">
                      Permitir vendas sem cliente
                    </label>
                    <p className="text-xs text-gray-500">
                      Permite realizar vendas sem informar dados do cliente
                    </p>
                  </div>
                  <input
                    type="checkbox"
                    checked={settings.pdv.permitir_venda_sem_cliente}
                    onChange={(e) => updateSettings('pdv', 'permitir_venda_sem_cliente', e.target.checked)}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Desconto máximo permitido (%)
                  </label>
                  <input
                    type="number"
                    min="0"
                    max="100"
                    value={settings.pdv.permitir_desconto_maximo}
                    onChange={(e) => updateSettings('pdv', 'permitir_desconto_maximo', parseFloat(e.target.value))}
                    className="w-32 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700">
                      Imprimir cupom automaticamente
                    </label>
                    <p className="text-xs text-gray-500">
                      Imprime o cupom fiscal automaticamente após a venda
                    </p>
                  </div>
                  <input
                    type="checkbox"
                    checked={settings.pdv.imprimir_automatico}
                    onChange={(e) => updateSettings('pdv', 'imprimir_automatico', e.target.checked)}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700">
                      Fechar caixa automaticamente
                    </label>
                    <p className="text-xs text-gray-500">
                      Fecha o caixa automaticamente no final do expediente
                    </p>
                  </div>
                  <input
                    type="checkbox"
                    checked={settings.pdv.fechar_caixa_automatico}
                    onChange={(e) => updateSettings('pdv', 'fechar_caixa_automatico', e.target.checked)}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700">
                      Validar CPF/CNPJ
                    </label>
                    <p className="text-xs text-gray-500">
                      Valida se CPF/CNPJ informados são válidos
                    </p>
                  </div>
                  <input
                    type="checkbox"
                    checked={settings.pdv.validar_cpf_cnpj}
                    onChange={(e) => updateSettings('pdv', 'validar_cpf_cnpj', e.target.checked)}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </div>
              </div>
            </div>
          )}

          {/* Aba Notificações */}
          {/* Aba Notificações */}
          {activeTab === 'notificacoes' && (
            <div className="space-y-6">
              <h3 className="text-lg font-semibold text-gray-900">Configurações de Notificações</h3>
              
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700">
                      E-mail para vendas
                    </label>
                    <p className="text-xs text-gray-500">
                      Enviar e-mail com resumo das vendas do dia
                    </p>
                  </div>
                  <input
                    type="checkbox"
                    checked={settings.notificacoes.email_vendas}
                    onChange={(e) => updateSettings('notificacoes', 'email_vendas', e.target.checked)}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700">
                      E-mail para estoque baixo
                    </label>
                    <p className="text-xs text-gray-500">
                      Notificar quando produtos estiverem com estoque baixo
                    </p>
                  </div>
                  <input
                    type="checkbox"
                    checked={settings.notificacoes.email_estoque_baixo}
                    onChange={(e) => updateSettings('notificacoes', 'email_estoque_baixo', e.target.checked)}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700">
                      WhatsApp para status de OS
                    </label>
                    <p className="text-xs text-gray-500">
                      Enviar mensagens sobre mudanças de status das ordens de serviço
                    </p>
                  </div>
                  <input
                    type="checkbox"
                    checked={settings.notificacoes.whatsapp_os_status}
                    onChange={(e) => updateSettings('notificacoes', 'whatsapp_os_status', e.target.checked)}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700">
                      WhatsApp para vendas
                    </label>
                    <p className="text-xs text-gray-500">
                      Enviar comprovantes de venda via WhatsApp
                    </p>
                  </div>
                  <input
                    type="checkbox"
                    checked={settings.notificacoes.whatsapp_vendas}
                    onChange={(e) => updateSettings('notificacoes', 'whatsapp_vendas', e.target.checked)}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </div>
              </div>
            </div>
          )}

          {/* Aba Segurança */}
          {activeTab === 'seguranca' && (
            <div className="space-y-6">
              <h3 className="text-lg font-semibold text-gray-900">Configurações de Segurança</h3>
              
              <div className="space-y-6">
                <div>
                  <h4 className="text-md font-semibold text-gray-900 mb-4">Sessões</h4>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Timeout da sessão (minutos)
                    </label>
                    <input
                      type="number"
                      min="5"
                      max="1440"
                      value={settings.seguranca.sessao_timeout_minutos}
                      onChange={(e) => updateSettings('seguranca', 'sessao_timeout_minutos', parseInt(e.target.value))}
                      className="w-32 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                    <p className="text-xs text-gray-500 mt-1">
                      Tempo em minutos para expirar a sessão do usuário (padrão: 480)
                    </p>
                  </div>
                </div>

                <div>
                  <h4 className="text-md font-semibold text-gray-900 mb-4">Login</h4>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Máximo de tentativas de login
                    </label>
                    <input
                      type="number"
                      min="3"
                      max="10"
                      value={settings.seguranca.login_max_tentativas}
                      onChange={(e) => updateSettings('seguranca', 'login_max_tentativas', parseInt(e.target.value))}
                      className="w-32 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                    <p className="text-xs text-gray-500 mt-1">
                      Após atingir o limite, a conta será bloqueada temporariamente
                    </p>
                  </div>
                </div>

                <div>
                  <h4 className="text-md font-semibold text-gray-900 mb-4">Políticas de Senha</h4>
                  <div className="space-y-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Mínimo de caracteres
                      </label>
                      <input
                        type="number"
                        min="6"
                        max="50"
                        value={settings.seguranca.senha_minima_chars}
                        onChange={(e) => updateSettings('seguranca', 'senha_minima_chars', parseInt(e.target.value))}
                        className="w-32 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      />
                    </div>

                    <div className="space-y-2">
                      <label className="flex items-center">
                        <input
                          type="checkbox"
                          checked={settings.seguranca.senha_requer_maiuscula}
                          onChange={(e) => updateSettings('seguranca', 'senha_requer_maiuscula', e.target.checked)}
                          className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                        />
                        <span className="ml-2 text-sm text-gray-700">
                          Exigir pelo menos uma letra maiúscula
                        </span>
                      </label>

                      <label className="flex items-center">
                        <input
                          type="checkbox"
                          checked={settings.seguranca.senha_requer_numero}
                          onChange={(e) => updateSettings('seguranca', 'senha_requer_numero', e.target.checked)}
                          className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                        />
                        <span className="ml-2 text-sm text-gray-700">
                          Exigir pelo menos um número
                        </span>
                      </label>

                      <label className="flex items-center">
                        <input
                          type="checkbox"
                          checked={settings.seguranca.senha_requer_simbolo}
                          onChange={(e) => updateSettings('seguranca', 'senha_requer_simbolo', e.target.checked)}
                          className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                        />
                        <span className="ml-2 text-sm text-gray-700">
                          Exigir pelo menos um símbolo (!@#$%^&*)
                        </span>
                      </label>
                    </div>
                  </div>
                </div>

                <div>
                  <h4 className="text-md font-semibold text-gray-900 mb-4">Autenticação de Dois Fatores</h4>
                  <div className="flex items-center justify-between">
                    <div>
                      <label className="text-sm font-medium text-gray-700">
                        Exigir 2FA para todos os usuários
                      </label>
                      <p className="text-xs text-gray-500">
                        Força todos os usuários a configurar autenticação de dois fatores
                      </p>
                    </div>
                    <input
                      type="checkbox"
                      checked={settings.seguranca.duplo_fator_obrigatorio}
                      onChange={(e) => updateSettings('seguranca', 'duplo_fator_obrigatorio', e.target.checked)}
                      className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default AdminSystemSettingsPage;