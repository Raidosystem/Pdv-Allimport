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
  printConfig?: {
    cabecalho_personalizado?: string;
    rodape_linha1?: string;
    rodape_linha2?: string;
    rodape_linha3?: string;
    rodape_linha4?: string;
    fonte_tamanho?: 'pequena' | 'media' | 'grande';
    fonte_intensidade?: 'normal' | 'medio' | 'forte';
    fonte_negrito?: boolean;
    papel_tamanho?: 'auto' | 'A4' | '80mm' | '58mm';
    logo_recibo?: boolean;
  };
}

// Detectar automaticamente o tamanho do papel baseado na impressora do sistema
// Detectar automaticamente o tamanho do papel
// Abordagem: verificar a largura da tela como heurística
// Em dispositivos móveis/tablets → provavelmente impressora térmica
// Em desktop → verificar se tem impressora térmica ou A4
function detectPaperSize(): 'A4' | '80mm' | '58mm' {
  try {
    // Dispositivos com tela pequena geralmente estão conectados a térmicas
    if (window.innerWidth <= 1024) return '80mm';
    // Desktop com tela grande → A4
    return 'A4';
  } catch {
    return '80mm';
  }
}

// Resolver 'auto' para tamanho real de papel
function resolvePaperSize(size?: string): 'A4' | '80mm' | '58mm' {
  if (!size || size === 'auto') return detectPaperSize();
  return size as 'A4' | '80mm' | '58mm';
}

