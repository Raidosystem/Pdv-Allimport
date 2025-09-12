import { useState } from 'react'

export function ProductsPageSimple() {
  console.log('🚀 ProductsPageSimple carregada!')
  
  const [modalOpen, setModalOpen] = useState(false)
  
  const handleNewProduct = () => {
    console.log('🆕 Botão Novo Produto clicado!')
    setModalOpen(true)
  }
  
  const handleEdit = () => {
    console.log('✏️ Botão Editar clicado!')
    alert('Editar produto!')
  }
  
  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Produtos - Teste Simples</h1>
        <button 
          onClick={handleNewProduct}
          className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
        >
          + Novo Produto
        </button>
      </div>
      
      <div className="bg-white rounded-lg shadow p-4">
        <h2 className="text-lg font-semibold mb-4">Lista de Produtos</h2>
        
        <div className="border rounded p-4 mb-4">
          <div className="flex justify-between items-center">
            <div>
              <h3 className="font-medium">Produto Teste 1</h3>
              <p className="text-gray-600">R$ 25,00</p>
            </div>
            <button 
              onClick={handleEdit}
              className="bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600"
            >
              ✏️ Editar
            </button>
          </div>
        </div>
        
        <div className="border rounded p-4">
          <div className="flex justify-between items-center">
            <div>
              <h3 className="font-medium">Produto Teste 2</h3>
              <p className="text-gray-600">R$ 50,00</p>
            </div>
            <button 
              onClick={handleEdit}
              className="bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600"
            >
              ✏️ Editar
            </button>
          </div>
        </div>
      </div>
      
      {modalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
          <div className="bg-white p-6 rounded-lg max-w-md w-full">
            <h2 className="text-xl font-bold mb-4">Novo Produto</h2>
            <input 
              type="text" 
              placeholder="Nome do produto"
              className="w-full p-2 border rounded mb-4"
            />
            <div className="flex gap-2">
              <button 
                onClick={() => {
                  console.log('💾 Produto salvo!')
                  alert('Produto salvo com sucesso!')
                  setModalOpen(false)
                }}
                className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
              >
                Salvar
              </button>
              <button 
                onClick={() => {
                  console.log('❌ Modal cancelado')
                  setModalOpen(false)
                }}
                className="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600"
              >
                Cancelar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}