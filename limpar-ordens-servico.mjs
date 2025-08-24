const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

async function limparOrdensServico() {
  console.log('🔧 VERIFICANDO E LIMPANDO ORDENS DE SERVIÇO...\n');
  
  try {
    // Verificar se há ordens de serviço
    console.log('📋 Verificando ordens de serviço...');
    const osRes = await fetch(`${supabaseUrl}/rest/v1/ordens_servico?select=*`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    
    if (!osRes.ok) {
      const error = await osRes.json();
      console.log('❌ Erro ao verificar ordens de serviço:', error.message);
      return;
    }
    
    const ordens = await osRes.json();
    
    if (Array.isArray(ordens) && ordens.length > 0) {
      console.log(`⚠️  ENCONTRADAS ${ordens.length} ORDENS DE SERVIÇO:`);
      
      ordens.forEach((ordem, index) => {
        console.log(`${index + 1}. ${ordem.cliente_nome || 'Cliente não informado'}`);
        console.log(`   📞 ${ordem.telefone || 'Telefone não informado'}`);
        console.log(`   📱 ${ordem.equipamento || 'Equipamento não informado'}`);
        console.log(`   🔧 ${ordem.defeito || 'Defeito não informado'}`);
        console.log(`   📊 Status: ${ordem.status || 'Não informado'}`);
        console.log(`   💰 Valor: R$ ${ordem.valor_orcamento || '0,00'}`);
        console.log(`   📅 Data: ${ordem.data_entrada ? new Date(ordem.data_entrada).toLocaleDateString('pt-BR') : 'Não informada'}`);
        console.log('');
      });
      
      // Limpar as ordens de serviço
      console.log('🗑️  LIMPANDO ORDENS DE SERVIÇO...');
      const deleteRes = await fetch(`${supabaseUrl}/rest/v1/ordens_servico`, {
        method: 'DELETE',
        headers: {
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({}) // Sem filtros = deletar todas (cuidado!)
      });
      
      if (deleteRes.ok) {
        console.log('✅ TODAS AS ORDENS DE SERVIÇO FORAM REMOVIDAS!');
      } else {
        const deleteError = await deleteRes.json();
        console.log('❌ Erro ao limpar ordens de serviço:', deleteError.message);
        
        // Tentar deletar uma por uma
        console.log('🔄 Tentando deletar uma por uma...');
        for (const ordem of ordens) {
          try {
            const individualDeleteRes = await fetch(`${supabaseUrl}/rest/v1/ordens_servico?id=eq.${ordem.id}`, {
              method: 'DELETE',
              headers: {
                'apikey': supabaseKey,
                'Authorization': `Bearer ${supabaseKey}`
              }
            });
            
            if (individualDeleteRes.ok) {
              console.log(`✅ OS ${ordem.id} removida`);
            } else {
              console.log(`❌ Erro ao remover OS ${ordem.id}`);
            }
          } catch (err) {
            console.log(`❌ Erro ao remover OS ${ordem.id}:`, err.message);
          }
        }
      }
      
      // Verificar novamente
      console.log('\n🔍 VERIFICAÇÃO FINAL...');
      const finalRes = await fetch(`${supabaseUrl}/rest/v1/ordens_servico?select=count`, {
        headers: {
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`,
          'Prefer': 'count=exact'
        }
      });
      
      if (finalRes.ok) {
        const count = finalRes.headers.get('content-range');
        const totalOrdens = count ? count.split('/')[1] : '0';
        console.log(`📊 Total de ordens restantes: ${totalOrdens}`);
        
        if (totalOrdens === '0') {
          console.log('🎉 SISTEMA COMPLETAMENTE LIMPO!');
          console.log('✅ Pronto para dados reais');
        } else {
          console.log(`⚠️  Ainda restam ${totalOrdens} ordens no sistema`);
        }
      }
      
    } else {
      console.log('✅ NENHUMA ORDEM DE SERVIÇO ENCONTRADA');
      console.log('Sistema já está limpo!');
    }
    
    // Verificar também clientes relacionados
    console.log('\n👤 VERIFICANDO CLIENTES...');
    const clientesRes = await fetch(`${supabaseUrl}/rest/v1/clientes?select=*`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    
    if (clientesRes.ok) {
      const clientes = await clientesRes.json();
      if (Array.isArray(clientes) && clientes.length > 0) {
        console.log(`⚠️  ENCONTRADOS ${clientes.length} CLIENTES:`);
        clientes.forEach((cliente, index) => {
          console.log(`${index + 1}. ${cliente.nome} - ${cliente.telefone || 'Sem telefone'}`);
        });
      } else {
        console.log('✅ Nenhum cliente encontrado');
      }
    }
    
  } catch (error) {
    console.error('❌ Erro geral:', error.message);
  }
}

limparOrdensServico();
