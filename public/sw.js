// Service Worker para PDV Allimport
// Fornece funcionalidade offline e sincronização automática

const CACHE_NAME = 'pdv-allimport-v1';
const OFFLINE_URL = '/offline.html';

// Recursos essenciais para cache
const ESSENTIAL_RESOURCES = [
  '/',
  '/offline.html',
  '/manifest.json',
  '/static/js/bundle.js',
  '/static/css/main.css'
];

// Dados para cache offline
const OFFLINE_DATA_KEY = 'pdv-offline-data';
const SYNC_QUEUE_KEY = 'pdv-sync-queue';

// Instalar Service Worker
self.addEventListener('install', (event) => {
  console.log('🔧 Service Worker: Instalando...');
  
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('📦 Cache: Armazenando recursos essenciais');
      return cache.addAll(ESSENTIAL_RESOURCES.map(url => new Request(url, {
        cache: 'reload'
      })));
    })
  );
  
  // Força ativação imediata
  self.skipWaiting();
});

// Ativar Service Worker
self.addEventListener('activate', (event) => {
  console.log('✅ Service Worker: Ativado');
  
  event.waitUntil(
    // Limpar caches antigos
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('🗑️ Cache: Removendo cache antigo:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  
  // Assume controle de todas as abas
  self.clients.claim();
});

// Interceptar requisições (estratégia Network First com fallback para cache)
self.addEventListener('fetch', (event) => {
  // Só interceptar requisições GET
  if (event.request.method !== 'GET') return;
  
  // Estratégia para navegação (páginas HTML)
  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          // Se online, armazenar no cache e retornar
          const responseClone = response.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseClone);
          });
          return response;
        })
        .catch(() => {
          // Se offline, tentar cache ou página offline
          return caches.match(event.request)
            .then((cachedResponse) => {
              return cachedResponse || caches.match(OFFLINE_URL);
            });
        })
    );
    return;
  }
  
  // Estratégia para recursos estáticos (CSS, JS, imagens)
  if (event.request.destination === 'script' || 
      event.request.destination === 'style' || 
      event.request.destination === 'image') {
    event.respondWith(
      caches.match(event.request)
        .then((cachedResponse) => {
          if (cachedResponse) {
            return cachedResponse;
          }
          
          return fetch(event.request).then((response) => {
            const responseClone = response.clone();
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(event.request, responseClone);
            });
            return response;
          });
        })
    );
    return;
  }
  
  // Para requisições de API (Supabase)
  if (event.request.url.includes('supabase.co')) {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          // Se a requisição for bem-sucedida, processar fila de sincronização
          if (response.ok) {
            processSyncQueue();
          }
          return response;
        })
        .catch((error) => {
          console.log('🔴 API offline, adicionando à fila:', event.request.url);
          
          // Se for uma requisição POST/PUT/DELETE, adicionar à fila de sincronização
          if (event.request.method !== 'GET') {
            addToSyncQueue(event.request);
          }
          
          // Retornar dados em cache se disponível
          return getOfflineData(event.request);
        })
    );
    return;
  }
});

// Adicionar requisições à fila de sincronização
async function addToSyncQueue(request) {
  try {
    const requestData = {
      url: request.url,
      method: request.method,
      headers: Object.fromEntries(request.headers.entries()),
      body: await request.text(),
      timestamp: Date.now()
    };
    
    // Obter fila atual
    const syncQueue = await getSyncQueue();
    syncQueue.push(requestData);
    
    // Salvar fila atualizada
    await setSyncQueue(syncQueue);
    
    console.log('📝 Adicionado à fila de sincronização:', requestData.url);
  } catch (error) {
    console.error('❌ Erro ao adicionar à fila:', error);
  }
}

// Processar fila de sincronização
async function processSyncQueue() {
  try {
    const syncQueue = await getSyncQueue();
    
    if (syncQueue.length === 0) return;
    
    console.log('🔄 Processando fila de sincronização:', syncQueue.length, 'itens');
    
    const processedItems = [];
    
    for (const item of syncQueue) {
      try {
        const response = await fetch(item.url, {
          method: item.method,
          headers: item.headers,
          body: item.body
        });
        
        if (response.ok) {
          processedItems.push(item);
          console.log('✅ Sincronizado:', item.url);
        }
      } catch (error) {
        console.log('⏳ Falha na sincronização (tentará novamente):', item.url);
      }
    }
    
    // Remover itens processados da fila
    if (processedItems.length > 0) {
      const updatedQueue = syncQueue.filter(item => 
        !processedItems.some(processed => 
          processed.url === item.url && processed.timestamp === item.timestamp
        )
      );
      
      await setSyncQueue(updatedQueue);
      
      // Notificar clientes sobre sincronização
      notifyClients({
        type: 'SYNC_COMPLETE',
        processed: processedItems.length,
        remaining: updatedQueue.length
      });
    }
  } catch (error) {
    console.error('❌ Erro ao processar fila de sincronização:', error);
  }
}

// Background Sync para quando a conexão voltar
self.addEventListener('sync', (event) => {
  console.log('🔄 Background Sync:', event.tag);
  
  if (event.tag === 'pdv-sync') {
    event.waitUntil(processSyncQueue());
  }
});

// Gerenciar dados offline no IndexedDB
async function getOfflineData(request) {
  // Implementar lógica para recuperar dados offline
  // Por enquanto, retornar uma resposta padrão
  return new Response(
    JSON.stringify({ 
      offline: true, 
      message: 'Dados offline não disponíveis' 
    }),
    { 
      headers: { 'Content-Type': 'application/json' },
      status: 503
    }
  );
}

// Utilitários para gerenciar fila de sincronização
async function getSyncQueue() {
  try {
    const data = await localforage.getItem(SYNC_QUEUE_KEY);
    return data || [];
  } catch {
    return [];
  }
}

async function setSyncQueue(queue) {
  try {
    await localforage.setItem(SYNC_QUEUE_KEY, queue);
  } catch (error) {
    console.error('❌ Erro ao salvar fila:', error);
  }
}

// Notificar clientes (páginas abertas)
function notifyClients(message) {
  self.clients.matchAll().then((clients) => {
    clients.forEach((client) => {
      client.postMessage(message);
    });
  });
}

// Monitorar mudanças de conectividade
self.addEventListener('online', () => {
  console.log('🌐 Conexão restaurada - iniciando sincronização');
  processSyncQueue();
});

self.addEventListener('offline', () => {
  console.log('📴 Conexão perdida - modo offline ativado');
});

console.log('🚀 PDV Allimport Service Worker carregado');
