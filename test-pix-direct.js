// Teste direto da API PIX
async function testPixAPI() {
  console.log('🧪 Testando API PIX...')
  
  const testData = {
    userEmail: 'teste@pdvallimport.com',
    userName: 'Teste Usuario',
    amount: 59.90,
    description: 'Teste PIX - PDV Allimport'
  }
  
  try {
    console.log('📤 Enviando dados:', testData)
    
    const response = await fetch('https://pdv-allimport.vercel.app/api/pix', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(testData)
    })
    
    console.log('📡 Status da resposta:', response.status)
    console.log('📡 Headers:', [...response.headers.entries()])
    
    if (!response.ok) {
      const errorText = await response.text()
      console.error('❌ Erro HTTP:', response.status, errorText)
      return
    }
    
    const result = await response.json()
    console.log('✅ Resultado da API:', result)
    
    if (result.success) {
      console.log('🎉 PIX gerado com sucesso!')
      console.log('Payment ID:', result.payment_id)
      console.log('Status:', result.status)
      console.log('QR Code presente:', !!result.qr_code)
      console.log('QR Code Base64 presente:', !!result.qr_code_base64)
    } else {
      console.log('❌ Falha na geração do PIX:', result.error)
    }
    
  } catch (error) {
    console.error('❌ Erro na requisição:', error)
  }
}

// Testar automaticamente
testPixAPI()
