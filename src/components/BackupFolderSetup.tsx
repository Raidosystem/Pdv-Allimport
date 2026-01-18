import { useState, useEffect } from 'react'
import { FolderOpen, X } from 'lucide-react'
import { isPWA } from './PWARedirect'

/**
 * Componente que oferece configuração de pasta de backup no primeiro acesso ao PWA
 */
export function BackupFolderSetup() {
  const [showModal, setShowModal] = useState(false)
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState(false)

  useEffect(() => {
    // Só mostrar em PWA
    if (!isPWA()) {
      return
    }

    // Verificar se já foi configurado ou rejeitado
    const alreadyConfigured = localStorage.getItem('backup-folder-configured') === 'true'
    const wasSkipped = localStorage.getItem('backup-folder-skipped') === 'true'
    const firstAccess = localStorage.getItem('pwa-first-access') !== 'true'

    // Mostrar modal apenas no primeiro acesso ao PWA e se não foi configurado/rejeitado
    if (firstAccess && !alreadyConfigured && !wasSkipped) {
      // Aguardar 3 segundos para usuário se situar
      setTimeout(() => {
        setShowModal(true)
        localStorage.setItem('pwa-first-access', 'true')
      }, 3000)
    }
  }, [])

  const handleCreateFolder = async () => {
    setLoading(true)

    try {
      // Verificar se suporta File System Access API
      if (!('showDirectoryPicker' in window)) {
        alert('Seu navegador não suporta seleção de pastas. Use Chrome, Edge ou Safari atualizado.')
        setLoading(false)
        return
      }

      // Buscar nome do usuário para criar pasta personalizada
      const userEmail = localStorage.getItem('user-email') || ''
      const empresaNome = userEmail.split('@')[0] || 'RaVal-PDV'

      // Solicitar permissão para criar pasta
      const dirHandle = await (window as any).showDirectoryPicker({
        mode: 'readwrite',
        startIn: 'documents',
        id: 'backup-raval-pdv'
      })

      // Criar subpasta com nome da empresa
      const backupFolderName = `Backup-${empresaNome.replace(/\s+/g, '-')}`
      const backupHandle = await dirHandle.getDirectoryHandle(backupFolderName, { create: true })

      // Criar arquivo README.txt
      const readmeHandle = await backupHandle.getFileHandle('README.txt', { create: true })
      const writable = await readmeHandle.createWritable()
      await writable.write(`Pasta de Backup Automático - RaVal PDV

Esta pasta foi criada automaticamente pelo sistema RaVal PDV.
Os backups são salvos aqui em formato JSON.

📅 Data de criação: ${new Date().toLocaleString('pt-BR')}
🏢 Empresa: ${empresaNome}

⚠️ NÃO DELETE ESTA PASTA - seus backups estão aqui!

Para fazer backup manual:
1. Entre no sistema
2. Vá em Configurações > Backup
3. Clique em "Exportar dados"
`)
      await writable.close()

      // Salvar configuração
      localStorage.setItem('backup-folder-configured', 'true')
      localStorage.setItem('backup-folder-name', backupFolderName)

      console.log('✅ Pasta de backup criada:', backupFolderName)

      // Mostrar sucesso
      setSuccess(true)
      setLoading(false)

      // Fechar modal após 2 segundos
      setTimeout(() => {
        setShowModal(false)
      }, 2000)

    } catch (error: any) {
      setLoading(false)
      
      if (error.name === 'AbortError') {
        console.log('ℹ️ Usuário cancelou seleção de pasta')
      } else {
        console.error('❌ Erro ao criar pasta:', error)
        alert('Erro ao criar pasta de backup. Você pode configurar depois em Configurações.')
      }
    }
  }

  const handleSkip = () => {
    localStorage.setItem('backup-folder-skipped', 'true')
    setShowModal(false)
  }

  if (!showModal) {
    return null
  }

  return (
    <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-[10000] animate-fadeIn p-4">
      <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl animate-slideUp">
        {success ? (
          <div className="p-8 text-center">
            <div className="text-6xl mb-4">✅</div>
            <h2 className="text-2xl font-bold text-green-600 mb-2">
              Pasta criada com sucesso!
            </h2>
            <p className="text-gray-600">
              Seus backups serão salvos em <strong>Documentos/Backup-[Empresa]</strong>
            </p>
          </div>
        ) : (
          <>
            <div className="p-6 border-b border-gray-200">
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl flex items-center justify-center">
                    <FolderOpen className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <h2 className="text-xl font-bold text-gray-900">
                      Configurar Backup Automático
                    </h2>
                    <p className="text-sm text-gray-500">Primeiro acesso ao PWA</p>
                  </div>
                </div>
                <button
                  onClick={handleSkip}
                  className="text-gray-400 hover:text-gray-600 transition-colors p-1"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
            </div>

            <div className="p-6">
              <p className="text-gray-700 mb-4 leading-relaxed">
                Deseja criar uma pasta para salvar <strong>backups automáticos</strong> dos seus dados?
              </p>
              
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
                <ul className="space-y-2 text-sm text-gray-700">
                  <li className="flex items-start gap-2">
                    <span className="text-blue-600 font-bold">📁</span>
                    <span>Pasta criada em <strong>Documentos</strong></span>
                  </li>
                  <li className="flex items-start gap-2">
                    <span className="text-blue-600 font-bold">🔒</span>
                    <span>Seus dados ficam seguros localmente</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <span className="text-blue-600 font-bold">⚡</span>
                    <span>Você pode configurar depois em Configurações</span>
                  </li>
                </ul>
              </div>

              <div className="flex gap-3">
                <button
                  onClick={handleSkip}
                  disabled={loading}
                  className="flex-1 px-4 py-3 border-2 border-gray-300 text-gray-700 font-semibold rounded-xl hover:bg-gray-50 transition-all disabled:opacity-50"
                >
                  Agora não
                </button>
                <button
                  onClick={handleCreateFolder}
                  disabled={loading}
                  className="flex-1 px-4 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white font-bold rounded-xl hover:from-blue-700 hover:to-purple-700 transition-all shadow-lg hover:shadow-xl disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {loading ? (
                    <>
                      <span className="inline-block animate-spin mr-2">⏳</span>
                      Criando...
                    </>
                  ) : (
                    '✨ Criar pasta'
                  )}
                </button>
              </div>
            </div>
          </>
        )}
      </div>

      <style>{`
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        @keyframes slideUp {
          from { transform: translateY(20px); opacity: 0; }
          to { transform: translateY(0); opacity: 1; }
        }
        .animate-fadeIn {
          animation: fadeIn 0.3s ease-out;
        }
        .animate-slideUp {
          animation: slideUp 0.3s ease-out;
        }
      `}</style>
    </div>
  )
}
