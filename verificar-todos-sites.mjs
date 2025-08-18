import https from 'https';

const sites = [
  {
    name: 'GitHub Pages',
    url: 'https://raidosystem.github.io/Pdv-Allimport/',
    hostname: 'raidosystem.github.io',
    path: '/Pdv-Allimport/'
  },
  {
    name: 'Vercel (Principal)',
    url: 'https://pdv.crmvsystem.com/',
    hostname: 'pdv.crmvsystem.com',
    path: '/'
  },
  {
    name: 'Surge.sh (Backup)',
    url: 'https://pdv-producao.surge.sh/',
    hostname: 'pdv-producao.surge.sh',
    path: '/'
  }
];

console.log('🔍 Verificando status de todos os deploys...\n');

sites.forEach((site, index) => {
  setTimeout(() => {
    const options = {
      hostname: site.hostname,
      path: site.path,
      method: 'HEAD',
      timeout: 10000
    };

    const req = https.request(options, (res) => {
      const status = res.statusCode === 200 ? '✅ ONLINE' : `⚠️  Status: ${res.statusCode}`;
      console.log(`${status} - ${site.name}`);
      console.log(`   URL: ${site.url}`);
      console.log('');
    });

    req.on('error', (err) => {
      console.log(`❌ OFFLINE - ${site.name}`);
      console.log(`   URL: ${site.url}`);
      console.log(`   Erro: ${err.message}`);
      console.log('');
    });

    req.on('timeout', () => {
      console.log(`⏰ TIMEOUT - ${site.name}`);
      console.log(`   URL: ${site.url}`);
      console.log('');
      req.destroy();
    });

    req.end();
  }, index * 1000);
});

setTimeout(() => {
  console.log('📊 Verificação concluída!');
}, sites.length * 1000 + 2000);
