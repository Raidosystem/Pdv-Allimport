import { useCallback } from 'react';

interface PrintReceiptData {
  sale: {
    id: string;
    total_amount: number;
    discount_amount: number;
    payment_method: string;
    payment_details?: any;
    created_at: string;
    items: Array<{
      product_id: string;
      quantity: number;
      unit_price: number;
      total_price: number;
      product?: {
        name: string;
        sku?: string;
      };
    }>;
  };
  customer?: {
    id: string;
    name: string;
    email?: string;
    phone?: string;
    document?: string;
  } | null;
  storeName?: string;
  storeInfo?: {
    logo?: string;
    address?: string;
    phone?: string;
    cnpj?: string;
    razao_social?: string;
    email?: string;
    // Endereço completo separado
    logradouro?: string;
    numero?: string;
    complemento?: string;
    bairro?: string;
    cidade?: string;
    estado?: string;
    cep?: string;
  };
  cashReceived?: number;
  changeAmount?: number;
  // Configurações de impressão personalizadas
  printConfig?: {
    // Textos personalizados
    cabecalho_personalizado?: string;
    rodape_linha1?: string;
    rodape_linha2?: string;
    rodape_linha3?: string;
    rodape_linha4?: string;
    // Configurações de fonte
    fonte_tamanho?: 'pequena' | 'media' | 'grande';
    fonte_intensidade?: 'normal' | 'medio' | 'forte';
    fonte_negrito?: boolean;
    // Outras configurações
    papel_tamanho?: 'A4' | '80mm' | '58mm';
    logo_recibo?: boolean;
  };
}

