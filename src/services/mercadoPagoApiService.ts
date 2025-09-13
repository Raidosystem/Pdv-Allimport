// API Backend Service para integração com Mercado Pago
const isDevelopment = import.meta.env.DEV && import.meta.env.VITE_DEV_MODE !== 'false';
const isProduction = window.location.hostname.includes('vercel.app') || 
                    window.location.hostname.includes('pdv-allimport') ||
                    import.meta.env.VITE_DEV_MODE === 'false';

// Em desenvolvimento local, usar origem atual. Em produção, usar Vercel.
const API_BASE_URL = isProduction 
  ? window.location.origin 
  : window.location.origin; // Sempre usar a mesma origem

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
        console.log('✅ Detectado ambiente Vercel - API disponível');
        return true;
      }
      
      // Em desenvolvimento local, não tentar conectar para evitar erros
      console.log('⚠️ Modo desenvolvimento - usando fallback local');
      return false;
    } catch (error) {
      console.log('❌ API não disponível - erro:', error);
      return false;
    }
  }

  private generateMockQRCode(): string {
    // Gerar código PIX mais realístico baseado no padrão brasileiro
    const pixCode = `00020126580014br.gov.bcb.pix0136${this.PRODUCTION_ACCESS_TOKEN.substring(8, 44)}5204000053039865802BR5925PDV ALLIMPORT LTDA ME6009SAO PAULO62070503***6304`;
    
    // Calcular checksum simples para o código
    const checksum = Array.from(pixCode)
      .reduce((sum, char) => sum + char.charCodeAt(0), 0)
      .toString(16)
      .toUpperCase()
      .substring(0, 4);
    
    return pixCode + checksum;
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
      
      // Sempre tentar usar a API do Vercel para PIX
      console.log('🎯 Fazendo requisição PIX via API Vercel...');
      try {
        const response = await this.makeApiCall('/api/pix', 'POST', {
          amount: data.amount,
          description: data.description,
          email: data.userEmail
        });

        console.log('🔍 Resposta da API PIX:', response);
        
        if (response && response.success && (response.qr_code || response.qr_code_base64)) {
          const result = {
            success: true,
            paymentId: String(response.payment_id),
            status: response.status || 'pending',
            qrCode: response.qr_code || '',
            qrCodeBase64: response.qr_code_base64 || '',
            ticketUrl: response.ticket_url || ''
          };
          
          console.log('🎯 PIX criado com sucesso:', result);
          return result;
        } else {
          throw new Error('Resposta inválida da API');
        }
      } catch (error) {
        console.error('❌ Erro na API PIX:', error);
        throw new Error(`Erro ao gerar PIX: ${error instanceof Error ? error.message : 'Erro desconhecido'}`);
      }
      
    } catch (error) {
      console.error('❌ Erro ao criar pagamento PIX:', error);
      throw new Error('Erro ao processar pagamento PIX. Verifique sua conexão e tente novamente.');
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
      
      // Usar API do Vercel para preference (cartão de crédito)
      console.log('🎯 Fazendo requisição de preferência via API Vercel...');
      try {
        const response = await this.makeApiCall('/api/preference', 'POST', {
          amount: data.amount,
          description: data.description || 'Assinatura PDV Allimport',
          email: data.userEmail
        });

        console.log('🔍 Resposta da API Preference:', response);

        if (response && response.success && (response.init_point || response.sandbox_init_point)) {
          return {
            success: true,
            paymentId: response.preference_id,
            checkoutUrl: response.init_point || response.sandbox_init_point,
            status: 'pending'
          };
        } else {
          throw new Error('Resposta inválida da API de preferência');
        }
      } catch (error) {
        console.error('❌ Erro na API de preferência:', error);
        return {
          success: false,
          error: 'Erro ao criar preferência de pagamento. Tente novamente.'
        };
      }
      
    } catch (error) {
      console.error('❌ Erro ao criar preferência:', error);
      return {
        success: false,
        error: 'Erro ao processar pagamento. Tente novamente.'
      };
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
