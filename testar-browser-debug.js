// Teste para verificar se o debug está funcionando no browser
import { createClient } from '@supabase/supabase-js';

// Usar as mesmas credenciais hardcoded que estão no código
const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

console.log('🔍 TESTE LOCAL - Verificando configuração Supabase...');
console.log('SUPABASE_URL:', SUPABASE_URL);
console.log('SUPABASE_ANON_KEY:', SUPABASE_ANON_KEY?.substring(0, 20) + '...');

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

console.log('🔧 Client criado:', supabase);

// Testar autenticação
async function testarAuth() {
    try {
        console.log('🔐 Testando login...');
        const { data, error } = await supabase.auth.signInWithPassword({
            email: 'admin@pdv.com',
            password: 'admin123'
        });
        
        if (error) {
            console.error('❌ Erro no login:', error.message);
            console.error('Erro completo:', error);
        } else {
            console.log('✅ Login sucesso:', data);
        }
    } catch (err) {
        console.error('❌ Exception durante login:', err);
    }
}

testarAuth();
