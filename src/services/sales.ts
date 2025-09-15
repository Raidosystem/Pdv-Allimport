import { supabase } from '../lib/supabase'
import type { Product, Customer, Sale, CashRegister, SaleSearchParams, SaleItem } from '../types/sales'
import { EMBEDDED_PRODUCTS, searchEmbeddedProducts } from '../data/products'

// Serviços de Produtos
export const productService = {
  async search(params: SaleSearchParams): Promise<Product[]> {
    console.log('🔍 ProductService.search chamado com:', params);
    
    // Usa produtos embutidos diretamente (garantia de funcionamento)
    console.log('📦 Usando produtos embutidos');
    
    const embeddedResults = searchEmbeddedProducts(params.search);
    
    // Adapta formato dos produtos embutidos para o frontend
    const adaptedProducts: Product[] = embeddedResults.map(product => ({
      id: product.id,
      name: product.name,
      description: `${product.category} - ${product.name}`,
      sku: product.sku,
      barcode: product.barcode,
      price: product.price,
      stock_quantity: product.stock,
      min_stock: 1,
      unit: 'un',
      active: product.active,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }));
    
    // Filtra por código de barras APENAS se fornecido
    if (params.barcode && params.barcode.trim()) {
      const filtered = adaptedProducts.filter(p => p.barcode === params.barcode);
      console.log(`🔍 Filtrado por código de barras ${params.barcode}:`, filtered.length, 'produtos');
      return filtered;
    }
    
    // Filtra por busca de texto se fornecido
    if (params.search && params.search.trim()) {
      const searchTerm = params.search.toLowerCase().trim();
      const filtered = adaptedProducts.filter(p => 
        p.name.toLowerCase().includes(searchTerm) ||
        p.description?.toLowerCase().includes(searchTerm) ||
        p.barcode?.includes(searchTerm)
      );
      console.log(`🔍 Filtrado por busca de texto "${params.search}":`, filtered.length, 'produtos');
      return filtered;
    }
    
    console.log('✅ Retornando', adaptedProducts.length, 'produtos embutidos');
    return adaptedProducts;
  },

  async getById(id: string): Promise<Product | null> {
    console.log('🔍 Buscando produto por ID:', id);
    
    const product = EMBEDDED_PRODUCTS.find(p => p.id === id);
    
    if (!product) {
      console.log('❌ Produto não encontrado');
      return null;
    }

    const adaptedProduct: Product = {
      id: product.id,
      name: product.name,
      description: `${product.category} - ${product.name}`,
      sku: product.sku,
      barcode: product.barcode,
      price: product.price,
      stock_quantity: product.stock,
      min_stock: 1,
      unit: 'un',
      active: product.active,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    console.log('✅ Produto encontrado:', adaptedProduct);
    return adaptedProduct;
  }
};

// Serviços de Clientes
export const customerService = {
  async search(query?: string): Promise<Customer[]> {
    try {
      let queryBuilder = supabase
        .from('clientes')
        .select('*')
        .eq('ativo', true)
        .order('nome');
      
      if (query) {
        queryBuilder = queryBuilder.or(`nome.ilike.%${query}%,telefone.ilike.%${query}%,documento.ilike.%${query}%`);
      }
      
      const { data, error } = await queryBuilder.limit(50);
      
      if (error) throw error;
      
      const adaptedCustomers: Customer[] = (data || []).map(customer => ({
        id: customer.id,
        name: customer.nome,
        email: customer.email || '',
        phone: customer.telefone || '',
        document: customer.documento || '',
        address: customer.endereco || '',
        active: customer.ativo !== false,
        created_at: customer.criado_em,
        updated_at: customer.atualizado_em
      }));
      
      return adaptedCustomers;
      
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      return [];
    }
  },

  async getById(id: string): Promise<Customer | null> {
    try {
      const { data, error } = await supabase
        .from('clientes')
        .select('*')
        .eq('id', id)
        .single();
      
      if (error) throw error;
      
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
      };
      
      return adaptedCustomer;
      
    } catch (error) {
      console.error('Erro ao buscar cliente por ID:', error);
      return null;
    }
  },

  async create(customerData: {
    name: string;
    email?: string;
    phone?: string;
    document?: string;
    address?: string;
  }): Promise<Customer> {
    try {
      const { data, error } = await supabase
        .from('clientes')
        .insert({
          nome: customerData.name,
          email: customerData.email || '',
          telefone: customerData.phone || '',
          documento: customerData.document || '',
          endereco: customerData.address || '',
          ativo: true
        })
        .select()
        .single();
      
      if (error) throw error;
      
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
      };
      
      return adaptedCustomer;
      
    } catch (error) {
      console.error('Erro ao criar cliente:', error);
      throw error;
    }
  }
};

