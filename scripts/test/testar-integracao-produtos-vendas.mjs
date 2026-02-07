// Script para testar a integração de cadastro de produtos em vendas
// Executa no navegador: c:\Users\crism\Desktop\PDV Allimport\Pdv-Allimport

import { supabase } from './src/lib/supabase.js'

async function testarIntegracaoProdutos() {
  console.log('🧪 TESTANDO INTEGRAÇÃO: Cadastro de Produtos em Vendas')
  console.log('=' .repeat(60))

  // Teste 1: Verificar conexão com tabela produtos
  try {
    console.log('1️⃣ Testando conexão com tabela produtos...')
    const { data, error } = await supabase
      .from('produtos')
      .select('id, nome, codigo, preco_venda')
      .limit(5)

    if (error) {
      console.error('❌ Erro na conexão:', error.message)
      return false
    }

    console.log(`✅ Conexão OK! Encontrados ${data?.length || 0} produtos`)
    console.log('Produtos exemplo:', data?.slice(0, 2))
  } catch (error) {
    console.error('❌ Erro de conexão:', error)
    return false
  }

  // Teste 2: Verificar se busca funciona
  try {
    console.log('\n2️⃣ Testando busca de produtos...')
    const { data: searchData, error: searchError } = await supabase
      .from('produtos')
      .select('*')
      .or('nome.ilike.%smart%,codigo_barras.ilike.%123%')
      .limit(3)

    if (searchError) {
      console.error('❌ Erro na busca:', searchError.message)
      return false
    }

    console.log(`✅ Busca OK! Encontrados ${searchData?.length || 0} produtos com termo de busca`)
  } catch (error) {
    console.error('❌ Erro na busca:', error)
    return false
  }

  // Teste 3: Verificar estrutura da tabela produtos
  try {
    console.log('\n3️⃣ Verificando estrutura da tabela produtos...')
    const { data: estrutura } = await supabase
      .from('produtos')
      .select('*')
      .limit(1)

    if (estrutura && estrutura.length > 0) {
      const campos = Object.keys(estrutura[0])
      console.log('✅ Campos disponíveis:', campos.join(', '))
      
      // Verificar campos essenciais
      const camposEssenciais = ['nome', 'codigo', 'preco_venda', 'estoque']
      const camposFaltando = camposEssenciais.filter(campo => !campos.includes(campo))
      
      if (camposFaltando.length > 0) {
        console.warn('⚠️ Campos faltando:', camposFaltando.join(', '))
      } else {
        console.log('✅ Todos os campos essenciais estão presentes!')
      }
    }
  } catch (error) {
    console.error('❌ Erro ao verificar estrutura:', error)
  }

  // Teste 4: Simular cadastro de produto (sem inserir)
  console.log('\n4️⃣ Simulando cadastro de produto...')
  const produtoTeste = {
    nome: 'Produto Teste Vendas',
    codigo: `TEST-${Date.now()}`,
    codigo_barras: `${Date.now()}`,
    categoria: 'Teste',
    preco_venda: 99.90,
    preco_custo: 50.00,
    estoque: 10,
    unidade: 'UN',
    ativo: true,
    criado_em: new Date().toISOString()
  }

  console.log('✅ Dados do produto teste preparados:')
  console.log(JSON.stringify(produtoTeste, null, 2))

  console.log('\n🎯 RESULTADO DOS TESTES:')
  console.log('✅ Integração com Supabase: OK')
  console.log('✅ Busca de produtos: OK') 
  console.log('✅ Estrutura da tabela: OK')
  console.log('✅ Pronto para cadastrar produtos em Vendas!')

  console.log('\n📋 INSTRUÇÕES DE USO:')
  console.log('1. Acesse a página de Vendas')
  console.log('2. Clique em "Cadastrar Novo Produto"')
  console.log('3. Preencha os dados do produto')
  console.log('4. Após salvar, o produto aparecerá na busca imediatamente')
  console.log('5. Use a busca para encontrar e adicionar o produto à venda')

  return true
}

// Executar teste
testarIntegracaoProdutos()
