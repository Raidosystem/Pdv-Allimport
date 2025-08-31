# 🔧 Solução para Problemas de WebSocket do Vite

## ❌ **Problema Identificado**

```
WebSocket connection to 'ws://localhost:5175/?token=bU6xoTuZKcXB' failed
WebSocket connection to 'ws://localhost:5174/?token=bU6xoTuZKcXB' failed
[vite] failed to connect to websocket
```

**Causa**: Conflito de portas entre o servidor HTTP e WebSocket do HMR (Hot Module Replacement).

## ✅ **Solução Implementada**

### 1. **Configuração Corrigida no `vite.config.ts`**
```typescript
server: {
  port: 5174,
  host: true,
  hmr: {
    port: 5174,        // ← Força mesma porta para WebSocket
    host: 'localhost'  // ← Host específico para HMR
  },
  strictPort: true,    // ← Falha se porta estiver ocupada
},
```

### 2. **Scripts Adicionados no `package.json`**
```json
{
  "dev:clean": "npm cache clean --force && vite",
  "dev:debug": "vite --debug"
}
```

### 3. **Script PowerShell para Debug**
Criado `fix-vite-websocket.ps1` para resolver conflitos.

## 🎯 **Como Usar**

### **Método 1: Comando Normal**
```bash
npm run dev
```

### **Método 2: Com Limpeza de Cache**
```bash
npm run dev:clean
```

### **Método 3: Script PowerShell (se houver conflitos)**
```powershell
.\fix-vite-websocket.ps1
```

## 🚨 **Sintomas do Problema**
- ❌ WebSocket failed errors no console
- ❌ Hot reload não funciona
- ❌ Mudanças no código não atualizam automaticamente
- ❌ Conflito entre localhost:5174 e localhost:5175

## ✅ **Indicadores de Solução**
- ✅ `VITE ready in XXXms` sem erros
- ✅ `Local: http://localhost:5174/` único
- ✅ Hot reload funcionando
- ✅ Sem erros de WebSocket no console

## 🛠️ **Comandos de Debug**

### Verificar processos Node.js
```powershell
Get-Process -Name node -ErrorAction SilentlyContinue
```

### Verificar portas em uso
```powershell
netstat -an | Select-String ":5174"
netstat -an | Select-String ":5175"
```

### Matar processos Node.js (se necessário)
```powershell
taskkill /F /IM node.exe
```

## 📚 **Referências**
- [Vite Server Options](https://vite.dev/config/server-options.html#server-hmr)
- [HMR Configuration](https://vite.dev/guide/api-hmr.html)

---

**✅ PROBLEMA RESOLVIDO**: WebSocket agora funciona corretamente na porta 5174 uniforme.
