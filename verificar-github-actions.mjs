import https from 'https';

const options = {
  hostname: 'api.github.com',
  path: '/repos/Raidosystem/Pdv-Allimport/actions/runs?per_page=5',
  headers: {
    'User-Agent': 'Node.js'
  }
};

console.log('🔍 Verificando GitHub Actions...\n');

https.get(options, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    try {
      const result = JSON.parse(data);
      if (result.workflow_runs) {
        console.log('✅ GitHub Actions encontrados:');
        result.workflow_runs.slice(0, 3).forEach((run, i) => {
          console.log(`${i+1}. ${run.name}`);
          console.log(`   Status: ${run.status}`);
          console.log(`   Resultado: ${run.conclusion || 'Em andamento'}`);
          console.log(`   Data: ${new Date(run.created_at).toLocaleString('pt-BR')}`);
          console.log(`   URL: ${run.html_url}`);
          console.log('');
        });
      } else {
        console.log('❌ Erro ao acessar Actions:', result.message || 'Repositório privado');
        console.log('📝 Detalhes:', JSON.stringify(result, null, 2));
      }
    } catch (e) {
      console.log('❌ Erro ao processar resposta:', e.message);
      console.log('📝 Dados recebidos:', data.substring(0, 200) + '...');
    }
  });
}).on('error', err => {
  console.log('❌ Erro de conexão:', err.message);
});
