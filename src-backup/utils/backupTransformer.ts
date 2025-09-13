// 🔄 TRANSFORMADOR UNIVERSAL DE BACKUPS
// Sistema que aceita qualquer JSON e converte para o formato PDV

export interface BackupStructure {
  backup_info?: {
    user_id?: string;
    user_email?: string;
    backup_date?: string;
    backup_version?: string;
    system?: string;
  };
  data?: any;
  // Campos alternativos comuns em outros sistemas
  [key: string]: any;
}

export interface PDVBackupData {
  backup_info: {
    user_id: string;
    user_email: string;
    backup_date: string;
    backup_version: string;
    system: string;
  };
  data: {
    clientes: any[];
    categorias: any[];
    produtos: any[];
    vendas: any[];
    itens_venda: any[];
    caixa: any[];
    movimentacoes_caixa: any[];
    configuracoes: any[];
  };
}

// 🧠 MAPEAMENTOS INTELIGENTES DE CAMPOS
const FIELD_MAPPINGS = {
  // Mapeamento de produtos
  produtos: {
    name: ['name', 'nome', 'produto', 'descricao', 'description', 'title', 'titulo'],
    preco: ['preco', 'price', 'valor', 'value', 'cost', 'custo', 'amount'],
    codigo: ['codigo', 'code', 'sku', 'barcode', 'id_produto'],
    categoria: ['categoria', 'category', 'tipo', 'type', 'group', 'grupo'],
    estoque: ['estoque', 'stock', 'quantity', 'qtd', 'quantidade'],
    ativo: ['ativo', 'active', 'enabled', 'status', 'visible']
  },
  
  // Mapeamento de clientes
  clientes: {
    name: ['name', 'nome', 'cliente', 'razao_social', 'company_name'],
    email: ['email', 'e_mail', 'mail', 'correio'],
    telefone: ['telefone', 'phone', 'tel', 'celular', 'mobile'],
    cpf: ['cpf', 'cnpj', 'document', 'documento', 'tax_id'],
    endereco: ['endereco', 'address', 'rua', 'street'],
    cidade: ['cidade', 'city', 'locality'],
    cep: ['cep', 'zip', 'zipcode', 'postal_code']
  },
  
  // Mapeamento de categorias
  categorias: {
    name: ['name', 'nome', 'categoria', 'title', 'titulo', 'description', 'descricao'],
    cor: ['cor', 'color', 'background', 'theme'],
    ativo: ['ativo', 'active', 'enabled', 'status', 'visible']
  },
  
  // Mapeamento de vendas
  vendas: {
    data: ['data', 'date', 'created_at', 'timestamp', 'when'],
    total: ['total', 'amount', 'value', 'valor', 'price'],
    cliente_id: ['cliente_id', 'customer_id', 'client_id', 'user_id'],
    desconto: ['desconto', 'discount', 'off', 'reduction'],
    status: ['status', 'state', 'condition', 'situation']
  }
};

// 🔍 DETECTORES DE ESTRUTURA
export class BackupTransformer {
  
  // Detectar se é um backup válido
  static isValidBackup(data: any): boolean {
    if (!data || typeof data !== 'object') {
      console.log('❌ Backup inválido: não é um objeto');
      return false;
    }
    
    // Se tem backup_info e data, é um backup PDV válido
    if (data.backup_info && data.data) {
      console.log('✅ Backup PDV Allimport detectado');
      return true;
    }
    
    // Verificar se tem estrutura de dados (outros formatos)
    const hasData = data.produtos || data.clients || data.customers ||
                   data.products || data.items || data.vendas ||
                   data.clientes || data.categorias ||
                   Object.keys(data).some(key => Array.isArray(data[key]));
    
    if (hasData) {
      console.log('✅ Estrutura de backup detectada');
      return true;
    }
    
    console.log('❌ Nenhuma estrutura de backup válida encontrada');
    console.log('📋 Chaves disponíveis:', Object.keys(data));
    return false;
  }
  
  // Detectar tipo de sistema do backup
  static detectBackupSystem(data: any): string {
    if (data.backup_info?.system) return data.backup_info.system;
    if (data.system) return data.system;
    if (data.app || data.application) return data.app || data.application;
    
    // Detectar por estrutura
    if (data.allimport || data.ALL_IMPORT) return 'AllImport';
    if (data.pdv_data) return 'PDV Generic';
    if (data.pos_data) return 'POS System';
    if (data.vendas && data.produtos) return 'Sistema PDV';
    
    return 'Sistema Desconhecido';
  }
  
