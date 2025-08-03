export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instanciate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "12.2.12 (cd3cf9e)"
  }
  public: {
    Tables: {
      caixa: {
        Row: {
          atualizado_em: string
          criado_em: string
          data_abertura: string
          data_fechamento: string | null
          diferenca: number | null
          id: string
          observacoes: string | null
          status: string
          usuario_id: string
          valor_final: number | null
          valor_inicial: number
        }
        Insert: {
          atualizado_em?: string
          criado_em?: string
          data_abertura?: string
          data_fechamento?: string | null
          diferenca?: number | null
          id?: string
          observacoes?: string | null
          status?: string
          usuario_id: string
          valor_final?: number | null
          valor_inicial?: number
        }
        Update: {
          atualizado_em?: string
          criado_em?: string
          data_abertura?: string
          data_fechamento?: string | null
          diferenca?: number | null
          id?: string
          observacoes?: string | null
          status?: string
          usuario_id?: string
          valor_final?: number | null
          valor_inicial?: number
        }
        Relationships: []
      }
      cash_registers: {
        Row: {
          closed_at: string | null
          closed_by: string | null
          closing_amount: number | null
          id: string
          opened_at: string | null
          opened_by: string
          opening_amount: number
          status: string
          total_sales: number | null
        }
        Insert: {
          closed_at?: string | null
          closed_by?: string | null
          closing_amount?: number | null
          id?: string
          opened_at?: string | null
          opened_by: string
          opening_amount?: number
          status?: string
          total_sales?: number | null
        }
        Update: {
          closed_at?: string | null
          closed_by?: string | null
          closing_amount?: number | null
          id?: string
          opened_at?: string | null
          opened_by?: string
          opening_amount?: number
          status?: string
          total_sales?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "cash_registers_closed_by_fkey"
            columns: ["closed_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cash_registers_opened_by_fkey"
            columns: ["opened_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      categories: {
        Row: {
          active: boolean | null
          created_at: string | null
          description: string | null
          id: string
          name: string
          updated_at: string | null
        }
        Insert: {
          active?: boolean | null
          created_at?: string | null
          description?: string | null
          id?: string
          name: string
          updated_at?: string | null
        }
        Update: {
          active?: boolean | null
          created_at?: string | null
          description?: string | null
          id?: string
          name?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      clientes: {
        Row: {
          ativo: boolean | null
          atualizado_em: string | null
          bairro: string | null
          cep: string | null
          cidade: string | null
          complemento: string | null
          cpf_cnpj: string | null
          criado_em: string | null
          email: string | null
          endereco: string | null
          estado: string | null
          id: string
          logradouro: string | null
          nome: string
          numero: string | null
          observacoes: string | null
          ponto_referencia: string | null
          telefone: string | null
          tipo: string
          tipo_logradouro: string | null
        }
        Insert: {
          ativo?: boolean | null
          atualizado_em?: string | null
          bairro?: string | null
          cep?: string | null
          cidade?: string | null
          complemento?: string | null
          cpf_cnpj?: string | null
          criado_em?: string | null
          email?: string | null
          endereco?: string | null
          estado?: string | null
          id?: string
          logradouro?: string | null
          nome: string
          numero?: string | null
          observacoes?: string | null
          ponto_referencia?: string | null
          telefone?: string | null
          tipo?: string
          tipo_logradouro?: string | null
        }
        Update: {
          ativo?: boolean | null
          atualizado_em?: string | null
          bairro?: string | null
          cep?: string | null
          cidade?: string | null
          complemento?: string | null
          cpf_cnpj?: string | null
          criado_em?: string | null
          email?: string | null
          endereco?: string | null
          estado?: string | null
          id?: string
          logradouro?: string | null
          nome?: string
          numero?: string | null
          observacoes?: string | null
          ponto_referencia?: string | null
          telefone?: string | null
          tipo?: string
          tipo_logradouro?: string | null
        }
        Relationships: []
      }
      movimentacoes_caixa: {
        Row: {
          caixa_id: string
          criado_em: string
          data: string
          descricao: string
          id: string
          tipo: string
          usuario_id: string
          valor: number
          venda_id: string | null
        }
        Insert: {
          caixa_id: string
          criado_em?: string
          data?: string
          descricao: string
          id?: string
          tipo: string
          usuario_id: string
          valor: number
          venda_id?: string | null
        }
        Update: {
          caixa_id?: string
          criado_em?: string
          data?: string
          descricao?: string
          id?: string
          tipo?: string
          usuario_id?: string
          valor?: number
          venda_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "movimentacoes_caixa_caixa_id_fkey"
            columns: ["caixa_id"]
            isOneToOne: false
            referencedRelation: "caixa"
            referencedColumns: ["id"]
          },
        ]
      }
      ordens_servico: {
        Row: {
          acessorios: string | null
          atualizado_em: string | null
          checklist: Json | null
          cliente_id: string | null
          criado_em: string | null
          data_entrada: string | null
          data_fim_garantia: string | null
          data_finalizacao: string | null
          data_previsao: string | null
          defeitos_encontrados: string | null
          descricao_problema: string
          descricao_servico: string | null
          equipamento: string | null
          garantia_meses: number | null
          id: string
          marca: string | null
          modelo: string | null
          numero_os: string
          numero_serie: string | null
          observacoes: string | null
          pecas_utilizadas: Json | null
          status: string
          tempo_gasto: unknown | null
          usuario_id: string | null
          valor: number | null
        }
        Insert: {
          acessorios?: string | null
          atualizado_em?: string | null
          checklist?: Json | null
          cliente_id?: string | null
          criado_em?: string | null
          data_entrada?: string | null
          data_fim_garantia?: string | null
          data_finalizacao?: string | null
          data_previsao?: string | null
          defeitos_encontrados?: string | null
          descricao_problema: string
          descricao_servico?: string | null
          equipamento?: string | null
          garantia_meses?: number | null
          id?: string
          marca?: string | null
          modelo?: string | null
          numero_os: string
          numero_serie?: string | null
          observacoes?: string | null
          pecas_utilizadas?: Json | null
          status?: string
          tempo_gasto?: unknown | null
          usuario_id?: string | null
          valor?: number | null
        }
        Update: {
          acessorios?: string | null
          atualizado_em?: string | null
          checklist?: Json | null
          cliente_id?: string | null
          criado_em?: string | null
          data_entrada?: string | null
          data_fim_garantia?: string | null
          data_finalizacao?: string | null
          data_previsao?: string | null
          defeitos_encontrados?: string | null
          descricao_problema?: string
          descricao_servico?: string | null
          equipamento?: string | null
          garantia_meses?: number | null
          id?: string
          marca?: string | null
          modelo?: string | null
          numero_os?: string
          numero_serie?: string | null
          observacoes?: string | null
          pecas_utilizadas?: Json | null
          status?: string
          tempo_gasto?: unknown | null
          usuario_id?: string | null
          valor?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "ordens_servico_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
        ]
      }
      products: {
        Row: {
          active: boolean | null
          barcode: string | null
          category_id: string | null
          cost: number | null
          created_at: string | null
          description: string | null
          id: string
          image_url: string | null
          min_stock: number | null
          name: string
          price: number
          sku: string | null
          stock_quantity: number | null
          unit: string | null
          updated_at: string | null
        }
        Insert: {
          active?: boolean | null
          barcode?: string | null
          category_id?: string | null
          cost?: number | null
          created_at?: string | null
          description?: string | null
          id?: string
          image_url?: string | null
          min_stock?: number | null
          name: string
          price?: number
          sku?: string | null
          stock_quantity?: number | null
          unit?: string | null
          updated_at?: string | null
        }
        Update: {
          active?: boolean | null
          barcode?: string | null
          category_id?: string | null
          cost?: number | null
          created_at?: string | null
          description?: string | null
          id?: string
          image_url?: string | null
          min_stock?: number | null
          name?: string
          price?: number
          sku?: string | null
          stock_quantity?: number | null
          unit?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "products_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "categories"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          active: boolean | null
          avatar_url: string | null
          created_at: string | null
          email: string
          id: string
          name: string
          phone: string | null
          role: string
          updated_at: string | null
        }
        Insert: {
          active?: boolean | null
          avatar_url?: string | null
          created_at?: string | null
          email: string
          id: string
          name: string
          phone?: string | null
          role?: string
          updated_at?: string | null
        }
        Update: {
          active?: boolean | null
          avatar_url?: string | null
          created_at?: string | null
          email?: string
          id?: string
          name?: string
          phone?: string | null
          role?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      sale_items: {
        Row: {
          created_at: string | null
          id: string
          product_id: string
          quantity: number
          sale_id: string
          total_price: number
          unit_price: number
        }
        Insert: {
          created_at?: string | null
          id?: string
          product_id: string
          quantity?: number
          sale_id: string
          total_price: number
          unit_price: number
        }
        Update: {
          created_at?: string | null
          id?: string
          product_id?: string
          quantity?: number
          sale_id?: string
          total_price?: number
          unit_price?: number
        }
        Relationships: [
          {
            foreignKeyName: "sale_items_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sale_items_sale_id_fkey"
            columns: ["sale_id"]
            isOneToOne: false
            referencedRelation: "sales"
            referencedColumns: ["id"]
          },
        ]
      }
      sales: {
        Row: {
          cash_register_id: string
          created_at: string | null
          customer_id: string | null
          discount_amount: number | null
          id: string
          notes: string | null
          payment_details: Json | null
          payment_method: string
          status: string
          total_amount: number
          updated_at: string | null
          user_id: string
        }
        Insert: {
          cash_register_id: string
          created_at?: string | null
          customer_id?: string | null
          discount_amount?: number | null
          id?: string
          notes?: string | null
          payment_details?: Json | null
          payment_method: string
          status?: string
          total_amount?: number
          updated_at?: string | null
          user_id: string
        }
        Update: {
          cash_register_id?: string
          created_at?: string | null
          customer_id?: string | null
          discount_amount?: number | null
          id?: string
          notes?: string | null
          payment_details?: Json | null
          payment_method?: string
          status?: string
          total_amount?: number
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "sales_cash_register_id_fkey"
            columns: ["cash_register_id"]
            isOneToOne: false
            referencedRelation: "cash_registers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sales_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      service_orders: {
        Row: {
          brand: string | null
          created_at: string | null
          customer_id: string
          defect_description: string
          delivered_at: string | null
          equipment: string
          estimated_cost: number | null
          estimated_delivery: string | null
          final_cost: number | null
          id: string
          model: string | null
          notes: string | null
          priority: string | null
          serial_number: string | null
          service_description: string | null
          status: string
          updated_at: string | null
          user_id: string
        }
        Insert: {
          brand?: string | null
          created_at?: string | null
          customer_id: string
          defect_description: string
          delivered_at?: string | null
          equipment: string
          estimated_cost?: number | null
          estimated_delivery?: string | null
          final_cost?: number | null
          id?: string
          model?: string | null
          notes?: string | null
          priority?: string | null
          serial_number?: string | null
          service_description?: string | null
          status?: string
          updated_at?: string | null
          user_id: string
        }
        Update: {
          brand?: string | null
          created_at?: string | null
          customer_id?: string
          defect_description?: string
          delivered_at?: string | null
          equipment?: string
          estimated_cost?: number | null
          estimated_delivery?: string | null
          final_cost?: number | null
          id?: string
          model?: string | null
          notes?: string | null
          priority?: string | null
          serial_number?: string | null
          service_description?: string | null
          status?: string
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "service_orders_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      stock_movements: {
        Row: {
          created_at: string | null
          id: string
          product_id: string
          quantity: number
          reason: string
          reference_id: string | null
          reference_type: string | null
          type: string
          user_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          product_id: string
          quantity: number
          reason: string
          reference_id?: string | null
          reference_type?: string | null
          type: string
          user_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          product_id?: string
          quantity?: number
          reason?: string
          reference_id?: string | null
          reference_type?: string | null
          type?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "stock_movements_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_movements_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      check_auth_config: {
        Args: Record<PropertyKey, never>
        Returns: {
          setting_name: string
          current_value: string
          recommended_value: string
          status: string
          instructions: string
        }[]
      }
      check_email_config: {
        Args: Record<PropertyKey, never>
        Returns: {
          setting_name: string
          current_value: string
          recommended_value: string
          status: string
        }[]
      }
      get_confirmation_url: {
        Args: { user_email: string }
        Returns: string
      }
      get_dashboard_summary: {
        Args: Record<PropertyKey, never>
        Returns: Json
      }
      get_low_stock_products: {
        Args: { min_stock_threshold?: number }
        Returns: {
          product_id: string
          name: string
          current_stock: number
          min_stock: number
          category_name: string
        }[]
      }
      get_sales_report: {
        Args: { start_date?: string; end_date?: string }
        Returns: {
          total_sales: number
          total_amount: number
          avg_sale_amount: number
          top_products: Json
        }[]
      }
      update_cash_register_sales: {
        Args: { register_id: string; sale_amount: number }
        Returns: undefined
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
