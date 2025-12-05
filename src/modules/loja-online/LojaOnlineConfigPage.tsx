import { useState, useEffect } from 'react';
import { 
  Store, 
  Globe, 
  Palette, 
  Upload, 
  Eye, 
  EyeOff, 
  Save,
  ExternalLink,
  BarChart3,
  Copy,
  CheckCircle2
} from 'lucide-react';
import { lojaOnlineService } from '../../services/lojaOnlineService';
import type { LojaOnline } from '../../services/lojaOnlineService';
import toast from 'react-hot-toast';

export function LojaOnlineConfigPage() {
  const [loja, setLoja] = useState<LojaOnline | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [slugDisponivel, setSlugDisponivel] = useState<boolean | null>(null);
  const [verificandoSlug, setVerificandoSlug] = useState(false);
  const [copiedUrl, setCopiedUrl] = useState(false);

  // Form state
  const [formData, setFormData] = useState({
    slug: '',
    nome: '',
    whatsapp: '',
    ativa: false,
    logo_url: '',
    cor_primaria: '#3B82F6',
    cor_secundaria: '#10B981',
    descricao: '',
    mostrar_preco: true,
    mostrar_estoque: false,
    permitir_carrinho: true,
    calcular_frete: false,
    permitir_retirada: true,
    meta_title: '',
    meta_description: '',
    meta_keywords: ''
  });

  useEffect(() => {
    carregarLoja();
  }, []);

  const carregarLoja = async () => {
    try {
      setLoading(true);
      const lojaData = await lojaOnlineService.buscarMinhaLoja();
      
      if (lojaData) {
        setLoja(lojaData);
        setFormData({
          slug: lojaData.slug,
          nome: lojaData.nome,
          whatsapp: lojaData.whatsapp,
          ativa: lojaData.ativa,
          logo_url: lojaData.logo_url || '',
          cor_primaria: lojaData.cor_primaria,
          cor_secundaria: lojaData.cor_secundaria,
          descricao: lojaData.descricao || '',
          mostrar_preco: lojaData.mostrar_preco,
          mostrar_estoque: lojaData.mostrar_estoque,
          permitir_carrinho: lojaData.permitir_carrinho,
          calcular_frete: lojaData.calcular_frete,
          permitir_retirada: lojaData.permitir_retirada,
          meta_title: lojaData.meta_title || '',
          meta_description: lojaData.meta_description || '',
          meta_keywords: lojaData.meta_keywords || ''
        });
        setSlugDisponivel(true);
      }
    } catch (error) {
      console.error('Erro ao carregar loja:', error);
      toast.error('Erro ao carregar configurações da loja');
    } finally {
      setLoading(false);
    }
  };

  const verificarSlug = async (slug: string) => {
    if (!slug || slug === loja?.slug) {
      setSlugDisponivel(null);
      return;
    }

    setVerificandoSlug(true);
    try {
      const disponivel = await lojaOnlineService.verificarSlugDisponivel(slug);
      setSlugDisponivel(disponivel);
    } catch (error) {
      console.error('Erro ao verificar slug:', error);
    } finally {
      setVerificandoSlug(false);
    }
  };

  const handleSlugChange = (value: string) => {
    // Permitir apenas letras minúsculas, números e hífens
    const slugFormatado = value.toLowerCase().replace(/[^a-z0-9-]/g, '');
    setFormData({ ...formData, slug: slugFormatado });
    
    // Verificar disponibilidade após 500ms
    clearTimeout((window as any).slugTimeout);
    (window as any).slugTimeout = setTimeout(() => {
      verificarSlug(slugFormatado);
    }, 500);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!formData.slug) {
      toast.error('Slug é obrigatório');
      return;
    }

    if (!formData.nome) {
      toast.error('Nome da loja é obrigatório');
      return;
    }

    if (!formData.whatsapp) {
      toast.error('WhatsApp é obrigatório');
      return;
    }

    if (!loja && slugDisponivel === false) {
      toast.error('Este slug já está em uso');
      return;
    }

    setSaving(true);
    try {
      if (loja) {
        // Atualizar loja existente
        const lojaAtualizada = await lojaOnlineService.atualizarLoja(loja.id, formData);
        setLoja(lojaAtualizada);
        toast.success('Loja atualizada com sucesso!');
      } else {
        // Criar nova loja
        const novaLoja = await lojaOnlineService.criarLoja(formData);
        setLoja(novaLoja);
        toast.success('Loja criada com sucesso!');
      }
      
      await carregarLoja();
    } catch (error) {
      console.error('Erro ao salvar loja:', error);
      toast.error('Erro ao salvar configurações');
    } finally {
      setSaving(false);
    }
  };

  const toggleLojaAtiva = async () => {
    if (!loja) return;

    try {
      const novoStatus = !loja.ativa;
      await lojaOnlineService.toggleAtiva(loja.id, novoStatus);
      setLoja({ ...loja, ativa: novoStatus });
      setFormData({ ...formData, ativa: novoStatus });
      toast.success(novoStatus ? 'Loja ativada!' : 'Loja desativada!');
    } catch (error) {
      console.error('Erro ao alterar status:', error);
      toast.error('Erro ao alterar status da loja');
    }
  };

  const copiarUrl = () => {
    if (!loja) return;
    const url = `${window.location.origin}/loja/${loja.slug}`;
    navigator.clipboard.writeText(url);
    setCopiedUrl(true);
    toast.success('URL copiada!');
    setTimeout(() => setCopiedUrl(false), 2000);
  };

  const abrirLoja = () => {
    if (!loja) return;
    window.open(`/loja/${loja.slug}`, '_blank');
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-5xl mx-auto">
        {/* Header */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                <Store className="w-6 h-6 text-blue-600" />
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Loja Online</h1>
                <p className="text-sm text-gray-600">Configure seu catálogo de produtos online</p>
              </div>
            </div>

            {loja && (
              <div className="flex items-center gap-3">
                <button
                  onClick={toggleLojaAtiva}
                  className={`flex items-center gap-2 px-4 py-2 rounded-lg border transition-colors ${
                    loja.ativa
                      ? 'bg-green-50 border-green-200 text-green-700 hover:bg-green-100'
                      : 'bg-gray-50 border-gray-200 text-gray-700 hover:bg-gray-100'
                  }`}
                >
                  {loja.ativa ? (
                    <>
                      <Eye className="w-4 h-4" />
                      Loja Ativa
                    </>
                  ) : (
                    <>
                      <EyeOff className="w-4 h-4" />
                      Loja Inativa
                    </>
                  )}
                </button>

                {loja.ativa && (
                  <>
                    <button
                      onClick={copiarUrl}
                      className="flex items-center gap-2 px-4 py-2 bg-blue-50 text-blue-600 rounded-lg border border-blue-200 hover:bg-blue-100 transition-colors"
                    >
                      {copiedUrl ? (
                        <>
                          <CheckCircle2 className="w-4 h-4" />
                          Copiado!
                        </>
                      ) : (
                        <>
                          <Copy className="w-4 h-4" />
                          Copiar URL
                        </>
                      )}
                    </button>

                    <button
                      onClick={abrirLoja}
                      className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
                    >
                      <ExternalLink className="w-4 h-4" />
                      Abrir Loja
                    </button>
                  </>
                )}
              </div>
            )}
          </div>

          {loja && loja.ativa && (
            <div className="mt-4 p-4 bg-blue-50 rounded-lg border border-blue-200">
              <div className="flex items-start gap-3">
                <Globe className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <p className="text-sm font-medium text-blue-900">Sua loja está online!</p>
                  <p className="text-sm text-blue-700 mt-1 font-mono break-all">
                    {window.location.origin}/loja/{loja.slug}
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Informações Básicas */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <Store className="w-5 h-5" />
              Informações Básicas
            </h2>

            <div className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Nome da Loja *
                  </label>
                  <input
                    type="text"
                    value={formData.nome}
                    onChange={(e) => setFormData({ ...formData, nome: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="Minha Loja"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    WhatsApp (com DDD) *
                  </label>
                  <input
                    type="text"
                    value={formData.whatsapp}
                    onChange={(e) => setFormData({ ...formData, whatsapp: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="11999999999"
                    required
                  />
                  <p className="text-xs text-gray-500 mt-1">
                    Apenas números, ex: 11999999999
                  </p>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  URL da Loja (Slug) *
                </label>
                <div className="flex items-center gap-2">
                  <span className="text-sm text-gray-500">{window.location.origin}/loja/</span>
                  <input
                    type="text"
                    value={formData.slug}
                    onChange={(e) => handleSlugChange(e.target.value)}
                    className={`flex-1 px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                      slugDisponivel === false ? 'border-red-300' : 
                      slugDisponivel === true ? 'border-green-300' : 
                      'border-gray-300'
                    }`}
                    placeholder="minhaloja"
                    required
                  />
                  {verificandoSlug && (
                    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-blue-600"></div>
                  )}
                  {slugDisponivel === true && !verificandoSlug && (
                    <CheckCircle2 className="w-5 h-5 text-green-600" />
                  )}
                  {slugDisponivel === false && !verificandoSlug && (
                    <span className="text-xs text-red-600">Já existe</span>
                  )}
                </div>
                <p className="text-xs text-gray-500 mt-1">
                  Apenas letras minúsculas, números e hífens
                </p>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Descrição da Loja
                </label>
                <textarea
                  value={formData.descricao}
                  onChange={(e) => setFormData({ ...formData, descricao: e.target.value })}
                  rows={3}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Descreva sua loja..."
                />
              </div>
            </div>
          </div>

          {/* Personalização */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <Palette className="w-5 h-5" />
              Personalização
            </h2>

            <div className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Cor Principal
                  </label>
                  <div className="flex items-center gap-2">
                    <input
                      type="color"
                      value={formData.cor_primaria}
                      onChange={(e) => setFormData({ ...formData, cor_primaria: e.target.value })}
                      className="w-12 h-12 rounded-lg border border-gray-300 cursor-pointer"
                    />
                    <input
                      type="text"
                      value={formData.cor_primaria}
                      onChange={(e) => setFormData({ ...formData, cor_primaria: e.target.value })}
                      className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 font-mono"
                      placeholder="#3B82F6"
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
                      value={formData.cor_secundaria}
                      onChange={(e) => setFormData({ ...formData, cor_secundaria: e.target.value })}
                      className="w-12 h-12 rounded-lg border border-gray-300 cursor-pointer"
                    />
                    <input
                      type="text"
                      value={formData.cor_secundaria}
                      onChange={(e) => setFormData({ ...formData, cor_secundaria: e.target.value })}
                      className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 font-mono"
                      placeholder="#10B981"
                    />
                  </div>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Logo da Loja
                </label>
                <div className="flex items-center gap-4">
                  {formData.logo_url && (
                    <img 
                      src={formData.logo_url} 
                      alt="Logo" 
                      className="w-20 h-20 object-contain border border-gray-300 rounded-lg"
                    />
                  )}
                  <button
                    type="button"
                    className="flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
                  >
                    <Upload className="w-4 h-4" />
                    Upload Logo
                  </button>
                </div>
                <p className="text-xs text-gray-500 mt-1">
                  Recomendado: PNG transparente, 200x200px
                </p>
              </div>
            </div>
          </div>

          {/* Configurações de Exibição */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Configurações de Exibição
            </h2>

            <div className="space-y-3">
              <label className="flex items-center gap-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={formData.mostrar_preco}
                  onChange={(e) => setFormData({ ...formData, mostrar_preco: e.target.checked })}
                  className="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                />
                <div>
                  <p className="font-medium text-gray-900">Mostrar Preços</p>
                  <p className="text-sm text-gray-600">Exibir preços dos produtos no catálogo</p>
                </div>
              </label>

              <label className="flex items-center gap-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={formData.mostrar_estoque}
                  onChange={(e) => setFormData({ ...formData, mostrar_estoque: e.target.checked })}
                  className="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                />
                <div>
                  <p className="font-medium text-gray-900">Mostrar Estoque</p>
                  <p className="text-sm text-gray-600">Exibir quantidade disponível</p>
                </div>
              </label>

              <label className="flex items-center gap-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={formData.permitir_carrinho}
                  onChange={(e) => setFormData({ ...formData, permitir_carrinho: e.target.checked })}
                  className="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                />
                <div>
                  <p className="font-medium text-gray-900">Permitir Carrinho de Compras</p>
                  <p className="text-sm text-gray-600">Clientes podem adicionar múltiplos produtos</p>
                </div>
              </label>

              <label className="flex items-center gap-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={formData.permitir_retirada}
                  onChange={(e) => setFormData({ ...formData, permitir_retirada: e.target.checked })}
                  className="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                />
                <div>
                  <p className="font-medium text-gray-900">Permitir Retirada na Loja</p>
                  <p className="text-sm text-gray-600">Opção de retirar o pedido pessoalmente</p>
                </div>
              </label>

              <label className="flex items-center gap-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={formData.calcular_frete}
                  onChange={(e) => setFormData({ ...formData, calcular_frete: e.target.checked })}
                  className="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                />
                <div>
                  <p className="font-medium text-gray-900">Calcular Frete</p>
                  <p className="text-sm text-gray-600">Solicitar CEP e calcular frete (em breve)</p>
                </div>
              </label>
            </div>
          </div>

          {/* Botões de Ação */}
          <div className="flex items-center justify-between">
            <button
              type="button"
              onClick={carregarLoja}
              className="px-6 py-2 text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
            >
              Cancelar
            </button>

            <button
              type="submit"
              disabled={saving || (slugDisponivel === false && !loja)}
              className="flex items-center gap-2 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <Save className="w-4 h-4" />
              {saving ? 'Salvando...' : loja ? 'Atualizar Loja' : 'Criar Loja'}
            </button>
          </div>
        </form>

        {/* Analytics (se loja existir) */}
        {loja && (
          <div className="mt-6 bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center gap-2 mb-4">
              <BarChart3 className="w-5 h-5 text-gray-700" />
              <h2 className="text-lg font-semibold text-gray-900">Analytics</h2>
            </div>
            <p className="text-sm text-gray-600">
              Acompanhe as métricas da sua loja online (em breve)
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
