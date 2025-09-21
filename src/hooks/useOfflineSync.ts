import { useState, useEffect, useCallback } from 'react'
import { toast } from 'react-hot-toast'
import { supabase } from '../lib/supabase'

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
    const wasOffline = !isOnline
    
    setIsOnline(online)
    setSyncStatus(prev => ({ ...prev, isOnline: online }))
    
    if (online && wasOffline) {
      console.log('🌐 [SYNC] Conexão restaurada - iniciando sincronização única')
      toast.success('🌐 Conexão restaurada! Sincronizando dados...', {
        duration: 3000
      })
      // Sincronizar apenas uma vez quando reconectar
      setTimeout(startSync, 2000)
    } else if (!online) {
      console.log('📴 [SYNC] Conexão perdida - modo offline')
      toast.error('📴 Sem conexão. Modo offline ativado.', {
        duration: 4000
      })
    }
  }, [isOnline])

  // Salvar dados offline no localStorage com isolamento por usuário
  const saveOfflineData = useCallback(async (key: string, data: any) => {
    try {
      // Obter ID do usuário atual
      const { data: { user } } = await supabase.auth.getUser()
      const userId = user?.id || 'anonymous'
      
      const offlineData = await getOfflineData()
      offlineData[key as keyof OfflineData] = data
      
      // Usar chave específica do usuário
      const userKey = `pdv-offline-data-${userId}`
      localStorage.setItem(userKey, JSON.stringify(offlineData))
      
      // Adicionar timestamp para controle (também isolado por usuário)
      localStorage.setItem(`pdv-last-save-${userId}`, new Date().toISOString())
      
      console.log(`💾 Dados salvos offline (usuário ${userId}): ${key}`)
      return true
    } catch (error) {
      console.error('❌ Erro ao salvar dados offline:', error)
      return false
    }
  }, [])

  // Recuperar dados offline com isolamento por usuário
  const getOfflineData = useCallback(async (): Promise<OfflineData> => {
    try {
      // Obter ID do usuário atual
      const { data: { user } } = await supabase.auth.getUser()
      const userId = user?.id || 'anonymous'
      
      // Usar chave específica do usuário para evitar vazamento de dados
      const userKey = `pdv-offline-data-${userId}`
      const data = localStorage.getItem(userKey)
      
      console.log('🔍 [OFFLINE] Usando chave isolada:', userKey)
      
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
      const offlineData = await getOfflineData()
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
    if (!isOnline || syncStatus.isSyncing) {
      console.log('🚫 [SYNC] Sync cancelado - isOnline:', isOnline, 'isSyncing:', syncStatus.isSyncing)
      return
    }

    console.log('🔄 [SYNC] Iniciando verificação de sincronização...')
    setSyncStatus(prev => ({ ...prev, isSyncing: true }))

    try {
      const offlineData = await getOfflineData()
      const { syncQueue } = offlineData
      
      console.log('📋 [SYNC] Fila de sincronização:', syncQueue.length, 'itens')
      
      if (syncQueue.length === 0) {
        console.log('✅ [SYNC] Nenhum item para sincronizar')
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

  // Limpar dados offline antigos com isolamento por usuário
  const clearOldOfflineData = useCallback(async () => {
    try {
      const maxAge = 7 * 24 * 60 * 60 * 1000 // 7 dias
      
      // Obter ID do usuário atual
      const { data: { user } } = await supabase.auth.getUser()
      const userId = user?.id || 'anonymous'
      
      const lastSaveKey = `pdv-last-save-${userId}`
      const dataKey = `pdv-offline-data-${userId}`
      
      const lastSave = localStorage.getItem(lastSaveKey)
      
      if (lastSave) {
        const saveTime = new Date(lastSave).getTime()
        const now = Date.now()
        
        if (now - saveTime > maxAge) {
          localStorage.removeItem(dataKey)
          localStorage.removeItem(lastSaveKey)
          console.log(`🗑️ Dados offline antigos removidos para usuário ${userId}`)
        }
      }
    } catch (error) {
      console.error('❌ Erro ao limpar dados antigos:', error)
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
    const initializeOfflineData = async () => {
      await clearOldOfflineData()
      
      // Verificar fila pendente
      try {
        const offlineData = await getOfflineData()
        setSyncStatus(prev => ({
          ...prev,
          pendingItems: offlineData.syncQueue.length
        }))
      } catch (error) {
        console.error('❌ Erro ao verificar fila pendente:', error)
      }
    }
    
    initializeOfflineData()

    // Sincronizar se estiver online (TEMPORARIAMENTE DESABILITADO)
    // if (navigator.onLine) {
    //   setTimeout(startSync, 1000)
    // }

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
