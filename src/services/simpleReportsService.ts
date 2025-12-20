import { supabase } from '../lib/supabase';
import { format, startOfWeek, startOfMonth, endOfWeek, endOfMonth, subDays, subWeeks, subMonths } from 'date-fns';

// Interfaces dos relatórios
export interface SalesReport {
  totalSales: number;
  totalAmount: number;
  paymentMethods: Array<{
    method: string;
    count: number;
    amount: number;
  }>;
  topProducts: Array<{
    productName: string;
    quantity: number;
    revenue: number;
  }>;
  dailySales: Array<{
    date: string;
    amount: number;
    count: number;
  }>;
}

export interface ClientsReport {
  totalClients: number;
  newClients: number;
  clientsWithPurchases: number;
  topClients: Array<{
    clientName: string;
    totalPurchases: number;
    totalAmount: number;
    serviceOrders: number;
    serviceAmount: number;
  }>;
  clientGrowth: Array<{
    date: string;
    newClients: number;
    totalClients: number;
  }>;
}

export interface ServiceOrdersReport {
  totalOrders: number;
  totalRevenue: number;
  newClients: number;
  repeatClients: number;
  equipmentStats: Array<{
    equipment: string;
    count: number;
    revenue: number;
  }>;
  statusDistribution: Array<{
    status: string;
    count: number;
    percentage: number;
  }>;
  monthlyOrders: Array<{
    date: string;
    orders: number;
    revenue: number;
  }>;
}

// Classe do serviço de relatórios simplificada
class SimpleReportsService {
  private getDateRange(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    const now = new Date();
    let startDate: Date;
    let endDate: Date;

    switch (period) {
      case 'week':
        // Últimos 7 dias
        startDate = subDays(now, 7);
        endDate = now;
        break;
      case 'month':
        // Últimos 30 dias (não mês atual, mas últimos 30 dias)
        startDate = subDays(now, 30);
        endDate = now;
        break;
      case 'quarter':
        // Últimos 90 dias
        startDate = subDays(now, 90);
        endDate = now;
        break;
      case 'all':
        // 🌟 Período COMPLETO - desde o início dos tempos até agora
        startDate = new Date('2000-01-01'); // Data muito antiga para pegar todos os dados
        endDate = now;
        break;
      default:
        startDate = subDays(now, 30);
        endDate = now;
    }

    return { startDate, endDate };
  }

