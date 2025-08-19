import fetch from 'node-fetch';

const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.J4gAQcV_rJiw1xAvXgo8kyiPvDIZN3HtKyuBR-i5jL4';

console.log('🔍 Verificando estrutura atual das tabelas e RLS...');

// Primeiro, vamos criar a função exec_sql
const criarFuncaoSQL = `
CREATE OR REPLACE FUNCTION exec_sql(sql_query text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result json;
BEGIN
    EXECUTE sql_query;
    GET DIAGNOSTICS result = ROW_COUNT;
    RETURN json_build_object('rows_affected', result);
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('error', SQLERRM);
END;
$$;
`;

async function criarFuncao() {
    try {
        console.log('🔧 Criando função exec_sql...');
        const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/`, {
            method: 'POST', 
            headers: {
                'Content-Type': 'application/json',
                'apikey': SERVICE_ROLE_KEY,
                'Authorization': `Bearer ${SERVICE_ROLE_KEY}`
            },
            body: JSON.stringify({
                name: 'exec_sql_create',
                args: { query: criarFuncaoSQL }
            })
        });
        
        console.log('Status:', response.status);
        const text = await response.text();
        console.log('Response:', text);
        
    } catch (error) {
        console.error('❌ Erro:', error.message);
    }
}

async function verificarTabelas() {
    try {
        console.log('📊 Verificando estrutura das tabelas...');
        
        // Usar a REST API para consultar o pg_tables diretamente
        const response = await fetch(`${SUPABASE_URL}/rest/v1/pg_tables?schemaname=eq.public&select=tablename,rowsecurity`, {
            headers: {
                'apikey': SERVICE_ROLE_KEY,
                'Authorization': `Bearer ${SERVICE_ROLE_KEY}`
            }
        });
        
        if (response.ok) {
            const tables = await response.json();
            console.log('📋 Tabelas encontradas:');
            console.table(tables);
        } else {
            console.log('❌ Erro ao consultar tabelas:', response.status);
        }
        
    } catch (error) {
        console.error('❌ Erro:', error.message);
    }
}

async function verificarColunas() {
    try {
        console.log('🔍 Verificando colunas user_id...');
        
        const tabelas = ['clientes', 'produtos', 'vendas', 'caixa'];
        
        for (const tabela of tabelas) {
            try {
                const response = await fetch(`${SUPABASE_URL}/rest/v1/${tabela}?select=*&limit=1`, {
                    headers: {
                        'apikey': SERVICE_ROLE_KEY,
                        'Authorization': `Bearer ${SERVICE_ROLE_KEY}`
                    }
                });
                
                if (response.ok) {
                    const data = await response.json();
                    const sample = data[0] || {};
                    const hasUserId = 'user_id' in sample;
                    console.log(`📝 ${tabela}: user_id = ${hasUserId ? '✅ EXISTE' : '❌ FALTA'}`);
                    if (data.length > 0) {
                        console.log(`   Campos: ${Object.keys(sample).join(', ')}`);
                    }
                } else {
                    console.log(`❌ ${tabela}: Erro ${response.status}`);
                }
            } catch (e) {
                console.log(`❌ ${tabela}: ${e.message}`);
            }
        }
        
    } catch (error) {
        console.error('❌ Erro geral:', error.message);
    }
}

async function main() {
    await verificarTabelas();
    await verificarColunas();
}

main();
