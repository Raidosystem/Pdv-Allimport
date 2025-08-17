// Vamos criar os ícones automaticamente usando Canvas
// Este script JavaScript cria os ícones necessários para o PWA

console.log('🎨 Criando ícones para PWA...');

// Função para criar um ícone com Canvas
function createIcon(size, text = 'PDV', bgColor = '#3b82f6', textColor = '#ffffff') {
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  
  canvas.width = size;
  canvas.height = size;
  
  // Fundo
  ctx.fillStyle = bgColor;
  ctx.fillRect(0, 0, size, size);
  
  // Adicionar gradiente
  const gradient = ctx.createLinearGradient(0, 0, size, size);
  gradient.addColorStop(0, bgColor);
  gradient.addColorStop(1, '#1d4ed8');
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, size, size);
  
  // Borda arredondada (efeito de ícone moderno)
  ctx.globalCompositeOperation = 'destination-in';
  ctx.beginPath();
  const radius = size * 0.2; // 20% do tamanho como raio
  ctx.roundRect(0, 0, size, size, radius);
  ctx.fill();
  
  ctx.globalCompositeOperation = 'source-over';
  
  // Texto
  ctx.fillStyle = textColor;
  ctx.font = `bold ${size * 0.25}px Arial, sans-serif`;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  
  // Sombra no texto
  ctx.shadowColor = 'rgba(0,0,0,0.3)';
  ctx.shadowBlur = 2;
  ctx.shadowOffsetY = 1;
  
  ctx.fillText(text, size / 2, size / 2);
  
  return canvas;
}

// Função para download do ícone
function downloadIcon(canvas, filename) {
  canvas.toBlob((blob) => {
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }, 'image/png');
}

// Criar todos os ícones necessários
const iconSizes = [72, 96, 128, 144, 152, 192, 256, 384, 512];

iconSizes.forEach(size => {
  const canvas = createIcon(size);
  downloadIcon(canvas, `icon-${size}x${size}.png`);
});

// Criar favicon também
const favicon = createIcon(32, 'P');
downloadIcon(favicon, 'favicon.png');

console.log('✅ Todos os ícones foram criados! Salve-os na pasta public/icons/');
