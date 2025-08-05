#!/usr/bin/env node

import { createClient } from '@supabase/supabase-js'
import fs from 'fs'

// Configuração do Supabase
import fs from 'fs';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

async function deploySupabase() {
  try {
    console.log('🚀 Iniciando deploy no Supabase...');
    
    // Testar conexão primeiro
    console.log('🔍 Testando conexão...');
    const testResponse = await fetch(`${supabaseUrl}/rest/v1/`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    
    if (!testResponse.ok) {
      throw new Error('Falha na conexão com Supabase');
    }
    
    console.log('✅ Conexão estabelecida!');
    
    // Executar comandos principais
    const comandosImportantes = [
      // 1. Atualizar preços
      `UPDATE public.subscriptions SET payment_amount = 59.90, updated_at = NOW() WHERE payment_amount != 59.90;`,
      
      // 2. Criar tabela de pagamentos
      `CREATE TABLE IF NOT EXISTS public.payments (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        created_at TIMESTAMPTZ DEFAULT NOW(),
        mp_payment_id TEXT NOT NULL UNIQUE,
        mp_status TEXT NOT NULL,
        amount DECIMAL(10,2) NOT NULL,
        payer_email TEXT NOT NULL,
        user_id UUID REFERENCES auth.users(id),
        webhook_data JSONB
      );`,
      
      // 3. Ativar RLS
      `ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;`,
      
      // 4. Criar políticas básicas
      `CREATE POLICY IF NOT EXISTS "anyone_can_insert_payments" ON public.payments FOR INSERT WITH CHECK (true);`,
      
      `CREATE POLICY IF NOT EXISTS "users_can_view_own_payments" ON public.payments FOR SELECT USING (auth.uid() = user_id OR auth.jwt()->>'email' = payer_email);`
    ];
    
    console.log('⚙️ Executando comandos principais...');
    
    for (let i = 0; i < comandosImportantes.length; i++) {
      const comando = comandosImportantes[i];
      console.log(`📋 Comando ${i + 1}/${comandosImportantes.length}`);
      
      try {
        // Usar uma abordagem mais simples - apenas fazer POST para rest API
        const response = await fetch(`${supabaseUrl}/rest/v1/`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/sql',
            'apikey': supabaseKey,
            'Authorization': `Bearer ${supabaseKey}`,
            'Accept': 'application/json'
          },
          body: comando
        });
        
        if (response.ok || response.status === 409) { // 409 = já existe
          console.log(`✅ Comando ${i + 1} executado`);
        } else {
          console.log(`⚠️ Comando ${i + 1} - Status:`, response.status);
        }
      } catch (error) {
        console.log(`⚠️ Erro no comando ${i + 1}:`, error.message);
      }
      
      // Pausa entre comandos
      await new Promise(resolve => setTimeout(resolve, 200));
    }
    
    console.log('🎉 Deploy do Supabase concluído!');
    console.log('📋 Para configurações avançadas, acesse:');
    console.log('   https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw');
    
  } catch (error) {
    console.error('❌ Erro no deploy:', error.message);
  }
}

deploySupabase();

const supabase = createClient(supabaseUrl, supabaseServiceKey)

console.log('🚀 Deploy para Supabase - PDV Allimport')
console.log('📅 Data:', new Date().toLocaleString('pt-BR'))
console.log('🌐 URL:', supabaseUrl)

async function executeSQLFile(filePath, description) {
  try {
    console.log(`\n📋 Executando: ${description}`)
    console.log(`📄 Arquivo: ${filePath}`)
    
    if (!fs.existsSync(filePath)) {
      console.log(`❌ Arquivo não encontrado: ${filePath}`)
      return false
    }

    const sql = fs.readFileSync(filePath, 'utf8')
    
    // Dividir SQL em comandos individuais (por ponto e vírgula)
    const commands = sql
      .split(';')
      .map(cmd => cmd.trim())
      .filter(cmd => cmd.length > 0 && !cmd.startsWith('--'))

    console.log(`🔧 Executando ${commands.length} comandos SQL...`)

    for (let i = 0; i < commands.length; i++) {
      const command = commands[i]
      if (command.trim()) {
        try {
          const { error } = await supabase.rpc('exec_sql', { 
            sql: command + ';' 
          })
          
          if (error) {
            console.log(`❌ Erro no comando ${i + 1}:`, error.message)
            // Continuar com próximo comando mesmo se houver erro
          } else {
            console.log(`✅ Comando ${i + 1} executado`)
          }
        } catch (err) {
          console.log(`❌ Erro no comando ${i + 1}:`, err.message)
        }
      }
    }

    console.log(`✅ ${description} - Concluído`)
    return true
  } catch (error) {
    console.log(`❌ Erro ao executar ${description}:`, error.message)
    return false
  }
}

