<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Instruções para o Sistema PDV Allimport

**🌐 IDIOMA**: Sempre responda e converse em **português brasileiro (pt-BR)**. Todo código, comentários e documentação devem estar em português.

Sistema de **Ponto de Venda (PDV)** Progressive Web App multi-tenant com **React 19 + TypeScript + Supabase**. Desenvolvido com Vite, TailwindCSS, React Query, React Hook Form/Zod, suportando PWA offline e real-time.

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

### Backend Supabase & Configuração
- **Client**: Configurado em `src/lib/supabase.ts` com PKCE flow, persistência de sessão, autoRefreshToken
- **Autenticação**: `AuthContext` em `src/modules/auth/AuthContext.tsx` gerencia sessão e admin roles
- **Real-time**: Configurado com limite de 10 eventos/segundo (evitar flood de eventos)
- **Migrations**: Scripts SQL na raiz do projeto (numerados sequencialmente)
- **⚠️ CRÍTICO**: Ao criar novas queries, SEMPRE considere RLS - use `.from('tabela')` sem `.eq('user_id')` pois RLS já filtra

### Estrutura de Módulos
```
src/
├── modules/                    # Módulos funcionais isolados
│   ├── auth/                   # AuthContext, ProtectedRoute, login/signup
│   ├── sales/                  # Fluxo de vendas
│   ├── clientes/               # Gestão de clientes
│   ├── products/               # Gestão de produtos
│   ├── dashboard/              # Dashboard principal
│   ├── financeiro/             # Relatórios e DRE
│   ├── loja-online/            # E-commerce integrado
│   ├── admin/                  # Painel administrativo (super-admin apenas)
│   └── landing/                # Landing page
├── components/ui/              # Componentes base (Button, Card, Input, Modal)
├── services/                   # Lógica de negócio e APIs Supabase
├── hooks/                      # Custom hooks (useCaixa, useSales, usePermissions, etc)
├── contexts/                   # Contextos React adicionais
├── types/                      # Tipos TypeScript (sales.ts, cliente.ts, supabase.ts auto-gerado)
├── utils/                      # Utilitários (format.ts, validation.ts)
├── schemas/                    # Validação Zod
├── lib/                        # Configurações (supabase.ts, etc)
└── styles/                     # Variáveis CSS e estilos globais
```

### Principais Serviços
**Pattern**: `src/services/[entidade]Service.ts` (ex: `clienteService.ts`, `caixaService.ts`)
- **ClienteService**: Busca com filtros complexos (CPF, telefone, nome), RLS automática
- **SalesService**: Fluxo completo de vendas com cálculo de descontos
- **CaixaService**: Abertura/fechamento de caixa com validações
- **SubscriptionService**: Gestão de assinaturas e planos
- **ReportsService**: Geração de relatórios com cálculos financeiros
- **EmailService/EmailServiceSupabase**: Envio de e-mails via Resend ou Supabase
- **WhatsappService**: Integração com WhatsApp para notificações
- **MercadoPagoService**: Integração com Mercado Pago

## 🔧 Desenvolvimento Local

### Comandos Principais
```bash
npm run dev          # Desenvolvimento local (porta 5174, hot reload Vite)
npm run build        # Build produção (executa update-version.js + tsc + vite build)
npm run build:prod   # Build com NODE_ENV=production
npm run preview      # Preview do build local (porta 4173)
npm run lint         # ESLint com eslint.config.js
npm run type-check   # Verificação TypeScript sem emitir código
npm run deploy       # Deploy Vercel em produção (vercel --prod)
npm run deploy:dev   # Deploy Vercel em preview
npm run update-version  # Atualiza versão em package.json (executado antes do build)
```

### Estrutura de Build
- **Bundler**: Vite com alias `@` para `src/`
- **Chunks**: Manual chunks para `vendor` (react, react-dom) e `supabase`
- **Output**: `dist/` com sourcemaps desabilitados em produção
- **Assets**: Hashing automático para cache-busting
- **PWA**: Service Worker em `public/sw.js`, manifest em `public/manifest.json`

### Scripts de Banco de Dados
- **SQL Scripts**: Arquivos `.sql` na raiz (ex: `RLS_MANUAL_SUPABASE.sql`)
- **Executar SQL**: Use o SQL Editor do dashboard Supabase ou use `supabase-cli`
- **Scripts Node**: Utilitários em `scripts/` (ex: `create-test-user.mjs`, `update-version.js`)
- **⚠️ Ordem crítica**: Sempre verificar `EXECUTAR_PRIMEIRO.md` antes de rodar SQLs
- **🚨 Validar estrutura**: Antes de criar/alterar tabelas, rodar `VERIFICAR_ESTRUTURA_TABELAS.sql`

