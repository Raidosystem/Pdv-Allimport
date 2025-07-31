// Teste rápido do banco de dados
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testConnection() {
  console.log('Testando conexão com Supabase...');
  
  try {
    // Testar categorias
    const { data: categories, error: catError } = await supabase
      .from('categories')
      .select('*');
    
    if (catError) {
      console.error('Erro ao buscar categorias:', catError);
    } else {
      console.log('Categorias encontradas:', categories.length);
      categories.forEach(cat => console.log(`- ${cat.name}`));
    }

    // Testar produtos
    const { data: products, error: prodError } = await supabase
      .from('products')
      .select('*, categories(name)');
    
    if (prodError) {
      console.error('Erro ao buscar produtos:', prodError);
    } else {
      console.log('\nProdutos encontrados:', products.length);
      products.forEach(prod => console.log(`- ${prod.name} (${prod.categories?.name}) - R$ ${prod.price}`));
    }

    // Testar função do dashboard
    const { data: dashboard, error: dashError } = await supabase
      .rpc('get_dashboard_summary');
    
    if (dashError) {
      console.error('Erro ao buscar dashboard:', dashError);
    } else {
      console.log('\nResumo do Dashboard:', dashboard);
    }

  } catch (error) {
    console.error('Erro geral:', error);
  }
}

testConnection();
