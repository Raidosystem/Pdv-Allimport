import { useState } from 'react'
import { supabase } from '../lib/supabase'
import type { Product, ProductFormData, Category } from '../types/product'
import { toast } from 'react-hot-toast'

export function useProducts() {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [products, setProducts] = useState<Product[]>([])
  const [categories, setCategories] = useState<Category[]>([])

  // Carregar todos os produtos do usuário
  const loadProducts = async () => {
    setLoading(true)
    setError(null)
    try {
      // Obter user_id do usuário autenticado
      const { data: { user }, error: userError } = await supabase.auth.getUser()
      if (userError || !user) {
        const errorMsg = 'Erro ao carregar produtos: usuário não identificado'
        setError(errorMsg)
        console.error('Erro ao obter usuário:', userError)
        toast.error(errorMsg)
        setProducts([])
        setLoading(false)
        return
      }

      const { data, error } = await supabase
        .from('produtos')
        .select('*')
        .eq('user_id', user.id)
        .order('criado_em', { ascending: false })

      if (error) throw error
      setProducts(data || [])
      setError(null)
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Erro ao carregar produtos'
      setError(errorMsg)
      console.error('[useProducts] Erro ao carregar:', error)
      toast.error(errorMsg)
      setProducts([])
    } finally {
      setLoading(false)
    }
  }

  // Deletar produto (apenas do próprio usuário)
  const deleteProduct = async (productId: string) => {
    setLoading(true)
    try {
      // Obter user_id do usuário autenticado
      const { data: { user }, error: userError } = await supabase.auth.getUser()
      if (userError || !user) {
        console.error('Erro ao obter usuário:', userError)
        toast.error('Erro: usuário não identificado')
        setLoading(false)
        return
      }

      // Deletar apenas se o produto pertencer ao usuário
      const { error } = await supabase
        .from('produtos')
        .delete()
        .eq('id', productId)
        .eq('user_id', user.id)

      if (error) throw error
      
      // Atualizar lista local
      setProducts(prev => prev.filter(p => p.id !== productId))
      toast.success('Produto deletado com sucesso!')
    } catch (error) {
      console.error('Erro ao deletar produto:', error)
      toast.error('Erro ao deletar produto')
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
      // Obter empresa_id do usuário autenticado
      const { data: { user }, error: userError } = await supabase.auth.getUser()
      if (userError || !user) {
        console.error('Erro ao obter usuário:', userError)
        return
      }

      // Usar o ID do usuário como empresa_id
      const empresa_id = user.id

      const { data, error } = await supabase
        .from('categorias')
        .select('*')
        .eq('user_id', empresa_id)  // CORRIGIDO: tabela categorias usa user_id
        .order('nome')

      if (error) throw error
      
      // Adaptar dados do banco (nome → name) para o tipo Category
      const adaptedCategories = (data || []).map((cat: any) => ({
        id: cat.id,
        name: cat.nome || cat.name, // Suporta ambos os nomes
        created_at: cat.created_at
      }))
      
      setCategories(adaptedCategories)
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
      
      // Obter empresa_id do usuário autenticado
      const { data: { user }, error: userError } = await supabase.auth.getUser()
      if (userError || !user) {
        console.error('Erro ao obter usuário:', userError)
        toast.error('Erro ao criar categoria: usuário não identificado')
        return null
      }

      const empresa_id = user.id
      
      // Verificar se já existe uma categoria com este nome PARA ESTE USUÁRIO
      const { data: existing, error: checkError } = await supabase
        .from('categorias')
        .select('id, nome')
        .eq('nome', name.trim())
        .eq('user_id', empresa_id)  // CORRIGIDO: tabela categorias usa user_id
        .maybeSingle()  // ✅ CORRIGIDO: maybeSingle() não gera erro 406 quando não encontra

      if (checkError && checkError.code !== 'PGRST116') {
        // PGRST116 = No rows found (que é o que queremos)
        console.error('Erro ao verificar categoria existente:', checkError)
        throw checkError
      }

      if (existing) {
        toast.error('Já existe uma categoria com este nome')
        return null
      }

      // Criar nova categoria com user_id
      const { data, error } = await supabase
        .from('categorias')
        .insert([{ nome: name.trim(), user_id: empresa_id }])  // CORRIGIDO: usar user_id
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
      
      // Adaptar dados do banco para o tipo Category
      const adaptedCategory: Category = {
        id: data.id,
        name: data.nome || data.name,
        created_at: data.created_at
      }
      
      return adaptedCategory
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
      // Obter user_id do usuário autenticado (obrigatório para isolamento de dados)
      const { data: { user }, error: userError } = await supabase.auth.getUser()
      if (userError || !user) {
        console.error('Erro ao obter usuário:', userError)
        toast.error('Erro: usuário não identificado. Faça login novamente.')
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

      // Preparar dados para o banco (apenas campos que existem na tabela)
      const productToSave = {
        nome: productData.nome?.trim(),
        descricao: productData.descricao?.trim() || null,
        preco: Number(productData.preco_venda) || 0,  // garantir número
        categoria_id: productData.categoria_id || null,
        estoque: Number(productData.estoque) >= 0 ? Number(productData.estoque) : 0,  // garantir número não-negativo
        codigo_barras: productData.codigo_barras?.trim() || null,
        sku: productData.codigo?.trim() || null,  // usar código como SKU
        codigo_interno: productData.codigo?.trim() || null,  // salvar como codigo_interno também
        estoque_minimo: 0,  // valor padrão
        unidade: productData.unidade?.trim() || null,
        ativo: productData.ativo !== false,  // garantir boolean
        preco_custo: productData.preco_custo ? Number(productData.preco_custo) : null,
        fornecedor: productData.fornecedor?.trim() || null,
        image_url: productData.image_url || imageUrl || null,  // URL da imagem
        exibir_loja_online: productData.exibir_loja_online !== false,  // campo para loja online
        user_id: user.id
        // updated_at é gerenciado automaticamente pelo banco via trigger
      }

      // Validação básica
      if (!productToSave.nome || productToSave.nome.length === 0) {
        toast.error('Nome do produto é obrigatório')
        setLoading(false)
        return false
      }

      if (productToSave.preco < 0) {
        toast.error('Preço deve ser maior ou igual a zero')
        setLoading(false)
        return false
      }

      console.log('🔍 [saveProduct] Dados do produto a salvar:', {
        nome: productToSave.nome,
        categoria_id: productToSave.categoria_id,
        categoria_id_vazio: !productToSave.categoria_id,
        sku: productToSave.sku,
        estoque: productToSave.estoque,
        estoque_tipo: typeof productToSave.estoque,
        ativo: productToSave.ativo,
        ativo_original: productData.ativo,
        user_id: productToSave.user_id
      })

      // ✅ VALIDAÇÃO CRÍTICA: Verificar se a categoria existe no banco ANTES de tentar inserir
      if (productToSave.categoria_id) {
        console.log('🔍 [saveProduct] Validando categoria:', productToSave.categoria_id)
        
        const { data: categoryExists, error: catError } = await supabase
          .from('categorias')
          .select('id')
          .eq('id', productToSave.categoria_id)
          .limit(1)

        if (catError || !categoryExists || categoryExists.length === 0) {
          console.error('❌ [saveProduct] Categoria não encontrada ou inválida:', {
            categoria_id: productToSave.categoria_id,
            encontrado: categoryExists?.length || 0,
            error: catError
          })
          toast.error('❌ ERRO: Categoria selecionada não existe na base de dados. Por favor, selecione uma categoria válida.')
          setLoading(false)
          return false
        }
        
        console.log('✅ [saveProduct] Categoria validada com sucesso:', categoryExists[0])
      }

      let result

      if (id) {
        // Atualizar produto existente (sem updated_at pois o banco gerencia)
        result = await supabase
          .from('produtos')
          .update(productToSave)
          .eq('id', id)
          .eq('user_id', user.id)  // garantir isolamento
      } else {
        // Criar novo produto
        console.log('📤 [saveProduct] Enviando dados para inserção:', JSON.stringify(productToSave, null, 2))
        result = await supabase
          .from('produtos')
          .insert([productToSave])
          .select()  // Retornar o produto criado
      }

      console.log('📥 [saveProduct] Resposta do Supabase:', { 
        error: result.error, 
        data: result.data,
        status: result.status,
        statusText: result.statusText 
      })

      if (result.error) {
        console.error('❌ [saveProduct] Erro detalhado do Supabase:', {
          message: result.error.message,
          details: result.error.details,
          hint: result.error.hint,
          code: result.error.code
        })
        throw result.error
      }

      // Remover toast.success daqui - será controlado pelo componente que chama
      return true
    } catch (error: unknown) {
      console.error('💥 [saveProduct] Erro ao salvar produto:', error)
      
      // Log detalhado do erro
      if (error && typeof error === 'object') {
        const err = error as any
        console.error('💥 [saveProduct] Detalhes do erro:', {
          message: err.message,
          code: err.code,
          details: err.details,
          hint: err.hint,
          statusCode: err.statusCode,
          status: err.status
        })
      }
      
      const isError = error as { code?: string; message?: string }
      
      // P0001 = erro customizado do trigger (ex: código duplicado)
      if (isError.code === 'P0001') {
        // Usar a mensagem específica do trigger
        toast.error(`❌ ${isError.message || 'Código já existe no sistema'}`)
      } else if (isError.code === '23505') {
        toast.error('❌ Código já existe. Use um código único.')
      } else if (isError.code === '42P01') {
        toast.error('❌ Erro: Tabela de produtos não encontrada no banco')
      } else if (isError.code === '23502') {
        toast.error('❌ Erro: Campo obrigatório não preenchido')
      } else if (isError.code === '23503') {
        toast.error('❌ Erro: Categoria inválida ou inexistente')
      } else if (isError.message) {
        toast.error(`❌ Erro ao salvar: ${isError.message}`)
      } else {
        toast.error('❌ Erro ao salvar produto. Verifique os dados.')
      }
      return false
    } finally {
      setLoading(false)
    }
  }

  // Buscar produto por ID (apenas do usuário autenticado)
  const getProduct = async (id: string): Promise<Product | null> => {
    try {
      // Obter user_id do usuário autenticado
      const { data: { user }, error: userError } = await supabase.auth.getUser()
      if (userError || !user) {
        console.error('Erro ao obter usuário:', userError)
        toast.error('Erro: usuário não identificado')
        return null
      }

      const { data, error } = await supabase
        .from('produtos')
        .select('*')
        .eq('id', id)
        .eq('user_id', user.id)
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao buscar produto:', error)
      toast.error('Erro ao carregar produto')
      return null
    }
  }

  // Verificar se código já existe (para este usuário)
  const checkCodeExists = async (code: string, excludeId?: string): Promise<boolean> => {
    try {
      // Obter user_id do usuário autenticado
      const { data: { user }, error: userError } = await supabase.auth.getUser()
      if (userError || !user) {
        console.error('Erro ao obter usuário:', userError)
        return false
      }

      let query = supabase
        .from('produtos')
        .select('id')
        .eq('codigo', code)
        .eq('user_id', user.id)

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
    error,
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
