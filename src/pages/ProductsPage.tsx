import { useState, useEffect } from 'react'
import { Package, Plus, Search, Edit, Trash2, Eye, Users, Store, ExternalLink } from 'lucide-react'
import { Button } from '../components/ui/Button'
import { Modal } from '../components/ui/Modal'
import ProductForm from '../components/product/ProductForm'
import { FornecedorForm } from '../components/fornecedor/FornecedorForm'
import { useProdutos } from '../hooks/useProdutos'
import { useProducts } from '../hooks/useProducts'
import { usePermissions } from '../hooks/usePermissions'
import { supabase } from '../lib/supabase'
import { toast } from 'react-hot-toast'
import { useLocation, useNavigate } from 'react-router-dom'
import type { Fornecedor, FornecedorFormData } from '../types/fornecedor'
import { lojaOnlineService } from '../services/lojaOnlineService'
import type { LojaOnline } from '../services/lojaOnlineService'

interface Product {
  id: string
  user_id?: string
  name: string
  barcode: string
  codigo_interno?: string  // Código interno automático
  category_id?: string
  sale_price: number
  cost_price: number
  current_stock: number
  minimum_stock: number
  unit_measure: string
  active: boolean
  image_url?: string | null  // URL da imagem do produto
  expiry_date?: string | null
  created_at: string
  updated_at: string
}

type ViewMode = 'list' | 'form' | 'view'

