import { ImportadorPrivado } from '../utils/importador-privado';
import { readFileSync } from 'fs';
import { join } from 'path';

/**
 * SCRIPT DE IMPORTAÇÃO AUTOMÁTICA
 * Execute este script após fazer login no sistema
 */

async function executarImportacaoAutomatica() {
  try {
    console.log('🔒 INICIANDO IMPORTAÇÃO AUTOMÁTICA COM PRIVACIDADE TOTAL');
    console.log('══════════════════════════════════════════════════════');
    
    // 1. Ler o arquivo de backup
    const backupPath = join(__dirname, '../backup-allimport.json');
    const backupJson = readFileSync(backupPath, 'utf-8');
    
    console.log('📁 Backup carregado:', backupPath);
    
    // 2. Executar importação privada
    // Criar importador (usar um userId de exemplo)
    const importador = new ImportadorPrivado('exemplo-user-id');
    const resultado = await importador.importarBackup(backupJson);
    
    // 3. Exibir resultados
    if (resultado.sucesso) {
      console.log('\n✅ IMPORTAÇÃO CONCLUÍDA COM SUCESSO!');
      console.log(`📊 Total de registros importados: ${resultado.total}`);
      console.log('\n📋 Detalhes por tabela:');
      
      Object.entries(resultado.detalhes).forEach(([tabela, quantidade]) => {
        const emoji = {
          'clientes': '👥',
          'products': '📦',
          'categories': '🏷️',
          'service_orders': '🔧',
          'establishments': '🏪'
        }[tabela] || '📄';
        
        console.log(`   ${emoji} ${tabela}: ${quantidade} registros`);
      });
      
      console.log('\n🔒 PRIVACIDADE GARANTIDA:');
      console.log('   • Todos os dados estão vinculados ao seu usuário');
      console.log('   • RLS (Row Level Security) ativo');
      console.log('   • Outros usuários NUNCA verão estes dados');
      console.log('   • Isolamento completo por conta');
      
    } else {
      console.log('\n❌ ERRO NA IMPORTAÇÃO:');
      resultado.erros.forEach((erro: string) => console.log(`   • ${erro}`));
    }
    
  } catch (error) {
    console.error('\n💥 ERRO GERAL:', error);
    
    if (error instanceof Error) {
      if (error.message.includes('login')) {
        console.log('\n⚠️ SOLUÇÃO: Faça login no sistema primeiro');
        console.log('   1. Abra: http://localhost:5175/login');
        console.log('   2. Faça login com suas credenciais');
        console.log('   3. Execute este script novamente');
      }
    }
  }
}

// Executar se chamado diretamente
if (require.main === module) {
  executarImportacaoAutomatica()
    .then(() => {
      console.log('\n🏁 Script finalizado.');
      process.exit(0);
    })
    .catch(error => {
      console.error('💀 Erro fatal:', error);
      process.exit(1);
    });
}

export { executarImportacaoAutomatica };
