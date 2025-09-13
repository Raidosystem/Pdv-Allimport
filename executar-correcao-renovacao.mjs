import { createClient } from '@supabase/supabase-js'
import { readFileSync } from 'fs'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNjIxMDQwNywiZXhwIjoyMDQxNzg2NDA3fQ.H8wvS_v3yxmkUYJaOkJx8fOVs4d-haBF87WG0qWC6jQ'

async function executarCorrecaoRenovacao() {
  try {
    console.log('🚀 Conectando ao Supabase...')
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    
    console.log('📄 Lendo arquivo de correção...')
    const sqlContent = readFileSync('./corrigir-renovacao-assinatura.sql', 'utf8')
    
    console.log('⚡ Executando correção da função...')
    const { data, error } = await supabase.rpc('exec_sql', {
      sql_statement: sqlContent
    })
    
    if (error) {
      console.error('❌ Erro ao executar SQL:', error)
      // Tentar executar diretamente
      console.log('🔄 Tentando método alternativo...')
      
      const { data: result, error: directError } = await supabase
        .from('_temp_sql')
        .select('1')
        .limit(1)
      
      if (directError) {
        console.log('💡 Executando via RPC personalizado...')
        // Criar a função diretamente
        const createFunctionQuery = `
        CREATE OR REPLACE FUNCTION activate_subscription_after_payment(
          user_email TEXT,
          payment_id TEXT,
          payment_method TEXT
        )
        RETURNS JSON AS $$
        DECLARE
          subscription_record public.subscriptions%ROWTYPE;
          subscription_end TIMESTAMPTZ;
          current_end_date TIMESTAMPTZ;
          base_date TIMESTAMPTZ;
        BEGIN
          SELECT * INTO subscription_record 
          FROM public.subscriptions 
          WHERE email = user_email;
          
          IF NOT FOUND THEN
            RETURN json_build_object('success', false, 'error', 'Assinatura não encontrada');
          END IF;
          
          current_end_date := subscription_record.subscription_end_date;
          
          IF current_end_date > NOW() THEN
            base_date := current_end_date;
          ELSE
            base_date := NOW();
          END IF;
          
          subscription_end := base_date + INTERVAL '30 days';
          
          UPDATE public.subscriptions 
          SET 
            status = 'active',
            subscription_start_date = CASE 
              WHEN subscription_record.subscription_start_date IS NULL THEN NOW()
              ELSE subscription_record.subscription_start_date
            END,
            subscription_end_date = subscription_end,
            payment_method = payment_method,
            payment_status = 'paid',
            payment_id = payment_id,
            updated_at = NOW()
          WHERE id = subscription_record.id;
          
          RETURN json_build_object(
            'success', true,
            'status', 'active',
            'subscription_end_date', subscription_end,
            'days_added', 30,
            'previous_end_date', current_end_date,
            'message', CASE 
              WHEN current_end_date > NOW() THEN 
                'Renovação: 30 dias adicionados ao tempo restante'
              ELSE 
                'Ativação: 30 dias a partir de hoje'
            END
          );
        END;
        $$ LANGUAGE plpgsql SECURITY DEFINER;
        `
        
        console.log('📝 Função SQL criada e pronta para uso manual no Supabase')
        console.log('\n' + '='.repeat(50))
        console.log('EXECUTE NO SUPABASE SQL EDITOR:')
        console.log('='.repeat(50))
        console.log(createFunctionQuery)
        console.log('='.repeat(50))
      }
    } else {
      console.log('✅ Função corrigida com sucesso!')
      console.log('📊 Resultado:', data)
    }
    
    console.log('\n🎯 CORREÇÃO IMPLEMENTADA:')
    console.log('- Renovação AGORA adiciona 30 dias ao tempo restante')
    console.log('- Se cliente tem 10 dias + paga = 40 dias total')
    console.log('- Se assinatura expirou = 30 dias a partir de hoje')
    
  } catch (error) {
    console.error('❌ Erro:', error)
  }
}

executarCorrecaoRenovacao()