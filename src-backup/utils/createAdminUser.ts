import { supabase } from '../lib/supabase'

export async function createAdminUser() {
  try {
    // Usar signup normal em vez de admin.createUser
    const { data, error } = await supabase.auth.signUp({
      email: 'novaradiosystem@outlook.com',
      password: '@qw12aszx##',
      options: {
        data: {
          full_name: 'Administrador Principal',
          role: 'admin'
        }
      }
    })

    if (error) {
      console.error('Erro ao criar usuário admin:', error)
      return { success: false, error: error.message }
    }

    console.log('✅ Usuário administrador criado com sucesso:', data.user?.email)
    return { success: true, user: data.user }
  } catch (error) {
    console.error('Erro inesperado:', error)
    return { success: false, error: 'Erro inesperado ao criar usuário' }
  }
}

export async function ensureAdminUserExists() {
  try {
    // Tentar fazer login para verificar se o usuário já existe
    const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({
      email: 'novaradiosystem@outlook.com',
      password: '@qw12aszx##'
    })

    if (!loginError && loginData.user) {
      // Usuário já existe e login funcionou
      console.log('✅ Usuário administrador já existe')
      
      // Fazer logout para não interferir com o estado atual
      await supabase.auth.signOut()
      
      return { success: true, exists: true, user: loginData.user, error: undefined }
    }

    // Se o login falhou, provavelmente o usuário não existe, então vamos criar
    const result = await createAdminUser()
    return { ...result, exists: false }
  } catch (error) {
    console.error('Erro inesperado:', error)
    return { success: false, error: 'Erro inesperado', exists: false }
  }
}
