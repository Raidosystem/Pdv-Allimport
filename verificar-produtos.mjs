import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { persistSession: false }
});

async function verificarProdutos() {
  console.log('🔍 Verificando produtos no sistema...\n');

  try {
    // Verificar produtos existentes
    const { data: produtos, error } = await supabase
      .from('produtos')
      .select('id, nome, preco, user_id')
      .limit(10);

    if (error) {
      console.error('❌ Erro ao buscar produtos:', error);
      return;
    }

    console.log(`📦 Total de produtos encontrados: ${produtos?.length || 0}`);
    
    if (produtos && produtos.length > 0) {
      console.log('\n📋 Primeiros produtos:');
      produtos.forEach((produto, index) => {
        console.log(`${index + 1}. ${produto.nome} - R$ ${produto.preco}`);
        console.log(`   ID: ${produto.id}`);
        console.log(`   USER_ID: ${produto.user_id || 'FALTANDO'}\n`);
      });

      // Contar quantos têm user_id
      const comUserId = produtos.filter(p => p.user_id).length;
      const semUserId = produtos.length - comUserId;
      
      console.log(`✅ Produtos com user_id: ${comUserId}`);
      console.log(`❌ Produtos sem user_id: ${semUserId}`);
    } else {
      console.log('⚠️ Nenhum produto encontrado');
    }

  } catch (error) {
    console.error('❌ Erro geral:', error);
  }
}

verificarProdutos();
