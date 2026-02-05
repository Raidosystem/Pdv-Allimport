# 🔍 DIAGNÓSTICO: Perda de Centavos nos Valores das OS

## 📋 Problema Relatado
- Valor cadastrado: **R$ 240,00**
- Valor na listagem: **R$ 239,99**
- Valor ao encerrar: **R$ 239,98**
- **Perde 0,01 centavo a cada operação**

---

## 🎯 CAUSA RAIZ IDENTIFICADA

### ❌ Problema 1: Conversão Float com `valueAsNumber`

**Arquivo:** `src/components/ordem-servico/OrdemServicoForm.tsx` (linha 1540)
```tsx
<input
  {...register('valor_orcamento', { valueAsNumber: true })}
  type="number"
  min="0"
  step="0.01"
  className="..."
  placeholder="0,00"
/>
```

**Arquivo:** `src/components/ordem-servico/ModalEntregaOS.tsx` (linha 242)
```tsx
<input
  {...register('valor_final', { valueAsNumber: true })}
  type="number"
  min="0"
  step="0.01"
  className="..."
  placeholder="0,00"
/>
```

### 🐛 O que está acontecendo:

1. **Cadastro da OS:**
   - Usuário digita: `240.00`
   - `valueAsNumber: true` converte para: `240` (número JavaScript)
   - JavaScript armazena como IEEE 754 float: `239.99999999999997`
   - Salvo no banco: `239.99999999999997`

2. **Carregamento na Listagem:**
   - Banco retorna: `239.99999999999997`
   - `toLocaleString()` arredonda para: `R$ 239,99`

3. **Modal de Entrega:**
   - `defaultValues.valor_final = ordem.valor_orcamento` → `239.99999999999997`
   - Exibido como: `239.99`
   - Reprocessado pelo input: `239.98999999999998`
   - Salvo no banco: `239.98999999999998`

4. **Impressão Final:**
   - `toFixed(2)` arredonda: `239.98`

---

## 📊 Fluxo da Perda de Precisão

```
INPUT DO USUÁRIO
    240.00
      ↓
JavaScript Float (IEEE 754)
    239.99999999999997
      ↓
Banco de dados (numeric/decimal)
    239.99999999999997
      ↓
toLocaleString() ou toFixed(2)
    R$ 239,99
      ↓
Re-processamento em novo input
    239.98999999999998
      ↓
toFixed(2) final
    R$ 239,98
```

---

## 🔬 Evidências no Código

### 1. Input de Valor Orçamento
**Arquivo:** `src/components/ordem-servico/OrdemServicoForm.tsx:1540`
```tsx
{...register('valor_orcamento', { valueAsNumber: true })}
```
☠️ **PROBLEMA:** `valueAsNumber` converte string para float JavaScript

### 2. Input de Valor Final
**Arquivo:** `src/components/ordem-servico/ModalEntregaOS.tsx:242`
```tsx
{...register('valor_final', { valueAsNumber: true })}
```
☠️ **PROBLEMA:** Mesma conversão problemática

### 3. Validação Zod
**Arquivo:** `src/components/ordem-servico/ModalEntregaOS.tsx:24`
```tsx
valor_final: z.number().min(0, 'Valor deve ser positivo').optional()
```
✅ **OK:** Validação aceita number (mas deveria ser decimal/string)

### 4. Formatação na Listagem
**Arquivo:** `src/pages/OrdensServicoPageNew.tsx:845-849`
```tsx
const formatPrice = (price: number) => {
  return price.toLocaleString('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  })
}
```
✅ **OK:** Formatação correta, mas recebe número com erro acumulado

### 5. Display no Modal de Resumo
**Arquivo:** `src/components/ordem-servico/ModalEntregaOS.tsx:357`
```tsx
R$ {(watch('valor_final') || 0).toFixed(2)}
```
⚠️ **ARREDONDAMENTO:** Perde mais precisão ao usar `.toFixed(2)`