export function ProductsPage() {
  console.log('🔥 ProductsPage carregando...')
  
  const location = useLocation()
  const navigate = useNavigate()
  
  const {
    produtos: products,
    todosProdutos: allProducts,
    loading,
    mostrarTodos,
    toggleMostrarTodos,
    carregarProdutos
  } = useProdutos()

  const { deleteProduct } = useProducts()

  const { can, isAdminEmpresa, isSuperAdmin } = usePermissions()
  
  // Owner = Admin da empresa OU Super Admin
  const isOwner = isAdminEmpresa || isSuperAdmin
  
  const [viewMode, setViewMode] = useState<ViewMode>('list')
  const [editingProduct, setEditingProduct] = useState<Product | null>(null)
  const [viewingProduct, setViewingProduct] = useState<Product | null>(null)
  const [searchTerm, setSearchTerm] = useState('')
  
  // Estados para modal de produto
  const [isProductModalOpen, setIsProductModalOpen] = useState(false)
  const [cameFromExternalPage, setCameFromExternalPage] = useState(false)
  
  // Detectar se veio da página de vendas para abrir modal automaticamente
  useEffect(() => {
    if (location.state?.openForm) {
      setIsProductModalOpen(true)
      setCameFromExternalPage(true)
      // Limpar o state para não reabrir ao navegar de volta
      window.history.replaceState({}, document.title)
    }
  }, [location])
  
  // Estados para modal de fornecedores
  const [isFornecedorModalOpen, setIsFornecedorModalOpen] = useState(false)
  const [isFornecedorFormOpen, setIsFornecedorFormOpen] = useState(false)
  const [fornecedores, setFornecedores] = useState<Fornecedor[]>([])
  const [selectedFornecedor, setSelectedFornecedor] = useState<Fornecedor | undefined>()
  const [isSubmittingFornecedor, setIsSubmittingFornecedor] = useState(false)

  // Estado para loja online
  const [lojaOnline, setLojaOnline] = useState<LojaOnline | null>(null)

  // Carregar loja online
  useEffect(() => {
    carregarLojaOnline()
  }, [])

  const carregarLojaOnline = async () => {
    try {
      const loja = await lojaOnlineService.buscarMinhaLoja()
      setLojaOnline(loja)
    } catch (error) {
      console.log('Loja online não configurada')
    }
  }

  const abrirLojaOnline = () => {
    if (!lojaOnline) {
      toast.error('Configure sua loja online primeiro em Administração')
      return
    }
    
    if (!lojaOnline.ativa) {
      toast.error('Ative sua loja online primeiro em Administração')
      return
    }

    const url = `${window.location.origin}/loja/${lojaOnline.slug}`
    window.open(url, '_blank')
    toast.success('Abrindo sua loja online...')
  }

  const handleNovoProduto = () => {
    setEditingProduct(null)
    setIsProductModalOpen(true)
  }

  const handleEditarProduto = (product: Product) => {
    setEditingProduct(product)
    setIsProductModalOpen(true)
    // Não muda viewMode - mantém na visualização se estiver lá
  }

  const handleVisualizarProduto = (product: Product) => {
    setViewingProduct(product)
    setViewMode('view')
  }

  const handleSalvarProduto = async () => {
    try {
      // Se estava visualizando um produto, recarregar os dados dele
      if (viewMode === 'view' && editingProduct) {
        // Buscar dados atualizados do produto
        const { data } = await supabase
          .from('produtos')
          .select('*')
          .eq('id', editingProduct.id)
          .single()
        
        if (data) {
          // Adaptar para o formato esperado
          const updatedProduct: Product = {
            id: data.id,
            user_id: data.user_id,
            name: data.nome || '',
            barcode: data.codigo_barras || '',
            codigo_interno: data.codigo_interno || '',
            category_id: data.categoria_id,
            sale_price: data.preco || 0,
            cost_price: data.preco_custo || 0,
            current_stock: data.estoque || 0,
            minimum_stock: data.estoque_minimo || 0,
            unit_measure: data.unidade || 'UN',
            active: data.ativo !== false,
            expiry_date: data.data_validade || null,
            image_url: data.image_url || null,
            created_at: data.criado_em || new Date().toISOString(),
            updated_at: data.atualizado_em || new Date().toISOString()
          }
          setViewingProduct(updatedProduct)
        }
      }
      
      // Fechar modal e limpar estado de edição para forçar recriação
      setIsProductModalOpen(false)
      setEditingProduct(null)
      
      // Recarregar apenas a lista de produtos (sem recarregar página completa)
      console.log('🔄 [ProductsPage] Recarregando lista de produtos...')
      await carregarProdutos()
      console.log('✅ [ProductsPage] Lista de produtos atualizada!')
      
      // Se veio de página externa, voltar
      if (cameFromExternalPage) {
        navigate(-1)
      }
      
      console.log('✅ Produto salvo com sucesso!')
    } catch (error) {
      console.error('Erro ao salvar produto:', error)
    }
  }

  const handleCancelar = () => {
    setIsProductModalOpen(false)
    setEditingProduct(null)
    
    // Se NÃO está visualizando, limpa tudo
    if (viewMode !== 'view') {
      setViewingProduct(null)
    }
    
    // Se veio de página externa (vendas, dashboard), voltar
    if (cameFromExternalPage) {
      navigate(-1)
    }
  }

  const handleVoltarParaLista = () => {
    setViewMode('list')
    setViewingProduct(null)
    setEditingProduct(null)
    
    // Se veio de página externa, voltar
    if (cameFromExternalPage) {
      navigate(-1)
    }
  }

  // Funções para gerenciar fornecedores
  const loadFornecedores = async () => {
    try {
      // Buscar user_id para filtrar fornecedores (RLS)
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) {
        console.error('Usuário não autenticado')
        return
      }

      const { data, error } = await supabase
        .from('fornecedores')
        .select('*')
        .eq('user_id', user.id)
        .order('nome', { ascending: true })

      if (error) throw error
      setFornecedores(data || [])
    } catch (error) {
      console.error('Erro ao carregar fornecedores:', error)
      toast.error('Erro ao carregar fornecedores')
    }
  }

  const handleOpenFornecedorModal = () => {
    loadFornecedores()
    setIsFornecedorModalOpen(true)
  }

  const handleCloseFornecedorModal = () => {
    setIsFornecedorModalOpen(false)
    setIsFornecedorFormOpen(false)
    setSelectedFornecedor(undefined)
  }

  const handleNewFornecedor = () => {
    setSelectedFornecedor(undefined)
    setIsFornecedorFormOpen(true)
  }

  const handleEditFornecedor = (fornecedor: Fornecedor) => {
    setSelectedFornecedor(fornecedor)
    setIsFornecedorFormOpen(true)
  }

  const handleSubmitFornecedor = async (data: FornecedorFormData) => {
    try {
      setIsSubmittingFornecedor(true)

      // Buscar user_id da sessão atual (necessário para RLS)
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuário não autenticado')

      if (selectedFornecedor) {
        const { error } = await supabase
          .from('fornecedores')
          .update({ ...data, user_id: user.id, updated_at: new Date().toISOString() })
          .eq('id', selectedFornecedor.id)

        if (error) throw error
        toast.success('Fornecedor atualizado!')
      } else {
        const { error } = await supabase
          .from('fornecedores')
          .insert([{ ...data, user_id: user.id }])

        if (error) throw error
        toast.success('Fornecedor cadastrado!')
      }

      setIsFornecedorFormOpen(false)
      setSelectedFornecedor(undefined)
      loadFornecedores()
      
      // Recarrega fornecedores no ProductForm
      window.dispatchEvent(new CustomEvent('fornecedorUpdated'))
    } catch (error) {
      console.error('Erro ao salvar fornecedor:', error)
      toast.error('Erro ao salvar fornecedor')
    } finally {
      setIsSubmittingFornecedor(false)
    }
  }

  const handleDeleteFornecedor = async (id: string) => {
    if (!confirm('Deseja realmente excluir este fornecedor?')) return

    try {
      const { error } = await supabase
        .from('fornecedores')
        .delete()
        .eq('id', id)

      if (error) throw error
      toast.success('Fornecedor excluído!')
      loadFornecedores()
      
      // Recarrega fornecedores no ProductForm
      window.dispatchEvent(new CustomEvent('fornecedorUpdated'))
    } catch (error) {
      console.error('Erro ao excluir fornecedor:', error)
      toast.error('Erro ao excluir fornecedor')
    }
  }

  const formatPrice = (price: number) => {
    return price.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    })
  }

  const filteredProducts = allProducts.filter(product =>
    product.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    product.barcode.includes(searchTerm)
  )

  // Se há busca, mostrar todos os resultados filtrados
  // Se não há busca, aplicar lógica de paginação (limitados ou todos)
  const produtosParaExibir = searchTerm.trim() !== '' 
    ? filteredProducts 
    : (mostrarTodos ? allProducts : products)

  // Usar todos os produtos para estatísticas
  const activeProducts = allProducts.filter(p => p.active)
  const lowStockProducts = allProducts.filter(p => p.current_stock <= p.minimum_stock)
  const totalValue = allProducts.reduce((acc, p) => acc + (p.sale_price * p.current_stock), 0)

  // Modal de Produto (Criar/Editar) - FULLSCREEN em vez de flutuante
  const renderProductModal = () => {
    if (!isProductModalOpen) return null
    
    return (
      <div className="pb-8">
        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center mb-6">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
                <Package className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  {editingProduct ? 'Editar Produto' : 'Novo Produto'}
                </h1>
                <p className="text-sm text-gray-600">Preencha os dados do produto</p>
              </div>
            </div>
            
            <Button
              onClick={handleCancelar}
              className="bg-orange-600 hover:bg-orange-700 text-white"
            >
              Voltar para Lista
            </Button>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <ProductForm
              key={editingProduct?.id ? `edit-${editingProduct.id}-${Date.now()}` : `new-${Date.now()}`}
              productId={editingProduct?.id}
              onSuccess={handleSalvarProduto}
              onCancel={handleCancelar}
            />
          </div>
        </main>
      </div>
    )
  }

  // View de visualização do produto
  if (viewMode === 'view' && viewingProduct) {
    return (
      <div className="pb-8">
        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center mb-6">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
                <Package className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  Visualizar Produto
                </h1>
                <p className="text-sm text-gray-600">{viewingProduct.name}</p>
              </div>
            </div>
            
            <div className="flex gap-2">
              <Button
                onClick={() => handleEditarProduto(viewingProduct)}
                className="bg-blue-600 hover:bg-blue-700 text-white"
              >
                Editar Produto
              </Button>
              <Button
                onClick={handleVoltarParaLista}
                className="bg-orange-600 hover:bg-orange-700 text-white"
              >
                Voltar para Lista
              </Button>
            </div>
          </div>

          {/* Card de visualização do produto */}
          <div className="bg-white rounded-lg border p-6">
            {/* Imagem do produto (se existir) */}
            {viewingProduct.image_url && (
              <div className="mb-6">
                <h2 className="text-lg font-semibold text-gray-900 border-b pb-2 mb-4">
                  Imagem do Produto
                </h2>
                <div className="flex justify-center">
                  <img 
                    src={viewingProduct.image_url} 
                    alt={viewingProduct.name}
                    className="max-w-md w-full h-auto rounded-lg shadow-md object-contain"
                    onError={(e) => {
                      e.currentTarget.style.display = 'none'
                    }}
                  />
                </div>
              </div>
            )}
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Informações básicas */}
              <div className="space-y-4">
                <h2 className="text-lg font-semibold text-gray-900 border-b pb-2">
                  Informações Básicas
                </h2>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Nome do Produto</label>
                  <p className="text-gray-900 font-medium">{viewingProduct.name}</p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Código de Barras</label>
                  <p className="text-gray-900">{viewingProduct.barcode || 'Não informado'}</p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Unidade de Medida</label>
                  <p className="text-gray-900">{viewingProduct.unit_measure}</p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Status</label>
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                    viewingProduct.active 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-red-100 text-red-800'
                  }`}>
                    {viewingProduct.active ? 'Ativo' : 'Inativo'}
                  </span>
                </div>
              </div>

              {/* Preços e estoque */}
              <div className="space-y-4">
                <h2 className="text-lg font-semibold text-gray-900 border-b pb-2">
                  Preços e Estoque
                </h2>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Preço de Venda</label>
                  <p className="text-xl font-bold text-green-600">{formatPrice(viewingProduct.sale_price)}</p>
                </div>
                
                {viewingProduct.cost_price > 0 && (
                  <div>
                    <label className="block text-sm font-medium text-gray-600">Preço de Custo</label>
                    <p className="text-lg font-medium text-gray-700">{formatPrice(viewingProduct.cost_price)}</p>
                  </div>
                )}
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Estoque Atual</label>
                  <p className={`text-lg font-bold ${
                    viewingProduct.current_stock <= viewingProduct.minimum_stock 
                      ? 'text-red-600' 
                      : 'text-gray-900'
                  }`}>
                    {viewingProduct.current_stock} {viewingProduct.unit_measure}
                  </p>
                  {viewingProduct.current_stock <= viewingProduct.minimum_stock && (
                    <p className="text-sm text-red-500 mt-1">⚠️ Estoque baixo!</p>
                  )}
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Estoque Mínimo</label>
                  <p className="text-gray-900">{viewingProduct.minimum_stock} {viewingProduct.unit_measure}</p>
                </div>
              </div>
            </div>

            {/* Informações adicionais */}
            <div className="mt-6 pt-6 border-t">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">
                Informações Adicionais
              </h2>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-gray-600">
                <div>
                  <span className="font-medium">Criado em:</span> {new Date(viewingProduct.created_at).toLocaleDateString('pt-BR')}
                </div>
                <div>
                  <span className="font-medium">Última atualização:</span> {new Date(viewingProduct.updated_at).toLocaleDateString('pt-BR')}
                </div>
                {viewingProduct.expiry_date && (
                  <div>
                    <span className="font-medium">Data de vencimento:</span> {new Date(viewingProduct.expiry_date).toLocaleDateString('pt-BR')}
                  </div>
                )}
                {viewingProduct.cost_price > 0 && viewingProduct.sale_price > 0 && (
                  <div>
                    <span className="font-medium">Margem de lucro:</span> 
                    <span className="ml-1 font-bold text-green-600">
                      {(((viewingProduct.sale_price - viewingProduct.cost_price) / viewingProduct.cost_price) * 100).toFixed(1)}%
                    </span>
                  </div>
                )}
              </div>
            </div>
          </div>
        </main>
        
        {/* Renderizar modal de produto se estiver aberto */}
        {renderProductModal()}
      </div>
    )
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p>Carregando produtos...</p>
        </div>
      </div>
    )
  }

  // View de edição/criação de produto (fullscreen)
  if (isProductModalOpen) {
    return renderProductModal()
  }

  // View de gerenciamento de fornecedores (fullscreen)
  if (isFornecedorModalOpen) {
    return (
      <div className="pb-8">
        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center mb-6">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-green-600 rounded-lg flex items-center justify-center">
                <Users className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  {isFornecedorFormOpen 
                    ? (selectedFornecedor ? 'Editar Fornecedor' : 'Novo Fornecedor')
                    : 'Gerenciar Fornecedores'
                  }
                </h1>
                <p className="text-sm text-gray-600">
                  {isFornecedorFormOpen 
                    ? 'Preencha os dados do fornecedor'
                    : `${fornecedores.length} fornecedor(es) cadastrado(s)`
                  }
                </p>
              </div>
            </div>
            
            <Button
              onClick={handleCloseFornecedorModal}
              className="bg-orange-600 hover:bg-orange-700 text-white"
            >
              Voltar para Produtos
            </Button>
          </div>

          {!isFornecedorFormOpen ? (
            <div className="bg-white rounded-lg shadow">
              <div className="p-6 border-b flex justify-between items-center">
                <div>
                  <h2 className="text-lg font-semibold text-gray-900">Lista de Fornecedores</h2>
                  <p className="text-sm text-gray-600 mt-1">Cadastre e gerencie seus fornecedores</p>
                </div>
                <Button onClick={handleNewFornecedor}>
                  <Plus className="w-4 h-4 mr-2" />
                  Novo Fornecedor
                </Button>
              </div>

              <div className="p-6">
                {fornecedores.length === 0 ? (
                  <div className="text-center py-16">
                    <Users className="w-16 h-16 mx-auto mb-4 text-gray-400" />
                    <h3 className="text-lg font-medium text-gray-900 mb-2">
                      Nenhum fornecedor cadastrado
                    </h3>
                    <p className="text-gray-600 mb-4">
                      Comece cadastrando seu primeiro fornecedor
                    </p>
                    <Button onClick={handleNewFornecedor}>
                      <Plus className="w-4 h-4 mr-2" />
                      Cadastrar Primeiro Fornecedor
                    </Button>
                  </div>
                ) : (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {fornecedores.map((fornecedor) => (
                      <div
                        key={fornecedor.id}
                        className="p-4 border border-gray-200 rounded-lg hover:border-blue-300 hover:shadow-md transition-all"
                      >
                        <div className="flex items-start justify-between mb-3">
                          <h3 className="font-semibold text-gray-900 text-lg">{fornecedor.nome}</h3>
                          <span
                            className={`px-2 py-1 text-xs font-medium rounded-full ${
                              fornecedor.ativo
                                ? 'bg-green-100 text-green-800'
                                : 'bg-red-100 text-red-800'
                            }`}
                          >
                            {fornecedor.ativo ? 'Ativo' : 'Inativo'}
                          </span>
                        </div>
                        
                        <div className="space-y-2 text-sm text-gray-600 mb-4">
                          {fornecedor.cnpj && (
                            <div>
                              <span className="font-medium">CNPJ:</span> {fornecedor.cnpj}
                            </div>
                          )}
                          {fornecedor.telefone && (
                            <div>
                              <span className="font-medium">Tel:</span> {fornecedor.telefone}
                            </div>
                          )}
                          {fornecedor.email && (
                            <div>
                              <span className="font-medium">E-mail:</span> {fornecedor.email}
                            </div>
                          )}
                          {fornecedor.endereco && (
                            <div>
                              <span className="font-medium">End:</span> {fornecedor.endereco}
                            </div>
                          )}
                        </div>
                        
                        <div className="flex gap-2 pt-3 border-t">
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => handleEditFornecedor(fornecedor)}
                            className="flex-1"
                          >
                            <Edit className="w-4 h-4 mr-1" />
                            Editar
                          </Button>
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => handleDeleteFornecedor(fornecedor.id)}
                          >
                            <Trash2 className="w-4 h-4 text-red-600" />
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          ) : (
            <div className="bg-white rounded-lg shadow p-6">
              <button
                onClick={() => {
                  setIsFornecedorFormOpen(false)
                  setSelectedFornecedor(undefined)
                }}
                className="text-sm text-blue-600 hover:text-blue-800 mb-6 flex items-center gap-1 font-medium"
              >
                ← Voltar para lista de fornecedores
              </button>
              <FornecedorForm
                fornecedor={selectedFornecedor}
                onSubmit={handleSubmitFornecedor}
                onCancel={() => {
                  setIsFornecedorFormOpen(false)
                  setSelectedFornecedor(undefined)
                }}
                isSubmitting={isSubmittingFornecedor}
              />
            </div>
          )}
        </main>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-blue-100 rounded-lg">
            <Package className="w-6 h-6 text-blue-600" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Produtos</h1>
            <p className="text-sm text-gray-600">Gerencie seus produtos e estoque</p>
          </div>
        </div>
        
        <div className="flex gap-2">
          {lojaOnline && lojaOnline.ativa && (
            <Button 
              onClick={abrirLojaOnline}
              className="flex items-center gap-2 bg-green-600 hover:bg-green-700 text-white"
              title="Ver catálogo online dos produtos"
            >
              <Store className="w-4 h-4" />
              <span className="hidden sm:inline">Catálogo Online</span>
              <ExternalLink className="w-3 h-3" />
            </Button>
          )}
          <Button 
            onClick={handleOpenFornecedorModal}
            className="flex items-center gap-2 bg-blue-900 hover:bg-blue-800 text-white"
          >
            <Users className="w-4 h-4" />
            Fornecedores
          </Button>
          <Button onClick={handleNovoProduto} className="flex items-center gap-2">
            <Plus className="w-4 h-4" />
            Novo Produto
          </Button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-lg border">
          <div className="text-2xl font-bold text-blue-600">{allProducts.length}</div>
          <div className="text-sm text-gray-600">Total de Produtos</div>
        </div>
        <div className="bg-white p-4 rounded-lg border">
          <div className="text-2xl font-bold text-green-600">{activeProducts.length}</div>
          <div className="text-sm text-gray-600">Produtos Ativos</div>
        </div>
        <div className="bg-white p-4 rounded-lg border">
          <div className="text-2xl font-bold text-red-600">{lowStockProducts.length}</div>
          <div className="text-sm text-gray-600">Estoque Baixo</div>
        </div>
        {/* Valor Total do Estoque - APENAS PARA OWNERS */}
        {isOwner && (
          <div className="bg-white p-4 rounded-lg border">
            <div className="text-2xl font-bold text-purple-600">{formatPrice(totalValue)}</div>
            <div className="text-sm text-gray-600">Valor Total Estoque</div>
          </div>
        )}
      </div>

      {/* Search */}
      <div className="bg-white rounded-lg border p-4">
        <div className="flex items-center gap-2">
          <Search className="w-5 h-5 text-gray-400" />
          <input
            type="text"
            placeholder="Buscar produtos..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="flex-1 border-0 focus:ring-0 focus:outline-none"
          />
        </div>
      </div>

      {/* Products Table */}
      <div className="bg-white rounded-lg border">
        <div className="p-4 border-b">
          <div className="flex justify-between items-center">
            <h2 className="text-lg font-semibold">
              Produtos ({allProducts.length})
            </h2>
            
            <div className="flex items-center space-x-3">
              <div className="text-sm text-gray-600">
                Mostrando {products.length} de {allProducts.length} produtos
              </div>
            </div>
          </div>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nome</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Código</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Preço</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estoque</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {produtosParaExibir.map((product) => (
                <tr key={product.id} className="hover:bg-gray-50">
                  <td className="px-4 py-3">
                    <div className="font-medium text-gray-900 truncate max-w-xs">{product.name}</div>
                  </td>
                  <td className="px-4 py-3 text-sm text-gray-600">
                    {(product as any).codigo_interno || '-'}
                  </td>
                  <td className="px-4 py-3">
                    <div className="text-sm">
                      <div className="font-medium text-green-600">
                        {formatPrice(product.sale_price)}
                      </div>
                      {product.cost_price > 0 && (
                        <div className="text-xs text-gray-500">
                          Custo: {formatPrice(product.cost_price)}
                        </div>
                      )}
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <div className="text-sm">
                      <span className={`font-medium ${
                        product.current_stock <= product.minimum_stock 
                          ? 'text-red-600' 
                          : 'text-gray-900'
                      }`}>
                        {product.current_stock}
                      </span>
                      <span className="text-gray-500 ml-1">{product.unit_measure}</span>
                      {product.current_stock <= product.minimum_stock && (
                        <div className="text-xs text-red-500">Estoque baixo!</div>
                      )}
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      product.active 
                        ? 'bg-green-100 text-green-800' 
                        : 'bg-red-100 text-red-800'
                    }`}>
                      {product.active ? 'Ativo' : 'Inativo'}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <button 
                        className="p-1 text-blue-600 hover:text-blue-800"
                        title="Visualizar produto"
                        onClick={() => handleVisualizarProduto(product)}
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <button 
                        className="p-1 text-green-600 hover:text-green-800"
                        title="Editar produto"
                        onClick={() => handleEditarProduto(product)}
                      >
                        <Edit className="w-4 h-4" />
                      </button>
                      {can('produtos', 'delete') && (
                        <button 
                          className="p-1 text-red-600 hover:text-red-800"
                          title="Excluir produto"
                          onClick={async () => {
                            console.log('🗑️ Excluir produto:', product.id);
                            if (confirm(`Deseja excluir o produto "${product.name}"?`)) {
                              try {
                                await deleteProduct(product.id);
                                await carregarProdutos(); // Recarregar lista após exclusão
                              } catch (error) {
                                console.error('Erro ao excluir:', error);
                              }
                            }
                          }}
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {/* Botão Ver mais produtos - só mostrar se não há busca ativa */}
        {!mostrarTodos && searchTerm.trim() === '' && allProducts.length > 10 && (
          <div className="p-4 border-t text-center">
            <button
              onClick={toggleMostrarTodos}
              className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 text-sm font-medium"
            >
              Ver mais produtos ({allProducts.length - 10} restantes)
            </button>
          </div>
        )}
        
        {produtosParaExibir.length === 0 && (
          <div className="text-center py-12">
            <Package className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              {searchTerm ? 'Nenhum produto encontrado' : 'Nenhum produto cadastrado'}
            </h3>
            <p className="text-gray-600 mb-4">
              {searchTerm ? 'Tente buscar com outros termos' : 'Comece criando seu primeiro produto'}
            </p>
            {!searchTerm && (
              <Button onClick={handleNovoProduto} className="flex items-center gap-2 mx-auto">
                <Plus className="w-4 h-4" />
                Criar Primeiro Produto
              </Button>
            )}
          </div>
        )}
      </div>

      {/* Renderizar modal de produto se estiver aberto */}
      {renderProductModal()}

    </div>
  )
}
