# 📱 PDV Allimport - PWA & Funcionalidade Offline

## 🚀 **Características PWA Implementadas**

### ✅ **Instalação em Qualquer Dispositivo**
- **Windows**: Instalar via Chrome/Edge → Menu → "Instalar PDV Allimport"
- **macOS**: Instalar via Safari/Chrome → Menu → "Adicionar à Dock"
- **Linux**: Instalar via Chrome/Firefox → Menu → "Instalar aplicativo"
- **Mobile**: Adicionar à tela inicial

### 🔄 **Funcionalidade Offline Completa**

#### **O que funciona sem internet:**
- ✅ Realizar vendas normalmente
- ✅ Consultar produtos em estoque
- ✅ Visualizar clientes cadastrados
- ✅ Imprimir recibos de venda
- ✅ Acessar relatórios locais
- ✅ Gerenciar caixa do dia
- ✅ Todas as operações do PDV

#### **Sincronização Automática:**
- 🔄 Quando a internet volta, todos os dados são sincronizados automaticamente
- 📝 Fila de sincronização para operações pendentes
- ⚡ Background sync para melhor performance
- 🔔 Notificações de status de sincronização

## 🛠️ **Arquivos Implementados**

### **1. Manifest PWA** (`/public/manifest.json`)
```json
{
  "name": "PDV Allimport - Sistema de Ponto de Venda",
  "short_name": "PDV Allimport",
  "display": "standalone",
  "start_url": "/",
  "background_color": "#ffffff",
  "theme_color": "#3b82f6"
}
```

### **2. Service Worker** (`/public/sw.js`)
- **Cache Strategy**: Network First com fallback para cache
- **Offline Data**: Armazenamento local com IndexedDB
- **Sync Queue**: Fila de sincronização para operações pendentes
- **Background Sync**: Sincronização automática quando conexão volta

### **3. Hook de Sincronização** (`/src/hooks/useOfflineSync.ts`)
```typescript
const { 
  isOnline, 
  syncStatus, 
  saveOfflineData, 
  addToSyncQueue, 
  installPWA 
} = useOfflineSync()
```

### **4. Componente Offline** (`/src/components/OfflineIndicator.tsx`)
- **Status Visual**: Indicador de conexão online/offline
- **Prompt de Instalação**: Modal automático para instalar PWA
- **Sincronização Manual**: Botão para tentar sincronizar
- **Contador de Pendências**: Mostra itens aguardando sincronização

### **5. Página Offline** (`/public/offline.html`)
- Página personalizada exibida quando offline
- Lista de funcionalidades disponíveis
- Status de conexão em tempo real

## 📊 **Fluxo de Dados Offline**

### **1. Modo Online (Normal)**
```
Usuário → Interface → API Supabase → Banco de Dados
```

### **2. Modo Offline**
```
Usuário → Interface → localStorage → Fila de Sincronização
```

### **3. Volta da Conexão**
```
Service Worker → Processa Fila → Supabase → Atualiza Local
```

## 🎯 **Estados de Sincronização**

| Estado | Descrição | Ação |
|--------|-----------|------|
| 🌐 **Online** | Conectado, sincronizado | Operação normal |
| 📴 **Offline** | Sem conexão, salvando localmente | Adicionar à fila |
| 🔄 **Sincronizando** | Processando fila de operações | Aguardar |
| ⏳ **Pendente** | X itens aguardando sincronização | Tentar novamente |
| ✅ **Sincronizado** | Todos os dados atualizados | Limpar fila |

## 💾 **Armazenamento Local**

### **localStorage Keys:**
- `pdv-offline-data`: Dados principais (vendas, produtos, clientes)
- `pdv-sync-queue`: Fila de operações pendentes
- `pdv-last-save`: Timestamp da última gravação
- `pdv-install-prompted`: Flag de prompt de instalação mostrado

### **Limpeza Automática:**
- Dados offline são removidos após 7 dias sem uso
- Fila de sincronização é limpa após sucesso
- Cache do Service Worker é atualizado automaticamente

## 🔧 **Como Usar**

### **1. Instalação:**
```bash
# O sistema automaticamente solicita instalação após 30 segundos
# Ou usar o botão de download fixo no canto inferior esquerdo
```

### **2. Funcionamento Offline:**
```bash
# Todas as operações funcionam normalmente
# Sistema salva automaticamente no localStorage
# Quando internet volta, sincroniza tudo automaticamente
```

### **3. Monitoramento:**
```bash
# Indicador visual no topo esquerdo mostra status
# Card de detalhes aparece quando offline
# Notificações informam sobre sincronização
```

## 🎨 **Interface de Status**

### **Indicadores Visuais:**
- 🌐 **Verde**: Online e sincronizado
- 📴 **Vermelho**: Offline, salvando localmente
- 🔄 **Azul**: Sincronizando dados
- ⏳ **Amarelo**: Pendências aguardando sincronização

### **Notificações:**
- ✅ "Conexão restaurada! Sincronizando dados..."
- 📴 "Sem conexão. Modo offline ativado."
- 🔄 "X operações sincronizadas!"
- ⏳ "X itens aguardando sincronização"

## 🚀 **Benefícios**

### **Para o Usuário:**
- ✅ PDV funciona sempre, com ou sem internet
- ✅ Não perde vendas por problemas de conexão
- ✅ Interface igual a um app nativo
- ✅ Instalação fácil em qualquer dispositivo

### **Para o Negócio:**
- ✅ Zero downtime por problemas de rede
- ✅ Sincronização automática e transparente
- ✅ Dados sempre seguros e atualizados
- ✅ Experiência profissional e confiável

## 📱 **Compatibilidade**

- ✅ **Windows 10/11**: Chrome, Edge, Firefox
- ✅ **macOS**: Safari, Chrome, Firefox
- ✅ **Linux**: Chrome, Firefox
- ✅ **Android**: Chrome, Samsung Internet
- ✅ **iOS**: Safari, Chrome (limitado)

O **PDV Allimport** agora é um verdadeiro **aplicativo offline-first** que garante funcionamento contínuo independente da conexão de internet! 🎉
