import fs from 'fs';

// Função para extrair telefone de texto (procurar padrão de telefone)
function extrairTelefone(texto) {
  if (!texto) return '';
  
  // Procurar padrões de telefone brasileiro
  const patterns = [
    /(\(?[0-9]{2}\)?\s?[0-9]{4,5}-?[0-9]{4})/g,
    /([0-9]{10,11})/g
  ];
  
  for (const pattern of patterns) {
    const match = texto.match(pattern);
    if (match) {
      return match[0].replace(/[^\d]/g, '');
    }
  }
  return '';
}

// Função para limpar nome (remover telefone se estiver junto)
function limparNome(nomeCompleto) {
  if (!nomeCompleto) return 'Cliente não informado';
  
  // Remover telefones do nome
  return nomeCompleto
    .replace(/\(?[0-9]{2}\)?\s?[0-9]{4,5}-?[0-9]{4}/g, '')
    .replace(/[0-9]{10,11}/g, '')
    .trim()
    .replace(/\s+/g, ' ') || 'Cliente não informado';
}

// Função para extrair marca do device_model
function extrairMarca(deviceModel) {
  if (!deviceModel) return 'Não informado';
  
  const modelo = deviceModel.toUpperCase();
  
  // Lista de marcas conhecidas
  const marcas = {
    'SAMSUNG': ['SAMSUNG', 'SAM '],
    'APPLE': ['IPHONE', 'APPLE'],
    'MOTOROLA': ['MOTOROLA', 'MOTO '],
    'MICROSOFT': ['XBOX', 'MICROSOFT'],
    'SONY': ['SONY', 'PS3', 'PS4', 'PLAYSTATION'],
    'LENOVO': ['LENOVO', 'IDEAPAD', 'THINKPAD'],
    'XIAOMI': ['XIAOMI', 'REDMI', 'POCO'],
    'LG': ['LG '],
    'DELL': ['DELL'],
    'ACER': ['ACER'],
    'ASUS': ['ASUS'],
    'NINTENDO': ['NINTENDO'],
    'POSITIVO': ['POSITIVO'],
    'NOKIA': ['NOKIA']
  };
  
  for (const [marca, patterns] of Object.entries(marcas)) {
    for (const pattern of patterns) {
      if (modelo.includes(pattern)) {
        return marca;
      }
    }
  }
  
  // Se não encontrou marca conhecida, usar primeira palavra
  const palavras = modelo.split(' ');
  return palavras[0] || 'Outros';
}

// Função para extrair modelo
function extrairModelo(deviceModel) {
  if (!deviceModel) return 'Não informado';
  
  const modelo = deviceModel.toUpperCase().trim();
  
  // Remover marca do início para ficar só o modelo
  return modelo
    .replace(/^SAMSUNG\s+/, '')
    .replace(/^MOTOROLA\s+/, '')
    .replace(/^MOTO\s+/, '')
    .replace(/^APPLE\s+/, '')
    .replace(/^IPHONE\s+/, 'IPHONE ')
    .replace(/^LENOVO\s+/, '')
    .replace(/^SONY\s+/, '')
    .replace(/^MICROSOFT\s+/, '')
    .replace(/^XIAOMI\s+/, '')
    .replace(/^LG\s+/, '')
    .replace(/^DELL\s+/, '')
    .replace(/^ACER\s+/, '')
    .replace(/^ASUS\s+/, '')
    .replace(/^NINTENDO\s+/, '')
    .replace(/^POSITIVO\s+/, '')
    .replace(/^NOKIA\s+/, '')
    .trim() || deviceModel;
}

// Função para mapear status com precisão
function mapearStatus(status) {
  if (!status) return 'Em análise';
  
  const statusMap = {
    'aberta': 'Em análise',
    'fechada': 'Entregue',
    'orcamento': 'Orçamento',
    'cancelada': 'Cancelado',
    'em_andamento': 'Em conserto'
  };
  
  return statusMap[status.toLowerCase()] || 'Em análise';
}

// Função para converter garantia (dias para meses)
function converterGarantia(dias) {
  if (!dias || dias === 0) return null;
  return Math.floor(dias / 30) || 1;
}

// Função para formatar data corretamente
function formatarData(dataString) {
  if (!dataString) return new Date().toISOString().split('T')[0];
  
  // Se já está no formato YYYY-MM-DD
  if (/^\d{4}-\d{2}-\d{2}$/.test(dataString)) {
    return dataString;
  }
  
  // Se tem timestamp, extrair só a data
  if (dataString.includes('T')) {
    return dataString.split('T')[0];
  }
  
  // Fallback
  return new Date().toISOString().split('T')[0];
}

// Função para formatar timestamp completo
function formatarTimestamp(timestampString) {
  if (!timestampString) return new Date().toISOString();
  
  // Se já está no formato ISO
  if (timestampString.includes('T')) {
    return timestampString;
  }
  
  return new Date().toISOString();
}

