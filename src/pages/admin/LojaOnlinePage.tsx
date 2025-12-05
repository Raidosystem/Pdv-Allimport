import React, { useState, useEffect } from 'react'
import { 
  Store, Power, PowerOff, Link2, Palette, Eye, BarChart3, 
  Upload, Save, AlertCircle, Check, ExternalLink 
} from 'lucide-react'
import { lojaOnlineService, type LojaOnline } from '../../services/lojaOnlineService'
import toast from 'react-hot-toast'

export default function LojaOnlinePage() {
  const [loja, setLoja] = useState<LojaOnline | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [uploadingLogo, setUploadingLogo] = useState(false)
  
  const [formData, setFormData] = useState({
    nome: '',
    whatsapp: '',
    descricao: '',
    cor_primaria: '#3B82F6',
    cor_secundaria: '#10B981',
    mostrar_preco: true,
    mostrar_estoque: false,
    permitir_carrinho: true,
    calcular_frete: false,
    permitir_retirada: true,
  })

  useEffect(() => {
    carregarLoja()
  }, [])

  const carregarLoja = async () => {
    try {
      setLoading(true)
      const data = await lojaOnlineService.buscarMinhaLoja()
      
      if (data) {
        setLoja(data)
        setFormData({
          nome: data.nome,
          whatsapp: data.whatsapp,
          descricao: data.descricao || '',
          cor_primaria: data.cor_primaria,
          cor_secundaria: data.cor_secundaria,
          mostrar_preco: data.mostrar_preco,
          mostrar_estoque: data.mostrar_estoque,
          permitir_carrinho: data.permitir_carrinho,
          calcular_frete: data.calcular_frete,
          permitir_retirada: data.permitir_retirada,
        })
      }
    } catch (error) {
      console.error('Erro ao carregar loja:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSalvar = async () => {
    if (!formData.nome || !formData.whatsapp) {
      toast.error('Preencha nome e WhatsApp')
      return
    }

    if (!lojaOnlineService.validarWhatsApp(formData.whatsapp)) {
      toast.error('WhatsApp inválido')
      return
    }

    try {
      setSaving(true)
      
      if (loja) {
        // Atualizar
        await lojaOnlineService.atualizarLoja(loja.id, formData)
        toast.success('Loja atualizada com sucesso!')
      } else {
        // Criar
        const novaLoja = await lojaOnlineService.criarLoja(formData)
        setLoja(novaLoja)
        toast.success('Loja criada com sucesso!')
      }
      
      await carregarLoja()
    } catch (error: any) {
      console.error('Erro ao salvar:', error)
      toast.error(error.message || 'Erro ao salvar loja')
    } finally {
      setSaving(false)
    }
  }

  const handleToggleAtiva = async () => {
    if (!loja) return

    try {
      const novoStatus = !loja.ativa
      await lojaOnlineService.toggleAtiva(loja.id, novoStatus)
      setLoja({ ...loja, ativa: novoStatus })
      toast.success(novoStatus ? 'Loja ativada!' : 'Loja desativada!')
    } catch (error) {
      console.error('Erro ao alterar status:', error)
      toast.error('Erro ao alterar status da loja')
    }
  }

  const handleUploadLogo = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file || !loja) return

    // Validar tipo
    if (!file.type.startsWith('image/')) {
      toast.error('Selecione uma imagem')
      return
    }

    // Validar tamanho (max 2MB)
    if (file.size > 2 * 1024 * 1024) {
      toast.error('Imagem muito grande (máx 2MB)')
      return
    }

    try {
      setUploadingLogo(true)
      const logoUrl = await lojaOnlineService.uploadLogo(file, loja.id)
      await lojaOnlineService.atualizarLoja(loja.id, { logo_url: logoUrl })
      await carregarLoja()
      toast.success('Logo atualizada!')
    } catch (error) {
      console.error('Erro ao fazer upload:', error)
      toast.error('Erro ao fazer upload da logo')
    } finally {
      setUploadingLogo(false)
    }
  }

  const urlLoja = loja ? `${window.location.origin}/loja/${loja.slug}` : ''

  const copiarUrl = () => {
    if (urlLoja) {
      navigator.clipboard.writeText(urlLoja)
      toast.success('URL copiada!')
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Store className="w-8 h-8 text-blue-600" />
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Loja Online</h1>
            <p className="text-sm text-gray-600">
              Crie um catálogo online com carrinho WhatsApp
            </p>
          </div>
        </div>

        {loja && (
          <button
            onClick={handleToggleAtiva}
            className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-colors ${
              loja.ativa
                ? 'bg-red-50 text-red-600 hover:bg-red-100 border border-red-200'
                : 'bg-green-50 text-green-600 hover:bg-green-100 border border-green-200'
            }`}
          >
            {loja.ativa ? (
              <>
                <PowerOff className="w-4 h-4" />
                Desativar Loja
              </>
            ) : (
              <>
                <Power className="w-4 h-4" />
                Ativar Loja
              </>
            )}
          </button>
        )}
      </div>

      {/* Status da Loja */}
      {loja && (
        <div className={`rounded-lg p-4 ${loja.ativa ? 'bg-green-50 border border-green-200' : 'bg-gray-50 border border-gray-200'}`}>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className={`w-3 h-3 rounded-full ${loja.ativa ? 'bg-green-500 animate-pulse' : 'bg-gray-400'}`} />
              <div>
                <p className="font-medium text-gray-900">
                  Status: {loja.ativa ? 'Loja Ativa' : 'Loja Desativada'}
                </p>
                {loja.ativa && (
                  <p className="text-sm text-gray-600">
                    Sua loja está acessível publicamente
                  </p>
                )}
              </div>
            </div>

            {loja.ativa && (
              <div className="flex gap-2">
                <button
                  onClick={copiarUrl}
                  className="flex items-center gap-2 px-3 py-2 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors text-sm"
                >
                  <Link2 className="w-4 h-4" />
                  Copiar URL
                </button>
                <a
                  href={urlLoja}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm"
                >
                  <Eye className="w-4 h-4" />
                  Visualizar
                  <ExternalLink className="w-3 h-3" />
                </a>
              </div>
            )}
          </div>

          {loja.ativa && (
            <div className="mt-3 p-3 bg-white rounded border border-green-200">
              <p className="text-xs text-gray-600 mb-1">URL da sua loja:</p>
              <code className="text-sm text-blue-600 font-mono break-all">
                {urlLoja}
              </code>
            </div>
          )}
        </div>
      )}

      {/* Formulário */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        <div className="p-6 space-y-6">
          {/* Informações Básicas */}
          <section>
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Informações Básicas
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nome da Loja *
                </label>
                <input
                  type="text"
                  value={formData.nome}
                  onChange={(e) => setFormData({ ...formData, nome: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Minha Loja"
                />
                <p className="text-xs text-gray-500 mt-1">
                  Nome que aparecerá no site público
                </p>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  WhatsApp para Pedidos *
                </label>
                <input
                  type="text"
                  value={formData.whatsapp}
                  onChange={(e) => setFormData({ ...formData, whatsapp: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="(11) 99999-9999"
                />
                <p className="text-xs text-gray-500 mt-1">
                  Número que receberá os pedidos
                </p>
              </div>

              {loja && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Slug (URL)
                  </label>
                  <input
                    type="text"
                    value={loja.slug}
                    disabled
                    className="w-full px-3 py-2 bg-gray-50 border border-gray-300 rounded-lg text-gray-600"
                  />
                  <p className="text-xs text-gray-500 mt-1">
                    URL: /loja/{loja.slug}
                  </p>
                </div>
              )}

              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Descrição da Loja
                </label>
                <textarea
                  value={formData.descricao}
                  onChange={(e) => setFormData({ ...formData, descricao: e.target.value })}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none"
                  placeholder="Descrição breve sobre sua loja..."
                />
              </div>
            </div>
          </section>

          {/* Logo */}
          <section>
            <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <Palette className="w-5 h-5" />
              Personalização Visual
            </h2>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Logo da Loja
                </label>
                <div className="flex items-center gap-4">
                  {loja?.logo_url && (
                    <img
                      src={loja.logo_url}
                      alt="Logo"
                      className="w-20 h-20 object-contain border border-gray-200 rounded-lg"
                    />
                  )}
                  <label className="cursor-pointer">
                    <div className="flex items-center gap-2 px-4 py-2 bg-gray-50 border border-gray-300 rounded-lg hover:bg-gray-100 transition-colors">
                      <Upload className="w-4 h-4" />
                      {uploadingLogo ? 'Enviando...' : 'Escolher Imagem'}
                    </div>
                    <input
                      type="file"
                      accept="image/*"
                      onChange={handleUploadLogo}
                      disabled={uploadingLogo || !loja}
                      className="hidden"
                    />
                  </label>
                </div>
                <p className="text-xs text-gray-500 mt-1">
                  PNG ou JPG (máx 2MB) - Salve a loja antes de fazer upload
                </p>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Cor Primária
                  </label>
                  <div className="flex items-center gap-2">
                    <input
                      type="color"
                      value={formData.cor_primaria}
                      onChange={(e) => setFormData({ ...formData, cor_primaria: e.target.value })}
                      className="w-12 h-10 rounded border border-gray-300 cursor-pointer"
                    />
                    <input
                      type="text"
                      value={formData.cor_primaria}
                      onChange={(e) => setFormData({ ...formData, cor_primaria: e.target.value })}
                      className="flex-1 px-3 py-2 border border-gray-300 rounded-lg"
                      placeholder="#3B82F6"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Cor Secundária
                  </label>
                  <div className="flex items-center gap-2">
                    <input
                      type="color"
                      value={formData.cor_secundaria}
                      onChange={(e) => setFormData({ ...formData, cor_secundaria: e.target.value })}
                      className="w-12 h-10 rounded border border-gray-300 cursor-pointer"
                    />
                    <input
                      type="text"
                      value={formData.cor_secundaria}
                      onChange={(e) => setFormData({ ...formData, cor_secundaria: e.target.value })}
                      className="flex-1 px-3 py-2 border border-gray-300 rounded-lg"
                      placeholder="#10B981"
                    />
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Configurações */}
          <section>
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Configurações da Loja
            </h2>
            <div className="space-y-3">
              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={formData.mostrar_preco}
                  onChange={(e) => setFormData({ ...formData, mostrar_preco: e.target.checked })}
                  className="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                />
                <div>
                  <p className="font-medium text-gray-900 group-hover:text-blue-600 transition-colors">
                    Mostrar Preços
                  </p>
                  <p className="text-sm text-gray-500">
                    Exibir valores dos produtos no catálogo
                  </p>
                </div>
              </label>

              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={formData.mostrar_estoque}
                  onChange={(e) => setFormData({ ...formData, mostrar_estoque: e.target.checked })}
                  className="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                />
                <div>
                  <p className="font-medium text-gray-900 group-hover:text-blue-600 transition-colors">
                    Mostrar Estoque
                  </p>
                  <p className="text-sm text-gray-500">
                    Exibir quantidade disponível
                  </p>
                </div>
              </label>

              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={formData.permitir_carrinho}
                  onChange={(e) => setFormData({ ...formData, permitir_carrinho: e.target.checked })}
                  className="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                />
                <div>
                  <p className="font-medium text-gray-900 group-hover:text-blue-600 transition-colors">
                    Permitir Carrinho de Compras
                  </p>
                  <p className="text-sm text-gray-500">
                    Clientes podem adicionar múltiplos produtos
                  </p>
                </div>
              </label>

              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={formData.permitir_retirada}
                  onChange={(e) => setFormData({ ...formData, permitir_retirada: e.target.checked })}
                  className="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                />
                <div>
                  <p className="font-medium text-gray-900 group-hover:text-blue-600 transition-colors">
                    Permitir Retirada na Loja
                  </p>
                  <p className="text-sm text-gray-500">
                    Cliente pode retirar o pedido pessoalmente
                  </p>
                </div>
              </label>
            </div>
          </section>

          {/* Aviso */}
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div className="flex gap-3">
              <AlertCircle className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
              <div className="text-sm text-blue-800">
                <p className="font-medium mb-1">Como funciona:</p>
                <ul className="list-disc list-inside space-y-1">
                  <li>Todos os produtos cadastrados aparecerão automaticamente no catálogo</li>
                  <li>Clientes navegam, adicionam ao carrinho e finalizam pelo WhatsApp</li>
                  <li>Você receberá uma mensagem formatada com todos os detalhes do pedido</li>
                </ul>
              </div>
            </div>
          </div>

          {/* Botões */}
          <div className="flex justify-end gap-3 pt-4 border-t">
            <button
              onClick={handleSalvar}
              disabled={saving}
              className="flex items-center gap-2 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {saving ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent" />
                  Salvando...
                </>
              ) : (
                <>
                  <Save className="w-4 h-4" />
                  Salvar Configurações
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
