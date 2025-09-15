import { useNavigate } from 'react-router-dom'
import { ClienteFormUnificado } from '../../components/cliente/ClienteFormUnificado'

export function NovoClientePage({ empresaId, onSuccess, onCancel }: NovoClientePageProps) {
  return (
    <ClienteFormUnificado
      empresaId={empresaId}
      titulo="Novo Cliente"
      onSuccess={onSuccess}
      onCancel={onCancel}
      showHeader={true}
      isModal={false}
      showUseClientButton={false}
    />
  )
}

interface NovoClientePageProps {
  empresaId?: string
  onSuccess?: (cliente: any) => void
  onCancel?: () => void
}

export default function NovoCliente() {
  const navigate = useNavigate()

  const handleSuccess = () => {
    navigate('/clientes')
  }

  const handleCancel = () => {
    navigate('/clientes')
  }

  return (
    <ClienteFormUnificado
      titulo="Novo Cliente"
      onSuccess={handleSuccess}
      onCancel={handleCancel}
      showHeader={true}
      isModal={false}
      showToastOnSelect={true}
      showUseClientButton={false}
    />
  )
}