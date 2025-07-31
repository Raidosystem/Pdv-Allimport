import { useEffect } from 'react'

export function DebugComponent() {
  useEffect(() => {
    console.log('=== PDV ALLIMPORT DEBUG ===')
    console.log('Environment:', import.meta.env.MODE)
    console.log('Supabase URL:', import.meta.env.VITE_SUPABASE_URL ? 'Configurada' : 'NÃO CONFIGURADA')
    console.log('Supabase Key:', import.meta.env.VITE_SUPABASE_ANON_KEY ? 'Configurada' : 'NÃO CONFIGURADA')
    console.log('App Name:', import.meta.env.VITE_APP_NAME)
    console.log('All env vars:', import.meta.env)
    console.log('=== END DEBUG ===')
  }, [])

  return (
    <div style={{ 
      position: 'fixed', 
      top: 0, 
      right: 0, 
      background: 'red', 
      color: 'white', 
      padding: '10px', 
      zIndex: 9999,
      fontSize: '12px'
    }}>
      DEBUG: ENV={import.meta.env.MODE}
    </div>
  )
}
