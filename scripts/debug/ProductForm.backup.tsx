import { useEffect, useState } from 'react'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Save, RotateCcw, Barcode as BarcodeIcon, Hash, Package } from 'lucide-react'

import { Button } from '../ui/Button'
import { BackButton } from '../ui/BackButton'
import { Input } from '../ui/Input'
import { Card } from '../ui/Card'
import { ImageUpload } from '../ui/ImageUpload'
import { PriceInput } from '../ui/PriceInput'

// ProductForm - Formulário unificado com formatação brasileira de preços
import { CategorySelector } from './CategorySelector'

import { productSchema } from '../../schemas/productSchema'
import { useProducts } from '../../hooks/useProducts'
import { UNIDADES_MEDIDA } from '../../types/product'


interface ProductFormProps {
  productId?: string
  onSuccess?: () => void
  onCancel?: () => void
}

export function ProductForm({ productId, onSuccess, onCancel }: ProductFormProps) {
  console.log('🚀 ProductForm renderizado - productId:', productId, 'timestamp:', new Date().toISOString())
  
  const [selectedImage, setSelectedImage] = useState<File | string | null>(null)
  const [isCodeManual, setIsCodeManual] = useState(false)
  
  const {
    loading,
    categories,
    generateCode,
    fetchCategories,
    createCategory,
    saveProduct,
    getProduct,
    checkCodeExists
  } = useProducts()

  const {
    register,
    handleSubmit,
    control,
    setValue,
    reset,
    formState: { errors, isSubmitting }
  } = useForm<any>({
    resolver: zodResolver(productSchema),
    defaultValues: {
      nome: '',
      codigo: '',
      codigo_barras: '',
      categoria: '',
      preco_venda: 0,
      preco_custo: 0,
      estoque: 0,
      unidade: 'UN',
      descricao: '',
      fornecedor: '',
      ativo: true
    }
  })

  // Carregar dados iniciais
  useEffect(() => {
    fetchCategories()
    
    if (productId) {
      loadProduct()
    } else {
      generateNewCode()
    }
  }, [productId])

  const loadProduct = async () => {
    if (!productId) return
    
    const product = await getProduct(productId)
    if (product) {
      reset({
        nome: product.nome,
        codigo: product.codigo,
        codigo_barras: product.codigo_barras || '',
        categoria: product.categoria,
        preco_venda: product.preco_venda,
        preco_custo: product.preco_custo || 0,
        estoque: product.estoque,
        unidade: product.unidade,
        descricao: product.descricao || '',
        fornecedor: product.fornecedor || '',
        ativo: product.ativo
      })
      
      if (product.imagem_url) {
        setSelectedImage(product.imagem_url as string)
      }
      setIsCodeManual(true)
    }
  }

  const generateNewCode = async () => {
    if (!isCodeManual) {
      const newCode = await generateCode()
      setValue('codigo', newCode)
    }
  }

  const validateCode = async (code: string) => {
    if (!code) return true
    const exists = await checkCodeExists(code, productId)
    return !exists || 'Este código já está em uso'
  }

  // Helper para lidar com mensagens de erro do react-hook-form
  const getErrorMessage = (error: any): string | undefined => {
    return error?.message
  }



  const onSubmit = async (data: any) => {
    const formData = {
      ...data,
      imagem: selectedImage instanceof File ? selectedImage : undefined
    }

    const success = await saveProduct(formData, productId)
    if (success) {
      if (!productId) {
        // Reset form for new product
        reset()
        setSelectedImage(null)
        setIsCodeManual(false)
        await generateNewCode()
      }
      onSuccess?.()
    }
  }

  const handleReset = () => {
    reset()
    setSelectedImage(null)
    setIsCodeManual(false)
    generateNewCode()
  }

  return (
    <Card className="w-full max-w-4xl mx-auto p-6 bg-white shadow-xl">
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between border-b border-gray-200 pb-4">
          <div className="flex items-center space-x-3">
            <div className="w-12 h-12 bg-gradient-to-br from-orange-500 to-orange-600 rounded-xl flex items-center justify-center">
              <Package className="w-6 h-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900">
                {productId ? 'Editar Produto' : 'Cadastrar Produto'}
              </h2>
              <p className="text-gray-600">
                {productId ? 'Atualize as informações do produto' : 'Preencha os dados do novo produto'}
              </p>
            </div>
          </div>
          <BackButton />
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Coluna Principal */}
            <div className="lg:col-span-2 space-y-6">
              {/* Informações Básicas */}
              <div className="bg-gray-50 rounded-xl p-6 space-y-4">
                <h3 className="text-lg font-semibold text-gray-900 flex items-center">
                  <Package className="w-5 h-5 mr-2 text-orange-500" />
                  Informações Básicas
                </h3>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Nome do Produto *
                    </label>
                    <Input
                      {...register('nome')}
                      placeholder="Ex: Smartphone Samsung Galaxy"
                      error={getErrorMessage(errors.nome)}
                      className="w-full"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Código Interno *
                    </label>
                    <div className="flex space-x-2">
                      <Input
                        {...register('codigo', { validate: validateCode })}
                        placeholder="PDV123456"
                        error={getErrorMessage(errors.codigo)}
                        className="flex-1"
                        onChange={(e) => {
                          setIsCodeManual(true)
                          register('codigo').onChange(e)
                        }}
                      />
                      <Button
                        type="button"
                        variant="outline"
                        onClick={generateNewCode}
                        disabled={isSubmitting}
                        className="border-orange-300 text-orange-600 hover:bg-orange-50"
                      >
                        <Hash className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Código de Barras
                    </label>
                    <Input
                      {...register('codigo_barras')}
                      placeholder="7891234567890"
                      error={getErrorMessage(errors.codigo_barras)}
                      icon={<BarcodeIcon className="w-4 h-4" />}
                    />
                  </div>
                </div>

                <Controller
                  name="categoria"
                  control={control}
                  render={({ field }) => (
                    <CategorySelector
                      categories={categories}
                      value={field.value}
                      onChange={field.onChange}
                      onCreateCategory={createCategory}
                      error={getErrorMessage(errors.categoria)}
                      disabled={isSubmitting}
                    />
                  )}
                />

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Descrição
                  </label>
                  <textarea
                    {...register('descricao')}
                    placeholder="Descrição detalhada do produto..."
                    rows={3}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                  />
                  {errors.descricao && (
                    <p className="text-sm text-red-600 mt-1">{getErrorMessage(errors.descricao)}</p>
                  )}
                </div>
              </div>

              {/* Preços e Estoque */}
              <div className="bg-gray-50 rounded-xl p-6 space-y-4">
                <h3 className="text-lg font-semibold text-gray-900">
                  Preços e Estoque
                </h3>
                
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1 bg-red-200 p-2">
                      ⚠️ TESTE: Preço de Venda * (Formatação BR) ⚠️
                    </label>
                    <Controller
                      name="preco_venda"
                      control={control}
                      render={({ field: { onChange, value } }) => (
                        <PriceInput
                          value={value || 0}
                          onChange={onChange}
                          placeholder="0,00"
                          error={getErrorMessage(errors.preco_venda)}
                        />
                      )}
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Preço de Custo (Formatação BR)
                    </label>
                    <Controller
                      name="preco_custo"
                      control={control}
                      render={({ field: { onChange, value } }) => (
                        <PriceInput
                          value={value || 0}
                          onChange={onChange}
                          placeholder="0,00"
                          error={getErrorMessage(errors.preco_custo)}
                        />
                      )}
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Estoque Atual *
                    </label>
                    <Input
                      type="number"
                      {...register('estoque', { valueAsNumber: true })}
                      placeholder="0"
                      error={getErrorMessage(errors.estoque)}
                      className="text-right"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Unidade de Medida *
                    </label>
                    <select
                      {...register('unidade')}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                    >
                      {UNIDADES_MEDIDA.map((unidade) => (
                        <option key={unidade.value} value={unidade.value}>
                          {unidade.label} ({unidade.value})
                        </option>
                      ))}
                    </select>
                    {errors.unidade && (
                      <p className="text-sm text-red-600 mt-1">{getErrorMessage(errors.unidade)}</p>
                    )}
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Fornecedor
                    </label>
                    <Input
                      {...register('fornecedor')}
                      placeholder="Nome do fornecedor"
                      error={getErrorMessage(errors.fornecedor)}
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Coluna Lateral */}
            <div className="space-y-6">
              {/* Upload de Imagem */}
              <ImageUpload
                value={selectedImage || undefined}
                onChange={setSelectedImage}
                disabled={isSubmitting}
              />

              {/* Status */}
              <div className="bg-gray-50 rounded-xl p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">
                  Status do Produto
                </h3>
                
                <div className="flex items-center space-x-3">
                  <input
                    type="checkbox"
                    {...register('ativo')}
                    id="ativo"
                    className="w-4 h-4 text-orange-600 border-gray-300 rounded focus:ring-orange-500"
                  />
                  <label htmlFor="ativo" className="text-sm font-medium text-gray-700">
                    Produto ativo para venda
                  </label>
                </div>
              </div>
            </div>
          </div>

          {/* Botões de Ação */}
          <div className="flex justify-between items-center pt-6 border-t border-gray-200">
            <div className="flex space-x-3">
              {onCancel && (
                <Button
                  type="button"
                  variant="outline"
                  onClick={onCancel}
                  disabled={isSubmitting}
                >
                  Cancelar
                </Button>
              )}
              
              {!productId && (
                <Button
                  type="button"
                  variant="outline"
                  onClick={handleReset}
                  disabled={isSubmitting}
                  className="border-gray-300 text-gray-600 hover:bg-gray-50"
                >
                  <RotateCcw className="w-4 h-4 mr-2" />
                  Limpar
                </Button>
              )}
            </div>

            <Button
              type="submit"
              disabled={isSubmitting || loading}
              className="bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700 text-white font-semibold px-8"
            >
              <Save className="w-4 h-4 mr-2" />
              {isSubmitting ? 'Salvando...' : productId ? 'Atualizar' : 'Cadastrar'}
            </Button>
          </div>
        </form>
      </div>
    </Card>
  )
}
