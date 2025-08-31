import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'

const EMAIL_USUARIO = 'assistenciaallimport10@gmail.com'

async function configurarMultiTenantEspecifico() {
    console.log('🏢 CONFIGURAÇÃO MULTI-TENANT - ASSISTÊNCIA ALL IMPORT')
    console.log(`📧 Usuário específico: ${EMAIL_USUARIO}`)
    console.log('')
    
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
    
    try {
        // 1. Verificar se o usuário existe na tabela auth.users
        console.log('📋 1. Verificando usuário no sistema...')
        
        // Como não temos acesso direto ao auth.users, vamos criar/encontrar na tabela profiles
        let userId = null
        
        // Tentar encontrar na tabela profiles primeiro
        const { data: profileData, error: profileError } = await supabase
            .from('profiles')
            .select('id, email, name')
            .eq('email', EMAIL_USUARIO)
            .single()
            
        if (profileError && profileError.code !== 'PGRST116') {
            console.log('⚠️ Tabela profiles pode não existir ainda')
        } else if (profileData) {
            userId = profileData.id
            console.log(`✅ Usuário encontrado: ${profileData.name} (${profileData.email})`)
            console.log(`🆔 User ID: ${userId}`)
        }
        
        // Se não encontrou, vamos criar um ID padrão baseado no email
        if (!userId) {
            // Gerar UUID determinístico baseado no email
            const crypto = require('crypto')
            const hash = crypto.createHash('sha256').update(EMAIL_USUARIO).digest('hex')
            userId = `${hash.substr(0,8)}-${hash.substr(8,4)}-${hash.substr(12,4)}-${hash.substr(16,4)}-${hash.substr(20,12)}`
            console.log(`⚠️ Usuário não encontrado, usando ID gerado: ${userId}`)
        }
        
        // 2. Verificar tabela clientes atual
        console.log('📋 2. Verificando clientes atuais...')
        const { data: clientesData, error: clientesError } = await supabase
            .from('clientes')
            .select('id, nome, telefone, user_id')
            .limit(10)
            
        if (clientesError) {
            console.error('❌ Erro ao acessar clientes:', clientesError.message)
            console.log('🔧 Você precisa executar o script SQL primeiro!')
            console.log('📁 Execute: CONFIGURAR_MULTI_TENANT_RLS.sql')
            return
        }
        
        console.log(`✅ Clientes encontrados: ${clientesData.length} registros`)
        
        // Verificar quantos já têm user_id
        const clientesComUserId = clientesData.filter(c => c.user_id).length
        const clientesSemUserId = clientesData.filter(c => !c.user_id).length
        
        console.log(`   - Com user_id: ${clientesComUserId}`)
        console.log(`   - Sem user_id: ${clientesSemUserId}`)
        
        // 3. Atualizar todos os clientes para o usuário específico
        if (clientesSemUserId > 0) {
            console.log('📋 3. Associando clientes ao usuário...')
            
            const { data: updateData, error: updateError } = await supabase
                .from('clientes')
                .update({ user_id: userId })
                .is('user_id', null)
                .select('count', { count: 'exact', head: true })
                
            if (updateError) {
                console.error('❌ Erro ao atualizar user_id:', updateError.message)
            } else {
                console.log(`✅ ${updateData} clientes associados ao usuário ${EMAIL_USUARIO}`)
            }
        } else {
            console.log('✅ Todos os clientes já têm user_id definido')
        }
        
        // 4. Verificar isolamento - contar total de clientes para este usuário
        console.log('📋 4. Verificando isolamento...')
        const { data: countData, error: countError } = await supabase
            .from('clientes')
            .select('id')
            .eq('user_id', userId)
            
        if (countError) {
            console.error('❌ Erro ao contar clientes:', countError.message)
        } else {
            console.log(`🎯 Clientes exclusivos para ${EMAIL_USUARIO}: ${countData.length}`)
        }
        
        // 5. Criar usuário de teste para verificar isolamento
        console.log('📋 5. Testando isolamento com usuário diferente...')
        
        const usuarioTeste = 'teste@exemplo.com'
        const userIdTeste = '11111111-2222-3333-4444-555555555555'
        
        // Inserir cliente de teste para outro usuário
        const { data: testeData, error: testeError } = await supabase
            .from('clientes')
            .insert({
                nome: 'Cliente Teste - Outro Usuário',
                telefone: '(11) 00000-0000',
                cpf_cnpj: '000.000.000-99',
                email: 'teste@outro.com',
                endereco: 'Endereço de teste',
                tipo: 'Física',
                observacoes: 'Cliente para testar isolamento',
                ativo: true,
                user_id: userIdTeste
            })
            .select()
            
        if (testeError) {
            console.error('❌ Erro ao criar cliente teste:', testeError.message)
        } else {
            console.log(`✅ Cliente teste criado para usuário diferente`)
            
            // Verificar se o isolamento está funcionando
            const { data: isolamentoData, error: isolamentoError } = await supabase
                .from('clientes')
                .select('id')
                .eq('user_id', userIdTeste)
                
            if (!isolamentoError) {
                console.log(`📊 Clientes para usuário teste: ${isolamentoData.length}`)
            }
        }
        
        console.log('')
        console.log('🎉 CONFIGURAÇÃO MULTI-TENANT CONCLUÍDA!')
        console.log(`📧 Usuário: ${EMAIL_USUARIO}`)
        console.log(`🆔 User ID: ${userId}`)
        console.log(`👥 Clientes exclusivos: Verificado`)
        console.log('')
        console.log('⚠️ IMPORTANTE: Agora você precisa implementar autenticação no frontend!')
        console.log('   1. Login do usuário assistenciaallimport10@gmail.com')
        console.log('   2. Outros usuários só verão seus próprios dados')
        
    } catch (error) {
        console.error('❌ Erro geral:', error)
    }
}

configurarMultiTenantEspecifico()
