import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Input } from '../ui/Input';
import { Button } from '../ui/Button';
import type { Fornecedor, FornecedorFormData } from '../../types/fornecedor';

const fornecedorSchema = z.object({
  nome: z.string().min(1, 'Nome é obrigatório'),
  cnpj: z.string().optional(),
  telefone: z.string().optional(),
  email: z.string().email('E-mail inválido').or(z.literal('')).optional(),
  endereco: z.string().optional(),
  ativo: z.boolean().default(true),
});

interface FornecedorFormProps {
  fornecedor?: Fornecedor;
  onSubmit: (data: FornecedorFormData) => Promise<void>;
  onCancel: () => void;
  isSubmitting?: boolean;
}

export function FornecedorForm({ 
  fornecedor, 
  onSubmit, 
  onCancel,
  isSubmitting = false
}: FornecedorFormProps) {
  const {
    control,
    handleSubmit,
    formState: { errors },
  } = useForm<FornecedorFormData>({
    resolver: zodResolver(fornecedorSchema),
    defaultValues: {
      nome: fornecedor?.nome || '',
      cnpj: fornecedor?.cnpj || '',
      telefone: fornecedor?.telefone || '',
      email: fornecedor?.email || '',
      endereco: fornecedor?.endereco || '',
      ativo: fornecedor?.ativo ?? true,
    },
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="md:col-span-2">
          <Controller
            name="nome"
            control={control}
            render={({ field }) => (
              <Input
                {...field}
                label="Nome *"
                error={errors.nome?.message}
                placeholder="Nome do fornecedor"
              />
            )}
          />
        </div>

        <Controller
          name="cnpj"
          control={control}
          render={({ field }) => (
            <Input
              {...field}
              label="CNPJ"
              error={errors.cnpj?.message}
              placeholder="00.000.000/0000-00"
            />
          )}
        />

        <Controller
          name="telefone"
          control={control}
          render={({ field }) => (
            <Input
              {...field}
              label="Telefone"
              error={errors.telefone?.message}
              placeholder="(00) 00000-0000"
            />
          )}
        />

        <Controller
          name="email"
          control={control}
          render={({ field }) => (
            <Input
              {...field}
              type="email"
              label="E-mail"
              error={errors.email?.message}
              placeholder="fornecedor@exemplo.com"
            />
          )}
        />

        <div className="md:col-span-2">
          <Controller
            name="endereco"
            control={control}
            render={({ field }) => (
              <Input
                {...field}
                label="Endereço"
                error={errors.endereco?.message}
                placeholder="Endereço completo"
              />
            )}
          />
        </div>

        <div className="md:col-span-2">
          <Controller
            name="ativo"
            control={control}
            render={({ field }) => (
              <label className="flex items-center space-x-2">
                <input
                  type="checkbox"
                  checked={field.value}
                  onChange={field.onChange}
                  className="w-4 h-4 text-blue-600 rounded focus:ring-blue-500"
                />
                <span className="text-sm text-gray-700">Fornecedor ativo</span>
              </label>
            )}
          />
        </div>
      </div>

      <div className="flex justify-end space-x-3 pt-4">
        <Button
          type="button"
          variant="outline"
          onClick={onCancel}
          disabled={isSubmitting}
        >
          Cancelar
        </Button>
        <Button type="submit" disabled={isSubmitting}>
          {isSubmitting ? 'Salvando...' : fornecedor ? 'Atualizar' : 'Cadastrar'}
        </Button>
      </div>
    </form>
  );
}
