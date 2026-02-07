# 📊 Sistema DRE - Demonstração do Resultado do Exercício

Sistema completo de **DRE** (Demonstração do Resultado do Exercício) com **Custo Médio Móvel (CMV)**, controle de **estoque**, **multi-tenant** por `empresa_id` e **Row Level Security (RLS)**.

---

## 🚀 O que foi implementado

### ✅ **Banco de Dados (SQL)**

#### **Tabelas Criadas:**
- `compras` - Registro de compras de mercadorias
- `itens_compra` - Itens individuais de cada compra
- `movimentacoes_estoque` - Livro de estoque (stock ledger) com todas as movimentações
- `despesas` - Despesas operacionais (aluguel, energia, salários, etc.)
- `outras_movimentacoes_financeiras` - Receitas e despesas não operacionais

#### **Campos Adicionados em `produtos`:**
- `custo_medio` - Custo médio móvel calculado automaticamente
- `quantidade_estoque` - Quantidade atual em estoque
- `estoque_minimo` - Nível mínimo de estoque
- `controla_estoque` - Flag para ativar/desativar controle

#### **Funções RPC:**
1. **`fn_recalc_custo_medio`** - Recalcula custo médio móvel
   ```sql
   SELECT * FROM fn_recalc_custo_medio(
       p_produto_id UUID,
       p_quantidade INTEGER,
       p_custo_unitario DECIMAL,
       p_tipo_movimentacao TEXT
   );
   ```

2. **`fn_aplicar_compra`** - Processa compra (atualiza estoque + custo médio)
   ```sql
   SELECT fn_aplicar_compra('uuid-da-compra');
   ```

3. **`fn_aplicar_venda`** - Processa venda (baixa estoque + registra CMV)
   ```sql
   SELECT fn_aplicar_venda('uuid-da-venda');
   ```

4. **`fn_calcular_dre`** - Calcula DRE para um período
   ```sql
   SELECT * FROM fn_calcular_dre(
       '2025-01-01'::DATE,
       '2025-01-31'::DATE,
       'empresa-id-uuid'::UUID
   );
   ```

#### **Políticas RLS:**
Todas as tabelas possuem **RLS** ativo com isolamento por `empresa_id` e `user_id`:
- ✅ Cada usuário vê apenas dados da sua empresa
- ✅ Proteção contra vazamento de dados entre empresas

---

## 📦 Arquivos Criados

### **1. Migração SQL**
📄 `database/migrations/20250104_dre_sistema_completo.sql`
- Schema completo
- Funções RPC
- Políticas RLS
- Índices para performance

### **2. Seeds (Dados de Exemplo)**
📄 `database/seeds/dre_seeds.sql`
- Produtos de exemplo
- Compra de teste com entrada de estoque
- Venda de teste com saída de estoque
- Despesas operacionais
- Outras movimentações financeiras

### **3. Tipos TypeScript**
📄 `src/types/dre.ts`
- Interfaces completas:
  - `DRE`, `KPIsDRE`
  - `Compra`, `ItemCompra`, `CompraForm`
  - `Despesa`, `DespesaForm`
  - `MovimentacaoEstoque`
  - `OutraMovimentacaoFinanceira`
- Constantes e enums

### **4. Serviço DRE**
📄 `src/services/dreService.ts`
- `criarCompra()` - Registrar compra
- `listarCompras()` - Listar com filtros
- `criarDespesa()` - Registrar despesa
- `listarDespesas()` - Listar com filtros
- `calcularDRE()` - Calcular DRE para período
- `exportarDREParaCSV()` - Exportar para CSV

### **5. Hooks React**
📄 `src/hooks/useDRE.ts`
- `useDRE()` - Gerenciar cálculo de DRE
- `useCompras()` - Gerenciar compras
- `useDespesas()` - Gerenciar despesas
- `useOutrasMovimentacoes()` - Outras receitas/despesas

---

## 🛠️ Como Instalar

### **Passo 1: Executar Migração**

1. Abra o **Supabase SQL Editor**
2. Copie e execute: `database/migrations/20250104_dre_sistema_completo.sql`
3. Aguarde a mensagem: ✅ Sistema DRE criado com sucesso!

