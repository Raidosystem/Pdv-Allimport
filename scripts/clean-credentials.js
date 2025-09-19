#!/usr/bin/env node
/**
 * 🚨 SCRIPT DE EMERGÊNCIA - LIMPEZA DE CREDENCIAIS EXPOSTAS
 * Remove todas as credenciais hardcoded encontradas no código
 */

import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// Credenciais expostas que devem ser removidas
const EXPOSED_CREDENTIALS = {
  // MercadoPago Token
  'process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN': {
    replacement: 'process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN',
    description: 'MercadoPago Access Token'
  },
  
  // Supabase Anon Key
  'process.env.VITE_SUPABASE_ANON_KEY': {
    replacement: 'process.env.VITE_SUPABASE_ANON_KEY',
    description: 'Supabase Anon Key'
  },

  // URLs hardcoded
  'process.env.VITE_SUPABASE_URL': {
    replacement: 'process.env.VITE_SUPABASE_URL',
    description: 'Supabase URL'
  }
}

// Arquivos que devem ser ignorados (já limpos ou são configs de exemplo)
const IGNORE_FILES = [
  '.env.local',
  '.env.vercel', 
  '.env.example',
  'api/.env.example',
  'ROTACAO_CHAVES_AGORA.md',
  'CONFIGURACAO_OFICIAL.md',
  'EMERGENCIA_SEGURANCA.md',
  'scripts/clean-credentials.js', // Este próprio script
  'ANALISE_TERMINAL.md',
  'CACHE_SYSTEM_README.md'
]

// Extensões de arquivos para verificar
const FILE_EXTENSIONS = ['.js', '.ts', '.tsx', '.jsx', '.html', '.md', '.json', '.yml', '.yaml']

function shouldIgnoreFile(filePath) {
  // Ignorar node_modules, .git, dist, etc
  if (filePath.includes('node_modules') || 
      filePath.includes('.git') || 
      filePath.includes('dist') ||
      filePath.includes('.vercel')) {
    return true
  }

  // Ignorar arquivos específicos
  const relativePath = path.relative(process.cwd(), filePath)
  return IGNORE_FILES.some(ignore => relativePath.includes(ignore))
}

function scanDirectory(dirPath) {
  const results = []
  
  try {
    const items = fs.readdirSync(dirPath, { withFileTypes: true })
    
    for (const item of items) {
      const fullPath = path.join(dirPath, item.name)
      
      if (item.isDirectory()) {
        if (!shouldIgnoreFile(fullPath)) {
          results.push(...scanDirectory(fullPath))
        }
      } else if (item.isFile()) {
        const ext = path.extname(item.name)
        if (FILE_EXTENSIONS.includes(ext) && !shouldIgnoreFile(fullPath)) {
          results.push(fullPath)
        }
      }
    }
  } catch (error) {
    console.warn(`⚠️ Erro ao ler diretório ${dirPath}:`, error.message)
  }
  
  return results
}

function cleanFile(filePath) {
  try {
    let content = fs.readFileSync(filePath, 'utf8')
    let modified = false
    const changes = []

    // Verificar cada credencial exposta
    for (const [credential, config] of Object.entries(EXPOSED_CREDENTIALS)) {
      if (content.includes(credential)) {
        // Para arquivos JS/TS, usar replacement inteligente
        if (filePath.endsWith('.js') || filePath.endsWith('.ts') || filePath.endsWith('.tsx')) {
          // Substituir apenas se estiver em contexto de código, não em comentários de documentação
          const lines = content.split('\n')
          let lineModified = false
          
          for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            if (line.includes(credential) && !line.trim().startsWith('//') && !line.trim().startsWith('*')) {
              lines[i] = line.replace(new RegExp(credential.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&'), 'g'), config.replacement)
              lineModified = true
            }
          }
          
          if (lineModified) {
            content = lines.join('\n')
            modified = true
            changes.push(`${config.description} removido`)
          }
        } else {
          // Para outros arquivos, substituir diretamente
          content = content.replace(new RegExp(credential.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&'), 'g'), `[${config.description}_REMOVIDO]`)
          modified = true
          changes.push(`${config.description} removido`)
        }
      }
    }

    if (modified) {
      fs.writeFileSync(filePath, content)
      console.log(`✅ ${path.relative(process.cwd(), filePath)}: ${changes.join(', ')}`)
      return true
    }
    
    return false
  } catch (error) {
    console.error(`❌ Erro ao limpar ${filePath}:`, error.message)
    return false
  }
}

function main() {
  console.log('🚨 INICIANDO LIMPEZA DE EMERGÊNCIA DE CREDENCIAIS')
  console.log('=' .repeat(60))
  
  const rootDir = path.join(__dirname, '..')
  const allFiles = scanDirectory(rootDir)
  
  console.log(`📁 Verificando ${allFiles.length} arquivos...`)
  
  let cleanedFiles = 0
  
  for (const filePath of allFiles) {
    if (cleanFile(filePath)) {
      cleanedFiles++
    }
  }
  
  console.log('=' .repeat(60))
  console.log(`🎯 RESULTADO: ${cleanedFiles} arquivos limpos de credenciais expostas`)
  
  if (cleanedFiles > 0) {
    console.log('')
    console.log('⚠️  PRÓXIMOS PASSOS OBRIGATÓRIOS:')
    console.log('1. 🔄 Rotacionar TODAS as credenciais imediatamente')
    console.log('2. 🔑 Configurar novas credenciais no Vercel')
    console.log('3. 🚀 Fazer redeploy')
    console.log('4. 🛡️ Ativar GitHub Secret Scanning')
  }
}

// Executar se chamado diretamente
main()

export { main as cleanCredentials }