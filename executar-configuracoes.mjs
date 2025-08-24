const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

async function executarSQL() {
  try {
    console.log('🔧 Executando SQL para criar tabela de configurações...');
    
    // SQL para criar a tabela
    const sql = `
-- Criar tabela de configurações da empresa se não existir
CREATE TABLE IF NOT EXISTS public.configuracoes_empresa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    nome_empresa TEXT NOT NULL,
    cnpj TEXT,
    telefone TEXT,
    endereco TEXT,
    cidade TEXT,
    estado TEXT,
    cep TEXT,
    email TEXT,
    logo_url TEXT,
    cor_primaria TEXT DEFAULT '#3B82F6',
    cor_secundaria TEXT DEFAULT '#1E40AF',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE public.configuracoes_empresa ENABLE ROW LEVEL SECURITY;

-- Política para o usuário ver apenas suas configurações
DROP POLICY IF EXISTS "Usuários podem ver suas próprias configurações de empresa" ON public.configuracoes_empresa;
CREATE POLICY "Usuários podem ver suas próprias configurações de empresa" ON public.configuracoes_empresa
    FOR ALL USING (auth.uid() = user_id);
`;

    const response = await fetch(`${supabaseUrl}/rest/v1/rpc/execute_sql`, {
      method: 'POST',
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ sql })
    });

    if (response.ok) {
      console.log('✅ SQL executado com sucesso!');
    } else {
      const error = await response.text();
      console.log('❌ Erro ao executar SQL:', error);
    }

    // Agora verificar as tabelas novamente
    console.log('\n=== VERIFICAÇÃO APÓS CRIAÇÃO ===\n');
    
    const tabelas = ['produtos', 'clientes', 'vendas', 'ordens_servico', 'funcionarios', 'configuracoes_empresa'];
    
    for (const tabela of tabelas) {
      try {
        const res = await fetch(`${supabaseUrl}/rest/v1/${tabela}?select=*&limit=3`, {
          headers: {
            'apikey': supabaseKey,
            'Authorization': `Bearer ${supabaseKey}`
          }
        });
        
        if (res.ok) {
          const data = await res.json();
          console.log(`✅ ${tabela.toUpperCase()}: ${data.length} registros encontrados`);
          
          if (data.length > 0) {
            if (tabela === 'funcionarios') {
              console.log('   Funcionários:', data.map(f => ({ nome: f.nome, cargo: f.cargo, ativo: f.ativo })));
            } else if (tabela === 'configuracoes_empresa') {
              console.log('   Empresa:', data.map(e => ({ nome: e.nome_empresa, cnpj: e.cnpj })));
            }
          }
        } else {
          const error = await res.json();
          console.log(`❌ ${tabela}: ${error.message}`);
        }
      } catch (e) {
        console.log(`❌ ${tabela}: Erro - ${e.message}`);
      }
    }
    
  } catch (error) {
    console.error('Erro geral:', error.message);
  }
}

executarSQL();
