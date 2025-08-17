const fs = require('fs');
const path = require('path');

// Criar diretório icons se não existir
const iconsDir = path.join(__dirname, 'public', 'icons');
if (!fs.existsSync(iconsDir)) {
  fs.mkdirSync(iconsDir, { recursive: true });
}

// Função para criar SVG
function createIconSVG(size) {
  return `<svg width="${size}" height="${size}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#3b82f6;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#1d4ed8;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="${size}" height="${size}" rx="${size * 0.15}" fill="url(#grad)"/>
  <circle cx="${size/2}" cy="${size/2}" r="${size*0.35}" fill="rgba(255,255,255,0.2)"/>
  <text x="${size/2}" y="${size/2}" text-anchor="middle" dominant-baseline="middle" 
        fill="white" font-size="${size*0.22}" font-weight="bold" 
        font-family="-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,sans-serif">PDV</text>
</svg>`;
}

// Tamanhos necessários para PWA
const sizes = [72, 96, 128, 144, 152, 192, 256, 384, 512];

// Criar ícones SVG
sizes.forEach(size => {
  const svg = createIconSVG(size);
  const filename = path.join(iconsDir, `icon-${size}x${size}.svg`);
  fs.writeFileSync(filename, svg);
  console.log(`✅ Criado: ${filename}`);
});

// Criar favicon também
const faviconSvg = createIconSVG(32);
fs.writeFileSync(path.join(iconsDir, 'favicon.svg'), faviconSvg);
console.log('✅ Criado: favicon.svg');

console.log('🎉 Todos os ícones SVG foram criados!');
console.log('📁 Localização:', path.resolve(iconsDir));
