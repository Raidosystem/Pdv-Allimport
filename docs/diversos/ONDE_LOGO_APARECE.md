🏢 ONDE A LOGO DA EMPRESA APARECERÁ APÓS O UPLOAD
=================================================

## 🎯 LOCAIS ONDE A LOGO SERÁ EXIBIDA:

### 1️⃣ **PÁGINA "CONFIGURAÇÕES DA EMPRESA"**
📍 **Local:** Seção "Logo da Empresa"
📝 **Descrição:** Logo aparece em uma caixa de 128x128 pixels (5x5 cm)
🎨 **Estilo:** Imagem arredondada, centralizada, com fundo transparente
✨ **Visualização:** Preview imediato após upload

```
┌─────────────────────────────────┐
│        Logo da Empresa          │
├─────────────────────────────────┤
│  ┌─────────────────────────────┐ │
│  │                             │ │
│  │       [LOGO AQUI]           │ │
│  │     (128x128 pixels)        │ │
│  │                             │ │
│  └─────────────────────────────┘ │
│                                 │
│     [Selecionar Logo] [Upload]  │
└─────────────────────────────────┘
```

### 2️⃣ **POSSÍVEIS LOCAIS FUTUROS** (para implementar):

🔹 **Header do Sistema:**
- No topo de todas as páginas
- Junto ao nome da empresa
- Tamanho pequeno (32x32 pixels)

🔹 **Recibos e Notas Fiscais:**
- No cabeçalho dos documentos
- Impressão em PDF
- Tamanho médio (64x64 pixels)

🔹 **Tela de Login:**
- Como identificação da empresa
- Logo centralizada
- Tamanho grande (256x256 pixels)

🔹 **WhatsApp e Comunicações:**
- Assinatura automática
- Pedidos enviados por WhatsApp
- Avatar da empresa

## 📋 ESPECIFICAÇÕES TÉCNICAS:

### ✅ **FORMATOS ACEITOS:**
- JPG/JPEG
- PNG (recomendado para fundos transparentes)
- WebP
- SVG (vetorial, melhor qualidade)

### 📏 **TAMANHOS RECOMENDADOS:**
- **Mínimo:** 128x128 pixels
- **Recomendado:** 512x512 pixels
- **Máximo:** 1024x1024 pixels
- **Proporção:** Quadrada (1:1) é ideal

### 💾 **ARMAZENAMENTO:**
- **Local:** Supabase Storage
- **Bucket:** 'empresas'
- **Caminho:** `{user_id}/logo.{extensao}`
- **URL:** Pública e acessível

### 🔒 **SEGURANÇA:**
- Apenas o dono da empresa pode fazer upload
- Substitui automaticamente logo anterior
- Backup automático no storage

## 🚀 COMO TESTAR:

### 1️⃣ **Fazer Upload:**
1. Vá em "Configurações da Empresa"
2. Clique em "Selecionar Logo"
3. Escolha uma imagem
4. Clique em "Upload"

### 2️⃣ **Verificar Resultado:**
- ✅ Logo aparece imediatamente na seção
- ✅ Mensagem "Logo atualizada com sucesso!"
- ✅ URL da logo salva no banco de dados

### 3️⃣ **Locais de Visualização Atual:**
- Página "Configurações da Empresa"
- Preview em tempo real
- Armazenamento permanente

## 💡 DICAS PARA MELHOR RESULTADO:

🎨 **Design:**
- Use logo com fundo transparente (PNG)
- Mantenha proporção quadrada
- Evite textos muito pequenos
- Use cores contrastantes

📐 **Tamanho:**
- 512x512 pixels é o tamanho ideal
- Arquivo menor que 2MB
- Formato PNG para transparência
- SVG para qualidade vetorial

🔧 **Implementação Futura:**
A logo ficará disponível para uso em:
- Sistema de impressão
- Comunicações automáticas
- Branding do sistema
- Documentos oficiais

=================================================
