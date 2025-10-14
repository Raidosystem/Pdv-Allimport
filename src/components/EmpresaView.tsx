import { memo } from 'react'
import { Save, Upload, AlertTriangle } from 'lucide-react'
import { EmpresaInput } from './EmpresaInput'

interface ConfiguracaoEmpresa {
  nome: string
  razao_social: string
  cnpj: string
  endereco: string
  cidade: string
  cep: string
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
  onEnderecoChange: (value: string) => void
  onLogoUpload: (e: React.ChangeEvent<HTMLInputElement>) => void
  onSave: () => void
}

export const EmpresaView = memo(({
  configEmpresa,
  loading,
  uploadingLogo,
  unsavedChanges,
  onEmpresaChange,
  onEnderecoChange,
  onLogoUpload,
  onSave
}: EmpresaViewProps) => {
  return (
    <div className="bg-white rounded-lg shadow-sm">
      <div className="p-6 border-b">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold text-gray-900">Dados da Empresa</h3>
            <p className="text-gray-600 mt-1">Informações básicas da sua empresa</p>
          </div>
          <button
            onClick={onSave}
            disabled={loading}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50 flex items-center gap-2"
          >
            {loading ? (
              <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent" />
            ) : (
              <Save className="h-4 w-4" />
            )}
            Salvar
          </button>
        </div>
      </div>
      
      <div className="p-6 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <EmpresaInput
            label="Nome da Empresa"
            value={configEmpresa.nome}
            onChange={(value) => onEmpresaChange('nome', value)}
            required
          />

          <EmpresaInput
            label="Razão Social"
            value={configEmpresa.razao_social}
            onChange={(value) => onEmpresaChange('razao_social', value)}
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
            label="Email"
            type="email"
            value={configEmpresa.email}
            onChange={(value) => onEmpresaChange('email', value)}
          />

          <EmpresaInput
            label="Website"
            type="url"
            value={configEmpresa.site}
            onChange={(value) => onEmpresaChange('site', value)}
            placeholder="www.empresa.com.br"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Endereço Completo
          </label>
          <textarea
            rows={3}
            value={`${configEmpresa.endereco}\n${configEmpresa.cidade}\nCEP: ${configEmpresa.cep}`}
            onChange={(e) => onEnderecoChange(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="Rua, número, bairro&#10;Cidade, Estado&#10;CEP: 00000-000"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Logo da Empresa
          </label>
          <div className="mt-2 flex items-center gap-4">
            {configEmpresa.logo && (
              <img 
                src={configEmpresa.logo} 
                alt="Logo" 
                className="h-20 w-20 object-contain rounded border border-gray-300"
              />
            )}
            <label className="cursor-pointer bg-white px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 flex items-center gap-2">
              {uploadingLogo ? (
                <div className="animate-spin rounded-full h-4 w-4 border-2 border-blue-600 border-t-transparent" />
              ) : (
                <Upload className="h-4 w-4" />
              )}
              <span className="text-sm">
                {uploadingLogo ? 'Enviando...' : 'Escolher arquivo'}
              </span>
              <input
                type="file"
                accept="image/*"
                onChange={onLogoUpload}
                className="hidden"
                disabled={uploadingLogo}
              />
            </label>
          </div>
          <p className="mt-2 text-sm text-gray-500">
            PNG, JPG ou GIF (máximo 2MB)
          </p>
        </div>

        {unsavedChanges && (
          <div className="bg-yellow-50 border border-yellow-200 rounded-md p-4">
            <div className="flex">
              <AlertTriangle className="h-5 w-5 text-yellow-400" />
              <div className="ml-3">
                <p className="text-sm text-yellow-800">
                  Você tem alterações não salvas. Clique em "Salvar" para aplicar as mudanças.
                </p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
})

EmpresaView.displayName = 'EmpresaView'
