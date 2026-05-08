import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const SHIPROCKET_API_URL = "https://apiv2.shiprocket.in/v1/external"

const SHIPROCKET_EMAIL = Deno.env.get('SHIPROCKET_EMAIL') || ''
const SHIPROCKET_PASSWORD = Deno.env.get('SHIPROCKET_PASSWORD') || ''
const PICKUP_PINCODE = Deno.env.get('SHIPROCKET_PICKUP_PINCODE') || '110001' // Default if not set

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { pincode, weight = 0.5 } = await req.json()

    if (!pincode) {
      return new Response(JSON.stringify({ error: 'Pincode is required' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      })
    }

    // 1. Login to Shiprocket
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

    // 2. Check Serviceability
    // GET /courier/serviceability?pickup_postcode={origin}&delivery_postcode={destination}&weight={weight}
    const serviceabilityUrl = `${SHIPROCKET_API_URL}/courier/serviceability?pickup_postcode=${PICKUP_PINCODE}&delivery_postcode=${pincode}&weight=${weight}`
    
    const serviceResponse = await fetch(serviceabilityUrl, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    })

    const serviceData = await serviceResponse.json()
    
    if (!serviceResponse.ok || !serviceData.status || serviceData.status !== 200) {
      return new Response(JSON.stringify({ 
        success: false, 
        message: serviceData.message || 'Pincode not serviceable' 
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Shiprocket returns available courier companies and their ETDs
    // We'll take the first available one or find the fastest
    const recommendation = serviceData.data.available_courier_companies[0]
    
    if (!recommendation) {
      return new Response(JSON.stringify({ success: false, message: 'No courier available for this location' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    return new Response(JSON.stringify({ 
      success: true, 
      etd: recommendation.etd,
      estimated_delivery_days: recommendation.estimated_delivery_days,
      courier_name: recommendation.courier_name
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
