# 🛍️ SISTEMA DE LOJA ONLINE - GUIA COMPLETO DE IMPLEMENTAÇÃO

## ✅ **JÁ IMPLEMENTADO**

### 1. Banco de Dados (`CRIAR_LOJA_ONLINE_ESTRUTURA.sql`)
- ✅ Tabela `lojas_online` com todas configurações
- ✅ Tabela `acessos_loja` para analytics
- ✅ RLS Policies (segurança)
- ✅ Funções RPC públicas

### 2. Service Layer (`src/services/lojaOnlineService.ts`)
- ✅ CRUD completo de loja
- ✅ Upload de logo
- ✅ Geração de mensagem WhatsApp
- ✅ Analytics
- ✅ Listagem pública de produtos

### 3. Painel Admin (`src/pages/admin/LojaOnlinePage.tsx`)
- ✅ Ativar/desativar loja
- ✅ Configurar WhatsApp
- ✅ Personalização (cores, logo)
- ✅ Preview da loja

---

## 📝 **PRÓXIMOS PASSOS - IMPLEMENTAR**

### 4. Catálogo Público (`src/pages/public/CatalogoPage.tsx`)

```tsx
import React, { useState, useEffect } from 'react'
import { useParams, Link } from 'react-router-dom'
import { Search, ShoppingCart, Store, Phone } from 'lucide-react'
import { lojaOnlineService, type LojaOnline, type ProdutoPublico } from '../../services/lojaOnlineService'
import { useCarrinho } from '../../hooks/useCarrinho'

export default function CatalogoPage() {
  const { slug } = useParams<{ slug: string }>()
  const [loja, setLoja] = useState<LojaOnline | null>(null)
  const [produtos, setProdutos] = useState<ProdutoPublico[]>([])
  const [produtosFiltrados, setProdutosFiltrados] = useState<ProdutoPublico[]>([])
  const [busca, setBusca] = useState('')
  const [categoriaFiltro, setCategoriaFiltro] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const { adicionarAoCarrinho, totalItens } = useCarrinho()

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
      
      setLoja(lojaData)
      setProdutos(produtosData)
      setProdutosFiltrados(produtosData)
    } catch (error) {
      console.error('Erro:', error)
    } finally {
      setLoading(false)
    }
  }

  const filtrarProdutos = () => {
    let resultado = [...produtos]

    // Filtrar por busca
    if (busca) {
      resultado = resultado.filter(p =>
        p.nome.toLowerCase().includes(busca.toLowerCase())
      )
    }

    // Filtrar por categoria
    if (categoriaFiltro) {
      resultado = resultado.filter(p => p.categoria_id === categoriaFiltro)
    }

    setProdutosFiltrados(resultado)
  }

  const categorias = Array.from(new Set(produtos.map(p => p.categoria_nome).filter(Boolean)))

  if (loading) {
    return <div className="flex justify-center items-center h-screen">Carregando...</div>
  }

  if (!loja) {
    return <div className="text-center p-8">Loja não encontrada</div>
  }

  return (
    <div className="min-h-screen bg-gray-50" style={{ 
      '--cor-primaria': loja.cor_primaria,
      '--cor-secundaria': loja.cor_secundaria 
    } as React.CSSProperties}>
      {/* Header */}
      <header className="bg-white border-b shadow-sm sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              {loja.logo_url && (
                <img src={loja.logo_url} alt={loja.nome} className="h-12 w-auto" />
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

            <div className="flex items-center gap-4">
              <a
                href={`https://wa.me/55${loja.whatsapp.replace(/\D/g, '')}`}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 text-green-600 hover:text-green-700"
              >
                <Phone className="w-5 h-5" />
                <span className="hidden sm:inline">{loja.whatsapp}</span>
              </a>

              {loja.permitir_carrinho && (
                <Link
                  to={`/loja/${slug}/carrinho`}
                  className="relative flex items-center gap-2 px-4 py-2 rounded-lg transition-colors"
                  style={{ backgroundColor: loja.cor_primaria, color: 'white' }}
                >
                  <ShoppingCart className="w-5 h-5" />
                  {totalItens > 0 && (
                    <span className="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full w-6 h-6 flex items-center justify-center">
                      {totalItens}
                    </span>
                  )}
                  Carrinho
                </Link>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Busca e Filtros */}
      <div className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex flex-col md:flex-row gap-4">
            {/* Busca */}
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                value={busca}
                onChange={(e) => setBusca(e.target.value)}
                placeholder="Buscar produtos..."
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>

            {/* Filtro de Categoria */}
            <div className="flex gap-2 flex-wrap">
              <button
                onClick={() => setCategoriaFiltro(null)}
                className={`px-4 py-2 rounded-lg transition-colors ${
                  categoriaFiltro === null
                    ? 'bg-blue-600 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                Todas
              </button>
              {categorias.map(cat => (
                <button
                  key={cat}
                  onClick={() => setCategoriaFiltro(cat)}
                  className={`px-4 py-2 rounded-lg transition-colors ${
                    categoriaFiltro === cat
                      ? 'bg-blue-600 text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  {cat}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Grid de Produtos */}
      <main className="max-w-7xl mx-auto px-4 py-8">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {produtosFiltrados.map(produto => (
            <div
              key={produto.id}
              className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden hover:shadow-md transition-shadow"
            >
              {/* Imagem */}
              <div className="aspect-square bg-gray-100 flex items-center justify-center">
                {produto.imagem_url ? (
                  <img
                    src={produto.imagem_url}
                    alt={produto.nome}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <Store className="w-20 h-20 text-gray-300" />
                )}
              </div>

              {/* Informações */}
              <div className="p-4">
                <h3 className="font-semibold text-gray-900 mb-1 line-clamp-2">
                  {produto.nome}
                </h3>
                
                {produto.descricao && (
                  <p className="text-sm text-gray-600 mb-2 line-clamp-2">
                    {produto.descricao}
                  </p>
                )}

                {loja.mostrar_preco && (
                  <p className="text-2xl font-bold mb-3" style={{ color: loja.cor_primaria }}>
                    R$ {produto.preco.toFixed(2).replace('.', ',')}
                  </p>
                )}

                {loja.mostrar_estoque && (
                  <p className="text-sm text-gray-600 mb-3">
                    {produto.quantidade > 0 ? (
                      <span className="text-green-600">✓ Em estoque ({produto.quantidade})</span>
                    ) : (
                      <span className="text-red-600">✗ Esgotado</span>
                    )}
                  </p>
                )}

                {loja.permitir_carrinho && produto.quantidade > 0 && (
                  <button
                    onClick={() => {
                      adicionarAoCarrinho({
                        produto_id: produto.id,
                        nome: produto.nome,
                        preco: produto.preco,
                        quantidade: 1,
                        imagem_url: produto.imagem_url
                      })
                    }}
                    className="w-full py-2 rounded-lg font-medium transition-colors"
                    style={{ backgroundColor: loja.cor_primaria, color: 'white' }}
                  >
                    Adicionar ao Carrinho
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>

        {produtosFiltrados.length === 0 && (
          <div className="text-center py-12">
            <Store className="w-16 h-16 text-gray-300 mx-auto mb-4" />
            <p className="text-gray-600">Nenhum produto encontrado</p>
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className="bg-white border-t mt-12">
        <div className="max-w-7xl mx-auto px-4 py-6 text-center text-sm text-gray-600">
          <p>© {new Date().getFullYear()} {loja.nome} - Todos os direitos reservados</p>
          <p className="mt-1">Desenvolvido com PDV Allimport</p>
        </div>
      </footer>
    </div>
  )
}
```

---

### 5. Hook do Carrinho (`src/hooks/useCarrinho.ts`)

```typescript
import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { ItemCarrinho } from '../services/lojaOnlineService'

interface CarrinhoStore {
  itens: ItemCarrinho[]
  totalItens: number
  totalValor: number
  adicionarAoCarrinho: (item: ItemCarrinho) => void
  removerDoCarrinho: (produtoId: string) => void
  atualizarQuantidade: (produtoId: string, quantidade: number) => void
  limparCarrinho: () => void
}

export const useCarrinho = create<CarrinhoStore>()(
  persist(
    (set, get) => ({
      itens: [],
      totalItens: 0,
      totalValor: 0,

      adicionarAoCarrinho: (item) => {
        const itens = get().itens
        const existente = itens.find(i => i.produto_id === item.produto_id)

        if (existente) {
          // Incrementar quantidade
          set({
            itens: itens.map(i =>
              i.produto_id === item.produto_id
                ? { ...i, quantidade: i.quantidade + item.quantidade }
                : i
            )
          })
        } else {
          // Adicionar novo
          set({ itens: [...itens, item] })
        }

        // Recalcular totais
        const novosItens = get().itens
        set({
          totalItens: novosItens.reduce((acc, i) => acc + i.quantidade, 0),
          totalValor: novosItens.reduce((acc, i) => acc + (i.preco * i.quantidade), 0)
        })
      },

      removerDoCarrinho: (produtoId) => {
        const itens = get().itens.filter(i => i.produto_id !== produtoId)
        set({
          itens,
          totalItens: itens.reduce((acc, i) => acc + i.quantidade, 0),
          totalValor: itens.reduce((acc, i) => acc + (i.preco * i.quantidade), 0)
        })
      },

      atualizarQuantidade: (produtoId, quantidade) => {
        if (quantidade <= 0) {
          get().removerDoCarrinho(produtoId)
          return
        }

        const itens = get().itens.map(i =>
          i.produto_id === produtoId ? { ...i, quantidade } : i
        )

        set({
          itens,
          totalItens: itens.reduce((acc, i) => acc + i.quantidade, 0),
          totalValor: itens.reduce((acc, i) => acc + (i.preco * i.quantidade), 0)
        })
      },

      limparCarrinho: () => {
        set({ itens: [], totalItens: 0, totalValor: 0 })
      }
    }),
    {
      name: 'carrinho-storage'
    }
  )
)
```

---

### 6. Página do Carrinho (`src/pages/public/CarrinhoPage.tsx`)

```tsx
import React, { useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { Trash2, Plus, Minus, ShoppingBag, ArrowLeft } from 'lucide-react'
import { useCarrinho } from '../../hooks/useCarrinho'
import { lojaOnlineService } from '../../services/lojaOnlineService'
import toast from 'react-hot-toast'

export default function CarrinhoPage() {
  const { slug } = useParams()
  const navigate = useNavigate()
  const { itens, totalValor, atualizarQuantidade, removerDoCarrinho, limparCarrinho } = useCarrinho()
  const [enviando, setEnviando] = useState(false)
  const [dadosCliente, setDadosCliente] = useState({
    nome: '',
    whatsapp: '',
    endereco: '',
    cep: '',
    observacoes: ''
  })

  const handleEnviarPedido = async () => {
    if (!slug) return

    if (!dadosCliente.nome || !dadosCliente.whatsapp) {
      toast.error('Preencha nome e WhatsApp')
      return
    }

    if (!lojaOnlineService.validarWhatsApp(dadosCliente.whatsapp)) {
      toast.error('WhatsApp inválido')
      return
    }

    try {
      setEnviando(true)
      const loja = await lojaOnlineService.buscarLojaPorSlug(slug)
      await lojaOnlineService.enviarPedidoWhatsApp(loja, itens, dadosCliente)
      
      limparCarrinho()
      toast.success('Pedido enviado! Você será redirecionado para o WhatsApp')
      
      setTimeout(() => navigate(`/loja/${slug}`), 2000)
    } catch (error) {
      console.error('Erro ao enviar pedido:', error)
      toast.error('Erro ao enviar pedido')
    } finally {
      setEnviando(false)
    }
  }

  if (itens.length === 0) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="text-center">
          <ShoppingBag className="w-20 h-20 text-gray-300 mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Carrinho vazio</h2>
          <p className="text-gray-600 mb-6">Adicione produtos para continuar</p>
          <button
            onClick={() => navigate(`/loja/${slug}`)}
            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            Ver Produtos
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8 px-4">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <button
          onClick={() => navigate(`/loja/${slug}`)}
          className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-6"
        >
          <ArrowLeft className="w-5 h-5" />
          Voltar para loja
        </button>

        <h1 className="text-3xl font-bold text-gray-900 mb-8">Seu Carrinho</h1>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Itens */}
          <div className="lg:col-span-2 space-y-4">
            {itens.map(item => (
              <div key={item.produto_id} className="bg-white rounded-lg shadow-sm border p-4 flex gap-4">
                {item.imagem_url && (
                  <img
                    src={item.imagem_url}
                    alt={item.nome}
                    className="w-24 h-24 object-cover rounded"
                  />
                )}
                <div className="flex-1">
                  <h3 className="font-semibold text-gray-900 mb-2">{item.nome}</h3>
                  <p className="text-lg font-bold text-blue-600 mb-3">
                    R$ {item.preco.toFixed(2).replace('.', ',')}
                  </p>
                  <div className="flex items-center gap-4">
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => atualizarQuantidade(item.produto_id, item.quantidade - 1)}
                        className="p-1 border rounded hover:bg-gray-100"
                      >
                        <Minus className="w-4 h-4" />
                      </button>
                      <span className="font-medium w-8 text-center">{item.quantidade}</span>
                      <button
                        onClick={() => atualizarQuantidade(item.produto_id, item.quantidade + 1)}
                        className="p-1 border rounded hover:bg-gray-100"
                      >
                        <Plus className="w-4 h-4" />
                      </button>
                    </div>
                    <button
                      onClick={() => removerDoCarrinho(item.produto_id)}
                      className="text-red-600 hover:text-red-700"
                    >
                      <Trash2 className="w-5 h-5" />
                    </button>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-lg font-bold">
                    R$ {(item.preco * item.quantidade).toFixed(2).replace('.', ',')}
                  </p>
                </div>
              </div>
            ))}
          </div>

          {/* Resumo e Dados */}
          <div className="space-y-6">
            {/* Total */}
            <div className="bg-white rounded-lg shadow-sm border p-6">
              <h3 className="font-semibold text-gray-900 mb-4">Resumo</h3>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span>Subtotal</span>
                  <span>R$ {totalValor.toFixed(2).replace('.', ',')}</span>
                </div>
                <div className="border-t pt-2 flex justify-between font-bold text-lg">
                  <span>Total</span>
                  <span className="text-blue-600">R$ {totalValor.toFixed(2).replace('.', ',')}</span>
                </div>
              </div>
            </div>

            {/* Dados do Cliente */}
            <div className="bg-white rounded-lg shadow-sm border p-6">
              <h3 className="font-semibold text-gray-900 mb-4">Seus Dados</h3>
              <div className="space-y-3">
                <input
                  type="text"
                  placeholder="Nome *"
                  value={dadosCliente.nome}
                  onChange={(e) => setDadosCliente({ ...dadosCliente, nome: e.target.value })}
                  className="w-full px-3 py-2 border rounded-lg"
                />
                <input
                  type="text"
                  placeholder="WhatsApp *"
                  value={dadosCliente.whatsapp}
                  onChange={(e) => setDadosCliente({ ...dadosCliente, whatsapp: e.target.value })}
                  className="w-full px-3 py-2 border rounded-lg"
                />
                <input
                  type="text"
                  placeholder="Endereço"
                  value={dadosCliente.endereco}
                  onChange={(e) => setDadosCliente({ ...dadosCliente, endereco: e.target.value })}
                  className="w-full px-3 py-2 border rounded-lg"
                />
                <input
                  type="text"
                  placeholder="CEP"
                  value={dadosCliente.cep}
                  onChange={(e) => setDadosCliente({ ...dadosCliente, cep: e.target.value })}
                  className="w-full px-3 py-2 border rounded-lg"
                />
                <textarea
                  placeholder="Observações"
                  value={dadosCliente.observacoes}
                  onChange={(e) => setDadosCliente({ ...dadosCliente, observacoes: e.target.value })}
                  rows={3}
                  className="w-full px-3 py-2 border rounded-lg"
                />
              </div>

              <button
                onClick={handleEnviarPedido}
                disabled={enviando}
                className="w-full mt-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 font-medium disabled:opacity-50"
              >
                {enviando ? 'Enviando...' : '📲 Finalizar Pedido pelo WhatsApp'}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
```

---

### 7. Adicionar Rotas (`src/App.tsx` ou `src/routes.tsx`)

```tsx
// Importar componentes
import CatalogoPage from './pages/public/CatalogoPage'
import CarrinhoPage from './pages/public/CarrinhoPage'
import LojaOnlinePage from './pages/admin/LojaOnlinePage'

// Adicionar rotas
const routes = [
  // ... rotas existentes
  
  // Rotas PÚBLICAS (sem autenticação)
  {
    path: '/loja/:slug',
    element: <CatalogoPage />
  },
  {
    path: '/loja/:slug/carrinho',
    element: <CarrinhoPage />
  },
  
  // Rota ADMIN (com autenticação)
  {
    path: '/admin/loja-online',
    element: <ProtectedRoute><LojaOnlinePage /></ProtectedRoute>
  }
]
```

---

### 8. Adicionar ao Menu Admin (`src/pages/AdministracaoPageNew.tsx`)

```tsx
// Adicionar item no menu
{
  id: 'loja-online' as ViewMode,
  label: 'Loja Online',
  icon: Store,
  description: 'Catálogo com carrinho WhatsApp'
},

// Adicionar no switch de ViewMode
case 'loja-online':
  return <LojaOnlinePage />
```

---

## 🚀 **COMO USAR**

### Passo 1: Executar SQL
```bash
# No Supabase SQL Editor, execute:
CRIAR_LOJA_ONLINE_ESTRUTURA.sql
```

### Passo 2: Instalar Dependências
```bash
npm install zustand
```

### Passo 3: Criar Bucket no Supabase
```
1. Ir em Storage → Create bucket
2. Nome: "lojas"
3. Public: true
```

### Passo 4: Criar os Arquivos
- Copiar código dos componentes acima
- Criar arquivos nas pastas corretas

### Passo 5: Testar
```
1. Login no sistema
2. Ir em Admin → Loja Online
3. Configurar nome, WhatsApp, cores
4. Ativar loja
5. Copiar URL e abrir em aba anônima
6. Adicionar produtos ao carrinho
7. Finalizar pedido
8. Verificar mensagem no WhatsApp
```

---

## 📊 **FUNCIONALIDADES COMPLETAS**

✅ **Admin**
- Criar/editar loja
- Upload de logo
- Personalizar cores
- Ativar/desativar
- Ver analytics

✅ **Catálogo Público**
- Grid responsivo de produtos
- Busca por nome
- Filtro por categoria
- Adicionar ao carrinho

✅ **Carrinho**
- Adicionar/remover produtos
- Alterar quantidade
- Preencher dados
- Enviar para WhatsApp

✅ **WhatsApp**
- Mensagem formatada
- Detalhes do cliente
- Lista de produtos
- Total do pedido

✅ **Analytics**
- Total de visitas
- Produtos mais vistos
- Taxa de conversão
- Pedidos realizados

---

## 🎨 **PERSONALIZAÇÃO**

Cada loja terá:
- URL única (`/loja/minhaloja`)
- Logo personalizada
- Cores do tema (primária e secundária)
- Nome e descrição próprios
- WhatsApp individual

---

## ✨ **DIFERENCIAIS**

1. **Zero Configuração**: Produtos aparecem automaticamente
2. **Sem Taxas**: Não cobra por transação (só WhatsApp)
3. **Responsivo**: Funciona em qualquer dispositivo
4. **Simples**: Cliente não precisa criar conta
5. **Rápido**: Finaliza em 2 cliques pelo WhatsApp

---

**Pronto! Implemente os arquivos acima e terá um sistema completo de loja online! 🎉**
