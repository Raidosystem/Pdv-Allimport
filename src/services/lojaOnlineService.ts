import { supabase } from '../lib/supabase'

// ============================================
// TIPOS E INTERFACES
// ============================================

export interface LojaOnline {
  id: string
  empresa_id: string
  slug: string
  nome: string
  ativa: boolean
  whatsapp: string
  logo_url: string | null
  cor_primaria: string
  cor_secundaria: string
  descricao: string | null
  mostrar_preco: boolean
  mostrar_estoque: boolean
  permitir_carrinho: boolean
  calcular_frete: boolean
  permitir_retirada: boolean
  meta_title: string | null
  meta_description: string | null
  meta_keywords: string | null
  created_at: string
  updated_at: string
}

export interface ProdutoPublico {
  id: string
  nome: string
  descricao: string | null
  preco: number
  preco_custo: number | null
  quantidade: number
  codigo_barras: string | null
  imagem_url: string | null
  categoria_id: string | null
  categoria_nome: string | null
}

export interface ItemCarrinho {
  produto_id: string
  nome: string
  preco: number
  quantidade: number
  imagem_url: string | null
}

export interface DadosCliente {
  nome: string
  whatsapp: string
  endereco?: string
  cep?: string
  observacoes?: string
}

export interface Analytics {
  total_visitas: number
  produtos_vistos: number
  adicoes_carrinho: number
  pedidos_whatsapp: number
  taxa_conversao: number
  produtos_populares: Array<{
    produto_id: string
    produto_nome: string
    visualizacoes: number
  }>
}

// ============================================
// SERVIÇO DE LOJA ONLINE
// ============================================

class LojaOnlineService {
  
  // ==========================================
  // ADMIN - GERENCIAMENTO DA LOJA
  // ==========================================

  /**
   * Buscar configuração da loja da empresa autenticada
   */
  async buscarMinhaLoja(): Promise<LojaOnline | null> {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('Usuário não autenticado')

    const { data, error } = await supabase
      .from('lojas_online')
      .select('*')
      .eq('empresa_id', user.id)
      .single()

    if (error && error.code !== 'PGRST116') {
      console.error('Erro ao buscar loja:', error)
      throw error
    }

    return data
  }

  /**
   * Criar nova loja online
   */
  async criarLoja(dados: Partial<LojaOnline>): Promise<LojaOnline> {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('Usuário não autenticado')

    // Gerar slug único baseado no nome
    const slugBase = this.gerarSlug(dados.nome || 'loja')
    const slug = await this.garantirSlugUnico(slugBase)

    const { data, error } = await supabase
      .from('lojas_online')
      .insert({
        ...dados,
        empresa_id: user.id,
        slug,
      })
      .select()
      .single()

    if (error) {
      console.error('Erro ao criar loja:', error)
      throw error
    }

    return data
  }

  /**
   * Atualizar configuração da loja
   */
  async atualizarLoja(id: string, dados: Partial<LojaOnline>): Promise<LojaOnline> {
    const { data, error } = await supabase
      .from('lojas_online')
      .update(dados)
      .eq('id', id)
      .select()
      .single()

    if (error) {
      console.error('Erro ao atualizar loja:', error)
      throw error
    }

    return data
  }

  /**
   * Ativar/Desativar loja
   */
  async toggleAtiva(id: string, ativa: boolean): Promise<void> {
    const { error } = await supabase
      .from('lojas_online')
      .update({ ativa })
      .eq('id', id)

    if (error) {
      console.error('Erro ao alterar status da loja:', error)
      throw error
    }
  }

  /**
   * Verificar se slug está disponível
   */
  async verificarSlugDisponivel(slug: string): Promise<boolean> {
    const { data: { user } } = await supabase.auth.getUser()
    
    const query = supabase
      .from('lojas_online')
      .select('id')
      .eq('slug', slug)
    
    // Se estiver autenticado, ignora a própria loja
    if (user) {
      query.neq('empresa_id', user.id)
    }
    
    const { data, error } = await query.single()
    
    // Se não encontrou nenhuma loja com esse slug, está disponível
    return error?.code === 'PGRST116' || !data
  }

