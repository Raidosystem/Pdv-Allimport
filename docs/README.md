# 🏪 Sistema PDV Allimport

Sistema de Ponto de Venda moderno desenvolvido com React + TypeScript + Supabase, projetado para ser escalável, confiável e fácil de usar em ambientes comerciais.

## 🚀 Stack Tecnológico

### Frontend
- **React 19** - Biblioteca principal
- **TypeScript** - Tipagem estática
- **Vite** - Build tool rápido
- **TailwindCSS** - Estilização utilitária
- **React Router DOM** - Roteamento
- **React Hook Form** - Gerenciamento de formulários
- **Zod** - Validação de schemas
- **React Query** - Estado do servidor
- **Lucide React** - Ícones modernos

### Backend (BaaS)
- **Supabase** - Backend como serviço
  - PostgreSQL (Banco de dados)
  - Autenticação e autorização
  - Storage para arquivos
  - Real-time subscriptions
  - Edge Functions

### Funcionalidades Especializadas
- **TanStack Table** - Tabelas avançadas
- **Recharts** - Gráficos e analytics
- **React-PDF + jsPDF** - Geração de PDFs
- **QRCode** - Códigos QR e barras
- **date-fns** - Manipulação de datas
- **React Hot Toast** - Notificações

## 📋 Funcionalidades do Sistema

### ✅ Módulos Implementados
- [x] Configuração inicial e dependências
- [x] Estrutura base do projeto
- [x] Tipagem TypeScript completa
- [x] Configuração Supabase
- [x] Utilitários e helpers

### 🔄 Em Desenvolvimento
- [ ] Sistema de autenticação
- [ ] Gestão de produtos
- [ ] Tela de vendas
- [ ] Controle de caixa
- [ ] Cadastro de clientes
- [ ] Ordens de serviço
- [ ] Relatórios e analytics
- [ ] Impressão de recibos
- [ ] Integração WhatsApp
- [ ] Configurações da loja

## 🗂️ Estrutura do Projeto

```
src/
├── components/       # Componentes reutilizáveis
├── pages/           # Páginas/rotas principais
├── hooks/           # Custom hooks
├── services/        # Serviços e APIs
├── types/           # Tipos TypeScript
├── utils/           # Funções utilitárias
├── lib/             # Configurações de bibliotecas
└── assets/          # Imagens e recursos estáticos
```

## 🛠️ Instalação e Configuração

### Pré-requisitos
- Node.js 18+ 
- npm ou yarn
- Conta no Supabase

### 1. Clone e instale dependências
```bash
git clone <repository-url>
cd Pdv-Allimport
npm install
```

### 2. Configure as variáveis de ambiente
```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas credenciais do Supabase:
```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 3. Execute o projeto
```bash
npm run dev
```

O aplicativo estará disponível em `http://localhost:5173`

## 🏗️ Scripts Disponíveis

```bash
npm run dev          # Modo desenvolvimento
npm run build        # Build para produção
npm run preview      # Preview do build
npm run lint         # Linting do código
npm run type-check   # Verificação de tipos
```

## 🎨 Padrões de Design

- **Interface limpa** otimizada para uso comercial
- **Tema claro** por padrão (melhor para PDVs)
- **Responsivo** para tablets e desktops
- **Acessibilidade** seguindo padrões WCAG
- **Performance** otimizada para operações rápidas

## 🔧 Configuração do Banco de Dados

O sistema utiliza PostgreSQL via Supabase. As principais tabelas incluem:

- `users` - Usuários do sistema
- `customers` - Clientes
- `products` - Produtos
- `sales` - Vendas
- `sale_items` - Itens de venda
- `cashiers` - Controle de caixa
- `service_orders` - Ordens de serviço

## 📱 Deployment

### Vercel (Recomendado)
```bash
npm install -g vercel
vercel --prod
```

### Outros provedores
O projeto pode ser deployed em qualquer provedor que suporte SPAs:
- Netlify
- Firebase Hosting
- AWS S3 + CloudFront

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 🆘 Suporte

Para suporte e dúvidas:
- Abra uma issue no GitHub
- Consulte a documentação do Supabase
- Verifique os exemplos em `/examples`

---

⚡ **Desenvolvido com foco em performance, usabilidade e confiabilidade para o ambiente comercial.**
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...
      // Enable lint rules for React
      reactX.configs['recommended-typescript'],
      // Enable lint rules for React DOM
      reactDom.configs.recommended,
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```
