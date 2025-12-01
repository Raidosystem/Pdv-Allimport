export async function createSampleData() {
  try {
    console.log('🎯 Criando dados de exemplo...')
    
    const sampleData = {
      clients: [
        {
          id: 'sample-1',
          nome: 'Cliente Teste',
          telefone: '(11) 99999-9999',
          email: 'teste@email.com',
          created_at: new Date().toISOString()
        }
      ],
      products: [
        {
          id: 'sample-prod-1',
          nome: 'Produto Teste',
          preco: 50.00,
          estoque: 10,
          categoria: 'Eletrônicos',
          created_at: new Date().toISOString()
        }
      ],
      sales: [
        {
          id: 'sample-sale-1',
          cliente_id: 'sample-1',
          total: 50.00,
          created_at: new Date().toISOString(),
          items: [
            {
              produto_id: 'sample-prod-1',
              quantidade: 1,
              preco_unitario: 50.00,
              subtotal: 50.00
            }
          ]
        }
      ],
      service_orders: [
        {
          id: 'sample-os-1',
          cliente_id: 'sample-1',
          equipamento: 'Smartphone Teste',
          defeito: 'Tela quebrada',
          status: 'Em análise',
          valor_orcamento: 100.00,
          created_at: new Date().toISOString()
        }
      ]
    }
    
    console.log('✅ Dados de exemplo criados:')
    console.log('- Clientes:', sampleData.clients.length)
    console.log('- Produtos:', sampleData.products.length)
    console.log('- Vendas:', sampleData.sales.length)
    console.log('- Ordens de Serviço:', sampleData.service_orders.length)
    
    return {
      success: true,
      data: sampleData,
      message: 'Dados de exemplo criados com sucesso'
    }
  } catch (error) {
    console.error('❌ Erro ao criar dados de exemplo:', error)
    return {
      success: false,
      error: error,
      message: 'Erro ao criar dados de exemplo'
    }
  }
}