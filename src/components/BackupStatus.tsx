import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/modules/auth/AuthContext'
import { Card } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { formatDistanceToNow } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import toast from 'react-hot-toast'

interface BackupFile {
  name: string
  created_at: string
  size: number
}

export function BackupStatus() {
  const { user } = useAuth()
  const [backups, setBackups] = useState<BackupFile[]>([])
  const [loading, setLoading] = useState(true)
  const [executandoBackup, setExecutandoBackup] = useState(false)

  useEffect(() => {
    carregarBackups()
  }, [user])

  const carregarBackups = async () => {
    if (!user?.id) return

    try {
      setLoading(true)
      
      // Buscar backups da empresa do usuário
      const pastaEmpresa = `empresa_${user.id.substring(0, 8)}`
      
      const { data, error } = await supabase.storage
        .from('backups')
        .list(pastaEmpresa, {
          limit: 10,
          sortBy: { column: 'created_at', order: 'desc' }
        })

      if (error) {
        console.error('Erro ao carregar backups:', error)
        return
      }

      setBackups((data as any) || [])
    } catch (err) {
      console.error('Erro:', err)
    } finally {
      setLoading(false)
    }
  }

  const executarBackupManual = async () => {
    try {
      setExecutandoBackup(true)
      toast.loading('Executando backup...', { id: 'backup-manual' })

      // Chamar Edge Function diretamente
      const { data, error } = await supabase.functions.invoke('backup-automatico', {
        body: {}
      })

      if (error) throw error

      toast.success('Backup executado com sucesso!', { id: 'backup-manual' })
      
      // Recarregar lista de backups
      setTimeout(() => carregarBackups(), 2000)
    } catch (err) {
      console.error('Erro ao executar backup:', err)
      const errorMessage = err instanceof Error ? err.message : 'Erro desconhecido'
      toast.error('Erro ao executar backup: ' + errorMessage, { id: 'backup-manual' })
    } finally {
      setExecutandoBackup(false)
    }
  }

  const baixarBackup = async (nomeArquivo: string) => {
    try {
      const pastaEmpresa = `empresa_${user?.id.substring(0, 8)}`
      const caminhoCompleto = `${pastaEmpresa}/${nomeArquivo}`

      toast.loading('Baixando backup...', { id: 'download-backup' })

      const { data, error } = await supabase.storage
        .from('backups')
        .download(caminhoCompleto)

      if (error) throw error

      // Criar link de download
      const url = URL.createObjectURL(data)
      const a = document.createElement('a')
      a.href = url
      a.download = nomeArquivo
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)

      toast.success('Backup baixado com sucesso!', { id: 'download-backup' })
    } catch (err) {
      console.error('Erro ao baixar backup:', err)
      toast.error('Erro ao baixar backup', { id: 'download-backup' })
    }
  }

  const formatarTamanho = (bytes: number) => {
    if (bytes < 1024) return `${bytes} B`
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
  }

  const ultimoBackup = backups[0]

  return (
    <Card className="p-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h3 className="text-lg font-semibold mb-1">
            🔐 Backup Automático
          </h3>
          <p className="text-sm text-gray-600">
            Sistema de backup em nuvem ativo
          </p>
        </div>
        <Button
          onClick={executarBackupManual}
          disabled={executandoBackup}
          size="sm"
        >
          {executandoBackup ? '⏳ Executando...' : '▶️ Executar Agora'}
        </Button>
      </div>

      {loading ? (
        <div className="text-center py-8 text-gray-500">
          Carregando status do backup...
        </div>
      ) : backups.length === 0 ? (
        <div className="text-center py-8">
          <p className="text-gray-600 mb-4">
            Nenhum backup encontrado ainda
          </p>
          <p className="text-sm text-gray-500 mb-4">
            O primeiro backup será executado automaticamente às 03:00
          </p>
          <Button onClick={executarBackupManual} disabled={executandoBackup}>
            Executar Primeiro Backup
          </Button>
        </div>
      ) : (
        <>
          {/* Status do Último Backup */}
          <div className="bg-green-50 border border-green-200 rounded-lg p-4 mb-6">
            <div className="flex items-start gap-3">
              <div className="flex-shrink-0 w-10 h-10 bg-green-500 rounded-full flex items-center justify-center text-white text-xl">
                ✓
              </div>
              <div className="flex-1">
                <h4 className="font-medium text-green-900 mb-1">
                  Último backup realizado
                </h4>
                <p className="text-sm text-green-700">
                  {formatDistanceToNow(new Date(ultimoBackup.created_at), {
                    addSuffix: true,
                    locale: ptBR
                  })}
                </p>
                <p className="text-xs text-green-600 mt-1">
                  Tamanho: {formatarTamanho(ultimoBackup.size)}
                </p>
              </div>
            </div>
          </div>

          {/* Informações do Sistema */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
            <div className="text-center p-4 bg-gray-50 rounded-lg">
              <div className="text-2xl font-bold text-blue-600 mb-1">
                {backups.length}
              </div>
              <div className="text-sm text-gray-600">
                Backups disponíveis
              </div>
            </div>
            <div className="text-center p-4 bg-gray-50 rounded-lg">
              <div className="text-2xl font-bold text-green-600 mb-1">
                03:00
              </div>
              <div className="text-sm text-gray-600">
                Próximo backup
              </div>
            </div>
            <div className="text-center p-4 bg-gray-50 rounded-lg">
              <div className="text-2xl font-bold text-purple-600 mb-1">
                7 dias
              </div>
              <div className="text-sm text-gray-600">
                Retenção
              </div>
            </div>
          </div>

          {/* Lista de Backups */}
          <div>
            <h4 className="font-medium mb-3">Histórico de Backups</h4>
            <div className="space-y-2 max-h-64 overflow-y-auto">
              {backups.map((backup) => (
                <div
                  key={backup.name}
                  className="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition"
                >
                  <div className="flex-1">
                    <div className="font-medium text-sm">
                      {new Date(backup.created_at).toLocaleString('pt-BR')}
                    </div>
                    <div className="text-xs text-gray-600">
                      {formatarTamanho(backup.size)} • {backup.name}
                    </div>
                  </div>
                  <Button
                    onClick={() => baixarBackup(backup.name)}
                    size="sm"
                    variant="outline"
                  >
                    📥 Baixar
                  </Button>
                </div>
              ))}
            </div>
          </div>

          {/* Informações Adicionais */}
          <div className="mt-6 pt-6 border-t border-gray-200">
            <h4 className="font-medium mb-3 text-sm">ℹ️ Informações</h4>
            <ul className="space-y-2 text-sm text-gray-600">
              <li className="flex items-start gap-2">
                <span className="text-green-500">✓</span>
                <span>Backup automático executado diariamente às 03:00</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-green-500">✓</span>
                <span>Dados salvos em servidor seguro na nuvem</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-green-500">✓</span>
                <span>Mantém últimos 7 dias de backup</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-green-500">✓</span>
                <span>Backup isolado por empresa (restauração seletiva)</span>
              </li>
            </ul>
          </div>
        </>
      )}
    </Card>
  )
}
