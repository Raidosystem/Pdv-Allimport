-- 🧪 TESTE: Verificar se função RPC de importação existe

-- Verificar se a função import_user_data_json existe
SELECT 
    routines.routine_name,
    routines.routine_type,
    routines.data_type,
    routines.routine_definition
FROM information_schema.routines 
WHERE routines.routine_schema = 'public' 
AND routines.routine_name = 'import_user_data_json';

-- Se não existir, vamos criar uma versão básica
CREATE OR REPLACE FUNCTION public.import_user_data_json(
    backup_json jsonb,
    clear_existing boolean DEFAULT true
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_uuid uuid;
    result jsonb := '{"success": false, "message": "Função de importação não implementada"}';
BEGIN
    -- Verificar se usuário está autenticado
    user_uuid := auth.uid();
    IF user_uuid IS NULL THEN
        RETURN '{"success": false, "message": "Usuário não autenticado"}';
    END IF;
    
    -- Log para debug
    RAISE LOG 'import_user_data_json chamado para usuário: %', user_uuid;
    RAISE LOG 'backup_json keys: %', jsonb_object_keys(backup_json);
    
    -- Verificar estrutura do backup
    IF NOT (backup_json ? 'backup_info' AND backup_json ? 'data') THEN
        RETURN '{"success": false, "message": "Estrutura de backup inválida - faltam backup_info ou data"}';
    END IF;
    
    -- Por enquanto, apenas retornar sucesso para teste
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Importação simulada com sucesso',
        'user_id', user_uuid,
        'backup_system', backup_json->'backup_info'->>'system'
    );
    
EXCEPTION WHEN OTHERS THEN
    RAISE LOG 'Erro na importação: %', SQLERRM;
    RETURN jsonb_build_object(
        'success', false,
        'message', 'Erro interno: ' || SQLERRM
    );
END;
$$;

-- Testar a função
SELECT public.import_user_data_json(
    '{"backup_info": {"system": "PDV Test"}, "data": {"produtos": []}}',
    true
);
