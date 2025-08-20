/**
 * SCRIPT DE IMPORTAÇÃO AUTOMÁTICA PARA LOCALHOST
 * Faz login e importa backup automaticamente
 */

import { supabase } from '../lib/supabase';
import { ImportadorPrivado } from '../utils/importador-privado';

async function importarBackupAutomatico() {
  try {
    console.log('🚀 Iniciando importação automática...');

    // 1. FAZER LOGIN
    const email = 'assistenciaallimport10@gmail.com';
    console.log(`🔐 Fazendo login com: ${email}`);
    
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: email,
      password: 'sua_senha_aqui' // ⚠️ SUBSTITUA PELA SENHA CORRETA
    });

    if (authError || !authData.user) {
      console.error('❌ Erro no login:', authError);
      return;
    }

    console.log('✅ Login realizado com sucesso!');
    console.log('👤 User ID:', authData.user.id);

    // 2. CARREGAR BACKUP DO LOCALHOST
    console.log('📦 Carregando backup do localhost...');
    
    const response = await fetch('http://localhost:5175/backup-allimport.json');
    
    if (!response.ok) {
      throw new Error(`Erro ao carregar backup: ${response.status}`);
    }

    const backupData = await response.json();
    console.log('✅ Backup carregado com sucesso!');
    console.log('📊 Estrutura do backup:', {
      clients: backupData.data?.clients?.length || 0,
      products: backupData.data?.products?.length || 0,
      categories: backupData.data?.categories?.length || 0,
      service_orders: backupData.data?.service_orders?.length || 0,
      service_parts: backupData.data?.service_parts?.length || 0
    });

    // 3. EXECUTAR IMPORTAÇÃO PRIVADA
    console.log('🔄 Iniciando importação privada...');
    
    const importador = new ImportadorPrivado(authData.user.id);
    const resultado = await importador.importarBackup(backupData);

    // 4. MOSTRAR RESULTADO
    console.log('🎉 RESULTADO DA IMPORTAÇÃO:');
    console.log('-----------------------------------');
    console.log(`✅ Sucesso: ${resultado.sucesso}`);
    console.log(`📊 Total importado: ${resultado.total} registros`);
    console.log(`⏱️ Tempo de execução: ${resultado.tempoExecucao}`);
    
    if (Object.keys(resultado.detalhes).length > 0) {
      console.log('\n📋 DETALHES POR TABELA:');
      Object.entries(resultado.detalhes).forEach(([tabela, count]) => {
        console.log(`  • ${tabela}: ${count} registros`);
      });
    }

    if (resultado.avisos && resultado.avisos.length > 0) {
      console.log('\n⚠️ AVISOS:');
      resultado.avisos.forEach(aviso => console.log(`  • ${aviso}`));
    }

    if (resultado.erros.length > 0) {
      console.log('\n❌ ERROS:');
      resultado.erros.forEach(erro => console.log(`  • ${erro}`));
    }

    console.log('-----------------------------------');
    console.log('🏁 Importação concluída!');

  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

// Executar se for chamado diretamente
if (typeof window !== 'undefined') {
  // No browser
  (window as any).importarBackupAutomatico = importarBackupAutomatico;
  console.log('🌐 Função disponível no console: importarBackupAutomatico()');
} else {
  // No Node.js
  importarBackupAutomatico();
}

export { importarBackupAutomatico };