// Configurações de tamanho por tipo de papel (unidades em pt para impressoras)
const PAPER_CONFIGS = {
  '58mm': {
    pageWidth: '58mm',
    receiptMaxWidth: '54mm',
    padding: '1mm 2mm',
    fontSize: {
      pequena: '6pt',
      media: '7pt',
      grande: '8pt',
    },
    storeNameSize: '9pt',
    titleSize: '8pt',
    itemSize: '7pt',
    totalSize: '8pt',
    totalFinalSize: '9pt',
    infoSize: '6.5pt',
    footerSize: '6pt',
    footerInfoSize: '5.5pt',
    skuSize: '5.5pt',
    logoMax: '80px',
    logoHeight: '50px',
    separatorMargin: '2mm 0',
    itemMargin: '1.5mm 0',
    sectionMargin: '2mm 0',
    garantiaSize: '7pt',
    garantiaPad: '1.5mm',
  },
  '80mm': {
    pageWidth: '80mm',
    receiptMaxWidth: '76mm',
    padding: '1mm 2mm',
    fontSize: {
      pequena: '7pt',
      media: '8pt',
      grande: '9pt',
    },
    storeNameSize: '10pt',
    titleSize: '9pt',
    itemSize: '8pt',
    totalSize: '9pt',
    totalFinalSize: '10pt',
    infoSize: '7.5pt',
    footerSize: '7pt',
    footerInfoSize: '6pt',
    skuSize: '6pt',
    logoMax: '100px',
    logoHeight: '60px',
    separatorMargin: '2.5mm 0',
    itemMargin: '2mm 0',
    sectionMargin: '3mm 0',
    garantiaSize: '8pt',
    garantiaPad: '2mm',
  },
  'A4': {
    pageWidth: 'auto',
    receiptMaxWidth: '190mm',
    padding: '10mm 10mm',
    fontSize: {
      pequena: '9pt',
      media: '10pt',
      grande: '11pt',
    },
    storeNameSize: '14pt',
    titleSize: '12pt',
    itemSize: '10pt',
    totalSize: '11pt',
    totalFinalSize: '13pt',
    infoSize: '9pt',
    footerSize: '9pt',
    footerInfoSize: '8pt',
    skuSize: '8pt',
    logoMax: '150px',
    logoHeight: '100px',
    separatorMargin: '4mm 0',
    itemMargin: '3mm 0',
    sectionMargin: '5mm 0',
    garantiaSize: '10pt',
    garantiaPad: '3mm',
  },
} as const;

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

    // Selecionar configuração do papel (detecta automaticamente se 'auto' ou não definido)
    const paperKey = resolvePaperSize(printConfig?.papel_tamanho);
    const cfg = PAPER_CONFIGS[paperKey];
    const baseFontSize = cfg.fontSize[printConfig?.fonte_tamanho || 'media'];

    // Intensidade da fonte
    const fontIntensityConfig = {
      'normal': { weight: 'normal', filter: 'none', stroke: '0' },
      'medio': { weight: '500', filter: 'contrast(1.15)', stroke: '0.2px' },
      'forte': { weight: 'bold', filter: 'contrast(1.3)', stroke: '0.4px' }
    };
    const intensitySettings = fontIntensityConfig[printConfig?.fonte_intensidade || 'normal'];
    const fontWeight = printConfig?.fonte_negrito ? 'bold' : intensitySettings.weight;
    const fontFilter = intensitySettings.filter;
    const textStroke = intensitySettings.stroke;

    const isTermica = paperKey !== 'A4';

    // CSS do @page adaptativo
    const pageCSS = isTermica 
      ? `@page { size: ${cfg.pageWidth} auto; margin: 0 !important; padding: 0 !important; }`
      : `@page { size: A4 portrait; margin: 10mm; }`;

    return `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <title>Comprovante de Venda</title>
          <style>
            *, *::before, *::after {
              margin: 0;
              padding: 0;
              box-sizing: border-box;
            }

            ${pageCSS}

            html {
              ${isTermica ? 'height: auto !important; min-height: 0 !important;' : ''}
            }

            body {
              font-family: ${isTermica ? "'Courier New', 'Lucida Console', monospace" : "'Segoe UI', Arial, sans-serif"};
              background: white;
              margin: 0;
              padding: 0;
              font-size: ${baseFontSize};
              font-weight: ${fontWeight};
              color: #000;
              filter: ${fontFilter};
              line-height: 1.3;
              ${isTermica ? 'height: auto !important; min-height: 0 !important; overflow: visible !important;' : ''}
              -webkit-print-color-adjust: exact !important;
              print-color-adjust: exact !important;
            }

            @media print {
              html, body {
                ${isTermica ? `
                  width: ${cfg.pageWidth};
                  height: auto !important;
                  min-height: 0 !important;
                  margin: 0 !important;
                  padding: 0 !important;
                  overflow: visible !important;
                ` : 'width: 100%;'}
              }
              ${isTermica ? `
              /* Forçar sem espaço extra em térmicas */
              html { height: fit-content !important; }
              body { height: fit-content !important; }
              ` : ''}
            }

            .receipt {
              width: ${cfg.receiptMaxWidth};
              max-width: ${cfg.receiptMaxWidth};
              ${isTermica ? 'margin: 0;' : 'margin: 0 auto;'}
              padding: ${cfg.padding};
              font-size: ${baseFontSize};
              line-height: 1.3;
              color: #000;
              font-weight: ${fontWeight};
              ${textStroke !== '0' ? `-webkit-text-stroke: ${textStroke} black;` : ''}
              overflow-wrap: break-word;
              word-wrap: break-word;
            }

            .header {
              text-align: center;
              margin-bottom: ${cfg.sectionMargin};
              border-bottom: 1px dashed #000;
              padding-bottom: ${isTermica ? '2mm' : '3mm'};
            }

            .store-name {
              font-size: ${cfg.storeNameSize};
              font-weight: bold;
              margin-bottom: 1mm;
            }

            .store-info {
              font-size: ${cfg.infoSize};
              margin-bottom: 0.5mm;
              line-height: 1.25;
            }

            .sale-info {
              margin: ${cfg.sectionMargin};
              font-size: ${cfg.infoSize};
            }

            .info-row {
              display: flex;
              justify-content: space-between;
              margin-bottom: 0.5mm;
              gap: 2mm;
            }

            .info-row span:last-child {
              text-align: right;
              flex-shrink: 0;
            }

            .separator {
              border-top: 1px dashed #000;
              margin: ${cfg.separatorMargin};
            }

            .items-section {
              margin: ${cfg.sectionMargin};
            }

            .items-title {
              font-size: ${cfg.titleSize};
              font-weight: bold;
              margin-bottom: 1mm;
            }

            .item {
              margin: ${cfg.itemMargin};
              font-size: ${cfg.itemSize};
            }

            .item-name {
              font-weight: bold;
              overflow-wrap: break-word;
            }

            .item-details {
              display: flex;
              justify-content: space-between;
              gap: 1mm;
            }

            .item-details span:last-child {
              text-align: right;
              flex-shrink: 0;
            }

            .item-sku {
              font-size: ${cfg.skuSize};
              color: #555;
            }

            .totals {
              margin: ${cfg.sectionMargin};
              font-size: ${cfg.totalSize};
            }

            .total-row {
              display: flex;
              justify-content: space-between;
              margin-bottom: 0.5mm;
            }

            .total-row span:last-child {
              text-align: right;
              flex-shrink: 0;
            }

            .total-final {
              display: flex;
              justify-content: space-between;
              font-size: ${cfg.totalFinalSize};
              font-weight: bold;
              border-top: 1px solid #000;
              padding-top: 1mm;
              margin-top: 1mm;
            }

            .payment-section {
              margin: ${cfg.sectionMargin};
              font-size: ${cfg.infoSize};
            }

            .payment-title {
              font-weight: bold;
              font-size: ${cfg.titleSize};
              margin-bottom: 1mm;
            }

            .garantia {
              text-align: center;
              font-size: ${cfg.garantiaSize};
              font-weight: bold;
              margin: ${cfg.sectionMargin};
              padding: ${cfg.garantiaPad};
              border: 1.5px solid #000;
              border-radius: 2px;
            }

            .footer {
              text-align: center;
              font-size: ${cfg.footerSize};
              margin: ${cfg.sectionMargin};
              line-height: 1.4;
            }

            .footer-info {
              font-size: ${cfg.footerInfoSize};
              margin-top: 1.5mm;
              color: #333;
            }
          </style>
        </head>
        <body>
          <div class="receipt">
            <!-- Cabeçalho da Loja -->
            <div class="header">
              ${(printConfig?.logo_recibo !== false && storeInfo?.logo) ? `
                <div style="margin-bottom: 1.5mm;">
                  <img src="${storeInfo.logo}" alt="Logo" style="max-width: ${cfg.logoMax}; max-height: ${cfg.logoHeight}; object-fit: contain; margin: 0 auto; display: block;" />
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
              <div class="payment-title">PAGAMENTO</div>
              <div class="total-row">
                <span>${sale.payment_method === 'cash' ? 'Dinheiro' : 
                         sale.payment_method === 'card' ? 'Cartão' :
                         sale.payment_method === 'pix' ? 'PIX' : 
                         sale.payment_method === 'mixed' ? 'Misto' : sale.payment_method}:</span>
                <span>${formatCurrency(sale.total_amount)}</span>
              </div>
              ${sale.payment_method === 'cash' && cashReceived > 0 ? `
                <div class="total-row">
                  <span>Recebido:</span>
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
            <div class="garantia">
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
    
    const printWindow = window.open('', '_blank');
    if (printWindow) {
      printWindow.document.write(receiptHTML);
      printWindow.document.close();
      
      printWindow.onload = () => {
        printWindow.focus();
        printWindow.print();
        
        // Fechar após impressão
        printWindow.onafterprint = () => {
          setTimeout(() => printWindow.close(), 500);
        };
        // Fallback: fechar após 30s
        setTimeout(() => {
          if (!printWindow.closed) printWindow.close();
        }, 30000);
      };
    }
  }, []);

  return {
    printReceipt
  };
}

export default usePrintReceipt;
