import fs from 'fs';

function converterBackupEspecifico(caminhoArquivo, caminhoSaida) {
  try {
    const dados = fs.readFileSync(caminhoArquivo, 'utf8');
    const data = JSON.parse(dados);
    
    console.log('🔄 CONVERTENDO BACKUP ESPECÍFICO PARA FORMATO PDV');
    console.log('================================================================================');
    
    // Acessar ordens de serviço e clientes
    const ordensServico = data.data.service_orders;
    const clientes = data.data.clients;
    
    // Criar mapa de clientes para buscar dados completos
    const mapaClientes = new Map();
    if (clientes) {
      clientes.forEach(cliente => {
        mapaClientes.set(cliente.id, cliente);
      });
    }
    
    console.log(`📦 Ordens encontradas: ${ordensServico.length}`);
    console.log(`👥 Clientes encontrados: ${clientes?.length || 0}`);
    console.log('');
    
    // Converter para formato compatível com nosso sistema
    const ordensConvertidas = ordensServico.map((ordem, index) => {
      const cliente = mapaClientes.get(ordem.client_id);
      
      // Mapear status
      let statusConvertido = 'Em análise';
      if (ordem.status) {
        switch (ordem.status.toLowerCase()) {
          case 'fechada':
          case 'closed':
          case 'finalizada':
            statusConvertido = 'Entregue';
            break;
          case 'aberta':
          case 'open':
          case 'em_andamento':
            statusConvertido = 'Em conserto';
            break;
          case 'pronto':
          case 'ready':
            statusConvertido = 'Pronto';
            break;
          default:
            statusConvertido = 'Em análise';
        }
      }
      
      // Mapear forma de pagamento
      let formaPagamento = '';
      if (ordem.payment_method) {
        switch (ordem.payment_method.toLowerCase()) {
          case 'dinheiro':
          case 'cash':
            formaPagamento = 'Dinheiro';
            break;
          case 'pix':
            formaPagamento = 'PIX';
            break;
          case 'cartao-credito':
          case 'credit_card':
            formaPagamento = 'Cartão de Crédito';
            break;
          case 'cartao-debito':
          case 'debit_card':
            formaPagamento = 'Cartão de Débito';
            break;
          case 'orcamento':
            formaPagamento = 'Orçamento';
            break;
          case 'garantia':
            formaPagamento = 'Garantia';
            break;
          default:
            formaPagamento = ordem.payment_method;
        }
      }
      
      return {
        // Identificação
        numero_os: `OS-${ordem.id.split('-')[0]}`,
        id_original: ordem.id,
        
        // Cliente
        cliente_nome: ordem.client_name,
        cliente_telefone: cliente?.phone || cliente?.cell_phone || '',
        cliente_email: cliente?.email || '',
        cliente_endereco: cliente?.address || '',
        cliente_bairro: cliente?.neighborhood || '',
        cliente_cidade: cliente?.city || '',
        cliente_cep: cliente?.zip_code || '',
        
        // Equipamento
        marca: ordem.device_model?.split(' ')[0] || 'Não informado',
        modelo: ordem.device_model || 'Não informado',
        equipamento: `${ordem.device_model} - ${ordem.device_name}`.trim(),
        tipo: 'Celular', // Assumindo que maioria é celular baseado nos dados
        cor: ordem.device_name?.includes('AZUL') ? 'Azul' : 
             ordem.device_name?.includes('PRETO') ? 'Preto' :
             ordem.device_name?.includes('BRANCO') ? 'Branco' : '',
        
        // Defeito e observações
        defeito_relatado: ordem.defect,
        descricao_problema: ordem.defect,
        observacoes: ordem.observations || '',
        
        // Datas (preservar formato original)
        data_entrada: ordem.opening_date,
        data_finalizacao: ordem.closing_date,
        data_previsao: ordem.closing_date,
        data_entrega: ordem.closing_date,
        criado_em: ordem.created_at,
        atualizado_em: ordem.updated_at,
        
        // Valores
        valor: parseFloat(ordem.total_amount) || 0,
        valor_final: parseFloat(ordem.total_amount) || 0,
        valor_orcamento: parseFloat(ordem.total_amount) || 0,
        mao_de_obra: parseFloat(ordem.labor_cost) || 0,
        forma_pagamento: formaPagamento,
        
        // Status e garantia
        status: statusConvertido,
        garantia_meses: Math.floor((parseInt(ordem.warranty_days) || 0) / 30),
        
        // Metadados
        origem: 'backup_estabelecimento_allimport',
        data_importacao: new Date().toISOString()
      };
    });
    
    // Salvar arquivo convertido
    fs.writeFileSync(caminhoSaida, JSON.stringify(ordensConvertidas, null, 2), 'utf8');
    
    console.log(`💾 ARQUIVO CONVERTIDO SALVO: ${caminhoSaida}`);
    console.log(`📦 Total de ordens convertidas: ${ordensConvertidas.length}`);
    
    // Mostrar exemplos de conversão
    console.log('\n📋 PRIMEIROS 3 REGISTROS CONVERTIDOS:');
    console.log('================================================================================');
    
    ordensConvertidas.slice(0, 3).forEach((ordem, index) => {
      console.log(`\n🔧 ORDEM ${index + 1}:`);
      console.log(`📋 Número OS: ${ordem.numero_os}`);
      console.log(`👤 Cliente: ${ordem.cliente_nome}`);
      console.log(`📞 Telefone: ${ordem.cliente_telefone}`);
      console.log(`📱 Equipamento: ${ordem.equipamento}`);
      console.log(`❌ Defeito: ${ordem.defeito_relatado}`);
      console.log(`📅 Data Entrada: ${ordem.data_entrada}`);
      console.log(`📅 Data Finalização: ${ordem.data_finalizacao || 'Não finalizada'}`);
      console.log(`💰 Valor: R$ ${ordem.valor}`);
      console.log(`💳 Forma Pagamento: ${ordem.forma_pagamento || 'Não informado'}`);
      console.log(`📊 Status: ${ordem.status}`);
      console.log(`🛡️ Garantia: ${ordem.garantia_meses} meses`);
      console.log('─'.repeat(80));
    });
    
    // Estatísticas
    const totalValor = ordensConvertidas.reduce((sum, o) => sum + o.valor, 0);
    const statusCount = {};
    const formaPagamentoCount = {};
    
    ordensConvertidas.forEach(ordem => {
      statusCount[ordem.status] = (statusCount[ordem.status] || 0) + 1;
      formaPagamentoCount[ordem.forma_pagamento || 'Não informado'] = 
        (formaPagamentoCount[ordem.forma_pagamento || 'Não informado'] || 0) + 1;
    });
    
    console.log('\n📊 ESTATÍSTICAS DA CONVERSÃO:');
    console.log('================================================================================');
    console.log(`💰 Valor Total: R$ ${totalValor.toLocaleString('pt-BR', {minimumFractionDigits: 2})}`);
    console.log(`📊 Status:`, statusCount);
    console.log(`💳 Formas Pagamento:`, formaPagamentoCount);
    
    return ordensConvertidas;
    
  } catch (error) {
    console.error('❌ Erro na conversão:', error.message);
    return null;
  }
}

// Executar conversão
const caminhoEntrada = process.argv[2];
const caminhoSaida = process.argv[3] || 'backup-ordens-convertido-final.json';

if (!caminhoEntrada) {
  console.error('❌ Por favor, forneça o caminho do arquivo de entrada');
  console.log('Uso: node converter-backup-especifico.js <caminho-entrada> [caminho-saida]');
  process.exit(1);
}

converterBackupEspecifico(caminhoEntrada, caminhoSaida);