// Tipos auxiliares para criação de venda
interface SaleItemInput {
  product_id: string | null; // Permitir null para produtos de venda rápida
  product_name?: string; // Nome do produto para vendas rápidas
  quantity: number;
  unit_price: number;
  total_price: number;
}

interface SaleInput {
  customer_id?: string;
  cash_register_id?: string;
  user_id: string;
  total_amount: number;
  discount_amount?: number;
  status: string;
  payment_method: string;
  payment_details?: Record<string, string | number | boolean>;
  notes?: string;
  sale_items: SaleItemInput[];
}

// Serviços de Vendas
export const saleService = {
  async create(sale: SaleInput): Promise<Sale> {
    console.log('🔄 Iniciando criação de venda...', sale);
    
    try {
      // ✅ CORREÇÃO: Incluir user_id obrigatório para RLS
      const vendaData = {
        // cliente_id: sale.customer_id, // Temporariamente removido para teste
        // Removendo caixa_id temporariamente para testar se esse é o problema
        total: sale.total_amount,
        desconto: sale.discount_amount || 0,
        status: sale.status,
        metodo_pagamento: sale.payment_method,
        observacoes: sale.notes || '',
        user_id: sale.user_id  // ✅ Campo obrigatório adicionado
      };
      
      console.log('🔧 [DEBUG] Dados da venda MÍNIMOS:', vendaData);
      
      console.log('📝 Inserindo venda:', vendaData);
      
      const { data, error } = await supabase
        .from('vendas')
        .insert(vendaData)
        .select()
        .single();
      
      if (error) {
        console.error('❌ Erro ao inserir venda:', error);
        console.error('❌ Detalhes do erro:', {
          message: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code
        });
        console.error('❌ Dados enviados:', vendaData);
        throw error;
      }

      console.log('✅ Venda criada:', data);
      
      // Inserir itens da venda
      const saleItems: SaleItem[] = [];
      if (sale.sale_items && sale.sale_items.length > 0) {
        console.log(`📦 Inserindo ${sale.sale_items.length} itens da venda...`);
        
        for (const item of sale.sale_items) {
          const itemData = {
            venda_id: data.id,
            produto_id: item.product_id, // Pode ser null para produtos de venda rápida
            // produto_nome: item.product_name || null, // Removido temporariamente
            quantidade: item.quantity,
            preco_unitario: item.unit_price,
            subtotal: item.total_price
            // user_id será setado automaticamente pelo trigger
          };
          
          console.log('📝 Inserindo item (sem produto_nome):', itemData);
          
          const { data: itemResult, error: itemError } = await supabase
            .from('vendas_itens')
            .insert(itemData)
            .select()
            .single();
            
          if (itemError) {
            console.error('❌ Erro ao inserir item:', itemError);
            console.error('❌ Detalhes do erro item:', {
              message: itemError.message,
              details: itemError.details,
              hint: itemError.hint,
              code: itemError.code
            });
            console.error('❌ Dados do item enviados:', itemData);
            throw itemError;
          }
          
          console.log('✅ Item inserido:', itemResult);
          
          saleItems.push({
            id: itemResult.id,
            sale_id: itemResult.venda_id,
            product_id: itemResult.produto_id,
            quantity: itemResult.quantidade,
            unit_price: itemResult.preco_unitario,
            total_price: itemResult.subtotal,
            created_at: itemResult.created_at
          });
        }
      }
      
      const adaptedSale: Sale = {
        id: data.id,
        customer_id: data.cliente_id,
        cash_register_id: sale.cash_register_id || '',
        user_id: sale.user_id,
        total_amount: data.total,
        discount_amount: data.desconto || 0,
        status: data.status,
        payment_method: data.metodo_pagamento,
        notes: data.observacoes || '',
        sale_items: saleItems,
        created_at: data.created_at,
        updated_at: data.updated_at
      };
      
      console.log('🎉 Venda completa criada:', adaptedSale);
      
      // ✅ NOVA FUNCIONALIDADE: Registrar movimentação de caixa automaticamente
      try {
        await saleService.registrarMovimentacaoCaixa(adaptedSale);
      } catch (caixaError) {
        console.warn('⚠️ Erro ao registrar movimentação de caixa:', caixaError);
        // Não falha a venda se houver erro no caixa
      }
      
      return adaptedSale;
      
    } catch (error) {
      console.error('💥 Erro completo ao criar venda:', error);
      
      // Log mais detalhado para debug
      if (error instanceof Error) {
        console.error('📋 Mensagem do erro:', error.message);
        console.error('📊 Stack do erro:', error.stack);
      }
      
      throw error;
    }
  },

  // ✅ NOVO MÉTODO: Registrar movimentação de caixa para cada venda
  async registrarMovimentacaoCaixa(sale: Sale): Promise<void> {
    try {
      console.log('💰 Registrando movimentação de caixa para venda:', sale.id);
      
      // Buscar caixa aberto
      const caixaAberto = await cashRegisterService.getStatus();
      if (!caixaAberto) {
        console.warn('⚠️ Nenhum caixa aberto encontrado - criando movimentação sem caixa');
        return;
      }
      
      // Criar movimentação de entrada no caixa
      const movimentacao = {
        caixa_id: caixaAberto.id,
        tipo: 'entrada',
        descricao: `Venda ${sale.id} - ${sale.payment_method}`,
        valor: sale.total_amount,
        usuario_id: sale.user_id,
        venda_id: sale.id,
        data: new Date().toISOString()
      };
      
      const { error } = await supabase
        .from('movimentacoes_caixa')
        .insert(movimentacao);
      
      if (error) {
        console.error('❌ Erro ao registrar movimentação:', error);
        throw error;
      }
      
      // Atualizar valor atual do caixa
      const novoValor = Number(caixaAberto.saldo_inicial || 0) + Number(sale.total_amount);
      
      const { error: updateError } = await supabase
        .from('caixa')
        .update({ 
          valor_atual: novoValor,
          atualizado_em: new Date().toISOString()
        })
        .eq('id', caixaAberto.id);
      
      if (updateError) {
        console.error('❌ Erro ao atualizar valor do caixa:', updateError);
        throw updateError;
      }
      
      console.log('✅ Movimentação de caixa registrada com sucesso');
      
    } catch (error) {
      console.error('💥 Erro ao registrar movimentação de caixa:', error);
      throw error;
    }
  }
};

