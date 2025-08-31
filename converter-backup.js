// 🔄 Conversor de Backup - Service Orders
// Converte backup do formato original para o formato aceito pelo sistema

import fs from 'fs';
import path from 'path';

// Função para extrair marca do device_model
function extrairMarca(deviceModel) {
  if (!deviceModel) return 'Outros';
  
  const modelo = deviceModel.toUpperCase();
  
  // Mapeamento de marcas
  if (modelo.includes('SAMSUNG') || modelo.includes('GALAXY') || modelo.includes('A0') || modelo.includes('A1') || modelo.includes('A2') || modelo.includes('A3') || modelo.includes('A5') || modelo.includes('S2') || modelo.includes('G7')) {
    return 'SAMSUNG';
  }
  if (modelo.includes('MOTO') || modelo.includes('MOTOROLA') || modelo.includes('G2') || modelo.includes('G6') || modelo.includes('G7') || modelo.includes('G8')) {
    return 'MOTOROLA';
  }
  if (modelo.includes('IPHONE') || modelo.includes('APPLE')) {
    return 'APPLE';
  }
  if (modelo.includes('XBOX')) {
    return 'MICROSOFT';
  }
  if (modelo.includes('PS3') || modelo.includes('PS4') || modelo.includes('PS5')) {
    return 'SONY';
  }
  if (modelo.includes('LENOVO') || modelo.includes('IDEALPAD')) {
    return 'LENOVO';
  }
  if (modelo.includes('ACER')) {
    return 'ACER';
  }
  if (modelo.includes('LG')) {
    return 'LG';
  }
  if (modelo.includes('POCO')) {
    return 'XIAOMI';
  }
  
  // Se não conseguiu identificar, usar primeira palavra
  const palavras = modelo.split(' ');
  return palavras[0] || 'Outros';
}

// Função para extrair modelo do device_model
function extrairModelo(deviceModel) {
  if (!deviceModel) return 'Não informado';
  
  const modelo = deviceModel.toUpperCase();
  
  // Remover prefixos de marca comum
  return modelo
    .replace(/^SAMSUNG\s+/, '')
    .replace(/^MOTOROLA\s+/, '')
    .replace(/^MOTO\s+/, '')
    .replace(/^APPLE\s+/, '')
    .replace(/^LENOVO\s+/, '')
    .replace(/^ACER\s+/, '')
    .replace(/^SONY\s+/, '')
    .replace(/^LG\s+/, '')
    .replace(/^MICROSOFT\s+/, '')
    .trim() || deviceModel;
}

// Função para mapear status
function mapearStatus(status) {
  if (!status) return 'Em análise';
  
  const statusMap = {
    'aberta': 'Em análise',
    'fechada': 'Entregue',
    'orcamento': 'Orçamento'
  };
  
  return statusMap[status.toLowerCase()] || 'Em análise';
}

// Função para converter garantia (dias para meses)
function converterGarantia(warrantyDays) {
  if (!warrantyDays || warrantyDays === 0) return null;
  return Math.round(warrantyDays / 30); // Converter dias para meses
}

// Função principal de conversão
function converterBackup(inputFile, outputFile) {
  try {
    console.log(`📁 Lendo arquivo: ${inputFile}`);
    const data = JSON.parse(fs.readFileSync(inputFile, 'utf8'));
    
    if (!data.data || !Array.isArray(data.data)) {
      throw new Error('Formato de backup inválido. Esperado: { data: [...] }');
    }
    
    console.log(`🔄 Convertendo ${data.data.length} ordens de serviço...`);
    
    const ordensConvertidas = [];
    let contador = 1;
    
    for (const ordem of data.data) {
      // Pular ordens incompletas
      if (!ordem.device_model && !ordem.defect) {
        continue;
      }
      
      const marca = extrairMarca(ordem.device_model);
      const modelo = extrairModelo(ordem.device_model);
      
      // Só incluir se tem dados essenciais
      if (marca && modelo && ordem.defect && 
          marca !== 'Outros' && 
          modelo !== 'Não informado' && 
          ordem.defect.trim() !== '') {
        
        const ordemConvertida = {
          defeito_relatado: ordem.defect,
          cliente_nome: ordem.client_name || 'Cliente não informado',
          // ADICIONAR TELEFONE DO CLIENTE (extrair do client_name se estiver junto)
          cliente_telefone: extrairTelefoneDoNome(ordem.client_name) || '',
          marca: marca,
          modelo: modelo,
          numero_os: `OS${String(contador).padStart(3, '0')}`,
          status: mapearStatus(ordem.status),
          valor_final: ordem.total_amount || 0,
          // USAR DATAS ORIGINAIS DO BACKUP
          data_entrada: ordem.opening_date || ordem.created_at?.split('T')[0] || new Date().toISOString().split('T')[0],
          data_conclusao: ordem.closing_date || null,
          // Preservar timestamps originais
          created_at: ordem.created_at || new Date().toISOString(),
          updated_at: ordem.updated_at || ordem.created_at || new Date().toISOString(),
          garantia_meses: converterGarantia(ordem.warranty_days),
          observacoes: [
            ordem.observations || '',
            ordem.device_name || ''
          ].filter(Boolean).join(' - ')
        };
        
        ordensConvertidas.push(ordemConvertida);
        contador++;
      }
    }
    
    console.log(`✅ Conversão concluída: ${ordensConvertidas.length} ordens válidas`);
    
    // Salvar arquivo convertido
    fs.writeFileSync(outputFile, JSON.stringify(ordensConvertidas, null, 2));
    console.log(`💾 Arquivo salvo: ${outputFile}`);
    
    // Mostrar estatísticas
    const marcas = {};
    ordensConvertidas.forEach(ordem => {
      marcas[ordem.marca] = (marcas[ordem.marca] || 0) + 1;
    });
    
    console.log('\n📊 Estatísticas:');
    console.log(`Total de ordens: ${ordensConvertidas.length}`);
    console.log('Marcas encontradas:');
    Object.entries(marcas)
      .sort((a, b) => b[1] - a[1])
      .forEach(([marca, qtd]) => {
        console.log(`  ${marca}: ${qtd} ordens`);
      });
    
  } catch (error) {
    console.error('❌ Erro na conversão:', error.message);
    process.exit(1);
  }
}

// Executar conversão
const inputFile = process.argv[2] || 'backup-limpo-service_orders.json';
const outputFile = process.argv[3] || 'backup-convertido-automatico.json';

if (!fs.existsSync(inputFile)) {
  console.error(`❌ Arquivo não encontrado: ${inputFile}`);
  console.log('Uso: node converter-backup.js [arquivo-entrada] [arquivo-saida]');
  process.exit(1);
}

converterBackup(inputFile, outputFile);
