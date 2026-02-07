# 📸 COMO ADICIONAR FOTOS NOS PRODUTOS

## ✅ Sistema Configurado

O sistema agora permite adicionar fotos aos produtos que aparecerão automaticamente no **catálogo online** da sua loja!

## 🚀 Como Usar

### 1. **Execute o Script SQL no Supabase**

1. Abra o **SQL Editor** do Supabase
2. Cole e execute: `migrations/CRIAR_BUCKET_PRODUTOS_IMAGENS.sql`
3. Aguarde a mensagem de sucesso ✅

### 2. **Adicionar Foto ao Cadastrar Produto**

1. Acesse **Produtos** → **Novo Produto**
2. Preencha os dados normais (nome, preço, etc)
3. No campo **"Foto do Produto"**:
   - Clique na área tracejada
   - Ou arraste uma imagem
4. Aguarde o upload concluir
5. A foto aparecerá em miniatura
6. Clique em **Cadastrar**

### 3. **Adicionar Foto ao Editar Produto**

1. Na lista de produtos, clique em **Editar** (ícone de lápis)
2. Role até o campo **"Foto do Produto"**
3. Clique para enviar uma nova foto
4. Para remover a foto atual, clique no **X vermelho**
5. Clique em **Salvar**

## 📋 Especificações das Imagens

- **Formatos aceitos**: JPG, PNG, WEBP, GIF
- **Tamanho máximo**: 2MB por arquivo
- **Resolução recomendada**: 800x800px (quadrada)
- **Armazenamento**: Supabase Storage (seguro e rápido)

## 🌐 Onde as Fotos Aparecem

✅ **Catálogo Online** - Loja pública dos produtos
✅ **Lista de Produtos** - Visualização interna (futuramente)
✅ **Vendas** - Ao selecionar produtos (futuramente)

## 🔒 Segurança

- ✅ Upload protegido (apenas usuários autenticados)
- ✅ Imagens públicas (visíveis no catálogo online)
- ✅ Validação de tipo e tamanho de arquivo
- ✅ Armazenamento seguro no Supabase

## 💡 Dicas

1. **Fotos Quadradas**: Use imagens quadradas para melhor visualização
2. **Boa Iluminação**: Fotos com boa iluminação vendem mais
3. **Fundo Neutro**: Prefira fundos brancos ou neutros
4. **Compressão**: Comprima as imagens antes de enviar para carregar mais rápido

## 🎯 Próximos Passos

Após adicionar fotos nos produtos:

1. Configure sua **Loja Online** em Configurações
2. Ative a loja
3. Compartilhe o link com seus clientes
4. As fotos aparecerão automaticamente no catálogo!

---

**Desenvolvido por Sistema RaVal PDV** 🚀
