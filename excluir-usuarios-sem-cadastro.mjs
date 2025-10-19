import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'

const supabase = createClient(supabaseUrl, supabaseKey)

async function excluirUsuariosSemCadastro() {
  try {
    console.log('\n🔍 Buscando usuários sem cadastro...\n')

    // 1. Buscar todas as subscriptions
    const { data: subscriptions, error: subError } = await supabase
      .from('subscriptions')
      .select('user_id, email, status')

    if (subError) {
      console.error('❌ Erro ao buscar subscriptions:', subError)
      return
    }

    // 2. Buscar todos os user_approvals
    const { data: userApprovals, error: uaError } = await supabase
      .from('user_approvals')
      .select('user_id')

    if (uaError) {
      console.error('❌ Erro ao buscar user_approvals:', uaError)
      return
    }

    // 3. Criar Set com user_ids que TÊM cadastro
    const userIdsComCadastro = new Set(userApprovals.map(u => u.user_id))

    // 4. Filtrar user_ids SEM cadastro
    const userIdsSemCadastro = subscriptions
      .filter(sub => !userIdsComCadastro.has(sub.user_id))
      .map(sub => sub.user_id)

    console.log(`📊 Total de assinaturas: ${subscriptions.length}`)
    console.log(`✅ Com cadastro completo: ${subscriptions.length - userIdsSemCadastro.length}`)
    console.log(`❌ Sem cadastro (serão deletadas): ${userIdsSemCadastro.length}\n`)

    if (userIdsSemCadastro.length === 0) {
      console.log('✅ Não há usuários sem cadastro para excluir!')
      return
    }

    // 5. Mostrar quais serão excluídos
    console.log('🗑️ Usuários que serão EXCLUÍDOS:')
    subscriptions
      .filter(sub => !userIdsComCadastro.has(sub.user_id))
      .forEach(sub => {
        console.log(`   - ${sub.email || sub.user_id.substring(0, 12)} (${sub.status})`)
      })

    console.log('\n⚠️  EXECUTANDO EXCLUSÃO em 3 segundos...\n')
    await new Promise(resolve => setTimeout(resolve, 3000))

    // 6. DELETAR subscriptions sem cadastro
    const { error: deleteError } = await supabase
      .from('subscriptions')
      .delete()
      .in('user_id', userIdsSemCadastro)

    if (deleteError) {
      console.error('❌ Erro ao deletar:', deleteError)
      return
    }

    console.log('✅ EXCLUSÃO CONCLUÍDA COM SUCESSO!\n')

    // 7. Verificar resultado final
    const { data: remaining, error: checkError } = await supabase
      .from('subscriptions')
      .select('user_id, email, status')
      .order('created_at', { ascending: false })

    if (!checkError) {
      console.log(`📊 Assinaturas restantes: ${remaining.length}`)
      console.log('\n👥 Usuários mantidos:')
      remaining.forEach(sub => {
        console.log(`   ✅ ${sub.email || sub.user_id.substring(0, 12)} (${sub.status})`)
      })
    }

    console.log('\n🎉 Processo finalizado!\n')

  } catch (error) {
    console.error('❌ Erro:', error)
  }
}

// Executar
excluirUsuariosSemCadastro()
