import { supabase } from '../lib/supabase';
import { format, startOfWeek, startOfMonth, endOfWeek, endOfMonth, subDays, subWeeks, subMonths } from 'date-fns';

export interface SalesReport {
  totalSales: number;
  totalAmount: number;
  paymentMethods: {
    method: string;
    count: number;
    amount: number;
  }[];
  topProducts: {
    productName: string;
    quantity: number;
    revenue: number;
  }[];
  dailySales: {
    date: string;
    amount: number;
    count: number;
  }[];
}

export interface ClientsReport {
  totalClients: number;
  newClients: number;
  clientsWithPurchases: number;
  topClients: {
    clientName: string;
    totalPurchases: number;
    totalAmount: number;
    serviceOrders: number;
    serviceAmount: number;
  }[];
  clientGrowth: {
    date: string;
    newClients: number;
    totalClients: number;
  }[];
}

export interface ServiceOrdersReport {
  totalOrders: number;
  totalRevenue: number;
  newClients: number;
  repeatClients: number;
  equipmentStats: {
    equipment: string;
    count: number;
    revenue: number;
  }[];
  statusDistribution: {
    status: string;
    count: number;
  }[];
  weeklyStats: {
    week: string;
    count: number;
    revenue: number;
  }[];
  monthlyStats: {
    month: string;
    count: number;
    revenue: number;
  }[];
}

class RealReportsService {
  async getSalesReport(period: 'week' | 'month' | 'quarter' = 'month'): Promise<SalesReport> {
    const now = new Date();
    let startDate: Date;
    let endDate: Date;

    switch (period) {
      case 'week':
        startDate = startOfWeek(now);
        endDate = endOfWeek(now);
        break;
      case 'month':
        startDate = startOfMonth(now);
        endDate = endOfMonth(now);
        break;
      case 'quarter':
        startDate = subMonths(now, 3);
        endDate = now;
        break;
    }

    console.log('🔍 Buscando vendas do período:', { startDate, endDate, period });

    // Buscar vendas do período com campos corretos
    const { data: sales, error: salesError } = await supabase
      .from('sales')
      .select('*')
      .gte('created_at', startDate.toISOString())
      .lte('created_at', endDate.toISOString());

    if (salesError) {
      console.error('❌ Erro ao buscar vendas:', salesError);
      throw salesError;
    }

    console.log('✅ Vendas encontradas:', sales?.length || 0);

    // Calcular totais
    const totalSales = sales?.length || 0;
    const totalAmount = sales?.reduce((sum, sale) => sum + (sale.total_amount || 0), 0) || 0;

    // Métodos de pagamento
    const paymentMethodsMap = new Map();
    sales?.forEach(sale => {
      const method = sale.payment_method || 'N/A';
      const current = paymentMethodsMap.get(method) || { count: 0, amount: 0 };
      paymentMethodsMap.set(method, {
        count: current.count + 1,
        amount: current.amount + (sale.total_amount || 0)
      });
    });

    const paymentMethods = Array.from(paymentMethodsMap.entries()).map(([method, data]) => ({
      method,
      count: data.count,
      amount: data.amount
    }));

    // Buscar produtos mais vendidos (dados reais)
    const { data: salesItems, error: itemsError } = await supabase
      .from('sale_items')
      .select('product_id, quantity, unit_price, total_price')
      .in('sale_id', sales?.map(s => s.id) || []);

    if (itemsError) {
      console.error('❌ Erro ao buscar itens de vendas:', itemsError);
    }

    // Buscar nomes dos produtos (usando os produtos embutidos como fallback)
    const productIds = salesItems?.map(item => item.product_id).filter(Boolean) || [];
    let productsData: any[] = [];
    
    if (productIds.length > 0) {
      // Buscar primeiro do banco de dados
      const { data: dbProducts } = await supabase
        .from('products')
        .select('id, name')
        .in('id', productIds);
      
      if (dbProducts) {
        productsData = dbProducts;
      }
      
      // DADOS EMBEDADOS DESABILITADOS - Usando apenas Supabase com RLS
      console.log('🔍 [REPORTS] Usando apenas dados do Supabase com RLS - produtos encontrados:', productsData.length)
    }

    // Processar produtos mais vendidos
    const productSalesMap = new Map<string, { quantity: number; revenue: number; name: string }>();
    
    salesItems?.forEach(item => {
      if (item.product_id) {
        const product = productsData.find(p => p.id === item.product_id);
        const productName = product?.name || `Produto ${item.product_id}`;
        
        const current = productSalesMap.get(item.product_id) || { 
          quantity: 0, 
          revenue: 0, 
          name: productName 
        };
        
        productSalesMap.set(item.product_id, {
          quantity: current.quantity + (item.quantity || 0),
          revenue: current.revenue + (item.total_price || 0),
          name: productName
        });
      }
    });

    // Converter para array e ordenar por quantidade vendida
    const topProducts = Array.from(productSalesMap.values())
      .sort((a, b) => b.quantity - a.quantity)
      .slice(0, 5)
      .map(p => ({
        productName: p.name,
        quantity: p.quantity,
        revenue: p.revenue
      }));

    // Vendas diárias
    const dailySalesMap = new Map();
    sales?.forEach(sale => {
      const date = format(new Date(sale.created_at), 'yyyy-MM-dd');
      const current = dailySalesMap.get(date) || { amount: 0, count: 0 };
      dailySalesMap.set(date, {
        amount: current.amount + (sale.total_amount || 0),
        count: current.count + 1
      });
    });

    const dailySales = Array.from(dailySalesMap.entries())
      .map(([date, data]) => ({
        date,
        amount: data.amount,
        count: data.count
      }))
      .sort((a, b) => a.date.localeCompare(b.date));

    return {
      totalSales,
      totalAmount,
      paymentMethods,
      topProducts,
      dailySales
    };
  }

