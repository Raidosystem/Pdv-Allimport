import { supabase } from '../lib/supabase'
import type { Product, Customer, Sale, CashRegister, SaleSearchParams, SaleItem } from '../types/sales'

// Serviços de Produtos
export const productService = {
  async search(params: SaleSearchParams): Promise<Product[]> {
    console.log('🔍 ProductService.search chamado com:', params);
    
    try {
      console.log('📦 BUSCANDO PRODUTOS NO SUPABASE (respeitando RLS)');
      
      // ✅ OBTER USER_ID DO USUÁRIO AUTENTICADO
      const { data: { user }, error: userError } = await supabase.auth.getUser();
      if (userError || !user) {
        console.error('❌ Erro ao obter usuário:', userError);
        return [];
      }
      
      let query = supabase
        .from('produtos')
        .select('*')
        .eq('user_id', user.id)  // ✅ FILTRAR POR USER_ID
        .eq('ativo', true)
        .order('nome');

      console.log('🔍 [productService.search] Filtros aplicados:', {
        user_id: user.id,
        ativo: true,
        barcode: params.barcode || 'não fornecido',
        search: params.search || 'não fornecido'
      });

      // 🔍 DEBUG: Verificar TODOS os produtos do usuário (sem filtro de ativo)
      const { data: allUserProducts } = await supabase
        .from('produtos')
        .select('id, nome, ativo, codigo_barras, sku')
        .eq('user_id', user.id);
      
      console.log(`📊 [DEBUG] Total de produtos do usuário: ${allUserProducts?.length || 0}`);
      console.log(`📊 [DEBUG] Produtos ativos: ${allUserProducts?.filter(p => p.ativo).length || 0}`);
      console.log(`📊 [DEBUG] Produtos inativos: ${allUserProducts?.filter(p => !p.ativo).length || 0}`);
      if (allUserProducts && allUserProducts.length > 0) {
        console.log('📋 [DEBUG] Primeiros 3 produtos:', allUserProducts.slice(0, 3));
      }

      // Filtrar por código de barras se fornecido
      if (params.barcode && params.barcode.trim()) {
        query = query.eq('codigo_barras', params.barcode.trim());
        console.log(`🔍 Filtrando por código de barras: ${params.barcode}`);
      }
      
      // Filtrar por texto de busca se fornecido
      if (params.search && params.search.trim()) {
        const searchTerm = params.search.trim();
        query = query.or(`nome.ilike.%${searchTerm}%,descricao.ilike.%${searchTerm}%,sku.ilike.%${searchTerm}%`);
        console.log(`🔍 Filtrando por busca de texto: ${searchTerm}`);
      }

      const { data, error } = await query.limit(50);

      if (error) {
        console.error('❌ Erro ao buscar produtos no Supabase:', error);
        return [];
      }

      console.log(`✅ Encontrados ${data?.length || 0} produtos no Supabase (respeitando RLS)`);

      // Adaptar formato do Supabase para o frontend
      const adaptedProducts: Product[] = (data || []).map(produto => {
        // Buscar estoque corretamente - a coluna principal é "estoque"
        const stockValue = produto.estoque ?? 
                          produto.current_stock ?? 
                          produto.estoque_atual ?? 
                          produto.quantidade ?? 
                          produto.qty ?? 
                          produto.stock ??
                          produto.quantidade_estoque ??
                          0; // Valor padrão 0 ao invés de 999
        
        console.log(`📦 [${produto.nome}] Estoque mapeado: ${stockValue} (estoque: ${produto.estoque}, current_stock: ${produto.current_stock}, quantidade: ${produto.quantidade})`);
        
        return {
          id: produto.id,
          name: produto.nome,
          description: produto.descricao || produto.nome,
          sku: produto.sku || '',
          barcode: produto.codigo_barras || '',
          price: produto.preco || 0,
          stock_quantity: stockValue,
          min_stock: produto.minimum_stock || produto.estoque_minimo || 0,
          unit: produto.unit_measure || produto.unidade || 'un',
          active: produto.ativo || true,
          created_at: produto.created_at || produto.criado_em || new Date().toISOString(),
          updated_at: produto.updated_at || produto.atualizado_em || new Date().toISOString()
        };
      });

      return adaptedProducts;
      
    } catch (error) {
      console.error('❌ Erro geral ao buscar produtos:', error);
      return [];
    }
  },

  async getById(id: string): Promise<Product | null> {
    console.log('🔍 Buscando produto por ID no Supabase:', id);
    
    try {
      // ✅ OBTER USER_ID DO USUÁRIO AUTENTICADO
      const { data: { user }, error: userError } = await supabase.auth.getUser();
      if (userError || !user) {
        console.error('❌ Erro ao obter usuário:', userError);
        return null;
      }
      
      const { data, error } = await supabase
        .from('produtos')
        .select('*')
        .eq('id', id)
        .eq('user_id', user.id)  // ✅ FILTRAR POR USER_ID
        .eq('ativo', true)
        .single();

      if (error || !data) {
        console.log('❌ Produto não encontrado no Supabase');
        return null;
      }

      const adaptedProduct: Product = {
        id: data.id,
        name: data.nome,
        description: data.descricao || data.nome,
        sku: data.sku || '',
        barcode: data.codigo_barras || '',
        price: data.preco || 0,
        stock_quantity: data.estoque ?? data.current_stock ?? data.estoque_atual ?? data.quantidade ?? 0,
        min_stock: data.minimum_stock || data.estoque_minimo || 0,
        unit: data.unit_measure || data.unidade || 'un',
        active: data.ativo || true,
        created_at: data.criado_em || new Date().toISOString(),
        updated_at: data.atualizado_em || new Date().toISOString()
      };
      
      console.log('✅ Produto encontrado no Supabase:', adaptedProduct);
      return adaptedProduct;
      
    } catch (error) {
      console.error('❌ Erro ao buscar produto por ID:', error);
      return null;
    }
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
      // ✅ CORREÇÃO: Incluir todos os campos necessários
      const vendaData: any = {
        total: sale.total_amount,
        desconto: sale.discount_amount || 0,
        status: sale.status,
        metodo_pagamento: sale.payment_method,
        observacoes: sale.notes || ''
        // user_id e empresa_id serão preenchidos pelo trigger automaticamente
      };

      // Adicionar cliente_id apenas se fornecido
      if (sale.customer_id) {
        vendaData.cliente_id = sale.customer_id;
      }

      // Adicionar caixa_id apenas se fornecido
      if (sale.cash_register_id) {
        vendaData.caixa_id = sale.cash_register_id;
      }

      // Adicionar payment_details se fornecido
      if (sale.payment_details) {
        vendaData.detalhes_pagamento = sale.payment_details;
      }
      
      console.log('🔧 [DEBUG] Dados da venda preparados:', vendaData);
      console.log('📝 [DEBUG] sale.customer_id:', sale.customer_id);
      console.log('📝 [DEBUG] sale.cash_register_id:', sale.cash_register_id);
      console.log('📝 [DEBUG] sale.user_id:', sale.user_id);
      
      console.log('📝 Inserindo venda:', vendaData);
      
      const { data, error } = await supabase
        .from('vendas')
        .insert(vendaData)
        .select()
        .single();
      
      if (error) {
        console.error('❌ Erro ao inserir venda:', error);
        console.error('❌ Código do erro:', error.code);
        console.error('❌ Mensagem:', error.message);
        console.error('❌ Detalhes:', error.details);
        console.error('❌ Hint:', error.hint);
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
            produto_nome: item.product_name || 'Produto sem nome', // Campo obrigatório
            quantidade: item.quantity,
            preco_unitario: item.unit_price,
            subtotal: item.total_price,
            total: item.total_price // Campo obrigatório - mesmo valor que subtotal
            // user_id será setado automaticamente pelo trigger
          };
          
          console.log('📝 Inserindo item com produto_nome e total:', itemData);
          
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
            product: item.product_name ? {
              id: item.product_id || '',
              name: item.product_name,
              price: item.unit_price,
              stock_quantity: 0,
              min_stock: 0,
              unit: 'un',
              active: true,
              created_at: '',
              updated_at: ''
            } : undefined,
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
      
      // ✅ APLICAR VENDA: Atualizar estoque e registrar CMV
      try {
        console.log('📦 Aplicando venda no estoque (fn_aplicar_venda)...');
        const { error: vendaError } = await supabase.rpc('fn_aplicar_venda', {
          p_venda_id: adaptedSale.id
        });
        
        if (vendaError) {
          console.error('❌ Erro ao aplicar venda no estoque:', vendaError);
          // Não falha a venda, mas registra o erro
        } else {
          console.log('✅ Venda aplicada no estoque com sucesso');
        }
      } catch (estoqueError) {
        console.warn('⚠️ Erro ao processar estoque:', estoqueError);
      }
      
      // ✅ NOVA FUNCIONALIDADE: Registrar movimentação de caixa automaticamente
      try {
        await saleService.registrarMovimentacaoCaixa(adaptedSale);
      } catch (caixaError) {
        console.warn('⚠️ Erro ao registrar movimentação de caixa:', caixaError);
        // Não falha a venda se houver erro no caixa
      }
      
      // ✅ DISPARA EVENTO PARA ATUALIZAR RELATÓRIOS EM TEMPO REAL
      try {
        const event = new CustomEvent('saleCompleted', { 
          detail: { sale: adaptedSale } 
        });
        window.dispatchEvent(event);
        console.log('📢 Evento saleCompleted disparado para atualizar relatórios');
      } catch (eventError) {
        console.warn('⚠️ Erro ao disparar evento:', eventError);
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
      
      // Montar descrição com nomes dos produtos
      let descricao = 'Venda';
      
      console.log('🔍 Debug sale:', {
        id: sale.id,
        sale_items_length: sale.sale_items?.length,
        sale_items: sale.sale_items
      });
      
      if (sale.sale_items && sale.sale_items.length > 0) {
        // PRIMEIRO: Tentar usar os nomes dos produtos já disponíveis nos sale_items
        const itemsComNomes = sale.sale_items.filter(item => item.product?.name);
        
        if (itemsComNomes.length > 0) {
          // Usar nomes já disponíveis
          const productNames = itemsComNomes.map(item => item.product!.name).slice(0, 3).join(', ');
          
          if (sale.sale_items.length > 3) {
            descricao = `Venda: ${productNames} e mais ${sale.sale_items.length - 3} item(ns)`;
          } else {
            descricao = `Venda: ${productNames}`;
          }
          
          console.log('✅ Descrição gerada com nomes dos items:', descricao);
        } else {
          // FALLBACK: Buscar nomes dos produtos no banco
          const productIds = sale.sale_items.map(item => item.product_id).filter(Boolean);
          
          console.log('🔍 Product IDs extraídos (busca no banco):', productIds);
          
          if (productIds.length > 0) {
            try {
              const { data: products, error: prodError } = await supabase
                .from('produtos')
                .select('id, nome')
                .in('id', productIds)
                .limit(3);
              
              console.log('🔍 Produtos encontrados:', { products, error: prodError });
              
              if (products && products.length > 0) {
                const productNames = products.map(p => p.nome).join(', ');
                
                if (sale.sale_items.length > 3) {
                  descricao = `Venda: ${productNames} e mais ${sale.sale_items.length - 3} item(ns)`;
                } else {
                  descricao = `Venda: ${productNames}`;
                }
                
                console.log('✅ Descrição gerada (busca no banco):', descricao);
              } else {
                descricao = `Venda de ${sale.sale_items.length} item(ns)`;
                console.log('⚠️ Nenhum produto encontrado - usando fallback');
              }
            } catch (error) {
              console.warn('⚠️ Erro ao buscar nomes dos produtos:', error);
              descricao = `Venda de ${sale.sale_items.length} item(ns)`;
            }
          } else {
            descricao = `Venda de ${sale.sale_items.length} item(ns)`;
            console.log('⚠️ Nenhum product_id válido - usando fallback');
          }
        }
      } else {
        // Fallback se não houver items
        descricao = `Venda #${sale.id.substring(0, 8)}`;
        console.log('⚠️ Sale sem items - usando ID');
      }
      
      // Adicionar método de pagamento
      const paymentMethodLabel: Record<string, string> = {
        'cash': 'Dinheiro',
        'credit': 'Crédito',
        'debit': 'Débito',
        'pix': 'PIX',
        'card': 'Cartão',
        'mixed': 'Misto'
      };
      
      descricao += ` - ${paymentMethodLabel[sale.payment_method] || sale.payment_method}`;
      
      // Criar movimentação de entrada no caixa
      const movimentacao = {
        caixa_id: caixaAberto.id,
        tipo: 'entrada',
        descricao,
        valor: sale.total_amount,
        user_id: sale.user_id,  // ✅ CORRIGIDO: Padronizado para user_id (conforme schema do banco)
        venda_id: sale.id,
        data: new Date().toISOString()
      };
      
      console.log('💰 [DEBUG] Movimentação a ser inserida:', movimentacao);
      
      const { error } = await supabase
        .from('movimentacoes_caixa')
        .insert(movimentacao);
      
      if (error) {
        console.error('❌ Erro ao registrar movimentação:', error);
        // Não lança erro para não interromper a venda
        return;
      }
      
      console.log('✅ Movimentação registrada com sucesso:', {
        caixa_id: caixaAberto.id,
        tipo: 'entrada',
        descricao,
        valor: sale.total_amount,
        user_id: sale.user_id,
        venda_id: sale.id
      });
      
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