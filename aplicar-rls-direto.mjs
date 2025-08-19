import fetch from 'node-fetch';

const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.J4gAQcV_rJiw1xAvXgo8kyiPvDIZN3HtKyuBR-i5jL4';

console.log('🚨 EMERGÊNCIA: Aplicando RLS IMEDIATAMENTE...');

// Comandos SQL críticos para isolamento
const sqlCommands = [
  // 1. Desabilitar RLS temporariamente para limpeza
  'ALTER TABLE clientes DISABLE ROW LEVEL SECURITY',
  'ALTER TABLE produtos DISABLE ROW LEVEL SECURITY',
  'ALTER TABLE vendas DISABLE ROW LEVEL SECURITY',
  'ALTER TABLE caixa DISABLE ROW LEVEL SECURITY',
  
  // 2. Remover todas as políticas existentes
  'DROP POLICY IF EXISTS "Usuários autenticados podem ver clientes" ON clientes',
  'DROP POLICY IF EXISTS "Usuários autenticados podem ver produtos" ON produtos',
  'DROP POLICY IF EXISTS "Usuários autenticados podem ver vendas" ON vendas',
  'DROP POLICY IF EXISTS "clientes_select_policy" ON clientes',
  'DROP POLICY IF EXISTS "produtos_select_policy" ON produtos',
  'DROP POLICY IF EXISTS "vendas_select_policy" ON vendas',
  
  // 3. Reabilitar RLS
  'ALTER TABLE clientes ENABLE ROW LEVEL SECURITY',
  'ALTER TABLE produtos ENABLE ROW LEVEL SECURITY',
  'ALTER TABLE vendas ENABLE ROW LEVEL SECURITY',
  'ALTER TABLE caixa ENABLE ROW LEVEL SECURITY',
  
  // 4. Criar políticas de isolamento total
  `CREATE POLICY "isolamento_clientes" ON clientes FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid())`,
  `CREATE POLICY "isolamento_produtos" ON produtos FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid())`,
  `CREATE POLICY "isolamento_vendas" ON vendas FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid())`,
  `CREATE POLICY "isolamento_caixa" ON caixa FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid())`
];

async function executarSQL(query) {
    const url = `${SUPABASE_URL}/rest/v1/rpc/exec_sql`;
    
    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'apikey': SERVICE_ROLE_KEY,
                'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
                'Prefer': 'return=minimal'
            },
            body: JSON.stringify({ sql_query: query })
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Status ${response.status}: ${errorText}`);
        }

        return await response.json();
    } catch (error) {
        throw error;
    }
}

async function aplicarSegurancaEmergencial() {
    let sucessos = 0;
    let falhas = 0;

    for (const [index, sql] of sqlCommands.entries()) {
        console.log(`🔧 Executando ${index + 1}/${sqlCommands.length}: ${sql.substring(0, 50)}...`);
        
        try {
            await executarSQL(sql);
            console.log(`✅ Sucesso`);
            sucessos++;
        } catch (error) {
            console.error(`❌ Falha: ${error.message}`);
            falhas++;
        }
    }

    console.log(`\n📊 RESULTADO:`);
    console.log(`✅ Sucessos: ${sucessos}`);
    console.log(`❌ Falhas: ${falhas}`);

    if (sucessos > 0) {
        console.log('🔒 RLS PARCIALMENTE/TOTALMENTE APLICADO!');
        await verificarStatus();
    } else {
        console.log('❌ FALHA TOTAL - RLS NÃO APLICADO');
    }
}

async function verificarStatus() {
    console.log('\n🔍 Verificando status RLS...');
    
    try {
        // Verificar se as tabelas têm RLS habilitado
        const statusQuery = `
            SELECT 
                tablename,
                rowsecurity as rls_habilitado
            FROM pg_tables 
            WHERE schemaname = 'public' 
            AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa')
        `;
        
        const status = await executarSQL(statusQuery);
        console.log('📋 Status das tabelas:');
        console.table(status);
        
    } catch (error) {
        console.error('❌ Erro ao verificar status:', error.message);
    }
}

aplicarSegurancaEmergencial();
