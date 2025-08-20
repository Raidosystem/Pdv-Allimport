📋 GUIA COMPLETO: CONFIGURAR STORAGE NO SUPABASE
=================================================

🎯 OBJETIVO: Resolver o erro "Storage não configurado" para permitir upload de logos

📝 PASSO A PASSO:

1️⃣ ACESSAR O SUPABASE
   • Vá para: https://supabase.com/dashboard
   • Faça login na sua conta
   • Selecione seu projeto PDV

2️⃣ ABRIR O SQL EDITOR
   • No menu lateral, clique em "SQL Editor"
   • Clique em "New query" ou use uma aba existente

3️⃣ EXECUTAR O SCRIPT
   • Copie TODO o conteúdo do arquivo CONFIGURAR_STORAGE_EMPRESAS.sql
   • Cole no SQL Editor
   • Clique em "RUN" (botão azul no canto inferior direito)

4️⃣ VERIFICAR RESULTADOS
   Você deve ver estas mensagens de sucesso:
   ✅ "Bucket criado com sucesso"
   ✅ "Política ativa" (para todas as políticas)
   ✅ "Storage para logos das empresas configurado com sucesso!"

5️⃣ TESTAR NO SISTEMA
   • Volte para sua aplicação web
   • Vá em "Configurações da Empresa"
   • Tente fazer upload de uma logo
   • O erro "Storage não configurado" deve desaparecer

🚨 SE AINDA DER ERRO:
   Execute este comando alternativo no SQL Editor:

   -- Comando simples para criar bucket
   INSERT INTO storage.buckets (id, name, public) 
   VALUES ('empresas', 'empresas', true)
   ON CONFLICT (id) DO NOTHING;

   -- Política básica para upload
   CREATE POLICY "allow_uploads_empresas" ON storage.objects
   FOR ALL USING (bucket_id = 'empresas' AND auth.uid() IS NOT NULL);

📞 SUPORTE:
   Se o problema persistir, verifique:
   • Se você está logado como administrador no Supabase
   • Se o projeto está ativo
   • Se não há limites de quota excedidos

🔗 LINKS ÚTEIS:
   • Supabase Dashboard: https://supabase.com/dashboard
   • Seu projeto: [Verifique na dashboard]
   • SQL Editor: [Projeto] → SQL Editor

⏰ TEMPO ESTIMADO: 2-3 minutos

✨ RESULTADO ESPERADO:
   Upload de logos funcionando perfeitamente na seção "Configurações da Empresa"

=================================================
