import { createClient } from '@supabase/supabase-js';
import { promises as fs } from 'fs';

const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.J4gAQcV_rJiw1xAvXgo8kyiPvDIZN3HtKyuBR-i5jL4'; // CHAVE SERVICE ROLE CORRETA

console.log('🚨 APLICANDO CORREÇÃO EMERGENCIAL DE SEGURANÇA...');

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

async function aplicarCorrecaoSeguranca() {
    try {
        // Ler o arquivo SQL
        const sqlContent = await fs.readFile('./EMERGENCIA_SEGURANCA_RLS.sql', 'utf8');
        
        // Dividir em comandos individuais 
        const commands = sqlContent
            .split(';')
            .map(cmd => cmd.trim())
            .filter(cmd => cmd && !cmd.startsWith('--'));

        console.log(`📋 Executando ${commands.length} comandos SQL...`);

        for (const [index, command] of commands.entries()) {
            if (command.trim()) {
                console.log(`🔧 Executando comando ${index + 1}/${commands.length}...`);
                
                const { data, error } = await supabase.rpc('exec_sql', { 
                    sql_query: command 
                });
                
                if (error) {
                    console.error(`❌ Erro no comando ${index + 1}:`, error.message);
                    
                    // Tentar executar diretamente se RPC falhar
                    try {
                        const { data: directData, error: directError } = await supabase
                            .from('pg_tables')
                            .select('*')
                            .limit(1);
                        
                        if (directError) {
                            console.error('❌ Erro de conexão:', directError.message);
                        } else {
                            console.log('✅ Conexão ativa, tentando próximo comando...');
                        }
                    } catch (e) {
                        console.error('❌ Erro de conexão geral:', e.message);
                    }
                } else {
                    console.log(`✅ Comando ${index + 1} executado com sucesso`);
                }
            }
        }

        console.log('🔒 CORREÇÃO DE SEGURANÇA APLICADA!');
        
        // Verificar se RLS está ativo
        await verificarRLS();
        
    } catch (error) {
        console.error('❌ Erro geral:', error.message);
    }
}

async function verificarRLS() {
    console.log('\n🔍 VERIFICANDO STATUS RLS...');
    
    try {
        // Verificar tabelas com RLS
        const { data: tables, error } = await supabase
            .rpc('exec_sql', { 
                sql_query: `
                SELECT 
                  tablename,
                  rowsecurity as rls_habilitado
                FROM pg_tables 
                WHERE schemaname = 'public' 
                AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa')
                ` 
            });
        
        if (error) {
            console.error('❌ Erro ao verificar RLS:', error.message);
        } else {
            console.log('📊 Status RLS das tabelas:');
            console.table(tables || []);
        }

        // Verificar políticas
        const { data: policies, error: policiesError } = await supabase
            .rpc('exec_sql', { 
                sql_query: `
                SELECT 
                  tablename,
                  policyname,
                  cmd
                FROM pg_policies 
                WHERE schemaname = 'public'
                AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa')
                ` 
            });
        
        if (policiesError) {
            console.error('❌ Erro ao verificar políticas:', policiesError.message);
        } else {
            console.log('📋 Políticas ativas:');
            console.table(policies || []);
        }

    } catch (error) {
        console.error('❌ Erro na verificação:', error.message);
    }
}

aplicarCorrecaoSeguranca();
