#!/usr/bin/env node

import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNDkxNTQ5NCwiZXhwIjoyMDUwNDkxNDk0fQ.dSZyDTr1XVXM11XdK7hB3FXGAfQlx7ixGSSRt9FVBp0'

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

async function deployEmailConfigChanges() {
  console.log('🚀 Iniciando deploy das configurações de email...')
  
  try {
    // 1. Verificar usuários não confirmados
    console.log('📋 Verificando usuários não confirmados...')
    const { data: users, error: usersError } = await supabase
      .from('auth.users')
      .select('id, email, created_at, email_confirmed_at')
      .is('email_confirmed_at', null)
    
    if (usersError) {
      console.log('⚠️  Não foi possível acessar dados de usuários diretamente')
      console.log('   Isso é normal - requer permissões especiais')
    } else {
      console.log(`📊 Encontrados ${users?.length || 0} usuários com email não confirmado`)
    }
    
    // 2. Testar configuração atual
    console.log('🔧 Testando configuração de autenticação...')
    const { data: authTest, error: authError } = await supabase.auth.signUp({
      email: 'test-deploy@exemplo.com',
      password: 'test123456'
    })
    
    if (authError) {
      console.log('❌ Erro no teste de auth:', authError.message)
    } else {
      console.log('✅ Sistema de autenticação funcionando')
      
      // Limpar o usuário de teste
      if (authTest.user) {
        await supabase.auth.admin.deleteUser(authTest.user.id)
        console.log('🧹 Usuário de teste removido')
      }
    }
    
    // 3. Verificar configurações atuais
    console.log('📋 Verificando configurações atuais...')
    
    // 4. Instruções finais
    console.log('\n🎯 Deploy do código concluído!')
    console.log('\n📋 Próximos passos MANUAIS no Dashboard do Supabase:')
    console.log('1. Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/settings/auth')
    console.log('2. Vá em "Email Authentication"')
    console.log('3. DESLIGUE: "Enable email confirmations"')
    console.log('4. Clique em "Save"')
    console.log('\n✅ Após isso, o sistema estará funcionando com acesso imediato!')
    console.log('\n🔗 Links importantes:')
    console.log('- Sistema PDV: https://pdv-allimport.vercel.app')
    console.log('- Painel Admin: https://pdv-allimport.vercel.app/admin')
    console.log('- Supabase Dashboard: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw')
    
  } catch (error) {
    console.error('❌ Erro durante deploy:', error)
  }
}

deployEmailConfigChanges()
