#!/usr/bin/env node
/**
 * Script para atualizar version.json automaticamente no build
 * Executa antes do deploy para garantir versão única
 */

import fs from 'fs'
import path from 'path'
import { execSync } from 'child_process'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

function updateVersionFile() {
  try {
    // Pegar informações do Git
    let gitCommit, gitBranch
    
    try {
      gitCommit = execSync('git rev-parse --short HEAD', { encoding: 'utf8' }).trim()
      gitBranch = execSync('git rev-parse --abbrev-ref HEAD', { encoding: 'utf8' }).trim()
    } catch (error) {
      console.warn('⚠️ Git não disponível, usando valores padrão')
      gitCommit = 'unknown'
      gitBranch = 'main'
    }

    // Criar objeto de versão
    const versionInfo = {
      version: new Date().toISOString(),
      commit: gitCommit,
      branch: gitBranch,
      build: Date.now().toString(),
      environment: process.env.NODE_ENV || 'production'
    }

    // Caminho do arquivo
    const versionPath = path.join(__dirname, '..', 'public', 'version.json')
    
    // Criar diretório se não existir
    const publicDir = path.dirname(versionPath)
    if (!fs.existsSync(publicDir)) {
      fs.mkdirSync(publicDir, { recursive: true })
    }

    // Escrever arquivo
    fs.writeFileSync(versionPath, JSON.stringify(versionInfo, null, 2))
    
    console.log('✅ version.json atualizado:')
    console.log(`   📅 Version: ${versionInfo.version}`)
    console.log(`   🔗 Commit: ${versionInfo.commit}`)
    console.log(`   🌿 Branch: ${versionInfo.branch}`)
    console.log(`   🏗️  Build: ${versionInfo.build}`)
    
    return versionInfo
    
  } catch (error) {
    console.error('❌ Erro ao atualizar version.json:', error)
    process.exit(1)
  }
}

// Executar se chamado diretamente
updateVersionFile()

export { updateVersionFile }