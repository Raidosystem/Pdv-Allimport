import { useState, useEffect } from 'react'
import { toast } from 'react-hot-toast'
import { supabase } from '../lib/supabase'

interface Product {
  id: string
  user_id?: string
  name: string
  barcode: string
  codigo_interno?: string
  category_id?: string
  sale_price: number
  cost_price: number
  current_stock: number
  minimum_stock: number
  unit_measure: string
  active: boolean
  expiry_date?: string | null
  image_url?: string | null
  created_at: string
  updated_at: string
}

// Função para carregar produtos do Supabase com RLS
const loadAllProducts = async (): Promise<Product[]> => {
  try {
    console.log('🔍 [useProdutos] Buscando produtos no Supabase com RLS...')
    console.log('📦 [useProdutos] BUSCANDO PRODUTOS NO SUPABASE (respeitando RLS)')
    
    const { data, error } = await supabase
      .from('produtos')
      .select('*')
      .eq('ativo', true)
      .order('nome')
    
    if (error) {
      console.error('❌ [useProdutos] Erro ao buscar produtos:', error)
      console.error('🔧 [useProdutos] Código do erro:', error.code)
      console.error('🔧 [useProdutos] Detalhes:', error.details)
      throw new Error(`Erro do Supabase: ${error.message}`)
    }
    
    console.log(`✅ [useProdutos] Encontrados ${data?.length || 0} produtos no Supabase (respeitando RLS)`)
    
    // Adaptar formato do Supabase para o frontend
    const adaptedProducts: Product[] = (data || []).map(produto => ({
      id: produto.id,
      user_id: produto.user_id,
      name: produto.nome || 'Produto sem nome',
      barcode: produto.codigo_barras || '',
      codigo_interno: produto.codigo_interno || '',
      category_id: produto.categoria_id,
      sale_price: produto.preco || 0,
      cost_price: produto.preco_custo || 0,
      current_stock: produto.estoque || 0,
      minimum_stock: produto.estoque_minimo || 0,
      unit_measure: produto.unidade || 'un',
      active: produto.ativo !== false,
      expiry_date: produto.data_validade || null,
      image_url: produto.imagem_url || produto.image_url || null,
      created_at: produto.criado_em || produto.created_at || new Date().toISOString(),
      updated_at: produto.atualizado_em || produto.updated_at || new Date().toISOString()
    }))
    
    console.log(`✅ [useProdutos] ${adaptedProducts.length} produtos carregados e adaptados do Supabase`)
    if (adaptedProducts.length > 0) {
      console.log('📋 [useProdutos] Primeiro produto:', adaptedProducts[0])
    }
    return adaptedProducts
  } catch (error) {
    console.error('❌ [useProdutos] Erro ao carregar produtos do Supabase:', error)
    throw error
  }
}

export function useProdutos() {
  const [todosProdutos, setTodosProdutos] = useState<Product[]>([]) // Lista completa
  const [produtos, setProdutos] = useState<Product[]>([]) // Lista exibida
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [mostrarTodos, setMostrarTodos] = useState(false) // Iniciar mostrando apenas 10

  // Carregar todos os produtos do backup
  const carregarTodosProdutos = async () => {
    try {
      console.log('🔍 [useProdutos] Iniciando carregamento de produtos...')
      console.log('🔍 [useProdutos] BACKUP DESABILITADO - Usando apenas Supabase com RLS')
      setLoading(true)
      setError(null)
      
      const allProducts = await loadAllProducts()
      console.log('🔍 [useProdutos] Produtos carregados:', allProducts.length)
      setTodosProdutos(allProducts)
      
      // Inicialmente mostrar apenas os primeiros 10 produtos
      const limitedProducts = allProducts.slice(0, 10)
      console.log('🔍 [useProdutos] Produtos limitados definidos:', limitedProducts.length)
      setProdutos(limitedProducts)
      setMostrarTodos(false)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro desconhecido'
      console.error('❌ [useProdutos] Erro no carregamento:', err)
      setError(errorMessage)
      toast.error(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  // Carregar apenas os últimos 10 produtos
  const carregarProdutosLimitados = async () => {
    if (todosProdutos.length > 0) {
      setProdutos(todosProdutos.slice(0, 10))
      setMostrarTodos(false)
    } else {
      await carregarTodosProdutos()
    }
  }

  // Função simples para ver todos
  const verTodos = () => {
    setProdutos(todosProdutos)
    setMostrarTodos(true)
  }

  // Carregar produtos na inicialização
  useEffect(() => {
    carregarTodosProdutos()
  }, [])

  return {
    produtos,
    todosProdutos, // Para estatísticas
    loading,
    error,
    mostrarTodos,
    carregarProdutos: carregarTodosProdutos,
    carregarProdutosLimitados,
    toggleMostrarTodos: verTodos
  }
}