import React from 'react';

interface ReceiptProps {
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
}

const Receipt: React.FC<ReceiptProps> = ({ 
  sale, 
  customer, 
  storeName = "PDV Allimport",
  storeInfo,
  cashReceived = 0,
  changeAmount = 0
}) => {
  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('pt-BR');
  };

  const receiptStyle = {
    width: '80mm',
    maxWidth: '302px', // 80mm = ~302px
    margin: '0 auto',
    padding: '10px',
    fontFamily: 'monospace',
    fontSize: '12px',
    lineHeight: '1.2',
    backgroundColor: 'white',
    color: 'black'
  };

  // Montar endereço completo
  const enderecoCompleto = storeInfo?.logradouro && storeInfo?.numero
    ? `${storeInfo.logradouro}, ${storeInfo.numero}${storeInfo.complemento ? ` - ${storeInfo.complemento}` : ''}`
    : storeInfo?.address || '';
  
  const bairroCidade = [storeInfo?.bairro, storeInfo?.cidade].filter(Boolean).join(' - ');
  const cepFormatado = storeInfo?.cep ? `CEP: ${storeInfo.cep}` : '';

  return (
    <div style={receiptStyle} id="receipt-content">
      {/* Cabeçalho da Loja com Logo */}
      <div style={{ textAlign: 'center', marginBottom: '15px', borderBottom: '1px dashed #000', paddingBottom: '10px' }}>
        {/* Logo da Empresa */}
        {storeInfo?.logo && (
          <div style={{ marginBottom: '10px' }}>
            <img 
              src={storeInfo.logo} 
              alt="Logo"
              style={{ 
                maxWidth: '120px', 
                maxHeight: '80px', 
                objectFit: 'contain',
                margin: '0 auto',
                display: 'block'
              }} 
            />
          </div>
        )}
        
        {/* Nome da Loja */}
        <div style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '3px' }}>
          {storeName}
        </div>
        
        {/* Razão Social (se diferente do nome) */}
        {storeInfo?.razao_social && storeInfo.razao_social !== storeName && (
          <div style={{ fontSize: '9px', marginBottom: '5px', color: '#555' }}>
            {storeInfo.razao_social}
          </div>
        )}
        
        {/* Endereço Completo */}
        {enderecoCompleto && (
          <div style={{ fontSize: '10px', marginBottom: '2px' }}>
            {enderecoCompleto}
          </div>
        )}
        {bairroCidade && (
          <div style={{ fontSize: '10px', marginBottom: '2px' }}>
            {bairroCidade}
          </div>
        )}
        {cepFormatado && (
          <div style={{ fontSize: '10px', marginBottom: '2px' }}>
            {cepFormatado}
          </div>
        )}
        
        {/* Telefone */}
        {storeInfo?.phone && (
          <div style={{ fontSize: '10px', marginBottom: '2px' }}>
            Tel: {storeInfo.phone}
          </div>
        )}
        
        {/* Email */}
        {storeInfo?.email && (
          <div style={{ fontSize: '10px', marginBottom: '2px' }}>
            Email: {storeInfo.email}
          </div>
        )}
        
        {/* CNPJ */}
        {storeInfo?.cnpj && (
          <div style={{ fontSize: '10px' }}>
            CNPJ: {storeInfo.cnpj}
          </div>
        )}
      </div>

      {/* Informações da Venda */}
      <div style={{ marginBottom: '15px', fontSize: '10px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between' }}>
          <span>Cupom:</span>
          <span>#{sale.id.slice(-8).toUpperCase()}</span>
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between' }}>
          <span>Data:</span>
          <span>{formatDate(sale.created_at)}</span>
        </div>
        {customer && (
          <>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span>Cliente:</span>
              <span>{customer.name}</span>
            </div>
            {customer.document && (
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span>CPF/CNPJ:</span>
                <span>{customer.document}</span>
              </div>
            )}
            {customer.phone && (
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span>Telefone:</span>
                <span>{customer.phone}</span>
              </div>
            )}
          </>
        )}
      </div>

      {/* Linha separadora */}
      <div style={{ borderTop: '1px dashed #000', marginBottom: '10px' }}></div>

      {/* Itens da Venda */}
      <div style={{ marginBottom: '15px' }}>
        <div style={{ fontSize: '11px', fontWeight: 'bold', marginBottom: '5px' }}>
          ITENS DA VENDA
        </div>
        {sale.items.map((item, index) => (
          <div key={index} style={{ marginBottom: '8px', fontSize: '10px' }}>
            <div style={{ fontWeight: 'bold' }}>
              {item.product?.name || `Produto ${item.product_id}`}
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span>{item.quantity} x {formatCurrency(item.unit_price)}</span>
              <span>{formatCurrency(item.total_price)}</span>
            </div>
            {item.product?.sku && (
              <div style={{ fontSize: '9px', color: '#666' }}>
                SKU: {item.product.sku}
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Linha separadora */}
      <div style={{ borderTop: '1px dashed #000', marginBottom: '10px' }}></div>

      {/* Totais */}
      <div style={{ marginBottom: '15px', fontSize: '11px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '3px' }}>
          <span>Subtotal:</span>
          <span>{formatCurrency(sale.total_amount + sale.discount_amount)}</span>
        </div>
        {sale.discount_amount > 0 && (
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '3px' }}>
            <span>Desconto:</span>
            <span>-{formatCurrency(sale.discount_amount)}</span>
          </div>
        )}
        <div style={{ 
          display: 'flex', 
          justifyContent: 'space-between', 
          fontSize: '13px', 
          fontWeight: 'bold',
          borderTop: '1px solid #000',
          paddingTop: '5px',
          marginTop: '5px'
        }}>
          <span>TOTAL:</span>
          <span>{formatCurrency(sale.total_amount)}</span>
        </div>
      </div>

      {/* Forma de Pagamento */}
      <div style={{ marginBottom: '15px', fontSize: '10px' }}>
        <div style={{ fontWeight: 'bold', marginBottom: '5px' }}>
          FORMA DE PAGAMENTO
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between' }}>
          <span>
            {sale.payment_method === 'cash' ? 'Dinheiro' : 
             sale.payment_method === 'card' ? 'Cartão' :
             sale.payment_method === 'pix' ? 'PIX' : 
             sale.payment_method === 'mixed' ? 'Misto' : sale.payment_method}:
          </span>
          <span>{formatCurrency(sale.total_amount)}</span>
        </div>
        
        {sale.payment_method === 'cash' && cashReceived > 0 && (
          <>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span>Dinheiro Recebido:</span>
              <span>{formatCurrency(cashReceived)}</span>
            </div>
            {changeAmount > 0 && (
              <div style={{ display: 'flex', justifyContent: 'space-between', fontWeight: 'bold' }}>
                <span>Troco:</span>
                <span>{formatCurrency(changeAmount)}</span>
              </div>
            )}
          </>
        )}
      </div>

      {/* Linha separadora */}
      <div style={{ borderTop: '1px dashed #000', marginBottom: '10px' }}></div>

      {/* Rodapé */}
      <div style={{ textAlign: 'center', fontSize: '9px', marginBottom: '10px' }}>
        <div style={{ marginBottom: '5px' }}>
          Obrigado pela preferência!
        </div>
        <div style={{ marginBottom: '5px' }}>
          Volte sempre!
        </div>
        <div style={{ marginTop: '10px', fontSize: '8px' }}>
          Sistema PDV Allimport
        </div>
        <div style={{ fontSize: '8px' }}>
          {new Date().toLocaleString('pt-BR')}
        </div>
      </div>

      {/* Espaço para corte */}
      <div style={{ height: '20px' }}></div>
    </div>
  );
};

export default Receipt;