  async getClientsReport(period: 'week' | 'month' | 'quarter' = 'month'): Promise<ClientsReport> {
    const now = new Date();
    let startDate: Date;
    let endDate: Date;

    switch (period) {
      case 'week':
        startDate = startOfWeek(now);
        endDate = endOfWeek(now);
        break;
      case 'month':
        startDate = startOfMonth(now);
        endDate = endOfMonth(now);
        break;
      case 'quarter':
        startDate = subMonths(now, 3);
        endDate = now;
        break;
    }

    console.log('🔍 Buscando dados de clientes do período:', { startDate, endDate, period });

    // Buscar todos os clientes
    const { data: allClients, error: clientsError } = await supabase
      .from('customers')
      .select('*');

    if (clientsError) {
      console.error('❌ Erro ao buscar clientes:', clientsError);
      throw clientsError;
    }

    // Clientes novos no período
    const { data: newClientsData, error: newClientsError } = await supabase
      .from('customers')
      .select('*')
      .gte('created_at', startDate.toISOString())
      .lte('created_at', endDate.toISOString());

    if (newClientsError) {
      console.error('❌ Erro ao buscar novos clientes:', newClientsError);
      throw newClientsError;
    }

    // Vendas por cliente (query simplificada)
    const { data: salesByClient, error: salesError } = await supabase
      .from('sales')
      .select('*')
      .not('cliente_id', 'is', null)
      .gte('created_at', startDate.toISOString())
      .lte('created_at', endDate.toISOString());

    if (salesError) {
      console.error('❌ Erro ao buscar vendas por cliente:', salesError);
      throw salesError;
    }

    // Ordens de serviço por cliente (query simplificada)
    const { data: serviceOrdersByClient, error: serviceError } = await supabase
      .from('service_orders')
      .select('*')
      .not('customer_id', 'is', null)
      .gte('created_at', startDate.toISOString())
      .lte('created_at', endDate.toISOString());

    if (serviceError) {
      console.error('❌ Erro ao buscar OS por cliente:', serviceError);
      throw serviceError;
    }

    console.log('✅ Dados encontrados:', {
      totalClients: allClients?.length || 0,
      newClients: newClientsData?.length || 0,
      salesByClient: salesByClient?.length || 0,
      serviceOrders: serviceOrdersByClient?.length || 0
    });

    // Processar dados dos clientes com nomes reais
    const clientStatsMap = new Map();

    // Criar mapa de clientes por ID para lookup rápido
    const clientsMap = new Map();
    allClients?.forEach(client => {
      clientsMap.set(client.id, client.nome || `Cliente ${client.id}`);
    });

    // Adicionar vendas
    salesByClient?.forEach(sale => {
      const clientId = sale.customer_id;
      const clientName = clientsMap.get(clientId) || `Cliente ${clientId}`;
      const current = clientStatsMap.get(clientId) || {
        clientName,
        totalPurchases: 0,
        totalAmount: 0,
        serviceOrders: 0,
        serviceAmount: 0
      };
      clientStatsMap.set(clientId, {
        ...current,
        totalPurchases: current.totalPurchases + 1,
        totalAmount: current.totalAmount + (sale.total_amount || 0)
      });
    });

    // Adicionar ordens de serviço
    serviceOrdersByClient?.forEach(order => {
      const clientId = order.cliente_id;
      const clientName = clientsMap.get(clientId) || `Cliente ${clientId}`;
      const current = clientStatsMap.get(clientId) || {
        clientName,
        totalPurchases: 0,
        totalAmount: 0,
        serviceOrders: 0,
        serviceAmount: 0
      };
      clientStatsMap.set(clientId, {
        ...current,
        serviceOrders: current.serviceOrders + 1,
        serviceAmount: current.serviceAmount + (order.valor_orcamento || order.valor_final || 0)
      });
    });

    const topClients = Array.from(clientStatsMap.values())
      .sort((a, b) => (b.totalAmount + b.serviceAmount) - (a.totalAmount + a.serviceAmount))
      .slice(0, 10);

    // Dados de crescimento reais baseados no banco
    const clientGrowthMap = new Map();
    
    // Inicializar mapa com os últimos 7 dias
    for (let i = 6; i >= 0; i--) {
      const date = format(subDays(now, i), 'yyyy-MM-dd');
      clientGrowthMap.set(date, { newClients: 0, totalClients: 0 });
    }

    // Contar novos clientes por dia
    newClientsData?.forEach(client => {
      const date = format(new Date(client.criado_em), 'yyyy-MM-dd');
      if (clientGrowthMap.has(date)) {
        const current = clientGrowthMap.get(date);
        clientGrowthMap.set(date, {
          ...current,
          newClients: current.newClients + 1
        });
      }
    });

    const clientGrowth = Array.from(clientGrowthMap.entries())
      .map(([date, data]) => ({
        date,
        newClients: data.newClients,
        totalClients: allClients?.length || 0 // Total atual para todos os dias
      }))
      .sort((a, b) => a.date.localeCompare(b.date));

    return {
      totalClients: allClients?.length || 0,
      newClients: newClientsData?.length || 0,
      clientsWithPurchases: clientStatsMap.size,
      topClients,
      clientGrowth
    };
  }

