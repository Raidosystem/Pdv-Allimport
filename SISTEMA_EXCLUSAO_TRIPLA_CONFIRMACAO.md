# Sistema de Exclusão de Usuários com Tripla Confirmação

## 📋 Visão Geral

Implementado sistema de segurança avançado para exclusão de usuários administradores, exigindo **3 confirmações sequenciais** antes da execução da exclusão permanente.

## 🎯 Objetivo

Prevenir exclusões acidentais de usuários e seus dados associados através de um processo de confirmação robusto e intuitivo.

## 🔐 Fluxo de Confirmação

### Passo 1: Aviso Inicial
- **Exibição**: Lista completa de dados que serão excluídos
- **Conteúdo**:
  - Nome e email do usuário
  - Conta de autenticação
  - Registro de funcionário
  - Produtos cadastrados
  - Clientes cadastrados
  - Vendas realizadas
  - Ordens de serviço
  - Registros de caixa
  - Todos os dados associados
- **Ação**: Botão "Continuar" amarelo

### Passo 2: Confirmação por Texto
- **Requisito**: Usuário deve digitar exatamente: `EXCLUIR PERMANENTEMENTE`
- **Validação**: Comparação case-sensitive em tempo real
- **Feedback Visual**:
  - ❌ Texto incorreto: mensagem de erro vermelha
  - ✅ Texto correto: mensagem de sucesso verde
- **Ação**: Botão "Próximo" laranja (desabilitado até texto correto)

### Passo 3: Confirmação Final
- **Exibição**: Aviso crítico de irreversibilidade
- **Destaques**:
  - Banner vermelho "ÚLTIMA CONFIRMAÇÃO"
  - Reexibição dos dados do usuário
  - Aviso "NÃO HÁ COMO DESFAZER ESTA AÇÃO"
- **Ação**: Botão vermelho "EXCLUIR PERMANENTEMENTE" com ícone de lixeira

## 🗑️ Processo de Exclusão

### Dados Deletados (em ordem)

1. **Produtos** (`produtos` table)
   - Filtro: `user_id = userId`

2. **Clientes** (`clientes` table)
   - Filtro: `user_id = userId`

3. **Vendas** (`vendas` table)
   - Filtro: `user_id = userId`

4. **Ordens de Serviço** (`ordens_servico` table)
   - Filtro: `user_id = userId`

5. **Registros de Caixa** (`caixas` table - se existir)
   - Filtro: `user_id = userId`
   - Erro 404 ignorado se tabela não existir

6. **Funcionário** (`funcionarios` table)
   - Filtro: `id = userId`

7. **Conta de Autenticação** (Supabase Auth) - ⚠️ **LIMITAÇÃO**
   - **PROBLEMA**: Não pode ser deletada com chave anônima (403 Forbidden)
   - **MOTIVO**: `supabase.auth.admin.deleteUser()` requer `service_role_key`
   - **SOLUÇÃO ATUAL**: Alerta ao usuário com instrução SQL
   - **SOLUÇÃO RECOMENDADA**: Usar função RPC `admin_delete_user()`

### ⚠️ Limitação de Segurança

Por segurança, o **frontend não pode deletar contas de autenticação** diretamente usando a chave anônima. Existem 3 opções:

#### Opção 1: SQL Manual (Atual)
```sql
-- Executar no SQL Editor do Supabase
DELETE FROM auth.users WHERE email = 'usuario@example.com';
```

#### Opção 2: Função RPC (Recomendado)
```sql
-- 1. Criar função no Supabase (ver DELETAR_USUARIO_AUTH_PERMANENTE.sql)
CREATE OR REPLACE FUNCTION admin_delete_user(user_email TEXT)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$...$$;

-- 2. Usar no código TypeScript:
const { error } = await supabase.rpc('admin_delete_user', { 
  user_email: userToDelete.email 
});
```

#### Opção 3: Edge Function
- Criar Edge Function com `service_role_key`
- Chamar via API do frontend
- Mais complexo, mas mais seguro

## 📁 Arquivos Modificados/Criados

### 1. DeleteUserModal.tsx (NOVO)
**Localização**: `src/components/admin/DeleteUserModal.tsx`

**Funcionalidades**:
- Modal responsivo com 3 etapas
- Gerenciamento de estado interno (step, confirmText, isDeleting)
- Validação de texto em tempo real
- Prevenção de fechamento durante exclusão
- Feedback visual por cores (amarelo → laranja → vermelho)
- Loading state durante exclusão

**Props**:
```typescript
interface DeleteUserModalProps {
  isOpen: boolean;           // Controla visibilidade do modal
  onClose: () => void;       // Callback para cancelamento
  onConfirm: () => Promise<void>; // Callback para confirmação final
  userName: string;          // Nome do usuário a excluir
  userEmail: string;         // Email do usuário a excluir
}
```

### 2. AdminUsersPage.tsx (MODIFICADO)

**Mudanças**:

1. **Import do Modal**:
```typescript
import { DeleteUserModal } from '../../components/admin/DeleteUserModal';
```

2. **Novos Estados**:
```typescript
const [showDeleteModal, setShowDeleteModal] = useState(false);
const [userToDelete, setUserToDelete] = useState<FuncionarioWithDetails | null>(null);
```

3. **Função handleDeleteUser** (refatorada):
```typescript
const handleDeleteUser = async (userId: string) => {
  const user = funcionarios.find(f => f.id === userId);
  if (!user) return;
  
  setUserToDelete(user);
  setShowDeleteModal(true);
};
```

