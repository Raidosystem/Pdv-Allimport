#!/usr/bin/env node

// Script para corrigir variáveis VITE_ no lado servidor
import fs from 'fs';
import path from 'path';
import { glob } from 'glob';

console.log('🔧 Iniciando correção de variáveis VITE_ no servidor...\n');

// Padrões a corrigir
const replacements = [
  // MercadoPago
  {
    from: /process\.env\.VITE_MP_ACCESS_TOKEN/g,
    to: 'process.env.MP_ACCESS_TOKEN',
    description: 'MP Access Token'
  },
  {
    from: /process\.env\.VITE_MP_PUBLIC_KEY/g,
    to: 'process.env.MP_PUBLIC_KEY',
    description: 'MP Public Key'
  },
  // Supabase URLs
  {
    from: /process\.env\.SUPABASE_URL \|\| process\.env\.VITE_SUPABASE_URL/g,
    to: 'process.env.SUPABASE_URL',
    description: 'Supabase URL (remover fallback VITE_)'
  },
  {
    from: /process\.env\.VITE_SUPABASE_URL/g,
    to: 'process.env.SUPABASE_URL',
    description: 'Supabase URL'
  },
  // Supabase Keys
  {
    from: /process\.env\.VITE_SUPABASE_SERVICE_ROLE_KEY/g,
    to: 'process.env.SUPABASE_SERVICE_ROLE_KEY',
    description: 'Supabase Service Role Key'
  },
  {
    from: /process\.env\.VITE_SUPABASE_ANON_KEY/g,
    to: 'process.env.SUPABASE_ANON_KEY',
    description: 'Supabase Anon Key'
  },
  // Fallbacks complexos
  {
    from: /process\.env\.MP_ACCESS_TOKEN \|\| process\.env\.VITE_MP_ACCESS_TOKEN/g,
    to: 'process.env.MP_ACCESS_TOKEN',
    description: 'MP Access Token (remover fallback VITE_)'
  },
  {
    from: /process\.env\.SUPABASE_SERVICE_ROLE_KEY \|\| process\.env\.VITE_SUPABASE_SERVICE_ROLE_KEY/g,
    to: 'process.env.SUPABASE_SERVICE_ROLE_KEY',
    description: 'Supabase Service Key (remover fallback VITE_)'
  }
];

// Buscar arquivos no diretório api/
const apiFiles = glob.sync('api/**/*.{js,ts}', {
  ignore: ['api/node_modules/**', 'api/_security/**']
});

let totalFiles = 0;
let totalReplacements = 0;

apiFiles.forEach(filePath => {
  const fullPath = path.resolve(filePath);
  
  try {
    let content = fs.readFileSync(fullPath, 'utf8');
    let modified = false;
    let fileReplacements = 0;

    replacements.forEach(({ from, to, description }) => {
      const matches = content.match(from);
      if (matches) {
        content = content.replace(from, to);
        fileReplacements += matches.length;
        modified = true;
        console.log(`  ✅ ${description}: ${matches.length} substituições`);
      }
    });

    if (modified) {
      fs.writeFileSync(fullPath, content, 'utf8');
      console.log(`📝 ${filePath} - ${fileReplacements} correções aplicadas`);
      totalFiles++;
      totalReplacements += fileReplacements;
    }
  } catch (error) {
    console.error(`❌ Erro ao processar ${filePath}:`, error.message);
  }
});

console.log(`\n🎯 RESUMO:`);
console.log(`  📁 Arquivos corrigidos: ${totalFiles}`);
console.log(`  🔧 Total de substituições: ${totalReplacements}`);
console.log(`\n✅ Correção concluída! Agora todas as APIs usam variáveis de servidor corretas.`);

if (totalReplacements > 0) {
  console.log(`\n⚠️  IMPORTANTE: Configure as seguintes variáveis no Vercel:`);
  console.log(`  - SUPABASE_URL`);
  console.log(`  - SUPABASE_SERVICE_ROLE_KEY`);
  console.log(`  - SUPABASE_ANON_KEY`);
  console.log(`  - MP_ACCESS_TOKEN`);
  console.log(`  - MP_PUBLIC_KEY`);
}