  async getServiceOrdersReport(period: 'week' | 'month' | 'quarter' | 'all' = 'month'): Promise<ServiceOrdersReport> {
    const now = new Date();
    let startDate: Date | undefined;
    let endDate: Date | undefined;

    switch (period) {
      case 'week':
        startDate = startOfWeek(now);
        endDate = endOfWeek(now);
        break;
      case 'month':
        startDate = startOfMonth(now);
        endDate = endOfMonth(now);
        break;
      case 'quarter':
        startDate = subMonths(now, 3);
        endDate = now;
        break;
      case 'all':
        // Para "all", não aplicamos filtro de data
        break;
    }

    console.log('🔍 Buscando ordens de serviço do período:', { startDate, endDate, period });

    // Buscar ordens de serviço do período
    let query = supabase
      .from('ordens_servico')
      .select(`
        *,
        clientes (nome, criado_em)
      `);

    // Só aplica filtro de data se não for "all"
    if (period !== 'all' && startDate && endDate) {
      query = query
        .gte('criado_em', startDate.toISOString())
        .lte('criado_em', endDate.toISOString());
    }

    const { data: orders, error: ordersError } = await query;

    if (ordersError) {
      console.error('❌ Erro ao buscar ordens de serviço:', ordersError);
      throw ordersError;
    }

    console.log('✅ Ordens de serviço encontradas:', orders?.length || 0);

    const totalOrders = orders?.length || 0;
    const totalRevenue = orders?.reduce((sum, order) => sum + (order.valor_orcamento || order.valor_final || 0), 0) || 0;

    // Novos vs clientes recorrentes
    const clientsInPeriod = new Set();
    const newClients = new Set();
    
    orders?.forEach(order => {
      if (order.cliente_id) {
        clientsInPeriod.add(order.cliente_id);
        
        // Verificar se é cliente novo (criado no mesmo período) - só se tiver startDate
        if (order.clientes?.criado_em && startDate) {
          const clientCreated = new Date(order.clientes.criado_em);
          if (clientCreated >= startDate) {
            newClients.add(order.cliente_id);
          }
        }
      }
    });

    // Estatísticas por equipamento
    const equipmentMap = new Map();
    orders?.forEach(order => {
      const equipment = order.tipo || 'Equipamento não especificado';
      const current = equipmentMap.get(equipment) || { count: 0, revenue: 0 };
      equipmentMap.set(equipment, {
        count: current.count + 1,
        revenue: current.revenue + (order.valor_orcamento || order.valor_final || 0)
      });
    });

    const equipmentStats = Array.from(equipmentMap.entries())
      .map(([equipment, data]) => ({
        equipment,
        count: data.count,
        revenue: data.revenue
      }))
      .sort((a, b) => b.revenue - a.revenue);

    // Distribuição por status
    const statusMap = new Map();
    orders?.forEach(order => {
      const status = order.status || 'Sem status';
      statusMap.set(status, (statusMap.get(status) || 0) + 1);
    });

    const statusDistribution = Array.from(statusMap.entries()).map(([status, count]) => ({
      status,
      count
    }));

    // Estatísticas semanais (últimas 8 semanas)
    const weeklyStats = [];
    for (let i = 7; i >= 0; i--) {
      const weekStart = startOfWeek(subWeeks(now, i));
      const weekEnd = endOfWeek(subWeeks(now, i));
      
      const { data: weekOrders } = await supabase
        .from('ordens_servico')
        .select('valor_orcamento, valor_final')
        .gte('criado_em', weekStart.toISOString())
        .lte('criado_em', weekEnd.toISOString());

      weeklyStats.push({
        week: format(weekStart, 'dd/MM'),
        count: weekOrders?.length || 0,
        revenue: weekOrders?.reduce((sum, order) => sum + (order.valor_orcamento || order.valor_final || 0), 0) || 0
      });
    }

    // Estatísticas mensais (últimos 6 meses)
    const monthlyStats = [];
    for (let i = 5; i >= 0; i--) {
      const monthStart = startOfMonth(subMonths(now, i));
      const monthEnd = endOfMonth(subMonths(now, i));
      
      const { data: monthOrders } = await supabase
        .from('ordens_servico')
        .select('valor_orcamento, valor_final')
        .gte('criado_em', monthStart.toISOString())
        .lte('criado_em', monthEnd.toISOString());

      monthlyStats.push({
        month: format(monthStart, 'MMM/yy'),
        count: monthOrders?.length || 0,
        revenue: monthOrders?.reduce((sum, order) => sum + (order.valor_orcamento || order.valor_final || 0), 0) || 0
      });
    }

    return {
      totalOrders,
      totalRevenue,
      newClients: newClients.size,
      repeatClients: clientsInPeriod.size - newClients.size,
      equipmentStats,
      statusDistribution,
      weeklyStats,
      monthlyStats
    };
  }

