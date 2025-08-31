import fs from 'fs';

function analisarBackupNovo(caminhoArquivo) {
  try {
    const dados = fs.readFileSync(caminhoArquivo, 'utf8');
    const data = JSON.parse(dados);
    
    console.log('🔍 ESTRUTURA GERAL DO BACKUP:');
    console.log('================================================================================');
    console.log(`📊 Chaves principais:`, Object.keys(data));
    console.log(`📝 Tipo de dados:`, typeof data);
    console.log('');
    
    // Verificar o conteúdo da seção data
    if (data.data) {
      console.log('📦 SEÇÃO DATA ENCONTRADA:');
      console.log(`📊 Chaves em data:`, Object.keys(data.data));
      console.log('');
    }

    // Verificar se tem service_orders ou ordens de serviço
    if (data.service_orders || (data.data && data.data.service_orders)) {
      const ordensServico = data.service_orders || data.data.service_orders;
      console.log('📦 SEÇÃO SERVICE_ORDERS ENCONTRADA:');
      console.log(`📊 Total de ordens: ${ordensServico.length}`);
      console.log('');
      
      if (ordensServico.length > 0) {
        console.log('🔍 ESTRUTURA DA PRIMEIRA ORDEM:');
        console.log('================================================================================');
        console.log(JSON.stringify(ordensServico[0], null, 2));
        console.log('');
        
        console.log('📈 CAMPOS DISPONÍVEIS (primeiros 5 registros):');
        console.log('================================================================================');
        
        // Coletar todos os campos únicos
        const todosOsCampos = new Set();
        ordensServico.slice(0, 5).forEach(ordem => {
          Object.keys(ordem).forEach(campo => todosOsCampos.add(campo));
        });
        
        console.log('Campos encontrados:', Array.from(todosOsCampos).sort());
        console.log('');
        
        // Mostrar exemplos de dados importantes
        console.log('📋 DADOS IMPORTANTES (primeiros 3 registros):');
        console.log('================================================================================');
        
        ordensServico.slice(0, 3).forEach((ordem, index) => {
          console.log(`\n--- ORDEM ${index + 1} ---`);
          console.log(`Nome Cliente: ${ordem.client_name || ordem.customer_name || ordem.name || 'N/A'}`);
          console.log(`Telefone: ${ordem.phone || ordem.client_phone || ordem.customer_phone || 'N/A'}`);
          console.log(`Data Abertura: ${ordem.opening_date || ordem.created_at || ordem.date || 'N/A'}`);
          console.log(`Data Entrega: ${ordem.delivery_date || ordem.closing_date || 'N/A'}`);
          console.log(`Equipamento: ${ordem.equipment_model || ordem.device_model || ordem.model || 'N/A'}`);
          console.log(`Defeito: ${ordem.defect || ordem.problem || ordem.issue || 'N/A'}`);
          console.log(`Status: ${ordem.status || 'N/A'}`);
          console.log(`Valor: ${ordem.total_amount || ordem.value || ordem.price || 'N/A'}`);
        });
        
        // Análise de clientes únicos
        const clientesUnicos = new Set();
        ordensServico.forEach(ordem => {
          const nomeCliente = ordem.client_name || ordem.customer_name || ordem.name;
          if (nomeCliente) clientesUnicos.add(nomeCliente);
        });
        
        console.log('\n📊 RESUMO GERAL:');
        console.log('================================================================================');
        console.log(`📦 Total de ordens: ${ordensServico.length}`);
        console.log(`👥 Clientes únicos: ${clientesUnicos.size}`);
        
        // Verificar datas
        const datasAbertura = ordensServico
          .map(o => o.opening_date || o.created_at || o.date)
          .filter(d => d)
          .slice(0, 10);
        console.log(`📅 Datas de abertura (primeiras 10):`, datasAbertura);
        
        const datasEntrega = ordensServico
          .map(o => o.delivery_date || o.closing_date)
          .filter(d => d)
          .slice(0, 10);
        console.log(`📅 Datas de entrega (primeiras 10):`, datasEntrega);
        
        // Verificar telefones
        const telefones = ordensServico
          .map(o => o.phone || o.client_phone || o.customer_phone)
          .filter(t => t)
          .slice(0, 10);
        console.log(`📞 Telefones (primeiros 10):`, telefones);
        
      } else {
        console.log('⚠️ Nenhuma ordem de serviço encontrada');
      }
    } else {
      console.log('⚠️ Seção service_orders não encontrada');
      console.log('Estrutura disponível:', Object.keys(data));
    }
    
  } catch (error) {
    console.error('❌ Erro ao analisar backup:', error.message);
  }
}

const caminhoArquivo = process.argv[2];
if (!caminhoArquivo) {
  console.error('❌ Por favor, forneça o caminho do arquivo de backup');
  process.exit(1);
}

analisarBackupNovo(caminhoArquivo);
