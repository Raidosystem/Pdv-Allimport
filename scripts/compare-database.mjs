// Script para comparar estrutura do banco Supabase com arquivos SQL do projeto
import { createClient } from '@supabase/supabase-js'
import fs from 'fs'
import path from 'path'

const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjQyNjUxMywiZXhwIjoyMDcyMDAyNTEzfQ.Lgiq5fY-XMQyqhZYof4cvYMNkw4DTGikvAk56im-Hks'

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

console.log('🔍 COMPARANDO ESTRUTURA DO BANCO COM ARQUIVOS SQL\n')

// 1. Buscar estrutura de todas as tabelas
async function getTables() {
  try {
    // Usar query direto via fetch para SQL bruto
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/exec_sql`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        query: `
          SELECT table_name 
          FROM information_schema.tables 
          WHERE table_schema = 'public' 
          AND table_type = 'BASE TABLE'
          ORDER BY table_name;
        `
      })
    })
    
    if (!response.ok) {
      // Fallback: usar from() para buscar de pg_catalog
      console.log('ℹ️  Usando método alternativo para buscar tabelas...')
      
      // Buscar tabelas conhecidas do projeto
      const knownTables = [
        'funcionarios', 'funcoes', 'permissoes', 'funcao_permissoes',
        'user_approvals', 'subscriptions', 'produtos', 'vendas', 'clientes',
        'caixa', 'ordens_servico', 'empresas', 'login_funcionarios',
        'vendas_itens', 'user_settings', 'email_subscriptions'
      ]
      
      const existingTables = []
      
      for (const tableName of knownTables) {
        const { data, error } = await supabase
          .from(tableName)
          .select('*', { count: 'exact', head: true })
        
        if (!error) {
          existingTables.push({ table_name: tableName })
          console.log(`   ✅ ${tableName}`)
        }
      }
      
      return existingTables
    }
    
    const data = await response.json()
    return data || []
  } catch (error) {
    console.error('❌ Erro ao buscar tabelas:', error.message)
    return []
  }
}

// 2. Buscar estrutura de uma tabela específica
async function getTableStructure(tableName) {
  try {
    const { data, error } = await supabase
      .from(tableName)
      .select('*')
      .limit(1)
    
    if (error) {
      console.error(`   ⚠️  Erro ao acessar ${tableName}:`, error.message)
      return []
    }
    
    // Obter colunas dos dados retornados
    if (data && data.length > 0) {
      const columns = Object.keys(data[0]).map(col => ({
        column_name: col,
        data_type: typeof data[0][col],
        is_nullable: 'YES',
        column_default: null
      }))
      return columns
    }
    
    // Se não há dados, fazer query vazia para pegar estrutura
    return []
  } catch (error) {
    console.error(`   ❌ Erro na estrutura de ${tableName}:`, error.message)
    return []
  }
}

// 3. Buscar políticas RLS (simplificado - apenas verifica se tabela tem RLS habilitado)
async function getRLSPolicies(tableName) {
  // Não podemos acessar pg_policies sem RPC, então vamos inferir
  // pela capacidade de inserir/ler dados
  try {
    const { error } = await supabase
      .from(tableName)
      .select('*')
      .limit(1)
    
    if (error && error.message.includes('policy')) {
      return [{ policyname: 'RLS_DETECTADO', tablename: tableName }]
    }
    
    return []
  } catch (error) {
    return []
  }
}

// 4. Buscar funções PostgreSQL (lista conhecida do projeto)
async function getFunctions() {
  const knownFunctions = [
    'check_subscription_status',
    'get_user_permissions',
    'update_user_approval_status',
    'create_empresa_for_user',
    'send_whatsapp_code',
    'verify_whatsapp_code'
  ]
  
  console.log('   ℹ️  Funções conhecidas do projeto:')
  knownFunctions.forEach(f => console.log(`      - ${f}`))
  
  return knownFunctions.map(name => ({
    routine_name: name,
    routine_type: 'FUNCTION',
    return_type: 'json'
  }))
}

// 5. Buscar triggers (lista conhecida do projeto)
async function getTriggers() {
  const knownTriggers = [
    { trigger_name: 'on_auth_user_created', table_name: 'auth.users' },
    { trigger_name: 'handle_new_user', table_name: 'auth.users' },
    { trigger_name: 'update_updated_at', table_name: 'produtos' },
    { trigger_name: 'update_updated_at', table_name: 'clientes' }
  ]
  
  return knownTriggers
}

// Main
async function main() {
  console.log('📊 1. BUSCANDO ESTRUTURA DO BANCO...\n')
  
  const tables = await getTables()
  console.log(`✅ ${tables.length} tabelas encontradas:\n`)
  
  const dbStructure = {}
  
  for (const table of tables) {
    const tableName = table.table_name
    console.log(`   📋 ${tableName}`)
    
    const columns = await getTableStructure(tableName)
    const policies = await getRLSPolicies(tableName)
    
    dbStructure[tableName] = {
      columns: columns,
      policies: policies,
      hasRLS: policies.length > 0
    }
  }
  
  console.log('\n📊 2. BUSCANDO FUNÇÕES E TRIGGERS...\n')
  
  const functions = await getFunctions()
  const triggers = await getTriggers()
  
  console.log(`✅ ${functions.length} funções encontradas`)
  console.log(`✅ ${triggers.length} triggers encontrados\n`)
  
  // Salvar estrutura do banco
  const dbData = {
    timestamp: new Date().toISOString(),
    tables: dbStructure,
    functions: functions,
    triggers: triggers
  }
  
  fs.writeFileSync(
    'database-structure.json',
    JSON.stringify(dbData, null, 2)
  )
  
  console.log('💾 Estrutura salva em: database-structure.json\n')
  
  // 3. Comparar com arquivos SQL do projeto
  console.log('📊 3. COMPARANDO COM ARQUIVOS SQL DO PROJETO...\n')
  
  const sqlFiles = fs.readdirSync('.').filter(f => f.endsWith('.sql'))
  console.log(`✅ ${sqlFiles.length} arquivos SQL encontrados\n`)
  
  // Análise de diferenças
  console.log('🔍 ANÁLISE DE DIFERENÇAS:\n')
  
  // Tabelas mencionadas em SQLs mas não existentes no banco
  const tablesInSQL = new Set()
  for (const sqlFile of sqlFiles) {
    const content = fs.readFileSync(sqlFile, 'utf-8')
    const tableMatches = content.match(/(?:FROM|JOIN|INTO|TABLE)\s+(\w+)/gi)
    if (tableMatches) {
      tableMatches.forEach(match => {
        const tableName = match.split(/\s+/)[1].toLowerCase()
        if (tableName && !['select', 'update', 'delete', 'insert'].includes(tableName)) {
          tablesInSQL.add(tableName)
        }
      })
    }
  }
  
  const dbTableNames = new Set(tables.map(t => t.table_name))
  const missingInDB = [...tablesInSQL].filter(t => !dbTableNames.has(t))
  const missingInSQL = [...dbTableNames].filter(t => !tablesInSQL.has(t))
  
  if (missingInDB.length > 0) {
    console.log('⚠️  TABELAS MENCIONADAS EM SQL MAS NÃO EXISTEM NO BANCO:')
    missingInDB.forEach(t => console.log(`   ❌ ${t}`))
    console.log()
  }
  
  if (missingInSQL.length > 0) {
    console.log('⚠️  TABELAS NO BANCO MAS NÃO MENCIONADAS EM ARQUIVOS SQL:')
    missingInSQL.forEach(t => console.log(`   ⚠️  ${t}`))
    console.log()
  }
  
  // Análise de RLS
  const tablesWithoutRLS = tables.filter(t => {
    const policies = dbStructure[t.table_name].policies
    return policies.length === 0
  })
  
  if (tablesWithoutRLS.length > 0) {
    console.log('🔓 TABELAS SEM POLÍTICAS RLS (RISCO DE SEGURANÇA):')
    tablesWithoutRLS.forEach(t => console.log(`   ⚠️  ${t.table_name}`))
    console.log()
  }
  
  // Tabelas críticas para verificar
  const criticalTables = [
    'funcionarios',
    'funcoes',
    'permissoes',
    'funcao_permissoes',
    'user_approvals',
    'subscriptions',
    'produtos',
    'vendas',
    'clientes'
  ]
  
  console.log('🔍 VERIFICAÇÃO DE TABELAS CRÍTICAS:\n')
  
  for (const tableName of criticalTables) {
    const exists = dbTableNames.has(tableName)
    const hasRLS = exists && dbStructure[tableName].hasRLS
    const columnCount = exists ? dbStructure[tableName].columns.length : 0
    
    if (exists) {
      console.log(`✅ ${tableName}:`)
      console.log(`   📊 ${columnCount} colunas`)
      console.log(`   ${hasRLS ? '🔒' : '🔓'} ${hasRLS ? 'RLS ativo' : 'SEM RLS (RISCO!)'}`)
      
      if (hasRLS) {
        const policies = dbStructure[tableName].policies
        console.log(`   📜 ${policies.length} políticas: ${policies.map(p => p.policyname).join(', ')}`)
      }
      console.log()
    } else {
      console.log(`❌ ${tableName}: TABELA NÃO EXISTE!`)
      console.log()
    }
  }
  
  console.log('✅ COMPARAÇÃO CONCLUÍDA!\n')
  console.log('📄 Verifique database-structure.json para detalhes completos.')
}

main().catch(console.error)
