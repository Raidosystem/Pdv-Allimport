import { supabase } from '../lib/supabase'
import type { Product, Category } from '../types/product'

/**
 * 🛍️ SERVICE DE PRODUTOS
 * 
 * Centraliza toda a lógica de negócio relacionada a produtos.
 * Separa responsabilidades: Service faz queries, Hooks gerenciam estado.
 */

export class ProductService {
  /**
   * Carregar todos os produtos do usuário autenticado
   */
  static async loadProducts(): Promise<Product[]> {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      throw new Error('Usuário não autenticado')
    }

    const { data, error } = await supabase
      .from('produtos')
      .select('*')
      .eq('user_id', user.id)
      .order('criado_em', { ascending: false })

    if (error) throw error
    return data || []
  }

  /**
   * Buscar produto por ID
   */
  static async getProductById(productId: string): Promise<Product | null> {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      throw new Error('Usuário não autenticado')
    }

    const { data, error } = await supabase
      .from('produtos')
      .select('*')
      .eq('id', productId)
      .eq('user_id', user.id)
      .maybeSingle()

    if (error) throw error
    return data
  }

  /**
   * Criar novo produto
   */
  static async createProduct(productData: Omit<Product, 'id' | 'criado_em' | 'atualizado_em'>): Promise<Product> {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      throw new Error('Usuário não autenticado')
    }

    const { data, error } = await supabase
      .from('produtos')
      .insert({
        ...productData,
        user_id: user.id,
        criado_em: new Date().toISOString(),
        atualizado_em: new Date().toISOString()
      })
      .select()
      .single()

    if (error) throw error
    return data
  }

  /**
   * Atualizar produto existente
   */
  static async updateProduct(productId: string, updates: Partial<Product>): Promise<Product> {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      throw new Error('Usuário não autenticado')
    }

    const { data, error } = await supabase
      .from('produtos')
      .update({
        ...updates,
        atualizado_em: new Date().toISOString()
      })
      .eq('id', productId)
      .eq('user_id', user.id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  /**
   * Deletar produto
   */
  static async deleteProduct(productId: string): Promise<void> {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      throw new Error('Usuário não autenticado')
    }

    const { error } = await supabase
      .from('produtos')
      .delete()
      .eq('id', productId)
      .eq('user_id', user.id)

    if (error) throw error
  }

  /**
   * Gerar código interno único (legado - mantido para compatibilidade)
   */
  static async generateCode(): Promise<string> {
    const timestamp = Date.now().toString().slice(-6)
    const random = Math.random().toString(36).substring(2, 5).toUpperCase()
    return `PDV${timestamp}${random}`
  }

  /**
   * Verificar se código interno já existe
   */
  static async checkCodeExists(code: string): Promise<boolean> {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) return false

    const { data, error } = await supabase
      .from('produtos')
      .select('id')
      .eq('user_id', user.id)
      .or(`codigo_interno.eq.${code},sku.eq.${code}`)
      .limit(1)

    if (error) {
      console.error('Erro ao verificar código:', error)
      return false
    }

    return (data?.length || 0) > 0
  }

  /**
   * Buscar o próximo código sequencial disponível
   * Formato: P0001, P0002, P0003... até P9999
   */
  static async getNextSequentialCode(): Promise<string> {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      console.error('Erro ao obter usuário:', userError)
      return 'P0001' // Fallback
    }

    try {
      // Buscar todos os códigos que seguem o padrão P#### (4 dígitos)
      const { data, error } = await supabase
        .from('produtos')
        .select('codigo_interno, sku')
        .eq('user_id', user.id)

      if (error) {
        console.error('Erro ao buscar códigos existentes:', error)
        return 'P0001'
      }

      // Extrair todos os números dos códigos no formato P####
      const codigosNumericos: number[] = []
      
      if (data && data.length > 0) {
        data.forEach((produto) => {
          // Verificar codigo_interno
          if (produto.codigo_interno) {
            const match = produto.codigo_interno.match(/^P(\d{4})$/i)
            if (match) {
              codigosNumericos.push(parseInt(match[1], 10))
            }
          }
          // Verificar sku também
          if (produto.sku) {
            const match = produto.sku.match(/^P(\d{4})$/i)
            if (match) {
              codigosNumericos.push(parseInt(match[1], 10))
            }
          }
        })
      }

      // Se não há códigos, começar do 1
      if (codigosNumericos.length === 0) {
        return 'P0001'
      }

      // Encontrar o maior número
      const maiorNumero = Math.max(...codigosNumericos)
      
      // Incrementar e formatar com 4 dígitos (P0001, P0002, etc.)
      const proximoNumero = maiorNumero + 1
      
      // Limitar a 9999
      if (proximoNumero > 9999) {
        console.warn('⚠️ Limite de 9999 produtos sequenciais atingido')
        // Buscar primeiro gap disponível entre 1 e 9999
        for (let i = 1; i <= 9999; i++) {
          if (!codigosNumericos.includes(i)) {
            return `P${i.toString().padStart(4, '0')}`
          }
        }
        // Se não há gaps, usar timestamp
        return `P${Date.now().toString().slice(-4)}`
      }

      return `P${proximoNumero.toString().padStart(4, '0')}`
    } catch (error) {
      console.error('Erro ao gerar código sequencial:', error)
      return 'P0001'
    }
  }

  /**
   * Gerar código interno único sequencial (P0001, P0002, P0003...)
   * Se o código gerado já existir, busca o próximo disponível
   */
  static async generateUniqueCode(): Promise<string> {
    try {
      // Buscar próximo código sequencial
      const proximoCodigo = await this.getNextSequentialCode()
      
      // Verificar se está disponível (segurança extra)
      const existe = await this.checkCodeExists(proximoCodigo)
      
      if (!existe) {
        console.log(`✅ Código sequencial gerado: ${proximoCodigo}`)
        return proximoCodigo
      }

      // Se por algum motivo o código existe, buscar o próximo gap
      console.warn(`⚠️ Código ${proximoCodigo} já existe, buscando próximo disponível...`)
      
      // Tentar até 100 códigos sequenciais
      for (let i = 1; i <= 100; i++) {
        const codigoTeste = `P${i.toString().padStart(4, '0')}`
        const existeTeste = await this.checkCodeExists(codigoTeste)
        
        if (!existeTeste) {
          console.log(`✅ Código disponível encontrado: ${codigoTeste}`)
          return codigoTeste
        }
      }

      // Fallback: usar timestamp
      const fallback = `P${Date.now().toString().slice(-4)}`
      console.log(`⚠️ Usando código fallback: ${fallback}`)
      return fallback
    } catch (error) {
      console.error('Erro ao gerar código único:', error)
      return 'P0001'
    }
  }

  /**
   * Buscar categorias do usuário
   */
  static async loadCategories(): Promise<Category[]> {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      throw new Error('Usuário não autenticado')
    }

    const { data, error } = await supabase
      .from('categorias')
      .select('*')
      .eq('user_id', user.id)
      .order('nome')

    if (error) throw error
    
    // Adaptar dados do banco (nome → name)
    return (data || []).map((cat) => ({
      id: cat.id,
      name: cat.nome || cat.name,
      created_at: cat.created_at
    }))
  }

  /**
   * Criar nova categoria
   */
  static async createCategory(nome: string): Promise<Category> {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      throw new Error('Usuário não autenticado')
    }

    const { data, error } = await supabase
      .from('categorias')
      .insert({
        nome,
        user_id: user.id
      })
      .select()
      .single()

    if (error) throw error
    
    return {
      id: data.id,
      name: data.nome,
      created_at: data.created_at
    }
  }

  /**
   * Atualizar estoque do produto
   */
  static async updateStock(productId: string, newStock: number): Promise<void> {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      throw new Error('Usuário não autenticado')
    }

    const { error } = await supabase
      .from('produtos')
      .update({
        estoque: newStock,
        atualizado_em: new Date().toISOString()
      })
      .eq('id', productId)
      .eq('user_id', user.id)

    if (error) throw error
  }

  /**
   * Buscar produtos por categoria
   */
  static async getProductsByCategory(categoryId: string): Promise<Product[]> {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      throw new Error('Usuário não autenticado')
    }

    const { data, error } = await supabase
      .from('produtos')
      .select('*')
      .eq('user_id', user.id)
      .eq('categoria_id', categoryId)
      .eq('ativo', true)
      .order('nome')

    if (error) throw error
    return data || []
  }

  /**
   * Buscar produtos com estoque baixo
   */
  static async getLowStockProducts(minimumStock: number = 10): Promise<Product[]> {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      throw new Error('Usuário não autenticado')
    }

    const { data, error } = await supabase
      .from('produtos')
      .select('*')
      .eq('user_id', user.id)
      .eq('ativo', true)
      .lte('estoque', minimumStock)
      .order('estoque', { ascending: true })

    if (error) throw error
    return data || []
  }
}
