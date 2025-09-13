import { ArrowLeft, Edit3, Phone, Mail, User, FileText, MapPin } from 'lucide-react'
import type { Cliente } from '../../types/cliente'
import { formatarCpfCnpj, formatarTelefone } from '../../utils/formatacao'

interface ClienteViewProps {
  cliente: Cliente
  onEdit: (cliente: Cliente) => void
  onBack: () => void
}

export function ClienteView({ cliente, onEdit, onBack }: ClienteViewProps) {
  return (
    <div className="max-w-4xl mx-auto">
      {/* Header com botões de ação */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
        <div className="px-6 py-4 border-b border-gray-200">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                onClick={onBack}
                className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
              >
                <ArrowLeft className="w-5 h-5" />
              </button>
              <div>
                <h1 className="text-xl font-bold text-gray-900">Visualizar Cliente</h1>
                <p className="text-sm text-gray-600">Informações de contato do cliente</p>
              </div>
            </div>
            <button
              onClick={() => onEdit(cliente)}
              className="flex items-center space-x-2 px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors"
            >
              <Edit3 className="w-4 h-4" />
              <span>Editar Cliente</span>
            </button>
          </div>
        </div>
      </div>

      {/* Informações do Cliente */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        <div className="px-6 py-6">
          {/* Nome e Documento */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div className="space-y-2">
              <div className="flex items-center space-x-2 text-gray-600">
                <User className="w-4 h-4" />
                <label className="text-sm font-medium">Nome</label>
              </div>
              <p className="text-lg font-semibold text-gray-900">
                {cliente.nome || 'Não informado'}
              </p>
            </div>

            <div className="space-y-2">
              <div className="flex items-center space-x-2 text-gray-600">
                <FileText className="w-4 h-4" />
                <label className="text-sm font-medium">CPF/CNPJ</label>
              </div>
              <p className="text-lg font-semibold text-gray-900">
                {cliente.cpf_cnpj ? formatarCpfCnpj(cliente.cpf_cnpj) : 'Não informado'}
              </p>
            </div>
          </div>

          {/* Linha separadora */}
          <div className="border-t border-gray-200 my-6"></div>

          {/* Informações de Contato */}
          <div className="space-y-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Informações de Contato</h3>
            
            {/* Telefone e Email */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <div className="flex items-center space-x-2 text-gray-600">
                  <Phone className="w-4 h-4" />
                  <label className="text-sm font-medium">Telefone</label>
                </div>
                <p className="text-base text-gray-900">
                  {cliente.telefone ? formatarTelefone(cliente.telefone) : 'Não informado'}
                </p>
              </div>

              <div className="space-y-2">
                <div className="flex items-center space-x-2 text-gray-600">
                  <Mail className="w-4 h-4" />
                  <label className="text-sm font-medium">E-mail</label>
                </div>
                <p className="text-base text-gray-900">
                  {cliente.email || 'Não informado'}
                </p>
              </div>
            </div>

            {/* Endereço - Apenas exibição básica */}
            <div className="space-y-2">
              <div className="flex items-center space-x-2 text-gray-600">
                <MapPin className="w-4 h-4" />
                <label className="text-sm font-medium">Endereço</label>
              </div>
              <div className="text-base text-gray-900">
                {cliente.endereco || cliente.logradouro ? (
                  <div className="space-y-1">
                    {cliente.endereco && <p>{cliente.endereco}</p>}
                    {cliente.logradouro && (
                      <p>
                        {[cliente.tipo_logradouro, cliente.logradouro, cliente.numero].filter(Boolean).join(' ')}
                        {cliente.complemento && `, ${cliente.complemento}`}
                      </p>
                    )}
                    {cliente.bairro && <p>{cliente.bairro}</p>}
                    {(cliente.cidade || cliente.estado || cliente.cep) && (
                      <p>
                        {[cliente.cidade, cliente.estado, cliente.cep].filter(Boolean).join(', ')}
                      </p>
                    )}
                  </div>
                ) : (
                  <p>Não informado</p>
                )}
              </div>
            </div>
          </div>

          {/* Informações adicionais se existirem */}
          {cliente.observacoes && (
            <>
              <div className="border-t border-gray-200 my-6"></div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-gray-600">Observações</label>
                <p className="text-base text-gray-900 bg-gray-50 p-3 rounded-lg">
                  {cliente.observacoes}
                </p>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  )
}