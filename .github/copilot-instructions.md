<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Instruções para o Sistema PDV Allimport

**🌐 IDIOMA**: Sempre responda e converse em **português brasileiro (pt-BR)**. Todo código, comentários e documentação devem estar em português.

Sistema de **Ponto de Venda (PDV)** Progressive Web App com arquitetura multi-tenant, desenvolvido com React 19 + TypeScript + Supabase.

## 🏗️ Arquitetura do Sistema

### Multi-Tenancy & Isolamento de Dados
Este é um sistema **multi-tenant** com isolamento completo por empresa:
- **Tabelas principais**: `clientes`, `produtos`, `vendas`, `vendas_itens`, `caixa`, `ordens_servico`
- **Chaves de isolamento**: Todas as tabelas possuem `user_id` e/ou `empresa_id` (UUID)
- **RLS (Row Level Security)**: Políticas Supabase garantem acesso apenas aos dados do usuário/empresa
- **Exemplo de política RLS**:
  ```sql
  CREATE POLICY "users_own_data" ON produtos
  FOR ALL USING (user_id = auth.uid());
  ```

### Backend Supabase
- **Client**: Configurado em `src/lib/supabase.ts` com PKCE flow
- **Autenticação**: `AuthContext` em `src/modules/auth/AuthContext.tsx` gerencia sessão
- **Real-time**: Configurado em `supabase.ts` com limite de 10 eventos/segundo
- **Migrations**: Scripts SQL na raiz do projeto (numerados sequencialmente)
- **⚠️ CRÍTICO**: Ao criar novas queries, SEMPRE considere RLS - use `.from('tabela')` sem `.eq('user_id')` pois RLS já filtra

### Estrutura de Módulos
```
src/
├── modules/           # Módulos funcionais isolados
│   ├── auth/          # AuthContext, LoginPage, SignupPage, ProtectedRoute
│   ├── sales/         # SalesPage, componentes de venda
│   ├── clientes/      # Gestão de clientes
│   ├── products/      # Gestão de produtos
│   ├── dashboard/     # Dashboard principal
│   └── admin/         # Painel administrativo
├── components/        # Componentes reutilizáveis (Button, Card, Modal)
├── services/          # Lógica de negócio e APIs Supabase
├── hooks/             # Custom hooks (useCaixa, useSales, usePermissions)
├── contexts/          # Contextos React adicionais
├── types/             # Tipos TypeScript (sales.ts, cliente.ts)
├── utils/             # Utilitários (format.ts, validation.ts)
└── lib/               # Configurações (supabase.ts)
```

## 🔧 Desenvolvimento Local

### Comandos Principais
```bash
npm run dev          # Desenvolvimento local (porta 5174)
npm run build        # Build de produção (executa update-version.js)
npm run preview      # Preview do build (porta 4173)
npm run lint         # ESLint
npm run type-check   # Verificação TypeScript
```

### Scripts de Banco de Dados
- **Executar SQL no Supabase**: Use o SQL Editor do dashboard do Supabase
- **Migrations**: Arquivos `.sql` na raiz (ex: `RLS_MANUAL_SUPABASE.sql`)
- **Scripts Node**: `scripts/` contém utilitários (ex: `create-test-user.mjs`)
- **⚠️ Ordem de execução**: Sempre verifique `EXECUTAR_PRIMEIRO.md` antes de rodar SQLs
- **🚨 VERIFICAR ESTRUTURA EXISTENTE**: Antes de criar/alterar tabelas, SEMPRE verifique a estrutura atual com `VERIFICAR_ESTRUTURA_TABELAS.sql` ou queries `SELECT * FROM information_schema.columns WHERE table_name = 'nome_tabela'` para não quebrar tabelas prontas

### Variáveis de Ambiente
```env
VITE_SUPABASE_URL=https://[project-ref].supabase.co
VITE_SUPABASE_ANON_KEY=[anon-key]
VITE_ADMIN_EMAILS=email1@example.com,email2@example.com
```

## 📝 Padrões de Código

### Componentes & Hooks
- **Componentes funcionais** com TypeScript
- **Hooks personalizados** para lógica compartilhada (ex: `useCaixa`, `useSales`)
- **Context API** para estado global (AuthContext via `src/modules/auth`)
- **React Query** para cache e sincronização servidor (TanStack Query)

### Tipagem TypeScript
- **Tipos centralizados**: `src/types/` (ex: `sales.ts` define Product, Customer, Sale)
- **Tipos Supabase**: Gerados automaticamente em `src/types/supabase.ts`
- **Evite `any`**: Use tipos estritos sempre que possível
- **Exemplo de tipo**:
  ```typescript
  export interface Product {
    id: string
    name: string
    price: number
    stock_quantity: number
    user_id: string // Chave de isolamento
  }
  ```

### Services & APIs
- **Padrão service**: `src/services/[entidade]Service.ts` (ex: `clienteService.ts`)
- **Funções CRUD**: `create`, `update`, `delete`, `getAll`, `getById`
- **Sempre use try/catch**: Tratamento de erros em todas as chamadas Supabase
- **Exemplo de service**:
  ```typescript
  export async function getClientes() {
    const { data, error } = await supabase
      .from('clientes')
      .select('*') // RLS filtra automaticamente
      .order('nome')
    
    if (error) throw error
    return data
  }
  ```

