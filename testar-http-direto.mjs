import fetch from 'node-fetch';

const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

console.log('🔍 Testando requisições HTTP diretas para Supabase Auth...');

// Testar endpoint de login
async function testarRequisicaoAuth() {
    const authUrl = `${SUPABASE_URL}/auth/v1/token?grant_type=password`;
    
    const headers = {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    };
    
    const body = JSON.stringify({
        email: 'admin@pdv.com',
        password: 'admin123'
    });
    
    console.log('📡 URL:', authUrl);
    console.log('📋 Headers:', headers);
    console.log('📦 Body:', body);
    
    try {
        console.log('🚀 Enviando requisição...');
        const response = await fetch(authUrl, {
            method: 'POST',
            headers,
            body
        });
        
        console.log('📊 Status:', response.status);
        console.log('📋 Response Headers:', Object.fromEntries(response.headers));
        
        const responseText = await response.text();
        console.log('📄 Response Body:', responseText);
        
        if (response.ok) {
            console.log('✅ Requisição HTTP direta funcionou!');
        } else {
            console.log('❌ Requisição HTTP direta falhou!');
        }
        
    } catch (error) {
        console.error('❌ Erro na requisição:', error.message);
    }
}

// Testar também o endpoint de usuário
async function testarEndpointUser() {
    const userUrl = `${SUPABASE_URL}/auth/v1/user`;
    
    const headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    };
    
    console.log('\n🔍 Testando endpoint /auth/v1/user...');
    console.log('📡 URL:', userUrl);
    console.log('📋 Headers:', headers);
    
    try {
        const response = await fetch(userUrl, {
            method: 'GET',
            headers
        });
        
        console.log('📊 Status:', response.status);
        const responseText = await response.text();
        console.log('📄 Response:', responseText);
        
    } catch (error) {
        console.error('❌ Erro:', error.message);
    }
}

testarRequisicaoAuth().then(() => {
    return testarEndpointUser();
});
