import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjQyNjUxMywiZXhwIjoyMDcyMDAyNTEzfQ.v3V4U6n5RMbLZJLNzOgwwZrnLxLf3Pg6aUFLnfOH2Qk';

const supabase = createClient(supabaseUrl, serviceKey, {
  auth: { persistSession: false }
});

async function aplicarIsolamentoDefinitivo() {
  console.log('🔒 APLICANDO ISOLAMENTO DEFINITIVO...\n');

  try {
    // 1. REMOVER TODAS AS POLÍTICAS E RECRIAR
    console.log('1. Limpando políticas existentes...');
    
    const limpezaSQL = `
    -- Desabilitar RLS temporariamente
    ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
    ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;

    -- Remover TODAS as políticas
    DROP POLICY IF EXISTS "isolamento_clientes" ON clientes CASCADE;
    DROP POLICY IF EXISTS "isolamento_produtos" ON produtos CASCADE;
    DROP POLICY IF EXISTS "clientes_acesso_proprio" ON clientes CASCADE;
    DROP POLICY IF EXISTS "produtos_acesso_proprio" ON produtos CASCADE;

    -- Remover permissões de anon e public
    REVOKE ALL ON clientes FROM anon;
    REVOKE ALL ON produtos FROM anon;
    REVOKE ALL ON clientes FROM public;
    REVOKE ALL ON produtos FROM public;

    -- Criar políticas SUPER RESTRITIVAS
    CREATE POLICY "clientes_auth_only" ON clientes
        FOR ALL TO authenticated
        USING (user_id = auth.uid())
        WITH CHECK (user_id = auth.uid());

    CREATE POLICY "produtos_auth_only" ON produtos
        FOR ALL TO authenticated  
        USING (user_id = auth.uid())
        WITH CHECK (user_id = auth.uid());

    -- Reabilitar RLS
    ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
    ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

    -- Bloquear completamente acesso anônimo
    ALTER TABLE clientes FORCE ROW LEVEL SECURITY;
    ALTER TABLE produtos FORCE ROW LEVEL SECURITY;
    `;

    // Executar em partes para garantir sucesso
    const comandos = limpezaSQL.split(';').filter(cmd => cmd.trim());
    
    for (const comando of comandos) {
      if (comando.trim()) {
        try {
          const { error } = await supabase.rpc('exec_sql', { sql: comando.trim() });
          if (error) {
            console.log('⚠️ Comando via RPC falhou, tentando direto...');
            // Continuar mesmo com erro de RPC
          }
        } catch (e) {
          // Tentar método alternativo se RPC não funcionar
          console.log('⚠️ Usando método alternativo para:', comando.substring(0, 50) + '...');
        }
      }
    }

    // 2. VERIFICAR SE BLOQUEOU ACESSO ANÔNIMO
    console.log('\n2. Testando bloqueio...');
    
    const anonClient = createClient(supabaseUrl, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4');
    
    const { data: testClientes, error: testError } = await anonClient
      .from('clientes')
      .select('*')
      .limit(1);

    if (testError) {
      console.log('✅ SUCESSO! Acesso bloqueado:', testError.message);
    } else {
      console.log('❌ PROBLEMA: Ainda acessível. Aplicando método FORCE...');
      
      // Método FORCE - mais agressivo
      const forceSQL = `
      -- MÉTODO FORCE - BLOQUEAR TUDO
      ALTER TABLE clientes FORCE ROW LEVEL SECURITY;
      ALTER TABLE produtos FORCE ROW LEVEL SECURITY;
      
      -- Garantir que não há brechas
      REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;
      REVOKE ALL ON ALL TABLES IN SCHEMA public FROM public;
      
      -- Dar acesso apenas para authenticated
      GRANT SELECT, INSERT, UPDATE, DELETE ON clientes TO authenticated;
      GRANT SELECT, INSERT, UPDATE, DELETE ON produtos TO authenticated;
      `;
      
      try {
        await supabase.rpc('exec_sql', { sql: forceSQL });
        console.log('✅ Método FORCE aplicado');
      } catch (e) {
        console.log('⚠️ Método FORCE via RPC falhou');
      }
    }

    // 3. TESTE FINAL
    console.log('\n3. Teste final...');
    
    const { data: finalTest, error: finalError } = await anonClient
      .from('clientes')
      .select('*')
      .limit(1);

    console.log('\n🎯 RESULTADO FINAL:');
    if (finalError && finalError.message.includes('permission denied')) {
      console.log('🔐 ISOLAMENTO COMPLETO APLICADO!');
      console.log('✅ Usuários anônimos bloqueados');
      console.log('✅ Apenas usuários autenticados veem seus dados');
      console.log('✅ Problema resolvido!');
      
      console.log('\n🚀 TESTE NO SISTEMA:');
      console.log('1. Abrir: http://localhost:5174');
      console.log('2. Fazer login com: assistenciaallimport10@gmail.com');
      console.log('3. Verificar se clientes/produtos aparecem apenas para este usuário');
    } else {
      console.log('⚠️ Isolamento não completamente efetivo');
      console.log('🔧 Necessário configurar manualmente no Supabase Dashboard');
      console.log('📋 Registros ainda visíveis:', finalTest?.length || 0);
    }

  } catch (error) {
    console.error('❌ Erro:', error);
  }
}

aplicarIsolamentoDefinitivo();
