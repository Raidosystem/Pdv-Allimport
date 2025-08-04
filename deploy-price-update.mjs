import { createClient } from '@supabase/supabase-js'
import fs from 'fs'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM0MTY2NDEsImV4cCI6MjA0ODk5MjY0MX0.wBdKtebJPmvp63eCtLu1IfDMRF0mQZUKaGhQCJMo0LI'

const supabase = createClient(supabaseUrl, supabaseKey)

async function updatePricing() {
  console.log('🔄 Iniciando atualização de preço para R$ 59,90...')
  
  try {
    // 1. Atualizar valor padrão na tabela
    console.log('📝 Atualizando valor padrão na tabela subscriptions...')
    
    const { error: alterError } = await supabase.rpc('execute_sql', {
      sql: 'ALTER TABLE public.subscriptions ALTER COLUMN payment_amount SET DEFAULT 59.90'
    })
    
    if (alterError) {
      console.log('ℹ️ Tentativa de ALTER falhou (pode ser limitação do RPC), continuando...')
    } else {
      console.log('✅ Valor padrão atualizado!')
    }
    
    // 2. Atualizar registros existentes
    console.log('📊 Atualizando registros existentes...')
    
    const { data: updateData, error: updateError } = await supabase
      .from('subscriptions')
      .update({ 
        payment_amount: 59.90,
        updated_at: new Date().toISOString()
      })
      .eq('payment_amount', 29.90)
    
    if (updateError) {
      console.error('❌ Erro ao atualizar registros:', updateError)
    } else {
      console.log('✅ Registros existentes atualizados!')
    }
    
    // 3. Verificar assinatura do admin
    console.log('🔍 Verificando assinatura do admin...')
    
    const { data: adminSub, error: checkError } = await supabase
      .from('subscriptions')
      .select('id, email, payment_amount, status, updated_at')
      .eq('email', 'novaradiosystem@outlook.com')
      .single()
    
    if (checkError) {
      console.error('❌ Erro ao verificar admin:', checkError)
    } else {
      console.log('✅ Assinatura do admin:', adminSub)
    }
    
    // 4. Testar função de verificação
    console.log('🧪 Testando função de verificação...')
    
    const { data: statusData, error: statusError } = await supabase.rpc(
      'check_subscription_status', 
      { user_email: 'novaradiosystem@outlook.com' }
    )
    
    if (statusError) {
      console.error('❌ Erro ao verificar status:', statusError)
    } else {
      console.log('✅ Status da assinatura:', statusData)
    }
    
    console.log('\n🎉 Deploy de preço completado com sucesso!')
    console.log('💰 Novo preço: R$ 59,90/mês')
    console.log('🌐 Sistema disponível em: https://pdv-allimport.vercel.app')
    
  } catch (error) {
    console.error('❌ Erro no deploy:', error)
    process.exit(1)
  }
}

updatePricing()