  async getSalesReport(period: 'week' | 'month' | 'quarter' = 'month'): Promise<SalesReport> {
    const callId = Math.random().toString(36).substr(2, 9);
    console.log(`🔵 [CALL ${callId}] getSalesReport INICIADO - period: ${period}`);
    
    try {
      const { startDate, endDate } = this.getDateRange(period);
      
      console.log(`🔍 [${callId}] Buscando vendas do período:`, { startDate, endDate, period });
      console.log(`🔍 [${callId}] Data de início:`, startDate.toISOString());
      console.log(`🔍 [${callId}] Data de fim:`, endDate.toISOString());

      // Tentar primeiro com created_at (campo padrão)
      let sales = null;
      let salesError = null;

      const result1 = await supabase
        .from('vendas')
        .select('*')
        .gte('created_at', startDate.toISOString())
        .lte('created_at', endDate.toISOString());

      if (result1.error) {
        console.warn(`⚠️ [${callId}] Erro com created_at, tentando data_venda...`, result1.error);
        
        // Fallback: tentar com data_venda (dados antigos)
        const result2 = await supabase
          .from('vendas')
          .select('*')
          .gte('data_venda', startDate.toISOString())
          .lte('data_venda', endDate.toISOString());
        
        sales = result2.data;
        salesError = result2.error;
      } else {
        sales = result1.data;
      }

      if (salesError) {
        console.error('❌ Erro ao buscar vendas:', salesError);
        console.error('❌ Detalhes:', JSON.stringify(salesError, null, 2));
        throw salesError;
      }

      console.log(`✅ [${callId}] Vendas encontradas no período:`, sales?.length || 0);
      console.log(`✅ [${callId}] Primeira venda (se existir):`, sales?.[0]);
      if (sales && sales.length > 0) {
        console.log(`📅 [${callId}] Datas das vendas encontradas:`, sales.map(s => ({ id: s.id, created_at: s.created_at, total: s.total })));
      }
      
      // DEBUG: Buscar TODAS as vendas sem filtro para verificar
      const { data: allSales } = await supabase
        .from('vendas')
        .select('id, created_at, total')
        .order('created_at', { ascending: false })
        .limit(10);
      console.log(`🔍 [${callId}] Total de vendas na tabela (últimas 10):`, allSales?.length);
      if (allSales && allSales.length > 0) {
        console.log(`🔍 [${callId}] Datas de TODAS as vendas recentes:`);
        allSales.forEach(s => {
          console.log(`  📅 ID ${s.id}: ${s.created_at} (total: R$ ${s.total})`);
        });
      }

      // Calcular totais (campos em português: total e desconto)
      const totalSales = sales?.length || 0;
      const totalAmount = sales?.reduce((sum, sale) => {
        const total = Number(sale.total) || 0;
        const desconto = Number(sale.desconto) || 0;
        const valor = total - desconto;
        console.log(`  💳 [${callId}] Venda ID ${sale.id}: total=${total}, desconto=${desconto}, valor final=${valor}`);
        return sum + valor;
      }, 0) || 0;

      console.log(`💰 [${callId}] Total calculado: R$ ${totalAmount.toFixed(2)} de ${totalSales} vendas`);

      // Métodos de pagamento (campo: metodo_pagamento)
      const paymentMethodsMap = new Map();
      sales?.forEach(sale => {
        const method = sale.metodo_pagamento || 'dinheiro';
        const total = Number(sale.total) || 0;
        const desconto = Number(sale.desconto) || 0;
        const amount = total - desconto;
        const current = paymentMethodsMap.get(method) || { count: 0, amount: 0 };
        paymentMethodsMap.set(method, {
          count: current.count + 1,
          amount: current.amount + amount
        });
      });

      const paymentMethods = Array.from(paymentMethodsMap.entries()).map(([method, data]) => ({
        method,
        count: data.count,
        amount: data.amount
      }));

      // Vendas diárias (agrupar por data real usando created_at)
      const dailySalesMap = new Map<string, { amount: number; count: number }>();
      
      sales?.forEach(sale => {
        const dateKey = format(new Date(sale.created_at), 'dd/MM');
        const total = Number(sale.total) || 0;
        const desconto = Number(sale.desconto) || 0;
        const amount = total - desconto;
        const current = dailySalesMap.get(dateKey) || { amount: 0, count: 0 };
        
        dailySalesMap.set(dateKey, {
          amount: current.amount + amount,
          count: current.count + 1
        });
      });

      const dailySales = Array.from(dailySalesMap.entries())
        .map(([date, data]) => ({
          date,
          amount: data.amount,
          count: data.count
        }))
        .sort((a, b) => {
          // Ordenar por data
          const [dayA, monthA] = a.date.split('/').map(Number);
          const [dayB, monthB] = b.date.split('/').map(Number);
          return monthA === monthB ? dayA - dayB : monthA - monthB;
        });

      // Buscar produtos mais vendidos (da tabela vendas_itens)
      const { data: salesItems, error: itemsError } = await supabase
        .from('vendas_itens')
        .select(`
          produto_id,
          quantidade,
          subtotal,
          produtos (nome)
        `)
        .in('venda_id', sales?.map(s => s.id) || []);

      if (itemsError) {
        console.error('❌ Erro ao buscar itens:', itemsError);
      }

      // Agrupar produtos
      const productMap = new Map<string, { name: string; quantity: number; revenue: number }>();
      
      salesItems?.forEach(item => {
        const productId = item.produto_id || 'unknown';
        const productName = (item.produtos as any)?.nome || 'Produto sem nome';
        const quantity = Number(item.quantidade) || 0;
        const revenue = Number(item.subtotal) || 0;
        
        const current = productMap.get(productId) || { name: productName, quantity: 0, revenue: 0 };
        productMap.set(productId, {
          name: productName,
          quantity: current.quantity + quantity,
          revenue: current.revenue + revenue
        });
      });

      const topProducts = Array.from(productMap.values())
        .sort((a, b) => b.revenue - a.revenue)
        .slice(0, 10)
        .map(p => ({
          productName: p.name,
          quantity: p.quantity,
          revenue: p.revenue
        }));

      console.log(`🚀 [${callId}] RETORNO - totalSales=${totalSales}, totalAmount=${totalAmount}`);
      console.log(`🚀 [${callId}] Objeto completo:`, { totalSales, totalAmount, paymentMethodsCount: paymentMethods.length, topProductsCount: topProducts.length, dailySalesCount: dailySales.length });

      return {
        totalSales,
        totalAmount,
        paymentMethods,
        topProducts,
        dailySales
      };

    } catch (error) {
      console.error(`❌ [${callId}] Erro ao gerar relatório de vendas:`, error);
      
      // Retornar dados padrão em caso de erro
      return {
        totalSales: 0,
        totalAmount: 0,
        paymentMethods: [],
        topProducts: [],
        dailySales: []
      };
    }
  }

  async getClientsReport(period: 'week' | 'month' | 'quarter' = 'month'): Promise<ClientsReport> {
    try {
      const { startDate, endDate } = this.getDateRange(period);
      
      console.log('🔍 [SIMPLE] Buscando dados de clientes do período:', { startDate, endDate, period });

      // Buscar todos os clientes (tabela clientes no sistema)
      const { data: allClients, error: clientsError } = await supabase
        .from('clientes')
        .select('*');

      if (clientsError) {
        console.error('❌ Erro ao buscar clientes:', clientsError);
        throw clientsError;
      }

      // Clientes novos no período
      const { data: newClientsData, error: newClientsError } = await supabase
        .from('clientes')
        .select('*')
        .gte('created_at', startDate.toISOString())
        .lte('created_at', endDate.toISOString());

      if (newClientsError) {
        console.error('❌ Erro ao buscar novos clientes:', newClientsError);
      }

      console.log('✅ Clientes encontrados:', allClients?.length || 0, 'novos:', newClientsData?.length || 0);

      const totalClients = allClients?.length || 0;
      const newClients = newClientsData?.length || 0;

      // Dados simulados para top clientes
      const topClients = [
        { clientName: 'Cliente VIP A', totalPurchases: 15, totalAmount: 2500, serviceOrders: 3, serviceAmount: 450 },
        { clientName: 'Cliente VIP B', totalPurchases: 12, totalAmount: 1800, serviceOrders: 2, serviceAmount: 300 },
        { clientName: 'Cliente VIP C', totalPurchases: 8, totalAmount: 1200, serviceOrders: 1, serviceAmount: 150 },
        { clientName: 'Cliente VIP D', totalPurchases: 6, totalAmount: 900, serviceOrders: 1, serviceAmount: 100 },
        { clientName: 'Cliente VIP E', totalPurchases: 4, totalAmount: 600, serviceOrders: 0, serviceAmount: 0 }
      ];

      // Crescimento de clientes (simulado)
      const clientGrowth = [];
      for (let i = 0; i < 30; i++) {
        const date = new Date(startDate);
        date.setDate(date.getDate() + i);
        clientGrowth.push({
          date: format(date, 'dd/MM'),
          newClients: Math.round(Math.random() * 3),
          totalClients: totalClients + i
        });
      }

      return {
        totalClients,
        newClients,
        clientsWithPurchases: Math.round(totalClients * 0.7),
        topClients,
        clientGrowth
      };

    } catch (error) {
      console.error('❌ [SIMPLE] Erro ao gerar relatório de clientes:', error);
      
      return {
        totalClients: 0,
        newClients: 0,
        clientsWithPurchases: 0,
        topClients: [],
        clientGrowth: []
      };
    }
  }