// Serviços de Caixa
export const cashRegisterService = {
  async getStatus(): Promise<CashRegister | null> {
    try {
      const { data, error } = await supabase
        .from('caixa')
        .select('*')
        .eq('status', 'aberto')
        .order('criado_em', { ascending: false })
        .limit(1)
        .single();
        
      if (error) {
        if (error.code === 'PGRST116') return null; // Nenhum registro encontrado
        throw error;
      }
      
      return {
        id: data.id,
        user_id: data.usuario_id,
        data_abertura: data.criado_em,
        data_fechamento: data.fechado_em,
        saldo_inicial: data.valor_inicial,
        saldo_final: data.valor_atual,
        status: data.status,
        created_at: data.criado_em,
        updated_at: data.atualizado_em || data.criado_em
      };
      
    } catch (error) {
      console.error('Erro ao verificar status do caixa:', error);
      return null;
    }
  },

  async open(openingBalance: number): Promise<CashRegister> {
    try {
      const { data, error } = await supabase
        .from('caixa')
        .insert({
          valor_inicial: openingBalance,
          valor_atual: openingBalance,
          status: 'aberto'
        })
        .select()
        .single();
      
      if (error) throw error;
      
      return {
        id: data.id,
        user_id: data.usuario_id,
        data_abertura: data.criado_em,
        data_fechamento: data.fechado_em,
        saldo_inicial: data.valor_inicial,
        saldo_final: data.valor_atual,
        status: data.status,
        created_at: data.criado_em,
        updated_at: data.atualizado_em || data.criado_em
      };
      
    } catch (error) {
      console.error('Erro ao abrir caixa:', error);
      throw error;
    }
  },

  async close(closingBalance: number): Promise<void> {
    try {
      const { error } = await supabase
        .from('caixa')
        .update({
          valor_atual: closingBalance,
          status: 'fechado',
          fechado_em: new Date().toISOString()
        })
        .eq('status', 'aberto');
      
      if (error) throw error;
      
    } catch (error) {
      console.error('Erro ao fechar caixa:', error);
      throw error;
    }
  }
};

// Alias para compatibilidade
export const salesService = saleService;