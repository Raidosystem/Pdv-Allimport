import { useState } from 'react'

export function ProductsPage() {
  console.log('🏪 [DEBUG] ProductsPage CARREGOU!')
  
  const [showProductModal, setShowProductModal] = useState(false)
  
  console.log('🏪 [DEBUG] showProductModal:', showProductModal)
  
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      <h1 style={{color: 'red', fontSize: '32px', padding: '20px'}}>
        🏪 PÁGINA PRODUTOS FUNCIONANDO!
      </h1>
      
      <div style={{padding: '20px'}}>
        <button 
          onClick={() => {
            console.log('🧪 [TESTE] Clique no botão!')
            setShowProductModal(true)
            console.log('🧪 [TESTE] Modal definido para:', true)
          }}
          style={{
            backgroundColor: 'red',
            color: 'white', 
            padding: '10px 20px',
            border: 'none',
            borderRadius: '5px',
            fontSize: '16px',
            cursor: 'pointer'
          }}
        >
          🧪 TESTE - CLIQUE AQUI
        </button>
        
        <p style={{marginTop: '10px', fontSize: '18px'}}>
          Modal aberto: {showProductModal ? 'SIM' : 'NÃO'}
        </p>
      </div>
      
      {/* Modal Simples */}
      {showProductModal && (
        <div style={{
          position: 'fixed',
          top: '0',
          left: '0',
          right: '0',
          bottom: '0',
          backgroundColor: 'rgba(0,0,0,0.5)',
          zIndex: 9999,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center'
        }}>
          <div style={{
            backgroundColor: 'white',
            padding: '20px',
            borderRadius: '10px',
            textAlign: 'center'
          }}>
            <h2>🎉 MODAL FUNCIONANDO!</h2>
            <button 
              onClick={() => setShowProductModal(false)}
              style={{
                backgroundColor: 'blue',
                color: 'white',
                padding: '5px 15px',
                border: 'none',
                borderRadius: '3px',
                marginTop: '10px'
              }}
            >
              Fechar
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
