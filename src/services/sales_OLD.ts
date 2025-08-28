import type { Product, Customer, Sale, CashRegister, SaleSearchParams } from '../types/sales'

const MOCK_PRODUCTS: Product[] = [
  {
    id: '1',
    name: 'Smartphone Samsung Galaxy',
    description: 'Smartphone Android com 128GB',
    sku: 'SAMSUNG001',
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
    name: 'Fone Bluetooth',
    description: 'Fone sem fio',
    sku: 'FONE001',
    barcode: '7891234567891',
    price: 199.99,
    stock_quantity: 50,
    min_stock: 10,
    unit: 'un',
    active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  }
];

export const productService = {
  async search(params: SaleSearchParams): Promise<Product[]> {
    console.log('🔍 ProductService funcionando!', params);
    
    let filtered = MOCK_PRODUCTS;
    
    if (params.search) {
      const searchLower = params.search.toLowerCase();
      filtered = MOCK_PRODUCTS.filter(product => 
        product.name.toLowerCase().includes(searchLower) ||
        (product.sku && product.sku.toLowerCase().includes(searchLower))
      );
    }
    
    console.log('✅ Retornando', filtered.length, 'produtos');
    return filtered;
  },

  async getById(id: string): Promise<Product | null> {
    return MOCK_PRODUCTS.find(p => p.id === id) || null;
  }
};

export const customerService = {
  async search(): Promise<Customer[]> { return []; }
};

export const salesService = {
  async create(): Promise<Sale> { throw new Error('Not implemented'); }
};

export const categoryService = {
  async getAll() { return []; }
};

export const cashRegisterService = {
  async getOpenRegister(): Promise<CashRegister | null> { return null; }
};
