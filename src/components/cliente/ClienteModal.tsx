import { X, User, Phone, Mail, MapPin, FileText, Calendar, Building2 } from 'lucide-react'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'
import type { Cliente } from '../../types/cliente'

interface ClienteModalProps {
  cliente: Cliente
  onClose: () => void
  onEdit: () => void
}

export function ClienteModal({ cliente, onClose, onEdit }: ClienteModalProps) {
  const formatarTelefone = (telefone: string) => {
    if (!telefone) return ''
    const nums = telefone.replace(/\D/g, '')
    if (nums.length === 11) {
      return `(${nums.slice(0, 2)}) ${nums.slice(2, 7)}-${nums.slice(7)}`
    }
    return telefone
  }

  const formatarData = (data: string) => {
    return new Date(data).toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-lg w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <Card className="border-0 shadow-2xl">
          {/* Cabeçalho */}
          <div className="flex items-center justify-between p-6 border-b border-gray-200">
            <div className="flex items-center space-x-3">
              <div className={`w-12 h-12 rounded-full flex items-center justify-center ${
                cliente.tipo === 'fisica' 
                  ? 'bg-blue-100 text-blue-600' 
                  : 'bg-purple-100 text-purple-600'
              }`}>
                {cliente.tipo === 'fisica' ? (
                  <User className="w-6 h-6" />
                ) : (
                  <Building2 className="w-6 h-6" />
                )}
              </div>
              <div>
                <h2 className="text-xl font-bold text-gray-900">{cliente.nome}</h2>
                <p className="text-sm text-gray-600">
                  {cliente.tipo === 'fisica' ? 'Pessoa Física' : 'Pessoa Jurídica'}
                </p>
              </div>
            </div>
            <div className="flex items-center space-x-2">
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                cliente.ativo
                  ? 'bg-green-100 text-green-800'
                  : 'bg-red-100 text-red-800'
              }`}>
                {cliente.ativo ? 'Ativo' : 'Inativo'}
              </span>
              <Button
                variant="outline"
                size="sm"
                onClick={onClose}
                className="text-gray-600 hover:text-gray-800"
              >
                <X className="w-4 h-4" />
              </Button>
            </div>
          </div>

          {/* Conteúdo */}
          <div className="p-6 space-y-6">
            {/* Informações de Contato */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Informações de Contato</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="flex items-center space-x-3">
                  <div className="w-8 h-8 bg-orange-100 rounded-lg flex items-center justify-center">
                    <Phone className="w-4 h-4 text-orange-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Telefone</p>
                    <p className="font-medium text-gray-900">{formatarTelefone(cliente.telefone)}</p>
                  </div>
                </div>

                {cliente.email && (
                  <div className="flex items-center space-x-3">
                    <div className="w-8 h-8 bg-orange-100 rounded-lg flex items-center justify-center">
                      <Mail className="w-4 h-4 text-orange-600" />
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">E-mail</p>
                      <p className="font-medium text-gray-900">{cliente.email}</p>
                    </div>
                  </div>
                )}

                {cliente.cpf_cnpj && (
                  <div className="flex items-center space-x-3">
                    <div className="w-8 h-8 bg-orange-100 rounded-lg flex items-center justify-center">
                      <FileText className="w-4 h-4 text-orange-600" />
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">
                        {cliente.tipo === 'fisica' ? 'CPF' : 'CNPJ'}
                      </p>
                      <p className="font-medium text-gray-900">{cliente.cpf_cnpj}</p>
                    </div>
                  </div>
                )}

                {cliente.endereco && (
                  <div className="flex items-start space-x-3 md:col-span-2">
                    <div className="w-8 h-8 bg-orange-100 rounded-lg flex items-center justify-center">
                      <MapPin className="w-4 h-4 text-orange-600" />
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">Endereço</p>
                      <p className="font-medium text-gray-900">{cliente.endereco}</p>
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* Observações */}
            {cliente.observacoes && (
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Observações</h3>
                <div className="bg-gray-50 rounded-lg p-4">
                  <p className="text-gray-700">{cliente.observacoes}</p>
                </div>
              </div>
            )}

            {/* Informações do Sistema */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Informações do Sistema</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="flex items-center space-x-3">
                  <div className="w-8 h-8 bg-gray-100 rounded-lg flex items-center justify-center">
                    <Calendar className="w-4 h-4 text-gray-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Cadastrado em</p>
                    <p className="font-medium text-gray-900">{formatarData(cliente.criado_em)}</p>
                  </div>
                </div>

                <div className="flex items-center space-x-3">
                  <div className="w-8 h-8 bg-gray-100 rounded-lg flex items-center justify-center">
                    <Calendar className="w-4 h-4 text-gray-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Última atualização</p>
                    <p className="font-medium text-gray-900">{formatarData(cliente.atualizado_em)}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Rodapé */}
          <div className="flex justify-end space-x-3 p-6 border-t border-gray-200">
            <Button
              variant="outline"
              onClick={onClose}
            >
              Fechar
            </Button>
            <Button
              onClick={onEdit}
              className="bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700"
            >
              Editar Cliente
            </Button>
          </div>
        </Card>
      </div>
    </div>
  )
}
