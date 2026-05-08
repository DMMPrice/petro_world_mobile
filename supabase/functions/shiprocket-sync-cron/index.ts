import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    // Fetch all active orders that have a Shiprocket order ID
    const { data: orders, error } = await supabase
      .from('orders')
      .select('id, shiprocket_order_id, shipment_id, tracking_number, status')
      .in('status', ['ordered', 'processing', 'shipped'])
      .not('shiprocket_order_id', 'is', null)

    if (error) throw error

    console.log(`[shiprocket-sync-cron] Syncing ${orders?.length ?? 0} active orders`)

    const results = await Promise.allSettled(
      (orders ?? []).map(async (order: any) => {
        try {
          const res = await fetch(
            `${Deno.env.get('SUPABASE_URL')}/functions/v1/shiprocket-core/sync`,
            {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}`,
              },
              body: JSON.stringify({
                order_id:        order.id,
                shipment_id:     order.shipment_id,
                tracking_number: order.tracking_number,
              }),
            }
          )
          const data = await res.json()
          console.log(`Order ${order.id}: ${data.current_status ?? 'no status'}`)
          return { id: order.id, success: true, status: data.current_status }
        } catch (e: any) {
          console.error(`Order ${order.id} sync failed:`, e.message)
          return { id: order.id, success: false, error: e.message }
        }
      })
    )

    const succeeded = results.filter(r => r.status === 'fulfilled' && (r.value as any).success).length
    const failed    = results.length - succeeded

    return new Response(
      JSON.stringify({ synced: succeeded, failed, total: results.length }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (err: any) {
    console.error('[shiprocket-sync-cron] Fatal error:', err.message)
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
