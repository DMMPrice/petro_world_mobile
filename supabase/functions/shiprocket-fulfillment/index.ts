import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const SHIPROCKET_API_URL = "https://apiv2.shiprocket.in/v1/external"

// PLACEHOLDERS FOR CREDENTIALS
// In production, these should be set via Supabase Secrets:
// supabase secrets set SHIPROCKET_EMAIL=your@email.com
// supabase secrets set SHIPROCKET_PASSWORD=your_password
const SHIPROCKET_EMAIL = Deno.env.get('SHIPROCKET_EMAIL') || 'YOUR_SHIPROCKET_EMAIL'
const SHIPROCKET_PASSWORD = Deno.env.get('SHIPROCKET_PASSWORD') || 'YOUR_SHIPROCKET_PASSWORD'
const PICKUP_LOCATION = Deno.env.get('SHIPROCKET_PICKUP_LOCATION') || 'Primary'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { order_id } = await req.json()

    if (!order_id) {
      return new Response(JSON.stringify({ error: 'Order ID is required' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      })
    }

    // 1. Fetch Order and Customer Details
    const { data: order, error: orderError } = await supabaseClient
      .from('orders')
      .select(`
        *,
        profiles:user_id (*),
        addresses:address_id (*),
        order_items (*)
      `)
      .eq('id', order_id)
      .single()

    if (orderError || !order) {
      throw new Error(`Order not found: ${orderError?.message}`)
    }

    // 2. Fetch Product Details (Weight/Dimensions) for all items
    const productIds = order.order_items.map((item: any) => item.product_id)
    const { data: products, error: productsError } = await supabaseClient
      .from('products')
      .select('id, title, weight, length, width, height')
      .in('id', productIds)

    if (productsError) throw productsError

    // 3. Login to Shiprocket
    const authResponse = await fetch(`${SHIPROCKET_API_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: SHIPROCKET_EMAIL,
        password: SHIPROCKET_PASSWORD,
      }),
    })

    const authData = await authResponse.json()
    if (!authResponse.ok) throw new Error(`Shiprocket Auth Failed: ${authData.message}`)
    const token = authData.token

    // 4. Map PetroWorld Order to Shiprocket Ad-hoc Order
    const shiprocketOrderItems = order.order_items.map((item: any) => {
      const product = products.find((p: any) => p.id === item.product_id)
      return {
        name: product?.title || 'Unknown Product',
        sku: product?.id || 'SKU-UNKNOWN',
        units: item.quantity,
        selling_price: item.price_at_purchase,
        discount: 0,
        tax: 0,
        hsn: 0
      }
    })

    // Calculate total weight (sum of weights * quantities)
    const totalWeight = order.order_items.reduce((sum: number, item: any) => {
      const product = products.find((p: any) => p.id === item.product_id)
      return sum + ((product?.weight || 0.5) * item.quantity)
    }, 0)

    const payload = {
      order_id: order.order_number || order.id,
      order_date: new Date(order.created_at).toISOString().split('T')[0],
      pickup_location: PICKUP_LOCATION,
      billing_customer_name: order.profiles.first_name,
      billing_last_name: order.profiles.last_name || '',
      billing_address: order.addresses.address,
      billing_city: order.addresses.city || "New Delhi",
      billing_pincode: order.addresses.pincode || "110001", 
      billing_state: order.addresses.state || "Delhi",
      billing_country: "India",
      billing_email: order.profiles.email,
      billing_phone: order.addresses.phone_number || order.profiles.phone_number,
      shipping_is_billing: true,
      order_items: shiprocketOrderItems,
      payment_method: order.payment_method === 'COD' ? 'COD' : 'Prepaid',
      sub_total: order.total_amount,
      length: 10, // Default dimensions if not complex
      width: 10,
      height: 10,
      weight: totalWeight
    }

    // 5. Create Order in Shiprocket
    const createOrderResponse = await fetch(`${SHIPROCKET_API_URL}/orders/create/adhoc`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify(payload),
    })

    const createOrderData = await createOrderResponse.json()
    if (!createOrderResponse.ok) throw new Error(`Shiprocket Order Creation Failed: ${createOrderData.message}`)

    const shiprocketOrderId = createOrderData.order_id
    const shipmentId = createOrderData.shipment_id

    // 6. Assign AWB (Tracking Number)
    // You can let Shiprocket choose the best courier automatically
    const assignAwbResponse = await fetch(`${SHIPROCKET_API_URL}/courier/assign/awb`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ shipment_id: shipmentId }),
    })

    const assignAwbData = await assignAwbResponse.json()
    const trackingNumber = assignAwbData.response?.data?.awb_code || null

    // 7. Update Supabase Order
    const { error: updateError } = await supabaseClient
      .from('orders')
      .update({
        shiprocket_order_id: shiprocketOrderId.toString(),
        shipment_id: shipmentId.toString(),
        tracking_number: trackingNumber,
        courier_status: trackingNumber ? 'Booked' : 'Pending',
        shipping_provider: 'Shiprocket'
      })
      .eq('id', order_id)

    if (updateError) throw updateError

    return new Response(JSON.stringify({ 
      success: true, 
      shiprocket_order_id: shiprocketOrderId,
      tracking_number: trackingNumber 
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