  // Encontrar arrays de dados no JSON
  static findDataArrays(data: any): { [key: string]: any[] } {
    const arrays: { [key: string]: any[] } = {};
    
    // Função recursiva para encontrar arrays
    const findArrays = (obj: any, prefix = '') => {
      for (const [key, value] of Object.entries(obj)) {
        const fullKey = prefix ? `${prefix}.${key}` : key;
        
        if (Array.isArray(value) && value.length > 0) {
          // Verificar se é array de objetos (dados válidos)
          if (typeof value[0] === 'object' && value[0] !== null) {
            arrays[fullKey] = value;
          }
        } else if (value && typeof value === 'object' && value !== null) {
          findArrays(value, fullKey);
        }
      }
    };
    
    findArrays(data);
    return arrays;
  }
  
  // Mapear campo usando inteligência
  static mapField(sourceObj: any, targetField: string, possibleFields: string[]): any {
    // Tentar encontrar o campo exato
    for (const field of possibleFields) {
      if (sourceObj.hasOwnProperty(field)) {
        return sourceObj[field];
      }
      
      // Tentar case-insensitive
      const lowerField = field.toLowerCase();
      for (const key of Object.keys(sourceObj)) {
        if (key.toLowerCase() === lowerField) {
          return sourceObj[key];
        }
      }
    }
    
    // Valor padrão baseado no tipo
    if (targetField.includes('ativo') || targetField.includes('active')) return true;
    if (targetField.includes('preco') || targetField.includes('price')) return 0;
    if (targetField.includes('estoque') || targetField.includes('stock')) return 0;
    
    return null;
  }
  
  // Transformar produtos
  static transformProdutos(sourceArray: any[]): any[] {
    return sourceArray.map((item, index) => ({
      id: item.id || `prod_${index + 1}`,
      name: this.mapField(item, 'name', FIELD_MAPPINGS.produtos.name) || `Produto ${index + 1}`,
      preco: parseFloat(this.mapField(item, 'preco', FIELD_MAPPINGS.produtos.preco)) || 0,
      codigo: this.mapField(item, 'codigo', FIELD_MAPPINGS.produtos.codigo) || `COD${index + 1}`,
      categoria: this.mapField(item, 'categoria', FIELD_MAPPINGS.produtos.categoria) || 'Geral',
      estoque: parseInt(this.mapField(item, 'estoque', FIELD_MAPPINGS.produtos.estoque)) || 0,
      ativo: this.mapField(item, 'ativo', FIELD_MAPPINGS.produtos.ativo) !== false,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }));
  }
  
  // Transformar clientes
  static transformClientes(sourceArray: any[]): any[] {
    return sourceArray.map((item, index) => ({
      id: item.id || `client_${index + 1}`,
      name: this.mapField(item, 'name', FIELD_MAPPINGS.clientes.name) || `Cliente ${index + 1}`,
      email: this.mapField(item, 'email', FIELD_MAPPINGS.clientes.email) || '',
      telefone: this.mapField(item, 'telefone', FIELD_MAPPINGS.clientes.telefone) || '',
      cpf: this.mapField(item, 'cpf', FIELD_MAPPINGS.clientes.cpf) || '',
      endereco: this.mapField(item, 'endereco', FIELD_MAPPINGS.clientes.endereco) || '',
      cidade: this.mapField(item, 'cidade', FIELD_MAPPINGS.clientes.cidade) || '',
      cep: this.mapField(item, 'cep', FIELD_MAPPINGS.clientes.cep) || '',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }));
  }
  
  // Transformar categorias
  static transformCategorias(sourceArray: any[]): any[] {
    return sourceArray.map((item, index) => ({
      id: item.id || `cat_${index + 1}`,
      name: this.mapField(item, 'name', FIELD_MAPPINGS.categorias.name) || `Categoria ${index + 1}`,
      cor: this.mapField(item, 'cor', FIELD_MAPPINGS.categorias.cor) || '#3B82F6',
      ativo: this.mapField(item, 'ativo', FIELD_MAPPINGS.categorias.ativo) !== false,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }));
  }
  
