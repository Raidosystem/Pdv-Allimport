# Validação de CPF em Tempo Real com Supabase

Este sistema implementa validação de CPF em tempo real com checagem de duplicidade no Supabase, incluindo garantias no banco de dados.

## 📁 Arquivos Criados

### 1. Utilitários de CPF
- **`src/lib/cpf.ts`** - Funções para validação e formatação de CPF
- **`src/hooks/useDebounce.ts`** - Hook para debounce de valores

### 2. Componente de Input
- **`src/components/CpfInput.tsx`** - Componente de input com validação em tempo real

### 3. Exemplos de Uso
- **`src/pages/clientes/NovoCliente.tsx`** - Página completa de exemplo
- **`src/components/cliente/ClienteFormularioComCpf.tsx`** - Integração com formulário existente

### 4. Migração SQL
- **`migrations/2025-09-14_cpf_validations.sql`** - Script de migração para o banco

## 🚀 Como Usar

### 1. Executar Migração SQL

Execute o script SQL no seu Supabase:

```sql
-- Copie e execute o conteúdo de migrations/2025-09-14_cpf_validations.sql
```

### 2. Usar o Componente CpfInput

```tsx
import { useRef } from 'react'
import { CpfInput, type CpfInputRef } from '../components/CpfInput'

function MeuFormulario() {
  const [cpf, setCpf] = useState('')
  const cpfInputRef = useRef<CpfInputRef>(null)

  const handleSubmit = () => {
    if (cpfInputRef.current?.isCpfOk) {
      // CPF válido e não duplicado
      const cpfDigits = onlyDigits(cpf)
      // Salvar cpfDigits no banco
    }
  }

  return (
    <CpfInput
      ref={cpfInputRef}
      value={cpf}
      onChange={setCpf}
      empresaId="uuid-da-empresa" // Opcional para multi-tenant
    />
  )
}
```

### 3. Funcionalidades

#### ✅ **Validação Local**
- Remove caracteres não numéricos automaticamente
- Aplica máscara `000.000.000-00` em tempo real
- Valida dígitos verificadores do CPF
- Rejeita sequências repetidas (000.000.000-00, etc.)

#### ✅ **Checagem no Supabase**
- Debounce de 250ms para evitar spam de requisições
- Verifica duplicidade na tabela `clientes`
- Suporte a multi-tenant opcional via `empresa_id`
- Feedback visual em tempo real

#### ✅ **Estados do Componente**
- **`idle`** - "Digite o CPF."
- **`invalid`** - "CPF inválido." (borda vermelha)
- **`checking`** - "Verificando CPF…" (borda amarela + spinner)
- **`duplicate`** - "Este CPF já está cadastrado." (borda vermelha)
- **`ok`** - "CPF válido." (borda verde)

#### ✅ **Garantias no Banco**
- Função `is_valid_cpf()` em PL/pgSQL
- Constraint de validação na coluna `cpf_digits`
- Índice único por empresa: `(empresa_id, cpf_digits)`
- Trigger para normalizar entrada (remove formatação)

## 🔧 Configuração

### 1. Variáveis de Ambiente

Certifique-se de que as variáveis estão configuradas:

```env
VITE_SUPABASE_URL=sua_url_aqui
VITE_SUPABASE_ANON_KEY=sua_chave_aqui
```

### 2. Schema da Tabela Clientes

```sql
CREATE TABLE public.clientes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  cpf_digits text NOT NULL 
    CHECK (char_length(cpf_digits) = 11 AND cpf_digits ~ '^[0-9]{11}$' AND public.is_valid_cpf(cpf_digits)),
  email text,
  telefone text,
  endereco text,
  tipo text NOT NULL DEFAULT 'Física',
  empresa_id uuid, -- Opcional para multi-tenant
  ativo boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Índice único
CREATE UNIQUE INDEX uniq_clientes_empresa_cpf 
ON public.clientes(coalesce(empresa_id, '00000000-0000-0000-0000-000000000000'::uuid), cpf_digits);
```

## 📝 Exemplos Práticos

### Validação de CPFs

```typescript
import { isValidCPF, formatCPF, onlyDigits } from './lib/cpf'

// Testes
console.log(isValidCPF('11144477735')) // true
console.log(isValidCPF('12345678901')) // false
console.log(isValidCPF('00000000000')) // false (sequência repetida)

// Formatação
console.log(formatCPF('11144477735')) // "111.444.777-35"
console.log(onlyDigits('111.444.777-35')) // "11144477735"
```

### Integração com React Hook Form

```tsx
const { register, handleSubmit } = useForm()
const [cpf, setCpf] = useState('')
const cpfRef = useRef<CpfInputRef>(null)

const onSubmit = (data) => {
  if (!cpfRef.current?.isCpfOk) {
    alert('CPF inválido!')
    return
  }

  const payload = {
    ...data,
    cpf_digits: onlyDigits(cpf)
  }
  // Enviar para o servidor
}
```

## ⚠️ Importante

1. **Armazenamento**: Sempre armazenar `cpf_digits` (apenas números) no banco
2. **Exibição**: Usar `formatCPF()` para mostrar com máscara no frontend
3. **Validação**: O banco garante integridade mesmo se o frontend falhar
4. **Multi-tenant**: Configure `empresa_id` se necessário
5. **Performance**: O debounce evita consultas excessivas ao Supabase

## 🧪 Testes

Execute os testes básicos:

```typescript
import { CPF_TESTS, isValidCPF } from './lib/cpf'

// CPFs válidos
CPF_TESTS.valid.forEach(cpf => {
  console.assert(isValidCPF(cpf), `${cpf} deveria ser válido`)
})

// CPFs inválidos
CPF_TESTS.invalid.forEach(cpf => {
  console.assert(!isValidCPF(cpf), `${cpf} deveria ser inválido`)
})
```

## 🎨 Personalização

### Estilos Customizados

```tsx
<CpfInput
  className="minha-classe-custom"
  value={cpf}
  onChange={setCpf}
  placeholder="Digite seu CPF"
/>
```

### Status Personalizado

```tsx
const cpfRef = useRef<CpfInputRef>(null)

// Acessar status atual
console.log(cpfRef.current?.status) // 'idle' | 'invalid' | 'checking' | 'duplicate' | 'ok'
console.log(cpfRef.current?.isCpfOk) // boolean
```

Sistema implementado com sucesso! 🎉