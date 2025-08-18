import https from 'https';

const testUrls = [
  'https://raidosystem.github.io/Pdv-Allimport/',
  'https://raidosystem.github.io/Pdv-Allimport/manifest.json'
];

console.log('🔍 Testando MIME types dos assets do GitHub Pages...\n');

testUrls.forEach((url, index) => {
  setTimeout(() => {
    const parsedUrl = new URL(url);
    const options = {
      hostname: parsedUrl.hostname,
      path: parsedUrl.pathname,
      method: 'HEAD'
    };

    const req = https.request(options, (res) => {
      const contentType = res.headers['content-type'] || 'Não definido';
      console.log(`📄 ${parsedUrl.pathname}`);
      console.log(`   Status: ${res.statusCode}`);
      console.log(`   Content-Type: ${contentType}`);
      console.log('');
    });

    req.on('error', (err) => {
      console.log(`❌ Erro ao testar ${url}:`);
      console.log(`   ${err.message}`);
      console.log('');
    });

    req.end();
  }, index * 1000);
});

// Aguardar e mostrar resultado
setTimeout(() => {
  console.log('✅ Teste de MIME types concluído!');
  console.log('\n📝 Agora teste manualmente no navegador:');
  console.log('   1. Abra https://raidosystem.github.io/Pdv-Allimport/');
  console.log('   2. Abra DevTools (F12)');
  console.log('   3. Verifique o Console para erros de MIME type');
}, 3000);
