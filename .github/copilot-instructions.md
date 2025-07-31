<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Instruções para o Sistema PDV Allimport

Este é um projeto de **Sistema de Ponto de Venda (PDV)** moderno desenvolvido com React + TypeScript + Vite.

## Stack Tecnológico

- **Frontend**: React 19 + TypeScript + Vite
- **Styling**: TailwindCSS + componentes customizados
- **Backend**: Supabase (PostgreSQL, Auth, Storage, RPCs)
- **Roteamento**: React Router DOM
- **Formulários**: React Hook Form + Zod (validação)
- **Estado**: React Query (TanStack Query)
- **Tabelas**: TanStack Table
- **Gráficos**: Recharts
- **PDFs**: React-PDF + jsPDF
- **QR/Códigos de Barras**: qrcode
- **Notificações**: React Hot Toast
- **Ícones**: Lucide React
- **Utilitários**: date-fns, clsx, tailwind-merge

## Módulos do Sistema PDV

1. **Autenticação & Autorização**
   - Login/Logout de usuários
   - Cadastro de usuários
   - Controle de permissões por usuário

2. **Gestão de Clientes**
   - Cadastro, edição e listagem de clientes
   - Histórico de compras

3. **Gestão de Produtos**
   - Cadastro, edição e listagem de produtos
   - Controle de estoque
   - Categorização

4. **Vendas**
   - Interface de vendas (com e sem cliente)
   - Carrinho de compras
   - Aplicação de descontos
   - Finalização de vendas

5. **Caixa**
   - Abertura e fechamento de caixa
   - Controle de entrada/saída de dinheiro
   - Relatórios de caixa

6. **Ordens de Serviço**
   - Cadastro de equipamentos
   - Controle de defeitos e status
   - Acompanhamento de OS

7. **Relatórios**
   - Vendas diárias/mensais
   - Relatórios financeiros
   - Gráficos e analytics

8. **Impressão**
   - Recibos de venda
   - Notas fiscais
   - Relatórios em PDF

9. **Configurações**
   - Customização da loja (logo, cores)
   - Configurações de impressão
   - Backup/importação de dados

10. **Integração WhatsApp**
    - Envio de pedidos via WhatsApp
    - Comunicação com clientes

## Padrões de Código

- Use **componentes funcionais** com hooks
- Implemente **tipagem TypeScript rigorosa**
- Utilize **Zod** para validação de dados
- Mantenha **componentes pequenos e reutilizáveis**
- Implemente **tratamento de erros adequado**
- Use **React Query** para gerenciamento de estado servidor
- Aplique **princípios de acessibilidade**
- Mantenha **código limpo e bem documentado**

## Estrutura de Pastas Recomendada

```
src/
├── components/     # Componentes reutilizáveis
├── pages/         # Páginas/rotas principais
├── hooks/         # Custom hooks
├── services/      # Serviços (Supabase, APIs)
├── stores/        # Estado global
├── types/         # Tipos TypeScript
├── utils/         # Funções utilitárias
├── lib/           # Configurações de bibliotecas
└── assets/        # Imagens, ícones, etc.
```

## Convenções de Nomenclatura

- **Componentes**: PascalCase (ex: `SalesForm.tsx`)
- **Hooks**: camelCase com prefixo "use" (ex: `useAuth.ts`)
- **Tipos**: PascalCase (ex: `Customer`, `Product`)
- **Funções**: camelCase (ex: `formatCurrency`)
- **Constantes**: UPPER_SNAKE_CASE (ex: `API_BASE_URL`)

## Princípios de Design

- **Interface limpa e intuitiva** para uso em ambiente comercial
- **Responsividade** para tablets e desktops
- **Performance otimizada** para operações rápidas
- **Feedback visual claro** para ações do usuário
- **Tema claro** por padrão (ambiente comercial)
- **Acessibilidade** para diferentes usuários

Sempre priorize **performance**, **usabilidade** e **confiabilidade** ao desenvolver funcionalidades para este sistema PDV.
