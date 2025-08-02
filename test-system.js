#!/usr/bin/env node

/**
 * Script para testar rapidamente o sistema PDV Import
 * Executa verificações básicas de configuração e conectividade
 */

import fs from 'fs'
import path from 'path'
import { exec } from 'child_process'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

console.log('🚀 Iniciando teste rápido do sistema PDV Import...\n')

// Função para colorir texto no terminal
const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  reset: '\x1b[0m'
}

const log = (color, message) => {
  console.log(color + message + colors.reset)
}

console.log('📋 1. Verificando configuração...')

const envPath = path.join(__dirname, '.env')
if (fs.existsSync(envPath)) {
  log(colors.green, '  ✅ Arquivo .env encontrado')
  
  const envContent = fs.readFileSync(envPath, 'utf8')
  const hasUrl = envContent.includes('VITE_SUPABASE_URL=https://')
  const hasKey = envContent.includes('VITE_SUPABASE_ANON_KEY=')
  
  if (hasUrl) {
    log(colors.green, '  ✅ VITE_SUPABASE_URL configurado')
  } else {
    log(colors.red, '  ❌ VITE_SUPABASE_URL não configurado ou inválido')
  }
  
  if (hasKey) {
    log(colors.green, '  ✅ VITE_SUPABASE_ANON_KEY configurado')
  } else {
    log(colors.red, '  ❌ VITE_SUPABASE_ANON_KEY não configurado')
  }
} else {
  log(colors.red, '  ❌ Arquivo .env não encontrado')
}

// 2. Verificar package.json
console.log('\n📦 2. Verificando dependências...')

const packagePath = path.join(__dirname, 'package.json')
if (fs.existsSync(packagePath)) {
  log(colors.green, '  ✅ package.json encontrado')
  
  const packageContent = JSON.parse(fs.readFileSync(packagePath, 'utf8'))
  const hasDeps = packageContent.dependencies && Object.keys(packageContent.dependencies).length > 0
  
  if (hasDeps) {
    log(colors.green, `  ✅ ${Object.keys(packageContent.dependencies).length} dependências listadas`)
    
    // Verificar dependências críticas
    const criticalDeps = ['@supabase/supabase-js', 'react', 'vite']
    criticalDeps.forEach(dep => {
      if (packageContent.dependencies[dep] || packageContent.devDependencies?.[dep]) {
        log(colors.green, `    ✅ ${dep}`)
      } else {
        log(colors.red, `    ❌ ${dep} não encontrado`)
      }
    })
  } else {
    log(colors.red, '  ❌ Nenhuma dependência encontrada')
  }
} else {
  log(colors.red, '  ❌ package.json não encontrado')
}

// 3. Verificar estrutura de arquivos
console.log('\n📁 3. Verificando estrutura de arquivos...')

const criticalFiles = [
  'src/App.tsx',
  'src/lib/supabase.ts',
  'src/modules/auth/AuthContext.tsx',
  'src/components/AuthDiagnostic.tsx',
  'script-completo-para-supabase.sql'
]

criticalFiles.forEach(file => {
  const filePath = path.join(__dirname, file)
  if (fs.existsSync(filePath)) {
    log(colors.green, `  ✅ ${file}`)
  } else {
    log(colors.red, `  ❌ ${file} não encontrado`)
  }
})

// 4. Verificar se node_modules existe
console.log('\n📚 4. Verificando instalação...')

const nodeModulesPath = path.join(__dirname, 'node_modules')
if (fs.existsSync(nodeModulesPath)) {
  log(colors.green, '  ✅ node_modules instalado')
  
  // Verificar se supabase está instalado
  const supabasePath = path.join(nodeModulesPath, '@supabase/supabase-js')
  if (fs.existsSync(supabasePath)) {
    log(colors.green, '  ✅ Supabase JS SDK instalado')
  } else {
    log(colors.red, '  ❌ Supabase JS SDK não instalado')
  }
} else {
  log(colors.red, '  ❌ node_modules não encontrado - execute npm install')
}

// 5. Verificar se servidor está rodando
console.log('\n🌐 5. Verificando servidor...')

exec('curl -s http://localhost:5174 -o /dev/null -w "%{http_code}"', (error, stdout) => {
  if (stdout === '200') {
    log(colors.green, '  ✅ Servidor rodando em http://localhost:5174')
  } else {
    exec('curl -s http://localhost:5175 -o /dev/null -w "%{http_code}"', (error, stdout) => {
      if (stdout === '200') {
        log(colors.green, '  ✅ Servidor rodando em http://localhost:5175')
      } else {
        log(colors.yellow, '  ⚠️  Servidor não está rodando - execute npm run dev')
      }
    })
  }
})

// Resumo e próximos passos
setTimeout(() => {
  console.log('\n' + '='.repeat(50))
  console.log('📋 RESUMO E PRÓXIMOS PASSOS:')
  console.log('='.repeat(50))
  
  log(colors.blue, '\n🔧 Para resolver problemas de autenticação:')
  console.log('   1. Acesse http://localhost:5175/diagnostic')
  console.log('   2. Use credenciais de teste: teste@teste.com / teste@@')
  console.log('   3. Execute o script SQL no Supabase se necessário')
  
  log(colors.blue, '\n🌐 Links úteis:')
  console.log('   • Login: http://localhost:5175/login')
  console.log('   • Diagnóstico: http://localhost:5175/diagnostic')
  console.log('   • Dashboard: http://localhost:5175/dashboard')
  console.log('   • Supabase: https://supabase.com/dashboard')
  
  log(colors.blue, '\n📝 Arquivo SQL para banco:')
  console.log('   • Execute script-completo-para-supabase.sql no Supabase SQL Editor')
  
  console.log('\n✨ Sistema pronto para uso!')
}, 1000)
