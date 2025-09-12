import { useState } from 'react'

export function ProductsPageTest() {
  const [showModal, setShowModal] = useState(false)
  
  console.log('🔥🔥🔥 PÁGINA DE TESTE CARREGADA - BOTÕES DEVEM FUNCIONAR 🔥🔥🔥')
  
  const handleClick = () => {
    console.log('✅ Botão funcionando!')
    setShowModal(true)
  }
  
  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold text-red-600 mb-4">
        🔥 PÁGINA DE TESTE - PRODUTOS 🔥
      </h1>
      
      <div className="space-y-4">
        <button 
          onClick={handleClick}
          className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
        >
          ✅ TESTE BOTÃO NOVO PRODUTO
        </button>
        
        <button 
          onClick={() => {
            console.log('✅ Botão editar funcionando!')
            alert('Botão de editar funcionando!')
          }}
          className="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600"
        >
          ✏️ TESTE BOTÃO EDITAR
        </button>
      </div>
      
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-lg">
            <h2 className="text-xl font-bold mb-4">🎉 MODAL FUNCIONANDO!</h2>
            <p>Se você está vendo isso, os botões estão funcionando!</p>
            <button 
              onClick={() => setShowModal(false)}
              className="mt-4 px-4 py-2 bg-red-500 text-white rounded"
            >
              Fechar
            </button>
          </div>
        </div>
      )}
    </div>
  )
}