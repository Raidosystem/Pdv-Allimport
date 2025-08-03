import { useState } from 'react'
import { supabase } from '../lib/supabase'
import type { Product, ProductFormData, Category } from '../types/product'
import { toast } from 'react-hot-toast'

export function useProducts() {
  const [loading, setLoading] = useState(false)
  const [products, setProducts] = useState<Product[]>([])
  const [categories, setCategories] = useState<Category[]>([])

  // Carregar todos os produtos
  const loadProducts = async () => {
    setLoading(true)
    try {
      const { data, error } = await supabase
        .from('produtos')
        .select('*')
        .order('criado_em', { ascending: false })

      if (error) throw error
      setProducts(data || [])
    } catch (error) {
      console.error('Erro ao carregar produtos:', error)
      toast.error('Erro ao carregar produtos')
      setProducts([])
    } finally {
      setLoading(false)
    }
  }

  // Deletar produto
  const deleteProduct = async (productId: string) => {
    setLoading(true)
    try {
      const { error } = await supabase
        .from('produtos')
        .delete()
        .eq('id', productId)

      if (error) throw error
      
      // Atualizar lista local
      setProducts(prev => prev.filter(p => p.id !== productId))
    } catch (error) {
      console.error('Erro ao deletar produto:', error)
      throw error
    } finally {
      setLoading(false)
    }
  }

  // Gerar código interno único
  const generateCode = async (): Promise<string> => {
    const timestamp = Date.now().toString().slice(-6)
    const random = Math.random().toString(36).substring(2, 5).toUpperCase()
    return `PDV${timestamp}${random}`
  }

  // Upload de imagem para Supabase Storage
  const uploadImage = async (file: File): Promise<string | null> => {
    try {
      const fileExt = file.name.split('.').pop()
      const fileName = `${Date.now()}.${fileExt}`
      const filePath = `products/${fileName}`

      const { error } = await supabase.storage
        .from('product-images')
        .upload(filePath, file)

      if (error) {
        console.error('Erro no upload:', error)
        return null
      }

      const { data } = supabase.storage
        .from('product-images')
        .getPublicUrl(filePath)

      return data.publicUrl
    } catch (error) {
      console.error('Erro no upload da imagem:', error)
      return null
    }
  }

  // Buscar categorias
  const fetchCategories = async () => {
    try {
      const { data, error } = await supabase
        .from('categories')
        .select('*')
        .order('name')

      if (error) throw error
      setCategories(data || [])
    } catch (error) {
      console.error('Erro ao carregar categorias:', error)
      toast.error('Erro ao carregar categorias')
    }
  }

  // Criar nova categoria
  const createCategory = async (name: string): Promise<Category | null> => {
    if (!name.trim()) {
      toast.error('Nome da categoria é obrigatório')
      return null
    }

    try {
      console.log('🔄 Criando categoria:', name)
      
      // Verificar se já existe uma categoria com este nome
      const { data: existing, error: checkError } = await supabase
        .from('categories')
        .select('id, name')
        .eq('name', name.trim())
        .single()

      if (checkError && checkError.code !== 'PGRST116') {
        // PGRST116 = No rows found (que é o que queremos)
        console.error('Erro ao verificar categoria existente:', checkError)
        throw checkError
      }

      if (existing) {
        toast.error('Já existe uma categoria com este nome')
        return null
      }

      // Criar nova categoria
      const { data, error } = await supabase
        .from('categories')
        .insert([{ name: name.trim() }])
        .select()
        .single()

      if (error) {
        console.error('Erro detalhado ao criar categoria:', error)
        
        // Tratar erros específicos
        if (error.code === '23505') {
          toast.error('Já existe uma categoria com este nome')
        } else if (error.code === '42P01') {
          toast.error('Tabela de categorias não encontrada. Entre em contato com o suporte.')
        } else {
          toast.error(`Erro ao criar categoria: ${error.message}`)
        }
        
        throw error
      }
      
      console.log('✅ Categoria criada com sucesso:', data)
      toast.success('Categoria criada com sucesso!')
      
      // Recarregar categorias
      await fetchCategories()
      
      return data
    } catch (error) {
      console.error('💥 Erro geral ao criar categoria:', error)
      
      // Se chegou até aqui e não foi tratado acima
      toast.error('Erro inesperado ao criar categoria')
      
      return null
    }
  }

  // Salvar produto
  const saveProduct = async (productData: ProductFormData, id?: string): Promise<boolean> => {
    setLoading(true)
    try {
      let imageUrl = null

      // Upload da imagem se fornecida
      if (productData.imagem) {
        imageUrl = await uploadImage(productData.imagem)
        if (!imageUrl) {
          toast.error('Erro no upload da imagem')
          return false
        }
      }

      // Preparar dados para o banco
      const productToSave = {
        nome: productData.nome,
        codigo: productData.codigo,
        codigo_barras: productData.codigo_barras || null,
        categoria: productData.categoria,
        preco_venda: productData.preco_venda,
        preco_custo: productData.preco_custo || null,
        estoque: productData.estoque,
        unidade: productData.unidade,
        descricao: productData.descricao || null,
        fornecedor: productData.fornecedor || null,
        ativo: productData.ativo,
        imagem_url: imageUrl,
        atualizado_em: new Date().toISOString()
      }

      let result

      if (id) {
        // Atualizar produto existente
        result = await supabase
          .from('produtos')
          .update(productToSave)
          .eq('id', id)
      } else {
        // Criar novo produto
        result = await supabase
          .from('produtos')
          .insert([{
            ...productToSave,
            criado_em: new Date().toISOString()
          }])
      }

      if (result.error) throw result.error

      toast.success(id ? 'Produto atualizado com sucesso!' : 'Produto cadastrado com sucesso!')
      return true
    } catch (error: unknown) {
      console.error('Erro ao salvar produto:', error)
      
      const isError = error as { code?: string }
      if (isError.code === '23505') {
        toast.error('Código já existe. Use um código único.')
      } else {
        toast.error('Erro ao salvar produto')
      }
      return false
    } finally {
      setLoading(false)
    }
  }

  // Buscar produto por ID
  const getProduct = async (id: string): Promise<Product | null> => {
    try {
      const { data, error } = await supabase
        .from('produtos')
        .select('*')
        .eq('id', id)
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao buscar produto:', error)
      toast.error('Erro ao carregar produto')
      return null
    }
  }

  // Verificar se código já existe
  const checkCodeExists = async (code: string, excludeId?: string): Promise<boolean> => {
    try {
      let query = supabase
        .from('produtos')
        .select('id')
        .eq('codigo', code)

      if (excludeId) {
        query = query.neq('id', excludeId)
      }

      const { data, error } = await query

      if (error) throw error
      return data.length > 0
    } catch (error) {
      console.error('Erro ao verificar código:', error)
      return false
    }
  }

  return {
    products,
    loading,
    categories,
    loadProducts,
    deleteProduct,
    generateCode,
    fetchCategories,
    createCategory,
    saveProduct,
    getProduct,
    checkCodeExists
  }
}
