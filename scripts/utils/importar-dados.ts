#!/usr/bin/env tsx
/**
 * SCRIPT DE IMPORTAÇÃO DE DADOS DO BACKUP PARA SUPABASE
 * 
 * Execução: npx tsx importar-dados.ts
 */

import { createClient } from '@supabase/supabase-js'
import { readFileSync } from 'fs'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

// Configuração do Supabase
const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)

// ID da empresa (pegar da sessão ou usar um fixo para testes)
const EMPRESA_ID = 'f1726fcf-d23b-4cca-8079-39314ae56e00' // Substitua pelo ID correto

interface ResultadoImportacao {
  sucesso: boolean
  total: number
  detalhes: Record<string, number>
  erros: string[]
}

async function importarClientes(clientes: any[], empresaId: string): Promise<number> {
  console.log(`📋 Importando ${clientes.length} clientes...`)
  
  const clientesFormatados = clientes.map((cliente: any) => ({
    id: cliente.id || crypto.randomUUID(),
    empresa_id: empresaId,
    nome: cliente.name || 'Cliente',
    telefone: cliente.phone || '',
    email: cliente.email || null,
    cpf_cnpj: cliente.cpf_cnpj || null,
    cpf_digits: cliente.cpf_cnpj ? cliente.cpf_cnpj.replace(/\D/g, '') : null,
    endereco: cliente.address || null,
    cidade: cliente.city || null,
    estado: cliente.state || null,
    cep: cliente.zip_code || null,
    tipo: 'Física',
    ativo: true,
    observacoes: null,
    criado_em: cliente.created_at || new Date().toISOString(),
    atualizado_em: new Date().toISOString()
  }))

  // Importar em lotes de 100
  let importados = 0
  const loteSize = 100

  for (let i = 0; i < clientesFormatados.length; i += loteSize) {
    const lote = clientesFormatados.slice(i, i + loteSize)
    
    const { data, error } = await supabase
      .from('clientes')
      .upsert(lote, { onConflict: 'id' })

    if (error) {
      console.error(`❌ Erro no lote ${i / loteSize + 1}:`, error.message)
      console.error('Detalhes:', error)
    } else {
      importados += lote.length
      console.log(`   ✅ Lote ${Math.floor(i / loteSize) + 1}: ${lote.length} registros`)
    }
  }

  return importados
}

async function importarProdutos(produtos: any[], empresaId: string): Promise<number> {
  console.log(`📦 Importando ${produtos.length} produtos...`)
  
  const produtosFormatados = produtos.map((produto: any) => ({
    id: produto.id || crypto.randomUUID(),
    empresa_id: empresaId,
    nome: produto.name || 'Produto',
    preco: Number(produto.sale_price || produto.price || 0),
    custo: Number(produto.cost_price || 0),
    estoque: Number(produto.current_stock || produto.stock || 0),
    estoque_minimo: Number(produto.minimum_stock || 0),
    unidade: produto.unit_measure || 'un',
    codigo_barras: produto.barcode || null,
    categoria_id: produto.category_id || null,
    ativo: produto.active !== false,
    criado_em: produto.created_at || new Date().toISOString(),
    atualizado_em: new Date().toISOString()
  }))

  let importados = 0
  const loteSize = 100

  for (let i = 0; i < produtosFormatados.length; i += loteSize) {
    const lote = produtosFormatados.slice(i, i + loteSize)
    
    const { data, error } = await supabase
      .from('produtos')
      .upsert(lote, { onConflict: 'id' })

    if (error) {
      console.error(`❌ Erro no lote ${i / loteSize + 1}:`, error.message)
    } else {
      importados += lote.length
      console.log(`   ✅ Lote ${Math.floor(i / loteSize) + 1}: ${lote.length} registros`)
    }
  }

  return importados
}

