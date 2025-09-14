// 🚀 CORREÇÃO COMPLETA: Service de Vendas com Erro de Finalização
// Problema: Campos faltando na inserção + tabela vendas_itens inexistente
// Solução: Corrigir service completo para compatibilidade com banco

import { supabase } from '../lib/supabase'
import type { Product, Customer, Sale, CashRegister, SaleSearchParams, SaleItem } from '../types/sales'
import { EMBEDDED_PRODUCTS, searchEmbeddedProducts } from '../data/products'

// Serviços de Produtos (mantido igual)
export const productService = {
  async search(params: SaleSearchParams): Promise<Product[]> {
    try {
      let query = supabase
        .from('produtos')
        .select(`
          id,
          nome,
          descricao,
          sku,
          codigo_barras,
          preco,
          estoque as estoque_atual,
          estoque_minimo,
          unidade,
          ativo,
          categoria_id,
          created_at,
          updated_at
        `)
        .eq('ativo', true)
        .limit(50)

      if (params.search) {
        query = query.or(`nome.ilike.%${params.search}%, codigo_barras.ilike.%${params.search}%`)
      }

      const { data, error } = await query

      if (error) {
        console.error('Erro na busca de produtos:', error)
        // Fallback para produtos embarcados
        return searchEmbeddedProducts(params.search || '')
      }

      // Adaptar para o formato esperado
      const adaptedProducts: Product[] = data.map(item => ({
        id: item.id,
        name: item.nome,
        description: item.descricao || '',
        sku: item.sku || '',
        barcode: item.codigo_barras || '',
        price: Number(item.preco),
        cost: 0,
        stock_quantity: item.estoque_atual || 0,
        min_stock: item.estoque_minimo || 0,
        unit: item.unidade || 'un',
        active: item.ativo !== false,
        category_id: item.categoria_id,
        created_at: item.created_at,
        updated_at: item.updated_at
      }))

      return adaptedProducts.length > 0 ? adaptedProducts : searchEmbeddedProducts(params.search || '')
      
    } catch (error) {
      console.error('Erro ao buscar produtos:', error)
      return searchEmbeddedProducts(params.search || '')
    }
  },

  async getById(id: string): Promise<Product | null> {
    try {
      const { data, error } = await supabase
        .from('produtos')
        .select('*')
        .eq('id', id)
        .single()

      if (error) throw error

      const adaptedProduct: Product = {
        id: data.id,
        name: data.nome,
        description: data.descricao || '',
        sku: data.sku || '',
        barcode: data.codigo_barras || '',
        price: Number(data.preco),
        cost: Number(data.preco_custo) || 0,
        stock_quantity: data.estoque || 0,
        min_stock: data.estoque_minimo || 0,
        unit: data.unidade || 'un',
        active: data.ativo !== false,
        category_id: data.categoria_id,
        created_at: data.created_at,
        updated_at: data.updated_at
      }

      return adaptedProduct

    } catch (error) {
      console.error('Erro ao buscar produto por ID:', error)
      // Tentar nos produtos embarcados
      const embedded = EMBEDDED_PRODUCTS.find(p => p.id === id)
      return embedded || null
    }
  }
}

// Serviços de Clientes (mantido igual)
export const customerService = {
  async search(query?: string): Promise<Customer[]> {
    try {
      let supabaseQuery = supabase
        .from('clientes')
        .select('*')
        .eq('ativo', true)
        .limit(20)

      if (query) {
        supabaseQuery = supabaseQuery.or(`nome.ilike.%${query}%, telefone.ilike.%${query}%, email.ilike.%${query}%`)
      }

      const { data, error } = await supabaseQuery

      if (error) throw error

      const adaptedCustomers: Customer[] = data.map(item => ({
        id: item.id,
        name: item.nome,
        email: item.email || '',
        phone: item.telefone || '',
        document: item.cpf_cnpj || '',
        address: item.endereco || '',
        active: item.ativo !== false,
        created_at: item.criado_em,
        updated_at: item.atualizado_em
      }))

      return adaptedCustomers

    } catch (error) {
      console.error('Erro ao buscar clientes:', error)
      return []
    }
  },

  async getById(id: string): Promise<Customer | null> {
    try {
      const { data, error } = await supabase
        .from('clientes')
        .select('*')
        .eq('id', id)
        .single()
      
      if (error) throw error
      
      const adaptedCustomer: Customer = {
        id: data.id,
        name: data.nome,
        email: data.email || '',
        phone: data.telefone || '',
        document: data.documento || '',
        address: data.endereco || '',
        active: data.ativo !== false,
        created_at: data.criado_em,
        updated_at: data.atualizado_em
      }
      
      return adaptedCustomer
      
    } catch (error) {
      console.error('Erro ao buscar cliente por ID:', error)
      return null
    }
  }
}

