
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

serve(async (req) => {
  
  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  
  const payload = await req.json()
  const newMessage = payload.record

  console.log("Nova mensagem recebida:", newMessage.id)

  try {
    
    const { data: participants, error: partError } = await supabaseAdmin
      .from('participants')
      .select('user_id')
      .eq('conversation_id', newMessage.conversation_id)
      .neq('user_id', newMessage.sender_id) // Não notificar o próprio remetente

    if (partError) throw partError

    for (const p of participants) {
   
      console.log(`[SIMULAÇÃO FCM] Enviando push para user ${p.user_id}: "Nova mensagem: ${newMessage.content?.substring(0, 20)}..."`)
      
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { "Content-Type": "application/json" },
      status: 200
    })

  } catch (error) {
    console.error("Erro na notification:", error.message)
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})