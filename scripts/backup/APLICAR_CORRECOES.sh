#!/bin/bash
# Script para aplicar correções no ClienteFormUnificado.tsx
# Execute este script ou aplique as mudanças manualmente

echo "=== CORREÇÕES PARA ClienteFormUnificado.tsx ==="
echo ""
echo "IMPORTANTE: Antes de aplicar, execute os scripts SQL no Supabase:"
echo "1. CORRIGIR_ERRO_406_EMPRESAS.sql"
echo "2. CORRIGIR_ERRO_400_CLIENTES.sql"
echo ""
echo "=== MUDANÇA 1: Atualizar Cliente (linhas 301-307) ==="
echo ""
echo "SUBSTITUIR:"
cat << 'EOF'
        // Atualizar cliente existente
        const { data, error } = await supabase
          .from('clientes')
          .update(clienteData)
          .eq('id', clienteParaAtualizar.id)
          .select()
          .single()
EOF

echo ""
echo "POR:"
cat << 'EOF'
        // Atualizar cliente existente usando função RPC segura
        const { data, error } = await supabase.rpc('atualizar_cliente_seguro', {
          p_cliente_id: clienteParaAtualizar.id,
          p_nome: clienteData.nome,
          p_cpf_cnpj: clienteData.cpf_cnpj,
          p_cpf_digits: clienteData.cpf_digits,
          p_email: clienteData.email,
          p_telefone: clienteData.telefone,
          p_rua: clienteData.rua,
          p_numero: clienteData.numero,
          p_cidade: clienteData.cidade,
          p_estado: clienteData.estado,
          p_cep: clienteData.cep,
          p_tipo: clienteData.tipo
        })
EOF

echo ""
echo "=== MUDANÇA 2: Criar Cliente (linhas 325-338) ==="
echo ""
echo "SUBSTITUIR:"
cat << 'EOF'
        const { data, error } = await supabase
          .from('clientes')
          .insert([clienteData])
          .select()
          .single()

        console.log('📊 [DEBUG] Resultado da inserção:', { data, error })

        if (error) {
          // Verificar se é erro de duplicação
          if (error.code === '23505') { // Unique violation
            toast.error('Este CPF já está cadastrado.')
            return
          }
EOF

echo ""
echo "POR:"
cat << 'EOF'
        const { data, error } = await supabase.rpc('criar_cliente_seguro', {
          p_nome: clienteData.nome,
          p_cpf_cnpj: clienteData.cpf_cnpj,
          p_cpf_digits: clienteData.cpf_digits,
          p_email: clienteData.email,
          p_telefone: clienteData.telefone,
          p_rua: clienteData.rua,
          p_numero: clienteData.numero,
          p_cidade: clienteData.cidade,
          p_estado: clienteData.estado,
          p_cep: clienteData.cep,
          p_empresa_id: clienteData.empresa_id,
          p_tipo: clienteData.tipo
        })

        console.log('📊 [DEBUG] Resultado da inserção:', { data, error })

        if (error) {
          // Verificar se é erro de duplicação
          if (error.message && error.message.includes('duplicate')) {
            toast.error('Este CPF já está cadastrado.')
            return
          }
EOF

echo ""
echo "=== FIM DAS CORREÇÕES ==="
echo ""
echo "Após aplicar as correções:"
echo "1. Salve o arquivo (Ctrl+S)"
echo "2. Verifique se não há erros de sintaxe"
echo "3. Teste criando um cliente"
echo ""
