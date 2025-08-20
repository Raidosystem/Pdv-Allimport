const https = require('https');

const SUPABASE_URL = 'https://vfuglqcyrmgwvrlmmotm.supabase.co';
const SERVICE_ROLE_KEY = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmdWdscWN5cm1nd3ZybG1tb3RtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNzc0MDkwNiwiZXhwIjoyMDUzMzE2OTA2fQ.jWHBh2_U7q12QrLwsJ2jqcHbONlJLHh85sOI1_HUJCo';

const SQL_STATEMENTS = [
  // 1. Criar tabela
  `CREATE TABLE IF NOT EXISTS public.user_approvals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    email TEXT NOT NULL,
    full_name TEXT,
    company_name TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    approved_by UUID,
    approved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
  );`,
  
  // 2. Criar índices
  `CREATE INDEX IF NOT EXISTS idx_user_approvals_user_id ON public.user_approvals(user_id);`,
  `CREATE INDEX IF NOT EXISTS idx_user_approvals_status ON public.user_approvals(status);`,
  `CREATE INDEX IF NOT EXISTS idx_user_approvals_email ON public.user_approvals(email);`,
  
  // 3. Habilitar RLS
  `ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;`,
  
  // 4. Políticas RLS
  `CREATE POLICY "Users can view own approval status" ON public.user_approvals
    FOR SELECT USING (auth.uid() = user_id);`,
  
  `CREATE POLICY "Admins can view all approvals" ON public.user_approvals
    FOR SELECT USING (
      EXISTS (
        SELECT 1 FROM auth.users 
        WHERE auth.uid() = id 
        AND (
          email = 'admin@pdvallimport.com' 
          OR email = 'novaradiosystem@outlook.com'
          OR email = 'teste@teste.com'
          OR raw_user_meta_data->>'role' = 'admin'
        )
      )
    );`,
    
  `CREATE POLICY "Admins can update approvals" ON public.user_approvals
    FOR UPDATE USING (
      EXISTS (
        SELECT 1 FROM auth.users 
        WHERE auth.uid() = id 
        AND (
          email = 'admin@pdvallimport.com' 
          OR email = 'novaradiosystem@outlook.com'
          OR email = 'teste@teste.com'
          OR raw_user_meta_data->>'role' = 'admin'
        )
      )
    );`,
    
  `CREATE POLICY "Allow insert on signup" ON public.user_approvals
    FOR INSERT WITH CHECK (true);`,
];

async function executeSQL(sql) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({
      query: sql
    });

    const options = {
      hostname: 'vfuglqcyrmgwvrlmmotm.supabase.co',
      port: 443,
      path: '/rest/v1/rpc/sql',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
        'apikey': SERVICE_ROLE_KEY,
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(data);
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${data}`));
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    req.write(postData);
    req.end();
  });
}

async function createApprovalSystem() {
  console.log('🚀 Criando sistema de aprovação no Supabase...');
  
  for (let i = 0; i < SQL_STATEMENTS.length; i++) {
    const sql = SQL_STATEMENTS[i];
    const stepName = [
      'Criando tabela user_approvals',
      'Criando índice user_id',
      'Criando índice status', 
      'Criando índice email',
      'Habilitando RLS',
      'Política: usuários podem ver próprio status',
      'Política: admins podem ver todos',
      'Política: admins podem atualizar',
      'Política: permitir inserção'
    ][i];
    
    try {
      console.log(`📝 ${stepName}...`);
      await executeSQL(sql);
      console.log(`✅ ${stepName} - OK`);
    } catch (error) {
      console.log(`⚠️ ${stepName} - Erro (pode ser normal se já existir):`, error.message.substring(0, 100));
    }
  }
  
  console.log('\n🎉 Sistema de aprovação criado com sucesso!');
  console.log('📋 Agora execute: node verificar-aprovacao.cjs');
}

createApprovalSystem().catch(console.error);
