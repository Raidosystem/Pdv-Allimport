// Service Worker para PWA - PDV Allimport
const CACHE_NAME = 'pdv-allimport-v2.2.5';
const STATIC_CACHE = 'pdv-static-v2.2.5';

// Recursos essenciais para cache
const CORE_FILES = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icons/icon-192x192.png',
  '/icons/icon-512x512.png'
];

// Install event - cache core files
self.addEventListener('install', event => {
  console.log('SW v2.2.5: Installing...');
  event.waitUntil(
    Promise.all([
      caches.open(STATIC_CACHE)
        .then(cache => {
          console.log('SW: Caching core files');
          return cache.addAll(CORE_FILES).catch(err => {
            console.warn('SW: Some files failed to cache:', err);
            // Tentar cachear arquivos individualmente
            return Promise.allSettled(
              CORE_FILES.map(file => cache.add(file))
            );
          });
        }),
      caches.open(CACHE_NAME)
        .then(cache => {
          console.log('SW: Cache opened');
          return cache.add('/');
        })
    ]).then(() => {
      console.log('SW: Install complete');
      return self.skipWaiting();
    }).catch(err => {
      console.error('SW: Install failed:', err);
    })
  );
});

// Activate event - clean old caches
self.addEventListener('activate', event => {
  console.log('SW: Activating...');
  event.waitUntil(
    Promise.all([
      // Clean old caches
      caches.keys().then(cacheNames => {
        return Promise.all(
          cacheNames.map(cacheName => {
            if (cacheName !== CACHE_NAME && cacheName !== STATIC_CACHE) {
              console.log('SW: Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      }),
      // Take control immediately
      self.clients.claim()
    ]).then(() => {
      console.log('SW: Activation complete');
    })
  );
});

// Fetch event - serve from cache when offline
self.addEventListener('fetch', event => {
  // Only handle same-origin requests
  if (!event.request.url.startsWith(self.location.origin)) {
    return;
  }

  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Return cached version or fetch from network
        return response || fetch(event.request)
          .then(fetchResponse => {
            // Cache successful responses
            if (fetchResponse.status === 200) {
              const responseClone = fetchResponse.clone();
              caches.open(CACHE_NAME)
                .then(cache => {
                  cache.put(event.request, responseClone);
                });
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