// FUNÇÃO PRINCIPAL DE CONVERSÃO
function converterBackupCompleto(inputFile, outputFile) {
  console.log(`📁 Lendo arquivo: ${inputFile}`);
  
  if (!fs.existsSync(inputFile)) {
    console.error(`❌ Arquivo não encontrado: ${inputFile}`);
    return;
  }
  
  const conteudo = fs.readFileSync(inputFile, 'utf8');
  const data = JSON.parse(conteudo);
  
  console.log(`🔄 Convertendo ${data.data.length} ordens de serviço...`);
  
  const ordensConvertidas = [];
  let contador = 1;
  
  for (const ordem of data.data) {
    // VALIDAÇÃO RIGOROSA - só incluir ordens com dados essenciais
    if (!ordem.device_model || !ordem.defect || 
        ordem.defect.trim() === '' || 
        ordem.device_model.trim() === '') {
      continue;
    }
    
    const marca = extrairMarca(ordem.device_model);
    const modelo = extrairModelo(ordem.device_model);
    
    // Só incluir se conseguiu extrair marca e modelo válidos
    if (marca === 'Não informado' || modelo === 'Não informado') {
      continue;
    }
    
    // EXTRAIR TODOS OS DADOS MANUALMENTE
    const nomeCompleto = ordem.client_name || 'Cliente não informado';
    const telefone = extrairTelefone(nomeCompleto);
    const nomeCliente = limparNome(nomeCompleto);
    
    const ordemConvertida = {
      // DADOS ESSENCIAIS
      defeito_relatado: ordem.defect.trim(),
      cliente_nome: nomeCliente,
      cliente_telefone: telefone,
      marca: marca,
      modelo: modelo,
      
      // IDENTIFICAÇÃO
      numero_os: `OS${String(contador).padStart(4, '0')}`,
      
      // STATUS E VALORES
      status: mapearStatus(ordem.status),
      valor_final: parseFloat(ordem.total_amount) || 0,
      
      // DATAS ORIGINAIS
      data_entrada: formatarData(ordem.opening_date || ordem.created_at),
      data_conclusao: ordem.closing_date ? formatarData(ordem.closing_date) : null,
      
      // TIMESTAMPS ORIGINAIS
      created_at: formatarTimestamp(ordem.created_at),
      updated_at: formatarTimestamp(ordem.updated_at || ordem.created_at),
      
      // OUTROS DADOS
      garantia_meses: converterGarantia(ordem.warranty_days),
      metodo_pagamento: ordem.payment_method || null,
      valor_mao_obra: parseFloat(ordem.labor_cost) || 0,
      
      // OBSERVAÇÕES COMPLETAS
      observacoes: [
        ordem.observations || '',
        ordem.device_name || '',
        ordem.payment_method ? `Pagamento: ${ordem.payment_method}` : ''
      ].filter(Boolean).join(' | ')
    };
    
    ordensConvertidas.push(ordemConvertida);
    contador++;
  }
  
  console.log(`✅ Conversão concluída: ${ordensConvertidas.length} ordens válidas`);
  
  // Salvar arquivo convertido
  const resultado = {
    ordens: ordensConvertidas,
    total: ordensConvertidas.length,
    data_conversao: new Date().toISOString(),
    estatisticas: gerarEstatisticas(ordensConvertidas)
  };
  
  fs.writeFileSync(outputFile, JSON.stringify(resultado, null, 2));
  console.log(`💾 Arquivo salvo: ${outputFile}`);
  
  // Mostrar estatísticas detalhadas
  console.log('\n📊 Estatísticas detalhadas:');
  console.log(`Total de ordens: ${ordensConvertidas.length}`);
  console.log(`Ordens com telefone: ${ordensConvertidas.filter(o => o.cliente_telefone).length}`);
  console.log(`Ordens com valor: ${ordensConvertidas.filter(o => o.valor_final > 0).length}`);
  console.log(`Ordens entregues: ${ordensConvertidas.filter(o => o.status === 'Entregue').length}`);
  
  console.log('\n🏷️ Marcas encontradas:');
  const marcas = {};
  ordensConvertidas.forEach(ordem => {
    marcas[ordem.marca] = (marcas[ordem.marca] || 0) + 1;
  });
  
  Object.entries(marcas)
    .sort(([,a], [,b]) => b - a)
    .forEach(([marca, count]) => {
      console.log(`  ${marca}: ${count} ordens`);
    });
}

function gerarEstatisticas(ordens) {
  const stats = {
    total: ordens.length,
    com_telefone: ordens.filter(o => o.cliente_telefone).length,
    com_valor: ordens.filter(o => o.valor_final > 0).length,
    por_status: {},
    por_marca: {},
    valor_total: ordens.reduce((sum, o) => sum + (o.valor_final || 0), 0)
  };
  
  ordens.forEach(ordem => {
    stats.por_status[ordem.status] = (stats.por_status[ordem.status] || 0) + 1;
    stats.por_marca[ordem.marca] = (stats.por_marca[ordem.marca] || 0) + 1;
  });
  
  return stats;
}

// Executar se chamado diretamente
if (process.argv.length < 4) {
  console.log('Uso: node converter-backup-completo.js <arquivo-entrada> <arquivo-saida>');
  process.exit(1);
}

const inputFile = process.argv[2];
const outputFile = process.argv[3];

converterBackupCompleto(inputFile, outputFile);
