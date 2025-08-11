import { useState, useEffect, useCallback } from 'react'
import { toast } from 'react-hot-toast'

interface OfflineData {
  vendas: any[]
  produtos: any[]
  clientes: any[]
  caixa: any[]
  syncQueue: any[]
}

interface SyncStatus {
  isOnline: boolean
  isSyncing: boolean
  lastSync: Date | null
  pendingItems: number
  totalSynced: number
}

export function useOfflineSync() {
  const [isOnline, setIsOnline] = useState(navigator.onLine)
  const [syncStatus, setSyncStatus] = useState<SyncStatus>({
    isOnline: navigator.onLine,
    isSyncing: false,
    lastSync: null,
    pendingItems: 0,
    totalSynced: 0
  })

  // Atualizar status de conexão
  const updateOnlineStatus = useCallback(() => {
    const online = navigator.onLine
    setIsOnline(online)
    setSyncStatus(prev => ({ ...prev, isOnline: online }))
    
    if (online) {
      toast.success('🌐 Conexão restaurada! Sincronizando dados...', {
        duration: 3000
      })
      startSync()
    } else {
      toast.error('📴 Sem conexão. Modo offline ativado.', {
        duration: 4000
      })
    }
  }, [])

  // Salvar dados offline no localStorage
  const saveOfflineData = useCallback(async (key: string, data: any) => {
    try {
      const offlineData = getOfflineData()
      offlineData[key as keyof OfflineData] = data
      localStorage.setItem('pdv-offline-data', JSON.stringify(offlineData))
      
      // Adicionar timestamp para controle
      localStorage.setItem('pdv-last-save', new Date().toISOString())
      
      console.log(`💾 Dados salvos offline: ${key}`)
      return true
    } catch (error) {
      console.error('❌ Erro ao salvar dados offline:', error)
      return false
    }
  }, [])

  // Recuperar dados offline
  const getOfflineData = useCallback((): OfflineData => {
    try {
      const data = localStorage.getItem('pdv-offline-data')
      return data ? JSON.parse(data) : {
        vendas: [],
        produtos: [],
        clientes: [],
        caixa: [],
        syncQueue: []
      }
    } catch (error) {
      console.error('❌ Erro ao recuperar dados offline:', error)
      return {
        vendas: [],
        produtos: [],
        clientes: [],
        caixa: [],
        syncQueue: []
      }
    }
  }, [])

  // Adicionar operação à fila de sincronização
  const addToSyncQueue = useCallback(async (operation: {
    type: 'CREATE' | 'UPDATE' | 'DELETE'
    table: string
    data: any
    timestamp: number
  }) => {
    try {
      const offlineData = getOfflineData()
      offlineData.syncQueue.push(operation)
      
      await saveOfflineData('syncQueue', offlineData.syncQueue)
      
      setSyncStatus(prev => ({
        ...prev,
        pendingItems: offlineData.syncQueue.length
      }))
      
      console.log('📝 Operação adicionada à fila de sincronização:', operation)
      
      // Se estiver online, tentar sincronizar imediatamente
      if (isOnline) {
        startSync()
      }
    } catch (error) {
      console.error('❌ Erro ao adicionar à fila de sincronização:', error)
    }
  }, [isOnline, saveOfflineData, getOfflineData])

  // Iniciar sincronização
  const startSync = useCallback(async () => {
    if (!isOnline || syncStatus.isSyncing) return

    setSyncStatus(prev => ({ ...prev, isSyncing: true }))

    try {
      const offlineData = getOfflineData()
      const { syncQueue } = offlineData
      
      if (syncQueue.length === 0) {
        setSyncStatus(prev => ({
          ...prev,
          isSyncing: false,
          lastSync: new Date()
        }))
        return
      }

      console.log(`🔄 Iniciando sincronização de ${syncQueue.length} itens`)

      let syncedCount = 0
      const remainingQueue = []

      for (const operation of syncQueue) {
        try {
          const success = await syncOperation(operation)
          
          if (success) {
            syncedCount++
            console.log('✅ Operação sincronizada:', operation.type, operation.table)
          } else {
            remainingQueue.push(operation)
          }
        } catch (error) {
          console.log('⏳ Falha na sincronização (tentará novamente):', operation)
          remainingQueue.push(operation)
        }
      }

      // Atualizar fila com operações não sincronizadas
      await saveOfflineData('syncQueue', remainingQueue)

      setSyncStatus(prev => ({
        ...prev,
        isSyncing: false,
        lastSync: new Date(),
        pendingItems: remainingQueue.length,
        totalSynced: prev.totalSynced + syncedCount
      }))

      if (syncedCount > 0) {
        toast.success(`✅ ${syncedCount} operações sincronizadas!`, {
          duration: 3000
        })
      }

      if (remainingQueue.length > 0) {
        toast(`⏳ ${remainingQueue.length} itens aguardando sincronização`, {
          duration: 2000,
          icon: '⏳'
        })
      }

    } catch (error) {
      console.error('❌ Erro durante sincronização:', error)
      setSyncStatus(prev => ({ ...prev, isSyncing: false }))
      
      toast.error('❌ Erro na sincronização. Tentando novamente...', {
        duration: 3000
      })
    }
  }, [isOnline, syncStatus.isSyncing, getOfflineData, saveOfflineData])

  // Simular sincronização de operação (aqui você integraria com o Supabase)
  const syncOperation = async (operation: any): Promise<boolean> => {
    // Simular latência de rede
    await new Promise(resolve => setTimeout(resolve, 500))
    
    // Aqui você faria a chamada real para o Supabase
    console.log('🔄 Sincronizando operação:', operation)
    
    // Por enquanto, simular sucesso (90% das vezes)
    return Math.random() > 0.1
  }

  // Limpar dados offline antigos
  const clearOldOfflineData = useCallback(() => {
    const maxAge = 7 * 24 * 60 * 60 * 1000 // 7 dias
    const lastSave = localStorage.getItem('pdv-last-save')
    
    if (lastSave) {
      const saveTime = new Date(lastSave).getTime()
      const now = Date.now()
      
      if (now - saveTime > maxAge) {
        localStorage.removeItem('pdv-offline-data')
        localStorage.removeItem('pdv-last-save')
        console.log('🗑️ Dados offline antigos removidos')
      }
    }
  }, [])

  // Instalar PWA
  const installPWA = useCallback(() => {
    const deferredPrompt = (window as any).deferredPrompt
    
    if (deferredPrompt) {
      deferredPrompt.prompt()
      
      deferredPrompt.userChoice.then((choiceResult: any) => {
        if (choiceResult.outcome === 'accepted') {
          toast.success('📱 PDV Allimport instalado com sucesso!', {
            duration: 4000
          })
        }
        
        // Limpar o prompt
        (window as any).deferredPrompt = null
      })
    } else {
      toast('💡 Para instalar, use o menu do navegador: "Instalar aplicativo"', {
        duration: 5000,
        icon: '💡'
      })
    }
  }, [])

  // Configurar listeners de eventos
  useEffect(() => {
    // Listeners de conectividade
    window.addEventListener('online', updateOnlineStatus)
    window.addEventListener('offline', updateOnlineStatus)

    // Listener para PWA install prompt
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault()
      ;(window as any).deferredPrompt = e
      console.log('💡 PWA pode ser instalado')
    })

    // Listener para Service Worker
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.addEventListener('message', (event) => {
        if (event.data.type === 'SYNC_COMPLETE') {
          console.log('🔄 Sincronização completa:', event.data)
          setSyncStatus(prev => ({
            ...prev,
            pendingItems: event.data.remaining,
            totalSynced: prev.totalSynced + event.data.processed
          }))
        }
      })
    }

    // Limpar dados antigos na inicialização
    clearOldOfflineData()

    // Verificar fila pendente
    const offlineData = getOfflineData()
    setSyncStatus(prev => ({
      ...prev,
      pendingItems: offlineData.syncQueue.length
    }))

    // Sincronizar se estiver online
    if (navigator.onLine) {
      setTimeout(startSync, 1000)
    }

    return () => {
      window.removeEventListener('online', updateOnlineStatus)
      window.removeEventListener('offline', updateOnlineStatus)
    }
  }, [updateOnlineStatus, clearOldOfflineData, getOfflineData, startSync])

  return {
    isOnline,
    syncStatus,
    saveOfflineData,
    getOfflineData,
    addToSyncQueue,
    startSync,
    installPWA
  }
}
