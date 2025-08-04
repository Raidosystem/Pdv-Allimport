import { supabase } from '../lib/supabase';

export interface AuthError {
  type: 'config' | 'connection' | 'authentication' | 'database' | 'unknown';
  message: string;
  userMessage: string;
  solutions: string[];
}

export async function detectAuthProblems(): Promise<AuthError[]> {
  const errors: AuthError[] = [];

  // 1. Verificar configuração
  const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
  const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

  if (!supabaseUrl || !supabaseKey || supabaseUrl === 'your_supabase_project_url') {
    errors.push({
      type: 'config',
      message: 'Variáveis de ambiente não configuradas',
      userMessage: 'Configuração do Supabase não encontrada',
      solutions: [
        'Configure VITE_SUPABASE_URL no arquivo .env',
        'Configure VITE_SUPABASE_ANON_KEY no arquivo .env',
        'Reinicie o servidor de desenvolvimento'
      ]
    });
    return errors; // Se não tem config, não pode testar mais nada
  }

  // 2. Testar conexão
  try {
    const { error: connectionError } = await supabase
      .from('_test_connection')
      .select('*')
      .limit(1);

    if (connectionError && connectionError.code !== 'PGRST116') {
      errors.push({
        type: 'connection',
        message: `Erro de conexão: ${connectionError.message}`,
        userMessage: 'Não foi possível conectar ao Supabase',
        solutions: [
          'Verifique sua conexão com a internet',
          'Confirme se a URL do Supabase está correta',
          'Verifique se a API Key não expirou'
        ]
      });
    }
  } catch (error) {
    errors.push({
      type: 'connection',
      message: `Erro de rede: ${error}`,
      userMessage: 'Falha na conexão com o servidor',
      solutions: [
        'Verifique sua conexão com a internet',
        'Tente recarregar a página',
        'Aguarde alguns minutos e tente novamente'
      ]
    });
  }

  // 3. Verificar estado de autenticação
  try {
    const { data: { user }, error: authError } = await supabase.auth.getUser();

    if (authError) {
      errors.push({
        type: 'authentication',
        message: `Erro de autenticação: ${authError.message}`,
        userMessage: 'Problema com o sistema de autenticação',
        solutions: [
          'Tente fazer login novamente',
          'Limpe os cookies do navegador',
          'Verifique suas credenciais de acesso'
        ]
      });
    } else if (!user) {
      // Usuário não logado, mas isso é normal
    }
  } catch (error) {
    errors.push({
      type: 'authentication',
      message: `Erro ao verificar usuário: ${error}`,
      userMessage: 'Falha na verificação de autenticação',
      solutions: [
        'Recarregue a página',
        'Limpe o cache do navegador',
        'Tente fazer login novamente'
      ]
    });
  }

  // 4. Verificar acesso ao banco (só se estiver autenticado)
  try {
    const { data: { user } } = await supabase.auth.getUser();
    
    if (user) {
      const { error: dbError } = await supabase
        .from('categories')
        .select('id')
        .limit(1);

      if (dbError) {
        errors.push({
          type: 'database',
          message: `Erro no banco: ${dbError.message}`,
          userMessage: 'Problema com as tabelas do banco de dados',
          solutions: [
            'Execute o script script-completo-para-supabase.sql no Supabase',
            'Verifique se as tabelas foram criadas corretamente',
            'Confirme as permissões de acesso às tabelas'
          ]
        });
      }
    }
  } catch (error) {
    errors.push({
      type: 'database',
      message: `Erro ao acessar banco: ${error}`,
      userMessage: 'Não foi possível acessar o banco de dados',
      solutions: [
        'Execute o script de criação de tabelas',
        'Verifique as configurações do Supabase',
        'Confirme se o projeto está ativo'
      ]
    });
  }

  return errors;
}

export function getErrorIcon(type: AuthError['type']): string {
  switch (type) {
    case 'config':
      return '⚙️';
    case 'connection':
      return '🌐';
    case 'authentication':
      return '🔐';
    case 'database':
      return '🗄️';
    default:
      return '❓';
  }
}

export function getErrorColor(type: AuthError['type']): string {
  switch (type) {
    case 'config':
      return 'red';
    case 'connection':
      return 'orange';
    case 'authentication':
      return 'yellow';
    case 'database':
      return 'blue';
    default:
      return 'gray';
  }
}

export async function autoFixCommonProblems(): Promise<{ fixed: boolean; message: string }> {
  try {
    // Verificar se há problemas que podem ser corrigidos automaticamente
    const { data: { user } } = await supabase.auth.getUser();
    
    if (!user) {
      return {
        fixed: false,
        message: 'Usuário não está autenticado. Faça login para continuar.'
      };
    }

    return {
      fixed: false,
      message: 'Nenhum problema foi identificado para correção automática'
    };
  } catch (error) {
    return {
      fixed: false,
      message: `Erro ao verificar problemas: ${error}`
    };
  }
}