  /**
   * Upload de logo
   */
  async uploadLogo(file: File, lojaId: string): Promise<string> {
    const fileExt = file.name.split('.').pop()
    const fileName = `${lojaId}-${Date.now()}.${fileExt}`
    const filePath = `logos/${fileName}`

    const { error: uploadError } = await supabase.storage
      .from('lojas')
      .upload(filePath, file, {
        cacheControl: '3600',
        upsert: true
      })

    if (uploadError) {
      console.error('Erro ao fazer upload:', uploadError)
      throw uploadError
    }

    const { data } = supabase.storage
      .from('lojas')
      .getPublicUrl(filePath)

    return data.publicUrl
  }

  /**
   * Buscar analytics da loja
   */
  async buscarAnalytics(
    lojaId: string,
    dataInicio?: Date,
    dataFim?: Date
  ): Promise<Analytics> {
    const { data, error } = await supabase.rpc('analytics_loja', {
      p_loja_id: lojaId,
      p_data_inicio: dataInicio?.toISOString().split('T')[0] || undefined,
      p_data_fim: dataFim?.toISOString().split('T')[0] || undefined
    })

    if (error) {
      console.error('Erro ao buscar analytics:', error)
      throw error
    }

    return data.analytics
  }

  // ==========================================
  // PÚBLICO - CATÁLOGO
  // ==========================================

  /**
   * Buscar loja por slug (acesso público)
   */
  async buscarLojaPorSlug(slug: string): Promise<LojaOnline> {
    const { data, error } = await supabase.rpc('buscar_loja_por_slug', {
      p_slug: slug
    })

    if (error || !data.success) {
      throw new Error(data?.error || 'Loja não encontrada')
    }

    return data.loja
  }

  /**
   * Listar produtos da loja (acesso público)
   */
  async listarProdutosLoja(slug: string): Promise<ProdutoPublico[]> {
    const { data, error } = await supabase.rpc('listar_produtos_loja', {
      p_slug: slug
    })

    if (error || !data.success) {
      throw new Error(data?.error || 'Erro ao buscar produtos')
    }

    return data.produtos || []
  }

  /**
   * Buscar produto específico
   */
  async buscarProduto(produtoId: string): Promise<ProdutoPublico | null> {
    const { data, error } = await supabase
      .from('produtos')
      .select(`
        id,
        nome,
        descricao,
        preco,
        preco_custo,
        quantidade,
        codigo_barras,
        imagem_url,
        categoria_id,
        categorias (nome)
      `)
      .eq('id', produtoId)
      .eq('ativo', true)
      .single()

    if (error) {
      console.error('Erro ao buscar produto:', error)
      return null
    }

    return {
      ...data,
      categoria_nome: (data.categorias as any)?.nome || null
    }
  }

  /**
   * Registrar acesso ao produto
   */
  async registrarAcessoProduto(lojaId: string, produtoId: string): Promise<void> {
    await supabase.from('acessos_loja').insert({
      loja_id: lojaId,
      produto_id: produtoId,
      tipo: 'visita_produto'
    })
  }

  /**
   * Registrar adição ao carrinho
   */
  async registrarAdicaoCarrinho(lojaId: string, produtoId: string): Promise<void> {
    await supabase.from('acessos_loja').insert({
      loja_id: lojaId,
      produto_id: produtoId,
      tipo: 'adicao_carrinho'
    })
  }

  // ==========================================
  // WHATSAPP - PEDIDOS
  // ==========================================