### **Passo 2: Instalar Seeds (Opcional - para teste)**

1. **IMPORTANTE:** Abra `database/seeds/dre_seeds.sql`
2. **Substitua** o `user_id` na linha 14:
   ```sql
   v_user_id UUID := 'SEU-USER-ID-AQUI';
   ```
   Para pegar seu user_id, execute:
   ```sql
   SELECT id FROM auth.users WHERE email = 'seu-email@exemplo.com';
   ```
3. Execute o script completo
4. Verifique os dados criados

### **Passo 3: Integrar no Frontend**

#### **3.1. Atualizar Menu de Navegação**

Localize o arquivo de rotas/navegação (ex: `src/App.tsx` ou `src/routes.tsx`):

```tsx
// ANTES (Relatórios Detalhados)
{ path: '/relatorios-detalhados', element: <RelatoriosDetalhados /> }

// DEPOIS (DRE)
{ path: '/dre', element: <DREPage /> }
```

No menu lateral, substitua:
```tsx
// ANTES
<NavLink to="/relatorios-detalhados">
  <FileText /> Relatórios Detalhados
</NavLink>

// DEPOIS
<NavLink to="/dre">
  <TrendingUp /> DRE
</NavLink>
```

#### **3.2. Criar Página DREPage (Simplificada)**

Crie `src/pages/DREPage.tsx`:

```tsx
import React, { useState } from 'react';
import { useDRE } from '../hooks/useDRE';
import { formatCurrency } from '../utils/format';
import { Download, Calendar, TrendingUp, TrendingDown } from 'lucide-react';

export default function DREPage() {
  const { dre, kpis, loading, calcularDRE, exportarCSV } = useDRE();
  const [dataInicio, setDataInicio] = useState(
    new Date(new Date().getFullYear(), new Date().getMonth(), 1)
  );
  const [dataFim, setDataFim] = useState(new Date());

  const handleCalcular = () => {
    calcularDRE({ data_inicio: dataInicio, data_fim: dataFim });
  };

  React.useEffect(() => {
    handleCalcular();
  }, []);

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">📊 DRE - Demonstração do Resultado</h1>
        <button
          onClick={exportarCSV}
          disabled={!dre}
          className="btn btn-primary flex items-center gap-2"
        >
          <Download size={20} />
          Exportar CSV
        </button>
      </div>

      {/* Filtros */}
      <div className="card p-4 mb-6">
        <div className="flex gap-4 items-end">
          <div className="flex-1">
            <label className="label">Data Início</label>
            <input
              type="date"
              value={dataInicio.toISOString().split('T')[0]}
              onChange={(e) => setDataInicio(new Date(e.target.value))}
              className="input"
            />
          </div>
          <div className="flex-1">
            <label className="label">Data Fim</label>
            <input
              type="date"
              value={dataFim.toISOString().split('T')[0]}
              onChange={(e) => setDataFim(new Date(e.target.value))}
              className="input"
            />
          </div>
          <button onClick={handleCalcular} className="btn btn-primary">
            <Calendar size={20} />
            Calcular DRE
          </button>
        </div>
      </div>

      {loading && <div className="text-center py-8">Calculando DRE...</div>}

      {dre && (
        <>
          {/* KPIs */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
            <div className="card p-4">
              <h3 className="text-sm text-gray-500">Margem Bruta</h3>
              <p className="text-2xl font-bold text-blue-600">
                {kpis?.margem_bruta_percentual.toFixed(2)}%
              </p>
            </div>
            <div className="card p-4">
              <h3 className="text-sm text-gray-500">Margem Operacional</h3>
              <p className="text-2xl font-bold text-green-600">
                {kpis?.margem_operacional_percentual.toFixed(2)}%
              </p>
            </div>
            <div className="card p-4">
              <h3 className="text-sm text-gray-500">Margem Líquida</h3>
              <p className="text-2xl font-bold text-purple-600">
                {kpis?.margem_liquida_percentual.toFixed(2)}%
              </p>
            </div>
          </div>

          {/* DRE Table */}
          <div className="card p-6">
            <h2 className="text-xl font-bold mb-4">Demonstração do Resultado</h2>
            <table className="w-full">
              <tbody className="divide-y">
                <tr>
                  <td className="py-2 font-medium">Receita Bruta</td>
                  <td className="py-2 text-right font-bold text-green-600">
                    {formatCurrency(dre.receita_bruta)}
                  </td>
                </tr>
                <tr>
                  <td className="py-2 pl-4">(-) Deduções</td>
                  <td className="py-2 text-right text-red-600">
                    {formatCurrency(dre.deducoes)}
                  </td>
                </tr>
                <tr className="bg-gray-50">
                  <td className="py-2 font-bold">(=) Receita Líquida</td>
                  <td className="py-2 text-right font-bold">
                    {formatCurrency(dre.receita_liquida)}
                  </td>
                </tr>
                <tr>
                  <td className="py-2 pl-4">(-) CMV (Custo da Mercadoria Vendida)</td>
                  <td className="py-2 text-right text-red-600">
                    {formatCurrency(dre.cmv)}
                  </td>
                </tr>
                <tr className="bg-blue-50">
                  <td className="py-2 font-bold">(=) Lucro Bruto</td>
                  <td className="py-2 text-right font-bold text-blue-600">
                    {formatCurrency(dre.lucro_bruto)}
                  </td>
                </tr>
                <tr>
                  <td className="py-2 pl-4">(-) Despesas Operacionais</td>
                  <td className="py-2 text-right text-red-600">
                    {formatCurrency(dre.despesas_operacionais)}
                  </td>
                </tr>
                <tr className="bg-green-50">
                  <td className="py-2 font-bold">(=) Resultado Operacional</td>
                  <td className="py-2 text-right font-bold text-green-600">
                    {formatCurrency(dre.resultado_operacional)}
                  </td>
                </tr>
                <tr>
                  <td className="py-2 pl-4">(+) Outras Receitas</td>
                  <td className="py-2 text-right text-green-600">
                    {formatCurrency(dre.outras_receitas)}
                  </td>
                </tr>
                <tr>
                  <td className="py-2 pl-4">(-) Outras Despesas</td>
                  <td className="py-2 text-right text-red-600">
                    {formatCurrency(dre.outras_despesas)}
                  </td>
                </tr>
                <tr className="bg-purple-100 border-t-2 border-purple-500">
                  <td className="py-3 font-bold text-lg">(=) RESULTADO LÍQUIDO</td>
                  <td className="py-3 text-right font-bold text-lg text-purple-600">
                    {formatCurrency(dre.resultado_liquido)}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}
```

