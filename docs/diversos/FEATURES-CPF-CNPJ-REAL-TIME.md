# 🚀 Busca por CPF/CNPJ em Tempo Real

## ✨ Nova Funcionalidade Implementada

### 📋 O que foi adicionado:

1. **Detecção Automática de Duplicatas**
   - Busca em tempo real conforme o usuário digita
   - Verificação a partir de 8 dígitos digitados
   - Debounce de 500ms para otimizar performance

2. **Indicadores Visuais**
   - 🔵 Campo azul com spinner durante verificação
   - 🟠 Campo laranja quando duplicata é encontrada
   - ⚡ Notificação "Cliente encontrado automaticamente"

3. **Busca Inteligente**
   - Busca parcial: mostra clientes que começam com os dígitos digitados
   - Busca exata: quando CPF (11 dígitos) ou CNPJ (14 dígitos) estão completos
   - Suporte a formatação automática

## 🔧 Como Funciona

### Fluxo da Verificação:
```
Usuário digita → Debounce 500ms → Busca no banco → Verifica duplicata → Mostra resultado
```

### Tipos de Busca:
- **8-10 dígitos**: Busca parcial (encontra CPFs que começam com os dígitos)
- **11 dígitos**: Busca exata de CPF
- **12-13 dígitos**: Busca parcial (encontra CNPJs que começam com os dígitos)
- **14 dígitos**: Busca exata de CNPJ

## 📊 Dados de Teste Disponíveis

O sistema possui **140 clientes** com CPF/CNPJ no backup, incluindo:

1. ANTONIO CLAUDIO FIGUEIRA - 33393732803
2. EDVANIA DA SILVA - 37511773885
3. SAULO DE TARSO - 32870183968
4. ALINE CRISTINA CAMARGO - 37784514808
5. WINDERSON RODRIGUES LELIS - 23510133870

## 🎯 Como Testar

1. Acesse uma **Ordem de Serviço** ou **Nova Venda**
2. Clique em **"Cadastrar novo cliente"**
3. No campo **CPF/CNPJ**, comece digitando:
   - `333937328` (para encontrar ANTONIO CLAUDIO FIGUEIRA)
   - `375117738` (para encontrar EDVANIA DA SILVA)
   - `328701839` (para encontrar SAULO DE TARSO)

### ✅ Comportamento Esperado:
- Após 8 dígitos: Campo fica azul com spinner
- Cliente encontrado: Campo fica laranja com aviso
- Opções: "Usar este cliente" ou "Editar dados"

## 🔍 Logs de Debug

O sistema gera logs no console para acompanhar:
```
🔍 Verificando duplicata em tempo real para: 333.937.328
📋 Clientes encontrados na busca: 5
🎯 Match parcial encontrado: ANTONIO CLAUDIO FIGUEIRA | 33393732803
⚠️ Cliente duplicado detectado: ANTONIO CLAUDIO FIGUEIRA
```

## 🚀 Performance

- **Debounce**: 500ms para evitar muitas requisições
- **Busca otimizada**: Apenas após 8 dígitos válidos
- **Cache**: Resultados são mantidos enquanto o formulário está aberto
- **Feedback visual**: Usuário sabe quando está buscando

## 💡 Benefícios

✅ **Prevenção de duplicatas** - Evita cadastros duplicados automaticamente
✅ **Experiência fluida** - Detecção instantânea sem botões extras
✅ **Feedback claro** - Usuário sabe imediatamente se cliente existe
✅ **Ação rápida** - Pode usar cliente existente ou editá-lo na hora
✅ **Performance otimizada** - Busca inteligente com debounce

## 📱 Interface

### Estados do Campo CPF/CNPJ:
- **Normal**: Campo branco padrão
- **Verificando**: Campo azul claro com spinner
- **Duplicata encontrada**: Campo laranja com aviso detalhado
- **Erro**: Campo vermelho com mensagem de erro

### Painel de Duplicata:
```
⚡ Cliente encontrado automaticamente
Detectamos um cliente com este CPF:

┌─────────────────────────────────┐
│ ANTONIO CLAUDIO FIGUEIRA        │
│ (11) 99999-9999 • email@test    │
└─────────────────────────────────┘

[Usar este cliente] [Editar dados]
```

Esta funcionalidade torna o cadastro de clientes muito mais eficiente e evita duplicações no sistema!