# 🏠 Backup Local do Usuário - PWA

## 🎯 Conceito

Cada cliente que usa o PDV pode configurar backup automático **no próprio computador**, salvando **apenas os dados da sua empresa**.

---

## 🔄 Como Funciona

### 1️⃣ **Backup do Servidor (Você - Administrador do Sistema)**
```
┌─────────────────────────────────────┐
│  SEU COMPUTADOR (Servidor)          │
│                                      │
│  ✅ Backup GERAL (3h)               │
│     → Todas as 13 tabelas           │
│     → Todas as 6 empresas           │
│     → Total: 1.265 registros        │
│                                      │
│  ✅ Backup POR EMPRESA (4h)         │
│     → Cada empresa em pasta isolada │
│     → Útil para restauração         │
└─────────────────────────────────────┘
         ↓
   USA SERVICE_ROLE_KEY
   (Acesso total ao banco)
```

### 2️⃣ **Backup do Cliente (Cada Usuário do PWA)**
```
┌─────────────────────────────────────┐
│  COMPUTADOR DO CLIENTE              │
│  (Empresa: Allimport)                │
│                                      │
│  ✅ Backup LOCAL (2h)               │
│     → Apenas dados da Allimport     │
│     → 819 produtos                  │
│     → 149 clientes                  │
│     → 7 vendas                      │
│     → etc.                          │
│                                      │
│  📁 Salvo em:                       │
│     Documentos/Backup-Allimport/    │
└─────────────────────────────────────┘
         ↓
   USA ACCESS_TOKEN do usuário
   (RLS filtra automaticamente)
```

---

## 📦 Fluxo Completo

### Passo 1: Cliente Acessa o PWA

```tsx
// No Dashboard do cliente
<BackupAutomaticoDownload />
```

Cliente vê botão: **"Baixar Instalador de Backup"**

### Passo 2: Sistema Gera Instalador Personalizado

Quando cliente clica, o sistema:

1. ✅ Pega `user_id` do cliente logado
2. ✅ Pega `access_token` da sessão atual
3. ✅ Pega nome da empresa
4. ✅ Gera 3 arquivos:
   - `backup.py` - Script Python com credenciais do cliente
   - `instalar-mac.sh` - Instalador para macOS
   - `instalar-windows.bat` - Instalador para Windows
5. ✅ Cria ZIP e faz download

### Passo 3: Cliente Instala

**macOS:**
```bash
bash instalar-mac.sh
```

**Windows:**
```cmd
instalar-windows.bat (Executar como administrador)
```

### Passo 4: Backup Roda Automaticamente

```
Todo dia às 2h da manhã:
┌──────────────────────────────────┐
│ 1. Script Python acorda          │
│ 2. Conecta no Supabase           │
│ 3. Busca TODAS as tabelas        │
│ 4. RLS filtra automaticamente    │
│    (só retorna dados do user_id) │
│ 5. Salva JSON localmente         │
└──────────────────────────────────┘
```

---

## 🔒 Segurança

### RLS (Row Level Security) Automático

```sql
-- Política RLS na tabela produtos
CREATE POLICY "users_own_products" ON produtos
FOR SELECT USING (user_id = auth.uid());
```

Quando cliente faz:
```python
# Cliente: Allimport (user_id = f7fdf4cf)
url = f"{SUPABASE_URL}/rest/v1/produtos?select=*"
requests.get(url, headers={"Authorization": f"Bearer {access_token}"})
```

**RLS garante que retorna APENAS:**
- Produtos onde `user_id = f7fdf4cf` ✅
- **NUNCA** retorna produtos de outras empresas ❌

---

## 📊 Comparação

| Aspecto | Backup Servidor | Backup Cliente |
|---------|----------------|----------------|
| **Onde roda** | Seu computador | Computador do cliente |
| **O que salva** | TODAS as empresas | APENAS a empresa dele |
| **Credencial** | SERVICE_ROLE_KEY | ACCESS_TOKEN do usuário |
| **Horário** | 3h e 4h | 2h |
| **Instalação** | Você instala 1 vez | Cada cliente instala o seu |
| **Segurança** | Acesso total (admin) | RLS filtra automaticamente |
| **Uso** | Administração do sistema | Cliente fazer backup próprio |

