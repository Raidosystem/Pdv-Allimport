import { useCallback } from 'react';

interface PrintOrdemServicoData {
  ordem: {
    id: string;
    numero_ordem?: string;
    cliente_nome: string;
    cliente_telefone?: string;
    cliente_email?: string;
    tipo: string;
    marca: string;
    modelo: string;
    cor?: string;
    numero_serie?: string;
    defeito_relatado: string;
    observacoes?: string;
    created_at?: string;
  };
  storeInfo?: {
    nome?: string;
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
  printConfig?: {
    cabecalho_personalizado?: string;
    rodape_linha1?: string;
    rodape_linha2?: string;
    rodape_linha3?: string;
    rodape_linha4?: string;
    papel_tamanho?: 'auto' | 'A4' | '80mm' | '58mm';
  };
}

// Detectar automaticamente o tamanho do papel
function detectPaperSize(): 'A4' | '80mm' | '58mm' {
  try {
    const isNarrow = window.matchMedia('print and (max-width: 90mm)').matches;
    const isVeryNarrow = window.matchMedia('print and (max-width: 62mm)').matches;
    if (isVeryNarrow) return '58mm';
    if (isNarrow) return '80mm';
    if (window.innerWidth <= 768) return '80mm';
    return 'A4';
  } catch {
    return '80mm';
  }
}

function resolvePaperSize(size?: string): 'A4' | '80mm' | '58mm' {
  if (!size || size === 'auto') return detectPaperSize();
  return size as 'A4' | '80mm' | '58mm';
}

export function usePrintOrdemServico() {
  const printOrdemServico = useCallback((data: PrintOrdemServicoData) => {
    try {
      // Formatar data
      const dataOS = data.ordem.created_at 
        ? new Date(data.ordem.created_at).toLocaleString('pt-BR')
        : new Date().toLocaleString('pt-BR');

      // Preparar cabeçalho
      const cabecalho = data.printConfig?.cabecalho_personalizado || 
        `${data.storeInfo?.nome || 'Assistência Técnica'}\n${data.storeInfo?.phone || ''}`;

      // Preparar rodapé
      const rodape = [
        data.printConfig?.rodape_linha1,
        data.printConfig?.rodape_linha2,
        data.printConfig?.rodape_linha3,
        data.printConfig?.rodape_linha4
      ].filter(Boolean).join('\n');

      // Detectar tamanho do papel (auto = detecta pela impressora)
      const paperKey = resolvePaperSize(data.printConfig?.papel_tamanho);
      const isTermica = paperKey !== 'A4';

      // Configurações por tamanho de papel
      const paperCfg = {
        '58mm': {
          pageSize: '58mm auto',
          bodyWidth: '54mm',
          fontSize: '7pt',
          titleSize: '9pt',
          subtitleSize: '8pt',
          sectionTitle: '7.5pt',
          labelSize: '7pt',
          footerSize: '6pt',
          padding: '1mm 2mm',
          borderWidth: '1px',
        },
        '80mm': {
          pageSize: '80mm auto',
          bodyWidth: '76mm',
          fontSize: '8pt',
          titleSize: '10pt',
          subtitleSize: '9pt',
          sectionTitle: '8.5pt',
          labelSize: '8pt',
          footerSize: '7pt',
          padding: '1.5mm 2mm',
          borderWidth: '1.5px',
        },
        'A4': {
          pageSize: 'A4 portrait',
          bodyWidth: '80mm',
          fontSize: '9pt',
          titleSize: '12pt',
          subtitleSize: '10pt',
          sectionTitle: '9.5pt',
          labelSize: '9pt',
          footerSize: '8pt',
          padding: '3mm 4mm',
          borderWidth: '2px',
        },
      } as const;

      const cfg = paperCfg[paperKey as keyof typeof paperCfg] || paperCfg['80mm'];

      // HTML do recibo
      const printContent = `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <title>Ordem de Serviço - ${data.ordem.numero_ordem || data.ordem.id}</title>
          <style>
            *, *::before, *::after {
              margin: 0;
              padding: 0;
              box-sizing: border-box;
            }

            @page {
              size: ${cfg.pageSize};
              margin: ${isTermica ? '0' : '10mm'};
            }

            body {
              font-family: 'Courier New', 'Lucida Console', monospace;
              font-size: ${cfg.fontSize};
              line-height: 1.35;
              color: #000;
              width: ${cfg.bodyWidth};
              max-width: ${cfg.bodyWidth};
              margin: 0 auto;
              padding: ${cfg.padding};
              -webkit-print-color-adjust: exact !important;
              print-color-adjust: exact !important;
            }

            @media print {
              html, body {
                width: ${isTermica ? cfg.bodyWidth : 'auto'};
                margin: ${isTermica ? '0' : '0 auto'} !important;
              }
            }

            .recibo {
              border: ${cfg.borderWidth} solid #000;
              padding: ${cfg.padding};
            }
            
            .cabecalho {
              text-align: center;
              border-bottom: 1.5px dashed #000;
              padding-bottom: 2mm;
              margin-bottom: 2.5mm;
              font-weight: bold;
              font-size: ${cfg.fontSize};
            }
            
            .titulo {
              font-size: ${cfg.titleSize};
              font-weight: bold;
              text-align: center;
              margin-bottom: 1mm;
            }
            
            .numero-os {
              font-size: ${cfg.subtitleSize};
              text-align: center;
              margin-bottom: 2.5mm;
            }
            
            .secao {
              margin-bottom: 2.5mm;
              border-bottom: 0.5px solid #ccc;
              padding-bottom: 2mm;
            }
            
            .secao-titulo {
              font-weight: bold;
              font-size: ${cfg.sectionTitle};
              margin-bottom: 1mm;
              text-decoration: underline;
            }
            
            .linha {
              margin: 0.8mm 0;
              font-size: ${cfg.labelSize};
            }
            
            .label {
              font-weight: bold;
              display: inline-block;
              min-width: ${isTermica ? '18mm' : '22mm'};
            }
            
            .rodape {
              border-top: 1.5px dashed #000;
              padding-top: 2mm;
              margin-top: 2.5mm;
              text-align: center;
              font-size: ${cfg.footerSize};
            }
            
            .observacoes-texto {
              white-space: pre-wrap;
              word-wrap: break-word;
              overflow-wrap: break-word;
              margin-top: 1mm;
              padding: 1mm 1.5mm;
              background: #f5f5f5;
              border-left: 2px solid #333;
              font-size: ${cfg.labelSize};
            }

            .assinaturas {
              margin-top: ${isTermica ? '4mm' : '12mm'};
              display: flex;
              justify-content: space-between;
              gap: ${isTermica ? '3mm' : '10mm'};
            }

            .assinatura {
              width: 48%;
              text-align: center;
            }

            .assinatura-linha {
              border-top: 1px solid #333;
              margin-top: ${isTermica ? '6mm' : '18mm'};
              padding-top: 0.5mm;
              font-size: ${cfg.footerSize};
            }
          </style>
        </head>
        <body>
          <div class="recibo">
            <!-- Cabeçalho -->
            <div class="cabecalho">
              <div style="white-space: pre-line;">${cabecalho}</div>
            </div>
            
            <!-- Título -->
            <div class="titulo">ORDEM DE SERVIÇO</div>
            <div class="numero-os">Nº ${data.ordem.numero_ordem || data.ordem.id.substring(0, 8).toUpperCase()}</div>
            
            <!-- Cliente -->
            <div class="secao">
              <div class="secao-titulo">CLIENTE</div>
              <div class="linha">
                <span class="label">Nome:</span> ${data.ordem.cliente_nome || 'Não informado'}
              </div>
              ${data.ordem.cliente_telefone ? `
                <div class="linha">
                  <span class="label">Telefone:</span> ${data.ordem.cliente_telefone}
                </div>
              ` : ''}
              ${data.ordem.cliente_email ? `
                <div class="linha">
                  <span class="label">Email:</span> ${data.ordem.cliente_email}
                </div>
              ` : ''}
            </div>
            
            <!-- Equipamento -->
            <div class="secao">
              <div class="secao-titulo">EQUIPAMENTO</div>
              <div class="linha">
                <span class="label">Tipo:</span> ${data.ordem.tipo}
              </div>
              <div class="linha">
                <span class="label">Marca:</span> ${data.ordem.marca}
              </div>
              <div class="linha">
                <span class="label">Modelo:</span> ${data.ordem.modelo}
              </div>
              ${data.ordem.cor ? `
                <div class="linha">
                  <span class="label">Cor:</span> ${data.ordem.cor}
                </div>
              ` : ''}
              ${data.ordem.numero_serie ? `
                <div class="linha">
                  <span class="label">Série:</span> ${data.ordem.numero_serie}
                </div>
              ` : ''}
            </div>
            
            <!-- Defeito Relatado -->
            <div class="secao">
              <div class="secao-titulo">DEFEITO RELATADO</div>
              <div class="observacoes-texto">${data.ordem.defeito_relatado}</div>
            </div>
            
            <!-- Observações -->
            ${data.ordem.observacoes ? `
              <div class="secao">
                <div class="secao-titulo">OBSERVAÇÕES</div>
                <div class="observacoes-texto">${data.ordem.observacoes}</div>
              </div>
            ` : ''}
            
            <!-- Data -->
            <div class="secao" style="border-bottom: none;">
              <div class="linha">
                <span class="label">Data:</span> ${dataOS}
              </div>
            </div>
            
            <!-- Assinaturas -->
            <div class="assinaturas">
              <div class="assinatura">
                <div class="assinatura-linha">Assinatura do Cliente</div>
              </div>
              <div class="assinatura">
                <div class="assinatura-linha">Assinatura da Empresa</div>
              </div>
            </div>

            <!-- Rodapé -->
            ${rodape ? `
              <div class="rodape">
                <div style="white-space: pre-line;">${rodape}</div>
              </div>
            ` : ''}
          </div>
        </body>
        </html>
      `;

      // Abrir janela de impressão
      setTimeout(() => {
        const printWindow = window.open('', '_blank');
        if (!printWindow) {
          throw new Error('Não foi possível abrir a janela de impressão. Verifique se pop-ups estão bloqueados.');
        }

        printWindow.document.write(printContent);
        printWindow.document.close();

        printWindow.onload = () => {
          setTimeout(() => {
            printWindow.focus();
            printWindow.print();
            
            printWindow.onafterprint = () => {
              setTimeout(() => printWindow.close(), 500);
            };
            
            // Fallback: fechar após 30s
            setTimeout(() => {
              if (!printWindow.closed) printWindow.close();
            }, 30000);
          }, 250);
        };
      }, 100);
    } catch (error) {
      console.error('❌ Erro ao imprimir ordem de serviço:', error);
      throw error;
    }
  }, []);

  return { printOrdemServico };
}
