-- =============================================
-- REVERTER: Restaurar endereços perdidos
-- =============================================

-- Infelizmente os endereços de CRISTIANO LUIZ e marcos junior foram perdidos
-- Precisamos restaurá-los manualmente se houver backup

-- Para JEAN e marco, está correto: eles têm os campos separados
-- então não precisam do campo endereco duplicado

-- Verificar quais clientes ficaram sem NADA
SELECT 
    id,
    nome,
    endereco,
    rua,
    numero,
    cidade,
    estado,
    cep
FROM clientes
WHERE endereco IS NULL 
  AND rua IS NULL 
  AND numero IS NULL 
  AND cidade IS NULL 
  AND estado IS NULL 
  AND cep IS NULL
ORDER BY nome;

-- Se houver clientes sem nenhum endereço, você precisará:
-- 1. Buscar o endereço correto
-- 2. Atualizar manualmente com UPDATE
