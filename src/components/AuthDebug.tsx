// Debug component para verificar autenticação
import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'

export function AuthDebug() {
  const [user, setUser] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Verificar se há usuário logado
    supabase.auth.getUser().then(({ data: { user } }) => {
      setUser(user)
      setLoading(false)
    })

    // Escutar mudanças de autenticação
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setUser(session?.user ?? null)
        setLoading(false)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  const signIn = async () => {
    const { error } = await supabase.auth.signInWithPassword({
      email: 'admin@allimport.com',
      password: '@qw12aszx##'
    })
    
    if (error) {
      console.error('Erro no login:', error)
      alert(`Erro no login: ${error.message}`)
    }
  }

  const signUp = async () => {
    const { error } = await supabase.auth.signUp({
      email: 'admin@allimport.com',
      password: '@qw12aszx##'
    })
    
    if (error) {
      console.error('Erro no cadastro:', error)
      alert(`Erro no cadastro: ${error.message}`)
    } else {
      alert('Usuário criado! Verifique seu email.')
    }
  }

  const signOut = async () => {
    await supabase.auth.signOut()
  }

  if (loading) {
    return <div>Carregando autenticação...</div>
  }

  return (
    <div style={{ 
      position: 'fixed', 
      top: 10, 
      right: 10, 
      background: 'white', 
      padding: 10, 
      border: '1px solid #ccc',
      borderRadius: 5,
      zIndex: 9999
    }}>
      <h4>Auth Debug</h4>
      {user ? (
        <div>
          <p>✅ Logado: {user.email}</p>
          <p>ID: {user.id}</p>
          <button onClick={signOut}>Logout</button>
        </div>
      ) : (
        <div>
          <p>❌ Não logado</p>
          <button onClick={signIn}>Login</button>
          <button onClick={signUp}>Criar Usuário</button>
        </div>
      )}
    </div>
  )
}
