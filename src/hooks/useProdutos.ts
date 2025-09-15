import { useState, useEffect } from 'react'
import { toast } from 'react-hot-toast'

interface Product {
  id: string
  user_id?: string
  name: string
  barcode: string
  category_id?: string
  sale_price: number
  cost_price: number
  current_stock: number
  minimum_stock: number
  unit_measure: string
  active: boolean
  expiry_date?: string | null
  created_at: string
  updated_at: string
}

interface ProductFilters {
  search?: string
  active?: boolean | null
  limit?: number
}

// Função para carregar produtos do backup
const loadAllProducts = async (): Promise<Product[]> => {
  try {
    const response = await fetch('/backup-products.json')
    const backupData = await response.json()
    return backupData.data || []
  } catch (error) {
    console.error('Erro ao carregar backup:', error)
    return []
  }
}

export function useProdutos() {
  const [produtos, setProdutos] = useState<Product[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [mostrarTodos, setMostrarTodos] = useState(false)

  // Carregar produtos
  const carregarProdutos = async (filtros: ProductFilters = {}) => {
    try {
      setLoading(true)
      setError(null)
      
      const allProducts = await loadAllProducts()
      let filteredProducts = allProducts

      // Aplicar filtro de busca
      if (filtros.search) {
        const searchLower = filtros.search.toLowerCase()
        filteredProducts = filteredProducts.filter(product =>
          product.name.toLowerCase().includes(searchLower) ||
          product.barcode.includes(filtros.search!)
        )
      }

      // Aplicar filtro de status
      if (filtros.active !== null && filtros.active !== undefined) {
        filteredProducts = filteredProducts.filter(product => product.active === filtros.active)
      }

      // Aplicar limite se especificado
      if (filtros.limit && filtros.limit > 0) {
        filteredProducts = filteredProducts.slice(0, filtros.limit)
      }

      setProdutos(filteredProducts)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro desconhecido'
      setError(errorMessage)
      toast.error(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  // Carregar apenas os últimos 10 produtos
  const carregarProdutosLimitados = async (filtros: ProductFilters = {}) => {
    try {
      setLoading(true)
      setError(null)
      await carregarProdutos({ ...filtros, limit: 10 })
      setMostrarTodos(false)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro desconhecido'
      setError(errorMessage)
      toast.error(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  // Alternar entre mostrar todos ou apenas 10
  const toggleMostrarTodos = async (filtros: ProductFilters = {}) => {
    if (mostrarTodos) {
      await carregarProdutosLimitados(filtros)
    } else {
      await carregarProdutos(filtros)
      setMostrarTodos(true)
    }
  }

  // Carregar produtos na inicialização
  useEffect(() => {
    carregarProdutosLimitados() // Iniciar mostrando apenas os últimos 10
  }, [])

  return {
    produtos,
    loading,
    error,
    mostrarTodos,
    carregarProdutos,
    carregarProdutosLimitados,
    toggleMostrarTodos
  }
}