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
      
      // Validar estrutura
      if (!backupData?.data) {
        throw new Error('Estrutura do backup inválida');
      }

      // 1. CLIENTES (prioridade alta)
      if (backupData.data.clients?.length > 0) {
        const clientesPrivados = backupData.data.clients.map((cliente: any) => ({
          ...cliente,
          user_id: this.userId, // VINCULA AO USUÁRIO
          id: cliente.id || crypto.randomUUID(),
          name: cliente.name || cliente.nome || 'Cliente',
          email: cliente.email || null,
          phone: cliente.phone || cliente.telefone || null,
          address: cliente.address || cliente.endereco || null,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }));

        await this.importarTabela('clients', clientesPrivados);
        resultado.detalhes.clients = clientesPrivados.length;
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
          price: Number(produto.price || produto.preco || 0),
          stock: Number(produto.stock || produto.estoque || 0),
          barcode: produto.barcode || produto.codigo_barras || null,
          category_id: produto.category_id || null,
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
          equipment: ordem.equipment || ordem.equipamento || 'Equipamento',
          defect: ordem.defect || ordem.defeito || 'Defeito',
          status: ordem.status || 'Aguardando',
          total: Number(ordem.total || ordem.valor_total || 0),
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

          await this.importarTabela('service_parts', pecasPrivadas);
          resultado.detalhes.service_parts = pecasPrivadas.length;
        } catch (error: any) {
          if (error.message?.includes('TABELA_NAO_EXISTE')) {
            console.warn('⚠️ Tabela service_parts não existe no banco - ignorando');
            resultado.avisos!.push('service_parts: Tabela não encontrada (ignorado)');
          } else {
            console.error('❌ Erro ao importar service_parts:', error);
            resultado.erros.push(`service_parts: ${error.message}`);
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
          
          console.error(`Erro detalhado em ${nomeTabela}:`, {
            message: error.message,
            details: error.details,
            hint: error.hint,
            code: error.code,
            amostraLote: loteSeguro.slice(0, 2) // Mostrar os primeiros 2 registros
          });
          throw new Error(`${error.message} (${error.code || 'sem código'})`);
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