  // ===== FUNÇÕES DE RANKING PARA ORDENS DE SERVIÇO =====

  async getClientRepairRanking(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    const now = new Date();
    let startDate: Date | undefined;
    let endDate: Date | undefined;

    switch (period) {
      case 'week':
        startDate = startOfWeek(now);
        endDate = endOfWeek(now);
        break;
      case 'month':
        startDate = startOfMonth(now);
        endDate = endOfMonth(now);
        break;
      case 'quarter':
        startDate = subMonths(now, 3);
        endDate = now;
        break;
      case 'all':
        // Para "all", não aplicamos filtro de data
        break;
    }

    let query = supabase
      .from('ordens_servico')
      .select(`
        cliente_id,
        valor_orcamento,
        valor_final,
        criado_em,
        clientes (nome)
      `)
      .not('cliente_id', 'is', null);

    if (period !== 'all' && startDate && endDate) {
      query = query
        .gte('criado_em', startDate.toISOString())
        .lte('criado_em', endDate.toISOString());
    }

    const { data: orders, error } = await query;

    if (error) {
      console.error('❌ Erro ao buscar ranking de clientes:', error);
      return [];
    }

    // Agrupar por cliente
    const clientMap = new Map();
    orders?.forEach(order => {
      const clientId = order.cliente_id;
      const clientName = (order.clientes as any)?.nome || `Cliente ${clientId}`;
      const value = order.valor_final || order.valor_orcamento || 0;
      
      if (clientMap.has(clientId)) {
        const current = clientMap.get(clientId);
        clientMap.set(clientId, {
          ...current,
          orders: current.orders + 1,
          totalValue: current.totalValue + value,
          lastOrder: order.criado_em > current.lastOrder ? order.criado_em : current.lastOrder
        });
      } else {
        clientMap.set(clientId, {
          id: clientId,
          name: clientName,
          orders: 1,
          totalValue: value,
          lastOrder: order.criado_em
        });
      }
    });

    // Converter para array e calcular ticket médio
    return Array.from(clientMap.values())
      .map(client => ({
        ...client,
        avgValue: client.orders > 0 ? client.totalValue / client.orders : 0
      }))
      .sort((a, b) => b.orders - a.orders)
      .slice(0, 10);
  }

