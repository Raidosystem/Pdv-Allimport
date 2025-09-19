/**
 * API para limpeza completa de cache - "Botão Nuclear"
 * Use apenas em situações críticas de cache teimoso
 */

import type { VercelRequest, VercelResponse } from '@vercel/node'

export default function handler(req: VercelRequest, res: VercelResponse) {
  try {
    console.log('🧹 Clear Cache API chamada:', {
      method: req.method,
      timestamp: new Date().toISOString(),
      userAgent: req.headers['user-agent'],
      ip: req.headers['x-forwarded-for'] || req.connection?.remoteAddress
    })

    // Configurar headers de limpeza total
    res.setHeader('Clear-Site-Data', '"cache", "cookies", "storage", "executionContexts"')
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate')
    res.setHeader('Pragma', 'no-cache')
    res.setHeader('Expires', '0')

    // Se for GET, retornar página de confirmação
    if (req.method === 'GET') {
      const html = `
        <!DOCTYPE html>
        <html>
        <head>
          <title>Limpeza de Cache - PDV AllImport</title>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            body { 
              font-family: system-ui, -apple-system, sans-serif; 
              max-width: 600px; 
              margin: 50px auto; 
              padding: 20px;
              background: #f5f5f5;
            }
            .card {
              background: white;
              padding: 30px;
              border-radius: 8px;
              box-shadow: 0 2px 10px rgba(0,0,0,0.1);
              text-align: center;
            }
            .icon { font-size: 48px; margin-bottom: 20px; }
            h1 { color: #333; margin-bottom: 20px; }
            p { color: #666; line-height: 1.6; margin-bottom: 20px; }
            .btn {
              display: inline-block;
              padding: 12px 24px;
              background: #007bff;
              color: white;
              text-decoration: none;
              border-radius: 4px;
              margin: 10px;
              transition: background 0.2s;
            }
            .btn:hover { background: #0056b3; }
            .btn-danger { background: #dc3545; }
            .btn-danger:hover { background: #c82333; }
          </style>
        </head>
        <body>
          <div class="card">
            <div class="icon">🧹</div>
            <h1>Cache Limpo com Sucesso!</h1>
            <p>
              Todos os dados em cache foram removidos:<br>
              • Cache do navegador<br>
              • Cookies<br>
              • LocalStorage<br>
              • SessionStorage
            </p>
            <p>Você será redirecionado para a página inicial em <span id="countdown">3</span> segundos.</p>
            <a href="/" class="btn">Ir para PDV agora</a>
          </div>
          
          <script>
            let count = 3;
            const countdown = document.getElementById('countdown');
            const timer = setInterval(() => {
              count--;
              countdown.textContent = count;
              if (count <= 0) {
                clearInterval(timer);
                window.location.href = '/';
              }
            }, 1000);
          </script>
        </body>
        </html>
      `
      
      res.setHeader('Content-Type', 'text/html; charset=utf-8')
      return res.status(200).send(html)
    }

    // Para outros métodos, retornar JSON
    res.status(200).json({
      success: true,
      message: 'Cache cleared successfully',
      timestamp: new Date().toISOString(),
      headers_set: [
        'Clear-Site-Data',
        'Cache-Control',
        'Pragma',
        'Expires'
      ]
    })

  } catch (error) {
    console.error('❌ Erro no clear-cache:', error)
    
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: error instanceof Error ? error.message : 'Unknown error'
    })
  }
}