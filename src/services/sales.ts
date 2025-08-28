import type { Product, Customer, Sale, CashRegister, SaleSearchParams } from '../types/sales'

// Cache para produtos carregados do backup
let ALL_PRODUCTS: Product[] = []
let PRODUCTS_LOADED = false

// Produtos mock como fallback
const MOCK_PRODUCTS: Product[] = [
  {
    id: '1',
    name: 'Smartphone Samsung Galaxy A54',
    description: 'Smartphone Android com 128GB de armazenamento',
    sku: 'SAMSUNG-A54-128',
    barcode: '7891234567890',
    price: 899.99,
    stock_quantity: 25,
    min_stock: 5,
    unit: 'un',
    active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: '2', 
    name: 'Fone Bluetooth JBL Tune 510BT',
    description: 'Fone de ouvido sem fio com cancelamento de ruído',
    sku: 'JBL-510BT',
    barcode: '7891234567891',
    price: 199.99,
    stock_quantity: 50,
    min_stock: 10,
    unit: 'un',
    active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: '3',
    name: 'Carregador USB-C 65W',
    description: 'Carregador rápido universal USB-C',
    sku: 'CARREGADOR-65W',
    barcode: '7891234567892',
    price: 89.90,
    stock_quantity: 100,
    min_stock: 20,
    unit: 'un',
    active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: '4',
    name: 'Película de Vidro iPhone 14',
    description: 'Película protetora de vidro temperado',
    sku: 'PELICULA-IP14',
    barcode: '7891234567893',
    price: 29.90,
    stock_quantity: 200,
    min_stock: 50,
    unit: 'un',
    active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: '5',
    name: 'Cabo Lightning 1m',
    description: 'Cabo de dados e carregamento Lightning original',
    sku: 'CABO-LIGHT-1M',
    barcode: '7891234567894',
    price: 49.90,
    stock_quantity: 75,
    min_stock: 15,
    unit: 'un',
    active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  }
];

// Função para carregar produtos do backup
const loadProductsFromBackup = async (): Promise<Product[]> => {
  if (PRODUCTS_LOADED) {
    return ALL_PRODUCTS;
  }
  
  try {
    console.log('📦 Carregando produtos do backup...');
    const response = await fetch('/backup-products.json');
    const backupData = await response.json();
    
    // Converter formato do backup para formato esperado
    const backupProducts = backupData.data.map((item: any) => ({
      id: item.id,
      name: item.name,
      description: item.name, // usar nome como descrição se não houver
      sku: item.barcode || `SKU-${item.id.slice(-8)}`,
      barcode: item.barcode || '',
      price: item.sale_price || 0,
      stock_quantity: item.current_stock || 0,
      min_stock: item.minimum_stock || 0,
      unit: item.unit_measure || 'un',
      active: item.active !== false,
      created_at: item.created_at || new Date().toISOString(),
      updated_at: item.updated_at || new Date().toISOString()
    }));
    
    // Combinar produtos do backup com mocks
    ALL_PRODUCTS = [...MOCK_PRODUCTS, ...backupProducts];
    PRODUCTS_LOADED = true;
    
    console.log(`✅ ${backupProducts.length} produtos carregados do backup + ${MOCK_PRODUCTS.length} mocks = ${ALL_PRODUCTS.length} total`);
    return ALL_PRODUCTS;
    
  } catch (error) {
    console.error('❌ Erro ao carregar backup:', error);
    ALL_PRODUCTS = MOCK_PRODUCTS;
    PRODUCTS_LOADED = true;
    console.log(`⚠️ Usando apenas ${MOCK_PRODUCTS.length} produtos mock`);
    return ALL_PRODUCTS;
  }
};

export const productService = {
  async search(params: SaleSearchParams): Promise<Product[]> {
    console.log('🔍 ProductService funcionando!', params);
    
    // Carregar produtos se ainda não foram carregados
    const allProducts = await loadProductsFromBackup();
    let filtered = allProducts.filter(p => p.active !== false); // Apenas produtos ativos
    
    if (params.search) {
      const searchLower = params.search.toLowerCase();
      filtered = filtered.filter(product => 
        product.name.toLowerCase().includes(searchLower) ||
        (product.sku && product.sku.toLowerCase().includes(searchLower)) ||
        (product.barcode && product.barcode.toLowerCase().includes(searchLower))
      );
    }
    
    console.log('✅ Retornando', filtered.length, 'produtos de', allProducts.length, 'total');
    return filtered;
  },

  async getById(id: string): Promise<Product | null> {
    const allProducts = await loadProductsFromBackup();
    return allProducts.find(p => p.id === id) || null;
  }
};

export const customerService = {
  async search(searchTerm?: string): Promise<Customer[]> { 
    console.log('🔍 CustomerService search:', searchTerm);
    return []; 
  },
  async create(customer: any): Promise<Customer> {
    console.log('📝 CustomerService create:', customer);
    throw new Error('Not implemented');
  }
};

export const salesService = {
  async create(saleData: any): Promise<Sale> {
    console.log('💰 SalesService create:', saleData);
    throw new Error('Not implemented');
  }
};

export const categoryService = {
  async getAll() { return []; }
};

export const cashRegisterService = {
  async getOpenRegister(): Promise<CashRegister | null> { return null; }
};
