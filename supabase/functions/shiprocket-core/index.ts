import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const SHIPROCKET_API_URL = "https://apiv2.shiprocket.in/v1/external"
const SHIPROCKET_EMAIL = Deno.env.get('SHIPROCKET_EMAIL') || ''
const SHIPROCKET_PASSWORD = Deno.env.get('SHIPROCKET_PASSWORD') || ''
const DEFAULT_PICKUP_LOCATION = Deno.env.get('SHIPROCKET_PICKUP_LOCATION') || 'warehouse'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const jsonRes = (data: unknown, status = 200) =>
  new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })

async function shiprocketLogin() {
  const res = await fetch(`${SHIPROCKET_API_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: SHIPROCKET_EMAIL, password: SHIPROCKET_PASSWORD }),
  })
  const data = await res.json()
  if (!res.ok) throw new Error(`Shiprocket Auth Failed: ${data.message || 'Check credentials'}`)
  return data.token as string
}

// Map Shiprocket courier status → our DB status
const STATUS_MAP: Record<string, string> = {
  'Delivered':        'delivered',
  'Canceled':         'canceled',
  'RTO':              'returned',
  'RTO Delivered':    'returned',
  'In Transit':       'shipped',
  'Shipped':          'shipped',
  'Out for Delivery': 'shipped',
  'Pickup Scheduled': 'processing',
  'Pickup Generated': 'processing',
  'AWB Assigned':     'processing',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  const url = new URL(req.url)
  const path = url.pathname.split('/').pop()

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {

    // ── CREATE: Push order to Shiprocket ───────────────────────────────────
    if (path === 'create') {
      const { order_id } = await req.json()

      const { data: order, error: orderErr } = await supabase
        .from('orders')
        .select('*, profiles:user_id(*), addresses:address_id(*), order_items(*)')
        .eq('id', order_id)
        .single()
      if (orderErr || !order) throw new Error(`Order not found: ${orderErr?.message}`)

      const productIds = order.order_items.map((i: any) => i.product_id)
      const { data: products } = await supabase.from('products').select('*').in('id', productIds)

      let totalWeight = 0, maxLength = 0, maxWidth = 0, totalHeight = 0
      order.order_items.forEach((item: any) => {
        const p = products?.find((x: any) => x.id === item.product_id)
        totalWeight += (Number(p?.weight) || 0.5) * item.quantity
        maxLength   = Math.max(maxLength, Number(p?.length) || 10)
        maxWidth    = Math.max(maxWidth,  Number(p?.width)  || 10)
        totalHeight += (Number(p?.height) || 10) * item.quantity
      })
      totalWeight = Math.max(Number(totalWeight.toFixed(2)), 0.1)
      maxLength   = Math.max(maxLength,   10)
      maxWidth    = Math.max(maxWidth,    10)
      totalHeight = Math.max(totalHeight, 10)

      const payload: any = {
        order_id:              order.order_number,
        order_date:            new Date(order.created_at).toISOString().split('T')[0],
        pickup_location:       DEFAULT_PICKUP_LOCATION,
        billing_customer_name: order.profiles?.first_name || 'Customer',
        billing_last_name:     order.profiles?.last_name  || '',
        billing_address:       order.addresses?.address   || 'N/A',
        billing_city:          order.addresses?.city      || 'City',
        billing_pincode:       order.addresses?.pincode   || '000000',
        billing_state:         order.addresses?.state     || 'State',
        billing_country:       'India',
        billing_email:         order.profiles?.email      || 'customer@example.com',
        billing_phone:         order.addresses?.phone_number || order.profiles?.phone_number || '0000000000',
        shipping_is_billing:   true,
        order_items:           order.order_items.map((item: any) => ({
          name:          products?.find((x: any) => x.id === item.product_id)?.title || 'Product',
          sku:           item.product_id,
          units:         item.quantity,
          selling_price: item.price_at_purchase,
        })),
        payment_method: order.payment_method === 'Cash on Delivery' ? 'COD' : 'Prepaid',
        sub_total:      order.total_amount,
        length:         maxLength,
        breadth:        maxWidth,
        height:         totalHeight,
        weight:         totalWeight,
      }

      const token = await shiprocketLogin()

      let createRes = await fetch(`${SHIPROCKET_API_URL}/orders/create/adhoc`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify(payload),
      })
      let createData = await createRes.json()
      console.log('Shiprocket create response:', JSON.stringify(createData))

      // Auto-retry with correct pickup location
      if (createData.message?.toLowerCase().includes('pickup location') && createData.data?.data?.length > 0) {
        payload.pickup_location = createData.data.data[0].pickup_location
        createRes  = await fetch(`${SHIPROCKET_API_URL}/orders/create/adhoc`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
          body: JSON.stringify(payload),
        })
        createData = await createRes.json()
      }

      // Recover existing order if duplicate
      if (createData.message?.toLowerCase().includes('already exists')) {
        const listRes  = await fetch(`${SHIPROCKET_API_URL}/orders?search=${order.order_number}`, {
          headers: { 'Authorization': `Bearer ${token}` },
        })
        const listData = await listRes.json()
        const existing = listData.data?.find((o: any) => o.channel_order_id === order.order_number)
        if (existing) createData = { order_id: existing.id, shipment_id: existing.shipments?.[0]?.id }
      }

      if (!createData.order_id) {
        throw new Error(`Shiprocket rejected: ${createData.message || 'Unknown'} — ${JSON.stringify(createData.errors ?? {})}`)
      }

      await supabase.from('orders').update({
        shiprocket_order_id: createData.order_id.toString(),
        shipment_id:         createData.shipment_id?.toString() ?? null,
        status:              'processing',
        courier_status:      'Order Created',
      }).eq('id', order_id)

      return jsonRes({ success: true, shiprocket_order_id: createData.order_id })
    }

    // ── SYNC: Pull latest status + AWB from Shiprocket ────────────────────
    if (path === 'sync') {
      const { order_id, shipment_id, tracking_number } = await req.json()
      if (!shipment_id && !tracking_number) throw new Error('shipment_id or tracking_number required')

      const token = await shiprocketLogin()
      let awbCode = tracking_number
      let currentStatus = 'Processing'
      let activities: any[] = []
      let labelUrl: string | null = null
      let courierName: string | null = null

      // If no AWB yet, check if Shiprocket assigned one via shipment details
      if (!awbCode && shipment_id) {
        const shipRes  = await fetch(`${SHIPROCKET_API_URL}/courier/track/shipment/${shipment_id}`, {
          headers: { 'Authorization': `Bearer ${token}` },
        })
        const shipData = await shipRes.json()
        console.log('Shipment track response:', JSON.stringify(shipData))
        awbCode     = shipData.tracking_data?.shipment_track?.[0]?.awb || null
        currentStatus = shipData.tracking_data?.shipment_track?.[0]?.current_status || 'Processing'
        activities  = shipData.tracking_data?.shipment_track_activities || []
        courierName = shipData.tracking_data?.shipment_track?.[0]?.courier_name || null
      }

      // If AWB is now known, fetch detailed tracking
      if (awbCode) {
        const trackRes  = await fetch(`${SHIPROCKET_API_URL}/courier/track/awb/${awbCode}`, {
          headers: { 'Authorization': `Bearer ${token}` },
        })
        const trackData = await trackRes.json()
        currentStatus   = trackData.tracking_data?.shipment_track?.[0]?.current_status || currentStatus
        activities      = trackData.tracking_data?.shipment_track_activities || activities
        courierName     = trackData.tracking_data?.shipment_track?.[0]?.courier_name || courierName

        // Try to fetch label URL from shipment details
        if (!labelUrl && shipment_id) {
          const labelRes  = await fetch(`${SHIPROCKET_API_URL}/orders/print/manifest`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
            body: JSON.stringify({ shipment_id: [parseInt(shipment_id)] }),
          })
          const labelData = await labelRes.json()
          labelUrl = labelData.manifest_url || null
        }
      }

      const update: any = { courier_status: currentStatus }
      if (awbCode)     update.tracking_number       = awbCode
      if (labelUrl)    update.shipping_label_url     = labelUrl
      if (courierName) update.courier_name           = courierName
      if (activities.length > 0) update.logistics_history = activities
      if (STATUS_MAP[currentStatus]) update.status   = STATUS_MAP[currentStatus]

      await supabase.from('orders').update(update).eq('id', order_id)

      return jsonRes({ success: true, tracking_number: awbCode, current_status: currentStatus, activities, label_url: labelUrl })
    }

    // ── CANCEL: Cancel on Shiprocket + update DB ───────────────────────────
    if (path === 'cancel') {
      const { order_id, is_return } = await req.json()

      const { data: order } = await supabase
        .from('orders')
        .select('shiprocket_order_id, shipment_id, status')
        .eq('id', order_id)
        .single()

      // Try to cancel on Shiprocket if we have the order ID
      if (order?.shiprocket_order_id) {
        try {
          const token = await shiprocketLogin()
          if (is_return) {
            // Return pickup request (for delivered orders)
            await fetch(`${SHIPROCKET_API_URL}/orders/return`, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
              body: JSON.stringify({
                order_id:        parseInt(order.shiprocket_order_id),
                order_date:      new Date().toISOString().split('T')[0],
                channel_id:      '',
                pickup_customer_name: 'Customer',
                pickup_address:  '',
                pickup_city:     '',
                pickup_state:    '',
                pickup_country:  'India',
                pickup_pincode:  '',
                pickup_email:    '',
                pickup_phone:    '',
                shipping_customer_name: 'PetroWorld',
                shipping_address: '',
                shipping_city:    '',
                shipping_country: 'India',
                shipping_pincode: '',
                shipping_state:   '',
                shipping_email:   '',
                shipping_phone:   '',
                order_items:      [],
                payment_method:   'Prepaid',
                sub_total:        0,
                length: 10, breadth: 10, height: 10, weight: 0.5,
              }),
            })
          } else {
            // Outright cancellation
            await fetch(`${SHIPROCKET_API_URL}/orders/cancel`, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
              body: JSON.stringify({ ids: [parseInt(order.shiprocket_order_id)] }),
            })
          }
        } catch (e) {
          console.warn('Shiprocket cancel API error (non-fatal):', e)
        }
      }

      // Always update DB regardless of Shiprocket API success
      await supabase.from('orders').update({
        status:         is_return ? 'returned' : 'canceled',
        courier_status: is_return ? 'Return Requested' : 'Canceled',
      }).eq('id', order_id)

      return jsonRes({ success: true })
    }

    throw new Error('Invalid endpoint. Use /create, /sync, or /cancel.')

  } catch (err: any) {
    console.error('[shiprocket-core] Error:', err.message)
    return jsonRes({ success: false, error: err.message })
  }
})
