// supabase/functions/update_user_status/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

// Headers de CORS são necessários porque o Flutter chama direto do celular
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Lida com requisição OPTIONS (pre-flight do navegador/app)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Cria o cliente Supabase usando o token do usuário que chamou a função
    // Isso garante que a função sabe QUEM está chamando (req.headers.get('Authorization'))
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    // 2. Verifica quem é o usuário
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser()
    if (userError || !user) throw new Error("Usuário não autenticado")

    // 3. Pega o novo status do corpo da requisição
    const { status } = await req.json() // Ex: { "status": "ONLINE" }

    // 4. Atualiza a tabela de profiles (supondo que você tenha uma coluna 'status' lá)
    const { error: updateError } = await supabaseClient
      .from('users') // ou 'profiles', dependendo do nome da sua tabela
      .update({ status: status, last_seen: new Date() })
      .eq('id', user.id)

    if (updateError) throw updateError

    return new Response(JSON.stringify({ message: "Status atualizado", newStatus: status }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    })
  }
})