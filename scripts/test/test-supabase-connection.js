// Teste básico de conexão com Supabase
import 'dotenv/config'

console.log('🔍 Testando conexão com Supabase...')

const SUPABASE_URL = process.env.SUPABASE_URL
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('⚠️ Defina SUPABASE_URL e SUPABASE_ANON_KEY nas variáveis de ambiente')
  process.exit(1)
}

// 1. Teste básico - verificar se URL responde
console.log('1️⃣ Testando URL básica...')
fetch(`${SUPABASE_URL}/rest/v1/`, {
  headers: {
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
    'Content-Type': 'application/json'
  }
})
.then(response => {
  console.log('✅ Status da API REST:', response.status)
  if (response.ok) {
    console.log('✅ URL e Key parecem corretas')
  } else {
    console.log('❌ Problema com URL ou Key')
  }
})
.catch(error => {
  console.log('❌ Erro na requisição REST:', error)
})

// 2. Teste do endpoint de auth
console.log('2️⃣ Testando endpoint de auth...')
fetch(`${SUPABASE_URL}/auth/v1/signup`, {
  method: 'POST',
  headers: {
    'apikey': SUPABASE_ANON_KEY,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    email: 'test@test.com',
    password: 'test123'
  })
})
.then(response => {
  console.log('🔐 Status do Auth:', response.status)
  if (response.status === 422) {
    console.log('✅ Auth endpoint funcionando (erro 422 = usuário já existe)')
  } else if (response.status === 400) {
    console.log('❌ Auth endpoint com problema (400 = Bad Request)')
  }
  return response.json()
})
.then(data => {
  console.log('🔐 Resposta do Auth:', data)
})
.catch(error => {
  console.log('❌ Erro no teste de auth:', error)
})

// 3. Teste com credenciais existentes
console.log('3️⃣ Testando login com credenciais...')
setTimeout(() => {
  fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=password`, {
    method: 'POST',
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      email: 'test@example.com',
      password: 'test-password'
    })
  })
  .then(response => {
    console.log('👤 Status do Login:', response.status)
    return response.json()
  })
  .then(data => {
    console.log('👤 Resposta do Login:', data)
  })
  .catch(error => {
    console.log('❌ Erro no login:', error)
  })
}, 3000)
