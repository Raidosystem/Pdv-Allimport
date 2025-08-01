import { Edit, Trash2, Package, AlertTriangle, XCircle } from 'lucide-react'
import { Button } from '../../../components/ui/Button'
import { Card } from '../../../components/ui/Card'
import type { Product } from '../../../types/product'
import { formatCurrency } from '../../../utils/format'

interface ProductGridProps {
  products: Product[]
  onEdit: (product: Product) => void
  onDelete: (productId: string) => void
}

export function ProductGrid({ products, onEdit, onDelete }: ProductGridProps) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      {products.map((product) => (
        <Card key={product.id} className="overflow-hidden hover:shadow-lg transition-shadow">
          {/* Imagem do Produto */}
          <div className="aspect-w-16 aspect-h-9 bg-gray-200">
            {product.imagem_url ? (
              <img
                src={product.imagem_url}
                alt={product.nome}
                className="w-full h-48 object-cover"
              />
            ) : (
              <div className="w-full h-48 bg-gradient-to-br from-gray-100 to-gray-200 flex items-center justify-center">
                <Package className="w-16 h-16 text-gray-400" />
              </div>
            )}
          </div>

          {/* Conteúdo do Card */}
          <div className="p-4">
            {/* Header com Status */}
            <div className="flex items-start justify-between mb-3">
              <div className="flex-1 min-w-0">
                <h3 className="text-lg font-semibold text-gray-900 truncate">
                  {product.nome}
                </h3>
                <p className="text-sm text-gray-600 font-mono">
                  SKU: {product.codigo}
                </p>
              </div>
              <span className={`ml-2 inline-flex px-2 py-1 text-xs font-medium rounded-full whitespace-nowrap ${
                product.ativo
                  ? 'bg-green-100 text-green-800'
                  : 'bg-red-100 text-red-800'
              }`}>
                {product.ativo ? 'Ativo' : 'Inativo'}
              </span>
            </div>

            {/* Categoria */}
            {product.categoria && (
              <div className="mb-3">
                <span className="inline-flex px-2 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-md">
                  {product.categoria}
                </span>
              </div>
            )}

            {/* Descrição */}
            {product.descricao && (
              <p className="text-sm text-gray-600 mb-3 line-clamp-2">
                {product.descricao}
              </p>
            )}

            {/* Informações de Preço e Estoque */}
            <div className="space-y-2 mb-4">
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Preço:</span>
                <span className="text-lg font-bold text-primary-600">
                  {formatCurrency(product.preco_venda)}
                </span>
              </div>
              
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Estoque:</span>
                <div className="flex items-center space-x-1">
                  <span className={`text-sm font-medium ${
                    product.estoque === 0 
                      ? 'text-red-600' 
                      : product.estoque <= 5 
                      ? 'text-orange-600' 
                      : 'text-green-600'
                  }`}>
                    {product.estoque} {product.unidade}
                  </span>
                  {product.estoque === 0 && (
                    <XCircle className="w-4 h-4 text-red-500" />
                  )}
                  {product.estoque > 0 && product.estoque <= 5 && (
                    <AlertTriangle className="w-4 h-4 text-orange-500" />
                  )}
                </div>
              </div>
            </div>

            {/* Alerta de Estoque Baixo */}
            {product.estoque === 0 && (
              <div className="mb-3 p-2 bg-red-50 border border-red-200 rounded-md">
                <div className="flex items-center space-x-2">
                  <XCircle className="w-4 h-4 text-red-500" />
                  <span className="text-xs text-red-700 font-medium">
                    Produto sem estoque
                  </span>
                </div>
              </div>
            )}
            
            {product.estoque > 0 && product.estoque <= 5 && (
              <div className="mb-3 p-2 bg-orange-50 border border-orange-200 rounded-md">
                <div className="flex items-center space-x-2">
                  <AlertTriangle className="w-4 h-4 text-orange-500" />
                  <span className="text-xs text-orange-700 font-medium">
                    Estoque baixo
                  </span>
                </div>
              </div>
            )}

            {/* Ações */}
            <div className="flex items-center space-x-2">
              <Button
                size="sm"
                variant="outline"
                onClick={() => onEdit(product)}
                className="flex-1 text-blue-600 border-blue-200 hover:bg-blue-50"
              >
                <Edit className="w-4 h-4 mr-1" />
                Editar
              </Button>
              <Button
                size="sm"
                variant="outline"
                onClick={() => product.id && onDelete(product.id)}
                className="text-red-600 border-red-200 hover:bg-red-50"
              >
                <Trash2 className="w-4 h-4" />
              </Button>
            </div>
          </div>
        </Card>
      ))}
    </div>
  )
}
