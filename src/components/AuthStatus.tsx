import React, { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

interface SupabaseUser {
  id: string
  email?: string
  created_at: string
  updated_at?: string
}

const AuthStatus: React.FC = () => {
  const [user, setUser] = useState<SupabaseUser | null>(null)
  const [loading, setLoading] = useState(true)
  const [sessionInfo, setSessionInfo] = useState<any>(null)
  const [testResult, setTestResult] = useState<string>('')

  // Testar getCurrentUser igual ao useProducts
  const testGetCurrentUser = async () => {
    try {
      const { data: { user }, error } = await supabase.auth.getUser()
      if (error || !user) {
        setTestResult('❌ Usuário não autenticado: ' + (error?.message || 'Sem usuário'))
        return
      }
      setTestResult('✅ getCurrentUser retornou: ' + user.id + ' (' + user.email + ')')
      console.log('🧪 Test getCurrentUser:', user)
    } catch (error: any) {
      setTestResult('💥 Erro: ' + error.message)
    }
  }

  useEffect(() => {
    const checkAuth = async () => {
      try {
        // Verificar usuário atual
        const { data: { user }, error } = await supabase.auth.getUser()
        console.log('👤 User from getUser():', user)
        console.log('🆔 User ID detectado:', user?.id)
        console.log('📧 Email detectado:', user?.email)
        
        if (error) {
          console.error('❌ Erro ao buscar usuário:', error)
        }

        setUser(user)

        // Verificar sessão atual
        const { data: { session }, error: sessionError } = await supabase.auth.getSession()
        console.log('🔒 Session info:', session)
        console.log('🔒 Session user ID:', session?.user?.id)
        console.log('🔒 Session user email:', session?.user?.email)
        
        if (sessionError) {
          console.error('❌ Erro ao buscar sessão:', sessionError)
        }

        setSessionInfo(session)
      } catch (error) {
        console.error('❌ Erro geral de autenticação:', error)
      } finally {
        setLoading(false)
      }
    }

    checkAuth()

    // Listener para mudanças de autenticação
    const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
      console.log('🔄 Auth state changed:', event, session)
      console.log('🔄 New user ID:', session?.user?.id)
      console.log('🔄 New user email:', session?.user?.email)
      setUser(session?.user || null)
      setSessionInfo(session)
    })

    return () => subscription.unsubscribe()
  }, [])

  if (loading) {
    return (
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4">
        <div className="text-blue-800">🔄 Verificando autenticação...</div>
      </div>
    )
  }

  return (
    <div className="bg-gray-50 border border-gray-200 rounded-lg p-4 mb-4">
      <h3 className="font-semibold mb-3 text-gray-800">📋 Status de Autenticação</h3>
      
      <div className="space-y-2 text-sm">
        <div>
          <strong>👤 Usuário Logado:</strong> {user ? (
            <span className="text-green-600">
              {user.email} (ID: {user.id})
            </span>
          ) : (
            <span className="text-red-600">❌ Nenhum usuário logado</span>
          )}
        </div>

        {user && (
          <>
            <div>
              <strong>🆔 User ID:</strong> 
              <code className="bg-gray-100 px-1 rounded text-xs ml-1">
                {user.id}
              </code>
            </div>

            <div>
              <strong>📧 Email:</strong> {user.email}
            </div>

            <div>
              <strong>📅 Criado em:</strong> {new Date(user.created_at).toLocaleString('pt-BR')}
            </div>

            <div>
              <strong>🔄 Última atualização:</strong> {new Date(user.updated_at || user.created_at).toLocaleString('pt-BR')}
            </div>
          </>
        )}

        {sessionInfo && (
          <div>
            <strong>⏰ Sessão expira em:</strong> {new Date(sessionInfo.expires_at * 1000).toLocaleString('pt-BR')}
          </div>
        )}

        <div className="mt-4 p-3 bg-yellow-50 border border-yellow-200 rounded">
          <div className="text-yellow-800 font-medium mb-1">🎯 UUID Esperado:</div>
          <code className="text-xs bg-yellow-100 px-1 rounded">
            f7fdf4cf-7101-45ab-86db-5248a7ac58c1
          </code>
          <div className="text-xs text-yellow-700 mt-1">
            (assistenciaallimport10@gmail.com)
          </div>
        </div>

        <div className="mt-4 p-3 bg-blue-50 border border-blue-200 rounded">
          <button 
            onClick={testGetCurrentUser}
            className="px-3 py-1 bg-blue-500 text-white text-xs rounded hover:bg-blue-600"
          >
            🧪 Testar getCurrentUser()
          </button>
          {testResult && (
            <div className="mt-2 text-xs">{testResult}</div>
          )}
        </div>

        {user && user.id !== 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' && (
          <div className="mt-2 p-3 bg-red-50 border border-red-200 rounded">
            <div className="text-red-800 font-medium">⚠️ UUID Diferente!</div>
            <div className="text-xs text-red-700 mt-1">
              O usuário logado tem UUID diferente do esperado. Isso pode explicar por que os produtos não aparecem.
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default AuthStatus
