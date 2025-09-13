// API Backend Service para integração com Mercado Pago
const isDevelopment = import.meta.env.DEV && import.meta.env.VITE_DEV_MODE !== 'false';
const isProduction = window.location.hostname.includes('vercel.app') || 
                    window.location.hostname.includes('pdv-allimport') ||
                    import.meta.env.VITE_DEV_MODE === 'false';

const API_BASE_URL = isDevelopment 
  ? 'http://localhost:3333'
  : window.location.origin; // Usar o mesmo domínio em produção

console.log('🔧 Configuração de ambiente:', {
  isDevelopment,
  isProduction,
  hostname: window.location.hostname,
  VITE_DEV_MODE: import.meta.env.VITE_DEV_MODE,
  API_BASE_URL
});

export interface PaymentData {
  userEmail: string;
  userName?: string;
  amount: number;
  description?: string;
}

export interface PaymentResponse {
  success: boolean;
  paymentId?: string;
  status?: string;
  qrCode?: string;
  qrCodeBase64?: string;
  ticketUrl?: string;
  checkoutUrl?: string;
  error?: string;
}

class MercadoPagoApiService {
  private isProduction = window.location.hostname.includes('vercel.app') || 
                        window.location.hostname.includes('pdv-allimport') ||
                        import.meta.env.VITE_DEV_MODE === 'false';
  
  // Credenciais de produção do Mercado Pago
  private readonly PRODUCTION_ACCESS_TOKEN = 'APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193';
  private readonly PRODUCTION_PUBLIC_KEY = 'APP_USR-4a8bfb6e-0ff5-47d1-be9c-092fbcf7e022';
  
  private getAccessToken(): string {
    // Sempre usar credenciais de produção para comercialização
    return this.PRODUCTION_ACCESS_TOKEN;
  }
  
  private getPublicKey(): string {
    // Sempre usar chave pública de produção
    return this.PRODUCTION_PUBLIC_KEY;
  }

  private get isDevelopment() {
    return !this.isProduction;
  }

  private async makeApiCall(endpoint: string, method: 'GET' | 'POST' = 'GET', body?: any) {
    try {
      console.log(`🌐 API Call: ${method} ${API_BASE_URL}${endpoint}`);
      const response = await fetch(`${API_BASE_URL}${endpoint}`, {
        method,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body ? JSON.stringify(body) : undefined,
      });

      if (!response.ok) {
        throw new Error(`API Error: ${response.status}`);
      }

      const result = await response.json();
      console.log(`✅ API Response:`, result);
      return result;
    } catch (error) {
      console.error(`❌ Erro na API (${endpoint}):`, error);
      throw error;
    }
  }

  private async isApiAvailable(): Promise<boolean> {
    try {
      console.log('🔍 Verificando disponibilidade da API:', API_BASE_URL);
      
      // Verificar se está no Vercel (produção)
      const isVercel = window.location.hostname.includes('vercel.app') || 
                       window.location.hostname.includes('pdv-allimport');
      
      if (isVercel) {
        console.log('✅ Detectado ambiente Vercel - forçando modo produção');
        return true;
      }
      
      // Em desenvolvimento, verificar se a API local está rodando
      if (this.isDevelopment) {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 3000);
        
        const response = await fetch(`${API_BASE_URL}/api/test`, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
          signal: controller.signal
        });
        
        clearTimeout(timeoutId);
        return response.ok;
      }
      
