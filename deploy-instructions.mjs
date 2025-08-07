import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Credenciais do Supabase não encontradas');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function deploySimple() {
  try {
    console.log('🚀 DEPLOY ULTRA SEGURO - MÉTODO SIMPLIFICADO');
    console.log('===========================================');
    
    // Ler o arquivo SQL
    const sqlContent = fs.readFileSync('./deploy-ultra-seguro.sql', 'utf8');
    console.log('📄 Arquivo SQL carregado:', sqlContent.length, 'caracteres');
    
    console.log('');
    console.log('📋 INSTRUÇÕES PARA EXECUTAR O DEPLOY:');
    console.log('');
    console.log('1. Acesse o Supabase Dashboard:');
    console.log('   🔗 https://supabase.com/dashboard/projects');
    console.log('');
    console.log('2. Vá para o SQL Editor:');
    console.log('   📝 Clique em "SQL Editor" na barra lateral');
    console.log('');
    console.log('3. Cole o script SQL:');
    console.log('   📋 Copie todo o conteúdo do arquivo deploy-ultra-seguro.sql');
    console.log('   📝 Cole no editor SQL');
    console.log('');
    console.log('4. Execute o script:');
    console.log('   ▶️ Clique em "Run" para executar');
    console.log('');
    console.log('🔍 VERIFICANDO CONEXÃO ATUAL...');
    
    // Testar conexão básica
    const { data, error } = await supabase.from('auth.users').select('count').limit(1);
    
    if (error) {
      console.log('❌ Conexão com Supabase:', error.message);
      console.log('');
      console.log('⚠️ SOLUÇÃO:');
      console.log('1. Verifique as credenciais no arquivo .env');
      console.log('2. Execute o SQL manualmente no Dashboard do Supabase');
    } else {
      console.log('✅ Conexão com Supabase: OK');
      console.log('');
      console.log('🎯 PRONTO PARA EXECUTAR O DEPLOY!');
      console.log('');
      console.log('💡 DICA: Se você tem acesso admin ao Supabase,');
      console.log('   execute o SQL diretamente no Dashboard para melhor resultado.');
    }
    
    console.log('');
    console.log('📄 CONTEÚDO DO SCRIPT A SER EXECUTADO:');
    console.log('=====================================');
    console.log('📊 Tamanho:', sqlContent.length, 'caracteres');
    console.log('🏗️ Principais operações:');
    console.log('  • Criar/atualizar 9 tabelas principais');
    console.log('  • Adicionar coluna user_id em todas as tabelas');
    console.log('  • Habilitar Row Level Security (RLS)');
    console.log('  • Criar políticas de segurança');
    console.log('  • Criar funções de backup/restauração');
    console.log('  • Configurar triggers automáticos');
    console.log('');
    console.log('🎉 APÓS A EXECUÇÃO:');
    console.log('✅ Sistema de privacidade total ativo');
    console.log('✅ Backup automático configurado');
    console.log('✅ Interface de backup disponível em /configuracoes');
    console.log('');
    
    // Criar arquivo de instruções
    const instructions = `
# 🚀 INSTRUÇÕES DE DEPLOY - PDV ALLIMPORT

## ⚡ EXECUÇÃO RÁPIDA

1. **Acesse o Supabase Dashboard:**
   https://supabase.com/dashboard/projects

2. **Vá para SQL Editor:**
   Clique em "SQL Editor" na barra lateral

3. **Cole e execute o script:**
   - Copie todo o conteúdo do arquivo: deploy-ultra-seguro.sql
   - Cole no editor SQL
   - Clique em "Run"

## 🎯 RESULTADO ESPERADO

Após a execução, você verá mensagens como:
- ✅ Coluna user_id adicionada à tabela [nome]
- ✅ RLS habilitado para tabela [nome]  
- ✅ Política RLS criada para tabela [nome]
- ✅ Trigger criado para tabela [nome]

## 🔒 SISTEMA ATIVADO

- 🛡️ Privacidade total por usuário
- 💾 Backup automático diário
- 🔐 Row Level Security (RLS)
- 🔄 Funções de backup/restore
- ⚙️ Interface em /configuracoes

## 🌐 TESTE O SISTEMA

Após deploy, acesse: http://localhost:5174/configuracoes
E clique em "Backup e Restauração"
`;
    
    fs.writeFileSync('./DEPLOY_INSTRUCTIONS.md', instructions);
    console.log('📝 Instruções salvas em: DEPLOY_INSTRUCTIONS.md');
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  }
}

deploySimple();