// Tipos auxiliares para criação de venda
interface SaleItemInput {
  product_id: string;
  quantity: number;
  unit_price: number;
  total_price: number;
}

interface SaleInput {
  customer_id?: string;
  cash_register_id: string;
  user_id: string;
  total_amount: number;
  discount_amount: number;
  payment_method: 'cash' | 'card' | 'pix' | 'mixed';
  payment_details?: Record<string, string | number | boolean>;
  status: 'pending' | 'completed' | 'cancelled';
  notes?: string;
  sale_items?: SaleItemInput[];
}

// 🔧 SERVIÇO DE VENDAS CORRIGIDO
export const saleService = {
  async create(sale: SaleInput): Promise<Sale> {
    console.log('🔄 Iniciando criação de venda...', sale)
    
    try {
      // ✅ CORREÇÃO 1: Incluir TODOS os campos obrigatórios na inserção da venda
      const vendaData = {
        cliente_id: sale.customer_id || null,
        total: sale.total_amount,
        desconto: sale.discount_amount || 0,
        status: sale.status,
        metodo_pagamento: sale.payment_method,
        observacoes: sale.notes || '',
        // 🚀 CAMPOS QUE ESTAVAM FALTANDO:
        user_id: sale.user_id,
        // Se a tabela vendas tiver cash_register_id, incluir também:
        // cash_register_id: sale.cash_register_id
      }
      
      console.log('📝 Dados da venda a inserir:', vendaData)
      
      const { data, error } = await supabase
        .from('vendas')
        .insert(vendaData)
        .select()
        .single()
      
      if (error) {
        console.error('❌ Erro ao inserir venda:', error)
        throw error
      }

      console.log('✅ Venda criada com sucesso:', data)
      
      // ✅ CORREÇÃO 2: Inserir itens na tabela correta (vendas_itens)
      const saleItems: SaleItem[] = []
      if (sale.sale_items && sale.sale_items.length > 0) {
        console.log(`📦 Inserindo ${sale.sale_items.length} itens da venda...`)
        
        for (const item of sale.sale_items) {
          const itemData = {
            venda_id: data.id,
            produto_id: item.product_id,
            quantidade: item.quantity,
            preco_unitario: item.unit_price,
            subtotal: item.total_price,
            // user_id será setado automaticamente pelo trigger
          }
          
          console.log('📝 Inserindo item:', itemData)
          
          const { data: itemResult, error: itemError } = await supabase
            .from('vendas_itens')  // ✅ Tabela corrigida
            .insert(itemData)
            .select()
            .single()
            
          if (itemError) {
            console.error('❌ Erro ao inserir item da venda:', itemError)
            throw itemError
          }
          
          console.log('✅ Item inserido:', itemResult)
          
          saleItems.push({
            id: itemResult.id,
            sale_id: itemResult.venda_id,
            product_id: itemResult.produto_id,
            quantity: itemResult.quantidade,
            unit_price: itemResult.preco_unitario,
            total_price: itemResult.subtotal,
            created_at: itemResult.created_at
          })
        }
      }
      
      // ✅ CORREÇÃO 3: Retornar dados adaptados corretamente
      const adaptedSale: Sale = {
        id: data.id,
        customer_id: data.cliente_id,
        cash_register_id: sale.cash_register_id, // Usar o que foi enviado
        user_id: data.user_id || sale.user_id,
        total_amount: data.total,
        discount_amount: data.desconto || 0,
        status: data.status,
        payment_method: data.metodo_pagamento,
        notes: data.observacoes || '',
        sale_items: saleItems,
        created_at: data.created_at,
        updated_at: data.updated_at
      }
      
      console.log('🎉 Venda completa criada:', adaptedSale)
      return adaptedSale
      
    } catch (error) {
      console.error('💥 Erro completo ao criar venda:', error)
      
      // Log mais detalhado para debug
      if (error instanceof Error) {
        console.error('📋 Mensagem do erro:', error.message)
        console.error('📊 Stack do erro:', error.stack)
      }
      
      throw error
    }
  }
}