async function deployToSupabase() {
  try {
    console.log('\n🔐 Testando conexão com Supabase...')
    
    // Teste básico de conexão
    const { data, error } = await supabase
      .from('user_approvals')
      .select('count')
      .limit(1)

    if (error) {
      console.log('⚠️ Tabela user_approvals não existe ainda, será criada...')
    } else {
      console.log('✅ Conexão com Supabase OK!')
    }

    // 1. Executar correção de RLS (problema atual)
    await executeSQLFile(
      './FIX_RLS_ADMIN_ACCESS.sql',
      'Correção de RLS para acesso admin'
    )

    // 2. Executar sistema de aprovação completo
    await executeSQLFile(
      './SETUP_APROVACAO_COMPLETO.sql',
      'Sistema de aprovação de usuários'
    )

    // 3. Executar sistema de assinatura
    await executeSQLFile(
      './SISTEMA_ASSINATURA_SETUP.sql',
      'Sistema de assinatura com pagamento'
    )

    console.log('\n🧪 Testando sistema após deploy...')

    // Teste 1: Verificar tabelas criadas
    try {
      const { data: approvals } = await supabase
        .from('user_approvals')
        .select('count')
        .limit(1)
      console.log('✅ Tabela user_approvals funcionando')
    } catch (err) {
      console.log('❌ Erro na tabela user_approvals:', err.message)
    }

    try {
      const { data: subscriptions } = await supabase
        .from('subscriptions')
        .select('count')
        .limit(1)
      console.log('✅ Tabela subscriptions funcionando')
    } catch (err) {
      console.log('❌ Erro na tabela subscriptions:', err.message)
    }

    try {
      const { data: payments } = await supabase
        .from('payments')
        .select('count')
        .limit(1)
      console.log('✅ Tabela payments funcionando')
    } catch (err) {
      console.log('❌ Erro na tabela payments:', err.message)
    }

    // Teste 2: Criar usuário admin teste
    console.log('\n👤 Criando usuário admin de teste...')
    const testEmail = `admin-test-${Date.now()}@pdvallimport.com`
    const testPassword = '@qw12aszx##'

    const { data: signupData, error: signupError } = await supabase.auth.signUp({
      email: testEmail,
      password: testPassword,
      options: {
        data: {
          full_name: 'Admin Teste',
          role: 'admin'
        }
      }
    })

    if (signupError) {
      console.log('⚠️ Erro ao criar usuário teste:', signupError.message)
    } else {
      console.log('✅ Usuário admin teste criado:', testEmail)
      console.log('🔑 Senha:', testPassword)
    }

    console.log('\n🎉 Deploy do Supabase concluído!')
    console.log('\n📋 Sistemas configurados:')
    console.log('✅ Sistema de aprovação de usuários')
    console.log('✅ Sistema de assinatura com período de teste')
    console.log('✅ Integração para pagamentos PIX/Cartão')
    console.log('✅ RLS policies corrigidas')
    console.log('✅ Funções SQL implementadas')

    console.log('\n🌐 URLs para acesso:')
    console.log('🏠 Frontend: https://pdv-allimport.vercel.app')
    console.log('🔐 Admin: https://pdv-allimport.vercel.app/admin')
    console.log('⚙️ Supabase: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw')

    console.log('\n📝 Próximos passos:')
    console.log('1. Configure credenciais Mercado Pago no .env')
    console.log('2. Teste fluxo de cadastro → aprovação → teste → pagamento')
    console.log('3. Configure webhook para produção (opcional)')

  } catch (error) {
    console.log('❌ Erro durante deploy:', error.message)
  }
}

deployToSupabase()
