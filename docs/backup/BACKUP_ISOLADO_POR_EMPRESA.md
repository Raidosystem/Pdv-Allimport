# 🏢 Sistema de Backup Isolado por Empresa

## 🎯 Problema Resolvido

**ANTES**: Backup único salvava TODOS os clientes juntos
- ❌ Restaurar Cliente A = sobrescrever dados do Cliente B
- ❌ Cliente B acabou de inserir dados = perda de dados ao restaurar Cliente A
- ❌ Impossível restaurar apenas UMA empresa

**AGORA**: Backup isolado por empresa
- ✅ Cada empresa tem sua própria pasta de backup
- ✅ Restaurar Cliente A = NÃO afeta Cliente B
- ✅ Multi-tenancy seguro e eficiente

---

## 📁 Estrutura de Pastas

```
backups/
├── empresa_abc12345/           # Empresa 1
│   ├── user_approvals_20260116_182944.json
│   ├── produtos_20260116_182944.json
│   ├── clientes_20260116_182945.json
│   ├── vendas_20260116_182945.json
│   └── backup_metadata_20260116_182947.json
│
├── empresa_def67890/           # Empresa 2
│   ├── user_approvals_20260116_182950.json
│   ├── produtos_20260116_182950.json
│   └── backup_metadata_20260116_182952.json
│
└── empresa_ghi11223/           # Empresa 3
    └── ...
```

**Isolamento**: Cada pasta contém os dados de APENAS uma empresa (filtrados por `user_id`)

---

## 🚀 Como Usar

### 1️⃣ Pré-requisitos

**IMPORTANTE**: Para backup completo, você precisa da `SERVICE_ROLE_KEY`

1. Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/settings/api
2. Copie a chave `service_role` (secret)
3. Adicione no `.env`:

```env
# 🚨 CRÍTICO: Nunca commitar esta chave!
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 2️⃣ Fazer Backup de Todas as Empresas

```powershell
# Backup de TODAS as empresas (cada uma em sua pasta)
C:/Users/GrupoRaval/Desktop/Pdv-Allimport/.venv/Scripts/python.exe scripts/backup-por-empresa.py
```

**Resultado**:
```
🚀 Iniciando backup isolado por empresa...
📊 Total de empresas: 3

🏢 Empresa: Grupo Raval
   ✅ produtos: 819 registros
   ✅ clientes: 145 registros
   ✅ vendas: 89 registros
   ✅ Backup concluído: ./backups/empresa_abc12345/

🏢 Empresa: Loja X
   ✅ produtos: 230 registros
   ✅ clientes: 45 registros
   ✅ Backup concluído: ./backups/empresa_def67890/
```

### 3️⃣ Restaurar UMA Empresa Específica

```powershell
# Restauração interativa (menu)
C:/Users/GrupoRaval/Desktop/Pdv-Allimport/.venv/Scripts/python.exe scripts/restaurar-empresa.py
```

**Fluxo interativo**:

1. **Selecionar empresa**:
   ```
   🏢 EMPRESAS COM BACKUP DISPONÍVEL
   1. Grupo Raval (último backup: 2026-01-16 18:29)
   2. Loja X (último backup: 2026-01-16 18:30)
   
   Escolha a empresa: 1
   ```

2. **Selecionar tabelas**:
   ```
   📋 TABELAS DISPONÍVEIS
   0. [TODAS AS TABELAS]
   1. produtos (3 backups)
   2. clientes (3 backups)
   3. vendas (3 backups)
   
   Escolha as tabelas (ex: 1,3 ou 0 para todas): 0
   ```

3. **Confirmar**:
   ```
   ⚠️ CONFIRMAÇÃO
   Empresa: Grupo Raval
   Tabelas: produtos, clientes, vendas
   
   🚨 ATENÇÃO: Dados atuais serão sobrescritos!
   ✅ Apenas a empresa "Grupo Raval" será afetada
   ✅ Outras empresas NÃO serão afetadas
   
   Digite 'RESTAURAR' para confirmar: RESTAURAR
   ```

4. **Executar**:
   ```
   ✅ RESTAURAÇÃO CONCLUÍDA!
   Empresa: Grupo Raval
   Tabelas restauradas: 13
   Total de registros: 1.053
   
   ✅ Apenas a empresa Grupo Raval foi restaurada
   ✅ Outras empresas permanecem intactas
   ```

---

## 🔒 Segurança Multi-Tenancy

### Como funciona o isolamento?

1. **Cada tabela tem `user_id`**:
   ```sql
   SELECT * FROM produtos WHERE user_id = 'abc12345...';
   ```

2. **Backup filtra por `user_id`**:
   ```python
   supabase.from_('produtos').select('*').eq('user_id', empresa_user_id)
   ```

3. **Restauração valida `user_id`**:
   ```python
   # Verifica se dados pertencem ao user_id correto
   if dados[0]['user_id'] != empresa_user_id:
       print("⚠️ AVISO: Dados não correspondem!")
   ```

### Tabelas com isolamento por `user_id`:

- ✅ `user_approvals` - Dados do owner
- ✅ `empresas` - Dados da empresa
- ✅ `subscriptions` - Assinatura
- ✅ `produtos` - Produtos
- ✅ `clientes` - Clientes
- ✅ `vendas` - Vendas
- ✅ `vendas_itens` - Itens das vendas
- ✅ `caixa` - Movimentação de caixa
- ✅ `categorias` - Categorias
- ✅ `fornecedores` - Fornecedores
- ✅ `despesas` - Despesas
- ✅ `ordens_servico` - Ordens de serviço
- ✅ `funcionarios` - Funcionários

---

## 🔄 Backup Automático (Agendado)

### Windows Task Scheduler

Crie uma tarefa agendada para backup diário:

```powershell
# Executar às 3:00 AM diariamente
$action = New-ScheduledTaskAction -Execute "C:/Users/GrupoRaval/Desktop/Pdv-Allimport/.venv/Scripts/python.exe" -Argument "C:/Users/GrupoRaval/Desktop/Pdv-Allimport/scripts/backup-por-empresa.py"

