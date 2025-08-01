import { Toaster } from 'react-hot-toast'
import { ProductForm } from '../components/product/ProductForm'

export function ProductPage() {
  const handleSuccess = () => {
    // Redirecionar para listagem ou outra ação
    console.log('Produto salvo com sucesso!')
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="container mx-auto px-4">
        <ProductForm onSuccess={handleSuccess} />
      </div>
      <Toaster
        position="top-right"
        toastOptions={{
          duration: 4000,
          style: {
            background: '#fff',
            color: '#374151',
            border: '1px solid #d1d5db',
            borderRadius: '0.75rem',
            fontSize: '14px',
            fontWeight: '500',
          },
          success: {
            iconTheme: {
              primary: '#059669',
              secondary: '#fff',
            },
          },
          error: {
            iconTheme: {
              primary: '#dc2626',
              secondary: '#fff',
            },
          },
        }}
      />
    </div>
  )
}