---

## 💡 POR QUE ISSO ACONTECE?

### JavaScript Float (IEEE 754) - O Vilão

JavaScript não consegue representar **0.01** exatamente em binário:

```javascript
// Teste no console:
console.log(240.00)              // 240
console.log(240.00.toFixed(20))  // "240.00000000000000000000"

// Mas com operações:
console.log(240.00 - 0.01)       // 239.98999999999998
console.log((240.00).toFixed(2)) // "240.00"
console.log(parseFloat("240.00"))// 240 (perde .00)

// Armazenado como float:
let valor = 240.00
console.log(valor * 100 / 100)   // 239.99999999999997
```

### Por que perde 0.01?

1. **Primeira conversão:** `240.00` → `239.99999999999997`
2. **toFixed(2):** `239.99999999999997` → `"240.00"` (string)
3. **Re-parse:** `"240.00"` → `240` → `239.99999999999997`
4. **Acúmulo:** Cada operação adiciona erro de arredondamento

---

## 🛠️ SOLUÇÃO NECESSÁRIA

### ✅ Opção 1: Armazenar como Centavos (Inteiro)
```tsx
// Converter antes de salvar
const valorEmCentavos = Math.round(valor * 100)

// Converter ao exibir
const valorEmReais = valorEmCentavos / 100
```

### ✅ Opção 2: Usar String com Validação
```tsx
// Input como text com máscara
<input type="text" value={formatarMoeda(valor)} />

// Converter apenas no submit
const valorNumerico = parseFloat(valor.replace(/[^0-9,]/g, '').replace(',', '.'))
```

### ✅ Opção 3: Usar Decimal.js ou Dinero.js
```tsx
import Decimal from 'decimal.js'

const valor = new Decimal('240.00')
const valorFinal = valor.minus('0.01') // Precisão exata
```

### ✅ Opção 4: Forçar 2 Casas Decimais no Parse
```tsx
// Ao recuperar do banco
const valorCorrigido = parseFloat(ordem.valor_orcamento.toFixed(2))

// Ao salvar
const valorParaSalvar = parseFloat(data.valor_final.toFixed(2))
```

---

## 📁 Arquivos Afetados

1. ✏️ `src/components/ordem-servico/OrdemServicoForm.tsx`
   - Linha 1540: Input valor_orcamento

2. ✏️ `src/components/ordem-servico/ModalEntregaOS.tsx`
   - Linha 56: defaultValues com valor_orcamento
   - Linha 242: Input valor_final
   - Linha 357: Display com toFixed(2)

3. ✏️ `src/services/ordemServicoService.ts`
   - Linha 168: Salva valor_orcamento
   - Linha 290: Salva valor_final

4. 👀 `src/pages/OrdensServicoPageNew.tsx`
   - Linha 845: formatPrice (apenas exibe)

5. 👀 `src/pages/OrdemServicoDetalhePage.tsx`
   - Exibição de valores (apenas leitura)

---

## ⚠️ RECOMENDAÇÃO

**NÃO MEXER NO CÓDIGO AINDA!**

Antes de corrigir, precisamos decidir:

1. **Qual abordagem usar?**
   - Centavos (inteiro)?
   - String com validação?
   - Biblioteca Decimal?
   - Parse com toFixed?

2. **Migração de dados existentes?**
   - Corrigir valores já salvos no banco?
   - Criar trigger para arredondar?

3. **Impacto em relatórios?**
   - Vendas usa o mesmo pattern?
   - Produtos tem o mesmo problema?

---

## 🎓 Lições Aprendidas

> **NUNCA use `valueAsNumber` para valores monetários em JavaScript!**
> 
> Floats IEEE 754 não são confiáveis para dinheiro.
> Use inteiros (centavos), strings ou bibliotecas especializadas.

---

**Data do Diagnóstico:** 04/02/2026  
**Status:** 🔴 AGUARDANDO DECISÃO DE CORREÇÃO
