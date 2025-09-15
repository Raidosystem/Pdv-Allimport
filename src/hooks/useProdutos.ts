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

// Função para carregar produtos do backup
const loadAllProducts = async (): Promise<Product[]> => {
  try {
    const response = await fetch('/backup-allimport.json')
    const backupData = await response.json()
    return backupData.data?.products || []
  } catch (error) {
    console.error('Erro ao carregar backup:', error)
    return []
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
      setLoading(true)
      setError(null)
      
      const allProducts = await loadAllProducts()
      setTodosProdutos(allProducts)
      
      // Inicialmente mostrar apenas os primeiros 10 produtos
      setProdutos(allProducts.slice(0, 10))
      setMostrarTodos(false)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro desconhecido'
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