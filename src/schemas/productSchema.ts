import { z } from 'zod'

export const productSchema = z.object({
  nome: z.string()
    .min(2, 'Nome deve ter pelo menos 2 caracteres')
    .max(100, 'Nome deve ter no máximo 100 caracteres'),
  
  codigo: z.string()
    .min(1, 'Código interno é obrigatório')
    .max(50, 'Código deve ter no máximo 50 caracteres'),
  
  codigo_barras: z.string()
    .optional()
    .or(z.literal('')),
  
  categoria: z.string()
    .min(1, 'Categoria é obrigatória'),
  
  preco_venda: z.number()
    .min(0.01, 'Preço de venda deve ser maior que zero')
    .max(999999.99, 'Preço de venda muito alto'),
  
  preco_custo: z.number()
    .min(0, 'Preço de custo não pode ser negativo')
    .max(999999.99, 'Preço de custo muito alto')
    .optional(),
  
  estoque: z.number()
    .min(0, 'Estoque não pode ser negativo')
    .max(999999, 'Estoque muito alto'),
  
  unidade: z.string()
    .min(1, 'Unidade de medida é obrigatória'),
  
  descricao: z.string()
    .max(500, 'Descrição deve ter no máximo 500 caracteres')
    .optional()
    .or(z.literal('')),
  
  fornecedor: z.string()
    .max(100, 'Nome do fornecedor deve ter no máximo 100 caracteres')
    .optional()
    .or(z.literal('')),
  
  ativo: z.boolean()
})

export type ProductFormSchema = z.infer<typeof productSchema>
