import { useState } from 'react'
import { supabase } from '../lib/supabase'
import type { Product, ProductFormData, Category } from '../types/product'
import { toast } from 'react-hot-toast'

export function useProducts() {
  const [loading, setLoading] = useState(false)
  const [products, setProducts] = useState<Product[]>([])
  const [categories, setCategories] = useState<Category[]>([])

  // Função para obter o usuário atual
  const getCurrentUser = async () => {
    const { data: { user }, error } = await supabase.auth.getUser()
    
    if (error || !user) {
      throw new Error('Usuário não autenticado')
    }
    
    return user.id
  }

  // Carregar todos os produtos
  const loadProducts = async () => {
    setLoading(true)
    try {
      // Obter o UUID do usuário atual logado
      const userId = await getCurrentUser()
      
      const { data, error } = await supabase
        .from('produtos')
        .select('*')
        .eq('user_id', userId) // USAR UUID DO USUÁRIO ATUAL
        .order('created_at', { ascending: false }) // CORRIGIDO: usar created_at ao invés de criado_em

      if (error) throw error
      
      setProducts(data || [])
    } catch (error) {
      console.error('❌ Erro ao carregar produtos:', error)
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
      const userId = await getCurrentUser()
      
      const { error } = await supabase
        .from('produtos')
        .delete()
        .eq('id', productId)
        .eq('user_id', userId) // FILTRO POR USUÁRIO ATUAL

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

  // Verificar se o bucket existe e criar se necessário
  const ensureBucketExists = async (): Promise<boolean> => {
    try {
      const { data: buckets, error } = await supabase.storage.listBuckets()
      
      if (error) {
        console.error('Erro ao listar buckets:', error)
        return false
      }

      const bucketExists = buckets?.some(bucket => bucket.id === 'product-images')
      
      if (!bucketExists) {
        console.log('Bucket product-images não existe, criando...')
        const { error: createError } = await supabase.storage.createBucket('product-images', {
          public: true,
          fileSizeLimit: 5242880 // 5MB
        })
        
        if (createError) {
          console.error('Erro ao criar bucket:', createError)
          toast.error('Erro ao configurar storage de imagens')
          return false
        }
        
        console.log('Bucket product-images criado com sucesso')
      }
      
      return true
    } catch (error) {
      console.error('Erro ao verificar bucket:', error)
      return false
    }
  }

  // Upload de imagem para Supabase Storage
  const uploadImage = async (file: File): Promise<string | null> => {
    try {
      // Verificar se o bucket existe antes de fazer upload
      const bucketReady = await ensureBucketExists()
      if (!bucketReady) {
        toast.error('Storage não configurado. Entre em contato com o administrador.')
        return null
      }

      const fileExt = file.name.split('.').pop()
      const fileName = `${Date.now()}.${fileExt}`
      const filePath = `products/${fileName}`

      console.log('Iniciando upload da imagem:', fileName)
      console.log('Tamanho do arquivo:', file.size, 'bytes')

      const { error, data } = await supabase.storage
        .from('product-images')
        .upload(filePath, file)

      if (error) {
        console.error('Erro no upload:', error)
        
        // Tentar salvar sem imagem como fallback
        if (error.message.includes('bucket') || error.message.includes('not found')) {
          toast.error('Storage de imagens não configurado. Produto será salvo sem imagem.')
          return null
        } else {
          toast.error(`Erro no upload: ${error.message}`)
        }
        
        return null
      }

      console.log('Upload realizado com sucesso:', data)

      const { data: urlData } = supabase.storage
        .from('product-images')
        .getPublicUrl(filePath)

      console.log('URL pública gerada:', urlData.publicUrl)
      toast.success('Imagem enviada com sucesso!')
      return urlData.publicUrl
    } catch (error) {
      console.error('Erro no upload da imagem:', error)
      toast.error('Erro inesperado no upload da imagem')
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
      const currentUser = await getCurrentUser()
      if (!currentUser) {
        toast.error('Usuário não autenticado')
        setLoading(false)
        return false
      }

      let imageUrl = null

      // Upload da imagem se fornecida
      if (productData.imagem) {
        console.log('Tentando fazer upload da imagem...')
        imageUrl = await uploadImage(productData.imagem)
        
        // Se falhou o upload da imagem, continua salvando o produto sem imagem
        if (!imageUrl) {
          console.log('Upload falhou, salvando produto sem imagem')
          toast.error('Produto será salvo sem imagem devido a erro no upload')
          // Continue salvando sem imagem ao invés de retornar false
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
          .eq('user_id', currentUser) // FILTRO POR USUÁRIO
      } else {
        // Criar novo produto
        result = await supabase
          .from('produtos')
          .insert([{
            ...productToSave,
            user_id: currentUser, // ASSOCIAR AO USUÁRIO
            created_at: new Date().toISOString() // CORRIGIDO: usar created_at
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
      const currentUser = await getCurrentUser()
      if (!currentUser) {
        toast.error('Usuário não autenticado')
        return null
      }

      const { data, error } = await supabase
        .from('produtos')
        .select('*')
        .eq('id', id)
        .eq('user_id', currentUser) // FILTRO POR USUÁRIO
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
      const currentUser = await getCurrentUser()
      if (!currentUser) {
        return false
      }

      let query = supabase
        .from('produtos')
        .select('id')
        .eq('codigo', code)
        .eq('user_id', currentUser) // FILTRO POR USUÁRIO

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
