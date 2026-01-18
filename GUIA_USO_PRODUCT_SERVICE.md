# 📘 GUIA DE USO - ProductService

## Como Usar o Novo ProductService

O `ProductService` foi criado para centralizar toda a lógica de produtos do sistema.  
Agora os **hooks** devem apenas gerenciar estado UI, enquanto o **service** faz as queries.

---

## 🎯 Importação

```typescript
import { ProductService } from '../services/productService'
```

---

## 📋 MÉTODOS DISPONÍVEIS

### 1. Carregar Todos os Produtos

```typescript
const produtos = await ProductService.loadProducts()
// Retorna: Product[]
```

### 2. Buscar Produto por ID

```typescript
const produto = await ProductService.getProductById('uuid-do-produto')
// Retorna: Product | null
```

### 3. Criar Novo Produto

```typescript
const novoProduto = await ProductService.createProduct({
  nome: 'Produto Teste',
  codigo: 'PROD001',
  categoria: 'Eletrônicos',
  preco_venda: 199.90,
  estoque: 50,
  unidade: 'UN',
  ativo: true
})
// Retorna: Product
```

### 4. Atualizar Produto

```typescript
const produtoAtualizado = await ProductService.updateProduct('uuid', {
  preco_venda: 249.90,
  estoque: 45
})
// Retorna: Product
```

### 5. Deletar Produto

```typescript
await ProductService.deleteProduct('uuid-do-produto')
// Retorna: void (lança erro se falhar)
```

### 6. Gerar Código Interno

```typescript
const codigo = await ProductService.generateCode()
// Retorna: string (ex: "PDV982345ABC")
```

### 7. Carregar Categorias

```typescript
const categorias = await ProductService.loadCategories()
// Retorna: Category[]
```

### 8. Criar Categoria

```typescript
const categoria = await ProductService.createCategory('Nova Categoria')
// Retorna: Category
```

### 9. Atualizar Estoque

```typescript
await ProductService.updateStock('uuid-do-produto', 30)
// Retorna: void
```

### 10. Buscar por Categoria

```typescript
const produtos = await ProductService.getProductsByCategory('uuid-da-categoria')
// Retorna: Product[]
```

### 11. Produtos com Estoque Baixo

```typescript
const produtosEsgotando = await ProductService.getLowStockProducts(10)
// Retorna: Product[] (produtos com estoque <= 10)
```

---

## 💡 EXEMPLO PRÁTICO - Refatorar useProducts

### ❌ ANTES (Lógica no Hook)

```typescript
export function useProducts() {
  const [products, setProducts] = useState<Product[]>([])
  const [loading, setLoading] = useState(false)

  const loadProducts = async () => {
    setLoading(true)
    try {
      const { data: { user } } = await supabase.auth.getUser()
      const { data, error } = await supabase
        .from('produtos')
        .select('*')
        .eq('user_id', user.id)
      
      if (error) throw error
      setProducts(data || [])
    } catch (error) {
      console.error(error)
    } finally {
      setLoading(false)
    }
  }

  return { products, loading, loadProducts }
}
```

### ✅ DEPOIS (Usando Service)

```typescript
import { ProductService } from '../services/productService'

export function useProducts() {
  const [products, setProducts] = useState<Product[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const loadProducts = async () => {
    setLoading(true)
    setError(null)
    try {
      const data = await ProductService.loadProducts()
      setProducts(data)
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Erro ao carregar produtos'
      setError(message)
      toast.error(message)
    } finally {
      setLoading(false)
    }
  }

  const deleteProduct = async (id: string) => {
    try {
      await ProductService.deleteProduct(id)
      setProducts(prev => prev.filter(p => p.id !== id))
      toast.success('Produto deletado!')
    } catch (err) {
      toast.error('Erro ao deletar produto')
    }
  }

  return { 
    products, 
    loading, 
    error,
    loadProducts,
    deleteProduct
  }
}
```

---

## 🔥 VANTAGENS DO NOVO PADRÃO

### 1. **Separação de Responsabilidades**
- Service = Lógica de negócio + queries
- Hook = Estado UI + reatividade

### 2. **Reutilização**
```typescript
// Pode usar em múltiplos lugares
const produtos = await ProductService.loadProducts()
```

### 3. **Testabilidade**
```typescript
// Fácil de mockar em testes
jest.mock('../services/productService')
```

### 4. **Manutenção**
- Bugs corrigidos em um lugar só
- Mudanças no banco refletidas no service
- Hooks mais simples e focados

---

## 🚨 TRATAMENTO DE ERROS

Todos os métodos lançam erros se:
- Usuário não autenticado
- Query do Supabase falhou
- Dados inválidos

**Sempre use try/catch:**

```typescript
try {
  const produto = await ProductService.createProduct(dados)
  toast.success('Produto criado!')
} catch (error) {
  if (error instanceof Error) {
    toast.error(error.message)
  } else {
    toast.error('Erro desconhecido')
  }
}
```

---

## 📝 NOTAS IMPORTANTES

1. **Autenticação Automática:** Service verifica usuário automaticamente
2. **RLS Respeitado:** Todas as queries filtram por `user_id`
3. **Timestamps:** `criado_em` e `atualizado_em` são automáticos
4. **Categorias:** Adapta `nome` → `name` automaticamente

---

## 🔄 MIGRAÇÃO GRADUAL

Não precisa refatorar tudo de uma vez!

**Estratégia recomendada:**
1. Use ProductService em **novos componentes**
2. Ao mexer em componente antigo, **refatore para usar Service**
3. Mantenha hooks antigos até ter tempo de refatorar

---

## ✅ CHECKLIST DE MIGRAÇÃO

Ao refatorar um hook para usar ProductService:

- [ ] Importar ProductService
- [ ] Substituir queries diretas por métodos do Service
- [ ] Adicionar try/catch
- [ ] Adicionar estado de error
- [ ] Testar funcionalidade
- [ ] Remover código duplicado

---

**Exemplo Completo:** Ver `src/services/productService.ts` (242 linhas)
