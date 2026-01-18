# 📊 EXTRAÇÃO DE DADOS POR EMPRESA DO BACKUP SUPABASE
# Extrai dados de uma empresa específica do backup SQL

import re
from pathlib import Path
from datetime import datetime

backup_file = Path('./backups/supabase-backup-15-01-2026.backup')

print("🔍 EXTRAÇÃO DE DADOS POR EMPRESA")
print("=" * 70)
print()

# Ler arquivo de backup
with open(backup_file, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# Extrair dados da tabela empresas
print("📊 EMPRESAS ENCONTRADAS NO BACKUP:")
print("-" * 70)

empresas_match = re.search(
    r'COPY public\.empresas.*?FROM stdin;\n(.*?)\n\\\.', 
    content, 
    re.DOTALL
)

empresas = []
if empresas_match:
    linhas = empresas_match.group(1).strip().split('\n')
    
    for i, linha in enumerate(linhas, 1):
        if linha and not linha.startswith('--'):
            # Parse linha (TSV format)
            campos = linha.split('\t')
            if len(campos) >= 3:
                empresa_id = campos[0]
                user_id = campos[1]
                nome = campos[2] if len(campos) > 2 else 'Sem nome'
                email = campos[6] if len(campos) > 6 else 'Sem email'
                
                empresas.append({
                    'numero': i,
                    'id': empresa_id,
                    'user_id': user_id,
                    'nome': nome,
                    'email': email,
                    'linha': linha
                })
                
                print(f"{i}. {nome}")
                print(f"   ID: {empresa_id[:8]}...")
                print(f"   User ID: {user_id[:8]}...")
                print(f"   Email: {email}")
                print()

print("=" * 70)
print(f"✅ Total: {len(empresas)} empresas")
print()

# Salvar lista de empresas
lista_file = Path('./backups/lista-empresas-backup.txt')
with open(lista_file, 'w', encoding='utf-8') as f:
    f.write("EMPRESAS NO BACKUP (15/01/2026)\n")
    f.write("=" * 70 + "\n\n")
    for emp in empresas:
        f.write(f"{emp['numero']}. {emp['nome']}\n")
        f.write(f"   ID Empresa: {emp['id']}\n")
        f.write(f"   User ID: {emp['user_id']}\n")
        f.write(f"   Email: {emp['email']}\n")
        f.write("\n")

print(f"📝 Lista salva em: {lista_file}")
print()
print("=" * 70)
print("🎯 COMO RESTAURAR UMA EMPRESA ESPECÍFICA:")
print("=" * 70)
print("""
MÉTODO 1 - Extração Manual (Recomendado):

1. Identifique o user_id da empresa desejada acima
2. Crie um novo script SQL com:
   a) Estrutura das tabelas (DDL)
   b) Dados filtrados por user_id (DML)
   
3. Execute no Supabase apenas os INSERTs dessa empresa

Exemplo:
INSERT INTO produtos (id, nome, preco, user_id, ...)
SELECT * FROM backup WHERE user_id = 'EMPRESA_USER_ID';


MÉTODO 2 - Restauração Completa + Limpeza:

⚠️ CUIDADO: Isso afeta TODOS os clientes!

1. Faça backup do estado atual primeiro
2. Restaure backup completo via Supabase Dashboard
3. DELETE manualmente dados de empresas indesejadas


MÉTODO 3 - Usar Sistema de Backup Isolado (MELHOR):

✅ Use os scripts que criamos:
   - backup-por-empresa-http.py
   - restaurar-empresa-http.py
   
Vantagens:
   ✅ Backup separado por empresa
   ✅ Restauração seletiva
   ✅ Não afeta outros clientes
   ✅ Mais rápido e seguro


💡 RECOMENDAÇÃO:

Este backup SQL é útil para:
- Ver quais empresas existiam em 15/01/2026
- Recuperação de desastre total
- Análise de dados históricos

Para restauração seletiva diária:
- Use o sistema de backup isolado por empresa
""")

# Função para extrair dados de uma empresa
def extrair_empresa(user_id_busca: str):
    """Extrai todos os dados de uma empresa específica"""
    
    print(f"\n🔍 Extraindo dados da empresa {user_id_busca[:8]}...")
    
    # Tabelas com user_id
    tabelas = [
        'empresas', 'produtos', 'clientes', 'vendas', 
        'vendas_itens', 'caixa', 'categorias', 'fornecedores',
        'funcionarios', 'ordens_servico'
    ]
    
    dados_empresa = {
        'user_id': user_id_busca,
        'data_extracao': datetime.now().isoformat(),
        'tabelas': {}
    }
    
    for tabela in tabelas:
        # Procurar dados da tabela
        pattern = rf'COPY public\.{tabela}.*?FROM stdin;\n(.*?)\n\\.'
        match = re.search(pattern, content, re.DOTALL)
        
        if match:
            linhas = match.group(1).strip().split('\n')
            registros_empresa = []
            
            for linha in linhas:
                if user_id_busca in linha:
                    registros_empresa.append(linha)
            
            dados_empresa['tabelas'][tabela] = registros_empresa
            print(f"   ✅ {tabela}: {len(registros_empresa)} registros")
    
    # Salvar extração
    output_file = Path(f'./backups/empresa_{user_id_busca[:8]}_extracao.sql')
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"-- EXTRAÇÃO DE DADOS DA EMPRESA\n")
        f.write(f"-- User ID: {user_id_busca}\n")
        f.write(f"-- Data: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        
        for tabela, registros in dados_empresa['tabelas'].items():
            if registros:
                f.write(f"\n-- {tabela} ({len(registros)} registros)\n")
                for reg in registros:
                    f.write(f"-- {reg[:100]}...\n")
    
    print(f"\n✅ Extração salva em: {output_file}")
    return dados_empresa

print("\n💬 Quer extrair dados de uma empresa específica?")
print("   Execute: extrair_empresa('user_id_completo')")