---

## 📊 Como Usar o Sistema

### **1. Registrar uma Compra**

```typescript
import { useCompras } from '../hooks/useDRE';

const { criarCompra } = useCompras();

await criarCompra({
  fornecedor_nome: 'Fornecedor XYZ',
  fornecedor_cnpj: '12.345.678/0001-90',
  numero_nota: 'NF-12345',
  data_compra: new Date(),
  itens: [
    {
      produto_id: 'uuid-produto-1',
      quantidade: 50,
      custo_unitario: 45.00
    }
  ]
});
```

### **2. Registrar uma Despesa**

```typescript
import { useDespesas } from '../hooks/useDRE';

const { criarDespesa } = useDespesas();

await criarDespesa({
  descricao: 'Aluguel da Loja - Janeiro',
  categoria: 'aluguel',
  valor: 2500.00,
  data_despesa: new Date(),
  status: 'pago'
});
```

### **3. Calcular DRE**

```typescript
import { useDRE } from '../hooks/useDRE';

const { calcularDRE, dre, kpis } = useDRE();

calcularDRE({
  data_inicio: new Date('2025-01-01'),
  data_fim: new Date('2025-01-31')
});

// Resultado:
console.log(dre.receita_liquida);
console.log(kpis.margem_liquida_percentual);
```

---

## 🧪 Como Testar

### **Teste 1: Verificar Custo Médio Móvel**