4. **Nova Função executeDeleteUser**:
- Busca authUser por email
- Deleta dados relacionados em cascata
- Deleta funcionário
- Deleta conta de autenticação
- Recarrega lista de funcionários

5. **Modal no JSX**:
```tsx
<DeleteUserModal
  isOpen={showDeleteModal}
  onClose={() => {
    setShowDeleteModal(false);
    setUserToDelete(null);
  }}
  onConfirm={executeDeleteUser}
  userName={userToDelete?.nome || 'Usuário sem nome'}
  userEmail={userToDelete?.email || ''}
/>
```

## 🎨 Design e UX

### Cores por Etapa
- **Passo 1**: Amarelo (⚠️ Aviso)
- **Passo 2**: Laranja (🔶 Atenção)
- **Passo 3**: Vermelho (🔴 Crítico)

### Ícones
- `AlertTriangle`: Aviso inicial
- `Trash2`: Exclusão final
- `X`: Fechar modal

### Estados do Botão Final
- **Normal**: "EXCLUIR PERMANENTEMENTE" com ícone
- **Loading**: Spinner + "Excluindo..."
- **Desabilitado**: Opacidade reduzida + cursor not-allowed

## 🔒 Segurança

### Validações Implementadas
1. ✅ Permissão de usuário (`can('administracao.usuarios', 'delete')` ou `isAdminEmpresa`)
2. ✅ Verificação de existência do usuário
3. ✅ Texto de confirmação case-sensitive
4. ✅ Desabilitação de ações durante exclusão
5. ✅ Prevenção de múltiplos cliques

### Tratamento de Erros
- Try-catch em todas operações de banco
- Log de erros no console
- Alert para usuário em caso de falha
- Não bloqueia exclusão se falhar apenas a remoção do auth

## 🚀 Como Usar

1. **Admin acessa**: Página de Usuários
2. **Clica em**: Botão de Excluir (ícone de lixeira)
3. **Modal abre**: Etapa 1/3 com aviso
4. **Clica**: "Continuar"
5. **Digite**: "EXCLUIR PERMANENTEMENTE"
6. **Clica**: "Próximo"
7. **Revisa**: Aviso final
8. **Confirma**: "EXCLUIR PERMANENTEMENTE"
9. **Sistema**: Executa exclusão completa
10. **Modal fecha**: Lista atualizada automaticamente

## ⚡ Performance

- **Deleções em paralelo**: Não (sequencial para garantir integridade)
- **Recarregamento**: Apenas após sucesso completo
- **Feedback**: Loading visual durante processo

## 📊 Dados de Auditoria

**Nota**: Sistema de audit_logs está comentado (tabela não existe no upgrade minimalista)

```typescript
// await supabase.from('audit_logs').insert({
//   recurso: 'administracao.usuarios',
//   acao: 'delete',
//   entidade_tipo: 'funcionario',
//   entidade_id: userId
// });
```

## 🧪 Testing Checklist

- [ ] Modal abre corretamente ao clicar em excluir
- [ ] Passo 1: Botão "Continuar" funciona
- [ ] Passo 2: Validação de texto funciona (case-sensitive)
- [ ] Passo 2: Botão desabilitado sem texto correto
- [ ] Passo 3: Exibe aviso final
- [ ] Exclusão: Deleta todos os dados relacionados
- [ ] Exclusão: Remove conta de autenticação
- [ ] Loading: Exibe estado de carregamento
- [ ] Erro: Trata falhas graciosamente
- [ ] Cancelar: Fecha modal sem executar ação
- [ ] Lista: Atualiza após exclusão bem-sucedida

## 📝 Notas Importantes

1. **Irreversibilidade**: Não há rollback implementado para dados deletados
2. **Limitação Auth**: Frontend não pode deletar contas de autenticação (requer service_role_key)
3. **Cascata Manual**: Deleções são feitas manualmente (não via FK cascade)
4. **Email Match**: Busca authUser por correspondência de email
5. **Tabela Caixas**: Erro 404 ignorado se tabela não existir
6. **Logs Detalhados**: Console mostra progresso de cada etapa da exclusão

### Comportamento Atual

Quando um admin tenta excluir um usuário:
1. ✅ Sistema deleta todos os dados relacionados (produtos, clientes, vendas, etc.)
2. ✅ Sistema deleta o registro na tabela `funcionarios`
3. ⚠️ Sistema **NÃO** deleta a conta de autenticação automaticamente
4. 📢 Sistema exibe alerta com instrução SQL para deletar manualmente

### Para Exclusão Completa

Execute no SQL Editor do Supabase:
```sql
-- Ver arquivo: DELETAR_USUARIO_AUTH_PERMANENTE.sql
DELETE FROM auth.users WHERE email = 'usuario@example.com';
```

Ou implemente a função RPC `admin_delete_user()` conforme documentado no arquivo SQL.

## 🔄 Próximas Melhorias Sugeridas

- [ ] Implementar sistema de audit_logs
- [ ] Adicionar backup antes de excluir
- [ ] Permitir restauração de usuários excluídos (soft delete)
- [ ] Enviar email de confirmação antes da exclusão
- [ ] Log de quem executou a exclusão
- [ ] Relatório de dados excluídos

---

**Implementado em**: 2024
**Versão**: 1.0.0
**Status**: ✅ Funcional
