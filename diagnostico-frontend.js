// Código para fechar caixas abertos via fetch (funciona no console)
console.log('🔄 Fechando caixas abertos...');

fetch('https://kmcaaqetxtwkdcczdomw.supabase.co/rest/v1/caixa?status=eq.aberto', {
  method: 'PATCH',
  headers: {
    'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg',
    'Content-Type': 'application/json',
    'Prefer': 'return=minimal'
  },
  body: JSON.stringify({
    status: 'fechado',
    data_fechamento: new Date().toISOString(),
    valor_final: 100
  })
})
.then(response => {
  console.log('Status da resposta:', response.status);
  if (response.ok) {
    console.log('✅ Caixas fechados com sucesso!');
    alert('Caixas fechados! Agora você pode abrir um novo caixa.');
  } else {
    console.log('❌ Erro ao fechar caixas');
  }
  return response.text();
})
.then(data => {
  console.log('Resposta do servidor:', data);
})
.catch(error => {
  console.error('❌ Erro:', error);
});

// =====================================================
// ALTERNATIVA: Se conseguir acessar o Supabase do React
// =====================================================
// 
// Para usar dentro do React (se window.supabase estiver disponível):
// 
// if (typeof window !== 'undefined' && window.supabase) {
//   window.supabase.from('caixa')
//     .update({ 
//       status: 'fechado', 
//       data_fechamento: new Date().toISOString(),
//       valor_final: 100
//     })
//     .eq('status', 'aberto')
//     .then(result => {
//       console.log('✅ Caixas fechados:', result);
//       alert('Caixas fechados! Agora você pode abrir um novo.');
//     });
// } else {
//   console.log('⚠️ Supabase não encontrado, usando fetch...');
//   // Use o código fetch acima
// }