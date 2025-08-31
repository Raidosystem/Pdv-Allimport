import { supabase } from '../lib/supabase'

export async function createSampleData() {
  console.log('📝 Criando dados de teste...')
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    console.log('❌ Usuário não logado')
    alert('❌ Usuário não está logado! Faça login primeiro.')
    return
  }

  const userId = user.id
  const hoje = new Date().toISOString()

  try {
    console.log('👤 Usuário logado:', user.email, 'ID:', userId)

    // Criar cliente de teste se não existir
    console.log('👤 Verificando se cliente existe...')
    const { data: clienteExiste } = await supabase
      .from('clientes')
      .select('id, nome')
      .eq('user_id', userId)
      .eq('nome', 'Cliente Teste')
      .single()

    let clienteId = clienteExiste?.id

    if (!clienteId) {
      console.log('👤 Criando novo cliente...')
      const { data: novoCliente, error: clienteError } = await supabase
        .from('clientes')
        .insert({
          user_id: userId,
          nome: 'Cliente Teste',
          email: 'cliente@teste.com',
          telefone: '(11) 99999-9999',
          ativo: true
        })
        .select('id')
        .single()

      if (clienteError) {
        console.error('❌ Erro ao criar cliente:', clienteError)
        alert('❌ Erro ao criar cliente: ' + clienteError.message)
        return
      }

      clienteId = novoCliente?.id
      console.log('✅ Cliente criado:', clienteId)
    } else {
      console.log('✅ Cliente já existe:', clienteId, clienteExiste?.nome)
    }

    // Criar venda de teste
    console.log('💰 Criando venda de teste...')
    const { data: novaVenda, error: vendaError } = await supabase
      .from('sales')
      .insert({
        user_id: userId,
        cliente_id: clienteId,
        total: 150.00,
        desconto: 0,
        forma_pagamento: 'Dinheiro',
        vendedor: 'Sistema',
        data_venda: hoje,
        status: 'finalizada'
      })
      .select('id')
      .single()

    if (vendaError) {
      console.error('❌ Erro ao criar venda:', vendaError)
      alert('❌ Erro ao criar venda: ' + vendaError.message)
      return
    }

    console.log('✅ Venda criada:', novaVenda?.id)

    // Criar categoria de teste
    const { data: categoriaExiste } = await supabase
      .from('categories')
      .select('id')
      .eq('user_id', userId)
      .eq('name', 'Categoria Teste')
      .single()

    let categoriaId = categoriaExiste?.id

    if (!categoriaId) {
      const { data: novaCategoria } = await supabase
        .from('categories')
        .insert({
          user_id: userId,
          name: 'Categoria Teste',
          description: 'Categoria de teste'
        })
        .select('id')
        .single()
      categoriaId = novaCategoria?.id
    }

    // Criar produto de teste se não existir
    console.log('📦 Criando produto de teste...')
    const { data: produtoExiste } = await supabase
      .from('produtos')
      .select('id')
      .eq('user_id', userId)
      .eq('nome', 'Produto Teste')
      .single()

    if (!produtoExiste) {
      await supabase
        .from('produtos')
        .insert({
          user_id: userId,
          nome: 'Produto Teste',
          preco: 50.00,
          estoque: 5,
          estoque_minimo: 10,
          ativo: true,
          category_id: categoriaId
        })
      console.log('✅ Produto criado')
    } else {
      console.log('✅ Produto já existe')
    }

    console.log('🎉 Dados de teste criados com sucesso!')
    alert('✅ Dados de teste criados! Recarregue a página para ver os resultados.')
    
  } catch (error) {
    console.error('❌ Erro ao criar dados de teste:', error)
    alert('❌ Erro ao criar dados: ' + (error as any).message)
  }
}
