import { useState } from 'react'

/**
 * Hook para gerenciar acesso ao sistema de arquivos
 * Usa File System Access API para criar pasta de backup
 */
export function useFileSystem() {
  const [backupDirHandle, setBackupDirHandle] = useState<FileSystemDirectoryHandle | null>(null)
  const [hasPermission, setHasPermission] = useState(false)

  /**
   * Solicita permissão para criar pasta de backup
   * @param empresaNome Nome da empresa para criar pasta
   */
  const requestBackupDirectory = async (empresaNome: string): Promise<boolean> => {
    try {
      // Verificar se navegador suporta File System Access API
      if (!('showDirectoryPicker' in window)) {
        console.warn('⚠️ File System Access API não suportada neste navegador')
        return false
      }

      // Pedir ao usuário para escolher/criar pasta
      const dirHandle = await (window as any).showDirectoryPicker({
        mode: 'readwrite',
        startIn: 'documents',
        id: 'backup-raval-pdv'
      })

      // Criar subpasta com nome da empresa
      const backupFolderName = `Backup-${empresaNome.replace(/\s+/g, '-')}`
      const backupHandle = await dirHandle.getDirectoryHandle(backupFolderName, { create: true })

      // Criar arquivo README.txt dentro da pasta
      const readmeHandle = await backupHandle.getFileHandle('README.txt', { create: true })
      const writable = await readmeHandle.createWritable()
      await writable.write(`Pasta de Backup Automático - ${empresaNome}
      
Esta pasta foi criada automaticamente pelo sistema RaVal PDV.
Os backups são salvos aqui em formato JSON.

📅 Data de criação: ${new Date().toLocaleString('pt-BR')}
🏢 Empresa: ${empresaNome}

⚠️ NÃO DELETE ESTA PASTA - seus backups estão aqui!
`)
      await writable.close()

      setBackupDirHandle(backupHandle)
      setHasPermission(true)

      // Salvar referência no localStorage
      localStorage.setItem('backup-folder-configured', 'true')
      localStorage.setItem('backup-folder-name', backupFolderName)

      console.log('✅ Pasta de backup criada:', backupFolderName)
      return true

    } catch (error: any) {
      if (error.name === 'AbortError') {
        console.log('ℹ️ Usuário cancelou seleção de pasta')
      } else {
        console.error('❌ Erro ao criar pasta de backup:', error)
      }
      return false
    }
  }

  /**
   * Verifica se já tem permissão configurada
   */
  const checkExistingPermission = (): boolean => {
    return localStorage.getItem('backup-folder-configured') === 'true'
  }

  /**
   * Salvar arquivo de backup na pasta
   */
  const saveBackupFile = async (filename: string, content: string): Promise<boolean> => {
    if (!backupDirHandle) {
      console.error('❌ Pasta de backup não configurada')
      return false
    }

    try {
      const fileHandle = await backupDirHandle.getFileHandle(filename, { create: true })
      const writable = await fileHandle.createWritable()
      await writable.write(content)
      await writable.close()
      
      console.log('✅ Backup salvo:', filename)
      return true
    } catch (error) {
      console.error('❌ Erro ao salvar backup:', error)
      return false
    }
  }

  return {
    backupDirHandle,
    hasPermission,
    requestBackupDirectory,
    checkExistingPermission,
    saveBackupFile
  }
}
