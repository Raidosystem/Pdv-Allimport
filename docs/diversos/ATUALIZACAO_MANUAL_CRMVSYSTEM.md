# 🚀 ATUALIZAÇÃO MANUAL - PDV CRMVSYSTEM

## 📋 Instruções para Atualizar https://pdv.crmvsystem.com/

### 🎯 **Resumo das Melhorias desta Atualização:**
- ✅ Layout de Ordem de Serviço 100% sem rolagem
- ✅ Remoção do indicador "Online" desnecessário
- ✅ Sistema de impressão multi-formato (A4/80mm/58mm) com detecção automática
- ✅ Filtros sempre visíveis na tela de OS
- ✅ Interface otimizada e mais compacta

---

## 📁 **PASSO 1: Fazer Backup do Site Atual**

1. **Acesse o servidor/hospedagem** onde está `https://pdv.crmvsystem.com/`
2. **Faça backup completo** da pasta atual do site
3. **Anote a localização** dos arquivos no servidor

---

## 📂 **PASSO 2: Baixar Arquivos Atualizados**

### Opção A: Download Direto dos Arquivos Build
1. Vá para: https://github.com/Raidosystem/Pdv-Allimport/actions
2. Clique no último workflow bem-sucedido
3. Baixe o artifact `build-files`

### Opção B: Clonar e Buildar Localmente
```bash
# Clone o repositório
git clone https://github.com/Raidosystem/Pdv-Allimport.git
cd Pdv-Allimport

# Instale dependências
npm install

# Faça o build
npm run build
```

---

## 🔄 **PASSO 3: Atualizar no Servidor**

### 3.1 Localizar Pasta `dist/`
Após o build, você terá uma pasta `dist/` com os seguintes arquivos:
```
dist/
├── index.html
├── assets/
│   ├── index-[hash].css
│   ├── index-[hash].js
│   ├── vendor-[hash].js
│   └── outros arquivos...
├── icons/
├── manifest.json
└── sw.js
```

### 3.2 Upload dos Arquivos
1. **Conecte-se ao servidor** onde está hospedado `pdv.crmvsystem.com`
2. **Navegue até a pasta raiz** do domínio
3. **Substitua TODOS os arquivos** pelos da pasta `dist/`

### 3.3 Verificações Importantes
- ✅ `index.html` foi substituído
- ✅ Pasta `assets/` foi completamente atualizada
- ✅ Arquivos `manifest.json` e `sw.js` foram atualizados
- ✅ Pasta `icons/` foi atualizada (se existir)

---

## 🌐 **PASSO 4: Testar a Atualização**

### 4.1 Limpar Cache
1. **Acesse**: https://pdv.crmvsystem.com/
2. **Pressione**: `Ctrl + F5` (força reload sem cache)
3. **Ou**: Abra em aba anônima/privada

### 4.2 Verificar Funcionalidades
- ✅ **Login funciona** normalmente
- ✅ **Ordem de Serviço** abre sem rolagem
- ✅ **Filtros sempre visíveis** na tela de OS
- ✅ **Não aparece "Online" verde** no canto superior esquerdo
- ✅ **Impressão** funciona com detecção automática de formato

---

## 🔧 **PASSO 5: Resolução de Problemas**

### Se o site não carregar:
1. **Verifique** se todos os arquivos foram transferidos
2. **Confirme** se `index.html` está na raiz correta
3. **Teste** em navegador diferente
4. **Verifique logs** do servidor

### Se aparecerem erros de JavaScript:
1. **Limpe completamente** o cache do navegador
2. **Verifique** se a pasta `assets/` foi totalmente substituída
3. **Confirme** se `manifest.json` foi atualizado

### Se o PWA não funcionar:
1. **Substitua** o arquivo `sw.js`
2. **Atualize** o `manifest.json`
3. **Teste instalação** do PWA

---

## 📱 **PASSO 6: Validação Final**

### Checklist de Validação:
- [ ] Site carrega normalmente em https://pdv.crmvsystem.com/
- [ ] Login funciona sem problemas
- [ ] Tela de Ordem de Serviço não tem rolagem
- [ ] Filtros ficam sempre visíveis
- [ ] Não aparece indicador "Online" verde
- [ ] Sistema de impressão funciona
- [ ] PWA pode ser instalado normalmente

---

## 🆘 **SUPORTE**

### Em caso de problemas:
1. **Restaure o backup** feito no Passo 1
2. **Verifique logs** do servidor
3. **Teste** em ambiente local primeiro
4. **Compare** com versões funcionais

### Arquivos críticos a verificar:
- `index.html` - Página principal
- `assets/index-[hash].js` - JavaScript principal
- `assets/index-[hash].css` - Estilos
- `manifest.json` - Configuração PWA
- `sw.js` - Service Worker

---

## ⚡ **COMANDO RÁPIDO (Se tiver acesso SSH)**

```bash
# No servidor, na pasta do domínio
cd /caminho/para/pdv.crmvsystem.com/

# Fazer backup
cp -r . ../backup-$(date +%Y%m%d-%H%M%S)

# Baixar e extrair arquivos atualizados
wget https://github.com/Raidosystem/Pdv-Allimport/archive/main.zip
unzip main.zip
cd Pdv-Allimport-main

# Build (se Node.js estiver disponível)
npm install && npm run build

# Copiar arquivos
cp -r dist/* /caminho/para/pdv.crmvsystem.com/
```

---

## 📊 **Log de Alterações desta Atualização**

### Arquivos Principais Modificados:
- `src/pages/OrdensServicoPage.tsx` - Layout otimizado sem rolagem
- `src/components/OfflineIndicator.tsx` - Removido indicador "Online"
- Função de impressão multi-formato adicionada
- Interface compacta e responsiva

### Melhorias Aplicadas:
1. **Layout 100% visível** - Ordem de serviço sem necessidade de rolagem
2. **Interface mais limpa** - Removido indicador desnecessário
3. **Impressão inteligente** - Detecta automaticamente A4, 80mm ou 58mm
4. **Filtros sempre ativos** - Melhor experiência do usuário
5. **Design compacto** - Melhor aproveitamento do espaço

---

**✅ Atualização concluída com sucesso!**
**🌐 Site atualizado em: https://pdv.crmvsystem.com/**
