import { X } from 'lucide-react'
import { Button } from '../../../components/ui/Button'
import { Input } from '../../../components/ui/Input'
import type { Product } from '../../../types/product'

interface ProductFiltersProps {
  filters: {
    category: string
    status: string
    stockLevel: string
    priceRange: { min: number; max: number }
  }
  onFiltersChange: (filters: any) => void
  products: Product[]
}

export function ProductFilters({ filters, onFiltersChange, products }: ProductFiltersProps) {
  // Obter categorias únicas dos produtos
  const categories = Array.from(
    new Set(products.map(p => p.categoria).filter(Boolean))
  ).sort()

  const handleFilterChange = (key: string, value: any) => {
    onFiltersChange({
      ...filters,
      [key]: value
    })
  }

  const handlePriceRangeChange = (type: 'min' | 'max', value: string) => {
    const numValue = parseFloat(value) || 0
    onFiltersChange({
      ...filters,
      priceRange: {
        ...filters.priceRange,
        [type]: numValue
      }
    })
  }

  const clearFilters = () => {
    onFiltersChange({
      category: '',
      status: 'all',
      stockLevel: 'all',
      priceRange: { min: 0, max: 0 }
    })
  }

  const hasActiveFilters = 
    filters.category !== '' ||
    filters.status !== 'all' ||
    filters.stockLevel !== 'all' ||
    filters.priceRange.min > 0 ||
    filters.priceRange.max > 0

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h4 className="font-medium text-gray-900">Filtros</h4>
        {hasActiveFilters && (
          <Button
            variant="ghost"
            size="sm"
            onClick={clearFilters}
            className="text-gray-500 hover:text-gray-700"
          >
            <X className="w-4 h-4 mr-1" />
            Limpar filtros
          </Button>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Filtro por Categoria */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Categoria
          </label>
          <select
            value={filters.category}
            onChange={(e) => handleFilterChange('category', e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
          >
            <option value="">Todas as categorias</option>
            {categories.map((category) => (
              <option key={category} value={category}>
                {category}
              </option>
            ))}
          </select>
        </div>

        {/* Filtro por Status */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Status
          </label>
          <select
            value={filters.status}
            onChange={(e) => handleFilterChange('status', e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
          >
            <option value="all">Todos</option>
            <option value="active">Ativos</option>
            <option value="inactive">Inativos</option>
          </select>
        </div>

        {/* Filtro por Nível de Estoque */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Estoque
          </label>
          <select
            value={filters.stockLevel}
            onChange={(e) => handleFilterChange('stockLevel', e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
          >
            <option value="all">Todos</option>
            <option value="normal">Estoque normal</option>
            <option value="low">Estoque baixo</option>
            <option value="out">Sem estoque</option>
          </select>
        </div>

        {/* Filtro por Faixa de Preço */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Faixa de Preço
          </label>
          <div className="grid grid-cols-2 gap-2">
            <Input
              type="number"
              placeholder="Min"
              value={filters.priceRange.min || ''}
              onChange={(e) => handlePriceRangeChange('min', e.target.value)}
              className="text-sm"
            />
            <Input
              type="number"
              placeholder="Max"
              value={filters.priceRange.max || ''}
              onChange={(e) => handlePriceRangeChange('max', e.target.value)}
              className="text-sm"
            />
          </div>
        </div>
      </div>

      {/* Contadores de Filtros Ativos */}
      {hasActiveFilters && (
        <div className="pt-3 border-t border-gray-200">
          <div className="flex flex-wrap gap-2">
            {filters.category && (
              <span className="inline-flex items-center px-2 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-md">
                Categoria: {filters.category}
                <button
                  onClick={() => handleFilterChange('category', '')}
                  className="ml-1 text-blue-600 hover:text-blue-800"
                >
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}
            
            {filters.status !== 'all' && (
              <span className="inline-flex items-center px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded-md">
                Status: {filters.status === 'active' ? 'Ativo' : 'Inativo'}
                <button
                  onClick={() => handleFilterChange('status', 'all')}
                  className="ml-1 text-green-600 hover:text-green-800"
                >
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}
            
            {filters.stockLevel !== 'all' && (
              <span className="inline-flex items-center px-2 py-1 text-xs font-medium bg-orange-100 text-orange-800 rounded-md">
                Estoque: {
                  filters.stockLevel === 'normal' ? 'Normal' :
                  filters.stockLevel === 'low' ? 'Baixo' : 'Sem estoque'
                }
                <button
                  onClick={() => handleFilterChange('stockLevel', 'all')}
                  className="ml-1 text-orange-600 hover:text-orange-800"
                >
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}
            
            {(filters.priceRange.min > 0 || filters.priceRange.max > 0) && (
              <span className="inline-flex items-center px-2 py-1 text-xs font-medium bg-purple-100 text-purple-800 rounded-md">
                Preço: R$ {filters.priceRange.min || 0} - R$ {filters.priceRange.max || '∞'}
                <button
                  onClick={() => handleFilterChange('priceRange', { min: 0, max: 0 })}
                  className="ml-1 text-purple-600 hover:text-purple-800"
                >
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}
          </div>
        </div>
      )}
    </div>
  )
}