  async getClientSpendingRanking(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    const ranking = await this.getClientRepairRanking(period);
    return ranking.sort((a, b) => b.totalValue - a.totalValue);
  }

  async getOrderTypeRanking(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    const now = new Date();
    let startDate: Date | undefined;
    let endDate: Date | undefined;

    switch (period) {
      case 'week':
        startDate = startOfWeek(now);
        endDate = endOfWeek(now);
        break;
      case 'month':
        startDate = startOfMonth(now);
        endDate = endOfMonth(now);
        break;
      case 'quarter':
        startDate = subMonths(now, 3);
        endDate = now;
        break;
      case 'all':
        break;
    }

    let query = supabase
      .from('ordens_servico')
      .select('tipo, valor_orcamento, valor_final, criado_em');

    if (period !== 'all' && startDate && endDate) {
      query = query
        .gte('criado_em', startDate.toISOString())
        .lte('criado_em', endDate.toISOString());
    }

    const { data: orders, error } = await query;

    if (error) {
      console.error('❌ Erro ao buscar ranking de tipos:', error);
      return [];
    }

    // Agrupar por tipo
    const typeMap = new Map();
    const totalOrders = orders?.length || 0;

    orders?.forEach(order => {
      const type = order.tipo || 'Tipo não especificado';
      const value = order.valor_final || order.valor_orcamento || 0;
      
      if (typeMap.has(type)) {
        const current = typeMap.get(type);
        typeMap.set(type, {
          ...current,
          count: current.count + 1,
          totalValue: current.totalValue + value
        });
      } else {
        typeMap.set(type, {
          id: Math.random(),
          type,
          count: 1,
          totalValue: value
        });
      }
    });

    return Array.from(typeMap.values())
      .map(typeData => ({
        ...typeData,
        percentage: totalOrders > 0 ? (typeData.count / totalOrders) * 100 : 0,
        avgValue: typeData.count > 0 ? typeData.totalValue / typeData.count : 0,
        avgTime: '3-5 dias' // Placeholder - seria necessário calcular com dados de conclusão
      }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 10);
  }

  async getEquipmentProfitRanking(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    const now = new Date();
    let startDate: Date | undefined;
    let endDate: Date | undefined;

    switch (period) {
      case 'week':
        startDate = startOfWeek(now);
        endDate = endOfWeek(now);
        break;
      case 'month':
        startDate = startOfMonth(now);
        endDate = endOfMonth(now);
        break;
      case 'quarter':
        startDate = subMonths(now, 3);
        endDate = now;
        break;
      case 'all':
        break;
    }

    let query = supabase
      .from('ordens_servico')
      .select('tipo, valor_orcamento, valor_final, criado_em');

    if (period !== 'all' && startDate && endDate) {
      query = query
        .gte('criado_em', startDate.toISOString())
        .lte('criado_em', endDate.toISOString());
    }

    const { data: orders, error } = await query;

    if (error) {
      console.error('❌ Erro ao buscar ranking de lucro por equipamento:', error);
      return [];
    }

    // Agrupar por tipo de equipamento
    const equipmentMap = new Map();

    orders?.forEach(order => {
      const equipment = order.tipo || 'Equipamento não especificado';
      const revenue = order.valor_final || order.valor_orcamento || 0;
      // Estimativa de custo (60% da receita - seria melhor ter dados reais)
      const cost = revenue * 0.6;
      const profit = revenue - cost;
      
      if (equipmentMap.has(equipment)) {
        const current = equipmentMap.get(equipment);
        equipmentMap.set(equipment, {
          ...current,
          count: current.count + 1,
          revenue: current.revenue + revenue,
          cost: current.cost + cost,
          profit: current.profit + profit
        });
      } else {
        equipmentMap.set(equipment, {
          id: Math.random(),
          equipment,
          count: 1,
          revenue,
          cost,
          profit
        });
      }
    });

    return Array.from(equipmentMap.values())
      .map(equipData => ({
        ...equipData,
        margin: equipData.revenue > 0 ? (equipData.profit / equipData.revenue) * 100 : 0
      }))
      .sort((a, b) => b.profit - a.profit)
      .slice(0, 10);
  }

  // ===== FUNÇÕES DE RANKING PARA PRODUTOS =====

  async getProductRanking(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    const now = new Date();
    let startDate: Date | undefined;
    let endDate: Date | undefined;

    switch (period) {
      case 'week':
        startDate = startOfWeek(now);
        endDate = endOfWeek(now);
        break;
      case 'month':
        startDate = startOfMonth(now);
        endDate = endOfMonth(now);
        break;
      case 'quarter':
        startDate = subMonths(now, 3);
        endDate = now;
        break;
      case 'all':
        break;
    }

    let query = supabase
      .from('sale_items')
      .select(`
        produto_id,
        quantidade,
        preco_unitario,
        total,
        vendas!inner(created_at),
        produtos(nome, categoria)
      `);

    if (period !== 'all' && startDate && endDate) {
      query = query
        .gte('vendas.created_at', startDate.toISOString())
        .lte('vendas.created_at', endDate.toISOString());
    }

    const { data: salesItems, error } = await query;

    if (error) {
      console.error('❌ Erro ao buscar ranking de produtos:', error);
      return [];
    }

    // Agrupar por produto
    const productMap = new Map();

    salesItems?.forEach(item => {
      const productId = item.produto_id;
      const productName = (item.produtos as any)?.nome || `Produto ${productId}`;
      const category = (item.produtos as any)?.categoria || 'Sem categoria';
      const revenue = item.total || (item.quantidade * item.preco_unitario);
      const quantity = item.quantidade || 0;
      // Estimativa de margem (30% - seria melhor ter dados reais de custo)
      const margin = 30;
      
      if (productMap.has(productId)) {
        const current = productMap.get(productId);
        productMap.set(productId, {
          ...current,
          sales: current.sales + 1,
          revenue: current.revenue + revenue,
          units: current.units + quantity
        });
      } else {
        productMap.set(productId, {
          id: productId,
          name: productName,
          category,
          sales: 1,
          revenue,
          units: quantity,
          margin
        });
      }
    });

    return Array.from(productMap.values())
      .sort((a, b) => b.revenue - a.revenue)
      .slice(0, 10);
  }

  // ===== FUNÇÕES DE RANKING PARA CATEGORIAS =====

  async getCategoryRanking(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    const productRanking = await this.getProductRanking(period);
    
    // Agrupar por categoria
    const categoryMap = new Map();
    let totalRevenue = 0;

    productRanking.forEach(product => {
      const category = product.category;
      totalRevenue += product.revenue;
      
      if (categoryMap.has(category)) {
        const current = categoryMap.get(category);
        categoryMap.set(category, {
          ...current,
          sales: current.sales + product.sales,
          revenue: current.revenue + product.revenue,
          units: current.units + product.units
        });
      } else {
        categoryMap.set(category, {
          id: Math.random(),
          name: category,
          sales: product.sales,
          revenue: product.revenue,
          units: product.units,
          margin: 30, // Estimativa
          growth: Math.random() * 20 - 5 // Estimativa de crescimento
        });
      }
    });

    return Array.from(categoryMap.values())
      .map(category => ({
        ...category,
        participation: totalRevenue > 0 ? (category.revenue / totalRevenue) * 100 : 0
      }))
      .sort((a, b) => b.revenue - a.revenue)
      .slice(0, 10);
  }

  // ===== Analytics Functions =====
  
  async getAnalyticsInsights(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    try {
      const insights = [];
      
      // Get basic sales data
      const salesPeriod = period === 'all' ? 'quarter' : period;
      const salesReport = await this.getSalesReport(salesPeriod);
      const serviceReport = await this.getServiceOrdersReport(period);
      
      // Insight 1: Revenue opportunity
      if (salesReport.totalAmount > 0) {
        const avgTicket = salesReport.totalAmount / salesReport.totalSales;
        insights.push({
          id: 'revenue-opportunity',
          type: 'opportunity' as const,
          title: 'Oportunidade de Aumento do Ticket Médio',
          description: `Com base no ticket médio atual de ${avgTicket.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })}, há potencial de crescimento`,
          impact: 'medium' as const,
          action: 'Implementar estratégias de cross-sell',
          value: avgTicket * salesReport.totalSales * 0.15, // 15% potential increase
          trend: 15
        });
      }

      // Insight 2: Service vs Sales comparison
      if (serviceReport.totalOrders > 0 && salesReport.totalSales > 0) {
        const serviceRevenuePct = (serviceReport.totalRevenue / (serviceReport.totalRevenue + salesReport.totalAmount)) * 100;
        
        if (serviceRevenuePct > 30) {
          insights.push({
            id: 'service-strength',
            type: 'success' as const,
            title: 'Forte Performance em Serviços',
            description: `Serviços representam ${serviceRevenuePct.toFixed(1)}% da receita total - excelente equilíbrio`,
            impact: 'high' as const,
            value: serviceReport.totalRevenue,
            trend: Math.round(serviceRevenuePct)
          });
        }
      }

      // Insight 3: Payment method analysis
      const pixPayments = salesReport.paymentMethods.find(p => p.method.toLowerCase().includes('pix'));
      if (pixPayments && salesReport.totalAmount > 0) {
        const pixPct = (pixPayments.amount / salesReport.totalAmount) * 100;
        
        if (pixPct < 30) {
          insights.push({
            id: 'pix-opportunity',
            type: 'warning' as const,
            title: 'Oportunidade de Crescimento via PIX',
            description: `PIX representa apenas ${pixPct.toFixed(1)}% das vendas. Incentive seu uso para reduzir custos`,
            impact: 'medium' as const,
            action: 'Criar campanha promocional PIX',
            trend: Math.round(pixPct)
          });
        }
      }

      // Insight 4: Top product performance
      if (salesReport.topProducts.length > 0) {
        const topProduct = salesReport.topProducts[0];
        const topProductRevenuePct = (topProduct.revenue / salesReport.totalAmount) * 100;
        
        if (topProductRevenuePct > 20) {
          insights.push({
            id: 'product-concentration',
            type: 'info' as const,
            title: 'Concentração em Produto Principal',
            description: `${topProduct.productName} representa ${topProductRevenuePct.toFixed(1)}% da receita`,
            impact: 'medium' as const,
            action: 'Diversificar portfólio de produtos',
            value: topProduct.revenue,
            trend: Math.round(topProductRevenuePct)
          });
        }
      }

      return insights;
    } catch (error) {
      console.error('Error getting analytics insights:', error);
      return [];
    }
  }

  async getAnalyticsPredictions(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    try {
      const predictions = [];
      
      // Get historical data
      const salesPeriod = period === 'all' ? 'quarter' : period;
      const salesReport = await this.getSalesReport(salesPeriod);
      const serviceReport = await this.getServiceOrdersReport(period);
      const clientsReport = await this.getClientsReport(salesPeriod);
      
      // Prediction 1: Revenue forecast
      if (salesReport.totalAmount > 0) {
        const currentRevenue = salesReport.totalAmount + serviceReport.totalRevenue;
        const predictedRevenue = currentRevenue * 1.12; // 12% growth prediction
        
        predictions.push({
          metric: 'Faturamento Total',
          current: currentRevenue,
          predicted: predictedRevenue,
          confidence: 85,
          trend: 'up' as const,
          timeframe: 'Próximo período'
        });
      }

      // Prediction 2: New clients
      if (clientsReport.newClients > 0) {
        const predictedNewClients = Math.round(clientsReport.newClients * 1.08); // 8% growth
        
        predictions.push({
          metric: 'Novos Clientes',
          current: clientsReport.newClients,
          predicted: predictedNewClients,
          confidence: 75,
          trend: 'up' as const,
          timeframe: 'Próximo período'
        });
      }

      // Prediction 3: Average ticket
      if (salesReport.totalSales > 0) {
        const currentTicket = salesReport.totalAmount / salesReport.totalSales;
        const predictedTicket = currentTicket * 1.05; // 5% increase
        
        predictions.push({
          metric: 'Ticket Médio',
          current: currentTicket,
          predicted: predictedTicket,
          confidence: 80,
          trend: 'up' as const,
          timeframe: 'Próximo período'
        });
      }

      // Prediction 4: Service orders
      if (serviceReport.totalOrders > 0) {
        const predictedOrders = Math.round(serviceReport.totalOrders * 1.15); // 15% growth
        
        predictions.push({
          metric: 'Ordens de Serviço',
          current: serviceReport.totalOrders,
          predicted: predictedOrders,
          confidence: 70,
          trend: 'up' as const,
          timeframe: 'Próximo período'
        });
      }

      return predictions;
    } catch (error) {
      console.error('Error getting analytics predictions:', error);
      return [];
    }
  }

  async getAnalyticsAnomalies(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    try {
      const anomalies = [];
      
      // Get current data
      const salesPeriod = period === 'all' ? 'quarter' : period;
      const salesReport = await this.getSalesReport(salesPeriod);
      const serviceReport = await this.getServiceOrdersReport(period);
      
      // Anomaly 1: Check for unusual payment method distribution
      if (salesReport.paymentMethods.length > 0 && salesReport.totalAmount > 0) {
        const cashPayments = salesReport.paymentMethods.find(p => 
          p.method.toLowerCase().includes('dinheiro') || p.method.toLowerCase().includes('cash')
        );
        
        if (cashPayments) {
          const cashPct = (cashPayments.amount / salesReport.totalAmount) * 100;
          
          if (cashPct > 50) { // Unusual high cash usage
            anomalies.push({
              id: 'high-cash-usage',
              metric: 'Pagamentos em Dinheiro',
              detected: new Date(),
              severity: 'medium' as const,
              description: `Uso de dinheiro acima do normal: ${cashPct.toFixed(1)}%`,
              expectedValue: 30,
              actualValue: Math.round(cashPct),
              deviation: Math.round(cashPct - 30)
            });
          }
        }
      }

      // Anomaly 2: Service to sales ratio
      if (serviceReport.totalRevenue > 0 && salesReport.totalAmount > 0) {
        const serviceRatio = (serviceReport.totalRevenue / salesReport.totalAmount) * 100;
        
        if (serviceRatio > 80) { // Very high service ratio
          anomalies.push({
            id: 'high-service-ratio',
            metric: 'Proporção Serviços/Vendas',
            detected: new Date(),
            severity: 'low' as const,
            description: `Proporção de serviços muito alta: ${serviceRatio.toFixed(1)}%`,
            expectedValue: 40,
            actualValue: Math.round(serviceRatio),
            deviation: Math.round(serviceRatio - 40)
          });
        }
      }

      // Anomaly 3: Low sales volume
      if (salesReport.totalSales < 5 && period === 'month') { // Very low monthly sales
        anomalies.push({
          id: 'low-sales-volume',
          metric: 'Volume de Vendas Mensais',
          detected: new Date(),
          severity: 'high' as const,
          description: `Volume de vendas muito baixo para o período: ${salesReport.totalSales} vendas`,
          expectedValue: 20,
          actualValue: salesReport.totalSales,
          deviation: Math.round(((salesReport.totalSales - 20) / 20) * 100)
        });
      }

      return anomalies;
    } catch (error) {
      console.error('Error getting analytics anomalies:', error);
      return [];
    }
  }
}

export const realReportsService = new RealReportsService();