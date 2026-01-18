import { useState, useEffect } from 'react'
import { X, RefreshCw } from 'lucide-react'
import { isPWA } from './PWARedirect'

// Versão atual do cache/build
const CURRENT_VERSION = '2.3.2'

/**
 * Componente que mostra notificação quando há atualização disponível no PWA
 * Aparece como um banner no topo da tela
 */
export function PWAUpdateNotification() {
  const [showUpdate, setShowUpdate] = useState(false)
  const [registration, setRegistration] = useState<ServiceWorkerRegistration | null>(null)
  const [updating, setUpdating] = useState(false)

  useEffect(() => {
    console.log('🔔 PWAUpdateNotification: Iniciando verificação de updates...');
    
    // Só mostrar em PWA
    if (!isPWA()) {
      console.log('🔔 Não é PWA, pulando verificação de updates');
      return
    }

    // Verificar se há Service Worker registrado
    if ('serviceWorker' in navigator) {
      // REGISTRAR Service Worker (garantir que está registrado)
      navigator.serviceWorker.register('/sw.js')
        .then(reg => {
          console.log('✅ Service Worker registrado:', reg);
          setRegistration(reg)

          // LISTENER 1: Detectar quando há um novo SW WAITING
          const checkUpdate = () => {
            if (reg.waiting) {
              console.log('🆕 NOVO SW DETECTADO (waiting)!');
              setShowUpdate(true);
            }
          };

          // LISTENER 2: Event updatefound - quando novo SW está instalando
          reg.addEventListener('updatefound', () => {
            console.log('🔍 Update found! Novo SW instalando...');
            const newWorker = reg.installing;
            
            if (newWorker) {
              newWorker.addEventListener('statechange', () => {
                console.log('🔄 SW state:', newWorker.state);
                if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                  // Novo SW instalado e há um SW antigo controlando
                  console.log('🆕 NOVO SW INSTALADO! Mostrando banner...');
                  setShowUpdate(true);
                }
              });
            }
          });

          // LISTENER 3: Verificação periódica a cada 10 segundos
          const interval = setInterval(() => {
            console.log('🔄 Verificando updates no SW...');
            reg.update().then(() => {
              checkUpdate();
            }).catch(err => {
              console.log('❌ Erro ao verificar update:', err);
            });
          }, 10000); // 10 segundos

          // LISTENER 4: Detectar quando o controller muda (novo SW ativou)
          navigator.serviceWorker.addEventListener('controllerchange', () => {
            console.log('🔄 Controller changed! Recarregando página...');
            window.location.reload();
          });

          // Verificar imediatamente se já há um SW waiting
          checkUpdate();

          return () => {
            clearInterval(interval);
          };
        })
        .catch(err => {
          console.error('❌ Erro ao registrar SW:', err);
        });
    } else {
      console.log('⚠️ Service Worker não suportado');
    }
  }, [])

  const handleUpdate = async () => {
    console.log('⚡ Usuário clicou em "Atualizar agora"');
    setUpdating(true)

    try {
      // Limpar caches antigos PRIMEIRO
      if ('caches' in window) {
        console.log('🗑️ Limpando caches antigos...');
        const cacheNames = await caches.keys();
        await Promise.all(cacheNames.map(name => {
          console.log('🗑️ Deletando cache:', name);
          return caches.delete(name);
        }));
      }

      // Se há Service Worker waiting, ativar
      if (registration?.waiting) {
        console.log('📤 Enviando SKIP_WAITING para SW...');
        registration.waiting.postMessage({ type: 'SKIP_WAITING' });
      }

      // Aguardar um pouco para SW processar e recarregar
      console.log('⏳ Aguardando 300ms antes de recarregar...');
      setTimeout(() => {
        console.log('🔄 RECARREGANDO PÁGINA...');
        window.location.reload();
      }, 300);
    } catch (error) {
      console.error('❌ Erro ao atualizar:', error);
      // Fallback: recarregar página imediatamente
      window.location.reload();
    }
  }

  const handleDismiss = () => {
    console.log('❌ Usuário dispensou notificação de update');
    setShowUpdate(false)
  }

  if (!showUpdate) {
    return null
  }

  console.log('🎨 Renderizando banner de update');

  return (
    <div className="fixed top-0 left-0 right-0 z-[10000] animate-slideDown">
      <div className="bg-gradient-to-r from-blue-600 via-blue-700 to-purple-600 text-white shadow-2xl">
        <div className="max-w-7xl mx-auto px-4 py-3">
          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-3 flex-1">
              <div className="flex-shrink-0 w-10 h-10 bg-white/20 rounded-full flex items-center justify-center">
                <RefreshCw className="w-5 h-5 animate-spin" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-bold text-sm md:text-base">
                  🎉 Nova atualização disponível!
                </p>
                <p className="text-xs md:text-sm text-blue-100 mt-0.5">
                  Clique em "Atualizar agora" - o app será reiniciado automaticamente
                </p>
              </div>
            </div>
            
            <div className="flex items-center gap-2 flex-shrink-0">
              <button
                onClick={handleUpdate}
                disabled={updating}
                className="px-4 py-2 bg-white text-blue-600 font-bold text-sm rounded-lg hover:bg-blue-50 transition-all shadow-lg hover:shadow-xl transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
              >
                {updating ? (
                  <>
                    <RefreshCw className="w-4 h-4 inline mr-1 animate-spin" />
                    Atualizando...
                  </>
                ) : (
                  '✨ Atualizar agora'
                )}
              </button>
              
              <button
                onClick={handleDismiss}
                className="p-2 hover:bg-white/10 rounded-lg transition-colors"
                title="Dispensar"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

// Estilo CSS inline para animação
const style = document.createElement('style')
style.textContent = `
  @keyframes slideDown {
    from {
      transform: translateY(-100%);
      opacity: 0;
    }
    to {
      transform: translateY(0);
      opacity: 1;
    }
  }
  
  .animate-slideDown {
    animation: slideDown 0.3s ease-out;
  }
`
if (!document.querySelector('style[data-pwa-update]')) {
  style.setAttribute('data-pwa-update', 'true')
  document.head.appendChild(style)
}