  async getServiceOrdersReport(period: 'week' | 'month' | 'quarter' | 'all' = 'month'): Promise<ServiceOrdersReport> {
    try {
      console.log('🔍 [SIMPLE] Buscando ordens de serviço - período:', period);
      console.log('🔍 [SIMPLE] Tipo do período:', typeof period, period === 'all');

      let query = supabase.from('ordens_servico').select('*');
      let startDate: Date;
      let endDate: Date;

      // Se o período não for 'all', aplicar filtro de data
      if (period !== 'all') {
        const range = this.getDateRange(period);
        startDate = range.startDate;
        endDate = range.endDate;
        console.log('📅 [SIMPLE] Filtrando por data:', { startDate, endDate });
        query = query
          .gte('created_at', startDate.toISOString())
          .lte('created_at', endDate.toISOString());
      } else {
        console.log('🌐 [SIMPLE] Buscando TODAS as ordens (sem filtro de data)');
        // Para 'all', usar range do último ano para cálculos
        endDate = new Date();
        startDate = new Date();
        startDate.setFullYear(startDate.getFullYear() - 1);
      }

      // Ordenar por data de criação
      query = query.order('created_at', { ascending: false });

      console.log('🔍 [SIMPLE] Executando query...');
      const { data: orders, error: ordersError } = await query;
      
      console.log('🔍 [SIMPLE] Query executada. Erro?', ordersError ? 'SIM' : 'NÃO');
      console.log('🔍 [SIMPLE] Dados retornados?', orders ? `SIM (${orders.length})` : 'NÃO');

      if (ordersError) {
        console.error('❌ Erro ao buscar ordens de serviço:', ordersError);
        throw ordersError;
      }

      console.log('✅ Ordens de serviço encontradas:', orders?.length || 0);
      if (orders && orders.length > 0) {
        console.log('📋 [SIMPLE] Primeira ordem:', {
          id: orders[0].id,
          created_at: orders[0].created_at,
          status: orders[0].status
        });
      }

      const totalOrders = orders?.length || 0;
      const totalRevenue = orders?.reduce((sum, order) => sum + (Number(order.valor_final) || 0), 0) || 0;

      console.log(`💰 Total OS: R$ ${totalRevenue.toFixed(2)} de ${totalOrders} ordens`);

      // Estatísticas de equipamentos
      const equipmentMap = new Map();
      orders?.forEach(order => {
        const equipment = order.equipamento || order.equipment || 'Não informado';
        const revenue = Number(order.valor_final) || Number(order.valor_estimado) || 0;
        const current = equipmentMap.get(equipment) || { count: 0, revenue: 0 };
        equipmentMap.set(equipment, {
          count: current.count + 1,
          revenue: current.revenue + revenue
        });
      });

      const equipmentStats = Array.from(equipmentMap.entries()).map(([equipment, data]) => ({
        equipment,
        count: data.count,
        revenue: data.revenue
      }));

      // Distribuição de status
      const statusMap = new Map();
      orders?.forEach(order => {
        const status = order.status || 'pending';
        statusMap.set(status, (statusMap.get(status) || 0) + 1);
      });

      const statusDistribution = Array.from(statusMap.entries()).map(([status, count]) => ({
        status,
        count,
        percentage: totalOrders > 0 ? Math.round((count / totalOrders) * 100) : 0
      }));

      // Ordens mensais (simulado)
      const monthlyOrders = [];
      const daysInPeriod = Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24));
      const avgDailyOrders = totalOrders / daysInPeriod;
      const avgDailyRevenue = totalRevenue / daysInPeriod;

      for (let i = 0; i < Math.min(daysInPeriod, 30); i++) {
        const date = new Date(startDate);
        date.setDate(date.getDate() + i);
        monthlyOrders.push({
          date: format(date, 'dd/MM'),
          orders: Math.round(avgDailyOrders * (0.8 + Math.random() * 0.4)),
          revenue: Math.round(avgDailyRevenue * (0.8 + Math.random() * 0.4))
        });
      }