  // Transformar backup completo
  static async transformBackup(sourceData: any, userEmail: string = 'usuario@sistema.com'): Promise<PDVBackupData> {
    console.log('🔄 Iniciando transformação do backup...');
    console.log('📁 Estrutura detectada:', Object.keys(sourceData));
    
    // Encontrar todos os arrays de dados
    const dataArrays = this.findDataArrays(sourceData);
    console.log('📊 Arrays encontrados:', Object.keys(dataArrays));
    
    // Mapear dados para estrutura PDV
    const transformedData: PDVBackupData = {
      backup_info: {
        user_id: crypto.randomUUID(),
        user_email: userEmail,
        backup_date: new Date().toISOString(),
        backup_version: '2.0',
        system: `PDV Allimport (Importado de ${this.detectBackupSystem(sourceData)})`
      },
      data: {
        clientes: [],
        categorias: [],
        produtos: [],
        vendas: [],
        itens_venda: [],
        caixa: [],
        movimentacoes_caixa: [],
        configuracoes: []
      }
    };
    
    // Transformar cada tipo de dado
    for (const [arrayPath, arrayData] of Object.entries(dataArrays)) {
      const arrayName = arrayPath.toLowerCase();
      
      console.log(`🔍 Analisando array: ${arrayPath} (${arrayData.length} itens)`);
      
      // Detectar tipo de dados por nome ou estrutura
      if (this.isProductArray(arrayName, arrayData)) {
        console.log('📦 Detectado como PRODUTOS');
        transformedData.data.produtos.push(...this.transformProdutos(arrayData));
      }
      else if (this.isClientArray(arrayName, arrayData)) {
        console.log('👥 Detectado como CLIENTES');
        transformedData.data.clientes.push(...this.transformClientes(arrayData));
      }
      else if (this.isCategoryArray(arrayName, arrayData)) {
        console.log('🏷️ Detectado como CATEGORIAS');
        transformedData.data.categorias.push(...this.transformCategorias(arrayData));
      }
      else if (this.isSalesArray(arrayName, arrayData)) {
        console.log('💰 Detectado como VENDAS');
        // Transformar vendas (implementar se necessário)
      }
      else {
        console.log('❓ Tipo desconhecido, tentando detectar pela estrutura...');
        
        // Tentar detectar pela estrutura do primeiro item
        if (arrayData.length > 0) {
          const sample = arrayData[0];
          const fields = Object.keys(sample);
          
          // Se tem campos típicos de produto
          if (fields.some(f => ['name', 'nome', 'price', 'preco'].includes(f.toLowerCase()))) {
            console.log('📦 Estrutura sugere PRODUTOS');
            transformedData.data.produtos.push(...this.transformProdutos(arrayData));
          }
          // Se tem campos típicos de cliente
          else if (fields.some(f => ['email', 'telefone', 'phone'].includes(f.toLowerCase()))) {
            console.log('👥 Estrutura sugere CLIENTES');
            transformedData.data.clientes.push(...this.transformClientes(arrayData));
          }
          // Tratar como categoria
          else {
            console.log('🏷️ Tratando como CATEGORIA por padrão');
            transformedData.data.categorias.push(...this.transformCategorias(arrayData));
          }
        }
      }
    }
    
    console.log('✅ Transformação concluída:');
    console.log(`📦 ${transformedData.data.produtos.length} produtos`);
    console.log(`👥 ${transformedData.data.clientes.length} clientes`);
    console.log(`🏷️ ${transformedData.data.categorias.length} categorias`);
    
    return transformedData;
  }
  
  // Detectores de tipo de array
  static isProductArray(name: string, data: any[]): boolean {
    const productKeywords = ['product', 'produto', 'item', 'merchandise'];
    return productKeywords.some(keyword => name.includes(keyword)) ||
           (data.length > 0 && Object.keys(data[0]).some(k => 
             ['name', 'nome', 'price', 'preco', 'sku'].includes(k.toLowerCase())
           ));
  }
  
  static isClientArray(name: string, data: any[]): boolean {
    const clientKeywords = ['client', 'cliente', 'customer', 'user', 'person'];
    return clientKeywords.some(keyword => name.includes(keyword)) ||
           (data.length > 0 && Object.keys(data[0]).some(k => 
             ['email', 'telefone', 'phone', 'cpf'].includes(k.toLowerCase())
           ));
  }
  
  static isCategoryArray(name: string, _data: any[]): boolean {
    const categoryKeywords = ['category', 'categoria', 'type', 'tipo', 'group'];
    return categoryKeywords.some(keyword => name.includes(keyword));
  }
  
  static isSalesArray(name: string, _data: any[]): boolean {
    const salesKeywords = ['sale', 'venda', 'order', 'pedido', 'transaction'];
    return salesKeywords.some(keyword => name.includes(keyword));
  }
  
  // Gerar relatório de transformação
  static generateTransformReport(original: any, transformed: PDVBackupData): string {
    const originalArrays = this.findDataArrays(original);
    const totalOriginal = Object.values(originalArrays).reduce((sum, arr) => sum + arr.length, 0);
    const totalTransformed = Object.values(transformed.data).reduce((sum, arr) => sum + arr.length, 0);
    
    return `
🔄 RELATÓRIO DE TRANSFORMAÇÃO DE BACKUP

📊 DADOS ORIGINAIS:
${Object.entries(originalArrays).map(([key, arr]) => `  • ${key}: ${arr.length} itens`).join('\n')}
  
📦 TOTAL ORIGINAL: ${totalOriginal} itens

✅ DADOS TRANSFORMADOS:
  • Produtos: ${transformed.data.produtos.length}
  • Clientes: ${transformed.data.clientes.length}  
  • Categorias: ${transformed.data.categorias.length}
  • Vendas: ${transformed.data.vendas.length}
  
📦 TOTAL TRANSFORMADO: ${totalTransformed} itens

🎯 SISTEMA ORIGEM: ${transformed.backup_info.system}
📅 DATA: ${new Date(transformed.backup_info.backup_date).toLocaleString('pt-BR')}
`;
  }
}
