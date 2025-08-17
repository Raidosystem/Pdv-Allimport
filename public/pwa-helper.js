// PWA Install Helper - Script para maximizar compatibilidade de instalação
(function() {
  console.log('🚀 PWA Install Helper carregado');
  
  // Função para verificar se pode ser instalado
  function canInstall() {
    // Verifica se já está instalado
    if (window.matchMedia('(display-mode: standalone)').matches) {
      console.log('📱 App já está instalado');
      return false;
    }
    
    // Verifica se é um navegador compatível
    const isChrome = /Chrome/.test(navigator.userAgent);
    const isEdge = /Edg/.test(navigator.userAgent);
    const isFirefox = /Firefox/.test(navigator.userAgent);
    const isSafari = /Safari/.test(navigator.userAgent) && !/Chrome/.test(navigator.userAgent);
    
    return isChrome || isEdge || isFirefox || isSafari;
  }
  
  // Adicionar dados estruturados para PWA
  function addStructuredData() {
    const script = document.createElement('script');
    script.type = 'application/ld+json';
    script.textContent = JSON.stringify({
      "@context": "https://schema.org",
      "@type": "WebApplication",
      "name": "PDV Allimport",
      "description": "Sistema de Ponto de Venda completo",
      "url": window.location.origin,
      "applicationCategory": "BusinessApplication",
      "operatingSystem": "Any",
      "offers": {
        "@type": "Offer",
        "price": "0",
        "priceCurrency": "BRL"
      },
      "featureList": [
        "Funciona offline",
        "Controle de estoque", 
        "Vendas e relatórios",
        "Interface responsiva"
      ]
    });
    document.head.appendChild(script);
    console.log('📊 Dados estruturados adicionados');
  }
  
  // Adicionar meta tags extras para PWA
  function addPWAMetaTags() {
    const metaTags = [
      { name: 'mobile-web-app-capable', content: 'yes' },
      { name: 'apple-mobile-web-app-capable', content: 'yes' },
      { name: 'apple-mobile-web-app-status-bar-style', content: 'default' },
      { name: 'apple-mobile-web-app-title', content: 'PDV Allimport' },
      { name: 'application-name', content: 'PDV Allimport' },
      { name: 'msapplication-starturl', content: '/' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1, shrink-to-fit=no, user-scalable=no, viewport-fit=cover' }
    ];
    
    metaTags.forEach(tag => {
      // Só adiciona se não existir
      if (!document.querySelector(`meta[name="${tag.name}"]`)) {
        const meta = document.createElement('meta');
        meta.name = tag.name;
        meta.content = tag.content;
        document.head.appendChild(meta);
      }
    });
    
    console.log('🏷️ Meta tags PWA verificadas/adicionadas');
  }
  
  // Log de informações sobre instalabilidade
  function logInstallInfo() {
    console.log('🔍 Informações de instalação:');
    console.log('- Navegador:', navigator.userAgent);
    console.log('- Pode instalar:', canInstall());
    console.log('- Já instalado:', window.matchMedia('(display-mode: standalone)').matches);
    console.log('- Service Worker suportado:', 'serviceWorker' in navigator);
    console.log('- Manifest encontrado:', !!document.querySelector('link[rel="manifest"]'));
  }
  
  // Executar quando DOM estiver pronto
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
      addStructuredData();
      addPWAMetaTags();
      logInstallInfo();
    });
  } else {
    addStructuredData();
    addPWAMetaTags();
    logInstallInfo();
  }
  
  // Adicionar listener global para evento de instalação
  window.addEventListener('beforeinstallprompt', function(e) {
    console.log('🎯 Evento beforeinstallprompt detectado!');
    console.log('📱 App pode ser instalado via prompt nativo');
  });
  
  window.addEventListener('appinstalled', function(e) {
    console.log('✅ App foi instalado com sucesso!');
  });
  
})();
