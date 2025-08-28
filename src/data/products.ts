// Produtos embutidos no sistema - Backup garantido
export const EMBEDDED_PRODUCTS = [
  {
    id: "a2d4691b-ab4d-4aba-a1e6-a1e69f57a3b0",
    name: "WIRELESS MICROPHONE",
    sku: "WM001",
    barcode: "",
    price: 160,
    stock: 1,
    category: "Áudio",
    active: true
  },
  {
    id: "17fd37b4-b9f0-484c-aeb1-6702b8b80b5f",
    name: "MINI MICROFONE DE LAPELA",
    sku: "ML001", 
    barcode: "7898594127486",
    price: 24.99,
    stock: 4,
    category: "Áudio",
    active: true
  },
  {
    id: "1b843d2d-263a-4333-8bba-c2466a1bad27",
    name: "CARTÃO DE MEMORIA A GOLD 64GB",
    sku: "CM064",
    barcode: "7219452780313",
    price: 75,
    stock: 2,
    category: "Memória",
    active: true
  },
  {
    id: "prod001",
    name: "CARREGADOR TURBO TIPO C",
    sku: "CTC001",
    barcode: "7891234567890",
    price: 45.50,
    stock: 10,
    category: "Carregadores",
    active: true
  },
  {
    id: "prod002", 
    name: "FONE BLUETOOTH JBL",
    sku: "FBJ001",
    barcode: "7891234567891",
    price: 89.90,
    stock: 5,
    category: "Áudio",
    active: true
  },
  {
    id: "prod003",
    name: "PELÍCULA DE VIDRO TEMPERADO",
    sku: "PVT001", 
    barcode: "7891234567892",
    price: 15.00,
    stock: 25,
    category: "Proteção",
    active: true
  },
  {
    id: "prod004",
    name: "CABO USB-C 2M",
    sku: "CUC2M",
    barcode: "7891234567893", 
    price: 25.90,
    stock: 15,
    category: "Cabos",
    active: true
  },
  {
    id: "prod005",
    name: "POWER BANK 10000MAH",
    sku: "PB10K",
    barcode: "7891234567894",
    price: 65.00,
    stock: 8,
    category: "Energia",
    active: true
  },
  {
    id: "prod006",
    name: "SUPORTE VEICULAR MAGNÉTICO",
    sku: "SVM001",
    barcode: "7891234567895",
    price: 35.90,
    stock: 12,
    category: "Suportes",
    active: true
  },
  {
    id: "prod007",
    name: "CAPINHA TRANSPARENTE",
    sku: "CT001",
    barcode: "7891234567896", 
    price: 12.50,
    stock: 30,
    category: "Proteção",
    active: true
  }
];

// Função para buscar produtos
export function searchEmbeddedProducts(searchTerm?: string) {
  if (!searchTerm) {
    return EMBEDDED_PRODUCTS;
  }
  
  const search = searchTerm.toLowerCase();
  return EMBEDDED_PRODUCTS.filter(product => 
    product.name.toLowerCase().includes(search) ||
    product.sku.toLowerCase().includes(search) ||
    product.barcode.includes(search) ||
    product.category.toLowerCase().includes(search)
  );
}
