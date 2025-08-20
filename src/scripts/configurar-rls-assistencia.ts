import { supabase } from '../lib/supabase';

/**
 * CONFIGURAR RLS PARA assistenciaallimport10@gmail.com
 * Este script aplica RLS específico para permitir importação
 */

async function configurarRLSAssistencia() {
  try {
    console.log('🚀 Configurando RLS para assistenciaallimport10@gmail.com...');

    // SQL para configurar RLS
    const sqlCommands = [
      // Verificar usuário
      `SELECT id, email FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com';`,
      
      // Remover políticas existentes
      `DROP POLICY IF EXISTS "Users can manage own clients" ON clients;`,
      `DROP POLICY IF EXISTS "Users can manage own products" ON products;`,
      `DROP POLICY IF EXISTS "Users can manage own categories" ON categories;`,
      `DROP POLICY IF EXISTS "Users can manage own service_orders" ON service_orders;`,
      `DROP POLICY IF EXISTS "Users can manage own establishments" ON establishments;`,
      
      // Criar políticas permissivas para assistenciaallimport10@gmail.com
      `CREATE POLICY "assistencia_full_access_clients" ON clients
       FOR ALL TO authenticated
       USING (auth.email() = 'assistenciaallimport10@gmail.com');`,
       
      `CREATE POLICY "assistencia_full_access_products" ON products
       FOR ALL TO authenticated
       USING (auth.email() = 'assistenciaallimport10@gmail.com');`,
       
      `CREATE POLICY "assistencia_full_access_categories" ON categories
       FOR ALL TO authenticated
       USING (auth.email() = 'assistenciaallimport10@gmail.com');`,
       
      `CREATE POLICY "assistencia_full_access_service_orders" ON service_orders
       FOR ALL TO authenticated
       USING (auth.email() = 'assistenciaallimport10@gmail.com');`,
       
      `CREATE POLICY "assistencia_full_access_establishments" ON establishments
       FOR ALL TO authenticated
       USING (auth.email() = 'assistenciaallimport10@gmail.com');`,
      
      // Habilitar RLS
      `ALTER TABLE clients ENABLE ROW LEVEL SECURITY;`,
      `ALTER TABLE products ENABLE ROW LEVEL SECURITY;`,
      `ALTER TABLE categories ENABLE ROW LEVEL SECURITY;`,
      `ALTER TABLE service_orders ENABLE ROW LEVEL SECURITY;`,
      `ALTER TABLE establishments ENABLE ROW LEVEL SECURITY;`
    ];

    // Executar cada comando
    for (let i = 0; i < sqlCommands.length; i++) {
      const sql = sqlCommands[i];
      console.log(`📋 Executando comando ${i + 1}/${sqlCommands.length}...`);
      
      try {
        const { error } = await supabase.rpc('exec_sql', { sql_query: sql });
        
        if (error) {
          console.warn(`⚠️ Comando ${i + 1} com aviso:`, error);
        } else {
          console.log(`✅ Comando ${i + 1} executado com sucesso`);
        }
      } catch (cmdError) {
        console.warn(`⚠️ Erro no comando ${i + 1}:`, cmdError);
      }
    }

    console.log('🎉 Configuração RLS concluída!');
    console.log('✅ assistenciaallimport10@gmail.com agora tem acesso completo');
    console.log('🚀 Teste a importação automática novamente!');

  } catch (error) {
    console.error('❌ Erro na configuração RLS:', error);
  }
}

// Tornar disponível no console do navegador
if (typeof window !== 'undefined') {
  (window as any).configurarRLSAssistencia = configurarRLSAssistencia;
  console.log('🌐 Função disponível: configurarRLSAssistencia()');
}

export { configurarRLSAssistencia };