### Validação de Formulários
- **React Hook Form** + **Zod** para validação
- **Schemas Zod**: Definir em `src/schemas/` ou inline no componente
- **Exemplo**:
  ```typescript
  const schema = z.object({
    nome: z.string().min(3, 'Mínimo 3 caracteres'),
    email: z.string().email('Email inválido').optional(),
    cpf_cnpj: z.string().optional()
  })
  ```

## 🚨 Pontos de Atenção CRÍTICOS

### Row Level Security (RLS)
- **NUNCA desabilite RLS em produção** sem análise de segurança
- **Teste políticas RLS**: Use o SQL Editor do Supabase para testar
- **Debug RLS**: Se dados sumirem, verifique políticas em `pg_policies`
- **Scripts de diagnóstico**: Veja `DIAGNOSTICO_RLS_COMPLETO.sql`

### Sistema de Permissões
- **Tabelas**: `user_approvals`, `funcoes`, `permissoes`, `funcao_permissoes`
- **Hook**: `usePermissions()` em `src/hooks/usePermissions.tsx`
- **Verificação**: `checkPermission(module, action)` antes de operações sensíveis
- **Admin Empresa**: Usuários que compram o sistema são admins de sua empresa
- **🚨 SUPER ADMIN**: Apenas `novaradiosystem@outlook.com` pode acessar o painel administrativo do sistema (`AdminDashboard`). Qualquer outro email deve receber mensagem de "Acesso Negado"

### Autenticação
- **Fluxo PKCE**: Configurado em `supabase.ts` para segurança
- **Sessão persistente**: localStorage (`supabase.auth.token`)
- **Auto-refresh**: Token atualizado automaticamente
- **Protected Routes**: Use `<ProtectedRoute>` do `src/modules/auth`

### PWA (Progressive Web App)
- **Manifest**: `public/manifest.json` (nome, ícones, tema)
- **Service Worker**: `public/sw.js` (cache offline)
- **Instalação**: Botão de instalação renderizado no canto inferior esquerdo
- **Offline-first**: Funcionalidades principais devem funcionar offline

## 🔍 Debugging & Troubleshooting

### ⚠️ PROTOCOLO DE DIAGNÓSTICO
**SEMPRE que houver erros no sistema:**
1. **Verificar o caminho completo do arquivo** mencionado no erro
2. **Confirmar o nome exato** da função/componente/variável no código
3. **Buscar no workspace** usando `grep_search` ou `semantic_search` antes de dar diagnóstico
4. **Ler o código real** com `read_file` para confirmar a implementação atual
5. **Não assumir** - sempre validar com ferramentas de busca

### Erros Comuns
1. **403 Forbidden**: Problema de RLS - verificar políticas no Supabase
2. **400 Bad Request**: Dados inválidos - verificar schema Zod
3. **Dados sumiram**: RLS bloqueando acesso - usar service_role_key para debug
4. **Permissões negadas**: Verificar `user_approvals` e `funcao_permissoes`
5. **Function not found**: Verificar se função RPC existe no Supabase e se extensões estão habilitadas

### Scripts de Diagnóstico
- `DIAGNOSTICO_COMPLETO_SISTEMA.sql` - Visão geral do banco
- `DIAGNOSTICO_RLS_COMPLETO.sql` - Status de RLS e políticas
- `debug-produtos-forcado.js` - Debug de produtos via Node.js
- `verificar-estrutura-tabelas.sql` - Validar estrutura do banco

### Logs & Monitoramento
- **Console do navegador**: Erros de frontend
- **Supabase Logs**: Dashboard > Logs & Reports
- **Network tab**: Verificar requisições falhando

## 📱 PWA & Deploy

### Build & Deploy
```bash
npm run build        # Build para produção
npm run preview      # Testar build localmente
```

### Deploy Vercel (configurado)
- **Domínio principal**: `pdv.gruporaval.com.br`
- **Backups**: `pdv-producao.surge.sh`, `pdv-final.surge.sh`
- **Variáveis de ambiente**: Configurar no dashboard Vercel

### Atualização de Versão
- **Automático**: `npm run build` executa `scripts/update-version.js`
- **Manual**: Editar `package.json` e rebuild

## 🎨 UI/UX

### Design System
- **Cores primárias**: Blue (`#3b82f6`) para ações principais
- **Componentes base**: `src/components/ui/` (Button, Card, Input, Modal)
- **TailwindCSS**: Classes utilitárias + `tailwind.config.js` customizado
- **Responsividade**: Mobile-first, testado em tablets e desktops

### Feedback Visual
- **Toast**: `react-hot-toast` para notificações
- **Loading**: Estados de loading em todas as operações assíncronas
- **Confirmações**: Modais para ações destrutivas (delete, finalizar venda)

## 🔐 Segurança

### Boas Práticas
- **Nunca commitar** `.env` ou credenciais
- **Validar dados** no frontend E backend (Supabase RLS + constraints)
- **Sanitizar inputs** para prevenir XSS
- **Rate limiting**: Configurado no Supabase por padrão

### Multi-Tenancy
- **Isolamento garantido** por RLS - cada usuário vê apenas seus dados
- **Triggers**: Alguns triggers preenchem `user_id` automaticamente
- **Empresa compartilhada**: Funcionários da mesma empresa podem compartilhar dados via `empresa_id`

Sempre priorize **segurança**, **performance** e **experiência do usuário** ao desenvolver funcionalidades.
