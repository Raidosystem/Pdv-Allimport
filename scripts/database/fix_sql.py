import re

input_file = r"c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA.sql"
output_file = r"c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA-FINAL.sql"
user_id = "f7fdf4cf-7101-45ab-86db-5248a7ac58c1"

# Ler arquivo
with open(input_file, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Corrigir tipos Física -> fisica e Jurídica -> juridica
content = content.replace("'Física',", "'fisica',")
content = content.replace("'Jurídica',", "'juridica',")

# 2. Adicionar user_id nas colunas onde não existe
# Pattern: id, empresa_id, nome  (sem user_id)
pattern1 = r'INSERT INTO clientes \(\n  id, empresa_id, nome,'
replacement1 = f'INSERT INTO clientes (\n  id, user_id, empresa_id, nome,'
content = re.sub(pattern1, replacement1, content)

# 3. Adicionar user_id nos VALUES onde não existe
# Pattern: UUID seguido de empresa_id diretamente
pattern2 = r"VALUES \(\n  '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})',\n  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',\n  '([^']+)',"
replacement2 = f"VALUES (\n  '\\1',\n  '{user_id}',\n  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',\n  '\\2',"
content = re.sub(pattern2, replacement2, content)

# Salvar
with open(output_file, 'w', encoding='utf-8') as f:
    f.write(content)

print(f"✅ Arquivo corrigido salvo em: {output_file}")
print("✅ Tipos corrigidos: Física -> fisica")
print("✅ Coluna user_id adicionada em todos os INSERTs")
