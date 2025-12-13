import React, { useState, useEffect, useRef } from 'react'
import { flushSync } from 'react-dom'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'react-hot-toast'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Card } from '../ui/Card'
import { useProducts } from '../../hooks/useProducts'
import { CategorySelector } from './CategorySelector'
import { supabase } from '../../lib/supabase'
import type { Fornecedor } from '../../types/fornecedor'

const ProductFormSchema = z.object({
  nome: z.string().min(1, 'Nome é obrigatório'),
  codigo: z.string().min(1, 'Código é obrigatório'),
  categoria: z.string().min(1, 'Categoria é obrigatória'),
  unidade: z.string().min(1, 'Unidade é obrigatória'),
  preco_venda: z.number().min(0, 'Preço de venda deve ser maior que zero'),
  preco_custo: z.number().min(0, 'Preço de custo deve ser maior ou igual a zero'),
  estoque: z.number().min(0, 'Estoque deve ser maior ou igual a zero'),
  fornecedor: z.string().optional(),
  ativo: z.boolean()
})

type ProductFormData = z.infer<typeof ProductFormSchema>

interface ProductFormProps {
  productId?: string
  onSuccess?: () => void
  onCancel?: () => void
}

function ProductForm({ productId, onSuccess, onCancel }: ProductFormProps) {
  const [loading, setLoading] = useState(false)
  const [fornecedores, setFornecedores] = useState<Fornecedor[]>([])
  const [formKey, setFormKey] = useState(0) // Chave para forçar remontagem
  const estoqueInputRef = useRef<HTMLInputElement>(null) // Ref para o input de estoque
  const { categories, fetchCategories, createCategory, saveProduct } = useProducts()

  // Estados para exibição formatada dos campos (apenas preços)
  const [precoVendaDisplay, setPrecoVendaDisplay] = useState('0,00')
  const [precoCustoDisplay, setPrecoCustoDisplay] = useState('0,00')

  // Estados para upload de imagem
  const [imageUrl, setImageUrl] = useState<string | null>(null)
  const [uploadingImage, setUploadingImage] = useState(false)

  const {
    control,
    handleSubmit,
    reset,
    watch,
    setValue,
    formState: { errors, isSubmitting }
  } = useForm<ProductFormData>({
    resolver: zodResolver(ProductFormSchema),
    defaultValues: {
      nome: '',
      codigo: '',
      categoria: '',
      unidade: 'UN',
      preco_venda: 0,
      preco_custo: 0,
      estoque: 0,
      fornecedor: '',
      ativo: true
    }
  })

  // Watch para sincronizar valores formatados dos preços
  const precoVenda = watch('preco_venda')
  const precoCusto = watch('preco_custo')
  const estoque = watch('estoque')

  // Sincronizar displays quando valores mudam
  useEffect(() => {
    if (precoVenda >= 0) {
      const formatted = precoVenda.toLocaleString('pt-BR', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      })
      setPrecoVendaDisplay(formatted)
    }
  }, [precoVenda])

  useEffect(() => {
    if (precoCusto >= 0) {
      const formatted = precoCusto.toLocaleString('pt-BR', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      })
      setPrecoCustoDisplay(formatted)
    }
  }, [precoCusto])

  async function loadProductData(id: string) {
    try {
      setLoading(true)
      console.log('🔍 [ProductForm] Carregando produto:', id)
      
      const { data, error } = await supabase
        .from('produtos')
        .select('*')
        .eq('id', id)
        .single()

      if (error) throw error

      if (data) {
        console.log('✅ [ProductForm] Produto carregado:', {
          nome: data.nome,
          categoria_id: data.categoria_id,
          preco: data.preco,
          preco_custo: data.preco_custo,
          estoque: data.estoque,
          sku: data.sku,
          codigo_barras: data.codigo_barras,
          codigo_interno: data.codigo_interno,
          fornecedor: data.fornecedor,
          image_url: data.image_url
        })

        // Carregar imagem se existir
        if (data.image_url) {
          setImageUrl(data.image_url)
        }

        const formData = {
          nome: data.nome || '',
          codigo: data.codigo_interno || data.sku || data.codigo_barras || '',
          categoria: data.categoria_id || '',
          unidade: data.unidade || 'UN',
          preco_venda: Number(data.preco) || 0,
          preco_custo: Number(data.preco_custo) || 0,
          estoque: Number(data.estoque) || 0,
          fornecedor: data.fornecedor || '',
          ativo: data.ativo !== false
        }

        console.log('📝 [ProductForm] Populando formulário com:', formData)
        console.log('📦 [ProductForm] Estoque a ser exibido:', formData.estoque)
        
        // Resetar o formulário com os novos valores
        reset(formData)
        
        // Forçar atualização do estoque usando flushSync
        flushSync(() => {
          setValue('estoque', formData.estoque, { shouldValidate: false, shouldDirty: false })
        })
        
        // Forçar remontagem do formulário incrementando a chave
        setFormKey(prev => prev + 1)
        
        // Forçar atualização do input diretamente via ref
        setTimeout(() => {
          if (estoqueInputRef.current) {
            estoqueInputRef.current.value = formData.estoque.toString()
            console.log('🎯 [ProductForm] Input atualizado via ref:', formData.estoque)
          }
        }, 0)
        
        console.log('✅ [ProductForm] Formulário atualizado - estoque:', formData.estoque)
        console.log('🔄 [ProductForm] Formulário remontado com nova chave')
      }
    } catch (error) {
      console.error('❌ [ProductForm] Erro ao carregar produto:', error)
      toast.error('Erro ao carregar dados do produto')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    const initializeForm = async () => {
      // Primeiro carrega categorias e fornecedores
      await Promise.all([fetchCategories(), loadFornecedores()])
      
      // Depois carrega o produto se estiver editando
      if (productId) {
        await loadProductData(productId)
      }
    }
    
    initializeForm()
    
    // Escutar evento de atualização de fornecedores
    const handleFornecedorUpdate = () => {
      loadFornecedores()
    }
    
    window.addEventListener('fornecedorUpdated', handleFornecedorUpdate)
    
    return () => {
      window.removeEventListener('fornecedorUpdated', handleFornecedorUpdate)
    }
  }, [productId])

  // Função para fazer upload da imagem
  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    // Validar tipo de arquivo
    if (!file.type.startsWith('image/')) {
      toast.error('Por favor, selecione apenas imagens')
      return
    }

    // Validar tamanho (máx 2MB)
    if (file.size > 2 * 1024 * 1024) {
      toast.error('Imagem muito grande. Máximo 2MB')
      return
    }

    try {
      setUploadingImage(true)

      // Gerar nome único para o arquivo
      const fileExt = file.name.split('.').pop()
      const fileName = `${Math.random().toString(36).substring(2)}-${Date.now()}.${fileExt}`
      const filePath = `produtos/${fileName}`

      // Fazer upload para o Supabase Storage
      const { data, error } = await supabase.storage
        .from('produtos-imagens')
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false
        })

      if (error) throw error

      // Obter URL pública
      const { data: { publicUrl } } = supabase.storage
        .from('produtos-imagens')
        .getPublicUrl(filePath)

      setImageUrl(publicUrl)
      toast.success('Imagem enviada com sucesso!')
    } catch (error: any) {
      console.error('Erro ao fazer upload:', error)
      toast.error(error.message || 'Erro ao enviar imagem')
    } finally {
      setUploadingImage(false)
    }
  }

  const removeImage = () => {
    setImageUrl(null)
    toast.success('Imagem removida')
  }

  async function loadFornecedores() {
    try {
      const { data, error } = await supabase
        .from('fornecedores')
        .select('*')
        .eq('ativo', true)
        .order('nome', { ascending: true })

      if (error) throw error
      setFornecedores(data || [])
    } catch (error) {
      console.error('Erro ao carregar fornecedores:', error)
    }
  }

  const getErrorMessage = (error: any): string => {
    if (!error) return ''
    if (typeof error === 'string') return error
    if (error.message) return error.message
    return 'Erro de validação'
  }

  const handleSubmitForm = async (data: ProductFormData) => {
    if (loading) return

    console.log('📝 [ProductForm] Dados do formulário antes de salvar:', {
      nome: data.nome,
      categoria: data.categoria,
      categoria_vazio: !data.categoria,
      sku: data.codigo,
      estoque: data.estoque,
      estoque_tipo: typeof data.estoque
    })

    console.log('📂 [ProductForm] Categorias carregadas no momento do submit:', {
      total: categories.length,
      primeira_id: categories[0]?.id,
      categoria_selecionada: data.categoria,
      existe: categories.some(c => c.id === data.categoria)
    })

    setLoading(true)
    try {
      // Converter categoria para categoria_id e adicionar image_url
      const productData = {
        ...data,
        categoria_id: data.categoria,
        image_url: imageUrl
      }
      const success = await saveProduct(productData, productId)
      
      if (success) {
        toast.success(productId ? 'Produto atualizado!' : 'Produto cadastrado!')
        
        // Dispara eventos para sincronização entre seções
        window.dispatchEvent(new CustomEvent('productAdded'))
        window.dispatchEvent(new CustomEvent('productUpdated'))
        
        // Chamar onSuccess() para fechar o modal automaticamente
        if (onSuccess) {
          onSuccess()
        }
      }
    } catch (error) {
      console.error('Erro ao salvar produto:', error)
      toast.error('Erro ao salvar produto')
    } finally {
      setLoading(false)
    }
  }

  console.log('🎨 [ProductForm] Renderizando formulário:', {
    productId,
    categories: categories.length,
    fornecedores: fornecedores.length
  })

  return (
    <form onSubmit={handleSubmit(handleSubmitForm)} className="space-y-6">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Nome do Produto *
        </label>
        <Controller
          name="nome"
          control={control}
          render={({ field: { onChange, value } }) => (
            <Input
              value={value}
              onChange={onChange}
              placeholder="Nome do produto"
              error={getErrorMessage(errors.nome)}
            />
          )}
        />
      </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Código *
          </label>
          <Controller
            name="codigo"
            control={control}
            render={({ field: { onChange, value } }) => (
              <Input
                  value={value}
                  onChange={onChange}
                  placeholder="Código interno"
                  error={getErrorMessage(errors.codigo)}
                />
              )}
            />
          </div>

          <div>
            <Controller
              name="categoria"
              control={control}
              render={({ field: { onChange, value } }) => (
                <CategorySelector
                  value={value}
                  onChange={onChange}
                  categories={categories}
                  onCreateCategory={createCategory}
                  error={getErrorMessage(errors.categoria)}
                />
              )}
            />
          </div>

          {/* Campo de Upload de Imagem */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Foto do Produto
            </label>
            <div className="space-y-3">
              {imageUrl ? (
                <div className="relative inline-block">
                  <img 
                    src={imageUrl} 
                    alt="Preview do produto" 
                    className="w-32 h-32 object-cover rounded-lg border-2 border-gray-200"
                  />
                  <button
                    type="button"
                    onClick={removeImage}
                    className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-600 transition-colors"
                    title="Remover imagem"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </div>
              ) : (
                <div className="flex items-center justify-center w-full">
                  <label className="flex flex-col items-center justify-center w-full h-32 border-2 border-gray-300 border-dashed rounded-lg cursor-pointer bg-gray-50 hover:bg-gray-100 transition-colors">
                    <div className="flex flex-col items-center justify-center pt-5 pb-6">
                      <svg className="w-8 h-8 mb-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                      </svg>
                      <p className="mb-1 text-sm text-gray-500">
                        <span className="font-semibold">Clique para enviar</span> ou arraste
                      </p>
                      <p className="text-xs text-gray-500">PNG, JPG ou WEBP (máx. 2MB)</p>
                    </div>
                    <input
                      type="file"
                      className="hidden"
                      accept="image/*"
                      onChange={handleImageUpload}
                      disabled={uploadingImage}
                    />
                  </label>
                </div>
              )}
              {uploadingImage && (
                <div className="text-sm text-blue-600 text-center">
                  Enviando imagem...
                </div>
              )}
              <p className="text-xs text-gray-500">
                💡 A imagem aparecerá no catálogo online da sua loja
              </p>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Preço de Venda *
              </label>
              <Controller
                name="preco_venda"
                control={control}
                render={({ field: { onChange, value } }) => {
                  // Formatação brasileira simples
                  const formatPrice = (inputValue: string) => {
                    const numbers = inputValue.replace(/\D/g, '')
                    if (!numbers) return ''
                    
                    const cents = parseInt(numbers)
                    const reais = cents / 100
                    
                    return reais.toLocaleString('pt-BR', {
                      minimumFractionDigits: 2,
                      maximumFractionDigits: 2
                    })
                  }

                  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
                    const input = e.target.value
                    
                    if (input === '') {
                      setPrecoVendaDisplay('')
                      onChange(0)
                      return
                    }

                    const formatted = formatPrice(input)
                    setPrecoVendaDisplay(formatted)
                    
                    if (formatted === '') {
                      onChange(0)
                    } else {
                      const numericValue = parseFloat(formatted.replace(/\./g, '').replace(',', '.')) || 0
                      onChange(numericValue)
                    }
                  }

                  const handleFocus = (e: React.FocusEvent<HTMLInputElement>) => {
                    if (precoVendaDisplay === '0,00' || value === 0) {
                      setPrecoVendaDisplay('')
                    }
                    e.target.select()
                  }

                  const handleBlur = () => {
                    if (precoVendaDisplay === '') {
                      setPrecoVendaDisplay('0,00')
                      onChange(0)
                    }
                  }

                  return (
                    <Input
                      type="text"
                      value={precoVendaDisplay}
                      onChange={handleChange}
                      onFocus={handleFocus}
                      onBlur={handleBlur}
                      placeholder="0,00"
                      error={getErrorMessage(errors.preco_venda)}
                      className="text-right"
                      inputMode="numeric"
                    />
                  )
                }}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Preço de Custo
              </label>
              <Controller
                name="preco_custo"
                control={control}
                render={({ field: { onChange, value } }) => {
                  // Formatação brasileira simples
                  const formatPrice = (inputValue: string) => {
                    const numbers = inputValue.replace(/\D/g, '')
                    if (!numbers) return ''
                    
                    const cents = parseInt(numbers)
                    const reais = cents / 100
                    
                    return reais.toLocaleString('pt-BR', {
                      minimumFractionDigits: 2,
                      maximumFractionDigits: 2
                    })
                  }

                  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
                    const input = e.target.value
                    
                    if (input === '') {
                      setPrecoCustoDisplay('')
                      onChange(0)
                      return
                    }

                    const formatted = formatPrice(input)
                    setPrecoCustoDisplay(formatted)
                    
                    if (formatted === '') {
                      onChange(0)
                    } else {
                      const numericValue = parseFloat(formatted.replace(/\./g, '').replace(',', '.')) || 0
                      onChange(numericValue)
                    }
                  }

                  const handleFocus = (e: React.FocusEvent<HTMLInputElement>) => {
                    if (precoCustoDisplay === '0,00' || value === 0) {
                      setPrecoCustoDisplay('')
                    }
                    e.target.select()
                  }

                  const handleBlur = () => {
                    if (precoCustoDisplay === '') {
                      setPrecoCustoDisplay('0,00')
                      onChange(0)
                    }
                  }

                  return (
                    <Input
                      type="text"
                      value={precoCustoDisplay}
                      onChange={handleChange}
                      onFocus={handleFocus}
                      onBlur={handleBlur}
                      placeholder="0,00"
                      error={getErrorMessage(errors.preco_custo)}
                      className="text-right"
                      inputMode="numeric"
                    />
                  )
                }}
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Estoque
            </label>
            <Controller
              key={`estoque-${formKey}`}
              name="estoque"
              control={control}
              render={({ field: { onChange, value } }) => {
                // Sempre exibir o valor atual do formulário
                const displayValue = value?.toString() || '0'
                
                console.log('📊 [ProductForm] Controller Estoque render:', { 
                  value, 
                  displayValue, 
                  formKey,
                  tipo: typeof value 
                })

                const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
                  const input = e.target.value
                  
                  if (input === '') {
                    onChange(0)
                    return
                  }

                  // Remove caracteres não numéricos
                  const numbers = input.replace(/\D/g, '')
                  if (numbers === '') {
                    onChange(0)
                    return
                  }

                  const numericValue = parseInt(numbers) || 0
                  onChange(numericValue)
                }

                const handleFocus = (e: React.FocusEvent<HTMLInputElement>) => {
                  e.target.select()
                }

                const handleBlur = () => {
                  if (!value || value === 0) {
                    onChange(0)
                  }
                }

                return (
                  <Input
                    type="text"
                    value={displayValue}
                    onChange={handleChange}
                    onFocus={handleFocus}
                    onBlur={handleBlur}
                    placeholder="0"
                    error={getErrorMessage(errors.estoque)}
                    className="text-right"
                    inputMode="numeric"
                  />
                )
              }}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Unidade *
            </label>
            <Controller
              name="unidade"
              control={control}
              render={({ field: { onChange, value } }) => (
                <select
                  value={value}
                  onChange={onChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value="UN">Unidade (UN)</option>
                  <option value="KG">Quilograma (KG)</option>
                  <option value="L">Litro (L)</option>
                  <option value="CX">Caixa (CX)</option>
                </select>
              )}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Fornecedor (opcional)
            </label>
            <Controller
              name="fornecedor"
              control={control}
              render={({ field: { onChange, value } }) => (
                <select
                  value={value || ''}
                  onChange={onChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value="">Selecione um fornecedor</option>
                  {fornecedores.map((fornecedor) => (
                    <option key={fornecedor.id} value={fornecedor.id}>
                      {fornecedor.nome}
                    </option>
                  ))}
                </select>
              )}
            />
            {fornecedores.length === 0 && (
              <p className="mt-1 text-xs text-gray-500">
                <a href="/fornecedores" target="_blank" className="text-blue-600 hover:underline">
                  Cadastre fornecedores aqui
                </a>
              </p>
            )}
          </div>

          <div>
            <Controller
              name="ativo"
              control={control}
              render={({ field: { onChange, value } }) => (
                <label className="flex items-center">
                  <input
                    type="checkbox"
                    checked={value}
                    onChange={onChange}
                    className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  />
                  <span className="ml-2 text-sm text-gray-700">Produto ativo</span>
                </label>
              )}
            />
          </div>

          <div className="flex justify-end space-x-3 pt-6 border-t">
            <Button
              type="button"
              variant="outline"
              onClick={onCancel}
              disabled={loading || isSubmitting}
            >
              Cancelar
            </Button>
            <Button
              type="submit"
              disabled={loading || isSubmitting}
              className="min-w-[120px]"
            >
              {loading || isSubmitting
                ? (productId ? 'Salvando...' : 'Cadastrando...')
                : (productId ? 'Salvar' : 'Cadastrar')
              }
            </Button>
          </div>
        </form>
  )
}

export default ProductForm
