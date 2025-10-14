import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { ShoppingCart, Eye, EyeOff, User, FileText, AlertCircle, Phone, MapPin } from 'lucide-react'
import { useAuth } from './AuthContext'
import { Button } from '../../components/ui/Button'
import { Input } from '../../components/ui/Input'
import { Card } from '../../components/ui/Card'
import { validateDocument, maskCPF, maskCNPJ, unformatDocument, maskPhone } from '../../utils/validators'
import { sendEmailVerificationCode, verifyEmailCode, resendEmailVerificationCode } from '../../services/emailServiceSupabase'
import { activateUserAfterEmailVerification } from '../../services/userActivationService'

type DocumentType = 'CPF' | 'CNPJ'

export function SignupPageNew() {
  const { signUp } = useAuth()
  
  const [step, setStep] = useState<'form' | 'verify'>('form')
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    fullName: '',
    companyName: '',
    documentType: 'CPF' as DocumentType,
    document: '',
    whatsapp: '',
    cep: '',
    street: '',
    number: '',
    complement: '',
    neighborhood: '',
    city: '',
    state: ''
  })
  
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const handleChange = (field: string, value: string) => {
    let processedValue = value

    if (field === 'document') {
      processedValue = formData.documentType === 'CPF' ? maskCPF(value) : maskCNPJ(value)
    } else if (field === 'whatsapp') {
      processedValue = maskPhone(value)
    } else if (field === 'cep') {
      const cleaned = value.replace(/\D/g, '')
      processedValue = cleaned.length <= 5 ? cleaned : `${cleaned.slice(0, 5)}-${cleaned.slice(5, 8)}`
      
      // Buscar endereço automaticamente quando CEP estiver completo
      if (cleaned.length === 8) {
        fetchAddressByCep(cleaned)
      }
    }
    
    setFormData(prev => ({ ...prev, [field]: processedValue }))
    setError('')
  }

  // Função para buscar endereço pela API ViaCEP
  const fetchAddressByCep = async (cep: string) => {
    try {
      console.log('🔍 Buscando CEP:', cep)
      const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`)
      const data = await response.json()

      if (data.erro) {
        setError('CEP não encontrado')
        return
      }

      console.log('✅ Endereço encontrado:', data)

      // Preencher campos automaticamente
      setFormData(prev => ({
        ...prev,
        street: data.logradouro || '',
        neighborhood: data.bairro || '',
        city: data.localidade || '',
        state: data.uf || ''
      }))

      setError('') // Limpar erro se houver
    } catch (error) {
      console.error('❌ Erro ao buscar CEP:', error)
      setError('Erro ao buscar CEP. Verifique sua conexão.')
    }
  }

  const handleDocumentTypeChange = (type: DocumentType) => {
    setFormData(prev => ({ ...prev, documentType: type, document: '' }))
  }

  const validateForm = (): boolean => {
    if (formData.fullName.trim().length < 3) {
      setError('Nome deve ter pelo menos 3 caracteres')
      return false
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      setError('Email inválido')
      return false
    }

    if (formData.password.length < 6) {
      setError('A senha deve ter pelo menos 6 caracteres')
      return false
    }

    if (formData.password !== formData.confirmPassword) {
      setError('As senhas não coincidem')
      return false
    }

    const cleanDocument = unformatDocument(formData.document)
    if (!validateDocument(cleanDocument)) {
      setError(`${formData.documentType} inválido`)
      return false
    }

    if (formData.documentType === 'CNPJ' && formData.companyName.trim().length < 3) {
      setError('Nome da empresa é obrigatório para CNPJ')
      return false
    }

    const cleanPhone = unformatDocument(formData.whatsapp)
    if (cleanPhone.length < 10 || cleanPhone.length > 11) {
      setError('Telefone inválido')
      return false
    }

    if (unformatDocument(formData.cep).length !== 8) {
      setError('CEP inválido')
      return false
    }

    if (!formData.street.trim() || !formData.number.trim() || 
        !formData.neighborhood.trim() || !formData.city.trim()) {
      setError('Todos os campos de endereço são obrigatórios')
      return false
    }

    if (!formData.state.trim() || formData.state.length !== 2) {
      setError('Estado inválido (use sigla: SP, RJ, etc)')
      return false
    }

    return true
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!validateForm()) return
    
    setLoading(true)
    setError('')

    try {
      const cleanDocument = unformatDocument(formData.document)
      const cleanPhone = unformatDocument(formData.whatsapp)
      const cleanCEP = unformatDocument(formData.cep)

      const result = await signUp(
        formData.email, 
        formData.password,
        {
          full_name: formData.fullName,
          company_name: formData.companyName || formData.fullName,
          document_type: formData.documentType,
          cpf_cnpj: cleanDocument,
          whatsapp: cleanPhone,
          cep: cleanCEP,
          street: formData.street,
          number: formData.number,
          complement: formData.complement || null,
          neighborhood: formData.neighborhood,
          city: formData.city,
          state: formData.state.toUpperCase(),
          email_verified: false
        }
      )
      
      if (result && 'error' in result && result.error) {
        const errorMessage = result.error.message || ''
        
        if (errorMessage.includes('duplicate') || errorMessage.includes('já existe') || errorMessage.includes('unique')) {
          setError('Este CPF/CNPJ já está cadastrado no sistema.')
        } else if (errorMessage.includes('email')) {
          setError('Este email já está cadastrado.')
        } else {
          throw result.error
        }
        return
      }

      if (result && 'data' in result && result.data) {
        const data = result.data as { user?: { id: string }; session?: unknown }
        if (data.user?.id) {
          console.log('📧 Enviando código via Supabase OTP para:', formData.email)
          
          // ENVIAR CÓDIGO VIA SUPABASE OTP (funciona e envia email)
          const emailResult = await sendEmailVerificationCode(formData.email)
          
          if (!emailResult.success) {
            console.error('⚠️ Erro ao enviar código:', emailResult.error)
            setError('Conta criada, mas houve erro ao enviar código. Tente novamente.')
            return
          }
          
          console.log('✅ Código enviado! Verifique seu email')
          setStep('verify')
        }
      }
    } catch (err: any) {
      console.error('Erro no cadastro:', err)
      setError(err.message || 'Erro ao criar conta.')
    } finally {
      setLoading(false)
    }
  }

  if (step === 'form') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 flex items-center justify-center p-4">
        <Card className="w-full max-w-2xl">
          <div className="flex items-center justify-center mb-6">
            <ShoppingCart className="w-8 h-8 text-blue-600 mr-2" />
            <h1 className="text-2xl font-bold text-gray-900">PDV Allimport</h1>
          </div>

          <h2 className="text-xl font-semibold text-gray-900 mb-2 text-center">
            Criar Conta
          </h2>
          <p className="text-gray-600 mb-6 text-center text-sm">
            Preencha todos os dados para começar
          </p>

          {error && (
            <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg flex items-start gap-2">
              <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
              <p className="text-sm text-red-600">{error}</p>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Dados Pessoais */}
            <div className="border-b pb-4">
              <h3 className="text-md font-semibold text-gray-800 mb-3 flex items-center gap-2">
                <User className="w-5 h-5 text-blue-600" />
                Dados Pessoais
              </h3>
              

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Nome Completo *
                  </label>
                  <Input
                    type="text"
                    value={formData.fullName}
                    onChange={(e) => handleChange('fullName', e.target.value)}
                    placeholder="Seu nome completo"
                    required
                    disabled={loading}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    <FileText className="w-4 h-4 inline mr-1" />
                    Tipo de Documento *
                  </label>
                  <div className="grid grid-cols-2 gap-2">
                    <button
                      type="button"
                      onClick={() => handleDocumentTypeChange('CPF')}
                      disabled={loading}
                      className={`px-4 py-2 rounded-lg border-2 font-medium transition-colors ${
                        formData.documentType === 'CPF'
                          ? 'border-blue-600 bg-blue-50 text-blue-700'
                          : 'border-gray-300 bg-white text-gray-700 hover:border-gray-400'
                      }`}
                    >
                      CPF (Pessoa Física)
                    </button>
                    <button
                      type="button"
                      onClick={() => handleDocumentTypeChange('CNPJ')}
                      disabled={loading}
                      className={`px-4 py-2 rounded-lg border-2 font-medium transition-colors ${
                        formData.documentType === 'CNPJ'
                          ? 'border-blue-600 bg-blue-50 text-blue-700'
                          : 'border-gray-300 bg-white text-gray-700 hover:border-gray-400'
                      }`}
                    >
                      CNPJ (Empresa)
                    </button>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      {formData.documentType} *
                    </label>
                    <Input
                      type="text"
                      value={formData.document}
                      onChange={(e) => handleChange('document', e.target.value)}
                      placeholder={formData.documentType === 'CPF' ? '000.000.000-00' : '00.000.000/0000-00'}
                      maxLength={formData.documentType === 'CPF' ? 14 : 18}
                      required
                      disabled={loading}
                    />
                    <p className="text-xs text-gray-500 mt-1">
                      ⚠️ Cada documento pode ter apenas uma conta
                    </p>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      <Phone className="w-4 h-4 inline mr-1" />
                      WhatsApp *
                    </label>
                    <Input
                      type="tel"
                      value={formData.whatsapp}
                      onChange={(e) => handleChange('whatsapp', e.target.value)}
                      placeholder="(00) 00000-0000"
                      maxLength={15}
                      required
                      disabled={loading}
                    />
                  </div>
                </div>

                {formData.documentType === 'CNPJ' && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Nome da Empresa *
                    </label>
                    <Input
                      type="text"
                      value={formData.companyName}
                      onChange={(e) => handleChange('companyName', e.target.value)}
                      placeholder="Razão Social ou Nome Fantasia"
                      required
                      disabled={loading}
                    />
                  </div>
                )}
              </div>
            </div>

            {/* Endereço */}
            <div className="border-b pb-4">
              <h3 className="text-md font-semibold text-gray-800 mb-3 flex items-center gap-2">
                <MapPin className="w-5 h-5 text-blue-600" />
                Endereço
              </h3>
              
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      CEP *
                    </label>
                    <Input
                      type="text"
                      value={formData.cep}
                      onChange={(e) => handleChange('cep', e.target.value)}
                      placeholder="00000-000"
                      maxLength={9}
                      required
                      disabled={loading}
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Estado (UF) *
                    </label>
                    <Input
                      type="text"
                      value={formData.state}
                      onChange={(e) => handleChange('state', e.target.value.toUpperCase())}
                      placeholder="SP"
                      maxLength={2}
                      required
                      disabled={loading}
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Cidade *
                    </label>
                    <Input
                      type="text"
                      value={formData.city}
                      onChange={(e) => handleChange('city', e.target.value)}
                      placeholder="Nome da cidade"
                      required
                      disabled={loading}
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Rua/Logradouro *
                  </label>
                  <Input
                    type="text"
                    value={formData.street}
                    onChange={(e) => handleChange('street', e.target.value)}
                    placeholder="Nome da rua"
                    required
                    disabled={loading}
                  />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Número *
                    </label>
                    <Input
                      type="text"
                      value={formData.number}
                      onChange={(e) => handleChange('number', e.target.value)}
                      placeholder="123"
                      required
                      disabled={loading}
                    />
                  </div>

                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Complemento
                    </label>
                    <Input
                      type="text"
                      value={formData.complement}
                      onChange={(e) => handleChange('complement', e.target.value)}
                      placeholder="Apto, Bloco, etc (opcional)"
                      disabled={loading}
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Bairro *
                  </label>
                  <Input
                    type="text"
                    value={formData.neighborhood}
                    onChange={(e) => handleChange('neighborhood', e.target.value)}
                    placeholder="Nome do bairro"
                    required
                    disabled={loading}
                  />
                </div>
              </div>
            </div>

            {/* Dados de Acesso */}
            <div className="pb-4">
              <h3 className="text-md font-semibold text-gray-800 mb-3 flex items-center gap-2">
                <Eye className="w-5 h-5 text-blue-600" />
                Dados de Acesso
              </h3>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Email *
                  </label>
                  <Input
                    type="email"
                    value={formData.email}
                    onChange={(e) => handleChange('email', e.target.value)}
                    placeholder="seu@email.com"
                    required
                    disabled={loading}
                  />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Senha *
                    </label>
                    <div className="relative">
                      <Input
                        type={showPassword ? 'text' : 'password'}
                        value={formData.password}
                        onChange={(e) => handleChange('password', e.target.value)}
                        placeholder="Mínimo 6 caracteres"
                        required
                        disabled={loading}
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                      >
                        {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}

                      </button>
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Confirmar Senha *
                    </label>
                    <div className="relative">
                      <Input
                        type={showConfirmPassword ? 'text' : 'password'}
                        value={formData.confirmPassword}
                        onChange={(e) => handleChange('confirmPassword', e.target.value)}
                        placeholder="Digite a senha novamente"
                        required
                        disabled={loading}
                      />
                      <button
                        type="button"
                        onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                        className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                      >
                        {showConfirmPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}

                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <Button 
              type="submit" 
              className="w-full"
              disabled={loading}
            >
              {loading ? 'Criando conta...' : 'Criar Conta'}
            </Button>

            <div className="mt-4 p-3 bg-blue-50 border border-blue-200 rounded-lg">
              <p className="text-xs text-blue-700">
                <strong>⚠️ Importante:</strong> Cada CPF/CNPJ pode ter apenas uma conta no sistema. 
                Certifique-se de que está usando um documento válido e que ainda não foi cadastrado.
              </p>
            </div>
          </form>

          <div className="mt-6 p-4 bg-gradient-to-r from-blue-500 to-purple-600 rounded-xl shadow-lg">
            <div className="text-center">
              <p className="text-white text-sm font-medium mb-2">
                Já possui uma conta?
              </p>
              <Link to="/login">
                <Button 
                  variant="outline" 
                  className="w-full bg-white text-blue-600 border-white hover:bg-blue-50 hover:border-blue-100 font-semibold shadow-md transition-all duration-200 hover:scale-105"
                >
                  Fazer Login
                </Button>
              </Link>
            </div>
          </div>

          <p className="mt-4 text-center text-xs text-gray-500">
            <Link to="/" className="hover:text-blue-600 transition-colors">
              ← Voltar para o início
            </Link>
          </p>
        </Card>
      </div>
    )
  }

  return (
    <VerifyEmailCode 
      email={formData.email}
      password={formData.password}
      onResend={async () => {
        console.log('🔄 Reenviando código via Supabase OTP...')
        const result = await resendEmailVerificationCode(formData.email)
        if (!result.success) {
          throw new Error(result.error || 'Erro ao reenviar código')
        }
        console.log('✅ Código reenviado com sucesso! Verifique seu email.')
      }}
    />
  )
}

// Componente de verificação
function VerifyEmailCode({ 
  email,
  password,
  onResend 
}: { 
  email: string
  password: string
  onResend: () => Promise<void>
}) {
  const navigate = useNavigate()
  const { signIn } = useAuth()
  const [code, setCode] = useState(['', '', '', '', '', ''])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [resending, setResending] = useState(false)
  const [successMessage, setSuccessMessage] = useState('')

  const handleCodeChange = (index: number, value: string) => {
    if (!/^\d*$/.test(value)) return
    if (value.length > 1) return
    
    const newCode = [...code]
    newCode[index] = value
    setCode(newCode)
    setError('')
    setSuccessMessage('')

    if (value && index < 5) {
      document.getElementById(`code-${index + 1}`)?.focus()
    }

    if (newCode.every(digit => digit !== '') && index === 5) {
      handleVerify(newCode.join(''))
    }
  }

  const handleVerify = async (fullCode: string) => {
    setLoading(true)
    setError('')

    try {
      // Verificar código com Supabase OTP
      const result = await verifyEmailCode(email, fullCode)
      
      if (result.success) {
        console.log('✅ Código verificado! Ativando usuário e concedendo 15 dias...')
        
        // IMPORTANTE: Ativar usuário e conceder 15 dias de teste
        const activationResult = await activateUserAfterEmailVerification(email)
        
        if (activationResult.success) {
          const message = `✅ Email verificado! Você ganhou ${activationResult.daysRemaining || 15} dias de teste gratuito!`;
          setSuccessMessage(message)
          console.log('🎉 Usuário ativado com 15 dias de teste!')
        } else {
          setSuccessMessage('✅ Email verificado com sucesso!')
          console.warn('⚠️ Código verificado mas erro ao ativar período de teste:', activationResult.error)
        }
        
        // Fazer login automático após verificação bem-sucedida
        console.log('🔐 Fazendo login automático...')
        
        try {
          const loginResult = await signIn(email, password)
          
          if (loginResult.error) {
            console.error('❌ Erro no login automático:', loginResult.error)
            // Se houver erro no login, redirecionar para página de login
            setSuccessMessage('✅ Conta verificada! Redirecionando para o login...')
            setTimeout(() => {
              navigate('/login')
            }, 2500)
          } else {
            console.log('✅ Login automático bem-sucedido! Redirecionando para o dashboard...')
            setSuccessMessage(`✅ Bem-vindo! Você tem ${activationResult.daysRemaining || 15} dias de teste gratuito!`)
            setTimeout(() => {
              navigate('/dashboard')
            }, 2500)
          }
        } catch (loginErr: any) {
          console.error('❌ Erro ao fazer login automático:', loginErr)
          setSuccessMessage('✅ Conta verificada! Redirecionando para o login...')
          setTimeout(() => {
            navigate('/login')
          }, 2500)
        }
      } else {
        setError(result.error || 'Código inválido. Tente novamente.')
        setCode(['', '', '', '', '', ''])
        document.getElementById('code-0')?.focus()
      }
    } catch (err: any) {
      setError(err.message || 'Erro ao verificar código')
      setCode(['', '', '', '', '', ''])
      document.getElementById('code-0')?.focus()
    } finally {
      setLoading(false)
    }
  }

  const handleResend = async () => {
    setResending(true)
    setError('')
    setSuccessMessage('')
    
    try {
      await onResend()
      setCode(['', '', '', '', '', ''])
      document.getElementById('code-0')?.focus()
      setSuccessMessage('✅ Novo código enviado!')
      setTimeout(() => setSuccessMessage(''), 3000)
    } catch (err: any) {
      setError(err.message || 'Erro ao reenviar código')
    } finally {
      setResending(false)
    }
  }

  const handlePaste = (e: React.ClipboardEvent) => {
    e.preventDefault()
    const pastedData = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6)
    
    if (pastedData.length === 6) {
      const newCode = pastedData.split('')
      setCode(newCode)
      handleVerify(pastedData)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 flex items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <div className="text-center mb-6">
          <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center mx-auto mb-4 shadow-lg">
            <svg 
              className="w-10 h-10 text-white" 
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24"
            >
              <path 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                strokeWidth={2} 
                d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" 
              />
            </svg>
          </div>
          
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            Verifique seu Email
          </h2>
          
          <p className="text-gray-600 text-sm mb-2">
            Enviamos um código de 6 dígitos para
          </p>
          
          <p className="text-gray-900 font-semibold text-lg">
            {email}
          </p>
          
          <p className="text-gray-500 text-xs mt-3">
            📧 Verifique sua caixa de entrada e também a pasta de SPAM
          </p>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg flex items-start gap-2">
            <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
            <p className="text-sm text-red-600">{error}</p>
          </div>
        )}

        {successMessage && (
          <div className="mb-4 p-3 bg-green-50 border border-green-200 rounded-lg">
            <p className="text-sm text-green-700 text-center font-medium">{successMessage}</p>
          </div>
        )}

        <div className="flex gap-2 justify-center mb-6" onPaste={handlePaste}>
          {code.map((digit, index) => (
            <input
              key={index}
              id={`code-${index}`}
              type="text"
              inputMode="numeric"
              pattern="[0-9]*"
              maxLength={1}
              value={digit}
              onChange={(e) => handleCodeChange(index, e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Backspace' && !digit && index > 0) {
                  document.getElementById(`code-${index - 1}`)?.focus()
                }
              }}
              disabled={loading}
              className="w-12 h-14 text-center text-2xl font-bold border-2 border-gray-300 rounded-lg focus:border-blue-600 focus:ring-2 focus:ring-blue-100 outline-none transition-all disabled:bg-gray-100"
              autoComplete="off"
            />
          ))}
        </div>

        <div className="mb-4 p-3 bg-blue-50 border border-blue-200 rounded-lg">
          <p className="text-xs text-blue-700 text-center">
            💡 Dica: Você pode copiar e colar o código completo
          </p>
        </div>

        <Button
          onClick={() => handleVerify(code.join(''))}
          disabled={code.some(d => !d) || loading}
          className="w-full mb-4"
        >
          {loading ? (
            <span className="flex items-center justify-center gap-2">
              <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
              </svg>
              Verificando...
            </span>
          ) : 'Verificar Código'}
        </Button>

        <div className="text-center space-y-3">
          <button
            onClick={handleResend}
            disabled={resending}
            className="text-sm text-blue-600 hover:text-blue-700 font-medium disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {resending ? '📧 Reenviando...' : '🔄 Não recebeu? Reenviar código'}
          </button>

          <p className="text-xs text-gray-500">
            ⏱️ O código expira em 10 minutos
          </p>
        </div>

        <div className="mt-6 pt-6 border-t border-gray-200">
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
            <p className="text-xs text-yellow-800">
              <strong>📌 Não encontrou o email?</strong><br/>
              • Verifique a pasta de <strong>SPAM/Lixo Eletrônico</strong><br/>
              • Aguarde até 5 minutos<br/>
              • Verifique se o email está correto: <strong>{email}</strong><br/>
              • Clique em "Reenviar código" se necessário
            </p>
          </div>
        </div>
      </Card>
    </div>
  )
}
