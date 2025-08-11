import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://riqbmfqwlpuqwrfrssmh.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJpcWJtZnF3bHB1cXdyZnJzc21oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5MTk0NDYsImV4cCI6MjA1MDQ5NTQ0Nn0.eXUZUJ9HUTg51dH6CjmxzCzN-IKC6mF7zfZaEXjEWy4'

const supabase = createClient(supabaseUrl, supabaseKey)

async function addModules() {
  console.log('🔧 Adicionando módulos do sistema...')
  
  const modules = [
    {
      name: 'sales',
      display_name: 'Vendas',
      description: 'Realizar vendas e emitir cupons fiscais',
      icon: 'ShoppingCart',
      path: '/vendas'
    },
    {
      name: 'clients',
      display_name: 'Clientes',
      description: 'Gerenciar cadastro de clientes',
      icon: 'Users',
      path: '/clientes'
    },
    {
      name: 'products',
      display_name: 'Produtos',
      description: 'Controle de estoque e produtos',
      icon: 'Package',
      path: '/produtos'
    },
    {
      name: 'cashier',
      display_name: 'Caixa',
      description: 'Controle de caixa e movimento',
      icon: 'DollarSign',
      path: '/caixa'
    },
    {
      name: 'orders',
      display_name: 'OS - Ordem de Serviço',
      description: 'Gestão de ordens de serviço',
      icon: 'FileText',
      path: '/ordens-servico'
    },
    {
      name: 'reports',
      display_name: 'Relatórios',
      description: 'Análises e relatórios de vendas',
      icon: 'BarChart3',
      path: '/relatorios'
    }
  ]
  
  for (const module of modules) {
    const { data, error } = await supabase
      .from('system_modules')
      .upsert(module, { onConflict: 'name' })
      .select()
    
    if (error) {
      console.error(`❌ Erro ao adicionar módulo ${module.name}:`, error)
    } else {
      console.log(`✅ Módulo ${module.name} adicionado/atualizado`)
    }
  }
  
  // Verificar total
  const { data: allModules } = await supabase
    .from('system_modules')
    .select('*')
  
  console.log(`📊 Total de módulos: ${allModules?.length || 0}`)
}

addModules()
