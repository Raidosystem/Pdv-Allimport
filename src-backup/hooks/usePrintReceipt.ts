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
    address?: string;
    phone?: string;
    cnpj?: string;
  };
  cashReceived?: number;
  changeAmount?: number;
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
    const { sale, customer, storeName = "PDV Allimport", storeInfo, cashReceived = 0, changeAmount = 0 } = data;
    
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
            }
            
            @media print {
              body {
                margin: 0;
                padding: 0;
              }
              
              @page {
                size: 80mm auto;
                margin: 0;
              }
              
              * {
                -webkit-print-color-adjust: exact !important;
                color-adjust: exact !important;
              }
            }
            
            .receipt {
              width: 80mm;
              max-width: 302px;
              margin: 0 auto;
              padding: 10px;
              font-size: 12px;
              line-height: 1.2;
              color: black;
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
              <div class="store-name">${storeName}</div>
              ${storeInfo?.address ? `<div class="store-info">${storeInfo.address}</div>` : ''}
              ${storeInfo?.phone ? `<div class="store-info">Tel: ${storeInfo.phone}</div>` : ''}
              ${storeInfo?.cnpj ? `<div class="store-info">CNPJ: ${storeInfo.cnpj}</div>` : ''}
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

            <!-- Rodapé -->
            <div class="footer">
              <div>Obrigado pela preferência!</div>
              <div>Volte sempre!</div>
              <div class="footer-info">Sistema PDV Allimport</div>
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
