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
  };
}

export function usePrintOrdemServico() {
  const printOrdemServico = useCallback((data: PrintOrdemServicoData) => {
    try {
      console.log('🖨️ [PRINT] Iniciando impressão de Ordem de Serviço');
      console.log('🖨️ [PRINT] Dados recebidos:', data);
      console.log('🖨️ [PRINT] Cliente nome:', data.ordem.cliente_nome);
      console.log('🖨️ [PRINT] Estrutura ordem:', Object.keys(data.ordem));

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

      // HTML do recibo
      const printContent = `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <title>Ordem de Serviço - ${data.ordem.numero_ordem || data.ordem.id}</title>
          <style>
            @media print {
              @page { 
                margin: 10mm;
                size: A4;
              }
              body { margin: 0; }
            }
            
            body {
              font-family: 'Courier New', monospace;
              font-size: 12pt;
              line-height: 1.4;
              color: #000;
              max-width: 80mm;
              margin: 0 auto;
              padding: 10px;
            }
            
            .recibo {
              border: 2px solid #000;
              padding: 15px;
            }
            
            .cabecalho {
              text-align: center;
              border-bottom: 2px dashed #000;
              padding-bottom: 10px;
              margin-bottom: 15px;
              font-weight: bold;
            }
            
            .titulo {
              font-size: 14pt;
              font-weight: bold;
              text-align: center;
              margin-bottom: 5px;
            }
            
            .numero-os {
              font-size: 13pt;
              text-align: center;
              margin-bottom: 10px;
            }
            
            .secao {
              margin-bottom: 15px;
              border-bottom: 1px solid #ccc;
              padding-bottom: 10px;
            }
            
            .secao-titulo {
              font-weight: bold;
              font-size: 11pt;
              margin-bottom: 5px;
              text-decoration: underline;
            }
            
            .linha {
              margin: 3px 0;
            }
            
            .label {
              font-weight: bold;
              display: inline-block;
              min-width: 100px;
            }
            
            .rodape {
              border-top: 2px dashed #000;
              padding-top: 10px;
              margin-top: 15px;
              text-align: center;
              font-size: 10pt;
            }
            
            .observacoes-texto {
              white-space: pre-wrap;
              word-wrap: break-word;
              margin-top: 5px;
              padding: 5px;
              background: #f5f5f5;
              border-left: 3px solid #333;
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
            
            <!-- Rodapé -->
            ${rodape ? `
              <div class="rodape">
                <div style="white-space: pre-line; font-size: 9pt;">${rodape}</div>
              </div>
            ` : ''}
          </div>
        </body>
        </html>
      `;

      // Abrir janela de impressão (com timeout para evitar bloqueio)
      setTimeout(() => {
        const printWindow = window.open('', '_blank');
        if (!printWindow) {
          throw new Error('Não foi possível abrir a janela de impressão. Verifique se pop-ups estão bloqueados.');
        }

        printWindow.document.write(printContent);
        printWindow.document.close();

        // Aguardar carregamento e imprimir
        printWindow.onload = () => {
          setTimeout(() => {
            printWindow.focus();
            printWindow.print();
            
            // ✅ CORRIGIDO: Fechar janela automaticamente após impressão
            // Isso previne tela branca ao voltar
            printWindow.onafterprint = () => {
              console.log('✅ Impressão concluída, fechando janela');
              setTimeout(() => {
                printWindow.close();
              }, 500);
            };
            
            // Fallback: fechar após 30 segundos se usuário não imprimir
            setTimeout(() => {
              if (!printWindow.closed) {
                console.log('⚠️ Fechando janela de impressão por timeout');
                printWindow.close();
              }
            }, 30000);
          }, 250);
        };
      }, 100);

      console.log('✅ Impressão enviada com sucesso');
    } catch (error) {
      console.error('❌ Erro ao imprimir ordem de serviço:', error);
      throw error;
    }
  }, []);

  return { printOrdemServico };
}
