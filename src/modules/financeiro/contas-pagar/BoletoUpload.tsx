import React, { useState } from 'react';
import { Upload, File, X, Check, AlertCircle } from 'lucide-react';
import { uploadBoleto } from './api';

interface BoletoUploadProps {
  contaPagarId?: string;
  onUploadSuccess?: (url: string) => void;
  onClose?: () => void;
}

const BoletoUpload: React.FC<BoletoUploadProps> = ({
  contaPagarId,
  onUploadSuccess,
  onClose
}) => {
  const [file, setFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0];
    
    if (!selectedFile) return;

    // Validar tipo de arquivo
    if (selectedFile.type !== 'application/pdf') {
      setError('Apenas arquivos PDF são permitidos');
      return;
    }

    // Validar tamanho (máx 10MB)
    if (selectedFile.size > 10 * 1024 * 1024) {
      setError('Arquivo muito grande. Máximo: 10MB');
      return;
    }

    setFile(selectedFile);
    setError(null);
    setSuccess(false);
  };

  const handleUpload = async () => {
    if (!file) return;

    setUploading(true);
    setError(null);

    try {
      const result = await uploadBoleto(file, contaPagarId);
      
      setSuccess(true);
      
      if (onUploadSuccess) {
        onUploadSuccess(result.url);
      }

      // Fechar após 2 segundos
      setTimeout(() => {
        if (onClose) {
          onClose();
        }
      }, 2000);

    } catch (err) {
      console.error('Erro ao fazer upload:', err);
      setError(err instanceof Error ? err.message : 'Erro ao fazer upload do boleto');
    } finally {
      setUploading(false);
    }
  };

  const handleRemoveFile = () => {
    setFile(null);
    setError(null);
    setSuccess(false);
  };

  const formatFileSize = (bytes: number) => {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  };

  return (
    <div className="space-y-4">
      {/* Área de Upload */}
      <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-blue-500 transition-colors">
        <input
          type="file"
          accept=".pdf"
          onChange={handleFileChange}
          className="hidden"
          id="boleto-upload"
          disabled={uploading || success}
        />
        
        <label
          htmlFor="boleto-upload"
          className={`cursor-pointer ${uploading || success ? 'opacity-50 cursor-not-allowed' : ''}`}
        >
          <Upload className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <p className="text-sm font-medium text-gray-700 mb-1">
            Clique para selecionar ou arraste o arquivo
          </p>
          <p className="text-xs text-gray-500">
            Apenas arquivos PDF (máx. 10MB)
          </p>
        </label>
      </div>

      {/* Arquivo Selecionado */}
      {file && (
        <div className="bg-gray-50 rounded-lg p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <File className="w-8 h-8 text-red-500" />
              <div>
                <p className="text-sm font-medium text-gray-900">{file.name}</p>
                <p className="text-xs text-gray-500">{formatFileSize(file.size)}</p>
              </div>
            </div>
            
            {!uploading && !success && (
              <button
                onClick={handleRemoveFile}
                className="p-1 hover:bg-gray-200 rounded transition-colors"
                title="Remover arquivo"
              >
                <X className="w-5 h-5 text-gray-600" />
              </button>
            )}

            {success && (
              <Check className="w-6 h-6 text-green-600" />
            )}
          </div>
        </div>
      )}

      {/* Mensagem de Erro */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <div className="flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
            <div>
              <p className="text-sm font-medium text-red-800">Erro no upload</p>
              <p className="text-sm text-red-700 mt-1">{error}</p>
            </div>
          </div>
        </div>
      )}

      {/* Mensagem de Sucesso */}
      {success && (
        <div className="bg-green-50 border border-green-200 rounded-lg p-4">
          <div className="flex items-start gap-3">
            <Check className="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" />
            <div>
              <p className="text-sm font-medium text-green-800">Upload concluído!</p>
              <p className="text-sm text-green-700 mt-1">
                Boleto anexado com sucesso
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Botões */}
      <div className="flex justify-end gap-3">
        {onClose && (
          <button
            onClick={onClose}
            disabled={uploading}
            className="px-4 py-2 text-gray-700 hover:text-gray-900 transition-colors disabled:opacity-50"
          >
            {success ? 'Fechar' : 'Cancelar'}
          </button>
        )}
        
        {file && !success && (
          <button
            onClick={handleUpload}
            disabled={uploading}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {uploading ? (
              <>
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                Enviando...
              </>
            ) : (
              <>
                <Upload className="w-4 h-4" />
                Fazer Upload
              </>
            )}
          </button>
        )}
      </div>
    </div>
  );
};

export default BoletoUpload;