---

## 💡 Exemplos Práticos

### Cenário 1: Cliente Allimport quer backup

1. Acessa PWA → Dashboard
2. Clica em "Baixar Instalador de Backup"
3. Baixa ZIP: `Backup-Automatico-Allimport.zip`
4. Extrai e roda `instalar-mac.sh`
5. Pronto! Todo dia às 2h faz backup automático
6. Backups salvos em: `~/Documents/Backup-Allimport/`

**O que é salvo:**
```
Backup-Allimport/
├── produtos_20260118_020000.json      (819 produtos)
├── clientes_20260118_020000.json      (149 clientes)
├── vendas_20260118_020000.json        (7 vendas)
├── vendas_itens_20260118_020000.json  (8 itens)
├── categorias_20260118_020000.json    (70 categorias)
└── ... (outras tabelas)
```

### Cenário 2: Cliente Cristiane Ramos quer backup

1. Acessa PWA → Dashboard
2. Clica em "Baixar Instalador de Backup"
3. Baixa ZIP: `Backup-Automatico-Cristiane-Ramos.zip`
4. Instala no computador dela
5. Todo dia às 2h faz backup automático
6. Backups salvos em: `~/Documents/Backup-Cristiane-Ramos/`

**O que é salvo (apenas dela):**
```
Backup-Cristiane-Ramos/
├── produtos_20260118_020000.json      (2 produtos)
├── clientes_20260118_020000.json      (1 cliente)
├── vendas_20260118_020000.json        (1 venda)
└── ... (outras tabelas)
```

**NÃO salva produtos da Allimport!** RLS bloqueia automaticamente ✅

---

## 🚀 Implementação no PWA

### 1. Adicionar Componente no Dashboard

```tsx
// src/modules/dashboard/Dashboard.tsx
import { BackupAutomaticoDownload } from '@/components/BackupAutomaticoDownload';

export function Dashboard() {
  return (
    <div className="space-y-6">
      {/* ... outros componentes ... */}
      
      <BackupAutomaticoDownload />
    </div>
  );
}
```

### 2. Instalar Dependência (JSZip)

```bash
npm install jszip
```

### 3. Atualizar Componente para Gerar ZIP Real

```tsx
import JSZip from 'jszip';

async function criarZip(arquivos) {
  const zip = new JSZip();
  
  for (const [nome, conteudo] of Object.entries(arquivos)) {
    zip.file(nome, conteudo);
  }
  
  return await zip.generateAsync({ type: 'blob' });
}
```

---

## 📋 Checklist de Implementação

- [ ] Instalar JSZip: `npm install jszip`
- [ ] Adicionar componente `BackupAutomaticoDownload.tsx`
- [ ] Importar componente no Dashboard
- [ ] Testar geração de instalador
- [ ] Testar instalação no macOS
- [ ] Testar instalação no Windows
- [ ] Documentar para clientes

---

## 🆘 Troubleshooting

### Problema: Token expirado

**Solução:** Cliente precisa fazer login novamente e baixar novo instalador

### Problema: Backup não roda automaticamente

**macOS:**
```bash
# Verificar se serviço está carregado
launchctl list | grep pdv.backup

# Testar manualmente
python3 ~/Documents/PDV-Backup-[Empresa]/backup.py
```

**Windows:**
```cmd
# Ver tarefas agendadas
schtasks /query | findstr "PDV Backup"
```

---

## ✅ Vantagens

1. ✅ **Segurança**: Dados ficam no computador do cliente
2. ✅ **Privacidade**: RLS garante isolamento total
3. ✅ **Automático**: Roda todo dia sem intervenção
4. ✅ **Simples**: Cliente baixa e instala em 2 cliques
5. ✅ **Personalizado**: Cada instalador é único para cada empresa

---

## 🎯 Resumo

- **Você (Admin)**: Backup de TODAS as empresas no seu servidor
- **Cliente**: Backup apenas da empresa dele no computador dele
- **Segurança**: RLS garante isolamento automático
- **Instalação**: Cliente baixa ZIP personalizado e instala
- **Horário**: 2h da manhã (cliente) vs 3h/4h (servidor)

**Resultado:** Sistema completo de backup multi-nível! 🚀
