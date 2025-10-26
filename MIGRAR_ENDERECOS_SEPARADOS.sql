-- =============================================
-- MIGRAR ENDEREÇOS PARA CAMPOS SEPARADOS
-- =============================================

-- Exemplo: "Rua 10, nº 704, Guaíra, SP, CEP: 14790-025"

-- OPÇÃO 1: Para clientes com endereço completo mas campos vazios
-- Deixar como está por enquanto - usuário pode editar manualmente

-- OPÇÃO 2: Limpar duplicação (cidade/estado/cep que estão em endereco E nos campos)
-- Para "marco aurélio becari" e "JEAN JUNIOR RIBEIRO"
-- Eles têm: endereco = "guaíra - sp, CEP: 14790000" 
-- E também: cidade=guaíra, estado=sp, cep=14790000

-- Vamos limpar o campo endereco quando os campos separados existem
UPDATE clientes
SET endereco = NULL
WHERE (cidade IS NOT NULL OR estado IS NOT NULL OR cep IS NOT NULL OR rua IS NOT NULL OR numero IS NOT NULL);

SELECT 'Endereços duplicados limpos!' as status;

-- Verificar resultado
SELECT 
    nome,
    endereco,
    rua,
    numero,
    cidade,
    estado,
    cep
FROM clientes
WHERE nome ILIKE '%cristiano%'
   OR nome ILIKE '%marco%'
   OR nome ILIKE '%jean%'
ORDER BY nome;
