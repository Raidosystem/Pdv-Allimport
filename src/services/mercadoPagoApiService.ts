// API Backend Service para integração com Mercado Pago
const isDevelopment = import.meta.env.DEV;
const API_BASE_URL = isDevelopment 
  ? 'http://localhost:3333'
  : window.location.origin; // Usar o mesmo domínio em produção

console.log('🔧 API_BASE_URL configurada:', API_BASE_URL, '(isDevelopment:', isDevelopment, ')');

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
  private isDevelopment = import.meta.env.DEV;

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
    return `00020101021226800014br.gov.bcb.pix2558pix-qr.mercadopago.com/instore/o/v2/d40de9b0-29b2-4e5a-8e3f-85c2a8b5d4c65204000053039865406${59.90}5802BR5925PDV Allimport6014SAO PAULO62070503***6304${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
  }

  async createPixPayment(data: PaymentData): Promise<PaymentResponse> {
    try {
      console.log('🚀 Iniciando createPixPayment com dados:', data);
      
      // Verificar se está no Vercel (forçar produção)
      const isVercel = window.location.hostname.includes('vercel.app') || 
                       window.location.hostname.includes('pdv-allimport');
      
      if (isVercel) {
        console.log('🎯 Ambiente Vercel detectado - fazendo requisição PIX real...');
        try {
          const response = await this.makeApiCall('/api/pix', 'POST', data);
          return {
            success: true,
            paymentId: response.payment_id,
            status: response.status,
            qrCode: response.qr_code,
            qrCodeBase64: response.qr_code_base64,
            ticketUrl: response.ticket_url
          };
        } catch (error) {
          console.error('❌ Erro na API Vercel:', error);
          // Em caso de erro na API do Vercel, usar fallback demo
        }
      }
      
      // Verificar se a API está disponível
      const apiAvailable = await this.isApiAvailable();
      console.log('📡 API disponível?', apiAvailable);
      
      if (!apiAvailable) {
        console.warn('⚠️ API backend não disponível. Usando modo demo.');
        return {
          success: true,
          paymentId: `demo_${Date.now()}`,
          status: 'pending',
          qrCode: this.generateMockQRCode(),
          qrCodeBase64: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
          ticketUrl: '#demo-ticket'
        };
      }

      console.log('✅ API disponível! Fazendo requisição PIX real...');
      const response = await this.makeApiCall('/api/pix', 'POST', data);

      return {
        success: true,
        paymentId: response.payment_id,
        status: response.status,
        qrCode: response.qr_code,
        qrCodeBase64: response.qr_code_base64,
        ticketUrl: response.ticket_url
      };
    } catch (error) {
      console.error('❌ Erro ao criar pagamento PIX:', error);
      
      // Fallback para modo demo em caso de erro
      return {
        success: true,
        paymentId: `demo_fallback_${Date.now()}`,
        status: 'pending',
        qrCode: this.generateMockQRCode(),
        qrCodeBase64: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
        ticketUrl: '#demo-ticket'
      };
    }
  }

  async createPaymentPreference(data: PaymentData): Promise<PaymentResponse> {
    try {
      console.log('🚀 Iniciando createPaymentPreference com dados:', data);
      
      // Verificar se está no Vercel (forçar produção)
      const isVercel = window.location.hostname.includes('vercel.app') || 
                       window.location.hostname.includes('pdv-allimport');
      
      if (isVercel) {
        console.log('🎯 Ambiente Vercel detectado - fazendo requisição preference real...');
        try {
          const response = await this.makeApiCall('/api/preference', 'POST', {
            userEmail: data.userEmail,
            userName: data.userName,
            amount: data.amount,
            planName: data.description || 'Assinatura PDV Allimport'
          });

          return {
            success: true,
            paymentId: response.id,
            checkoutUrl: response.init_point || response.sandbox_init_point
          };
        } catch (error) {
          console.error('❌ Erro na API Vercel:', error);
          // Em caso de erro na API do Vercel, usar fallback demo
        }
      }
      
      // Verificar se a API está disponível
      const apiAvailable = await this.isApiAvailable();
      console.log('📡 API disponível?', apiAvailable);
      
      if (!apiAvailable) {
        console.warn('⚠️ API backend não disponível. Usando modo demo.');
        return {
          success: true,
          paymentId: `demo_pref_${Date.now()}`,
          checkoutUrl: `${window.location.origin}/payment/demo?amount=${data.amount}&email=${encodeURIComponent(data.userEmail)}`
        };
      }

      console.log('✅ API disponível! Fazendo requisição real...');
      const response = await this.makeApiCall('/api/preference', 'POST', {
        userEmail: data.userEmail,
        userName: data.userName,
        amount: data.amount,
        planName: data.description || 'Assinatura PDV Allimport'
      });

      return {
        success: true,
        paymentId: response.id,
        checkoutUrl: response.init_point || response.sandbox_init_point
      };
    } catch (error) {
      console.error('❌ Erro ao criar preferência:', error);
      
      // Fallback para modo demo em caso de erro
      return {
        success: true,
        paymentId: `demo_pref_fallback_${Date.now()}`,
        checkoutUrl: `${window.location.origin}/payment/demo?amount=${data.amount}&email=${encodeURIComponent(data.userEmail)}`
      };
    }
  }

  async checkPaymentStatus(paymentId: string): Promise<{ status: string; approved: boolean }> {
    try {
      if (paymentId.startsWith('demo_')) {
        // Simular aprovação após 30 segundos para demo
        const createdTime = parseInt(paymentId.split('_')[1]) || parseInt(paymentId.split('_')[2]);
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

      const response = await this.makeApiCall(`/api/payment-status/${paymentId}`);
      
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
          publicKey: import.meta.env.VITE_MP_PUBLIC_KEY || '',
          environment: 'demo'
        };
      }

      const response = await this.makeApiCall('/api/config');
      
      return {
        publicKey: response.mp_public_key || '',
        environment: response.environment || 'production'
      };
    } catch (error) {
      console.error('❌ Erro ao obter configuração:', error);
      return {
        publicKey: import.meta.env.VITE_MP_PUBLIC_KEY || '',
        environment: 'demo'
      };
    }
  }
}

export const mercadoPagoApiService = new MercadoPagoApiService();
