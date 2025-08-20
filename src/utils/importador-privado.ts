import { supabase } from '../lib/supabase';

/**
 * IMPORTAÇÃO AUTOMÁTICA COM PRIVACIDADE TOTAL
 * - Dados ficam vinculados ao usuário logado
 * - RLS garante isolamento completo
 * - Backup original permanece intacto
 */

interface ResultadoImportacao {
  sucesso: boolean;
  total: number;
  detalhes: Record<string, number>;
  erros: string[];
  avisos?: string[];
  tempoExecucao?: string;
}

export class ImportadorPrivado {
  private userId: string;

  constructor(userId: string) {
    if (!userId) {
      throw new Error('User ID é obrigatório para importação privada');
    }
    this.userId = userId;
    console.log('🔒 Importador iniciado para usuário:', userId);
  }

  /**
   * IMPORTA BACKUP COMPLETO COM ISOLAMENTO POR USUÁRIO
   */
  async importarBackup(backupData: any): Promise<ResultadoImportacao> {
    const inicio = Date.now();
    
    const resultado: ResultadoImportacao = {
      sucesso: false,
      total: 0,
      detalhes: {},
      erros: [],
      avisos: []
    };

    try {
      console.log('🚀 Iniciando importação PRIVADA do backup...');
      console.log('🔍 DEBUG: Estrutura completa do backup:', JSON.stringify(backupData, null, 2).substring(0, 1000));
      
      // Validar estrutura
      if (!backupData?.data) {
        console.error('❌ Estrutura do backup inválida:', backupData);
        throw new Error('Estrutura do backup inválida - campo "data" não encontrado');
      }

      console.log('✅ Estrutura do backup validada');
      console.log('📊 Dados disponíveis:', {
        clients: backupData.data.clients?.length || 0,
        categories: backupData.data.categories?.length || 0,
        products: backupData.data.products?.length || 0,
        service_orders: backupData.data.service_orders?.length || 0,
        establishments: backupData.data.establishments?.length || 0,
        service_parts: backupData.data.service_parts?.length || 0,
        sales: backupData.data.sales?.length || 0
      });

      // 1. CLIENTES (prioridade alta) - usar tabela 'clientes' 
      if (backupData.data.clients?.length > 0) {
        const clientesPrivados = backupData.data.clients.map((cliente: any) => ({
          ...cliente,
          user_id: this.userId, // VINCULA AO USUÁRIO
          id: cliente.id || crypto.randomUUID(),
          name: cliente.name || cliente.nome || 'Cliente',
          nome: cliente.nome || cliente.name || 'Cliente', // Duplicar para compatibilidade
          email: cliente.email || null,
          phone: cliente.phone || cliente.telefone || null,
          telefone: cliente.telefone || cliente.phone || null, // Duplicar para compatibilidade
          address: cliente.address || cliente.endereco || null,
          endereco: cliente.endereco || cliente.address || null, // Duplicar para compatibilidade
          cpf_cnpj: cliente.cpf_cnpj || cliente.document || null,
          city: cliente.city || null,
          state: cliente.state || null,
          zip_code: cliente.zip_code || null,
          birth_date: cliente.birth_date || null,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }));

        await this.importarTabela('clientes', clientesPrivados);
        resultado.detalhes.clientes = clientesPrivados.length;
      }

      // 2. CATEGORIAS (antes dos produtos)
      if (backupData.data.categories?.length > 0) {
        const categoriasPrivadas = backupData.data.categories.map((cat: any) => ({
          ...cat,
          user_id: this.userId, // VINCULA AO USUÁRIO
          id: cat.id || crypto.randomUUID(),
          name: cat.name || cat.nome || 'Categoria',
          description: cat.description || cat.descricao || null,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }));

        await this.importarTabela('categories', categoriasPrivadas);
        resultado.detalhes.categories = categoriasPrivadas.length;
      }

      // 3. PRODUTOS (depende das categorias)
      if (backupData.data.products?.length > 0) {
        const produtosPrivados = backupData.data.products.map((produto: any) => ({
          ...produto,
          user_id: this.userId, // VINCULA AO USUÁRIO
          id: produto.id || crypto.randomUUID(),
          name: produto.name || produto.nome || 'Produto',
          price: Number(produto.price || produto.sale_price || produto.preco || 0),
          sale_price: Number(produto.sale_price || produto.price || produto.preco || 0),
          cost_price: Number(produto.cost_price || produto.custo || 0),
          stock: Number(produto.stock || produto.current_stock || produto.estoque || 0),
          current_stock: Number(produto.current_stock || produto.stock || produto.estoque || 0),
          minimum_stock: Number(produto.minimum_stock || produto.min_stock || produto.estoque_minimo || 0),
          unit_measure: produto.unit_measure || produto.unit || produto.unidade || 'un',
          barcode: produto.barcode || produto.codigo_barras || null,
          category_id: produto.category_id || null,
          active: produto.active !== false,
          expiry_date: produto.expiry_date || null,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }));

        await this.importarTabela('products', produtosPrivados);
        resultado.detalhes.products = produtosPrivados.length;
      }

      // 4. ORDENS DE SERVIÇO (independente)
      if (backupData.data.service_orders?.length > 0) {
        const ordensPrivadas = backupData.data.service_orders.map((ordem: any) => ({
          ...ordem,
          user_id: this.userId, // VINCULA AO USUÁRIO
          id: ordem.id || crypto.randomUUID(),
          client_id: ordem.client_id || null,
          client_name: ordem.client_name || null,
          equipment: ordem.equipment || ordem.device_name || ordem.equipamento || 'Equipamento',
          device_name: ordem.device_name || ordem.equipment || ordem.equipamento || 'Equipamento',
          device_model: ordem.device_model || ordem.modelo || null,
          defect: ordem.defect || ordem.defeito || 'Defeito',
          status: ordem.status || 'Aguardando',
          total: Number(ordem.total || ordem.total_amount || ordem.valor_total || 0),
          total_amount: Number(ordem.total_amount || ordem.total || ordem.valor_total || 0),
          labor_cost: Number(ordem.labor_cost || ordem.mao_obra || 0),
          payment_method: ordem.payment_method || ordem.forma_pagamento || null,
          warranty_days: Number(ordem.warranty_days || ordem.garantia_dias || 0),
          opening_date: ordem.opening_date || ordem.data_abertura || null,
          closing_date: ordem.closing_date || ordem.data_fechamento || null,
          observations: ordem.observations || ordem.observacoes || null,
          created_at: ordem.created_at || new Date().toISOString(),
          updated_at: new Date().toISOString()
        }));

        await this.importarTabela('service_orders', ordensPrivadas);
        resultado.detalhes.service_orders = ordensPrivadas.length;
      }

      // 5. ESTABELECIMENTOS (opcional)
      if (backupData.data.establishments?.length > 0) {
        const estabelecimentosPrivados = backupData.data.establishments.map((est: any) => ({
          ...est,
          user_id: this.userId, // VINCULA AO USUÁRIO
          id: est.id || crypto.randomUUID(),
          name: est.name || est.nome || 'Minha Empresa',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }));

        await this.importarTabela('establishments', estabelecimentosPrivados);
        resultado.detalhes.establishments = estabelecimentosPrivados.length;
      }

      // 6. PEÇAS DE SERVIÇO (opcional - pular se tabela não existir)
      if (backupData.data.service_parts?.length > 0) {
        try {
          console.log('🔍 DEBUG: Dados originais service_parts:', JSON.stringify(backupData.data.service_parts.slice(0, 2), null, 2));
          
          const pecasPrivadas = backupData.data.service_parts.map((peca: any) => ({
            ...peca,
            user_id: this.userId, // VINCULA AO USUÁRIO
            id: peca.id || crypto.randomUUID(),
            service_order_id: peca.service_order_id || null,
            name: peca.name || peca.nome || 'Peça',
            quantity: Number(peca.quantity || peca.quantidade || 1),
            price: Number(peca.price || peca.preco || 0),
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          }));

          console.log('🔍 DEBUG: Dados transformados service_parts:', JSON.stringify(pecasPrivadas.slice(0, 2), null, 2));

          await this.importarTabela('service_parts', pecasPrivadas);
          resultado.detalhes.service_parts = pecasPrivadas.length;
        } catch (error: any) {
          console.error('🚨 DEBUG: Erro completo service_parts:', error);
          console.error('🚨 DEBUG: Stack trace:', error.stack);
          
          if (error.message?.includes('TABELA_NAO_EXISTE')) {
            console.warn('⚠️ Tabela service_parts não existe no banco - ignorando');
            resultado.avisos!.push('service_parts: Tabela não encontrada (ignorado)');
          } else {
            console.error('❌ Erro ao importar service_parts:', error);
            resultado.erros.push(`service_parts: ${error.message || 'Erro desconhecido'}`);
          }
        }
      }

      // 7. VENDAS (opcional)
      if (backupData.data.sales?.length > 0) {
        try {
          const vendasPrivadas = backupData.data.sales.map((venda: any) => ({
            ...venda,
            user_id: this.userId, // VINCULA AO USUÁRIO
            id: venda.id || crypto.randomUUID(),
            total: Number(venda.total || venda.valor_total || 0),
            created_at: venda.created_at || new Date().toISOString(),
            updated_at: new Date().toISOString()
          }));

          await this.importarTabela('sales', vendasPrivadas);
          resultado.detalhes.sales = vendasPrivadas.length;
        } catch (error: any) {
          if (error.message?.includes('TABELA_NAO_EXISTE')) {
            console.warn('⚠️ Tabela sales não existe no banco - ignorando');
            resultado.avisos!.push('sales: Tabela não encontrada (ignorado)');
          } else {
            console.error('❌ Erro ao importar sales:', error);
            resultado.erros.push(`sales: ${error.message}`);
          }
        }
      }

      // Calcular totais
      resultado.total = Object.values(resultado.detalhes).reduce((sum, count) => sum + count, 0);
      resultado.sucesso = resultado.total > 0;
      
      const tempoMs = Date.now() - inicio;
      resultado.tempoExecucao = `${(tempoMs / 1000).toFixed(2)}s`;
      
      console.log('✅ Importação PRIVADA concluída:', resultado);
      
    } catch (error: any) {
      console.error('❌ Erro na importação privada:', error);
      resultado.erros.push(error.message || 'Erro desconhecido');
      resultado.sucesso = false;
    }

    return resultado;
  }