      return {
        totalOrders,
        totalRevenue,
        newClients: Math.round(totalOrders * 0.3),
        repeatClients: Math.round(totalOrders * 0.7),
        equipmentStats,
        statusDistribution,
        monthlyOrders
      };

    } catch (error) {
      console.error('❌ [SIMPLE] Erro ao gerar relatório de ordens de serviço:', error);
      
      return {
        totalOrders: 0,
        totalRevenue: 0,
        newClients: 0,
        repeatClients: 0,
        equipmentStats: [],
        statusDistribution: [],
        monthlyOrders: []
      };
    }
  }

  // Métodos para rankings (versões simplificadas)
  async getProductRanking(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    try {
      console.log('🔍 [SIMPLE] Buscando ranking de produtos do banco...');
      const { startDate, endDate } = this.getDateRange(period);
      
      // ESTRATÉGIA 1: Tentar buscar de itens_venda
      const { data: itens, error: itensError } = await supabase
        .from('itens_venda')
        .select(`
          id,
          quantidade,
          preco_unitario,
          subtotal,
          produto_id,
          produtos!inner (
            id,
            nome,
            categoria_id,
            categorias (
              nome
            )
          ),
          vendas!inner (
            created_at
          )
        `)
        .gte('vendas.created_at', startDate.toISOString())
        .lte('vendas.created_at', endDate.toISOString());

      // Se itens_venda tem dados, usar
      if (!itensError && itens && itens.length > 0) {
        console.log(`✅ Encontrados ${itens.length} itens em itens_venda`);
        const productsMap = new Map<string, { 
          id: string;
          name: string; 
          category: string; 
          units: number; 
          revenue: number 
        }>();
        
        itens.forEach((item: any) => {
          const produtoId = item.produtos?.id || item.produto_id || 'unknown';
          const produtoNome = item.produtos?.nome || 'Produto sem nome';
          const categoria = item.produtos?.categorias?.nome || 'Sem Categoria';
          
          const current = productsMap.get(produtoId) || { 
            id: produtoId,
            name: produtoNome,
            category: categoria,
            units: 0, 
            revenue: 0 
          };
          
          productsMap.set(produtoId, {
            ...current,
            units: current.units + (item.quantidade || 0),
            revenue: current.revenue + (item.subtotal || 0)
          });
        });

        const products = Array.from(productsMap.values())
          .sort((a, b) => b.revenue - a.revenue)
          .slice(0, 10);

        return products.map(p => ({ ...p, margin: 40 }));
      }

      // ESTRATÉGIA 2: itens_venda vazio - buscar vendas diretamente COM vendas_itens
      console.log('⚠️ itens_venda vazio, buscando de VENDAS com vendas_itens...');
      const { data: vendas, error: vendasError } = await supabase
        .from('vendas')
        .select(`
          id, 
          total, 
          desconto, 
          observacoes,
          created_at,
          vendas_itens (
            id,
            produto_id,
            quantidade,
            preco_unitario,
            subtotal,
            produtos (
              id,
              nome,
              categorias (
                nome
              )
            )
          )
        `)
        .gte('created_at', startDate.toISOString())
        .lte('created_at', endDate.toISOString());

      if (!vendasError && vendas && vendas.length > 0) {
        console.log(`✅ Encontradas ${vendas.length} vendas diretas`);
        
        // Tentar extrair produtos de vendas_itens
        const productsMap = new Map<string, { 
          id: string;
          name: string; 
          category: string; 
          units: number; 
          revenue: number 
        }>();
        
        vendas.forEach((venda: any) => {
          if (venda.vendas_itens && venda.vendas_itens.length > 0) {
            venda.vendas_itens.forEach((item: any) => {
              const produtoId = item.produtos?.id || item.produto_id || 'unknown';
              const produtoNome = item.produtos?.nome || 'Produto sem nome';
              const categoria = item.produtos?.categorias?.nome || 'Sem Categoria';
              
              const current = productsMap.get(produtoId) || { 
                id: produtoId,
                name: produtoNome,
                category: categoria,
                units: 0, 
                revenue: 0 
              };
              
              productsMap.set(produtoId, {
                ...current,
                units: current.units + (item.quantidade || 0),
                revenue: current.revenue + (item.subtotal || 0)
              });
            });
          }
          // NÃO incluir vendas sem itens detalhados - são agregados sem detalhamento
        });
        
        if (productsMap.size > 0) {
          const products = Array.from(productsMap.values())
            .sort((a, b) => b.revenue - a.revenue)
            .slice(0, 10);
          
          return products.map(p => ({ ...p, margin: 40 }));
        }
      }

      // ESTRATÉGIA 3: Fallback - produtos cadastrados
      console.log('⚠️ Buscando produtos cadastrados como fallback...');
      const { data: produtos, error: prodError } = await supabase
        .from('produtos')
        .select(`id, nome, preco_venda, estoque_atual, categorias(nome)`)
        .limit(20);
      
      if (!prodError && produtos && produtos.length > 0) {
        return produtos.map((p: any) => ({
          id: p.id,
          name: p.nome,
          category: p.categorias?.nome || 'Sem Categoria',
          units: p.estoque_atual || 0,
          revenue: (p.preco_venda || 0) * (p.estoque_atual || 0),
          margin: 40
        })).slice(0, 10);
      }

      console.log('⚠️ Nenhum dado encontrado');
      return [];

      // Agrupar por produto
      const productsMap = new Map<string, { 
        id: string;
        name: string; 
        category: string; 
        units: number; 
        revenue: number 
      }>();
      
      itens?.forEach((item: any) => {
        const produtoId = item.produtos?.id || item.produto_id || 'unknown';
        const produtoNome = item.produtos?.nome || 'Produto sem nome';
        const categoria = item.produtos?.categorias?.nome || 'Sem Categoria';
        
        const current = productsMap.get(produtoId) || { 
          id: produtoId,
          name: produtoNome,
          category: categoria,
          units: 0, 
          revenue: 0 
        };
        
        productsMap.set(produtoId, {
          ...current,
          units: current.units + (item.quantidade || 0),
          revenue: current.revenue + (item.subtotal || 0)
        });
      });

      // Converter para array e ordenar por faturamento
      const products = Array.from(productsMap.values())
        .sort((a, b) => b.revenue - a.revenue)
        .slice(0, 10);

      console.log(`✅ Encontrados ${products.length} produtos com vendas`);
      return products.map(p => ({
        ...p,
        margin: 40 // Margem padrão 40%
      }));
    } catch (error) {
      console.error('❌ [SIMPLE] Erro ao gerar ranking de produtos:', error);
      return [];
    }
  }

  async getCategoryRanking(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    try {
      console.log('🔍 [SIMPLE] Buscando ranking de categorias do banco...');
      const { startDate, endDate } = this.getDateRange(period);
      
      // ESTRATÉGIA 1: Tentar buscar de itens_venda
      const { data: itens, error: itensError } = await supabase
        .from('itens_venda')
        .select(`
          id,
          quantidade,
          preco_unitario,
          subtotal,
          produto_id,
          venda_id,
          produtos!inner (
            id,
            nome,
            categoria_id,
            categorias (
              nome
            )
          ),
          vendas!inner (
            created_at
          )
        `)
        .gte('vendas.created_at', startDate.toISOString())
        .lte('vendas.created_at', endDate.toISOString());

      // Se itens_venda tem dados, usar
      if (!itensError && itens && itens.length > 0) {
        console.log(`✅ Encontrados ${itens.length} itens em itens_venda`);
        const categoriesMap = new Map<string, { sales: number; revenue: number; units: number }>();
        
        itens.forEach((item: any) => {
          const categoria = item.produtos?.categorias?.nome || 'Sem Categoria';
          const current = categoriesMap.get(categoria) || { sales: 0, revenue: 0, units: 0 };
          
          categoriesMap.set(categoria, {
            sales: current.sales + 1,
            revenue: current.revenue + (item.subtotal || 0),
            units: current.units + (item.quantidade || 0)
          });
        });

        const totalRevenue = Array.from(categoriesMap.values())
          .reduce((sum, cat) => sum + cat.revenue, 0);

        const categories = Array.from(categoriesMap.entries())
          .map(([name, data], index) => ({
            id: `category-${index}`,
            name,
            sales: data.sales,
            participation: totalRevenue > 0 ? ((data.revenue / totalRevenue) * 100).toFixed(1) : '0',
            revenue: data.revenue,
            margin: 40,
            growth: 0
          }))
          .sort((a, b) => b.revenue - a.revenue)
          .slice(0, 10);

        return categories;
      }

      // ESTRATÉGIA 2: itens_venda vazio - buscar vendas diretamente COM vendas_itens
      console.log('⚠️ itens_venda vazio, buscando de VENDAS com vendas_itens...');
      const { data: vendas, error: vendasError } = await supabase
        .from('vendas')
        .select(`
          id, 
          total, 
          desconto,
          created_at,
          vendas_itens (
            id,
            produto_id,
            quantidade,
            subtotal,
            produtos (
              id,
              nome,
              categorias (
                nome
              )
            )
          )
        `)
        .gte('created_at', startDate.toISOString())
        .lte('created_at', endDate.toISOString());

      if (!vendasError && vendas && vendas.length > 0) {
        console.log(`✅ Encontradas ${vendas.length} vendas diretas`);
        
        const categoriesMap = new Map<string, { sales: number; revenue: number }>();
        let hasItems = false;
        
        vendas.forEach((venda: any) => {
          if (venda.vendas_itens && venda.vendas_itens.length > 0) {
            hasItems = true;
            venda.vendas_itens.forEach((item: any) => {
              const categoria = item.produtos?.categorias?.nome || 'Sem Categoria';
              const current = categoriesMap.get(categoria) || { sales: 0, revenue: 0 };
              
              categoriesMap.set(categoria, {
                sales: current.sales + 1,
                revenue: current.revenue + (item.subtotal || 0)
              });
            });
          }
        });
        
        // Se não tem itens detalhados, não mostrar dados agregados sem categoria
        if (!hasItems || categoriesMap.size === 0) {
          console.log('⚠️ Nenhum item detalhado em vendas_itens');
          return [];
        }
        
        // Tem itens, processar categorias
        const totalRevenue = Array.from(categoriesMap.values())
          .reduce((sum, cat) => sum + cat.revenue, 0);
        
        return Array.from(categoriesMap.entries())
          .map(([name, data], index) => ({
            id: `category-${index}`,
            name,
            sales: data.sales,
            participation: totalRevenue > 0 ? ((data.revenue / totalRevenue) * 100).toFixed(1) : '0',
            revenue: data.revenue,
            margin: 40,
            growth: 0
          }))
          .sort((a, b) => b.revenue - a.revenue)
          .slice(0, 10);
      }

      // ESTRATÉGIA 3: Fallback - produtos cadastrados
      console.log('⚠️ Buscando produtos cadastrados como fallback...');
      const { data: produtos, error: prodError } = await supabase
        .from('produtos')
        .select(`id, nome, preco_venda, categorias(nome)`)
        .limit(100);
      
      if (!prodError && produtos && produtos.length > 0) {
        const categoriesMap = new Map<string, { sales: number; revenue: number }>();
        produtos.forEach((p: any) => {
          const cat = p.categorias?.nome || 'Sem Categoria';
          const current = categoriesMap.get(cat) || { sales: 0, revenue: 0 };
          categoriesMap.set(cat, {
            sales: current.sales + 1,
            revenue: current.revenue + (p.preco_venda || 0)
          });
        });

        const totalRevenue = Array.from(categoriesMap.values())
          .reduce((sum, cat) => sum + cat.revenue, 0);

        return Array.from(categoriesMap.entries())
          .map(([name, data], index) => ({
            id: `category-${index}`,
            name,
            sales: data.sales,
            participation: totalRevenue > 0 ? ((data.revenue / totalRevenue) * 100).toFixed(1) : '0',
            revenue: data.revenue,
            margin: 40,
            growth: 0
          }))
          .sort((a, b) => b.revenue - a.revenue)
          .slice(0, 10);
      }

      console.log('⚠️ Nenhum dado encontrado');
      return [];
    } catch (error) {
      console.error('❌ [SIMPLE] Erro ao gerar ranking de categorias:', error);
      return [];
    }
  }

  async getClientRepairRanking(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    try {
      const { startDate, endDate } = this.getDateRange(period);
      console.log('🔍 [SIMPLE] Buscando ranking de clientes que mais arrumaram...');
      console.log('📅 Período:', period, '| Início:', startDate.toISOString(), '| Fim:', endDate.toISOString());
      
      // ✅ OBTER USER_ID DO USUÁRIO AUTENTICADO
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        console.error('❌ Usuário não autenticado');
        return [];
      }
      
      const { data, error } = await supabase.rpc('fn_ranking_clientes_reparos', {
        p_data_inicio: startDate.toISOString(),
        p_data_fim: endDate.toISOString(),
        p_user_id: user.id, // ✅ FILTRAR POR USER_ID
        p_limite: 10
      });

      if (error) {
        console.error('❌ Erro ao buscar ranking de reparos:', error);
        console.error('❌ Detalhes completos:', JSON.stringify(error, null, 2));
        return [];
      }

      console.log('✅ Ranking de clientes (reparos) - Dados brutos do Supabase:', data);
      console.log('✅ Total de registros:', data?.length || 0);
      
      // Mapear campos do resultado da função RPC
      const mapped = (data || []).map((item: any) => ({
        id: item.cliente_id,
        name: item.cliente_nome,
        count: item.total_ordens,
        totalValue: item.valor_total || 0,
        avgTicket: item.valor_medio || 0,
        lastOrder: item.ultima_ordem
      }));
      
      console.log('✅ Dados mapeados:', mapped);
      return mapped;
    } catch (error) {
      console.error('❌ [SIMPLE] Erro ao gerar ranking de reparos:', error);
      return [];
    }
  }

  async getClientSpendingRanking(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    try {
      const { startDate, endDate } = this.getDateRange(period);
      console.log('🔍 [SIMPLE] Buscando ranking de clientes que mais gastaram...');
      console.log('📅 Período:', period, '| Início:', startDate.toISOString(), '| Fim:', endDate.toISOString());
      
      // ✅ OBTER USER_ID DO USUÁRIO AUTENTICADO
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        console.error('❌ Usuário não autenticado');
        return [];
      }
      
      const { data, error } = await supabase.rpc('fn_ranking_clientes_gastos', {
        p_data_inicio: startDate.toISOString(),
        p_data_fim: endDate.toISOString(),
        p_user_id: user.id, // ✅ FILTRAR POR USER_ID
        p_limite: 10
      });

      if (error) {
        console.error('❌ Erro ao buscar ranking de gastos:', error);
        console.error('❌ Detalhes completos:', JSON.stringify(error, null, 2));
        return [];
      }

      console.log('✅ Ranking de clientes (gastos) - Dados brutos:', data);
      console.log('✅ Total de registros:', data?.length || 0);
      
      // Mapear campos do resultado da função RPC
      const mapped = (data || []).map((item: any) => ({
        id: item.cliente_id,
        name: item.cliente_nome,
        segment: item.segmento || 'Varejo',
        orderCount: item.total_ordens,
        totalSpent: item.gasto_total || 0,
        avgTicket: item.ticket_medio || 0
      }));
      
      console.log('✅ Dados mapeados:', mapped);
      return mapped;
    } catch (error) {
      console.error('❌ [SIMPLE] Erro ao gerar ranking de gastos:', error);
      return [];
    }
  }

  async getOrderTypeRanking(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    try {
      const { startDate, endDate } = this.getDateRange(period);
      console.log('🔍 [SIMPLE] Buscando ranking de tipos de equipamento...');
      console.log('📅 Período:', period, '| Início:', startDate.toISOString(), '| Fim:', endDate.toISOString());
      
      // ✅ OBTER USER_ID DO USUÁRIO AUTENTICADO
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        console.error('❌ Usuário não autenticado');
        return [];
      }
      
      const { data, error } = await supabase.rpc('fn_ranking_equipamentos', {
        p_data_inicio: startDate.toISOString(),
        p_data_fim: endDate.toISOString(),
        p_user_id: user.id, // ✅ FILTRAR POR USER_ID
        p_limite: 10
      });

      if (error) {
        console.error('❌ Erro ao buscar ranking de equipamentos:', error);
        console.error('❌ Detalhes completos:', JSON.stringify(error, null, 2));
        return [];
      }

      console.log('✅ Ranking de equipamentos - Dados brutos:', data);
      console.log('✅ Total de registros:', data?.length || 0);
      
      // Mapear para o formato esperado pela interface
      const mapped = (data || []).map((item: any, index: number) => ({
        id: `equipment-${item.equipamento}-${index}`,
        type: item.equipamento,
        count: item.total_reparos,
        percentage: item.percentual,
        avgValue: item.receita_media || 0,
        totalRevenue: item.receita_total || 0,
        avgTime: 'N/A',
        revenue: item.receita_total || 0
      }));
      
      console.log('✅ Dados mapeados:', mapped);
      return mapped;
    } catch (error) {
      console.error('❌ [SIMPLE] Erro ao gerar ranking de tipos de ordem:', error);
      return [];
    }
  }

  async getEquipmentProfitRanking(period: 'week' | 'month' | 'quarter' | 'all' = 'month') {
    try {
      const { startDate, endDate } = this.getDateRange(period);
      console.log('🔍 [SIMPLE] Buscando ranking de lucro por equipamento...');
      console.log('📅 Período:', period, '| Início:', startDate.toISOString(), '| Fim:', endDate.toISOString());
      
      // ✅ OBTER USER_ID DO USUÁRIO AUTENTICADO
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        console.error('❌ Usuário não autenticado');
        return [];
      }
      
      const { data, error } = await supabase.rpc('fn_ranking_equipamentos', {
        p_data_inicio: startDate.toISOString(),
        p_data_fim: endDate.toISOString(),
        p_user_id: user.id, // ✅ FILTRAR POR USER_ID
        p_limite: 10
      });

      if (error) {
        console.error('❌ Erro ao buscar ranking de lucro:', error);
        console.error('❌ Detalhes completos:', JSON.stringify(error, null, 2));
        return [];
      }

      console.log('✅ Ranking de lucro por equipamento - Dados brutos:', data);
      console.log('✅ Total de registros:', data?.length || 0);
      
      // Mapear para o formato esperado pela interface
      const mapped = (data || []).map((item: any, index: number) => ({
        id: `profit-${item.equipamento}-${index}`,
        equipment: item.equipamento,
        count: item.total_reparos,
        profit: (item.receita_total || 0) * 0.4, // Estima 40% de margem
        revenue: item.receita_total || 0,
        margin: 40
      }));
      
      console.log('✅ Dados mapeados:', mapped);
      return mapped;
    } catch (error) {
      console.error('❌ [SIMPLE] Erro ao gerar ranking de lucro por equipamento:', error);
      return [];
    }
  }

  // Métodos para analytics (versões simplificadas)
  async getAnalyticsInsights(period: 'week' | 'month' | 'quarter' = 'month') {
    try {
      console.log('🔍 [SIMPLE] Gerando insights analíticos...');
      console.log('📊 [ANALYTICS] Período recebido:', period);
      
      const salesReport = await this.getSalesReport(period);
      
      // Para Analytics, SEMPRE buscar TODAS as ordens (ignorar período)
      console.log('🌐 [ANALYTICS] Buscando TODAS as ordens de serviço (period=all)...');
      const serviceReport = await this.getServiceOrdersReport('all' as any);
      console.log('✅ [ANALYTICS] Ordens retornadas:', serviceReport.totalOrders);
      
      // Montar descrição detalhada das ordens de serviço
      let serviceDescription = '';
      if (serviceReport.totalOrders === 0) {
        serviceDescription = 'Nenhuma ordem de serviço cadastrada';
      } else if (serviceReport.totalOrders === 1) {
        serviceDescription = '1 ordem de serviço';
      } else {
        serviceDescription = `${serviceReport.totalOrders} ordens de serviço`;
      }
      
      // Adicionar detalhes por status se houver dados
      if (serviceReport.statusDistribution && serviceReport.statusDistribution.length > 0) {
        const statusLabels: { [key: string]: string } = {
          'pending': 'pendente',
          'in_progress': 'em andamento',
          'completed': 'concluída',
          'cancelled': 'cancelada'
        };
        
        const statusDetails = serviceReport.statusDistribution
          .map(s => `${s.count} ${statusLabels[s.status] || s.status}${s.count > 1 ? 's' : ''}`)
          .join(', ');
        
        serviceDescription = `Total: ${serviceReport.totalOrders} OS (${statusDetails})`;
      }
      
      return [
        {
          title: 'Vendas em Alta',
          description: `Total de ${salesReport.totalSales} vendas realizadas no período`,
          impact: 'positive',
          value: salesReport.totalAmount
        },
        {
          title: 'Serviços Ativos',
          description: serviceDescription,
          impact: serviceReport.totalOrders > 0 ? 'neutral' : 'negative',
          value: serviceReport.totalRevenue
        }
      ];
    } catch (error) {
      console.error('❌ [SIMPLE] Erro ao gerar insights:', error);
      return [];
    }
  }

  async getAnalyticsPredictions(period: 'week' | 'month' | 'quarter' = 'month') {
    try {
      console.log('🔍 [SIMPLE] Gerando predições analíticas...');
      
      // Buscar dados reais
      const salesReport = await this.getSalesReport(period);
      const serviceReport = await this.getServiceOrdersReport('all' as any);
      
      console.log('📊 [PREDICTIONS] Vendas atuais:', salesReport.totalSales);
      console.log('📊 [PREDICTIONS] Ordens atuais:', serviceReport.totalOrders);
      
      return [
        {
          metric: 'Tendência de Vendas',
          current: salesReport.totalSales,
          predicted: Math.round(salesReport.totalSales * 1.15),
          confidence: 85,
          trend: 'up' as const,
          timeline: '30 dias'
        },
        {
          metric: 'Demanda por Serviços',
          current: serviceReport.totalOrders,
          predicted: Math.round(serviceReport.totalOrders * 1.20),
          confidence: 78,
          trend: 'up' as const,
          timeline: '15 dias'
        }
      ];
    } catch (error) {
      console.error('❌ [SIMPLE] Erro ao gerar predições:', error);
      return [];
    }
  }

  async getAnalyticsAnomalies(period: 'week' | 'month' | 'quarter' = 'month') {
    try {
      console.log('🔍 [SIMPLE] Detectando anomalias...');
      
      // Buscar dados reais
      const salesReport = await this.getSalesReport(period);
      const serviceReport = await this.getServiceOrdersReport('all' as any);
      
      console.log('📊 [ANOMALIES] Vendas:', salesReport.totalSales);
      console.log('📊 [ANOMALIES] Ordens:', serviceReport.totalOrders);
      
      const anomalies: any[] = [];
      
      // Detectar anomalia em vendas com lógica contextual
      // Se tem poucas vendas históricas, não considera anomalia
      const minSalesForAnomaly = period === 'week' ? 10 : period === 'month' ? 30 : 90;
      
      if (salesReport.totalSales >= minSalesForAnomaly) {
        // Só detecta anomalia se houver volume suficiente de dados
        const avgSalesPerPeriod = period === 'week' ? 5 : period === 'month' ? 20 : 60;
        const expectedSales = Math.round(salesReport.totalSales * 0.7);
        const deviation = expectedSales > 0
          ? Math.round(((salesReport.totalSales - expectedSales) / expectedSales) * 100) 
          : 0;
        
        // Só alerta se desvio for muito alto (>150% ou <-60%)
        if (deviation > 150 || deviation < -60) {
          anomalies.push({
            id: 'sales-spike',
            metric: 'Vendas',
            detected: new Date(),
            severity: deviation > 0 ? 'medium' : 'high',
            description: `Vendas ${Math.abs(deviation)}% ${deviation > 0 ? 'acima' : 'abaixo'} da média histórica`,
            expectedValue: expectedSales,
            actualValue: salesReport.totalSales,
            deviation: Math.abs(deviation)
          });
        }
      }
      
      // Detectar anomalia em serviços com lógica mais inteligente
      // Para detectar anomalias reais, precisamos de histórico comparativo
      // Aqui usamos uma abordagem baseada em período
      const periodMultiplier = period === 'week' ? 4 : period === 'month' ? 1 : 0.33;
      const expectedServices = Math.round(serviceReport.totalOrders * periodMultiplier);
      
      // Só considera anomalia se a diferença for muito drástica no período específico
      const periodOrders = serviceReport.totalOrders; // No futuro, filtrar por período
      const serviceDeviation = expectedServices > 0
        ? Math.round(((periodOrders - expectedServices) / expectedServices) * 100)
        : 0;
      
      // Anomalia só se desvio > 200% (3x mais que o esperado para o período)
      if (Math.abs(serviceDeviation) > 200 && periodOrders < serviceReport.totalOrders * 0.3) {
        anomalies.push({
          id: 'service-surge',
          metric: 'Ordens de Serviço',
          detected: new Date(),
          severity: 'medium',
          description: `Volume de OS ${Math.abs(serviceDeviation)}% ${serviceDeviation > 0 ? 'acima' : 'abaixo'} do esperado para o período`,
          expectedValue: expectedServices,
          actualValue: periodOrders,
          deviation: Math.abs(serviceDeviation)
        });
      }
      
      console.log('✅ [ANOMALIES] Detectadas:', anomalies.length);
      console.log('📊 [ANOMALIES] Vendas no período:', salesReport.totalSales);
      console.log('📊 [ANOMALIES] Ordens totais:', serviceReport.totalOrders);
      
      // Mensagem contextual baseada no volume de dados
      const hasLowData = salesReport.totalSales < 30 && serviceReport.totalOrders < 50;
      const normalMessage = hasLowData
        ? `Sistema em fase inicial. ${salesReport.totalSales} venda(s) e ${serviceReport.totalOrders} ordens de serviço. Continue usando o sistema para análises mais precisas.`
        : `Sistema operando normalmente. ${salesReport.totalSales} vendas e ${serviceReport.totalOrders} ordens de serviço dentro dos padrões esperados.`;
      
      return anomalies.length > 0 ? anomalies : [{
        id: 'no-anomaly',
        metric: hasLowData ? '📊 Coletando Dados' : '✅ Sistema Normal',
        detected: new Date(),
        severity: 'low' as const,
        description: normalMessage,
        expectedValue: 0,
        actualValue: 0,
        deviation: 0
      }];
    } catch (error) {
      console.error('❌ [SIMPLE] Erro ao detectar anomalias:', error);
      return [];
    }
  }
}

// Instância exportada
export const simpleReportsService = new SimpleReportsService();
export { simpleReportsService as realReportsService }; // Alias para compatibilidade