// API Backend Service para integração com Mercado Pago
const isDevelopment = import.meta.env.DEV;
const isLocalhost = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
const isProduction = !isLocalhost && !isDevelopment;

// URLs das APIs baseadas no ambiente
const getApiBaseUrl = () => {
  if (isLocalhost) {
    // Em desenvolvimento local, usar API local se disponível
    return 'http://localhost:3000';
  } else {
    // Em produção, usar o MESMO domínio da página atual (window.location.origin)
    // Isso evita problemas de CORS com redirect www/non-www
    return window.location.origin;
  }
};

const API_BASE_URL = getApiBaseUrl();

console.log('🔧 Configuração de ambiente:', {
  isDevelopment,
  isLocalhost,
  isProduction,
  hostname: window.location.hostname,
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
  private isProduction = isProduction;
  private isLocalDev = isLocalhost;
  
  // Credenciais de produção do Mercado Pago
  private readonly PRODUCTION_ACCESS_TOKEN = import.meta.env.VITE_MP_ACCESS_TOKEN || '';
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
      // Em desenvolvimento local, retornar erro para forçar uso do modo demonstração
      if (this.isLocalDev) {
        console.warn(`⚠️ makeApiCall bloqueado em desenvolvimento local para endpoint: ${endpoint}`);
        console.log('💡 Use apenas o modo demonstração em ambiente local.');
        throw new Error('API calls not available in local development - use demo mode');
      }

      // Para produção, usar o MESMO domínio da página atual (evita problemas de CORS com redirect www/non-www)
      const baseUrl = window.location.origin; // https://www.pdv.gruporaval.com.br OU https://pdv.gruporaval.com.br
      const url = `${baseUrl}${endpoint}`;
      
      console.log(`🌐 API Call: ${method} ${url}`);
      console.log(`🔍 Origin: ${window.location.origin}`);
      
      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
      };

      // Adicionar token de autenticação se disponível
      const token = this.getAccessToken();
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }

      const response = await fetch(url, {
        method,
        headers,
        body: body ? JSON.stringify(body) : undefined,
        mode: 'cors'
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error(`❌ API Error ${response.status}:`, errorText);
        throw new Error(`API Error: ${response.status} - ${response.statusText}`);
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
      console.log('🔍 Verificando disponibilidade da API...');
      
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

  async createPixPayment(data: PaymentData): Promise<PaymentResponse> {
    try {
      console.log('🚀 Iniciando createPixPayment com dados:', data);
      console.log('🔍 Configuração de ambiente:', {
        isProduction: this.isProduction,
        isLocalDev: this.isLocalDev,
        hostname: window.location.hostname,
        hasProductionToken: !!this.getAccessToken()
      });
      
      // SEMPRE usar modo demonstração em desenvolvimento local
      if (this.isLocalDev) {
        console.log('🎯 Ambiente local detectado - usando modo demonstração...');
        
        // Simular um delay de rede
        await new Promise(resolve => setTimeout(resolve, 1500));
        
        // Criar SVG do QR Code sem caracteres especiais
        const cleanEmail = data.userEmail.replace(/[^a-zA-Z0-9@._-]/g, '');
        const svgContent = `<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
          <rect width="256" height="256" fill="white"/>
          <g fill="black">
            <rect x="20" y="20" width="40" height="40"/>
            <rect x="80" y="20" width="20" height="20"/>
            <rect x="120" y="20" width="20" height="20"/>
            <rect x="160" y="20" width="40" height="40"/>
            <rect x="220" y="20" width="20" height="20"/>
            <rect x="20" y="80" width="20" height="20"/>
            <rect x="60" y="80" width="20" height="20"/>
            <rect x="120" y="80" width="40" height="20"/>
            <rect x="180" y="80" width="20" height="20"/>
            <rect x="220" y="80" width="20" height="20"/>
          </g>
          <text x="128" y="120" text-anchor="middle" font-family="Arial, sans-serif" font-size="12" fill="black">PIX DEMO</text>
          <text x="128" y="140" text-anchor="middle" font-family="Arial, sans-serif" font-size="10" fill="gray">Desenvolvimento</text>
          <text x="128" y="160" text-anchor="middle" font-family="Arial, sans-serif" font-size="10" fill="gray">R$ ${data.amount.toFixed(2)}</text>
          <text x="128" y="180" text-anchor="middle" font-family="Arial, sans-serif" font-size="8" fill="blue">${cleanEmail}</text>
        </svg>`;
        
        const result = {
          success: true,
          paymentId: 'demo_' + Date.now(),
          status: 'pending',
          qrCode: `00020126360014BR.GOV.BCB.PIX0114+5511999999999520400005303986540${data.amount.toFixed(2)}5802BR5925RAVAL PDV LTDA6009SAO PAULO62070503***6304`,
          qrCodeBase64: 'data:image/svg+xml;base64,' + btoa(svgContent),
          ticketUrl: ''
        };
        
        console.log('🎯 PIX demo criado com sucesso:', result);
        return result;
      }
      
      // Para produção, usar a API do Vercel
      console.log('🎯 Ambiente de produção - usando API Vercel...');
      try {
        const response = await this.makeApiCall('/api/pix', 'POST', {
          amount: data.amount,
          description: data.description,
          email: data.userEmail,
          company_id: data.userEmail, // Usar email completo para buscar na tabela subscriptions
          user_id: data.userName || data.userEmail?.split('@')[0] || 'user'
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
      console.log('🔍 Configuração de ambiente:', {
        isProduction: this.isProduction,
        isLocalDev: this.isLocalDev,
        hostname: window.location.hostname,
        hasProductionToken: !!this.getAccessToken()
      });
      
      // SEMPRE usar modo demonstração em desenvolvimento local
      if (this.isLocalDev) {
        console.log('🎯 Ambiente local detectado - usando modo demonstração...');
        
        // Simular um delay de rede
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        const result = {
          success: true,
          paymentId: 'pref_demo_' + Date.now(),
          checkoutUrl: 'https://www.mercadopago.com.br/checkout/v1/redirect?pref_id=demo_local',
          status: 'pending'
        };
        
        console.log('🎯 Preferência demo criada com sucesso:', result);
        return result;
      }
      
      // Para produção, usar a API real do Vercel
      console.log('🎯 Ambiente de produção - usando API Vercel...');
      try {
        const response = await this.makeApiCall('/api/preference', 'POST', {
          amount: data.amount,
          description: data.description,
          email: data.userEmail,
          company_id: data.userEmail, // Usar email completo para buscar na tabela subscriptions
          user_id: data.userName || data.userEmail?.split('@')[0] || 'user'
        });

        console.log('🔍 Resposta da API Preference:', response);
        
        if (response && response.success && response.init_point) {
          const result = {
            success: true,
            paymentId: response.preference_id,
            checkoutUrl: response.init_point,
            status: 'pending'
          };
          
          console.log('🎯 Preferência criada com sucesso:', result);
          return result;
        } else {
          throw new Error('Resposta inválida da API');
        }
      } catch (error) {
        console.error('❌ Erro na API Preference:', error);
        throw new Error(`Erro ao gerar preferência: ${error instanceof Error ? error.message : 'Erro desconhecido'}`);
      }
      
    } catch (error) {
      console.error('❌ Erro ao criar preferência:', error);
      throw new Error('Erro ao processar pagamento. Verifique sua conexão e tente novamente.');
    }
  }

  private async checkPaymentStatusDirect(paymentId: string): Promise<{ status: string; approved: boolean }> {
    try {
      console.log(`🔍 Verificando status direto no MP: ${paymentId}`);
      
      const response = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${this.getAccessToken()}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        console.error('❌ Erro na consulta MP:', response.status);
        return { status: 'pending', approved: false };
      }

      const paymentData = await response.json();
      console.log('✅ Status recebido do MP:', paymentData.status);

      return {
        status: paymentData.status || 'unknown',
        approved: paymentData.status === 'approved'
      };
    } catch (error) {
      console.error('❌ Erro na verificação direta:', error);
      return { status: 'error', approved: false };
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

      // Em desenvolvimento local, usar chamada direta ao Mercado Pago
      if (this.isLocalDev) {
        console.log('🔍 Verificando status diretamente no Mercado Pago...');
        return await this.checkPaymentStatusDirect(paymentIdStr);
      }

      const response = await this.makeApiCall(`/api/payment-status?paymentId=${paymentIdStr}`);
      
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
