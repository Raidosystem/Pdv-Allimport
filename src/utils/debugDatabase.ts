export async function debugDatabase() {
  try {
    console.log('🔍 Debug do banco de dados - BACKUP DESABILITADO')
    
    // BACKUP DESABILITADO - Retornando dados padrão
    console.log('📊 BACKUP DESABILITADO - Usando apenas Supabase com RLS')
    
    return {
      success: true,
      data: null, // BACKUP DESABILITADO
      message: 'Debug concluído - Backup desabilitado, usando apenas Supabase'
    }
  } catch (error) {
    console.error('❌ Erro no debug:', error)
    return {
      success: false,
      error: error,
      message: 'Erro durante o debug'
    }
  }
}