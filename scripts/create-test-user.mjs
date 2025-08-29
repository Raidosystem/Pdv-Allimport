import 'dotenv/config'
import { createClient } from '@supabase/supabase-js'

const url = process.env.SUPABASE_URL
const anonKey = process.env.SUPABASE_ANON_KEY
const email = process.env.TEST_USER_EMAIL
const password = process.env.TEST_USER_PASSWORD

if (!url || !anonKey || !email || !password) {
  console.error('⚠️ Defina SUPABASE_URL, SUPABASE_ANON_KEY, TEST_USER_EMAIL e TEST_USER_PASSWORD')
  process.exit(1)
}

const supabase = createClient(url, anonKey)

async function main() {
  const { error } = await supabase.auth.signUp({ email, password })
  if (error) {
    console.error('Erro ao criar usuário:', error.message)
  } else {
    console.log('✅ Usuário de teste criado:', email)
  }
}

main()
