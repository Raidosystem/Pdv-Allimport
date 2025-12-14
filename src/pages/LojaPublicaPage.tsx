import { useState, useEffect } from 'react'
import { useParams } from 'react-router-dom'
import { Search, Phone, Store, ShoppingBag, AlertCircle } from 'lucide-react'
import { lojaOnlineService, type LojaOnline, type ProdutoPublico } from '../services/lojaOnlineService'
import toast from 'react-hot-toast'

export default function LojaPublicaPage() {
  const { slug } = useParams<{ slug: string }>()
  const [loja, setLoja] = useState<LojaOnline | null>(null)
  const [produtos, setProdutos] = useState<ProdutoPublico[]>([])
  const [produtosFiltrados, setProdutosFiltrados] = useState<ProdutoPublico[]>([])
  const [busca, setBusca] = useState('')
  const [categoriaFiltro, setCategoriaFiltro] = useState<string>('todas')
  const [loading, setLoading] = useState(true)
  const [carrinho, setCarrinho] = useState<{ [key: string]: number }>({})

  useEffect(() => {
    carregarDados()
  }, [slug])

  useEffect(() => {
    filtrarProdutos()
  }, [busca, categoriaFiltro, produtos])

  const carregarDados = async () => {
    if (!slug) return
    
    try {
      setLoading(true)
      const [lojaData, produtosData] = await Promise.all([
        lojaOnlineService.buscarLojaPorSlug(slug),
        lojaOnlineService.listarProdutosLoja(slug)
      ])
      
      if (!lojaData) {
        toast.error('Loja não encontrada')
        return
      }

      if (!lojaData.ativa) {
        toast.error('Esta loja está temporariamente indisponível')
        return
      }
      
      setLoja(lojaData)
      setProdutos(produtosData)
      setProdutosFiltrados(produtosData)
    } catch (error) {
      console.error('Erro ao carregar loja:', error)
      toast.error('Erro ao carregar loja')
    } finally {
      setLoading(false)
    }
  }

  const filtrarProdutos = () => {
    let resultado = produtos

    // Filtrar por categoria
    if (categoriaFiltro !== 'todas') {
      resultado = resultado.filter(p => p.categoria_id === categoriaFiltro)
    }

    // Filtrar por busca
    if (busca) {
      resultado = resultado.filter(p =>
        p.nome.toLowerCase().includes(busca.toLowerCase()) ||
        p.descricao?.toLowerCase().includes(busca.toLowerCase())
      )
    }

    setProdutosFiltrados(resultado)
  }

  const getCategorias = () => {
    const categoriasMap = new Map<string, string>()
    produtos.forEach(p => {
      if (p.categoria_id && p.categoria_nome) {
        categoriasMap.set(p.categoria_id, p.categoria_nome)
      }
    })
    return Array.from(categoriasMap.entries()).map(([id, nome]) => ({ id, nome }))
  }

  const getProdutosPorCategoria = () => {
    if (categoriaFiltro !== 'todas') {
      return [{ categoria: categoriaFiltro, produtos: produtosFiltrados }]
    }

    const grupos = new Map<string, ProdutoPublico[]>()
    
    produtosFiltrados.forEach(produto => {
      const categoria = produto.categoria_nome || 'Sem Categoria'
      if (!grupos.has(categoria)) {
        grupos.set(categoria, [])
      }
      grupos.get(categoria)!.push(produto)
    })

    return Array.from(grupos.entries()).map(([categoria, produtos]) => ({
      categoria,
      produtos
    }))
  }

  const adicionarAoCarrinho = (produtoId: string) => {
    setCarrinho(prev => ({
      ...prev,
      [produtoId]: (prev[produtoId] || 0) + 1
    }))
    toast.success('Produto adicionado ao carrinho')
  }

  const getTotalItens = () => {
    return Object.values(carrinho).reduce((sum, qty) => sum + qty, 0)
  }

  const enviarPedidoWhatsApp = () => {
    if (!loja) return

    const itensCarrinho = produtos
      .filter(p => carrinho[p.id])
      .map(p => ({
        nome: p.nome,
        quantidade: carrinho[p.id],
        preco: p.preco,
        subtotal: p.preco * carrinho[p.id]
      }))

    if (itensCarrinho.length === 0) {
      toast.error('Carrinho vazio')
      return
    }

    const total = itensCarrinho.reduce((sum, item) => sum + item.subtotal, 0)
    
    let mensagem = `🛒 *Pedido - ${loja.nome}*\n\n`
    itensCarrinho.forEach(item => {
      mensagem += `• ${item.quantidade}x ${item.nome}\n`
      if (loja.mostrar_preco) {
        mensagem += `  R$ ${item.preco.toFixed(2)} cada = R$ ${item.subtotal.toFixed(2)}\n`
      }
    })
    
    if (loja.mostrar_preco) {
      mensagem += `\n💰 *Total: R$ ${total.toFixed(2)}*`
    }

    const whatsappUrl = `https://wa.me/55${loja.whatsapp.replace(/\D/g, '')}?text=${encodeURIComponent(mensagem)}`
    window.open(whatsappUrl, '_blank')
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Carregando loja...</p>
        </div>
      </div>
    )
  }

  if (!loja) {
    return (
      <div className="flex justify-center items-center h-screen bg-gray-50">
        <div className="text-center">
          <AlertCircle className="w-16 h-16 text-red-500 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-800 mb-2">Loja não encontrada</h1>
          <p className="text-gray-600">Verifique se o endereço está correto</p>
        </div>
      </div>
    )
  }

  const totalItens = getTotalItens()

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header 
        className="bg-white border-b shadow-sm sticky top-0 z-50"
        style={{ borderColor: loja.cor_primaria }}
      >
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              {loja.logo_url ? (
                <img src={loja.logo_url} alt={loja.nome} className="h-12 w-auto object-contain" />
              ) : (
                <Store className="w-12 h-12" style={{ color: loja.cor_primaria }} />
              )}
              <div>
                <h1 className="text-2xl font-bold" style={{ color: loja.cor_primaria }}>
                  {loja.nome}
                </h1>
                {loja.descricao && (
                  <p className="text-sm text-gray-600">{loja.descricao}</p>
                )}
              </div>
            </div>

            <div className="flex items-center gap-3">
              <a
                href={`https://wa.me/55${loja.whatsapp.replace(/\D/g, '')}`}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
              >
                <Phone className="w-5 h-5" />
                <span className="hidden sm:inline">Contato</span>
              </a>

              {loja.permitir_carrinho && totalItens > 0 && (
                <button
                  onClick={enviarPedidoWhatsApp}
                  className="relative flex items-center gap-2 px-4 py-2 rounded-lg text-white transition-colors"
                  style={{ backgroundColor: loja.cor_primaria }}
                >
                  <ShoppingBag className="w-5 h-5" />
                  <span className="hidden sm:inline">Carrinho</span>
                  <span className="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full w-6 h-6 flex items-center justify-center">
                    {totalItens}
                  </span>
                </button>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Busca e Filtros */}
      <div className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 py-4 space-y-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input
              type="text"
              value={busca}
              onChange={(e) => setBusca(e.target.value)}
              placeholder="Buscar produtos..."
              className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          {/* Filtro de Categorias */}
          <div className="flex gap-2 overflow-x-auto pb-2">
            <button
              onClick={() => setCategoriaFiltro('todas')}
              className={`px-4 py-2 rounded-full whitespace-nowrap transition-colors ${
                categoriaFiltro === 'todas'
                  ? 'text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
              style={categoriaFiltro === 'todas' ? { backgroundColor: loja.cor_primaria } : {}}
            >
              Todas
            </button>
            {getCategorias().map(cat => (
              <button
                key={cat.id}
                onClick={() => setCategoriaFiltro(cat.id)}
                className={`px-4 py-2 rounded-full whitespace-nowrap transition-colors ${
                  categoriaFiltro === cat.id
                    ? 'text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
                style={categoriaFiltro === cat.id ? { backgroundColor: loja.cor_primaria } : {}}
              >
                {cat.nome}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Produtos por Categoria */}
      <div className="max-w-7xl mx-auto px-4 py-8">
        {produtosFiltrados.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-500 text-lg">Nenhum produto encontrado</p>
          </div>
        ) : (
          <div className="space-y-12">
            {getProdutosPorCategoria().map((grupo, index) => (
              <div key={index}>
                {/* Título da Categoria */}
                {categoriaFiltro === 'todas' && (
                  <h2 className="text-2xl font-bold mb-6 pb-2 border-b-2" style={{ color: loja.cor_primaria, borderColor: loja.cor_primaria }}>
                    {grupo.categoria}
                  </h2>
                )}

                {/* Grid de Produtos */}
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                  {grupo.produtos.map(produto => (
                    <div key={produto.id} className="bg-white rounded-lg shadow hover:shadow-lg transition-shadow overflow-hidden">
                      {/* Imagem */}
                      <div className="aspect-square bg-gray-100 flex items-center justify-center overflow-hidden">
                        {produto.imagem_url ? (
                          <img 
                            src={produto.imagem_url} 
                            alt={produto.nome}
                            className="w-full h-full object-cover"
                          />
                        ) : (
                          <Store className="w-16 h-16 text-gray-300" />
                        )}
                      </div>

                      {/* Conteúdo */}
                      <div className="p-4">
                        <h3 className="font-semibold text-gray-800 mb-1 line-clamp-2">
                          {produto.nome}
                        </h3>
                        
                        {produto.descricao && (
                          <p className="text-sm text-gray-600 mb-2 line-clamp-2">
                            {produto.descricao}
                          </p>
                        )}

                        {loja.mostrar_preco && (
                          <p className="text-2xl font-bold mb-3" style={{ color: loja.cor_primaria }}>
                            R$ {produto.preco.toFixed(2)}
                          </p>
                        )}

                        {loja.mostrar_estoque && (
                          <p className="text-sm text-gray-500 mb-3">
                            Estoque: {produto.quantidade} un
                          </p>
                        )}

                        {loja.permitir_carrinho ? (
                          <button
                            onClick={() => adicionarAoCarrinho(produto.id)}
                            disabled={produto.quantidade === 0}
                            className="w-full py-2 px-4 rounded-lg text-white font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                            style={{ backgroundColor: loja.cor_primaria }}
                          >
                            {produto.quantidade === 0 ? 'Esgotado' : 'Adicionar'}
                          </button>
                        ) : (
                          <a
                            href={`https://wa.me/55${loja.whatsapp.replace(/\D/g, '')}?text=${encodeURIComponent(`Tenho interesse no produto: ${produto.nome}`)}`}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="w-full block py-2 px-4 rounded-lg bg-green-600 text-white text-center font-medium hover:bg-green-700 transition-colors"
                          >
                            Consultar
                          </a>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Footer */}
      <footer className="bg-white border-t mt-12">
        <div className="max-w-7xl mx-auto px-4 py-6 text-center text-gray-600">
          <p>© {new Date().getFullYear()} {loja.nome} - Todos os direitos reservados</p>
        </div>
      </footer>
    </div>
  )
}