### Variáveis de Ambiente
```env
VITE_SUPABASE_URL=https://[project-ref].supabase.co
VITE_SUPABASE_ANON_KEY=[anon-key]
VITE_ADMIN_EMAILS=email1@example.com,email2@example.com
NODE_ENV=production  # Para build:prod
```

### Deploy
- **Plataforma**: Vercel (configurado via `vercel.json`)
- **Domínios**: 
  - Principal: `pdv.gruporaval.com.br`
  - Backups: `pdv-producao.surge.sh`, `pdv-final.surge.sh`
- **GitHub Integration**: Auto-deploy em push/PR para main/dev
- **Variáveis**: Configurar em dashboard Vercel (não em `.env.local`)

## 📝 Padrões de Código

### Services & Classes
- **Padrão**: Classes estáticas em `src/services/[Entidade]Service.ts` (ex: `ClienteService`, `SalesService`)
- **Métodos**: `static async create()`, `static async update()`, `static async delete()`, `static async buscar()`, etc
- **Exemplo ClienteService**:
  ```typescript
  export class ClienteService {
    static async buscarClientes(filtros: ClienteFilters = {}) {
      let query = supabase.from('clientes').select('*')
      if (filtros.search) {
        query = query.or(`nome.ilike.%${filtros.search}%,...`)
      }
      const { data, error } = await query
      if (error) throw error
      return data
    }
  }
  ```
- **RLS automática**: Services não precisam filtrar `user_id` - RLS Supabase já filtra dados do usuário
- **Error handling**: Sempre use try/catch e lance erros para que componentes tratem

### Componentes & Hooks
- **Componentes funcionais** com TypeScript
- **Hooks personalizados** para lógica compartilhada (ex: `useCaixa`, `useSales`, `usePermissions`)
- **Context API** para estado global (`AuthContext`, `PermissionsProvider`)
- **React Query**: Usado via hooks customizados que encapsulam queries ao Supabase
- **Exemplo hook de lista**:
  ```tsx
  export function useClientes(filtros?: ClienteFilters) {
    const [clientes, setClientes] = useState<Cliente[]>([])
    const [loading, setLoading] = useState(false)
    
    useEffect(() => {
      setLoading(true)
      ClienteService.buscarClientes(filtros)
        .then(setClientes)
        .catch(err => console.error(err))
        .finally(() => setLoading(false))
    }, [filtros])
    
    return { clientes, loading }
  }
  ```

### Tipagem TypeScript
- **Tipos centralizados**: `src/types/` (ex: `sales.ts`, `cliente.ts`, `supabase.ts` auto-gerado)
- **Evitar `any`**: Tipos estritos obrigatórios
- **Chaves de isolamento**: Todo tipo deve ter `user_id` e/ou `empresa_id`
- **Exemplo**:
  ```typescript
  export interface Cliente {
    id: string
    nome: string
    cpf_cnpj?: string
    telefone?: string
    user_id: string  // Isolamento
    empresa_id?: string
    criado_em: string
  }
  ```

### Validação de Formulários
- **React Hook Form** + **Zod** para validação
- **Schemas**: Definir em `src/schemas/` ou inline
- **Validação em tempo real**: Usar `mode: 'onChange'` para feedback imediato
- **Exemplo**:
  ```typescript
  const schema = z.object({
    nome: z.string().min(3, 'Mínimo 3 caracteres'),
    email: z.string().email('Email inválido').optional(),
    cpf_cnpj: z.string().refine(val => validarCPF(val), 'CPF inválido')
  })
  
  const form = useForm({ resolver: zodResolver(schema) })
  ```

### UI & Componentes
- **Componentes base**: `src/components/ui/` (Button, Card, Input, Modal, Dialog, etc)
- **TailwindCSS**: Classes utilitárias + config customizado em `tailwind.config.js`
- **Toast notifications**: `react-hot-toast` (usar `toast.success()`, `toast.error()`)
- **Responsive**: Mobile-first, classes `md:`, `lg:`, `xl:`
- **Exemplo componente**:
  ```tsx
  export function MyButton({ children, ...props }) {
    return (
      <button className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition">
        {children}
      </button>
    )
  }
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
