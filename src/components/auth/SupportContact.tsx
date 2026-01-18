import { useState } from 'react'
import { Phone, MessageCircle, Mail } from 'lucide-react'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'

interface SupportContactProps {
  userEmail: string
}

export function SupportContact({ userEmail }: SupportContactProps) {
  const [copied, setCopied] = useState(false)

  const supportInfo = {
    whatsapp: '+55 17 99978-3012',
    email: 'gruporaval@gmail.com',
    phone: '+55 17 99978-3012'
  }

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  const sendWhatsAppMessage = () => {
    const message = `Olá! Preciso de ajuda para recuperar minha senha do PDV Allimport. Meu email é: ${userEmail}`
    const whatsappUrl = `https://wa.me/${supportInfo.whatsapp.replace(/\D/g, '')}?text=${encodeURIComponent(message)}`
    window.open(whatsappUrl, '_blank')
  }

  return (
    <Card className="bg-blue-50 border border-blue-200 shadow-sm">
      <div className="p-6">
        <h3 className="text-blue-800 font-semibold mb-4 flex items-center">
          <MessageCircle className="w-5 h-5 mr-2" />
          Precisa de ajuda? Entre em contato conosco
        </h3>
        
        <div className="space-y-3">
          <Button
            onClick={sendWhatsAppMessage}
            className="w-full bg-green-600 hover:bg-green-700 text-white flex items-center justify-center"
          >
            <MessageCircle className="w-4 h-4 mr-2" />
            Solicitar ajuda pelo WhatsApp
          </Button>

          <div className="grid grid-cols-1 gap-2 text-sm">
            <div className="flex items-center justify-between p-2 bg-white rounded-lg">
              <span className="flex items-center text-gray-600">
                <Phone className="w-4 h-4 mr-2" />
                Telefone:
              </span>
              <button
                onClick={() => copyToClipboard(supportInfo.phone)}
                className="text-blue-600 hover:text-blue-800 font-medium"
              >
                {supportInfo.phone}
              </button>
            </div>

            <div className="flex items-center justify-between p-2 bg-white rounded-lg">
              <span className="flex items-center text-gray-600">
                <Mail className="w-4 h-4 mr-2" />
                Email:
              </span>
              <button
                onClick={() => copyToClipboard(supportInfo.email)}
                className="text-blue-600 hover:text-blue-800 font-medium"
              >
                {supportInfo.email}
              </button>
            </div>
          </div>

          {copied && (
            <p className="text-green-600 text-xs text-center font-medium">
              ✓ Copiado para a área de transferência!
            </p>
          )}
        </div>

        <div className="mt-4 p-3 bg-white rounded-lg border border-blue-100">
          <p className="text-xs text-gray-600">
            <strong>Seu email:</strong> {userEmail}
          </p>
          <p className="text-xs text-gray-500 mt-1">
            Mencione este email ao entrar em contato para agilizar o atendimento.
          </p>
        </div>
      </div>
    </Card>
  )
}
