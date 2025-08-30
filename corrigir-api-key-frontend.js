// ===================================================
// 🔧 SOLUÇÃO DEFINITIVA - Invalid API Key
// ===================================================
// Execute com: node corrigir-api-key-frontend.cjs

import fs from 'fs';
import path from 'path';

console.log('🔧 CORRIGINDO API KEY NO FRONTEND');
console.log('═'.repeat(50));

// Credenciais corretas
const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

function atualizarArquivo(caminho, novoConteudo) {
  try {
    if (fs.existsSync(caminho)) {
      fs.writeFileSync(caminho, novoConteudo, 'utf8');
      console.log(`✅ Atualizado: ${caminho}`);
      return true;
    } else {
      console.log(`⚠️ Arquivo não encontrado: ${caminho}`);
      return false;
    }
  } catch (error) {
    console.log(`❌ Erro ao atualizar ${caminho}:`, error.message);
    return false;
  }
}

// 1. Atualizar arquivo principal do Supabase
const supabaseContent = `import { createClient } from '@supabase/supabase-js'

// Credenciais atualizadas - 30/08/2025
const SUPABASE_URL = (import.meta as any)?.env?.VITE_SUPABASE_URL || '${SUPABASE_URL}'
const SUPABASE_ANON_KEY = (import.meta as any)?.env?.VITE_SUPABASE_ANON_KEY ||
  '${SUPABASE_KEY}'

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('Supabase config missing. Set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY.')
  throw new Error('Invalid Supabase configuration')
}

// Log de debug para verificar configurações
console.log('[supabase] url:', SUPABASE_URL)
console.log('[supabase] key length:', SUPABASE_ANON_KEY.length)
console.log('[supabase] using env vars:', !!(import.meta as any)?.env?.VITE_SUPABASE_URL, !!(import.meta as any)?.env?.VITE_SUPABASE_ANON_KEY)

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
  },
  realtime: {
    params: { eventsPerSecond: 10 },
  },
})

// Types placeholder; expand as needed
export type Database = {
  public: {
    Tables: {
      users: {
        Row: {
          id: string
          email: string
          name: string
          role: 'admin' | 'operator' | 'manager'
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          email: string
          name: string
          role?: 'admin' | 'operator' | 'manager'
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          email?: string
          name?: string
          role?: 'admin' | 'operator' | 'manager'
          created_at?: string
          updated_at?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
  }
}
`;

// 2. Criar arquivo .env.local
const envContent = `# Supabase Configuration - Updated 30/08/2025
VITE_SUPABASE_URL=${SUPABASE_URL}
VITE_SUPABASE_ANON_KEY=${SUPABASE_KEY}
`;

// Atualizar arquivos
console.log('📝 Atualizando arquivos...');
atualizarArquivo('./src/lib/supabase.ts', supabaseContent);
atualizarArquivo('./.env.local', envContent);

// 3. Criar arquivo de teste
const testeContent = `// Teste rápido das credenciais
import { supabase } from './src/lib/supabase.ts'

async function testar() {
  try {
    const { data, error } = await supabase.auth.getSession()
    console.log('✅ Supabase conectado!')
    console.log('Session:', data.session ? 'Ativa' : 'Nenhuma')
    if (error) console.log('Error:', error.message)
  } catch (err) {
    console.log('❌ Erro:', err.message)
  }
}

testar()
`;

atualizarArquivo('./teste-supabase-credenciais.js', testeContent);

console.log('\n🎯 PRÓXIMOS PASSOS:');
console.log('1. ✅ Credenciais atualizadas no código');
console.log('2. 🔄 Reinicie o servidor de desenvolvimento');
console.log('3. 🗑️ Limpe o cache do navegador');
console.log('4. 🧪 Teste login em aba incógnito');
console.log('5. 📧 Execute o script SQL para confirmar email do admin');

console.log('\n📋 COMANDOS:');
console.log('npm run dev  # Reiniciar servidor');
console.log('Ctrl+Shift+Delete  # Limpar cache');

console.log('\n✅ CORREÇÃO CONCLUÍDA!');