export function usePrintReceipt() {
  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('pt-BR');
  };

  const generateReceiptHTML = (data: PrintReceiptData) => {
    const { sale, customer, storeName = "RaVal pdv", storeInfo, cashReceived = 0, changeAmount = 0, printConfig } = data;
    
    // Debug: verificar dados do cliente
    console.log('🧾 Gerando HTML do cupom:', {
      temCliente: !!customer,
      nomeCliente: customer?.name,
      customer,
      printConfig
    });

    // Mapear configurações de tamanho de fonte
    const fontSizeMap = {
      'pequena': '10px',
      'media': '12px',
      'grande': '14px'
    };
    const baseFontSize = fontSizeMap[printConfig?.fonte_tamanho || 'media'];

    // Mapear configurações de intensidade (peso da fonte + filtro CSS)
    const fontIntensityConfig = {
      'normal': { weight: 'normal', filter: 'none', stroke: '0' },
      'medio': { weight: '500', filter: 'contrast(1.2)', stroke: '0.3px' },
      'forte': { weight: 'bold', filter: 'contrast(1.5)', stroke: '0.5px' }
    };
    const intensitySettings = fontIntensityConfig[printConfig?.fonte_intensidade || 'normal'];

    // Aplicar negrito (se configurado, sobrescreve o peso da intensidade)
    const fontWeight = printConfig?.fonte_negrito ? 'bold' : intensitySettings.weight;
    const fontFilter = intensitySettings.filter;
    const textStroke = intensitySettings.stroke;

    // Tamanho do papel
    const paperSize = printConfig?.papel_tamanho || '80mm';
    const paperWidth = paperSize === 'A4' ? '210mm' : paperSize === '58mm' ? '58mm' : '80mm';
    
    return `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <title>Comprovante de Venda</title>
          <style>
            * {
              margin: 0;
              padding: 0;
              box-sizing: border-box;
            }
            
            body {
              font-family: 'Courier New', monospace;
              background: white;
              margin: 0;
              padding: 5px;
              font-size: ${baseFontSize};
              font-weight: ${fontWeight};
              color: #000;
              filter: ${fontFilter};
            }
            
            @media print {
              body {
                margin: 0;
                padding: 0;
              }
              
              @page {
                size: ${paperWidth} auto;
                margin: 0;
              }
              
              * {
                -webkit-print-color-adjust: exact !important;
                color-adjust: exact !important;
                print-color-adjust: exact !important;
              }
            }
            
            .receipt {
              width: ${paperWidth};
              max-width: ${paperSize === 'A4' ? '210mm' : paperSize === '58mm' ? '220px' : '302px'};
              margin: 0 auto;
              padding: 10px;
              font-size: ${baseFontSize};
              line-height: 1.2;
              color: #000;
              font-weight: ${fontWeight};
              -webkit-text-stroke: ${textStroke} black;
            }
            
            .header {
              text-align: center;
              margin-bottom: 15px;
              border-bottom: 1px dashed #000;
              padding-bottom: 10px;
            }
            
            .store-name {
              font-size: 16px;
              font-weight: bold;
              margin-bottom: 5px;
            }
            
            .store-info {
              font-size: 10px;
              margin-bottom: 2px;
            }
            
            .sale-info {
              margin-bottom: 15px;
              font-size: 10px;
            }
            
            .info-row {
              display: flex;
              justify-content: space-between;
              margin-bottom: 2px;
            }
            
            .separator {
              border-top: 1px dashed #000;
              margin: 10px 0;
            }
            
            .items-section {
              margin-bottom: 15px;
            }
            
            .items-title {
              font-size: 11px;
              font-weight: bold;
              margin-bottom: 5px;
            }
            
            .item {
              margin-bottom: 8px;
              font-size: 10px;
            }
            
            .item-name {
              font-weight: bold;
            }
            
            .item-details {
              display: flex;
              justify-content: space-between;
            }
            
            .item-sku {
              font-size: 9px;
              color: #666;
            }
            
            .totals {
              margin-bottom: 15px;
              font-size: 11px;
            }
            
            .total-row {
              display: flex;
              justify-content: space-between;
              margin-bottom: 3px;
            }
            
            .total-final {
              display: flex;
              justify-content: space-between;
              font-size: 13px;
              font-weight: bold;
              border-top: 1px solid #000;
              padding-top: 5px;
              margin-top: 5px;
            }
            
            .payment-section {
              margin-bottom: 15px;
              font-size: 10px;
            }
            
            .payment-title {
              font-weight: bold;
              margin-bottom: 5px;
            }
            
            .footer {
              text-align: center;
              font-size: 9px;
              margin-bottom: 10px;
            }
            
            .footer-info {
              font-size: 8px;
              margin-top: 10px;
            }
          </style>
        </head>
        <body>
          <div class="receipt">
            <!-- Cabeçalho da Loja -->
            <div class="header">
              ${(printConfig?.logo_recibo !== false && storeInfo?.logo) ? `
                <div style="margin-bottom: 10px;">
                  <img src="${storeInfo.logo}" alt="Logo" style="max-width: 120px; max-height: 80px; object-fit: contain; margin: 0 auto; display: block;" />
                </div>
              ` : ''}
              ${printConfig?.cabecalho_personalizado ? `
                <div class="store-info" style="white-space: pre-line; font-weight: bold;">
                  ${printConfig.cabecalho_personalizado}
                </div>
              ` : `
                <div class="store-name">${storeName}</div>
                ${storeInfo?.logradouro && storeInfo?.numero ? `
                  <div class="store-info">${storeInfo.logradouro}, ${storeInfo.numero}${storeInfo.complemento ? ` - ${storeInfo.complemento}` : ''}</div>
                ` : storeInfo?.address ? `
                  <div class="store-info">${storeInfo.address}</div>
                ` : ''}
                ${storeInfo?.bairro || storeInfo?.cidade ? `
                  <div class="store-info">${[storeInfo?.bairro, storeInfo?.cidade, storeInfo?.estado].filter(Boolean).join(' - ')}</div>
                ` : ''}
                ${storeInfo?.cep ? `<div class="store-info">CEP: ${storeInfo.cep}</div>` : ''}
                ${storeInfo?.phone ? `<div class="store-info">Tel: ${storeInfo.phone}</div>` : ''}
                ${storeInfo?.email ? `<div class="store-info">Email: ${storeInfo.email}</div>` : ''}
                ${storeInfo?.cnpj ? `<div class="store-info">CNPJ: ${storeInfo.cnpj}</div>` : ''}
              `}
            </div>

            <!-- Informações da Venda -->
            <div class="sale-info">
              <div class="info-row">
                <span>Cupom:</span>
                <span>#${sale.id.slice(-8).toUpperCase()}</span>
              </div>
              <div class="info-row">
                <span>Data:</span>
                <span>${formatDate(sale.created_at)}</span>
              </div>
              ${customer ? `
                <div class="info-row">
                  <span>Cliente:</span>
                  <span>${customer.name}</span>
                </div>
                ${customer.document ? `
                  <div class="info-row">
                    <span>CPF/CNPJ:</span>
                    <span>${customer.document}</span>
                  </div>
                ` : ''}
                ${customer.phone ? `
                  <div class="info-row">
                    <span>Telefone:</span>
                    <span>${customer.phone}</span>
                  </div>
                ` : ''}
              ` : ''}
            </div>

            <div class="separator"></div>

            <!-- Itens da Venda -->
            <div class="items-section">
              <div class="items-title">ITENS DA VENDA</div>
              ${sale.items.map(item => `
                <div class="item">
                  <div class="item-name">${item.product?.name || `Produto ${item.product_id}`}</div>
                  <div class="item-details">
                    <span>${item.quantity} x ${formatCurrency(item.unit_price)}</span>
                    <span>${formatCurrency(item.total_price)}</span>
                  </div>
                  ${item.product?.sku ? `<div class="item-sku">SKU: ${item.product.sku}</div>` : ''}
                </div>
              `).join('')}
            </div>

            <div class="separator"></div>

            <!-- Totais -->
            <div class="totals">
              <div class="total-row">
                <span>Subtotal:</span>
                <span>${formatCurrency(sale.total_amount + sale.discount_amount)}</span>
              </div>
              ${sale.discount_amount > 0 ? `
                <div class="total-row">
                  <span>Desconto:</span>
                  <span>-${formatCurrency(sale.discount_amount)}</span>
                </div>
              ` : ''}
              <div class="total-final">
                <span>TOTAL:</span>
                <span>${formatCurrency(sale.total_amount)}</span>
              </div>
            </div>

            <!-- Forma de Pagamento -->
            <div class="payment-section">
              <div class="payment-title">FORMA DE PAGAMENTO</div>
              <div class="total-row">
                <span>${sale.payment_method === 'cash' ? 'Dinheiro' : 
                         sale.payment_method === 'card' ? 'Cartão' :
                         sale.payment_method === 'pix' ? 'PIX' : 
                         sale.payment_method === 'mixed' ? 'Misto' : sale.payment_method}:</span>
                <span>${formatCurrency(sale.total_amount)}</span>
              </div>
              
              ${sale.payment_method === 'cash' && cashReceived > 0 ? `
                <div class="total-row">
                  <span>Dinheiro Recebido:</span>
                  <span>${formatCurrency(cashReceived)}</span>
                </div>
                ${changeAmount > 0 ? `
                  <div class="total-row" style="font-weight: bold;">
                    <span>Troco:</span>
                    <span>${formatCurrency(changeAmount)}</span>
                  </div>
                ` : ''}
              ` : ''}
            </div>

            <div class="separator"></div>

            <!-- Garantia -->
            <div style="text-align: center; font-size: 11px; font-weight: bold; margin-bottom: 15px; padding: 8px; border: 2px solid #000; border-radius: 5px;">
              ★ GARANTIA DE 3 MESES ★
            </div>

            <!-- Rodapé -->
            <div class="footer">
              ${printConfig?.rodape_linha1 ? `<div>${printConfig.rodape_linha1}</div>` : ''}
              ${printConfig?.rodape_linha2 ? `<div>${printConfig.rodape_linha2}</div>` : ''}
              ${printConfig?.rodape_linha3 ? `<div>${printConfig.rodape_linha3}</div>` : ''}
              ${printConfig?.rodape_linha4 ? `<div>${printConfig.rodape_linha4}</div>` : ''}
              ${!printConfig?.rodape_linha1 && !printConfig?.rodape_linha2 && !printConfig?.rodape_linha3 && !printConfig?.rodape_linha4 ? `
                <div>Obrigado pela preferência!</div>
                <div>Volte sempre!</div>
              ` : ''}
              <div class="footer-info">Sistema RaVal pdv</div>
              <div class="footer-info">${new Date().toLocaleString('pt-BR')}</div>
            </div>
          </div>
        </body>
      </html>
    `;
  };

  const printReceipt = useCallback((data: PrintReceiptData) => {
    const receiptHTML = generateReceiptHTML(data);
    
    // Criar nova janela para impressão
    const printWindow = window.open('', '_blank');
    if (printWindow) {
      printWindow.document.write(receiptHTML);
      printWindow.document.close();
      
      // Aguardar carregamento e imprimir
      printWindow.onload = () => {
        printWindow.focus();
        printWindow.print();
        
        // Fechar janela após impressão
        setTimeout(() => {
          printWindow.close();
        }, 1000);
      };
    }
  }, []);

  return {
    printReceipt
  };
}

export default usePrintReceipt;
