-- Verificar se EDVANIA tem equipamentos agora

SELECT
  os.numero_os,
  os.marca,
  os.modelo,
  os.tipo,
  os.descricao_problema,
  os.data_entrada,
  os.status,
  c.nome as cliente_nome
FROM ordens_servico os
INNER JOIN clientes c ON os.cliente_id = c.id
WHERE c.cpf_cnpj = '37511773885'
ORDER BY os.data_entrada DESC;
