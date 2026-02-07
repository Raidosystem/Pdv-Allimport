# 🪣 Como Criar o Bucket para Logos

## ❌ Erro Atual
```
Bucket not found
```

Isso significa que o bucket `empresa-assets` não existe no Supabase Storage.

## ✅ Solução - Executar no Supabase

### Passo 1: Acessar o SQL Editor
1. Vá em: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw
2. No menu lateral, clique em **"SQL Editor"**

### Passo 2: Executar o Script
1. Clique em **"+ New Query"**
2. Copie TODO o conteúdo do arquivo **`CRIAR_BUCKET_LOGOS.sql`**
3. Cole no editor
4. Clique em **"Run"** (ou Ctrl+Enter)

### Passo 3: Verificar
Você deve ver no resultado:

| id | name | public | file_size_limit | allowed_mime_types |
|----|------|--------|----------------|-------------------|
| empresa-assets | empresa-assets | true | 2097152 | {image/jpeg,image/jpg,image/png,image/gif,image/webp} |

## 🎯 O que será criado:

### Bucket `empresa-assets`
- **Público:** Sim (logos podem ser vistas por todos)
- **Limite:** 2MB por arquivo
- **Tipos permitidos:** JPG, PNG, GIF, WebP

### Políticas RLS
1. ✅ **Visualização pública** - Qualquer um pode ver as logos
2. ✅ **Upload restrito** - Usuários só podem fazer upload para sua própria pasta
3. ✅ **Atualização restrita** - Usuários só podem atualizar suas próprias logos
4. ✅ **Deleção restrita** - Usuários só podem deletar suas próprias logos

### Estrutura de Pastas
```
empresa-assets/
└── logos/
    └── {user_id}-{timestamp}.{ext}
```

Exemplo: `logos/c6864d69-a55c-4aca-8fe4-87841ac1084a-1760409001548.png`

## 🧪 Teste Após Execução

1. Recarregue a página do sistema (F5)
2. Vá em **"Configurações do Sistema"** → **"Dados da Empresa"**
3. Clique em **"Escolher arquivo"** em "Logo da Empresa"
4. Selecione uma imagem (PNG, JPG, GIF até 2MB)
5. O upload deve funcionar! ✨

## ⚠️ Alternativa: Criar Via Interface

Se preferir criar manualmente:

1. Vá em **Storage** no menu lateral do Supabase
2. Clique em **"Create a new bucket"**
3. Nome: `empresa-assets`
4. Marque **"Public bucket"**
5. Clique em **"Save"**
6. Depois execute apenas as políticas RLS do script SQL

Mas é **mais fácil e seguro** executar o script SQL completo! 🚀