```sql
-- 1. Ver produto antes da compra
SELECT nome, custo_medio, quantidade_estoque FROM produtos WHERE id = 'produto-uuid';

-- 2. Criar compra
-- (use a função criarCompra ou insira manualmente)

-- 3. Aplicar compra
SELECT fn_aplicar_compra('compra-uuid');

-- 4. Ver produto depois da compra
SELECT nome, custo_medio, quantidade_estoque FROM produtos WHERE id = 'produto-uuid';

-- 5. Ver movimentação de estoque
SELECT * FROM movimentacoes_estoque 
WHERE produto_id = 'produto-uuid' 
ORDER BY data_movimentacao DESC 
LIMIT 5;
```

### **Teste 2: Calcular DRE**

```sql
-- Calcular DRE do mês atual
SELECT * FROM fn_calcular_dre(
    DATE_TRUNC('month', CURRENT_DATE)::DATE,
    CURRENT_DATE,
    'sua-empresa-uuid'::UUID
);
```

---

## 📝 Estrutura do DRE

```
RECEITA BRUTA                    R$ 10.000,00
(-) Deduções (descontos)         R$    200,00
──────────────────────────────────────────────
(=) RECEITA LÍQUIDA              R$  9.800,00

(-) CMV (Custo Merc. Vendida)    R$  4.500,00
──────────────────────────────────────────────
(=) LUCRO BRUTO                  R$  5.300,00
    Margem Bruta: 54,08%

(-) Despesas Operacionais        R$  3.000,00
──────────────────────────────────────────────
(=) RESULTADO OPERACIONAL        R$  2.300,00
    Margem Operacional: 23,47%

(+) Outras Receitas              R$    100,00
(-) Outras Despesas              R$     50,00
──────────────────────────────────────────────
(=) RESULTADO LÍQUIDO            R$  2.350,00
    Margem Líquida: 23,98%
```

---

## ⚙️ Configurações Adicionais

### **Permissões no Supabase**

As funções RPC já têm `SECURITY DEFINER` e os grants estão aplicados. Se necessário, execute:

```sql
GRANT EXECUTE ON FUNCTION fn_calcular_dre TO authenticated;
GRANT EXECUTE ON FUNCTION fn_aplicar_compra TO authenticated;
GRANT EXECUTE ON FUNCTION fn_aplicar_venda TO authenticated;
```

### **Triggers Automáticos**

As vendas existentes **NÃO** são processadas automaticamente. Para integrar vendas antigas:

```sql
-- Processar todas as vendas pendentes
DO $$
DECLARE
    v_venda RECORD;
BEGIN
    FOR v_venda IN 
        SELECT id FROM vendas WHERE status = 'completed'
    LOOP
        PERFORM fn_aplicar_venda(v_venda.id);
    END LOOP;
END $$;
```

---

## 🐛 Troubleshooting

### **Erro: "Estoque insuficiente"**
- Verifique `quantidade_estoque` do produto
- Certifique-se de que houve uma compra antes da venda

### **DRE retorna zeros**
- Verifique se há vendas no período
- Confirme que `fn_aplicar_venda` foi executado
- Verifique RLS (user_id e empresa_id corretos)

### **Custo médio não atualiza**
- Execute `fn_aplicar_compra` manualmente
- Verifique se a compra está com status 'finalizada'

---

## 📚 Próximos Passos

1. ✅ Executar migração SQL
2. ✅ Instalar seeds (opcional)
3. ✅ Criar página `DREPage.tsx`
4. ✅ Atualizar menu de navegação
5. ✅ Testar fluxo completo:
   - Compra → Atualiza estoque/custo
   - Venda → Baixa estoque/registra CMV
   - DRE → Calcula resultado

---

## 📦 Recursos Extras

- **Export CSV**: Botão para baixar DRE em CSV
- **Gráficos**: Integre com Recharts para visualizações
- **Comparativos**: Use `calcularDREComparativo()` para comparar períodos
- **Relatórios**: Crie relatórios de estoque, CMV, despesas por categoria

---

✅ **Sistema DRE Completo Instalado!**

Para dúvidas ou suporte, consulte a documentação do Supabase ou os comentários no código SQL.
