import { memo, useState } from 'react'
import { Save, Upload, AlertTriangle, Edit2, Building, Phone, MapPin } from 'lucide-react'
import { EmpresaInput } from './EmpresaInput'
import { EnderecoForm } from './EnderecoForm'

interface ConfiguracaoEmpresa {
  nome: string
  razao_social: string
  cnpj: string
  cep: string
  logradouro: string
  numero: string
  complemento: string
  bairro: string
  cidade: string
  estado: string
  telefone: string
  email: string
  site: string
  logo?: string
}

interface EmpresaViewProps {
  configEmpresa: ConfiguracaoEmpresa
  loading: boolean
  uploadingLogo: boolean
  unsavedChanges: boolean
  onEmpresaChange: (field: keyof ConfiguracaoEmpresa, value: string) => void
  onLogoUpload: (e: React.ChangeEvent<HTMLInputElement>) => void
  onSave: () => void
}

export const EmpresaView = memo(function EmpresaView({
  configEmpresa,
  loading,
  uploadingLogo,
  unsavedChanges,
  onEmpresaChange,
  onLogoUpload,
  onSave
}: EmpresaViewProps) {
  // Detecta se já tem dados salvos
  const hasData = configEmpresa.nome && configEmpresa.nome.trim() !== ''
  
  // Estado de edição (começa em true se não tem dados)
  const [isEditing, setIsEditing] = useState(!hasData)



  const handleSave = async () => {
    await onSave()
    setIsEditing(false) // Volta para modo visualização após salvar
  }

  // Modo visualização (quando tem dados e não está editando)
  if (hasData && !isEditing) {
    return (
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="text-xl font-semibold text-gray-900">Dados da Empresa</h2>
            <p className="text-sm text-gray-500 mt-1">
              Informações cadastradas
            </p>
          </div>
          
          <button
            onClick={() => setIsEditing(true)}
            className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            <Edit2 className="w-4 h-4" />
            Editar
          </button>
        </div>

        {/* Logo */}
        {configEmpresa.logo && (
          <div className="mb-6 flex justify-center">
            <img
              src={configEmpresa.logo}
              alt="Logo da empresa"
              className="max-h-32 object-contain rounded-lg shadow-sm"
            />
          </div>
        )}

        {/* Informações em cards */}
        <div className="space-y-4">
          {/* Dados Básicos */}
          <div className="border border-gray-200 rounded-lg p-4">
            <h3 className="text-sm font-medium text-gray-700 mb-3 flex items-center gap-2">
              <Building className="w-4 h-4" />
              Dados Básicos
            </h3>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-gray-500">Nome Fantasia:</span>
                <p className="font-medium text-gray-900 mt-1">{configEmpresa.nome || '-'}</p>
              </div>
              <div>
                <span className="text-gray-500">Razão Social:</span>
                <p className="font-medium text-gray-900 mt-1">{configEmpresa.razao_social || '-'}</p>
              </div>
              <div>
                <span className="text-gray-500">CNPJ:</span>
                <p className="font-medium text-gray-900 mt-1">{configEmpresa.cnpj || '-'}</p>
              </div>
            </div>
          </div>

          {/* Contato */}
          <div className="border border-gray-200 rounded-lg p-4">
            <h3 className="text-sm font-medium text-gray-700 mb-3 flex items-center gap-2">
              <Phone className="w-4 h-4" />
              Contato
            </h3>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-gray-500">Telefone:</span>
                <p className="font-medium text-gray-900 mt-1">{configEmpresa.telefone || '-'}</p>
              </div>
              <div>
                <span className="text-gray-500">E-mail:</span>
                <p className="font-medium text-gray-900 mt-1">{configEmpresa.email || '-'}</p>
              </div>
              <div className="col-span-2">
                <span className="text-gray-500">Site:</span>
                <p className="font-medium text-gray-900 mt-1">{configEmpresa.site || '-'}</p>
              </div>
            </div>
          </div>

          {/* Endereço */}
          <div className="border border-gray-200 rounded-lg p-4">
            <h3 className="text-sm font-medium text-gray-700 mb-3 flex items-center gap-2">
              <MapPin className="w-4 h-4" />
              Endereço
            </h3>
            <div className="text-sm space-y-2">
              <p className="font-medium text-gray-900">
                {configEmpresa.logradouro || '-'}
                {configEmpresa.numero && `, ${configEmpresa.numero}`}
              </p>
              {configEmpresa.complemento && (
                <p className="text-gray-600">{configEmpresa.complemento}</p>
              )}
              <p className="text-gray-600">
                {configEmpresa.bairro || '-'} - {configEmpresa.cidade || '-'}/{configEmpresa.estado || '-'}
              </p>
              <p className="text-gray-600">CEP: {configEmpresa.cep || '-'}</p>
            </div>
          </div>
        </div>
      </div>
    )
  }

  // Modo edição (formulário)
  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-xl font-semibold text-gray-900">Dados da Empresa</h2>
          <p className="text-sm text-gray-500 mt-1">
            Configure as informações da sua empresa
          </p>
        </div>
        
        <div className="flex items-center gap-2">
          {hasData && (
            <button
              onClick={() => setIsEditing(false)}
              className="inline-flex items-center gap-2 px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors"
            >
              Cancelar
            </button>
          )}
          <button
            onClick={handleSave}
            disabled={loading || !unsavedChanges}
            className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Save className="w-4 h-4" />
            Salvar
          </button>
        </div>
      </div>

      {/* Alerta de mudanças não salvas */}
      {unsavedChanges && (
        <div className="mb-6 flex items-center gap-2 text-amber-700 bg-amber-50 p-3 rounded-lg border border-amber-200">
          <AlertTriangle className="w-5 h-5 flex-shrink-0" />
          <p className="text-sm">Você tem alterações não salvas</p>
        </div>
      )}

      {/* Formulário */}
      <div className="space-y-6">
        {/* Dados Básicos */}
        <div className="grid grid-cols-2 gap-4">
          <EmpresaInput
            label="Nome Fantasia"
            value={configEmpresa.nome}
            onChange={(value) => onEmpresaChange('nome', value)}
            placeholder="Ex: Loja ABC"
          />
          <EmpresaInput
            label="Razão Social"
            value={configEmpresa.razao_social}
            onChange={(value) => onEmpresaChange('razao_social', value)}
            placeholder="Ex: Loja ABC Ltda"
          />
          <EmpresaInput
            label="CNPJ"
            value={configEmpresa.cnpj}
            onChange={(value) => onEmpresaChange('cnpj', value)}
            placeholder="00.000.000/0000-00"
          />
          <EmpresaInput
            label="Telefone"
            value={configEmpresa.telefone}
            onChange={(value) => onEmpresaChange('telefone', value)}
            placeholder="(00) 00000-0000"
          />
          <EmpresaInput
            label="E-mail"
            type="email"
            value={configEmpresa.email}
            onChange={(value) => onEmpresaChange('email', value)}
            placeholder="contato@empresa.com"
          />
          <EmpresaInput
            label="Site"
            value={configEmpresa.site}
            onChange={(value) => onEmpresaChange('site', value)}
            placeholder="www.empresa.com"
          />
        </div>

        {/* Endereço */}
        <div>
          <h3 className="text-sm font-medium text-gray-700 mb-3">Endereço</h3>
          <EnderecoForm
            endereco={{
              cep: configEmpresa.cep,
              logradouro: configEmpresa.logradouro,
              numero: configEmpresa.numero,
              complemento: configEmpresa.complemento,
              bairro: configEmpresa.bairro,
              cidade: configEmpresa.cidade,
              estado: configEmpresa.estado
            }}
            onChange={onEmpresaChange}
          />
        </div>

        {/* Logo */}
        <div>
          <h3 className="text-sm font-medium text-gray-700 mb-3">Logo da Empresa</h3>
          <div className="flex items-center gap-4">
            {configEmpresa.logo && (
              <img
                src={configEmpresa.logo}
                alt="Logo atual"
                className="w-20 h-20 object-contain rounded border border-gray-200"
              />
            )}
            <label className="cursor-pointer">
              <input
                type="file"
                accept="image/*"
                onChange={onLogoUpload}
                className="hidden"
                disabled={uploadingLogo}
              />
              <div className="inline-flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors">
                <Upload className="w-4 h-4" />
                {uploadingLogo ? 'Enviando...' : configEmpresa.logo ? 'Alterar Logo' : 'Enviar Logo'}
              </div>
            </label>
          </div>
          <p className="text-xs text-gray-500 mt-2">
            Formatos aceitos: JPG, PNG. Tamanho máximo: 2MB
          </p>
        </div>
      </div>
    </div>
  )
})
