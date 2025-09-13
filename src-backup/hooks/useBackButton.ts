import { useNavigate } from 'react-router-dom'

export function useBackButton() {
  const navigate = useNavigate()

  const goBack = () => {
    // Verifica se há histórico para voltar
    if (window.history.length > 1) {
      navigate(-1)
    } else {
      // Se não há histórico, volta para o dashboard
      navigate('/dashboard')
    }
  }

  return { goBack }
}
