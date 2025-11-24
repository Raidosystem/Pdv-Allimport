// Proxy para API PIX - contorna CORS
export default async function handler(req, res) {
  // Configurar CORS
  res.setHeader('Access-Control-Allow-Origin', 'https://pdv.gruporaval.com.br');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Allow-Credentials', 'true');

  // Responder OPTIONS (preflight)
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  // Apenas POST permitido
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    // Fazer requisição ao backend real
    const response = await fetch('https://pdv.crmvsystem.com/api/pix', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(req.body),
    });

    const data = await response.json();
    
    res.status(response.status).json(data);
  } catch (error) {
    console.error('Erro no proxy PIX:', error);
    res.status(500).json({ 
      error: 'Erro ao processar pagamento PIX',
      details: error.message 
    });
  }
}
