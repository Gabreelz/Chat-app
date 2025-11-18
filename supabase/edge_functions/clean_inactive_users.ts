
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  // Precisa de ADMIN para deletar usuários
  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
  
    const oneYearAgo = new Date();
    oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);

    
    const { error } = await supabaseAdmin
      .from('users')
      .delete()
      .lt('last_seen', oneYearAgo.toISOString()) // Usuários inativos por mais de 1 ano

    if (error) throw error

    console.log("Limpeza de usuários inativos concluída.")

    return new Response(JSON.stringify({ success: true }), {
      headers: { "Content-Type": "application/json" },
      status: 200
    })
  } catch (error) {
    console.error("Erro na limpeza:", error.message)
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})