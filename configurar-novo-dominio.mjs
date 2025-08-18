/**
 * CONFIGURAR SUPABASE PARA NOVO DOMÍNIO
 * URL: https://pdv.crmvsystem.com/
 * 
 * Execute este script no dashboard do Supabase ou via terminal
 */

import { createClient } from '@supabase/supabase-js'

// Configurações do Supabase (substitua pelos valores reais)
const SUPABASE_URL = 'SEU_SUPABASE_URL'
const SUPABASE_SERVICE_KEY = 'SEU_SUPABASE_SERVICE_KEY' // Chave de serviço (não anon!)

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

async function configurarNovodominio() {
  console.log('🚀 Configurando Supabase para novo domínio...')

  try {
    // 1. Verificar configuração atual
    console.log('\n📋 Verificando configuração atual...')
    
    // 2. Criar usuário admin se não existir
    console.log('\n👤 Verificando usuário admin...')
    const { data: users, error: usersError } = await supabase.auth.admin.listUsers()
    
    if (usersError) {
      console.error('❌ Erro ao listar usuários:', usersError)
    } else {
      console.log(`✅ Encontrados ${users.users.length} usuários`)
      
      const adminUser = users.users.find(u => u.email === 'novaradiosystem@outlook.com')
      
      if (!adminUser) {
        console.log('👤 Criando usuário admin...')
        const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
          email: 'novaradiosystem@outlook.com',
          password: 'Admin123!@#',
          email_confirm: true,
          user_metadata: {
            role: 'admin',
            name: 'Administrador',
            created_by: 'setup_script'
          }
        })
        
        if (createError) {
          console.error('❌ Erro ao criar usuário admin:', createError)
        } else {
          console.log('✅ Usuário admin criado:', newUser.user?.email)
        }
      } else {
        console.log('✅ Usuário admin já existe:', adminUser.email)
      }
    }

    // 3. Configurar RLS e políticas
    console.log('\n🔒 Configurando RLS e políticas...')
    
    const tables = [
      'clientes', 'produtos', 'vendas', 'itens_venda', 
      'caixa', 'movimentos_caixa', 'relatorios'
    ]
    
    for (const table of tables) {
      try {
        // Habilitar RLS
        const { error: rlsError } = await supabase.rpc('exec_sql', {
          sql: `ALTER TABLE IF EXISTS public.${table} ENABLE ROW LEVEL SECURITY;`
        })
        
        if (rlsError) {
          console.warn(`⚠️ Erro RLS ${table}:`, rlsError.message)
        }
        
        // Criar política
        const { error: policyError } = await supabase.rpc('exec_sql', {
          sql: `
            DROP POLICY IF EXISTS "Usuários autenticados podem acessar ${table}" ON public.${table};
            CREATE POLICY "Usuários autenticados podem acessar ${table}" ON public.${table}
              FOR ALL USING (auth.role() = 'authenticated');
          `
        })
        
        if (policyError) {
          console.warn(`⚠️ Erro política ${table}:`, policyError.message)
        } else {
          console.log(`✅ RLS e política configurados para: ${table}`)
        }
      } catch (err) {
        console.warn(`⚠️ Erro geral ${table}:`, err)
      }
    }

    // 4. Teste de autenticação
    console.log('\n🧪 Testando autenticação...')
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: 'novaradiosystem@outlook.com',
      password: 'Admin123!@#'
    })
    
    if (authError) {
      console.error('❌ Erro no teste de login:', authError)
    } else {
      console.log('✅ Login funcionando! Token:', authData.session?.access_token?.substring(0, 20) + '...')
      
      // Logout após teste
      await supabase.auth.signOut()
    }

    // 5. Teste de conexão com dados
    console.log('\n📊 Testando acesso aos dados...')
    const { data: clientesData, error: clientesError } = await supabase
      .from('clientes')
      .select('count', { count: 'exact', head: true })
    
    if (clientesError) {
      console.error('❌ Erro ao acessar clientes:', clientesError)
    } else {
      console.log(`✅ Acesso aos dados OK. Clientes cadastrados: ${clientesData || 0}`)
    }

    console.log('\n🎉 Configuração concluída!')
    console.log('📝 Próximos passos:')
    console.log('   1. Acesse: https://pdv.crmvsystem.com/')
    console.log('   2. Faça login com: novaradiosystem@outlook.com')
    console.log('   3. Senha temporária: Admin123!@#')
    console.log('   4. Altere a senha no primeiro acesso')

  } catch (error) {
    console.error('❌ Erro geral na configuração:', error)
  }
}

// Executar configuração se for script principal
if (typeof window === 'undefined') {
  configurarNovodominio()
}

export { configurarNovodominio }
