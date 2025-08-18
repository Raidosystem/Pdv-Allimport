# 🏪 PDV Allimport - Sistema de Ponto de Venda

## 📱 Progressive Web App (PWA) para Gestão Comercial

Sistema completo de **Ponto de Venda** desenvolvido em **React + TypeScript** com **Supabase** como backend.

[![Deploy Status](https://img.shields.io/badge/Deploy-✅_Ativo-brightgreen)]()
[![PWA](https://img.shields.io/badge/PWA-✅_Instalável-blue)]()
[![TypeScript](https://img.shields.io/badge/TypeScript-✅_100%25-blue)]()

## 🚀 **Acesso ao Sistema**

### 🌐 **Sites Ativos**
- **Produção Principal**: [https://pdv.crmvsystem.com/](https://pdv.crmvsystem.com/)
- **Backup Surge**: [https://pdv-producao.surge.sh/](https://pdv-producao.surge.sh/)
- **Backup Final**: [https://pdv-final.surge.sh/](https://pdv-final.surge.sh/)

### 🔐 **Credenciais de Teste**
- **Email**: `admin@pdv.com`
- **Senha**: `admin123`

## 📱 **Instalação PWA**

### Chrome (Desktop/Mobile)
1. Acesse qualquer site ativo
2. Clique no ícone de instalação na barra de endereços
3. Ou clique no botão azul "📱 Instalar App" no canto inferior esquerdo

### Edge, Safari, Firefox
1. Use o menu "Adicionar à tela inicial" 
2. Ou use as opções do navegador para "Instalar aplicativo"

## 🎯 **Funcionalidades**

### 💰 **Vendas**
- Interface de vendas rápida e intuitiva
- Carrinho de compras dinâmico
- Aplicação de descontos
- Finalização com múltiplas formas de pagamento
- Geração de recibos automática

### 👥 **Gestão de Clientes**
- Cadastro completo de clientes
- Histórico de compras
- Controle de endereços e contatos
- Integração com WhatsApp

### 📦 **Controle de Estoque**
- Cadastro de produtos com categorias
- Controle de estoque em tempo real
- Alertas de estoque baixo
- Relatórios de movimentação

### 💵 **Caixa**
- Abertura e fechamento de caixa
- Controle de entrada/saída
- Relatórios diários
- Histórico completo

### 🔧 **Ordens de Serviço**
- Gestão completa de OS
- Controle de equipamentos
- Acompanhamento de status
- Checklist personalizado

### 📊 **Relatórios**
- Vendas por período
- Gráficos de performance
- Ranking de produtos
- Exportação para Excel/PDF

## 🛠️ **Tecnologias**

### Frontend
- **React 19** + **TypeScript**
- **Vite** (build tool)
- **TailwindCSS** (styling)
- **React Router** (navegação)
- **React Query** (estado servidor)
- **React Hook Form + Zod** (formulários)

### Backend
- **Supabase** (PostgreSQL)
- **Row Level Security** (RLS)
- **Real-time** subscriptions
- **Storage** para arquivos

### PWA
- **Service Worker** personalizado
- **Manifest.json** otimizado
- **Offline-first** approach
- **Push notifications** ready

## 🏗️ **Arquitetura**

```
src/
├── components/     # Componentes reutilizáveis
├── modules/        # Módulos funcionais
│   ├── auth/       # Autenticação
│   ├── clientes/   # Gestão de clientes
│   ├── sales/      # Sistema de vendas
│   └── dashboard/  # Dashboard principal
├── pages/          # Páginas principais
├── hooks/          # Custom hooks
├── services/       # Serviços (APIs)
├── utils/          # Utilitários
└── types/          # Tipos TypeScript
```

## 🚀 **Desenvolvimento**

### Pré-requisitos
- Node.js 18+
- npm ou yarn
- Conta Supabase

### Instalação
```bash
# Clonar repositório
git clone https://github.com/Raidosystem/Pdv-Allimport.git
cd Pdv-Allimport

# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp .env.example .env

# Executar em desenvolvimento
npm run dev

# Build para produção
npm run build
```

### Variáveis de Ambiente
```env
VITE_SUPABASE_URL=sua_url_supabase
VITE_SUPABASE_ANON_KEY=sua_chave_publica
```

## 📋 **Scripts Disponíveis**

- `npm run dev` - Desenvolvimento
- `npm run build` - Build produção
- `npm run preview` - Preview build
- `npm run lint` - Verificar código
- `npm run type-check` - Verificar tipos

## 📁 **Organização**

- `/docs/` - Documentação completa
- `/scripts/diagnosticos/` - Scripts de teste e diagnóstico
- `/public/` - Arquivos estáticos e PWA
- `/api/` - API para pagamentos (opcional)

## 🔐 **Segurança**

- **RLS** (Row Level Security) configurado
- **CORS** adequadamente configurado
- **Autenticação JWT** via Supabase
- **Validação** rigorosa de dados

## 🌟 **Características PWA**

- ✅ **Instalável** em todos dispositivos
- ✅ **Funciona offline** (cache estratégico)
- ✅ **Responsivo** (mobile-first)
- ✅ **Rápido** (lazy loading)
- ✅ **Seguro** (HTTPS obrigatório)

## 📞 **Suporte**

Para dúvidas ou suporte:
- 📧 Email: suporte@crmvsystem.com
- 📱 WhatsApp: Disponível no sistema
- 📝 Issues: [GitHub Issues](https://github.com/Raidosystem/Pdv-Allimport/issues)

## 📄 **Licença**

Este projeto é propriedade da **Raido System** e está protegido por direitos autorais.

---

**Desenvolvido com ❤️ pela equipe Raido System**

*Sistema PDV moderno, confiável e sempre disponível.*
