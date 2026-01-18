// Service Worker para PWA - PDV Allimport
const CACHE_VERSION = '2.3.3'; // ATUALIZAR SEMPRE QUE FIZER DEPLOY
const CACHE_NAME = `pdv-allimport-v${CACHE_VERSION}`;
const STATIC_CACHE = `pdv-static-v${CACHE_VERSION}`;

// Recursos essenciais para cache (apenas os que existem com certeza)
const CORE_FILES = [
  '/manifest.json'
];

// Install event - cache core files e FORÇA ATUALIZAÇÃO IMEDIATA
self.addEventListener('install', event => {
  console.log(`🆕 SW v${CACHE_VERSION}: Installing...`);
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('SW: Cache criado');
        // Tentar cachear arquivos individualmente sem falhar
        return Promise.allSettled(
          CORE_FILES.map(file => 
            cache.add(file).catch(err => {
              console.log(`SW: Não foi possível cachear ${file}`);
              return null;
            })
          )
        );
      })
      .then(() => {
        console.log('✅ SW: Install complete - SKIP WAITING FORÇADO');
        // FORÇA atualização imediata sem esperar
        return self.skipWaiting();
      })
      .catch(err => {
        console.log('SW: Install com avisos:', err);
        return self.skipWaiting(); // Continuar mesmo com erros
      })
  );
});

// Activate event - clean old caches e ASSUME CONTROLE IMEDIATO
self.addEventListener('activate', event => {
  console.log(`🔄 SW v${CACHE_VERSION}: Activating...`);
  event.waitUntil(
    Promise.all([
      // Clean old caches
      caches.keys().then(cacheNames => {
        return Promise.all(
          cacheNames.map(cacheName => {
            if (cacheName !== CACHE_NAME && cacheName !== STATIC_CACHE) {
              console.log('🗑️ SW: Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      }),
      // Take control immediately - FORÇA RELOAD
      self.clients.claim().then(() => {
        console.log('✅ SW: Control claimed - RELOADING clients');
        // FORÇA reload de TODAS as abas abertas
        return self.clients.matchAll({ type: 'window' }).then(clients => {
          clients.forEach(client => {
            console.log('🔄 Reloading client:', client.url);
            client.navigate(client.url);
          });
        });
      })
    ]).then(() => {
      console.log('✅ SW: Activation complete');
    })
  );
});

// Listener para SKIP_WAITING forçado pelo app
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    console.log('⚡ SW: SKIP_WAITING recebido do app');
    self.skipWaiting();
  }
});

// Fetch event - serve from cache when offline
self.addEventListener('fetch', event => {
  // Only handle same-origin requests
  if (!event.request.url.startsWith(self.location.origin)) {
    return;
  }

  // ❌ NÃO CACHEAR REQUISIÇÕES POST/PUT/DELETE (apenas GET)
  if (event.request.method !== 'GET') {
    return;
  }

  // ❌ NÃO CACHEAR APIs do Supabase (sempre buscar dados frescos)
  if (event.request.url.includes('supabase.co')) {
    return;
  }

  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Return cached version or fetch from network
        return response || fetch(event.request)
          .then(fetchResponse => {
            // Cache successful responses (apenas GET de recursos estáticos)
            if (fetchResponse.status === 200 && event.request.method === 'GET') {
              // Apenas cachear assets estáticos (JS, CSS, imagens)
              const url = new URL(event.request.url);
              const isStaticAsset = /\.(js|css|png|jpg|jpeg|gif|svg|woff|woff2|ttf|ico)$/.test(url.pathname);
              
              if (isStaticAsset) {
                const responseClone = fetchResponse.clone();
                caches.open(CACHE_NAME)
                  .then(cache => {
                    cache.put(event.request, responseClone);
                  })
                  .catch(err => {
                    console.log('SW: Erro ao cachear:', err);
                  });
              }
            }
            return fetchResponse;
          })
          .catch(err => {
            // Fallback for navigation requests
            if (event.request.mode === 'navigate') {
              return caches.match('/index.html');
            }
            throw err;
          });
      })
  );
});