async function importarOrdensServico(ordens: any[], empresaId: string): Promise<number> {
  console.log(`🔧 Importando ${ordens.length} ordens de serviço...`)
  
  const ordensFormatadas = ordens.map((ordem: any) => ({
    id: ordem.id || crypto.randomUUID(),
    empresa_id: empresaId,
    cliente_id: ordem.client_id || null,
    cliente_nome: ordem.client_name || null,
    equipamento: ordem.equipment || ordem.device_name || 'Equipamento',
    modelo: ordem.device_model || null,
    defeito: ordem.defect || 'Defeito',
    status: ordem.status || 'Aguardando',
    valor_total: Number(ordem.total || ordem.total_amount || 0),
    mao_obra: Number(ordem.labor_cost || 0),
    forma_pagamento: ordem.payment_method || null,
    data_abertura: ordem.opening_date || null,
    data_fechamento: ordem.closing_date || null,
    observacoes: ordem.observations || null,
    criado_em: ordem.created_at || new Date().toISOString(),
    atualizado_em: new Date().toISOString()
  }))

  let importados = 0
  const loteSize = 100

  for (let i = 0; i < ordensFormatadas.length; i += loteSize) {
    const lote = ordensFormatadas.slice(i, i + loteSize)
    
    const { data, error } = await supabase
      .from('ordens_servico')
      .upsert(lote, { onConflict: 'id' })

    if (error) {
      console.error(`❌ Erro no lote ${i / loteSize + 1}:`, error.message)
    } else {
      importados += lote.length
      console.log(`   ✅ Lote ${Math.floor(i / loteSize) + 1}: ${lote.length} registros`)
    }
  }

  return importados
}

async function executarImportacao() {
  console.log('🚀 IMPORTAÇÃO DE DADOS DO BACKUP PARA SUPABASE')
  console.log('═══════════════════════════════════════════════\n')
  
  const inicio = Date.now()
  const resultado: ResultadoImportacao = {
    sucesso: false,
    total: 0,
    detalhes: {},
    erros: []
  }

  try {
    // 1. Ler o arquivo de backup
    console.log('📁 Carregando backup...')
    const backupPath = join(__dirname, 'public', 'backup-allimport.json')
    const backupJson = readFileSync(backupPath, 'utf-8')
    const backup = JSON.parse(backupJson)

    if (!backup.data) {
      throw new Error('Estrutura do backup inválida')
    }

    console.log('✅ Backup carregado com sucesso\n')
    console.log('📊 Dados disponíveis:')
    console.log(`   - Clientes: ${backup.data.clients?.length || 0}`)
    console.log(`   - Produtos: ${backup.data.products?.length || 0}`)
    console.log(`   - Ordens de Serviço: ${backup.data.service_orders?.length || 0}`)
    console.log(`   - Categorias: ${backup.data.categories?.length || 0}\n`)

    // 2. Importar Clientes
    if (backup.data.clients?.length > 0) {
      const importados = await importarClientes(backup.data.clients, EMPRESA_ID)
      resultado.detalhes.clientes = importados
    }

    // 3. Importar Produtos
    if (backup.data.products?.length > 0) {
      const importados = await importarProdutos(backup.data.products, EMPRESA_ID)
      resultado.detalhes.produtos = importados
    }

    // 4. Importar Ordens de Serviço
    if (backup.data.service_orders?.length > 0) {
      const importados = await importarOrdensServico(backup.data.service_orders, EMPRESA_ID)
      resultado.detalhes.ordens_servico = importados
    }

    // Calcular totais
    resultado.total = Object.values(resultado.detalhes).reduce((sum, count) => sum + count, 0)
    resultado.sucesso = resultado.total > 0

    const tempoMs = Date.now() - inicio
    
    console.log('\n✅ IMPORTAÇÃO CONCLUÍDA!')
    console.log('═══════════════════════════════════════════════')
    console.log(`⏱️  Tempo: ${(tempoMs / 1000).toFixed(2)}s`)
    console.log(`📊 Total importado: ${resultado.total} registros\n`)
    
    console.log('📋 Detalhes por tabela:')
    Object.entries(resultado.detalhes).forEach(([tabela, quantidade]) => {
      console.log(`   ${tabela}: ${quantidade} registros`)
    })

    if (resultado.erros.length > 0) {
      console.log('\n⚠️  Erros encontrados:')
      resultado.erros.forEach(erro => console.log(`   - ${erro}`))
    }

  } catch (error: any) {
    console.error('\n❌ ERRO NA IMPORTAÇÃO:', error.message)
    resultado.erros.push(error.message)
  }

  process.exit(resultado.sucesso ? 0 : 1)
}

// Executar
executarImportacao()
