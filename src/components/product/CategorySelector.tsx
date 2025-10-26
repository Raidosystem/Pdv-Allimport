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
  const [searchTerm, setSearchTerm] = useState('')
  const [isDropdownOpen, setIsDropdownOpen] = useState(false)

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

  // Filtrar categorias com base na busca
  const filteredCategories = categories.filter(cat =>
    cat.name.toLowerCase().includes(searchTerm.toLowerCase())
  )

  // Obter nome da categoria selecionada
  const selectedCategory = categories.find(cat => cat.id === value)
  const displayValue = selectedCategory ? selectedCategory.name : ''

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
            <div className="flex-1 relative">
              {/* Campo de busca/input */}
              <input
                type="text"
                value={isDropdownOpen ? searchTerm : displayValue}
                onChange={(e) => {
                  setSearchTerm(e.target.value)
                  setIsDropdownOpen(true)
                }}
                onFocus={() => setIsDropdownOpen(true)}
                placeholder="Digite para buscar ou selecione"
                disabled={disabled}
                className={`w-full px-3 py-2 border rounded-lg shadow-sm focus:ring-2 focus:ring-orange-500 focus:border-orange-500 ${
                  error ? 'border-red-300 focus:ring-red-500 focus:border-red-500' : 'border-gray-300'
                } ${disabled ? 'bg-gray-50 cursor-not-allowed' : 'bg-white'}`}
              />
              
              {/* Dropdown com lista de categorias */}
              {isDropdownOpen && !disabled && (
                <>
                  {/* Overlay para fechar ao clicar fora */}
                  <div
                    className="fixed inset-0 z-10"
                    onClick={() => {
                      setIsDropdownOpen(false)
                      setSearchTerm('')
                    }}
                  />
                  
                  {/* Lista de opções */}
                  <div className="absolute z-20 w-full mt-1 bg-white border border-gray-300 rounded-lg shadow-lg max-h-60 overflow-y-auto">
                    {filteredCategories.length === 0 ? (
                      <div className="px-3 py-2 text-sm text-gray-500">
                        Nenhuma categoria encontrada
                      </div>
                    ) : (
                      filteredCategories.map((category) => (
                        <button
                          key={category.id}
                          type="button"
                          onClick={() => {
                            onChange(category.id)
                            setIsDropdownOpen(false)
                            setSearchTerm('')
                          }}
                          className={`w-full text-left px-3 py-2 hover:bg-orange-50 transition-colors ${
                            value === category.id ? 'bg-orange-100 text-orange-900 font-medium' : 'text-gray-700'
                          }`}
                        >
                          {category.name}
                          {value === category.id && (
                            <Check className="w-4 h-4 inline ml-2 text-orange-600" />
                          )}
                        </button>
                      ))
                    )}
                  </div>
                </>
              )}
            </div>
            
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
