-- ============================================
-- 🔄 MIGRAÇÃO: CRIAR AUTH PARA JENNIFER
-- ============================================
-- Este script prepara a migração da Jennifer para conta Auth real
-- Assim ela terá sessão persistente e permissões editáveis
-- ============================================

-- 📊 PASSO 1: Verificar dados atuais da Jennifer
SELECT 
  '📋 DADOS ATUAIS DA JENNIFER' as info,
  f.id as funcionario_id,
  f.nome,
  f.email,
  f.empresa_id,
  f.funcao_id,
  fc.nome as funcao_nome,
  f.user_id,
  f.status,
  CASE 
    WHEN f.user_id IS NULL THEN '❌ SEM CONTA AUTH - PRECISA CRIAR'
    ELSE '✅ JÁ TEM CONTA AUTH'
  END as status_auth
FROM funcionarios f
LEFT JOIN funcoes fc ON fc.id = f.funcao_id
WHERE f.email = 'sousajenifer895@gmail.com';

-- ============================================
-- 🔑 PASSO 2: CRIAR CONTA AUTH (Manual)
-- ============================================
/*
⚠️  IMPORTANTE: Execute no Painel do Supabase

1. Acesse: https://supabase.com/dashboard/project/[seu-projeto]/auth/users

2. Clique em "Add user" (botão verde)

3. Preencha:
   - Email: sousajenifer895@gmail.com
   - Password: 123456 (ou defina outra senha)
   - ✅ Marque "Auto Confirm User" (IMPORTANTE!)

4. Clique em "Create user"

5. Copie o UUID gerado (aparece na coluna "ID")

6. Execute o PASSO 3 abaixo com esse UUID
*/

-- ============================================
-- 🔗 PASSO 3: VINCULAR user_id
-- ============================================
-- ⚠️  SUBSTITUA '[user_id_gerado]' pelo UUID do Supabase Auth

-- Primeiro, veja o ID do funcionário:
SELECT id, nome, email, user_id
FROM funcionarios
WHERE email = 'sousajenifer895@gmail.com';

-- Depois, vincule o user_id:
-- UPDATE funcionarios 
-- SET user_id = '[user_id_gerado_no_passo_2]',
--     updated_at = NOW()
-- WHERE email = 'sousajenifer895@gmail.com';

-- ✅ Exemplo (substitua o UUID real):
-- UPDATE funcionarios 
-- SET user_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
--     updated_at = NOW()
-- WHERE email = 'sousajenifer895@gmail.com';

-- ============================================
-- ✅ PASSO 4: VERIFICAR RESULTADO
-- ============================================
SELECT 
  '✅ VERIFICAÇÃO PÓS-MIGRAÇÃO' as info,
  f.id as funcionario_id,
  f.nome,
  f.email,
  f.user_id,
  fc.nome as funcao,
  CASE 
    WHEN f.user_id IS NOT NULL THEN '✅ CONTA AUTH VINCULADA - PRONTO!'
    ELSE '❌ AINDA SEM user_id - VERIFICAR PASSO 3'
  END as status
FROM funcionarios f
LEFT JOIN funcoes fc ON fc.id = f.funcao_id
WHERE f.email = 'sousajenifer895@gmail.com';

-- ============================================
-- 🧪 PASSO 5: TESTAR LOGIN
-- ============================================
/*
Após executar os passos acima:

1. Acesse a tela de login do sistema

2. Use as credenciais:
   Email: sousajenifer895@gmail.com
   Senha: 123456 (ou a que você definiu)

3. ✅ Deve fazer login com sucesso

4. ✅ Atualizar página → Deve permanecer logada

5. ✅ Editar permissões da função → Deve atualizar em tempo real

Se tudo funcionar, a Jennifer está migrada! 🎉
*/

-- ============================================
-- 📊 BONUS: LISTAR TODOS FUNCIONÁRIOS SEM AUTH
-- ============================================
SELECT 
  '⚠️  OUTROS FUNCIONÁRIOS QUE PRECISAM MIGRAÇÃO' as alerta,
  f.id as funcionario_id,
  f.nome,
  f.email,
  fc.nome as funcao,
  f.status
FROM funcionarios f
LEFT JOIN funcoes fc ON fc.id = f.funcao_id
WHERE f.user_id IS NULL
  AND f.tipo_admin IS NULL  -- Apenas funcionários (não admins)
  AND f.status = 'ativo'
ORDER BY f.created_at DESC;

-- ============================================
-- 📝 RESUMO DO PROCESSO
-- ============================================
/*
✅ O QUE ESTE SCRIPT FAZ:
   1. Mostra dados atuais da Jennifer
   2. Fornece instruções para criar conta Auth
   3. Vincula user_id ao funcionário
   4. Verifica resultado final
   5. Lista outros funcionários que precisam migração

✅ APÓS A MIGRAÇÃO:
   - Jennifer terá conta própria no Supabase Auth
   - Sessão persiste entre reloads (cookies httpOnly)
   - Não usa localStorage (multi-tenant seguro)
   - Permissões editáveis em tempo real
   - RLS funcionará corretamente

✅ PARA CRIAR NOVOS FUNCIONÁRIOS:
   Use o serviço TypeScript: funcionarioAuthService.ts
   Ou execute: SISTEMA_FUNCIONARIOS_AUTH_COMPLETO.sql
   
🎯 DOCUMENTAÇÃO COMPLETA:
   Leia: SISTEMA_FUNCIONARIOS_AUTH_GUIA.md
*/
