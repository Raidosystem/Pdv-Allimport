import fs from 'fs';

function extrairOrdensCompletas(caminhoArquivo) {
  try {
    const dados = fs.readFileSync(caminhoArquivo, 'utf8');
    const data = JSON.parse(dados);
    
    console.log('🔍 EXTRAINDO DADOS COMPLETOS DAS ORDENS DE SERVIÇO');
    console.log('================================================================================');
    
    // Acessar ordens de serviço
    const ordensServico = data.data.service_orders;
    const clientes = data.data.clients;
    
    // Criar mapa de clientes para buscar telefones
    const mapaClientes = new Map();
    if (clientes) {
      clientes.forEach(cliente => {
        mapaClientes.set(cliente.id, cliente);
      });
    }
    
    console.log(`📦 Total de ordens encontradas: ${ordensServico.length}`);
    console.log(`👥 Total de clientes encontrados: ${clientes?.length || 0}`);
    console.log('');
    
    // Extrair dados completos
    const ordensCompletas = ordensServico.map((ordem, index) => {
      const cliente = mapaClientes.get(ordem.client_id);
      
      return {
        numero: index + 1,
        id: ordem.id,
        cliente: {
          id: ordem.client_id,
          nome: ordem.client_name,
          telefone: cliente?.phone || cliente?.cell_phone || 'Não informado',
          email: cliente?.email || 'Não informado',
          endereco: cliente?.address || 'Não informado',
          bairro: cliente?.neighborhood || 'Não informado',
          cidade: cliente?.city || 'Não informado'
        },
        equipamento: {
          modelo: ordem.device_model,
          nome: ordem.device_name,
          defeito: ordem.defect
        },
        datas: {
          abertura: ordem.opening_date,
          fechamento: ordem.closing_date,
          criacao: ordem.created_at,
          atualizacao: ordem.updated_at
        },
        financeiro: {
          maoDeObra: ordem.labor_cost,
          valorTotal: ordem.total_amount,
          formaPagamento: ordem.payment_method
        },
        servico: {
          status: ordem.status,
          garantia: ordem.warranty_days,
          observacoes: ordem.observations || 'Nenhuma observação'
        }
      };
    });
    
    // Mostrar primeiros 5 registros completos
    console.log('📋 PRIMEIROS 5 REGISTROS COMPLETOS:');
    console.log('================================================================================');
    
    ordensCompletas.slice(0, 5).forEach((ordem, index) => {
      console.log(`\n🔧 ORDEM ${ordem.numero} - ${ordem.id}`);
      console.log(`📅 Data Abertura: ${ordem.datas.abertura}`);
      console.log(`📅 Data Fechamento: ${ordem.datas.fechamento || 'Em aberto'}`);
      console.log(`👤 Cliente: ${ordem.cliente.nome}`);
      console.log(`📞 Telefone: ${ordem.cliente.telefone}`);
      console.log(`📧 Email: ${ordem.cliente.email}`);
      console.log(`📍 Endereço: ${ordem.cliente.endereco}`);
      console.log(`🏘️ Bairro: ${ordem.cliente.bairro}`);
      console.log(`🏙️ Cidade: ${ordem.cliente.cidade}`);
      console.log(`📱 Equipamento: ${ordem.equipamento.modelo} - ${ordem.equipamento.nome}`);
      console.log(`❌ Defeito: ${ordem.equipamento.defeito}`);
      console.log(`💰 Valor Total: R$ ${ordem.financeiro.valorTotal}`);
      console.log(`💳 Forma Pagamento: ${ordem.financeiro.formaPagamento}`);
      console.log(`📊 Status: ${ordem.servico.status}`);
      console.log(`🛡️ Garantia: ${ordem.servico.garantia} dias`);
      console.log(`📝 Observações: ${ordem.servico.observacoes}`);
      console.log('─'.repeat(80));
    });
    
    // Salvar arquivo completo
    const nomeArquivoSaida = 'ordens-servico-completas-extraidas.json';
    fs.writeFileSync(nomeArquivoSaida, JSON.stringify(ordensCompletas, null, 2), 'utf8');
    
    console.log(`\n💾 ARQUIVO SALVO: ${nomeArquivoSaida}`);
    console.log(`📦 Total de ordens extraídas: ${ordensCompletas.length}`);
    
    // Análise estatística
    const statusCount = {};
    const formaPagamentoCount = {};
    const defeitos = new Set();
    const modelos = new Set();
    let valorTotal = 0;
    let ordensComTelefone = 0;
    
    ordensCompletas.forEach(ordem => {
      // Status
      statusCount[ordem.servico.status] = (statusCount[ordem.servico.status] || 0) + 1;
      
      // Forma de pagamento
      formaPagamentoCount[ordem.financeiro.formaPagamento] = (formaPagamentoCount[ordem.financeiro.formaPagamento] || 0) + 1;
      
      // Defeitos e modelos únicos
      defeitos.add(ordem.equipamento.defeito);
      modelos.add(ordem.equipamento.modelo);
      
      // Valor total
      valorTotal += ordem.financeiro.valorTotal;
      
      // Telefones
      if (ordem.cliente.telefone !== 'Não informado') {
        ordensComTelefone++;
      }
    });
    
    console.log('\n📊 ESTATÍSTICAS GERAIS:');
    console.log('================================================================================');
    console.log(`💰 Valor Total de Todas as Ordens: R$ ${valorTotal.toLocaleString('pt-BR', {minimumFractionDigits: 2})}`);
    console.log(`📞 Ordens com Telefone: ${ordensComTelefone}/${ordensCompletas.length} (${((ordensComTelefone/ordensCompletas.length)*100).toFixed(1)}%)`);
    console.log(`📊 Status das Ordens:`, statusCount);
    console.log(`💳 Formas de Pagamento:`, formaPagamentoCount);
    console.log(`🔧 Total de Defeitos Únicos: ${defeitos.size}`);
    console.log(`📱 Total de Modelos Únicos: ${modelos.size}`);
    
    console.log('\n📋 DEFEITOS MAIS COMUNS (Top 10):');
    const defeitosArray = Array.from(defeitos).slice(0, 10);
    defeitosArray.forEach((defeito, i) => console.log(`${i+1}. ${defeito}`));
    
    console.log('\n📱 MODELOS MAIS COMUNS (Top 10):');
    const modelosArray = Array.from(modelos).slice(0, 10);
    modelosArray.forEach((modelo, i) => console.log(`${i+1}. ${modelo}`));
    
    return ordensCompletas;
    
  } catch (error) {
    console.error('❌ Erro ao extrair ordens:', error.message);
  }
}

const caminhoArquivo = process.argv[2];
if (!caminhoArquivo) {
  console.error('❌ Por favor, forneça o caminho do arquivo de backup');
  process.exit(1);
}

extrairOrdensCompletas(caminhoArquivo);
