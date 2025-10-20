import { useState, useEffect } from 'react'
import { Plus, Check, X } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import type { Category } from '../../types/product'

interface CategorySelectorProps {
  categories: Category[]
  value: string
  onChange: (value: string) => void
  onCreateCategory: (name: string) => Promise<Category | null>
  error?: string
  disabled?: boolean
}

export function CategorySelector({
  categories,
  value,
  onChange,
  onCreateCategory,
  error,
  disabled
}: CategorySelectorProps) {
  const [isCreating, setIsCreating] = useState(false)
  const [newCategoryName, setNewCategoryName] = useState('')
  const [loading, setLoading] = useState(false)

  // ✅ Debug: Log quando as categorias mudam
  useEffect(() => {
    if (categories.length > 0) {
      console.log('📂 [CategorySelector] Categorias carregadas:', {
        total: categories.length,
        ids: categories.map(c => c.id),
        primeiro_id: categories[0].id,
        nomes: categories.map(c => c.name)
      })
    }
  }, [categories])

  const handleCreateCategory = async () => {
    if (!newCategoryName.trim()) return

    setLoading(true)
    try {
      const newCategory = await onCreateCategory(newCategoryName.trim())
      if (newCategory) {
        onChange(newCategory.id)
        setNewCategoryName('')
        setIsCreating(false)
      }
    } finally {
      setLoading(false)
    }
  }

  const cancelCreate = () => {
    setIsCreating(false)
    setNewCategoryName('')
  }

  return (
    <div className="space-y-2">
      <label className="block text-sm font-medium text-gray-700">
        Categoria *
      </label>
      
      {isCreating ? (
        <div className="space-y-3">
          <Input
            value={newCategoryName}
            onChange={(e) => setNewCategoryName(e.target.value)}
            placeholder="Nome da nova categoria"
            disabled={loading}
            onKeyDown={(e) => {
              if (e.key === 'Enter') {
                e.preventDefault()
                handleCreateCategory()
              } else if (e.key === 'Escape') {
                cancelCreate()
              }
            }}
            className="w-full"
          />
          <div className="flex space-x-2">
            <Button
              type="button"
              onClick={handleCreateCategory}
              disabled={!newCategoryName.trim() || loading}
              size="sm"
              className="bg-green-600 hover:bg-green-700 text-white"
            >
              <Check className="w-4 h-4 mr-1" />
              {loading ? 'Criando...' : 'Criar'}
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={cancelCreate}
              disabled={loading}
              size="sm"
            >
              <X className="w-4 h-4 mr-1" />
              Cancelar
            </Button>
          </div>
        </div>
      ) : (
        <div className="space-y-2">
          <div className="flex space-x-2">
            <select
              value={value}
              onChange={(e) => {
                const selectedId = e.target.value
                // ✅ Validar se a categoria existe
                if (selectedId && !categories.some(cat => cat.id === selectedId)) {
                  console.warn('⚠️ [CategorySelector] Tentativa de selecionar categoria inexistente:', selectedId)
                }
                onChange(selectedId)
              }}
              disabled={disabled}
              className={`flex-1 px-3 py-2 border rounded-lg shadow-sm focus:ring-2 focus:ring-orange-500 focus:border-orange-500 ${
                error ? 'border-red-300 focus:ring-red-500 focus:border-red-500' : 'border-gray-300'
              } ${disabled ? 'bg-gray-50 cursor-not-allowed' : 'bg-white'}`}
            >
              <option value="">Selecione uma categoria</option>
              {categories.map((category) => (
                <option key={category.id} value={category.id}>
                  {category.name}
                </option>
              ))}
            </select>
            
            <Button
              type="button"
              variant="outline"
              onClick={() => setIsCreating(true)}
              disabled={disabled}
              className="border-orange-300 text-orange-600 hover:bg-orange-50 hover:border-orange-400"
            >
              <Plus className="w-4 h-4 mr-1" />
              Nova
            </Button>
          </div>
        </div>
      )}
      
      {error && (
        <p className="text-sm text-red-600">{error}</p>
      )}
    </div>
  )
}