  /**
   * Gerar mensagem WhatsApp formatada
   */
  gerarMensagemWhatsApp(
    loja: LojaOnline,
    carrinho: ItemCarrinho[],
    cliente: DadosCliente
  ): string {
    const total = carrinho.reduce((acc, item) => acc + (item.preco * item.quantidade), 0)

    let mensagem = `🛒 *NOVO PEDIDO - ${loja.nome}*\n\n`
    mensagem += `👤 *Cliente:* ${cliente.nome}\n`
    mensagem += `📱 *Telefone:* ${cliente.whatsapp}\n`
    
    if (cliente.endereco) {
      mensagem += `📍 *Endereço:* ${cliente.endereco}\n`
    }
    
    if (cliente.cep) {
      mensagem += `📮 *CEP:* ${cliente.cep}\n`
    }

    mensagem += `\n━━━━━━━━━━━━━━━━━━━\n`
    mensagem += `📦 *PRODUTOS:*\n\n`

    carrinho.forEach(item => {
      const subtotal = item.preco * item.quantidade
      mensagem += `• ${item.nome}\n`
      mensagem += `  Qtd: ${item.quantidade} un.\n`
      mensagem += `  Valor: R$ ${subtotal.toFixed(2).replace('.', ',')}\n\n`
    })

    mensagem += `━━━━━━━━━━━━━━━━━━━\n`
    mensagem += `💰 *TOTAL: R$ ${total.toFixed(2).replace('.', ',')}*\n\n`

    if (cliente.observacoes) {
      mensagem += `📝 *Observações:* ${cliente.observacoes}\n\n`
    }

    mensagem += `_Pedido gerado automaticamente pelo sistema_`

    return mensagem
  }

  /**
   * Abrir WhatsApp com mensagem
   */
  async enviarPedidoWhatsApp(
    loja: LojaOnline,
    carrinho: ItemCarrinho[],
    cliente: DadosCliente
  ): Promise<void> {
    const mensagem = this.gerarMensagemWhatsApp(loja, carrinho, cliente)
    
    // Registrar pedido no banco
    await supabase.rpc('registrar_pedido_whatsapp', {
      p_slug: loja.slug,
      p_carrinho: {
        cliente,
        itens: carrinho,
        total: carrinho.reduce((acc, item) => acc + (item.preco * item.quantidade), 0)
      }
    })

    // Limpar número (remover caracteres especiais)
    const numero = loja.whatsapp.replace(/\D/g, '')
    
    // Codificar mensagem para URL
    const mensagemCodificada = encodeURIComponent(mensagem)
    
    // Detectar se é mobile ou desktop
    const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent)
    
    // Abrir WhatsApp
    const url = isMobile
      ? `whatsapp://send?phone=55${numero}&text=${mensagemCodificada}`
      : `https://web.whatsapp.com/send?phone=55${numero}&text=${mensagemCodificada}`
    
    window.open(url, '_blank')
  }

  // ==========================================
  // UTILITÁRIOS
  // ==========================================

  /**
   * Gerar slug a partir do nome
   */
  private gerarSlug(nome: string): string {
    return nome
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '') // Remove acentos
      .replace(/[^a-z0-9]+/g, '-') // Substitui caracteres especiais por hífen
      .replace(/^-+|-+$/g, '') // Remove hífens do início e fim
  }

  /**
   * Garantir que slug é único
   */
  private async garantirSlugUnico(slugBase: string): Promise<string> {
    let slug = slugBase
    let contador = 1

    while (true) {
      const { data } = await supabase
        .from('lojas_online')
        .select('id')
        .eq('slug', slug)
        .single()

      if (!data) break // Slug disponível

      slug = `${slugBase}-${contador}`
      contador++
    }

    return slug
  }

  /**
   * Validar número WhatsApp
   */
  validarWhatsApp(numero: string): boolean {
    const numeroLimpo = numero.replace(/\D/g, '')
    return numeroLimpo.length >= 10 && numeroLimpo.length <= 11
  }

  /**
   * Formatar número WhatsApp
   */
  formatarWhatsApp(numero: string): string {
    const numeroLimpo = numero.replace(/\D/g, '')
    
    if (numeroLimpo.length === 11) {
      return `(${numeroLimpo.substring(0, 2)}) ${numeroLimpo.substring(2, 7)}-${numeroLimpo.substring(7)}`
    } else if (numeroLimpo.length === 10) {
      return `(${numeroLimpo.substring(0, 2)}) ${numeroLimpo.substring(2, 6)}-${numeroLimpo.substring(6)}`
    }
    
    return numero
  }
}

export const lojaOnlineService = new LojaOnlineService()
