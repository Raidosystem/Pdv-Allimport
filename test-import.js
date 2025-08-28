// Teste de importação do productService
import { productService } from './services/sales'

console.log('ProductService importado:', typeof productService)
console.log('Métodos disponíveis:', Object.keys(productService))

// Teste da função search
if (productService.search) {
  console.log('✅ Função search disponível')
} else {
  console.log('❌ Função search não encontrada')
}
