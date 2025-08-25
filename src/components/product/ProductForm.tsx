import { useState, useEffect } from 'react'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'react-hot-toast'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Card } from '../ui/Card'
import { PriceInput } from '../ui/PriceInput'
import { useProducts } from '../../hooks/useProducts'
import { CategorySelector } from './CategorySelector'

const ProductFormSchema = z.object({
  nome: z.string().min(1, 'Nome é obrigatório'),
  codigo: z.string().min(1, 'Código é obrigatório'),
  categoria: z.string().min(1, 'Categoria é obrigatória'),
  unidade: z.string().min(1, 'Unidade é obrigatória'),
  preco_venda: z.number().min(0, 'Preço de venda deve ser maior que zero'),
  preco_custo: z.number().min(0, 'Preço de custo deve ser maior ou igual a zero'),
  estoque: z.number().min(0, 'Estoque deve ser maior ou igual a zero'),
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
  const { categories, fetchCategories, createCategory, saveProduct } = useProducts()

  const {
    control,
    handleSubmit,
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
      ativo: true
    }
  })

  useEffect(() => {
    fetchCategories()
  }, [fetchCategories])

  const getErrorMessage = (error: any): string => {
    if (!error) return ''
    if (typeof error === 'string') return error
    if (error.message) return error.message
    return 'Erro de validação'
  }

  const handleSubmitForm = async (data: ProductFormData) => {
    if (loading) return

    setLoading(true)
    try {
      await saveProduct(data, productId)
      toast.success(productId ? 'Produto atualizado!' : 'Produto cadastrado!')
      
      if (onSuccess) {
        onSuccess()
      }
    } catch (error) {
      console.error('Erro ao salvar produto:', error)
      toast.error('Erro ao salvar produto')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-4xl mx-auto p-6">
      <Card className="p-6">
        <div className="mb-6">
          <h2 className="text-2xl font-bold text-gray-900">
            {productId ? 'Editar Produto' : 'Novo Produto'}
          </h2>
        </div>

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
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Categoria *
            </label>
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

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Preço de Venda *
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
                Preço de Custo
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
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Estoque
            </label>
            <Controller
              name="estoque"
              control={control}
              render={({ field: { onChange, value } }) => (
                <Input
                  type="number"
                  value={value}
                  onChange={(e) => onChange(Number(e.target.value) || 0)}
                  placeholder="0"
                  error={getErrorMessage(errors.estoque)}
                />
              )}
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
      </Card>
    </div>
  )
}

export default ProductForm