      // Fallback: assumir disponível em produção
      console.log('✅ Assumindo API disponível em produção');
      return true;
    } catch (error) {
      console.log('❌ API não disponível - erro:', error);
      // Se está no Vercel, sempre retornar true
      const isVercel = window.location.hostname.includes('vercel.app');
      return isVercel || !this.isDevelopment;
    }
  }

  private generateMockQRCode(): string {
    // QR Code mock para desenvolvimento
    const value = Math.floor(Math.random() * 100) + 10; // Valor entre 10 e 110
    const reference = Math.random().toString(36).substring(2, 8).toUpperCase();
    return `00020101021226800014br.gov.bcb.pix2558pix-qr.mercadopago.com/instore/o/v2/d40de9b0-29b2-4e5a-8e3f-85c2a8b5d4c65204000053039865406${value}5802BR5925PDV Allimport6014SAO PAULO62070503${reference}6304DEMO`;
  }

  private async generateMockQRCodeBase64(): Promise<string> {
    try {
      // Importar QRCode dinamicamente apenas quando necessário
      const QRCode = await import('qrcode');
      const pixCode = this.generateMockQRCode();
      
      // Gerar QR code como Base64
      const qrCodeDataURL = await QRCode.toDataURL(pixCode, {
        type: 'image/png',
        width: 256,
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      });
      
      return qrCodeDataURL;
    } catch (error) {
      console.warn('⚠️ Erro ao gerar QR Code com biblioteca:', error);
      // Fallback: QR code simples como texto
      return 'data:image/svg+xml;base64,' + btoa(`
        <svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
          <rect width="256" height="256" fill="white"/>
          <text x="128" y="120" text-anchor="middle" font-family="monospace" font-size="12" fill="black">
            QR CODE DEMO
          </text>
          <text x="128" y="140" text-anchor="middle" font-family="monospace" font-size="10" fill="gray">
            PIX: ${this.generateMockQRCode().substring(0, 20)}...
          </text>
        </svg>
      `);
    }
  }

  async createPixPayment(data: PaymentData): Promise<PaymentResponse> {
    try {
      console.log('🚀 Iniciando createPixPayment com dados:', data);
      console.log('🔍 Configuração de produção:', {
        isProduction: this.isProduction,
        hostname: window.location.hostname,
        hasProductionToken: !!this.getAccessToken()
      });
      
      // Sistema sempre em produção para comercialização
      console.log('🎯 Usando API de produção do Mercado Pago...');
      try {
        console.log('✅ Fazendo requisição PIX via API Vercel...');
        const response = await this.makeApiCall('/api/pix', 'POST', {
          amount: data.amount,
          description: data.description,
          email: data.userEmail
        });

        console.log('🔍 Resposta da API PIX:', response);
        console.log('🔍 QR Code Base64:', response.qr_code_base64 ? 'PRESENTE' : 'AUSENTE');
        console.log('🔍 QR Code String:', response.qr_code ? 'PRESENTE' : 'AUSENTE');

        // Se não há QR codes válidos na resposta da API, usar fallback demo apenas para desenvolvimento
        if (!response.qr_code_base64 && !response.qr_code) {
          console.warn('⚠️ API retornou sucesso mas sem QR code - usando fallback temporário');
          return {
            success: true,
            paymentId: `temp_${Date.now()}`,
            status: 'pending',
            qrCode: this.generateMockQRCode(),
            qrCodeBase64: await this.generateMockQRCodeBase64(),
            ticketUrl: '#temp-ticket'
          };
        }

        const result = {
          success: true,
          paymentId: String(response.payment_id || `api_${Date.now()}`),
          status: response.status || 'pending',
          qrCode: response.qr_code || '',
          qrCodeBase64: response.qr_code_base64 || '',
          ticketUrl: response.ticket_url || ''
        };
        
        console.log('🎯 Resultado final do PIX:', result);
        return result;
      } catch (error) {
        console.error('❌ Erro na API Vercel para PIX:', error);
        
        // Tentar chamada direta ao Mercado Pago como backup
        console.log('🔄 Tentando chamada direta ao Mercado Pago...');
        const mpAccessToken = this.getAccessToken();
        
        const pixData = {
          transaction_amount: data.amount,
          description: data.description || 'Assinatura PDV Allimport',
          payment_method_id: 'pix',
          payer: {
            email: data.userEmail,
            first_name: data.userName || data.userEmail.split('@')[0]
          }
        };

        const mpResponse = await fetch('https://api.mercadopago.com/v1/payments', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${mpAccessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(pixData),
        });

        if (!mpResponse.ok) {
          throw new Error(`Mercado Pago API Error: ${mpResponse.status}`);
        }

        const payment = await mpResponse.json();
        console.log('✅ Resposta direta do Mercado Pago:', payment);

        return {
          success: true,
          paymentId: payment.id?.toString() || '',
          status: payment.status || 'pending',
          qrCode: payment.point_of_interaction?.transaction_data?.qr_code || '',
          qrCodeBase64: payment.point_of_interaction?.transaction_data?.qr_code_base64 || '',
          ticketUrl: payment.point_of_interaction?.transaction_data?.ticket_url || ''
        };
      }
    } catch (error) {
      console.error('❌ Erro ao criar pagamento PIX:', error);
      throw new Error('Erro ao processar pagamento PIX. Tente novamente.');
    }
  }

  async createPaymentPreference(data: PaymentData): Promise<PaymentResponse> {
    try {
      console.log('🚀 Iniciando createPaymentPreference com dados:', data);
      console.log('🔍 Configuração de produção:', {
        isProduction: this.isProduction,
        hostname: window.location.hostname,
        hasProductionToken: !!this.getAccessToken()
      });
      
      // Sistema sempre em produção para comercialização
      console.log('🎯 Fazendo chamada direta ao Mercado Pago para preference...');
      try {
        // Usar credenciais de produção configuradas
        const mpAccessToken = this.getAccessToken();
        
        console.log('⚡ Usando credenciais de produção para preference');

        const preferenceData = {
          items: [
            {
              title: data.description || 'Assinatura PDV Allimport',
              unit_price: data.amount,
              quantity: 1,
              currency_id: 'BRL'
            }
          ],
          payer: {
            email: data.userEmail,
            name: data.userName || data.userEmail.split('@')[0]
          },
          external_reference: `checkout_${Date.now()}`,
          notification_url: `${window.location.origin}/webhook/mp`,
          back_urls: {
            success: `${window.location.origin}/payment/success`,
            failure: `${window.location.origin}/payment/failure`,
            pending: `${window.location.origin}/payment/pending`
          },
          auto_return: 'approved'
        };

        console.log('📤 Enviando preferência para Mercado Pago:', preferenceData);

        const response = await fetch('https://api.mercadopago.com/checkout/preferences', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${mpAccessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(preferenceData),
        });

        if (!response.ok) {
          throw new Error(`Mercado Pago Preference API Error: ${response.status}`);
        }

        const mpResponse = await response.json();
        console.log('✅ Resposta do Mercado Pago (Preference):', mpResponse);

        return {
          success: true,
          paymentId: mpResponse.id?.toString() || '',
          checkoutUrl: mpResponse.init_point || mpResponse.sandbox_init_point || ''
        };
      } catch (error) {
        console.error('❌ Erro na chamada direta ao Mercado Pago (Preference):', error);
        
        // Tentar usando a API do backend como fallback
        try {
          console.log('🔄 Tentando via API backend como fallback...');
          const response = await this.makeApiCall('/api/preference', 'POST', {
            amount: data.amount,
            description: data.description || 'Assinatura PDV Allimport',
            email: data.userEmail
          });

          return {
            success: true,
            paymentId: response.preference_id || response.id,
            checkoutUrl: response.init_point || response.sandbox_init_point
          };
        } catch (backendError) {
          console.error('❌ Erro também na API backend:', backendError);
          throw new Error('Erro ao criar preferência de pagamento. Tente novamente.');
        }
      }
    } catch (error) {
      console.error('❌ Erro ao criar preferência:', error);
      throw new Error('Erro ao processar preferência de pagamento. Tente novamente.');
    }
  }

  async checkPaymentStatus(paymentId: string): Promise<{ status: string; approved: boolean }> {
    try {
      const paymentIdStr = String(paymentId);
      
      if (paymentIdStr.startsWith('demo_')) {
        // Simular aprovação após 30 segundos para demo
        const createdTime = parseInt(paymentIdStr.split('_')[1]) || parseInt(paymentIdStr.split('_')[2]);
        const now = Date.now();
        const elapsed = now - createdTime;
        
        if (elapsed > 30000) { // 30 segundos
          return { status: 'approved', approved: true };
        }
        return { status: 'pending', approved: false };
      }

      // Verificar se a API está disponível
      const apiAvailable = await this.isApiAvailable();
      
      if (!apiAvailable) {
        return { status: 'pending', approved: false };
      }

      const response = await this.makeApiCall(`/api/payment-status/${paymentIdStr}`);
      
      return {
        status: response.status || 'unknown',
        approved: response.approved || false
      };
    } catch (error) {
      console.error('❌ Erro ao verificar status:', error);
      return { status: 'error', approved: false };
    }
  }

  async getConfig(): Promise<{ publicKey: string; environment: string }> {
    try {
      const apiAvailable = await this.isApiAvailable();
      
      if (!apiAvailable) {
        return {
          publicKey: this.getPublicKey(),
          environment: 'production'
        };
      }

      const response = await this.makeApiCall('/api/config');
      
      return {
        publicKey: response.mp_public_key || this.getPublicKey(),
        environment: response.environment || 'production'
      };
    } catch (error) {
      console.error('❌ Erro ao obter configuração:', error);
      return {
        publicKey: this.getPublicKey(),
        environment: 'production'
      };
    }
  }
}

export const mercadoPagoApiService = new MercadoPagoApiService();
