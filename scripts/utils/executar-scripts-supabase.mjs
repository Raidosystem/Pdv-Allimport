#!/usr/bin/env node

import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

console.log('🚀 EXECUTANDO SCRIPTS DO SUPABASE...\n');

// Instruções para o usuário
console.log('📋 INSTRUÇÕES:');
console.log('1. Acesse seu projeto no Supabase Dashboard');
console.log('2. Vá em "SQL Editor"');
console.log('3. Execute os scripts na ordem correta:\n');

console.log('═══════════════════════════════════════════════════════════════');
console.log('📄 SCRIPT 1: CONFIGURAR_STORAGE_EMPRESAS.sql');
console.log('═══════════════════════════════════════════════════════════════');

try {
  const storageScript = readFileSync(join(__dirname, 'CONFIGURAR_STORAGE_EMPRESAS.sql'), 'utf8');
  console.log(storageScript);
} catch (error) {
  console.error('❌ Erro ao ler CONFIGURAR_STORAGE_EMPRESAS.sql:', error.message);
}

console.log('\n═══════════════════════════════════════════════════════════════');
console.log('📄 SCRIPT 2: CRIAR_SISTEMA_EMPRESA.sql');
console.log('═══════════════════════════════════════════════════════════════');

try {
  const empresaScript = readFileSync(join(__dirname, 'CRIAR_SISTEMA_EMPRESA.sql'), 'utf8');
  // Mostrar apenas as primeiras linhas para referência
  const lines = empresaScript.split('\n');
  const preview = lines.slice(0, 50).join('\n');
  console.log(preview);
  console.log('\n... (script completo disponível no arquivo CRIAR_SISTEMA_EMPRESA.sql)\n');
} catch (error) {
  console.error('❌ Erro ao ler CRIAR_SISTEMA_EMPRESA.sql:', error.message);
}

console.log('═══════════════════════════════════════════════════════════════');
console.log('✅ PRÓXIMOS PASSOS:');
console.log('1. Execute PRIMEIRO o script CONFIGURAR_STORAGE_EMPRESAS.sql');
console.log('2. Execute DEPOIS o script CRIAR_SISTEMA_EMPRESA.sql');
console.log('3. Teste o upload da logo da empresa');
console.log('4. Configure funcionários e permissões');
console.log('═══════════════════════════════════════════════════════════════');
