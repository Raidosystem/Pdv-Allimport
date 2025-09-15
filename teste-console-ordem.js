// 🧪 Teste da função criarOrdem - Execute no Console do Navegador
// Vá para http://localhost:5186 e cole este código no console

(async () => {
  try {
    console.log('🧪 TESTE: Iniciando teste de criação de ordem de serviço...');
    
    // Simular dados de uma nova ordem
    const dadosTesteOS = {
      cliente_nome: 'Teste Cliente OS',
      cliente_telefone: '11999999999',
      cliente_email: 'teste@email.com',
      tipo: 'Celular',
      marca: 'Samsung',
      modelo: 'Galaxy A10',
      cor: 'Preto',
      numero_serie: 'TEST123456',
      checklist: { aparelho_liga: false },
      observacoes: 'Teste de criação de OS via console',
      defeito_relatado: 'Aparelho não liga - teste console',
      data_previsao: null,
      valor_orcamento: 50
    };
    
    console.log('📦 TESTE: Dados preparados:', dadosTesteOS);
    
    // Tentar criar a ordem através do serviço
    // Assumindo que o ordemServicoService está disponível globalmente
    if (typeof window !== 'undefined' && window.ordemServicoService) {
      const resultado = await window.ordemServicoService.criarOrdem(dadosTesteOS);
      console.log('✅ TESTE: Ordem criada com sucesso!', resultado);
    } else {
      console.log('❌ TESTE: Serviço ordemServicoService não encontrado na janela');
      console.log('🔍 TESTE: Objetos disponíveis na janela:', Object.keys(window).filter(key => key.includes('ordem') || key.includes('Ordem')));
    }
    
  } catch (error) {
    console.error('❌ TESTE: Erro ao criar ordem:', error);
    console.log('📋 TESTE: Detalhes do erro:', {
      message: error.message,
      stack: error.stack,
      name: error.name
    });
  }
})();