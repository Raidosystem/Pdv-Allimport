# ?? CORRIGIR PERMISSÕES DE JENNIFER

## ? SOLUÇÃO RÁPIDA

**Erro recebido?**
```
ERROR: 23505: could not create unique index "funcao_permissoes_pkey"
```

### ? EXECUTE ESTE ARQUIVO:
**`CORRIGIR_PERMISSOES_V2_FINAL.sql`**

---

## ?? PASSOS

1. **Abra o Supabase SQL Editor**
2. **Copie TODO o conteúdo** do arquivo `CORRIGIR_PERMISSOES_V2_FINAL.sql`
3. **Cole no SQL Editor** e clique em "Run"
4. **Aguarde** ver a mensagem: `?? Total de permissões: 34`
5. **Jennifer faz logout e login** novamente

---

## ?? DOCUMENTAÇÃO COMPLETA

Para entender o problema e a solução detalhadamente:
- ?? **`EXPLICACAO_PROBLEMA_PERMISSOES.md`** - Entenda o que está acontecendo
- ?? **`QUAL_SCRIPT_EXECUTAR.md`** - Compare V1 vs V2 e veja por que usar o V2

---

## ? RESULTADO ESPERADO

Após executar o script:
- Jennifer terá **34 permissões** (não 63)
- Jennifer verá **6 módulos**: Vendas, Produtos, Clientes, Caixa, Ordens, Configurações
- Jennifer **NÃO** verá: Relatórios, Administração

---

## ?? PROBLEMAS?

Se após executar o V2 ainda houver problemas:

1. **Verifique o total de permissões**:
   ```sql
   SELECT COUNT(*) FROM funcao_permissoes fp
   JOIN funcionarios f ON f.funcao_id = fp.funcao_id
   WHERE f.email = 'sousajenifer895@gmail.com';
   ```
   **Deve ser**: 34

2. **Limpe o cache do navegador**: `Ctrl + Shift + Del`

3. **Jennifer faz logout/login** novamente

---

**?? TL;DR**: Execute `CORRIGIR_PERMISSOES_V2_FINAL.sql` no Supabase ? Jennifer faz logout/login ? Pronto!
