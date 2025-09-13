export async function debugDatabase() {
  try {
    console.log('🔍 Iniciando debug do banco de dados...')
    
    // Verificar backup
    const response = await fetch('/backup-allimport.json')
    const backupData = await response.json()
    
    console.log('📊 Estatísticas do backup:')
    console.log('- Vendas:', backupData.data?.sales?.length || 0)
    console.log('- Ordens de Serviço:', backupData.data?.service_orders?.length || 0)
    console.log('- Produtos:', backupData.data?.products?.length || 0)
    console.log('- Clientes:', backupData.data?.clients?.length || 0)
    
    return {
      success: true,
      data: backupData.data,
      message: 'Debug concluído com sucesso'
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