// Serviços de Caixa (mantido igual)
export const cashRegisterService = {
  async getCurrent(): Promise<CashRegister | null> {
    try {
      const { data, error } = await supabase
        .from('caixa')
        .select('*')
        .eq('status', 'aberto')
        .single()
      
      if (error) {
        if (error.code === 'PGRST116') {
          // Nenhum caixa aberto encontrado
          return null
        }
        throw error
      }
      
      const adaptedCashRegister: CashRegister = {
        id: data.id,
        opened_by: data.user_id,
        opening_amount: data.saldo_inicial,
        current_amount: data.saldo_inicial, // Pode ser calculado depois
        status: data.status as 'aberto' | 'fechado',
        opened_at: data.data_abertura,
        closed_at: data.data_fechamento,
        notes: data.observacoes || ''
      }
      
      return adaptedCashRegister
      
    } catch (error) {
      console.error('Erro ao buscar caixa atual:', error)
      return null
    }
  },

  async open(openingAmount: number): Promise<CashRegister> {
    try {
      const { data, error } = await supabase
        .from('caixa')
        .insert({
          saldo_inicial: openingAmount,
          status: 'aberto',
          observacoes: 'Caixa aberto automaticamente'
        })
        .select()
        .single()
      
      if (error) throw error
      
      const adaptedCashRegister: CashRegister = {
        id: data.id,
        opened_by: data.user_id,
        opening_amount: data.saldo_inicial,
        current_amount: data.saldo_inicial,
        status: data.status as 'aberto' | 'fechado',
        opened_at: data.data_abertura,
        closed_at: data.data_fechamento,
        notes: data.observacoes || ''
      }
      
      return adaptedCashRegister
      
    } catch (error) {
      console.error('Erro ao abrir caixa:', error)
      throw error
    }
  },

  async close(closingBalance: number): Promise<void> {
    try {
      const { error } = await supabase
        .from('caixa')
        .update({
          saldo_final: closingBalance,
          status: 'fechado',
          data_fechamento: new Date().toISOString()
        })
        .eq('status', 'aberto')
      
      if (error) throw error
      
    } catch (error) {
      console.error('Erro ao fechar caixa:', error)
      throw error
    }
  }
}

/*
📋 CORREÇÕES APLICADAS:

❌ PROBLEMAS ANTERIORES:
1. Campos user_id e cash_register_id faltando na inserção da venda
2. Tabela 'vendas_itens' provavelmente não existia
3. Logs insuficientes para debug
4. Tratamento de erro inadequado

✅ SOLUÇÕES IMPLEMENTADAS:
1. ✅ Adicionado user_id na inserção da venda  
2. ✅ Preparado para cash_register_id se necessário
3. ✅ Tabela vendas_itens será criada pelo SQL
4. ✅ Logs detalhados para debug
5. ✅ Tratamento de erro melhorado
6. ✅ Adaptação de dados corrigida

🔧 PRÓXIMOS PASSOS:
1. Execute o arquivo CORRIGIR_FINALIZACAO_VENDAS.sql no Supabase
2. Substitua este arquivo por src/services/salesEmbedded.ts
3. Teste a finalização de vendas
4. Verifique os logs no console para debug

📊 COMPATIBILIDADE:
- ✅ Estrutura atual mantida
- ✅ Tipos TypeScript mantidos  
- ✅ Fallbacks para produtos embarcados
- ✅ Adaptação de campos português/inglês
- ✅ RLS e triggers preparados
*/