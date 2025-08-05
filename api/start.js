#!/usr/bin/env node

console.log('🚀 Iniciando servidor de teste...')

try {
  import('./index.js')
    .then(() => {
      console.log('✅ Servidor iniciado com sucesso!')
    })
    .catch((error) => {
      console.error('❌ Erro ao iniciar servidor:', error)
    })
} catch (error) {
  console.error('❌ Erro crítico:', error)
}