  /**
   * Importa uma tabela específica com verificação de RLS
   */
  private async importarTabela(nomeTabela: string, dados: any[]): Promise<void> {
    if (dados.length === 0) return;

    console.log(`🔧 Importando ${nomeTabela}: ${dados.length} registros`);

    const loteSize = 100; // Inserir em lotes para performance
    
    for (let i = 0; i < dados.length; i += loteSize) {
      const lote = dados.slice(i, i + loteSize);
      
      // Garantir que TODOS os registros tenham user_id
      const loteSeguro = lote.map(item => ({
        ...item,
        user_id: this.userId // FORÇA o user_id para isolamento
      }));

      try {
        const { error } = await supabase
          .from(nomeTabela)
          .upsert(loteSeguro, { onConflict: 'id' });

        if (error) {
          // Detectar se tabela não existe
          if (error.code === '42P01' || (error.message?.includes('relation') && error.message?.includes('does not exist'))) {
            throw new Error(`TABELA_NAO_EXISTE: ${nomeTabela} não existe no banco de dados`);
          }
          
          console.error(`❌ Erro detalhado em ${nomeTabela}:`, {
            message: error.message,
            details: error.details,
            hint: error.hint,
            code: error.code,
            amostraLote: loteSeguro.slice(0, 2) // Mostrar os primeiros 2 registros
          });
          
          const errorMessage = error.message || 'Erro desconhecido';
          const errorCode = error.code || 'sem código';
          throw new Error(`${errorMessage} (${errorCode})`);
        }
      } catch (supabaseError: any) {
        // Verificar se é erro de tabela inexistente
        if (supabaseError.message?.includes('TABELA_NAO_EXISTE')) {
          throw supabaseError; // Repassar erro específico
        }
        
        console.error(`Erro no lote ${i / loteSize + 1} de ${nomeTabela}:`, supabaseError);
        throw supabaseError;
      }
    }

    console.log(`✅ ${nomeTabela}: ${dados.length} registros importados com isolamento`);
  }

  /**
   * Lista dados importados do usuário atual (teste de RLS)
   */
  async verificarImportacao(): Promise<Record<string, number>> {
    const contadores: Record<string, number> = {};
    
    const tabelas = ['clients', 'categories', 'products', 'service_orders', 'establishments'];
    
    for (const tabela of tabelas) {
      try {
        const { data, error } = await supabase
          .from(tabela)
          .select('id')
          .eq('user_id', this.userId);
        
        if (!error && data) {
          contadores[tabela] = data.length;
        }
      } catch (error) {
        console.warn(`⚠️ Erro ao verificar ${tabela}:`, error);
      }
    }
    
    return contadores;
  }
}
