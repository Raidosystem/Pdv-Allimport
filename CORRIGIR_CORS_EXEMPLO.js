/**
 * 🔒 CORREÇÃO CORS - SUBSTITUIR WILDCARD POR DOMÍNIOS ESPECÍFICOS
 * 
 * Aplicar este padrão em TODOS os arquivos api/
 */

// =====================================================
// ❌ ANTES (VULNERÁVEL)
// =====================================================
res.setHeader('Access-Control-Allow-Origin', '*');

// =====================================================
// ✅ DEPOIS (SEGURO)
// =====================================================
const allowedOrigins = [
  'https://pdv.crmvsystem.com',
  'https://pdv.gruporaval.com.br',
  // Apenas em desenvolvimento local
  ...(process.env.NODE_ENV === 'development' ? ['http://localhost:5174'] : [])
];

const origin = req.headers.origin;

if (allowedOrigins.includes(origin)) {
  res.setHeader('Access-Control-Allow-Origin', origin);
  res.setHeader('Access-Control-Allow-Credentials', 'true');
} else {
  console.warn(`🚨 CORS bloqueado para origem não autorizada: ${origin}`);
}

// =====================================================
// 📝 ARQUIVOS QUE PRECISAM SER CORRIGIDOS:
// =====================================================
// 1. api/backup_funcionando/api/test-mp.js (linha 4)
// 2. api/backup_funcionando/api/test.js (linha 3)
// 3. api/backup_funcionando/api/test-backurls.js (linha 3)
//
// OU DELETAR A PASTA api/backup_funcionando/ se forem backups antigos

// =====================================================
// ✅ EXEMPLO COMPLETO DE HANDLER SEGURO
// =====================================================
export default async function handler(req, res) {
  // 1. Configurar CORS seguro
  const allowedOrigins = [
    'https://pdv.crmvsystem.com',
    'https://pdv.gruporaval.com.br',
    ...(process.env.NODE_ENV === 'development' ? ['http://localhost:5174'] : [])
  ];

  const origin = req.headers.origin;
  
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Access-Control-Allow-Credentials', 'true');
  }
  
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // 2. Handle preflight
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // 3. Validar método
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // 4. Rate limiting (implementar depois)
  // const limiter = await checkRateLimit(req);
  // if (!limiter.success) {
  //   return res.status(429).json({ error: 'Too many requests' });
  // }

  // 5. Validar input
  const { payment_id, user_email } = req.body;
  
  if (!payment_id || !user_email) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  // Validar formato
  if (!/^[0-9]+$/.test(payment_id)) {
    return res.status(400).json({ error: 'Invalid payment_id format' });
  }

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(user_email)) {
    return res.status(400).json({ error: 'Invalid email format' });
  }

  // 6. Processar requisição
  try {
    // ... lógica da API
    return res.status(200).json({ success: true });
  } catch (error) {
    // NÃO logar dados sensíveis
    console.error('Erro ao processar:', {
      type: error.name,
      message: error.message
      // NÃO incluir: payment_id, user_email, tokens
    });
    
    return res.status(500).json({ error: 'Internal server error' });
  }
}