$trigger = New-ScheduledTaskTrigger -Daily -At 3:00AM

$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -WakeToRun

Register-ScheduledTask -TaskName "PDV Backup Empresas" -Action $action -Trigger $trigger -Settings $settings -Description "Backup diário isolado por empresa"
```

---

## ⚠️ Avisos Importantes

### 🚨 SERVICE_ROLE_KEY

- **NUNCA COMMITAR** no Git
- **USAR APENAS LOCALMENTE** para backups
- Bypassa todas as políticas RLS
- `.gitignore` já protege `.env`

### 🔒 Proteção de Backups

- Pasta `backups/` está no `.gitignore`
- **Nunca commitar** backups no Git
- Contém dados sensíveis de clientes
- Armazenar em local seguro (HD externo, cloud privado)

### 📊 Complemento ao PITR do Supabase

Este sistema **complementa** o PITR do Supabase Pro:

| Recurso | PITR Supabase | Backup Local |
|---------|---------------|--------------|
| Automático | ✅ Sim | ⚠️ Precisa agendar |
| Isolado por empresa | ❌ Não | ✅ Sim |
| Restauração seletiva | ❌ Restaura tudo | ✅ Escolhe empresa/tabela |
| Retenção | 7 dias (Pro) | ♾️ Ilimitado |
| Offline | ❌ Não | ✅ Sim (arquivos JSON) |

**Recomendação**: Use AMBOS!
- PITR Supabase: Recuperação rápida de desastres
- Backup Local: Restauração seletiva por empresa

---

## 🆘 Troubleshooting

### ❌ Erro: "permission denied for table"

**Causa**: Usando `ANON_KEY` ao invés de `SERVICE_ROLE_KEY`

**Solução**:
1. Obtenha `SERVICE_ROLE_KEY` no dashboard Supabase
2. Adicione no `.env`
3. Execute novamente

### ❌ Erro: "No module named 'supabase'"

**Solução**:
```powershell
pip install supabase python-dotenv
```

### ❌ Erro: "Nenhuma empresa encontrada"

**Causa**: Tabela `empresas` vazia ou sem dados

**Solução**:
1. Verifique se existem empresas cadastradas
2. Confirme que SERVICE_ROLE_KEY está correta

---

## 📖 Comandos Rápidos

```powershell
# Backup de todas as empresas
C:/Users/GrupoRaval/Desktop/Pdv-Allimport/.venv/Scripts/python.exe scripts/backup-por-empresa.py

# Restaurar empresa (interativo)
C:/Users/GrupoRaval/Desktop/Pdv-Allimport/.venv/Scripts/python.exe scripts/restaurar-empresa.py

# Listar backups
ls backups/

# Ver detalhes de um backup
cat backups/empresa_abc12345/backup_metadata_*.json
```

---

## ✅ Vantagens do Sistema

1. **Multi-Tenancy Seguro**: Cada empresa isolada
2. **Restauração Seletiva**: Escolha empresa e tabelas
3. **Sem Interferência**: Restaurar Cliente A ≠ afetar Cliente B
4. **Auditoria**: Metadata rastreia cada backup
5. **Flexível**: JSON permite análise e migração
6. **Offline**: Funciona sem internet (após download)

---

🎉 **Sistema pronto para produção!** Faça backup regularmente e durma tranquilo! 💤
